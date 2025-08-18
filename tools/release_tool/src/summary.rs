use crate::prompt_bool;
use indicatif::{MultiProgress, ProgressBar, ProgressStyle};
use regex::Regex;
use std::ffi::OsStr;
use std::fs;
use std::io::{BufReader, Read};
use std::os::unix::prelude::OsStrExt;
use std::path::PathBuf;
use std::process::{exit, Command, Stdio};

/// Summary of actions that will be taken
#[derive(Debug, Default)]
pub struct Summary {
    pub root: PathBuf,
    /// E.g. `version: 1.8.8+50`
    pub new_version_line: Option<String>,
    pub update_flutter: bool,
    pub update_dependencies: bool,
    pub run_tests: bool,
    pub build: bool,
}

impl Summary {
    pub fn print(&self) {
        println!("Summary:\n\
        > root = {}\n\
        > new_version_line = {:?}\n\
        > update_flutter = {}\n\
        > update_dependencies = {}\n\
        > run_tests = {}\n\
        > build = {}",
                &self.root.to_string_lossy(),
                &self.new_version_line,
                &self.update_flutter,
                &self.update_dependencies,
                &self.run_tests,
                &self.build);
    }

    /// Apply this config to the file system.
    pub fn apply(&self) {
        // Order:
        // 1. update flutter
        // 2. Write new app and flutter verrsion to pubspec
        // 3. update dependencies
        // 4. run tests and build
        let spinner_style = ProgressStyle::with_template("{prefix:.bold.dim} {spinner} {wide_msg}")
            .unwrap()
            .tick_chars("⠁⠂⠄⡀⢀⠠⠐⠈ ");
        let m = MultiProgress::new();

        if self.update_flutter {
            let pb = m.add(ProgressBar::new_spinner());
            pb.set_style(spinner_style.clone());
            pb.set_prefix("$ flutter upgrade");
            pb.set_message("Starting...");

            let child = Command::new("flutter")
                .arg("upgrade")
                .stdout(Stdio::piped())
                .spawn();
            if let Ok(mut child) = child {
                let mut stdout = child.stdout.take().unwrap();
                pb.set_message("Started");
                loop {
                    let mut buf = [0;255];
                    match stdout.read(&mut buf) {
                        Err(err) => {
                            println!("{}] Error reading from stream: {}", line!(), err);
                            break;
                        }
                        Ok(got) => {
                            if got == 0 {
                                break;
                            } else {
                                let msg = OsStr::from_bytes(&buf)
                                    .to_string_lossy();
                                pb.println(msg);
                            }
                        }
                    }
                }
                pb.set_message("Stopped reading from stdout");
                child.wait().unwrap();
                pb.finish_with_message("Completed");
            } else if let Err(err) = child {
                pb.println(format!("{}", err));
                pb.finish_with_message("flutter upgrade failed");
            }
        }

        let current_flutter_version = {
            let pb = m.add(ProgressBar::new_spinner());
            pb.set_style(spinner_style.clone());
            pb.set_prefix("$ flutter --version");
            pb.set_message("Starting...");
            let ouput = Command::new("flutter").arg("--version").stdout(Stdio::piped()).output().unwrap();
            pb.set_message("Extracting version...");
            if !ouput.status.success() {
                pb.println(format!("{}", String::from_utf8_lossy(&ouput.stderr)));
                exit(1);
            }
            pb.finish_with_message("Completed");
            let output = String::from_utf8_lossy(&ouput.stdout);
            let version = output.split(" ").nth(1).unwrap();
            version.to_string()
        };

        if self.update_dependencies {
            let pb = m.add(ProgressBar::new_spinner());
            pb.set_style(spinner_style.clone());
            pb.set_prefix("Updating dependencies");

            pb.set_message("health_data_store pub deps");
            Self::spawn_propagating_logs(
                Command::new("dart")
                            .arg("pub").arg("upgrade")
                            .arg("--tighten").arg("--major-versions")
                            .current_dir(&self.root.join("health_data_store")),
                    &pb,
            );

            pb.set_message("health_data_store generate");
            Self::spawn_propagating_logs(
                Command::new("dart")
                            .arg("run").arg("build_runner").arg("build")
                            .arg("--delete-conflicting-outputs")
                            .current_dir(&self.root.join("health_data_store")),
                    &pb,
            );

            pb.set_message("app pub deps");
            Self::spawn_propagating_logs(
                Command::new("flutter")
                            .arg("pub").arg("upgrade")
                            .arg("--tighten").arg("--major-versions")
                            .current_dir(&self.root.join("app")),
                    &pb,
            );

            pb.set_message("app generate");
            Self::spawn_propagating_logs(
                Command::new("flutter").arg("pub")
                            .arg("run").arg("build_runner").arg("build")
                            .arg("--delete-conflicting-outputs")
                            .current_dir(&self.root.join("app")),
                    &pb,
            );

            pb.finish_with_message("Completed");
        }

        if self.update_flutter || self.new_version_line.is_some() {
            _ = m.println("Updating pubspec.yaml");
            let pubspec = fs::read_to_string(self.root.join("app").join("pubspec.yaml")).unwrap();
            let version_re = Regex::new(r"flutter: '\d*.\d*.\d*'").unwrap();
            let pubspec = version_re.replace(pubspec.as_str(), format!("flutter: '{current_flutter_version}'"));

            let pubspec = if let Some(new_version_line) = &self.new_version_line {
                let version_re = Regex::new(r"version:\s*\d*.\d*.\d*\+\d*").unwrap();
                version_re.replace(&pubspec, new_version_line)
            } else { pubspec };

            fs::write(self.root.join("app").join("pubspec.yaml"), pubspec.to_string()).unwrap();
        }

        if self.run_tests {
            let pb = m.add(ProgressBar::new_spinner());
            pb.set_style(spinner_style.clone());
            pb.set_prefix("Running tests");

            pb.set_message("Testing health_data_store");
            let libs_ok = Self::spawn_propagating_logs(
                Command::new("dart").arg("test")
                    .current_dir(&self.root.join("health_data_store")),
                &pb,
            );

            pb.set_message("Testing app");
            let app_ok = Self::spawn_propagating_logs(
                Command::new("flutter").arg("test")
                    .current_dir(&self.root.join("app")),
                &pb,
            );

            if !libs_ok || !app_ok {
                if !prompt_bool("App or Library tests failed. Do you want to proceed?", None).unwrap_or(false) {
                    exit(0);
                }
            }

            pb.finish();
        }

        if self.build {
            let pb = m.add(ProgressBar::new_spinner());
            pb.set_style(spinner_style.clone());
            pb.set_prefix("Build App");

            pb.set_message("Cleaning...");
            Self::spawn_propagating_logs(
                Command::new("flutter").arg("clean")
                        .current_dir(&self.root.join("app")),
                    &pb,
            );

            pb.set_message("Build APK...");
            let debug_info_path = self.root
                .join("app")
                .join("build")
                .join("debug_info");
            Self::spawn_propagating_logs(
                Command::new("flutter").arg("build").arg("apk")
                        .arg("--release").arg("--flavor").arg("github")
                        .arg("--obfuscate").arg(format!("--split-debug-info={}", debug_info_path.display()))
                        .current_dir(&self.root.join("app")),
                    &pb,
            );

            pb.set_message("Build bundle...");
            Self::spawn_propagating_logs(
                Command::new("flutter").arg("build").arg("appbundle")
                        .arg("--release").arg("--flavor").arg("github")
                        .arg("--obfuscate").arg(format!("--split-debug-info={}", debug_info_path.display()))
                        .current_dir(&self.root.join("app")),
                    &pb,
            );

            pb.set_message("Compressing debug symbols");
            Command::new("zip")
                .arg("-r").arg("debug-info.zip").arg(".") // zip everything in debug_info
                .current_dir(&debug_info_path)
                .status().unwrap();

            // Clean target dir and copy files
            pb.set_message("Copying outputs");
            let target_dir = self.root.join("target");
            if target_dir.exists() {
                fs::remove_dir_all(&target_dir).unwrap();
            }
            fs::create_dir_all(&target_dir).unwrap();
            let out_base = self.root.join("app").join("build").join("app").join("outputs");
            let apk_path = out_base.join("flutter-apk").join("app-github-release.apk");
            let aab_path = out_base.join("bundle").join("githubRelease").join("app-github-release.aab");
            let zip_path = debug_info_path.join("debug-info.zip");

            fs::copy(&apk_path, target_dir.join("app-github-release.apk")).unwrap();
            fs::copy(&aab_path, target_dir.join("app-github-release.aab")).unwrap();
            fs::copy(&zip_path, target_dir.join("debug-info.zip")).unwrap();

            pb.finish();
        }
    }

     fn spawn_propagating_logs(cmd: &mut Command, pb: &ProgressBar) -> bool {
        let child = cmd.stdout(Stdio::piped()).spawn();
        if let Ok(mut child) = child {
            let stdout = child.stdout.take().unwrap();
            let mut reader = BufReader::new(stdout);
            let mut line_buf: Vec<u8> = Vec::new();
            let mut read_buf = [0; 1024];

            while let Ok(n) = reader.read(&mut read_buf) {
                if n == 0 {
                    break;
                }

                for &byte in &read_buf[..n] {
                    match byte {
                        b'\n' | b'\r' => {
                            pb.println(&String::from_utf8_lossy(&line_buf));
                            pb.force_draw();
                            line_buf.clear();
                        }
                        _ => {
                            line_buf.push(byte);
                        }
                    }
                }
            }

            if !line_buf.is_empty() {
                pb.println(&String::from_utf8_lossy(&line_buf));
            }

            // FIXME: continuously updating flutter test line doesn't update.
            return child.wait().is_ok_and(|e| e.success())
        }
         false
    }
}
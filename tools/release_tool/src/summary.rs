use std::ffi::OsStr;
use std::io::{BufRead, BufReader, Read};
use std::os::unix::prelude::OsStrExt;
use std::os::unix::process::CommandExt;
use std::path::PathBuf;
use std::process::{exit, Command, Stdio};
use indicatif::{MultiProgress, ProgressBar, ProgressStyle};

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
            let version = output.split(" ").nth(2).unwrap();
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

        assert!(!self.run_tests, "unimplemented");

        // TODO: update pubspec.yaml here

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
            Self::spawn_propagating_logs(
                Command::new("flutter").arg("build").arg("apk")
                        .arg("--release").arg("--flavor").arg("github")
                        .arg("--obfuscate").arg("--split-debug-info=./build/debug-info")
                        .current_dir(&self.root.join("app")),
                    &pb,
            );

            pb.set_message("Build bundle...");
            Self::spawn_propagating_logs(
                Command::new("flutter").arg("build").arg("appbundle")
                        .arg("--release").arg("--flavor").arg("github")
                        .arg("--obfuscate").arg("--split-debug-info=./build/debug-info")
                        .current_dir(&self.root.join("app")),
                    &pb,
            );

            pb.set_message("Compressing debug symbols");
            Command::new("zip").arg("debug-info.zip").arg("debug-info/*")
                .current_dir(&self.root.join("app").join("target"))
                .output().unwrap();

            // TODO: copy files to useful location

            pb.finish();
        }
    }

     fn spawn_propagating_logs(cmd: &mut Command, pb: &ProgressBar) {
        let child = cmd.stdout(Stdio::piped()).spawn();
        if let Ok(mut child) = child {
            let stdout = child.stdout.take().unwrap();
            let mut bufread = BufReader::new(stdout);
            let mut buf = String::new();

            while let Ok(n) = bufread.read_line(&mut buf) {
                if n > 0 {
                    pb.println(&buf);
                    buf.clear();
                } else {
                    break;
                }
            }
        }
    }
}
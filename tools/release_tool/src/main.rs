mod summary;

use crate::summary::Summary;
use anyhow::{bail, Context, Result};
use regex::Regex;
use std::io::Write;
use std::{env, fs, io, path::PathBuf};

fn main() -> Result<()>{
    let mut summary = Summary::default();

    summary.root = git_dir()
        .context("Couldn't find repository root")?;
    println!("Using repository at {:?}", summary.root);

    let version = get_version(&summary.root)
        .context("Couldn't read current app version")?;
    println!("Current app version is {} ({})", &version.0, &version.1);

    let bump_version = prompt_bool(format!("Bump app version ({}->{})?", version.1, version.1 + 1).as_str(), Some(true))?;
    if bump_version {
        print!("Version name (e.g. {}): ", version.0);
        io::stdout().flush()?;
        let mut buffer = String::new();
        io::stdin().read_line(&mut buffer)?;
        let regex = Regex::new(r"(\d+).(\d+).(\d+)")?;
        if regex.is_match(&buffer) {
            /*
            let old_parts = regex.captures(&buffer).context("Couldn't parse old version")?;
            let new_parts = regex.captures(&buffer).context("Couldn't parse new version")?;
            if (new_parts.get(1).unwrap().as_str().parse::<usize>()? // TODO: This is wrong
                    < new_parts.get(1).unwrap().as_str().parse::<usize>()?)
                || (new_parts.get(2).unwrap().as_str().parse::<usize>()?
                    < new_parts.get(2).unwrap().as_str().parse::<usize>()?)
                || (new_parts.get(3).unwrap().as_str().parse::<usize>()?
                    < new_parts.get(3).unwrap().as_str().parse::<usize>()?){
                bail!("New version name is ");
            }
             */
            summary.new_version_line = Some(format!("version: {buffer}+{}", version.1 + 1));
        } else {
            bail!("New version is malformed");
        }
    }

    summary.update_flutter = prompt_bool("Update flutter?", Some(true))?; // TODO: don't forge to update pubspec file
    summary.update_dependencies = prompt_bool("Update dependencies?", Some(true))?;
    summary.run_tests = prompt_bool("Run tests?", Some(true))?;
    summary.build = prompt_bool("Build app?", Some(true))?;

    summary.print();


    Ok(())
}

pub fn prompt_bool(prompt: &str, default: Option<bool>) -> Result<bool> {
    let y = if default.is_some_and(|d| d) { "Y" } else { "y" };
    let n = if default.is_some_and(|d| !d) { "N" } else { "n" };
    print!("{} [{}/{}] ", prompt, y, n);
    io::stdout().flush()?;

    let mut buffer = String::new();
    io::stdin().read_line(&mut buffer)?;
    buffer = buffer.trim().to_string();

    if buffer.eq_ignore_ascii_case("y") {
        Ok(true)
    } else if buffer.eq_ignore_ascii_case("n") {
        Ok(false)
    } else if let Some(default) = default {
        Ok(default)
    } else {
        bail!("Invalid input '{buffer}', please provide either 'y' or 'n'");
    }
}


/// Get the closest ancestor dir that contains a .git folder in order to find the repository root.
pub fn git_dir() -> Result<PathBuf> {
    let mut dir = env::current_dir()
        .context("no CWD")?;

    loop {
        // find a child dir with matching name
        let child = dir.read_dir()?
            .find(|e| e.is_ok() && e.as_ref().unwrap().file_name()
                    .eq_ignore_ascii_case(".git"));
        if let Some(Ok(_)) = child {
            return Ok(dir);
        }
        if let Some(parent) = dir.parent() {
            dir = parent.to_path_buf();
        } else {
            bail!("Reached fs root")
        }
    }
}

/// Read current app verison name and number from pubspec in `$root/app/pubspec.yaml`.
/// 
/// Example: ("1.8.4", 49)
pub fn get_version(root: &PathBuf) -> Result<(String, usize)> {
    let pubspec = root.join("app").join("pubspec.yaml");
    let pubspec = fs::read_to_string(pubspec).context("Couldn't find pubspec.yaml")?;

    // Matches the `version: ...+..` line of the file, capturing the name in 1 and the number in 2.
    let regex =  Regex::new(r"version:\s*([0-9.]*)\+([0-9]*)")?;
    let pubspec = regex.captures(&pubspec)
        .context("Can't find app version declaration in pubspec.yaml")?;
    
    let version_name = pubspec.get(1).expect("implied by regex");
    let version_num = pubspec.get(2).expect("implied by regex");
    let parsed_version_num = version_num.as_str().parse::<usize>()
        .context(format!("Extracted version string is: '{}'", version_num.as_str()))?;
    Ok((version_name.as_str().to_string(), parsed_version_num))
}
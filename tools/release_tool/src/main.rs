use std::{env, fs, path::PathBuf};
use anyhow::{bail, Context, Result};
use regex::Regex;

fn main() -> Result<()>{
    let root = git_dir()
        .context("Couldn't find repository root")?;
    println!("Using repository at {:?}", root);

    let version = get_version(&root)
        .context("Couldn't read current app version")?;
    println!("Current app version is {} ({})", &version.0, &version.1);
    
    Ok(())
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

    let regex = Regex::new(r"version:\s*([0-9.]*)\+([0-9]*)").unwrap();
    let pubspec = regex.captures(&pubspec)
        .context("Can't find app version declaration in pubspec.yaml")?;
    
    let version_name = pubspec.get(1).expect("implied by regex");
    let version_num = pubspec.get(2).expect("implied by regex");
    let parsed_version_num = version_num.as_str().parse::<usize>()
        .context(format!("Extracted version string is: '{}'", version_num.as_str()))?;
    Ok((version_name.as_str().to_string(), parsed_version_num))
}
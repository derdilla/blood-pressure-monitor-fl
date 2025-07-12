use std::path::PathBuf;

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
    }
}

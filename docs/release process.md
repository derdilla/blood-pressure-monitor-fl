*developer documentation - users can safely ignore this*

App release checklist 
- [ ] milestone finished
- [ ] no remaining breaking issues
- [ ] add translation from weblate
- [ ] create changelog
- [ ] update version in pubspec.yaml and android/app/build.gradle
- [ ] verify no tests fail
- [ ] compile apk `flutter build apk --release --flavor github --obfuscate --split-debug-info=./build/debug-info`
- [ ] compile play-store `flutter build appbundle --release --flavor github --obfuscate --split-debug-info=./build/debug-info`
- [ ] google play beta release
- [ ] once a user confirms the update works, promote play release and create github release
- [ ] Add debug symbols in `./build/debug-info` to github release
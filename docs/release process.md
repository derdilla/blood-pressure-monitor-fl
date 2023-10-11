*developer documentation - users can safely ignore this*

App release checklist
- [ ] milestone finished
- [ ] no remaining breaking issues
- [ ] add translation from Weblate
- [ ] create changelog
- [ ] update version in `pubspec.yaml` and `android/app/build.gradle`
- [ ] verify no tests fail
- [ ] compile apk `flutter build apk --release --flavor github --obfuscate --split-debug-info=./build/debug-info`
- [ ] compile play-store `flutter build appbundle --release --flavor github --obfuscate --split-debug-info=./build/debug-info`
- [ ] Google Play beta release
- [ ] Once a successful update was reported and the app works, promote the Play release and create a GitHub release
- [ ] Add debug symbols in `./build/debug-info` to GitHub release
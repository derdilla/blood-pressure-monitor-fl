App release checklist 
- [ ] milestone finished
- [ ] no remaining breaking issues
- [ ] add translation from weblate
- [ ] create changelog
- [ ] update version in pubspec.yaml and android/app/build.gradle
- [ ] verify no tests fail
- [ ] compile apk `flutter build apk --release --flavor github`
- [ ] compile play-store `flutter build appbundle --release --flavor github`
- [ ] test if app update works in vm

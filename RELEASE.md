App release checklist 
- [ ] milestone finished
- [ ] no remaining breaking issues
- [ ] add translation from weblate
- [ ] create changelog
- [ ] update version in pubspec.yaml and android/app/build.gradle
- [ ] verify no tests fail
- [ ] compile apk `flutter build apk --release --flavor github --obfuscate --split-debug-info=./build/debug-info`
- [ ] compile play-store `flutter build appbundle --release --flavor github --obfuscate --split-debug-info=./build/debug-info`
- [ ] test if app update works in vm


Compiling the app with obfuscation reduces app size by multiple megabytes. [This makes reading crashes and stack traces a bit harder](https://docs.flutter.dev/deployment/obfuscate#read-an-obfuscated-stack-trace).
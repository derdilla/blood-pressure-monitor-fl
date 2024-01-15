*developer documentation - users can safely ignore this*

App release checklist
- [ ] milestone finished
- [ ] no remaining breaking issues
- [ ] add translation from [Weblate](https://hosted.weblate.org/projects/blood-pressure-monitor-fl/#repository)
- [ ] in case new languages got added, add them to `iso_lang_names.dart`
- [ ] create changelog
- [ ] update version in `pubspec.yaml` and `android/app/build.gradle`
- [ ] verify no tests fail
- [ ] `flutter clean`
- [ ] `flutter pub upgrade`
- [ ] compile apk `flutter build apk --release --flavor github --obfuscate --split-debug-info=./build/debug-info`
- [ ] compile play-store `flutter build appbundle --release --flavor github --obfuscate --split-debug-info=./build/debug-info`
- [ ] obtain Playstore debug symbols by running `7z a debug-info.zip ./lib/arm64-v8a/ ./lib/armeabi-v7a/ ./lib/x86_64/
` in folder `build/app/intermediates/merged_native_libs/githubRelease/out/`
- [ ] Google Play beta release
- [ ] Once a successful update has been reported and the app works, promote the Play release and create a GitHub release
- [ ] Add debug symbols in `./build/debug-info` to GitHub release

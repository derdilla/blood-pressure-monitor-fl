*developer documentation - users can safely ignore this*

## App release checklist

- [ ] no remaining breaking issues
- [ ] add translation from [Weblate](https://hosted.weblate.org/projects/blood-pressure-monitor-fl/#repository)
- [ ] in case new languages got added, add them to `iso_lang_names.dart`
- [ ] create changelog
- [ ] update app version name and number in `pubspec.yaml`
- [ ] update to latest flutter stable and update the flutter version name for f-droid in `pubspec.yaml`
- [ ] `dart pub upgrade --tighten --major-versions` in health data store dir
- [ ] `flutter clean` in app dir
- [ ] `flutter pub upgrade --tighten --major-versions` in app dir
- [ ] verify no tests fail
- [ ] compile apk `flutter build apk --release --flavor github --obfuscate --split-debug-info=./build/debug-info`
- [ ] Manuall release testing: upgrading data and core features
- [ ] compile play-store `flutter build appbundle --release --flavor github --obfuscate --split-debug-info=./build/debug-info`
- [ ] obtain Playstore debug symbols by running `7z a debug-info.zip ./lib/arm64-v8a/ ./lib/armeabi-v7a/ ./lib/x86_64/
` in folder `build/app/intermediates/merged_native_libs/githubRelease/out/`
- [ ] make Play release and create a GitHub release
- [ ] Add debug symbols in `./build/debug-info` to GitHub release

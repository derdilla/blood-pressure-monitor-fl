#!/bin/sh

OUT_DIR="fastlane/metadata/android/en-US/images/phoneScreenshots"

cd app || exit 1
flutter drive --target=integration_test/screenshot_home.dart --dart-define=testing_mode=true --driver=test_driver/integration_test.dart  --browser-name android-chrome --android-emulator --flavor github --no-cache-startup-profile --no-enable-dart-profiling --no-track-widget-creation || exit 1
flutter drive --target=integration_test/screenshot_input.dart --dart-define=testing_mode=true --driver=test_driver/integration_test.dart  --browser-name android-chrome --android-emulator --flavor github --no-cache-startup-profile --no-enable-dart-profiling --no-track-widget-creation --no-pub || exit 1
flutter drive --target=integration_test/screenshot_settings.dart --dart-define=testing_mode=true --driver=test_driver/integration_test.dart  --browser-name android-chrome --android-emulator --flavor github --no-cache-startup-profile --no-enable-dart-profiling --no-track-widget-creation --no-pub || exit 1
flutter drive --target=integration_test/screenshot_stats.dart --dart-define=testing_mode=true --driver=test_driver/integration_test.dart  --browser-name android-chrome --android-emulator --flavor github --no-cache-startup-profile --no-enable-dart-profiling --no-track-widget-creation --no-pub || exit 1

cd build/screenshots
# remove top 80 px and resize to 2:1 ratio
find . -maxdepth 1 -iname "*.png" | xargs -L1 -I{} magick "{}" -crop 1080x2074+0+80 +repage -resize 1000x2000! "../../../$OUT_DIR/{}"
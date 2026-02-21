#!/bin/sh

OUT_DIR="fastlane/metadata/android/en-US/images/phoneScreenshots"

cd app || exit 1
flutter test integration_test/screenshot_home.dart     --flavor github --dart-define=testing_mode=true --update-goldens || exit 1
flutter test integration_test/screenshot_input.dart    --flavor github --dart-define=testing_mode=true --update-goldens || exit 1
flutter test integration_test/screenshot_settings.dart --flavor github --dart-define=testing_mode=true --update-goldens || exit 1
flutter test integration_test/screenshot_stats.dart    --flavor github --dart-define=testing_mode=true --update-goldens || exit 1

cd integration_test/screenshots || exit 1
# remove top 80 px and resize to 2:1 ratio
find . -maxdepth 1 -iname "*.png" | xargs -L1 -I{} magick "{}" -crop 1080x2074+0+80 +repage -resize 1000x2000! "../../../$OUT_DIR/{}"
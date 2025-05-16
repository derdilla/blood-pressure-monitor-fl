#!/usr/bin/env bash

APP_DIR="${BASH_SOURCE%/*}/.."
CURRENT_VERSION=$(sed -n -E "s/.*version:\s*[^\+]*\+//p" "$APP_DIR/app/pubspec.yaml")
NEXT_VERSION=$((CURRENT_VERSION+1))

echo "Preparing update ($CURRENT_VERSION -> $NEXT_VERSION)"


read -p "Cleanup old changelogs? [y/n]" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
  echo "Cleaning up changelogs:"
  for ((i = 0; i <= CURRENT_VERSION; i++)); do
    for file in $APP_DIR/fastlane/metadata/android/*/changelogs/$i.txt; do
      # Check if the file exists before attempting to delete it
      if [ -e "$file" ]; then
        echo "- $file"
        # rm "$file"
      fi
    done
  done
fi


read -p "Create new changelogs ($NEXT_VERSION.txt)? [Y/n]" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]?$ ]]
then
  vim "$APP_DIR/fastlane/metadata/android/en-US/changelogs/$NEXT_VERSION.txt"
  for dir in $APP_DIR/fastlane/metadata/android/*; do
    echo "+ $dir/changelogs/$NEXT_VERSION.txt"
    mkdir -p "$dir/changelogs"
    cp "$APP_DIR/fastlane/metadata/android/en-US/changelogs/$NEXT_VERSION.txt" "$dir/changelogs/$NEXT_VERSION.txt"
  done
fi


read -p "Bump app version($CURRENT_VERSION -> $NEXT_VERSION)? [Y/n]" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]?$ ]]
then
  # TODO
fi


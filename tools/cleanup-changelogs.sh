#!/usr/bin/env bash

# Check if an argument is provided
if [ -z "$1" ]; then
	echo "Please provide the current app version (e.g 36)."
  exit 1
fi

export END=$1-2

for ((i = 0; i <= $END; i++)); do
  for file in fastlane/metadata/android/*/changelogs/$i.txt; do
    # Check if the file exists before attempting to delete it
    if [ -e "$file" ]; then
      echo "- $file"
      rm "$file"
    fi
  done
done

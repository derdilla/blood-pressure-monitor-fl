TARGET_DIR := target
FLAVOR := github

FLUTTER := $(shell cd $(CURDIR) && pwd)/flutter/bin/flutter
DART := $(shell cd $(CURDIR) && pwd)/flutter/bin/dart

version := $(shell  grep "version:" app/pubspec.yaml | sed 's/.*+//')

# Supress gradle warning
export GRADLE_OPTS="--enable-native-access=ALL-UNNAMED"

.PHONY: clean build-all prepare-build get-deps codegen build-aab build-apk build-split-apk debug-info build-apk-x64 build-apk-arm build-apk-arm64 analyze
.NOTPARALLEL:

build-all: prepare-build get-deps codegen build-aab build-apk build-split-apk debug-info

prepare-build:
	-mkdir $(TARGET_DIR)

get-deps:
	$(FLUTTER) pub get --enforce-lockfile

codegen:
	$(DART) run build_runner build --workspace

build-aab:
	@cd app && $(FLUTTER) build aab --release \
		--flavor $(FLAVOR) \
		--obfuscate \
		--split-debug-info=./build/debug-info \
		--build-number $$((${version} * 100)) \
		-P force-version-code-ignoring-abi=true
	cp app/build/app/outputs/bundle/githubRelease/app-$(FLAVOR)-release.aab $(TARGET_DIR)/

build-apk:
	@cd app && $(FLUTTER) build apk --release \
		--flavor $(FLAVOR) \
		--obfuscate \
		--split-debug-info=./build/debug-info \
		--build-number $$((${version} * 100)) \
		-P force-version-code-ignoring-abi=true
	cp app/build/app/outputs/flutter-apk/app-$(FLAVOR)-release.apk $(TARGET_DIR)/

build-split-apk: build-apk-x64 build-apk-arm build-apk-arm64

build-apk-x64:
	@cd app && $(FLUTTER) build apk --release \
		--flavor $(FLAVOR) \
		--obfuscate \
		--split-debug-info=./build/debug-info \
		--build-number $$((${version} * 100 + 1)) \
		-P force-version-code-ignoring-abi=true \
		--split-per-abi \
		--target-platform="android-x64"
	cp app/build/app/outputs/flutter-apk/app-x86_64-$(FLAVOR)-release.apk $(TARGET_DIR)/

build-apk-arm:
	@cd app && $(FLUTTER) build apk --release \
		--flavor $(FLAVOR) \
		--obfuscate \
		--split-debug-info=./build/debug-info \
		--build-number $$((${version} * 100 + 2)) \
		-P force-version-code-ignoring-abi=true \
		--split-per-abi \
		--target-platform="android-arm"
	cp app/build/app/outputs/flutter-apk/app-armeabi-v7a-$(FLAVOR)-release.apk $(TARGET_DIR)/

build-apk-arm64:
	@cd app && $(FLUTTER) build apk --release \
		--flavor $(FLAVOR) \
		--obfuscate \
		--split-debug-info=./build/debug-info \
		--build-number $$((${version} * 100 + 3)) \
		-P force-version-code-ignoring-abi=true \
		--split-per-abi \
		--target-platform="android-arm64"
	cp app/build/app/outputs/flutter-apk/app-arm64-v8a-$(FLAVOR)-release.apk $(TARGET_DIR)/

debug-info:
	zip -r $(TARGET_DIR)/debug-info.zip app/build/debug-info


upgrade-deps: upgrade-deps-app upgrade-deps-libs

upgrade-deps-app:
	$(FLUTTER) pub upgrade --tighten --major-versions -C app

upgrade-deps-libs: upgrade-deps-health_data_store upgrade-deps-settings_annotation upgrade-deps-settings_builder

upgrade-deps-health_data_store:
	$(DART) pub upgrade --tighten --major-versions -C health_data_store

upgrade-deps-settings_annotation:
	$(FLUTTER) pub upgrade --tighten --major-versions -C settings_annotation

upgrade-deps-settings_builder:
	$(FLUTTER) pub upgrade --tighten --major-versions -C settings_builder

analyze:
	@cd health_data_store && dart analyze
	@cd app && flutter analyze
	@cd settings_builder && flutter analyze
	@cd settings_annotation && flutter analyze


version:
	@echo ${version}

apk-version:
	@echo $$((${version} * 100))


clean:
	@cd app && $(FLUTTER) clean
	$(FLUTTER) clean
	-rm -rf $(TARGET_DIR)



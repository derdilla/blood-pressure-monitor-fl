# Testing

Testing means catching bugs early and automated testing has already prevented 
multiple bugs from getting reintroduced. Therefor the goal is to have the 
entire codebase covered by extensive tests.

### Unit tests

Unit tests are fast and can all be run during development. Some util functions 
are present in the util file and in specialised ones in their respective widget
test (e.g. color picker).

```bash
flutter test
```

#### Integration test

Integration tests are slow and mainly used for core workflows and things that 
can't be tested without them. Integration tests should not use the `main` 
method but should rather pump the App directly to allow tests to be independent
of each other.

```dart
tester.pumpWidget(App(forceClearAppDataOnLaunch: true,));
```

To run integration tests an android emulator needs to be running. During development running a single test file is sufficient and faster.

```bash
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/<testName>.dart \
  --browser-name android-chrome --android-emulator \
  --flavor github
```

To ues the emulator `--browser-name android-chrome --android-emulator` is 
required. `--flavor github` is needed for the driver to find the apk. All tests are run by the CI and can also be manually run before merge:

```bash
flutter test integration_test --flavor github
```

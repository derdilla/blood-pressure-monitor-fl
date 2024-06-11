# Testing

Testing means catching bugs early and automated testing has already prevented 
multiple bugs from getting reintroduced. Therefor the goal is to have the 
entire codebase covered by extensive tests.

#### Running unit tests

```bash
flutter test
```

#### Running integration tests

To run integration tests an android emulator needs to be running.

```bash
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/<testName>.dart \
  --browser-name android-chrome --android-emulator \
  --flavor github
```

To ues the emulator `--browser-name android-chrome --android-emulator` is 
required. `--flavor github` is needed for the driver to find the apk.

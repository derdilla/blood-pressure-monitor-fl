import 'package:flutter_test/flutter_test.dart';

extension WaitUntil on WidgetTester {
  /// Retries with 100ms delay for up to [maxLength] for a [test] to succeed.
  ///
  /// When no value is provided [maxLength] defaults to 5s.
  Future<void> pumpUntil(bool Function() test, [Duration? maxLength]) async {
    maxLength ??= Duration(seconds: 5);

    int retries = maxLength.inMilliseconds ~/ 100;
    while(!test() && retries >= 0) {
      retries--;
      await pump(Duration(milliseconds: 100));
    }
    await pump();
  }
}

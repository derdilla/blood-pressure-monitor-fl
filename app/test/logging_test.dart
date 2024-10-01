import 'package:blood_pressure_app/logging.dart';
import 'package:flutter_test/flutter_test.dart';

/// Helper util for tests
void throwError() {
  throw Error();
}

void main() {
  test('Log.withoutTypes strips type references from log statement', () {
    const logLine = 'SomeClass<SomeType>';
    expect(Log.withoutTypes(logLine), 'SomeClass');
  });
}

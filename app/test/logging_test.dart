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
  
  test('Log.findRuntimeType extracts the expected callee from the current stracktrace', () {
    final callee1 = Log.findRuntimeType(StackTrace.current, 0);
    expect(callee1, 'main');
  });

  test('Log.findRuntimeType extracts the expected callee from error stracktrace', () {
    late StackTrace st;
    expect(throwError, throwsA((e) {
      st = e.stackTrace;
      return e is Error;
    }));

    final callee2 = Log.findRuntimeType(st, 0);
    expect(callee2, 'throwError');
  });

  test('Log.findRuntimeType extracts the expected callee from error stracktrace with skip count and strips anonymous closure', () {
    void fn1() => throwError();
    void fn2() => fn1();
    void fn3() => fn2();

    late StackTrace st;
    expect(fn3, throwsA((e) {
      st = e.stackTrace;
      return e is Error;
    }));

    final callee2 = Log.findRuntimeType(st);
    expect(callee2, 'main.fn2');

    final callee3 = Log.findRuntimeType(st, 3);
    expect(callee3, 'main.fn3');
  });
}

import 'package:health_data_store/src/extensions/castable.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  test('should cast null to null', () {
    expect((null as Object?)?.castOrNull<String>(), null);
  });
  test('should cast int', () {
    expect((123 as Object?)?.castOrNull<int>(), 123);
  });
  test('should not cast incorrectly', () {
    expect((123 as Object?)?.castOrNull<double>(), null);
  });
}

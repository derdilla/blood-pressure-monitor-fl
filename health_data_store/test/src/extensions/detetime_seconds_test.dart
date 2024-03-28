import 'package:health_data_store/src/extensions/datetime_seconds.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  test('should create DateTime correctly', () {
    final t = DateTimeS.fromSecondsSinceEpoch(42);
    expect(t.millisecondsSinceEpoch, 42 * 1000);
  });
  test('should return time since epoch correctly', () {
    final t = DateTimeS.fromSecondsSinceEpoch(42);
    expect(t.secondsSinceEpoch, 42);
  });
}

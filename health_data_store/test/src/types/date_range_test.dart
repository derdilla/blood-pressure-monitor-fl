import 'package:health_data_store/health_data_store.dart';
import 'package:test/test.dart';

void main() {
  test('should initialize', () {
    final timeA = DateTime.now();
    final timeB = timeA.subtract(Duration(hours: 20));
    final range = DateRange(start: timeA, end: timeB);
    expect(range.start, equals(timeA));
    expect(range.end, equals(timeB));
  });
  test('should calculate difference', () {
    final timeA = DateTime.now();
    final timeB = timeA.subtract(Duration(hours: 21, seconds: 42));
    final range = DateRange(start: timeA, end: timeB);
    expect(range.duration, equals(Duration(hours: -21, seconds: -42)));
  });
}

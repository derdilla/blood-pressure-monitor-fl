import 'package:health_data_store/health_data_store.dart';
import 'package:test/test.dart';

void main() {
  test('should initialize', () {
    final timeA = DateTime.now();
    final timeB = timeA.add(Duration(hours: 20));
    final range = DateRange(start: timeA, end: timeB);
    expect(range.start, equals(timeA));
    expect(range.end, equals(timeB));
  });
  test('should throw assertion error when used incorrectly', () {
    final start = DateTime.now();
    final end = start.subtract(Duration(hours: 20));
    expect(end.isBefore(start), true);
    expect(() => DateRange(start: start,end: end),
        throwsA(isA<AssertionError>()));
  });
  test('should calculate difference', () {
    final timeA = DateTime.now();
    final timeB = timeA.add(Duration(hours: 21, seconds: 42));
    final range = DateRange(start: timeA, end: timeB);
    expect(range.duration, equals(Duration(hours: 21, seconds: 42)));
  });
  test('should determine start and end time in seconds since epoch', () {
    final timeA = DateTime.fromMillisecondsSinceEpoch(0);
    final timeB = timeA.add(Duration(seconds: 283497));
    final range = DateRange(start: timeA, end: timeB);
    expect(range.startStamp, 0);
    expect(range.endStamp, 283497);
  });
}

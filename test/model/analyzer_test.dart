
import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:blood_pressure_app/model/blood_pressure_analyzer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BloodPressureAnalyser', () {
    test('should return averages', () async {
      var m = BloodPressureAnalyser([
        BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(1), 122, 87, 65, ''),
        BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(2), 100, 60, 62, ''),
        BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(3), 111, 73, 73, '')
      ]);

      expect(m.avgSys, 111);
      expect(m.avgDia, 73);
      expect(m.avgPul, 66);
    });

    test('should return max', () async {
      var a = BloodPressureAnalyser([
        BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(1), 123, 87, 65, ''),
        BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(2), 100, 60, 62, ''),
        BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(3), 111, 73, 73, ''),
        BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(4), 111, 73, 73, '')
      ]);

      expect(a.maxSys, 123);
      expect(a.maxDia, 87);
      expect(a.maxPul, 73);
    });

    test('should return min', () async {
      var a = BloodPressureAnalyser([
        BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(1), 123, 87, 65, ''),
        BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(2), 100, 60, 62, ''),
        BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(3), 111, 73, 73, ''),
        BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(4), 100, 60, 62, '')
      ]);

      expect(a.minSys, 100);
      expect(a.minDia, 60);
      expect(a.minPul, 62);
    });

    test('should know count', () async {
      var m = BloodPressureAnalyser([
        for (int i = 1; i < 101; i++)
          BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(i), 0, 0, 0, '')
      ]);
      expect(m.count, 100);
    });

    test('should determine special days', () async {
      var m = BloodPressureAnalyser([BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(100), 0, 0, 0, ''),
        BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(-2200), 0, 0, 0, ''),
        BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(9000000), 0, 0, 0, ''),
        BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(3124159), 0, 0, 0, ''),
      ]);
      
      expect((m.firstDay), DateTime.fromMillisecondsSinceEpoch(-2200));
      expect((m.lastDay), DateTime.fromMillisecondsSinceEpoch(9000000));
    });

    // TODO null tests, test with 1 element
  });
}
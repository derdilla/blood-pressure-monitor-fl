
import 'package:blood_pressure_app/model/blood_pressure_analyzer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_data_store/health_data_store.dart';

void main() {
  test('should return averages', () {
    final m = BloodPressureAnalyser([
      mockRecordPos(DateTime.fromMillisecondsSinceEpoch(1), 122, 87, 65),
      mockRecordPos(DateTime.fromMillisecondsSinceEpoch(2), 100, 60, 62),
      mockRecordPos(DateTime.fromMillisecondsSinceEpoch(3), 111, 73, 73),
    ]);

    expect(m.avgSys?.mmHg, 111);
    expect(m.avgDia?.mmHg, 73);
    expect(m.avgPul, 66);
  });

  test('should return max', () {
    final a = BloodPressureAnalyser([
      mockRecordPos(DateTime.fromMillisecondsSinceEpoch(1), 123, 87, 65),
      mockRecordPos(DateTime.fromMillisecondsSinceEpoch(2), 100, 60, 62),
      mockRecordPos(DateTime.fromMillisecondsSinceEpoch(3), 111, 73, 73),
      mockRecordPos(DateTime.fromMillisecondsSinceEpoch(4), 111, 73, 73),
    ]);

    expect(a.maxSys?.mmHg, 123);
    expect(a.maxDia?.mmHg, 87);
    expect(a.maxPul, 73);
  });

  test('should return min', () {
    final a = BloodPressureAnalyser([
      mockRecordPos(DateTime.fromMillisecondsSinceEpoch(1), 123, 87, 65),
      mockRecordPos(DateTime.fromMillisecondsSinceEpoch(2), 100, 60, 62),
      mockRecordPos(DateTime.fromMillisecondsSinceEpoch(3), 111, 73, 73),
      mockRecordPos(DateTime.fromMillisecondsSinceEpoch(4), 100, 60, 62),
    ]);

    expect(a.minSys?.mmHg, 100);
    expect(a.minDia?.mmHg, 60);
    expect(a.minPul, 62);
  });

  test('should know count', () {
    final m = BloodPressureAnalyser([
      for (int i = 1; i < 101; i++)
        mockRecordPos(DateTime.fromMillisecondsSinceEpoch(i), 0, 0, 0),
    ]);
    expect(m.count, 100);
  });

  test('should determine special days', () {
    final m = BloodPressureAnalyser([mockRecordPos(DateTime.fromMillisecondsSinceEpoch(100), 0, 0, 0),
      mockRecordPos(DateTime.fromMillisecondsSinceEpoch(20), 0, 0, 0),
      mockRecordPos(DateTime.fromMillisecondsSinceEpoch(9000000), 0, 0, 0),
      mockRecordPos(DateTime.fromMillisecondsSinceEpoch(3124159), 0, 0, 0),
    ]);

    expect((m.firstDay), DateTime.fromMillisecondsSinceEpoch(20));
    expect((m.lastDay), DateTime.fromMillisecondsSinceEpoch(9000000));
  });
  
  test('groups analyzers for all hours', () {
    final analyzer = BloodPressureAnalyser([]);
    final groups = analyzer.groupAnalysers();
    expect(groups, hasLength(24));
    expect(groups, everyElement(isA<BloodPressureAnalyser>().having((a) => a.count, 'count', 0)));
  });

  test('creates groups correctly', () {
    final analyzer = BloodPressureAnalyser([
      mockRecordPos(DateTime(2000, 1, 1, 5), 123),
      mockRecordPos(DateTime(2000, 1, 1, 5), 123),
      mockRecordPos(DateTime(2000, 1, 1, 5), 123),
      mockRecordPos(DateTime(2000, 1, 1, 8), 123),
      mockRecordPos(DateTime(2000, 1, 1, 12), 123),
      mockRecordPos(DateTime(2000, 1, 1, 12), 123),
      mockRecordPos(DateTime(2000, 1, 1, 19), 123),
      mockRecordPos(DateTime(2000, 1, 1, 19), 0, 122),
      mockRecord(time: DateTime(2000, 1, 1, 19), pul: 12),
      mockRecordPos(DateTime(2000, 1, 1, 23, 40), 123),
    ]);
    final groups = analyzer.groupAnalysers();
    expect(groups[5].count, 3);
    expect(groups[8].count, 1);
    expect(groups[12].count, 2);
    expect(groups[19].count, 3);
    expect(groups[0].count, 1);

    for (final i in [1,2,3,4,6,7,9,10,11,3,14,15,16,17,18,20,21,22,23]) {
      expect(groups[i].count, 0);
    }
  });
}

BloodPressureRecord mockRecordPos([
  DateTime? time,
  int? sys,
  int? dia,
  int? pul,
]) => mockRecord(
  time: time ?? DateTime.now(),
  sys: sys,
  dia: dia,
  pul: pul,
);

BloodPressureRecord mockRecord({
  DateTime? time,
  int? sys,
  int? dia,
  int? pul,
}) => BloodPressureRecord(
  time: time ?? DateTime.now(),
  sys: sys == null ? null : Pressure.mmHg(sys),
  dia: dia == null ? null : Pressure.mmHg(dia),
  pul: pul,
);

import 'package:health_data_store/src/types/blood_pressure_record.dart';
import 'package:test/test.dart';

void main() {
  test('should initialize with all data', () {
    final time = DateTime.now();
    final record = BloodPressureRecord(
      time: time,
      sys: 123,
      dia: 56,
      pul: 78,
    );
    expect(record.time, time);
    expect(record.sys, 123);
    expect(record.dia, 56);
    expect(record.pul, 78);
    expect(record, equals(BloodPressureRecord(
      time: time,
      sys: 123,
      dia: 56,
      pul: 78,
    )));
  });
  test('should initialize with partial data', () {
    final time = DateTime.now();
    final record = BloodPressureRecord(
      time: time,
      dia: 56,
    );
    expect(record.time, time);
    expect(record.sys, null);
    expect(record.dia, 56);
    expect(record.pul, null);
    expect(record, isNot(equals(BloodPressureRecord(
      time: time,
      sys: 123,
      dia: 56,
      pul: 78,
    ))));
  });
}

BloodPressureRecord mockRecord({
  int? time,
  int? sys,
  int? dia,
  int? pul,
}) => BloodPressureRecord(
  time: time!=null ? DateTime.fromMillisecondsSinceEpoch(time) : DateTime.now(),
  sys: sys,
  dia: dia,
  pul: pul,
);

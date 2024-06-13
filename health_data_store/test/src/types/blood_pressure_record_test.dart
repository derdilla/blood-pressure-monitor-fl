import 'package:health_data_store/src/types/blood_pressure_record.dart';
import 'package:health_data_store/src/types/units/pressure.dart';
import 'package:test/test.dart';

void main() {
  test('should initialize with all data', () {
    final time = DateTime.now();
    final record = BloodPressureRecord(
      time: time,
      sys: Pressure.mmHg(123),
      dia: Pressure.mmHg(56),
      pul: 78,
    );
    expect(record.time, time);
    expect(record.sys?.mmHg, 123);
    expect(record.dia?.mmHg, 56);
    expect(record.pul, 78);
    expect(record, equals(BloodPressureRecord(
      time: time,
      sys: Pressure.mmHg(123),
      dia: Pressure.mmHg(56),
      pul: 78,
    )));
  });
  test('should initialize with partial data', () {
    final time = DateTime.now();
    final record = BloodPressureRecord(
      time: time,
      dia: Pressure.mmHg(56),
    );
    expect(record.time, time);
    expect(record.sys?.mmHg, null);
    expect(record.dia?.mmHg, 56);
    expect(record.pul, null);
    expect(record, isNot(equals(BloodPressureRecord(
      time: time,
      sys: Pressure.mmHg(123),
      dia: Pressure.mmHg(56),
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
  sys: sys == null ? null : Pressure.mmHg(sys),
  dia: dia == null ? null : Pressure.mmHg(dia),
  pul: pul,
);

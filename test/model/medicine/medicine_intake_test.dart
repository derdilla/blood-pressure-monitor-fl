import 'package:blood_pressure_app/model/blood_pressure/medicine/medicine.dart';
import 'package:blood_pressure_app/model/blood_pressure/medicine/medicine_intake.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'medicine_test.dart';

void main() {
  group('MedicineIntake', () {
    test('should determine equality', () {
      final med = Medicine(1, designation: 'designation', color: Colors.red, defaultDosis: 123);
      final int1 = MedicineIntake(medicine: med, dosis: 10, timestamp: DateTime.fromMillisecondsSinceEpoch(123));
      final int2 = MedicineIntake(medicine: med, dosis: 10, timestamp: DateTime.fromMillisecondsSinceEpoch(123));
      expect(int1, int2);
    });
    test('should determine inequality', () {
      final med1 = Medicine(1, designation: 'designation', color: Colors.red, defaultDosis: 123);
      final med2 = Medicine(2, designation: 'designation', color: Colors.red, defaultDosis: 123);
      final int1 = MedicineIntake(medicine: med1, dosis: 10, timestamp: DateTime.fromMillisecondsSinceEpoch(123));
      final int2 = MedicineIntake(medicine: med2, dosis: 10, timestamp: DateTime.fromMillisecondsSinceEpoch(123));
      expect(int1, isNot(int2));
      final int3 = MedicineIntake(medicine: med1, dosis: 11, timestamp: DateTime.fromMillisecondsSinceEpoch(123));
      expect(int1, isNot(int3));
      final int4 = MedicineIntake(medicine: med1, dosis: 10, timestamp: DateTime.fromMillisecondsSinceEpoch(124));
      expect(int1, isNot(int4));
    });
    test('should deserialize serialized intake', () {
      final intake = mockIntake(timeMs: 543210);
      expect(MedicineIntake.deserialize(intake.serialize(), [intake.medicine]), intake);

      final intake2 = mockIntake(
          timeMs: 543211,
          dosis: 1000231,
          medicine: mockMedicine(designation: 'tst'),
      );
      expect(MedicineIntake.deserialize(
          intake2.serialize(),
          [intake.medicine, intake2.medicine],),
          intake2,);
    });
    test('should fail to deserialize serialized intake without exising med', () {
      final intake = mockIntake(medicine: mockMedicine(designation: 'tst'));
      expect(() => MedicineIntake.deserialize(
          intake.serialize(),
          [mockMedicine()],),
          throwsStateError,);
    });
  });
}

/// Create a mock intake.
///
/// [timeMs] creates the intake timestamp through [DateTime.fromMillisecondsSinceEpoch].
/// When is null [DateTime.now] is used.
MedicineIntake mockIntake({
  double dosis = 0,
  int? timeMs,
  Medicine? medicine,
}) => MedicineIntake(
    medicine: medicine ?? mockMedicine(),
    dosis: dosis,
    timestamp: timeMs == null ? DateTime.now() : DateTime.fromMillisecondsSinceEpoch(timeMs),
);

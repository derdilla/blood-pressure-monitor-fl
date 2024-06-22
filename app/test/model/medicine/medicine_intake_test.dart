import 'package:blood_pressure_app/model/blood_pressure/medicine/medicine.dart';
import 'package:blood_pressure_app/model/blood_pressure/medicine/medicine_intake.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('should determine equality', () {
    final med = Medicine(1, designation: 'designation', color: Colors.red, defaultDosis: 123);
    final int1 = OldMedicineIntake(medicine: med, dosis: 10, timestamp: DateTime.fromMillisecondsSinceEpoch(123));
    final int2 = OldMedicineIntake(medicine: med, dosis: 10, timestamp: DateTime.fromMillisecondsSinceEpoch(123));
    expect(int1, int2);
  });
  test('should determine inequality', () {
    final med1 = Medicine(1, designation: 'designation', color: Colors.red, defaultDosis: 123);
    final med2 = Medicine(2, designation: 'designation', color: Colors.red, defaultDosis: 123);
    final int1 = OldMedicineIntake(medicine: med1, dosis: 10, timestamp: DateTime.fromMillisecondsSinceEpoch(123));
    final int2 = OldMedicineIntake(medicine: med2, dosis: 10, timestamp: DateTime.fromMillisecondsSinceEpoch(123));
    expect(int1, isNot(int2));
    final int3 = OldMedicineIntake(medicine: med1, dosis: 11, timestamp: DateTime.fromMillisecondsSinceEpoch(123));
    expect(int1, isNot(int3));
    final int4 = OldMedicineIntake(medicine: med1, dosis: 10, timestamp: DateTime.fromMillisecondsSinceEpoch(124));
    expect(int1, isNot(int4));
  });
}

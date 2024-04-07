import 'package:blood_pressure_app/model/blood_pressure/medicine/medicine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('should determine equality', () {
    final med1 = Medicine(1, designation: 'designation', color: Colors.red, defaultDosis: 10);
    final med2 = Medicine(1, designation: 'designation', color: Colors.red, defaultDosis: 10);
    expect(med1, med2);
  });
  test('should determine inequality', () {
    final med1 = Medicine(1, designation: 'designation', color: Colors.red, defaultDosis: 10);
    final med2 = Medicine(1, designation: 'designatio', color: Colors.red, defaultDosis: 10);
    expect(med1, isNot(med2));
    final med3 = Medicine(1, designation: 'designation', color: Colors.blue, defaultDosis: 10);
    expect(med1, isNot(med3));
    final med4 = Medicine(1, designation: 'designation', color: Colors.red, defaultDosis: 11);
    expect(med1, isNot(med4));
  });
  test('should restore after encoded to map', () {
    final med1 = mockMedicine();
    final med1Restored = Medicine.fromMap(med1.toMap());
    expect(med1Restored, med1);

    final med2 = mockMedicine(color: Colors.red, designation: 'designation', defaultDosis: 15);
    final med2Restored = Medicine.fromMap(med2.toMap());
    expect(med2Restored, med2);
  });
  test('should restore after encoded to json', () {
    final med1 = mockMedicine();
    final med1Restored = Medicine.fromJson(med1.toJson());
    expect(med1Restored, med1);

    final med2 = mockMedicine(color: Colors.red, designation: 'designation', defaultDosis: 15);
    final med2Restored = Medicine.fromJson(med2.toJson());
    expect(med2Restored, med2);
  });
  test('should generate the same json after restoration', () {
    final med1 = mockMedicine();
    final med1Restored = Medicine.fromJson(med1.toJson());
    expect(med1Restored.toJson(), med1.toJson());

    final med2 = mockMedicine(color: Colors.red, designation: 'designation', defaultDosis: 15);
    final med2Restored = Medicine.fromJson(med2.toJson());
    expect(med2Restored.toJson(), med2.toJson());
  }); // not in a json serialization test as this is not a setting like file.
}


final List<Medicine> _meds = [];

/// Creates mock medicine.
///
/// Medicines with the same properties will keep the correct id.
Medicine mockMedicine({
  Color color = Colors.black,
  String designation = '',
  double? defaultDosis,
}) {
  final matchingMeds = _meds.where((med) => med.defaultDosis == defaultDosis && med.color == color && med.designation == designation);
  if (matchingMeds.isNotEmpty) return matchingMeds.first;
  final med = Medicine(_meds.length, designation: designation, color: color, defaultDosis: defaultDosis);
  _meds.add(med);
  return med;
}

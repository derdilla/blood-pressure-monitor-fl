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
}

import 'dart:math';

import 'package:health_data_store/src/types/medicine.dart';
import 'package:health_data_store/src/types/units/weight.dart';
import 'package:test/test.dart';

void main() {
  test('should initialize', () {
    final med = Medicine(designation: 'test', dosis: Weight.mg(42));
    expect(med.designation, equals('test'));
    expect(med.dosis?.mg, equals(42));
  });
}

Medicine mockMedicine({
  String? designation,
  double? dosis,
  int? color
}) => Medicine(
  designation: designation ??
      'med'+(Random().nextInt(899999) + 100000).toString(),
  dosis: dosis == null ? null : Weight.mg(dosis),
  color: color,
);

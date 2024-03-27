import 'dart:math';

import 'package:health_data_store/src/types/medicine.dart';
import 'package:test/test.dart';

void main() {
  test('should initialize', () {
    final med = Medicine(designation: 'test', dosis: 42);
    expect(med.designation, equals('test'));
    expect(med.dosis, equals(42));
  });
}

Medicine mockMedicine({
  String? designation,
  double? dosis,
}) => Medicine(
  designation: designation ??
      'med'+(Random().nextInt(899999) + 100000).toString(),
  dosis: dosis,
);

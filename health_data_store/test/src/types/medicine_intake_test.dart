import 'package:health_data_store/src/types/medicine.dart';
import 'package:health_data_store/src/types/medicine_intake.dart';
import 'package:health_data_store/src/types/units/weight.dart';
import 'package:test/test.dart';

void main() {
  test('should initialize', () {
    final intake = MedicineIntake(
      time: DateTime.now(),
      medicine: Medicine(designation: 'test', dosis: Weight.mg(42)),
      dosis: Weight.mg(42),
    );
    expect(
        intake.medicine,
        equals(Medicine(
          designation: 'test',
          dosis: Weight.mg(42),
        )));
    expect(intake.dosis.mg, equals(42));
  });
}

MedicineIntake mockIntake(
  Medicine medicine, {
  int? time,
  double? dosis,
}) =>
    MedicineIntake(
      time: time != null
          ? DateTime.fromMillisecondsSinceEpoch(time)
          : DateTime.now(),
      medicine: medicine,
      dosis: Weight.mg(dosis ?? medicine.dosis?.mg ?? 42.0),
    );

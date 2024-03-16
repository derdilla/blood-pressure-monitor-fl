import 'package:health_data_store/src/types/medicine.dart';
import 'package:health_data_store/src/types/medicine_intake.dart';
import 'package:test/test.dart';

void main() {
  test('should initialize', () {
    final intake = MedicineIntake(
      time: DateTime.now(),
      medicine: Medicine(designation: 'test', dosis: 42),
      dosis: 42,
    );
    expect(intake.medicine, equals(Medicine(designation: 'test', dosis: 42)));
    expect(intake.dosis, equals(42));
  });
}

import 'package:blood_pressure_app/model/weight_unit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_data_store/health_data_store.dart';

void main() {
  test('converts all units to kg', () {
    expect(WeightUnit.kg.store(72.34).kg, closeTo(72.34, 0.01));
    expect(WeightUnit.lbs.store(32.812872).kg, closeTo(72.34, 0.01));
    expect(WeightUnit.st.store(11.3916).kg, closeTo(72.34, 0.01));
  });
  test('converts kg to all units', () {
    expect(WeightUnit.kg.extract(Weight.kg(72.34)), closeTo(72.34, 0.01));
    expect(WeightUnit.lbs.extract(Weight.kg(72.34)), closeTo(32.812872, 0.00001));
    expect(WeightUnit.st.extract(Weight.kg(72.34)), closeTo(11.3916, 0.001));
  });
}

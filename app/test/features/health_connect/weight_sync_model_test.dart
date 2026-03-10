import 'package:test/test.dart';
import 'package:health/health.dart';

void main() {
 test('health types are of units assumed in code', () {
   expect(dataTypeToUnit[HealthDataType.WEIGHT], HealthDataUnit.KILOGRAM);    expect(dataTypeToUnit[HealthDataType.BLOOD_PRESSURE_SYSTOLIC], HealthDataUnit.MILLIMETER_OF_MERCURY);
 });
}

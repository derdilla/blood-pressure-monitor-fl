import 'package:health_data_store/src/types/medicine.dart';
import 'package:test/test.dart';

void main() {
  test('should initialize', () {
    final med = Medicine(designation: 'test', dosis: 42);
    expect(med.designation, equals('test'));
    expect(med.dosis, equals(42));
  });
}

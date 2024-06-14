import 'package:health_data_store/src/types/full_entry.dart';
import 'package:test/test.dart';

import 'blood_pressure_record_test.dart';
import 'medicine_intake_test.dart';
import 'medicine_test.dart';
import 'note_test.dart';

void main() {
  test('describes all types', () {
    final record = mockRecord();
    final note = mockNote();
    final intake1 = mockIntake(mockMedicine());
    final intake2 = mockIntake(mockMedicine());

    final FullEntry entry = (record, note, [intake1, intake2]);

    expect(entry.$1, record);
    expect(entry.$2, note);
    expect(entry.$3, containsAll([intake1, intake2]));
  });
  test('works without intake', () {
    final record = mockRecord();
    final note = mockNote();

    final FullEntry entry = (record, note, []);

    expect(entry.$1, record);
    expect(entry.$2, note);
    expect(entry.$3, isEmpty);
  });
}

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
  test('extracts records', () {
    final record1 = mockRecord(time: 1);
    final record2 = mockRecord(time: 2);
    final record3 = mockRecord(time: 3);
    final note = mockNote();

    final List<FullEntry> list = [
      (record1, note, []),
      (record2, note, []),
      (record3, note, []),
      (record2, note, []),
    ];

    expect(
      list.records,
      containsAllInOrder([record1, record2, record3, record2]),
    );
  });
  test('extracts notes', () {
    final record = mockRecord();
    final note1 = mockNote(note: 'a');
    final note2 = mockNote(note: 'b');
    final note3 = mockNote(note: 'c');

    final List<FullEntry> list = [
      (record, note1, []),
      (record, note2, []),
      (record, note3, []),
      (record, note2, []),
    ];

    expect(list.notes, containsAllInOrder([note1, note2, note3, note2]));
  });
  test('detects correct distinct medicines', () {
    final record = mockRecord();
    final note = mockNote();

    final med1 = mockMedicine();
    final med2 = mockMedicine();
    final med3 = mockMedicine();

    final List<FullEntry> list = [
      (record, note, [mockIntake(med1),mockIntake(med2)]),
      (record, note, [mockIntake(med1)]),
      (record, note, []),
      (record, note, [mockIntake(med3), mockIntake(med1)]),
    ];

    expect(list.distinctMedicines, containsAll([med1, med2, med3]));
  });
  test('fast getters provide correct values', () {
    final record = mockRecord(
      sys: 123,
      dia: 45,
      pul: 67,
    );
    final note = mockNote(
      note: 'Some test',
      color: 0xFFEEDD,
    );
    final intake = mockIntake(mockMedicine());

    final FullEntry entry = (record, note, [intake]);

    expect(entry.time, record.time);
    expect(entry.sys, record.sys);
    expect(entry.dia, record.dia);
    expect(entry.pul, record.pul);
    expect(entry.note, note.note);
    expect(entry.color, note.color);
    expect(entry.intakes, hasLength(1));
    expect(entry.intakes, contains(intake));
    expect(entry.recordObj, record);
    expect(entry.noteObj, note);
  });
}

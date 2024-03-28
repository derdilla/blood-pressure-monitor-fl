import 'package:health_data_store/health_data_store.dart';
import 'package:health_data_store/src/repositories/note_repository.dart';
import 'package:test/test.dart';

import '../database_manager_test.dart';
import '../types/blood_pressure_record_test.dart';
import '../types/note_test.dart';

void main() {
  sqfliteTestInit();
  test('should initialize', () async {
    final db = await mockDBManager();
    addTearDown(db.close);
    NoteRepository(db.db);
  });
  test('should store notes', () async {
    final db = await mockDBManager();
    addTearDown(db.close);
    final repo = NoteRepository(db.db);
    await repo.add(mockNote(color: 0x00FF00));
    await repo.add(mockNote(note: 'test'));
    expect(() async => repo.add(mockNote()), throwsA(isA<AssertionError>()));
  });
  test('should return stored notes', () async {
    final db = await mockDBManager();
    addTearDown(db.close);
    final repo = NoteRepository(db.db);
    final note1 = mockNote(time: 100000, color: 0x00FF00);
    await repo.add(note1);
    final note2 = mockNote(time: 700000, note: 'test');
    await repo.add(note2);
    final note3 = mockNote(time: 530000, note: 'test2');
    await repo.add(note3);

    final values = await repo.get(DateRange(
      start: DateTime.fromMillisecondsSinceEpoch(100000),
      end: DateTime.fromMillisecondsSinceEpoch(800000),
    ));

    expect(values, hasLength(3));
    expect(values, containsAll([note1, note2, note3]));
  });
  test('should remove notes', () async {
    final db = await mockDBManager();
    addTearDown(db.close);
    final repo = NoteRepository(db.db);
    final note1 = mockNote(time: 100000, color: 0x00FF00);
    await repo.add(note1);
    final note2 = mockNote(time: 700000, note: 'test');
    await repo.add(note2);
    final note3 = mockNote(time: 530000, note: 'test2');
    await repo.add(note3);

    await repo.remove(note1);
    await repo.remove(note3);
    await repo.remove(mockNote());

    final values = await repo.get(DateRange(
      start: DateTime.fromMillisecondsSinceEpoch(100000),
      end: DateTime.fromMillisecondsSinceEpoch(800000),
    ));
    expect(values, hasLength(1));
    expect(values, contains(note2));
  });
  test('should not return notes when only other data is present', () async {
    final db = await mockDBManager();
    addTearDown(db.close);
    final bpRepo = BloodPressureRepository(db.db);
    final r1 = mockRecord(time: 200000, sys: 456, dia: 457, pul: 458);
    await bpRepo.add(r1);
    final repo = NoteRepository(db.db);
    final values = await repo.get(DateRange(
      start: DateTime.fromMillisecondsSinceEpoch(100000),
      end: DateTime.fromMillisecondsSinceEpoch(800000),
    ));
    expect(values, isEmpty);
  });
}

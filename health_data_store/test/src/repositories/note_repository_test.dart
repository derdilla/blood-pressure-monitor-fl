import 'dart:async';

import 'package:health_data_store/src/repositories/blood_pressure_repository_impl.dart';
import 'package:health_data_store/src/repositories/note_repository_impl.dart';
import 'package:health_data_store/src/types/date_range.dart';
import 'package:test/test.dart';

import '../database_manager_test.dart';
import '../types/blood_pressure_record_test.dart';
import '../types/note_test.dart';

void main() {
  sqfliteTestInit();
  test('should initialize', () async {
    final db = await mockDBManager();
    addTearDown(db.close);
    NoteRepositoryImpl(db.db);
  });
  test('should store notes', () async {
    final db = await mockDBManager();
    addTearDown(db.close);
    final repo = NoteRepositoryImpl(db.db);
    await repo.add(mockNote(color: 0x00FF00));
    await repo.add(mockNote(note: 'test'));
    expect(() async => repo.add(mockNote()), throwsA(isA<AssertionError>()));
  });
  test('should return stored notes', () async {
    final db = await mockDBManager();
    addTearDown(db.close);
    final repo = NoteRepositoryImpl(db.db);
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
    final repo = NoteRepositoryImpl(db.db);
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
    final bpRepo = BloodPressureRepositoryImpl(db.db);
    final r1 = mockRecord(time: 200000, sys: 456, dia: 457, pul: 458);
    await bpRepo.add(r1);
    final repo = NoteRepositoryImpl(db.db);
    final values = await repo.get(DateRange(
      start: DateTime.fromMillisecondsSinceEpoch(100000),
      end: DateTime.fromMillisecondsSinceEpoch(800000),
    ));
    expect(values, isEmpty);
  });
  test('should emit stream events on changes', () async {
    final db = await mockDBManager();
    addTearDown(db.close);

    int notifyCount = 0;

    final repo = NoteRepositoryImpl(db.db);
    unawaited(repo.subscribe().forEach((_) => notifyCount++));
    final n = mockNote(time: 1000, note: 'asd');
    expect(notifyCount, 0);
    await repo.add(n);
    expect(notifyCount, 1);
    await repo.add(mockNote(time: 50000, color: 0x00FF00));
    expect(notifyCount, 2);
    await repo.remove(n);
    expect(notifyCount, 3);
  });
}

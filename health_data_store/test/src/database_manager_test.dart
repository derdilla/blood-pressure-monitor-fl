import 'package:health_data_store/src/database_manager.dart';
import 'package:sqflite_common/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:test/test.dart';

/// Initialize sqflite for test.
void sqfliteTestInit() {
  // Initialize ffi implementation
  sqfliteFfiInit();
  // Set global factory
  databaseFactory = databaseFactoryFfi;
}

void main() {
  sqfliteTestInit();
  test('should initialize without issues', () async {
    final db = await mockDBManager();
    addTearDown(db.close);
    expect(db.db.isOpen, isTrue);
  });
  test('should close', () async {
    final db = await mockDBManager();
    expect(db.db.isOpen, isTrue);
    await db.close();
    expect(db.db.isOpen, isFalse);
  });
  test('should setup medicine table', () async {
    final db = await mockDBManager();
    addTearDown(db.close);

    final result = await db.db
        .query('medicine', columns: ['medID', 'designation', 'defaultDose']);
    expect(result, isEmpty);

    final item1 = {
      'medID': 1,
      'designation': 'test',
      'defaultDose': 42,
    };
    final id1 = await db.db.insert('medicine', item1);

    final item2 = {
      'medID': 2,
      'designation': 'test2',
      'defaultDose': 4.2,
    };
    final id2 = await db.db.insert('medicine', item2);

    final item3 = {
      'medID': 3,
      'designation': 'test2',
      'defaultDose': null
    };
    final id3 = await db.db.insert('medicine', item3);
    expect(id2, greaterThan(id1));
    expect(id3, greaterThan(id2));

    final resultCols = await db.db
        .query('medicine', columns: ['medID', 'designation', 'defaultDose']);
    expect(resultCols, hasLength(equals(3)));
    expect(resultCols.first.keys, containsAll([
      'medID',
      'designation',
      'defaultDose',
    ]));
    expect(resultCols, containsAllInOrder([item1, item2, item3,]));

    final resultAll = await db.db.query('medicine');
    expect(resultAll, hasLength(equals(3)));
    expect(resultCols.first.keys, containsAll([
      'medID',
      'designation',
      'defaultDose',
    ]));
    expect(
      resultCols.first.keys,
      hasLength(resultCols.first.keys.length),
      reason: 'no extra columns.'
    );

    final item4 = {
      'medID': 1,
      'designation': null,
      'defaultDose': null
    };
    await expectLater(() async => db.db.insert('medicine', item4),
        throwsException);
  });
  test('should create timestamps table correctly', () async {
    final db = await mockDBManager();
    addTearDown(db.close);
    await db.db.insert('Timestamps', {
      'entryID': 1,
      'timestampUnixS': DateTime.now().millisecondsSinceEpoch ~/ 1000,
    });
    final data = await db.db.query('Timestamps');
    expect(data, hasLength(1));
    expect(data.first.keys, hasLength(2));

    await expectLater(() async => db.db.insert('Timestamps', {
      'entryID': 1,
      'timestampUnixS': DateTime.now().millisecondsSinceEpoch ~/ 1000,
    }), throwsException);
    await expectLater(() async => db.db.insert('Timestamps', {
      'entryID': 1,
      'timestampUnixS': null,
    }), throwsException);
  });
  test('should create intake table correctly', () async {
    final db = await mockDBManager();
    addTearDown(db.close);

    await db.db.insert('Intake', {
      'entryID': 2,
      'medID': 1,
      'dosis': 1,
    });
    final data = await db.db.query('Intake');
    expect(data, hasLength(1));
    expect(data.first.keys, hasLength(3));
  });
  test('should create timestamps sys,dia,pul tables correctly', () async {
    final db = await mockDBManager();
    addTearDown(db.close);
    for (final t in [
      ('Systolic','sys'),
      ('Diastolic', 'dia'),
      ('Pulse','pul')
    ]) {
      await db.db.insert(t.$1, {
        'entryID': 1,
        t.$2: 1,
      });
      await db.db.insert(t.$1, {
        'entryID': 2,
        t.$2: null,
      });
      final data = await db.db.query(t.$1);
      expect(data, hasLength(2));
      expect(data.first.keys, hasLength(2));
    }
  });
  test('should create notes table correctly', () async {
    final db = await mockDBManager();
    addTearDown(db.close);

    await db.db.insert('Notes', {
      'entryID': 2,
      'note': 'This was a triumph',
      'color': 0xFF990098,
    });
    final data = await db.db.query('Notes');
    expect(data, hasLength(1));
    expect(data.first.keys, hasLength(3));
    expect(data.first['color'], equals(0xFF990098));
  });
}

Future<DatabaseManager> mockDBManager() async => DatabaseManager.load(
    await openDatabase(inMemoryDatabasePath));

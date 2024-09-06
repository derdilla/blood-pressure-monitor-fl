import 'package:health_data_store/src/database_manager.dart';
import 'package:health_data_store/src/extensions/datetime_seconds.dart';
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
  test('creates timestamps table correctly', () async {
    final db = await mockDBManager();
    addTearDown(db.close);
    await db.db.insert('Timestamps', {
      'entryID': 1,
      'timestampUnixS': DateTime.now().secondsSinceEpoch,
    });
    final data = await db.db.query('Timestamps');
    expect(data, hasLength(1));
    expect(data.first.keys, hasLength(2));

    await expectLater(() async => db.db.insert('Timestamps', {
      'entryID': 1,
      'timestampUnixS': DateTime.now().secondsSinceEpoch,
    }), throwsException);
    await expectLater(() async => db.db.insert('Timestamps', {
      'entryID': 1,
      'timestampUnixS': null,
    }), throwsException);
  });
  test('creates intake table correctly', () async {
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
  test('creates timestamps sys,dia,pul tables correctly', () async {
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
  test('creates notes table correctly', () async {
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
  test('creates weight table correctly', () async {
    final db = await mockDBManager();
    addTearDown(db.close);

    await db.db.insert('Weight', {
      'entryID': 2,
      'weightMg': 123.45,
    });
    final data = await db.db.query('Weight');
    expect(data, hasLength(1));
    expect(data.first.keys, hasLength(2));
    expect(data.first['weightMg'], equals(123.45));
  });
  test('should cleanup unused timestamps', () async {
    final db = await mockDBManager();
    addTearDown(db.close);

    await db.db.insert('Timestamps', {
      'entryID': 1,
      'timestampUnixS': DateTime.now().secondsSinceEpoch,
    });
    expect(await db.db.query('Timestamps'), hasLength(1));
    await db.performCleanup();
    expect(await db.db.query('Timestamps'), isEmpty);
  });
  test('should cleanup deleted medicines', () async {
    final db = await mockDBManager();
    addTearDown(db.close);

    await db.db.insert('Medicine', {
      'medID': 1,
      'designation': 'test',
      'defaultDose': 42,
      'removed': 1,
    });
    await db.db.insert('Medicine', {
      'medID': 2,
      'designation': 'test2',
      'removed': 1,
    });
    await db.db.insert('Intake', {
      'entryID': 2,
      'medID': 2,
      'dosis': 1,
    });


    expect(await db.db.query('Medicine'), hasLength(2));
    await db.performCleanup();
    final data = await db.db.query('Medicine');
    expect(data, hasLength(1));
    expect(data, contains(isA<Map>().having((p0) => p0['medID'], 'medID', 2)));
  });
  test('cleanup should keep used timestamps', () async {
    final db = await mockDBManager();
    addTearDown(db.close);

    for (int i = 1; i <= 6; i += 1) {
      await db.db.insert('Timestamps', {
        'entryID': i,
        'timestampUnixS': i,
      });
    }
    await db.db.insert('Intake', {
      'entryID': 1,
      'medID': 0,
      'dosis': 0,
    });
    await db.db.insert('Systolic', {'entryID': 2,});
    await db.db.insert('Diastolic', {'entryID': 3,});
    await db.db.insert('Pulse', {'entryID': 4,});
    await db.db.insert('Notes', {'entryID': 5,});

    expect(await db.db.query('Timestamps'), hasLength(6));
    await db.performCleanup();
    expect(await db.db.query('Timestamps'), hasLength(5)); // remove 6 keep rest
  });
}

Future<DatabaseManager> mockDBManager() async => DatabaseManager.load(
  await openDatabase(inMemoryDatabasePath),
);

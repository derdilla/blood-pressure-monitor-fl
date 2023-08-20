import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class BloodPressureModel extends ChangeNotifier {
  static const maxEntries = 2E64; // https://www.sqlite.org/limits.html Nr.13
  late final Database _database;

  BloodPressureModel._create();
  Future<void> _asyncInit(String? dbPath, bool isFullPath) async {
    dbPath ??= await getDatabasesPath();

    if (dbPath != inMemoryDatabasePath && !isFullPath) {
      dbPath = join(dbPath, 'blood_pressure.db');
    }

    _database = await openDatabase(
      dbPath,
      // runs when the database is first created
      onCreate: (db, version) {
        return db.execute(
            'CREATE TABLE bloodPressureModel(timestamp INTEGER(14) PRIMARY KEY, systolic INTEGER, diastolic INTEGER, pulse INTEGER, notes STRING)');
      },
      version: 1,
    );
  }

  // factory method, to allow for async constructor
  static Future<BloodPressureModel> create({String? dbPath, bool isFullPath = false}) async {
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final component = BloodPressureModel._create();
    await component._asyncInit(dbPath, isFullPath);
    return component;
  }

  /// Adds a new measurement at the correct chronological position in the List.
  Future<void> add(BloodPressureRecord measurement) async {
    final existing = await _database.query('bloodPressureModel',
        where: 'timestamp = ?', whereArgs: [measurement.creationTime.millisecondsSinceEpoch]);
    if (existing.isNotEmpty) {
      await _database.update(
          'bloodPressureModel',
          {
            'systolic': measurement.systolic,
            'diastolic': measurement.diastolic,
            'pulse': measurement.pulse,
            'notes': measurement.notes
          },
          where: 'timestamp = ?',
          whereArgs: [measurement.creationTime.millisecondsSinceEpoch]);
    } else {
      await _database.insert('bloodPressureModel', {
        'timestamp': measurement.creationTime.millisecondsSinceEpoch,
        'systolic': measurement.systolic,
        'diastolic': measurement.diastolic,
        'pulse': measurement.pulse,
        'notes': measurement.notes
      });
    }
    notifyListeners();
  }

  Future<void> delete(DateTime timestamp) async {
    _database.delete('bloodPressureModel', where: 'timestamp = ?', whereArgs: [timestamp.millisecondsSinceEpoch]);
    notifyListeners();
  }

  /// Returns all recordings in saved in a range in ascending order
  Future<UnmodifiableListView<BloodPressureRecord>> getInTimeRange(DateTime from, DateTime to) async {
    final dbEntries = await _database.query('bloodPressureModel',
        orderBy: 'timestamp DESC',
        where: 'timestamp BETWEEN ? AND ?',
        whereArgs: [from.millisecondsSinceEpoch, to.millisecondsSinceEpoch]); // descending
    List<BloodPressureRecord> recordsInRange = _convert(dbEntries);
    return UnmodifiableListView(recordsInRange);
  }

  Future<UnmodifiableListView<BloodPressureRecord>> get all async {
    return UnmodifiableListView(_convert(await _database.query('bloodPressureModel', columns: ['*'])));
  }

  void close() {
    _database.close();
  }

  List<BloodPressureRecord> _convert(List<Map<String, Object?>> dbResult) {
    List<BloodPressureRecord> records = [];
    for (var e in dbResult) {
      records.add(BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(e['timestamp'] as int), e['systolic'] as int?,
          e['diastolic'] as int?, e['pulse'] as int?, e['notes'].toString()));
    }
    return records;
  }
}

@immutable
class BloodPressureRecord {
  late final DateTime _creationTime;
  final int? systolic;
  final int? diastolic;
  final int? pulse;
  final String notes;

  BloodPressureRecord(DateTime creationTime, this.systolic, this.diastolic, this.pulse, this.notes) {
    this.creationTime = creationTime;
  }

  DateTime get creationTime => _creationTime;
  /// datetime needs to be after epoch
  set creationTime(DateTime value) {
    if (creationTime.millisecondsSinceEpoch > 0) {
      _creationTime = creationTime;
    } else {
      assert(false, "Tried to create BloodPressureRecord at or before epoch");
      _creationTime = DateTime.fromMillisecondsSinceEpoch(1);
    }
  }

  @override
  String toString() {
    return 'BloodPressureRecord($creationTime, $systolic, $diastolic, $pulse, $notes)';
  }
}

// source: https://pressbooks.library.torontomu.ca/vitalsign/chapter/blood-pressure-ranges/ (last access: 20.05.2023)
class BloodPressureWarnValues {
  BloodPressureWarnValues._create();

  static String source = 'https://pressbooks.library.torontomu.ca/vitalsign/chapter/blood-pressure-ranges/';

  static int getUpperDiaWarnValue(int age) {
    if (age <= 2) {
      return 70;
    } else if (age <= 13) {
      return 80;
    } else if (age <= 18) {
      return 80;
    } else if (age <= 40) {
      return 80;
    } else if (age <= 60) {
      return 90;
    } else {
      return 90;
    }
  }

  static int getUpperSysWarnValue(int age) {
    if (age <= 2) {
      return 100;
    } else if (age <= 13) {
      return 120;
    } else if (age <= 18) {
      return 120;
    } else if (age <= 40) {
      return 125;
    } else if (age <= 60) {
      return 145;
    } else {
      return 145;
    }
  }
}

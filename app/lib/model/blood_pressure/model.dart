import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:blood_pressure_app/model/blood_pressure/needle_pin.dart';
import 'package:blood_pressure_app/model/blood_pressure/record.dart';
import 'package:blood_pressure_app/screens/error_reporting_screen.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Model to access values in the measurement database.
@Deprecated('use health_data_store')
class BloodPressureModel extends ChangeNotifier {

  BloodPressureModel._create();

  late final Database _database;

  FutureOr<void> _onDBCreate(Database db, int version) => db.execute('CREATE TABLE bloodPressureModel('
        'timestamp INTEGER(14) PRIMARY KEY,'
        'systolic INTEGER, diastolic INTEGER,'
        'pulse INTEGER,'
        'notes STRING,'
        'needlePin STRING)');

  FutureOr<void> _onDBUpgrade(Database db, int oldVersion, int newVersion) async {
    // When adding more versions the upgrade procedure proposed in https://stackoverflow.com/a/75153875/21489239
    // might be useful, to avoid duplicated code. Currently this would only lead to complexity, without benefits.
    if (oldVersion == 1 && newVersion == 2) {
      await db.execute('ALTER TABLE bloodPressureModel ADD COLUMN needlePin STRING;');
      await db.database.setVersion(2);
    } else {
      await ErrorReporting.reportCriticalError('Unsupported database upgrade', 'Attempted to upgrade the measurement database from version $oldVersion to version $newVersion, which is not supported. This action failed to avoid data loss. Please contact the app developer by opening an issue with the link below or writing an email to contact@derdilla.com.');
    }
  }

  /// Construct a instance of [BloodPressureModel] if a db file still exists.
  static Future<BloodPressureModel?> create({String? dbPath, bool isFullPath = false}) async {
    final component = BloodPressureModel._create();
    dbPath ??= await getDatabasesPath();

    if (dbPath != inMemoryDatabasePath && !isFullPath) {
      dbPath = join(dbPath, 'blood_pressure.db');
    }
    if (!File(dbPath).existsSync()) return null;
    component._database = await openDatabase(
      dbPath,
      onUpgrade: component._onDBUpgrade,
      // In integration tests the file may be deleted which causes deadlocks.
      singleInstance: false,
      version: 2,
    );
    return component;
  }

  /// Returns all recordings in saved in a range in ascending order
  Future<UnmodifiableListView<OldBloodPressureRecord>> getInTimeRange(DateTime from, DateTime to) async {
    if (!_database.isOpen) return UnmodifiableListView([]);
    final dbEntries = await _database.query('bloodPressureModel',
        orderBy: 'timestamp DESC',
        where: 'timestamp BETWEEN ? AND ?',
        whereArgs: [from.millisecondsSinceEpoch, to.millisecondsSinceEpoch],); // descending
    final List<OldBloodPressureRecord> recordsInRange = _convert(dbEntries);
    return UnmodifiableListView(recordsInRange);
  }

  /// Querries all measurements saved in the database.
  Future<UnmodifiableListView<OldBloodPressureRecord>> get all async {
    if (!_database.isOpen) return UnmodifiableListView([]);
    return UnmodifiableListView(_convert(await _database.query('bloodPressureModel', columns: ['*'])));
  }

  /// Close the database.
  ///
  /// Cannot be accessed anymore.
  Future<void> close() => _database.close();

  List<OldBloodPressureRecord> _convert(List<Map<String, Object?>> dbResult) {
    final List<OldBloodPressureRecord> records = [];
    for (final e in dbResult) {
      final needlePinJson = e['needlePin'] as String?;
      final needlePin = (needlePinJson != null) ? jsonDecode(needlePinJson) : null;
      records.add(OldBloodPressureRecord(
          DateTime.fromMillisecondsSinceEpoch(e['timestamp'] as int),
          e['systolic'] as int?,
          e['diastolic'] as int?,
          e['pulse'] as int?,
          e['notes'].toString(),
          needlePin: (needlePin != null) ? MeasurementNeedlePin.fromMap(needlePin) : null,
      ),);
    }
    return records;
  }
}

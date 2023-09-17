import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:blood_pressure_app/screens/error_reporting.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
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

    // In case safer data loading is needed: finish this.
    /*
    String? backupPath;
    if (dbPath != inMemoryDatabasePath) {
      assert(_database.isUndefinedOrNull);
      backupPath = join(Directory.systemTemp.path, 'blood_pressure_bu_${DateTime.now().millisecondsSinceEpoch}.db');
      final copiedFile = File(dbPath).copy(backupPath);
      copiedFile.onError((error, stackTrace) => null)
    }
    var preserveBackup = false;
    */

    _database = await openDatabase(
      dbPath,
      // runs when the database is first created
      onCreate: _onDBCreate,
      onUpgrade: _onDBUpgrade,
      version: 2,
    );
  }

  FutureOr<void> _onDBCreate(Database db, int version) {
      return db.execute('CREATE TABLE bloodPressureModel('
          'timestamp INTEGER(14) PRIMARY KEY,'
          'systolic INTEGER, diastolic INTEGER,'
          'pulse INTEGER,'
          'notes STRING,'
          'needlePin STRING)');
    }

  FutureOr<void> _onDBUpgrade(Database db, int oldVersion, int newVersion) async {
    // When adding more versions the upgrade procedure proposed in https://stackoverflow.com/a/75153875/21489239
    // might be useful, to avoid duplicated code. Currently this would only lead to complexity, without benefits.
    if (oldVersion == 1 && newVersion == 2) {
      db.execute('ALTER TABLE bloodPressureModel ADD COLUMN needlePin STRING;');
      db.database.setVersion(2);
    } else {
      await ErrorReporting.reportCriticalError('Unsupported database upgrade', 'Attempted to upgrade the measurement database from version $oldVersion to version $newVersion, which is not supported. This action failed to avoid data loss. Please contact the app developer by opening an issue with the link below or writing an email to contact@derdilla.com.');
    }
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
            'notes': measurement.notes,
            'needlePin': jsonEncode(measurement.needlePin)
          },
          where: 'timestamp = ?',
          whereArgs: [measurement.creationTime.millisecondsSinceEpoch]);
    } else {
      await _database.insert('bloodPressureModel', {
        'timestamp': measurement.creationTime.millisecondsSinceEpoch,
        'systolic': measurement.systolic,
        'diastolic': measurement.diastolic,
        'pulse': measurement.pulse,
        'notes': measurement.notes,
        'needlePin': jsonEncode(measurement.needlePin)
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
      final needlePinJson = e['needlePin'] as String?;
      records.add(BloodPressureRecord(
        DateTime.fromMillisecondsSinceEpoch(e['timestamp'] as int),
        e['systolic'] as int?,
        e['diastolic'] as int?,
        e['pulse'] as int?,
        e['notes'].toString(),
        needlePin: (needlePinJson == null) ? null : MeasurementNeedlePin.fromJson(jsonDecode(needlePinJson))
      ));
    }
    return records;
  }
}

@immutable
class BloodPressureRecord {
  late final DateTime creationTime;
  final int? systolic;
  final int? diastolic;
  final int? pulse;
  final String notes;
  final MeasurementNeedlePin? needlePin;

  BloodPressureRecord(DateTime creationTime, this.systolic, this.diastolic, this.pulse, this.notes, {
    this.needlePin
  }) {
    if (creationTime.millisecondsSinceEpoch > 0) {
      this.creationTime = creationTime;
    } else {
      assert(false, "Tried to create BloodPressureRecord at or before epoch");
      this.creationTime = DateTime.fromMillisecondsSinceEpoch(1);
    }
  }

  @override
  String toString() {
    return 'BloodPressureRecord($creationTime, $systolic, $diastolic, $pulse, $notes)';
  }
}

@immutable
class MeasurementNeedlePin {
  final Color color;

  const MeasurementNeedlePin(this.color);
  // When updating this, remember to be backwards compatible
  MeasurementNeedlePin.fromJson(Map<String, dynamic> json)
      : color = Color(json['color']);
  Map<String, dynamic> toJson() => {
    'color': color.value,
  };
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

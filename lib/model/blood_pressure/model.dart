import 'dart:async';
import 'dart:convert';

import 'package:blood_pressure_app/model/blood_pressure/needle_pin.dart';
import 'package:blood_pressure_app/model/blood_pressure/record.dart';
import 'package:blood_pressure_app/model/storage/storage.dart';
import 'package:blood_pressure_app/screens/error_reporting_screen.dart';
import 'package:blood_pressure_app/screens/subsettings/export_import/export_button_bar.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

/// Model to access values in the measurement database.
class BloodPressureModel extends ChangeNotifier {

  BloodPressureModel._create();

  late final Database _database;

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
      onCreate: _onDBCreate,
      onUpgrade: _onDBUpgrade,
      // When increasing the version an update procedure from every other possible version is needed
      version: 2,
    );
  }

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
      db.execute('ALTER TABLE bloodPressureModel ADD COLUMN needlePin STRING;');
      db.database.setVersion(2);
    } else {
      await ErrorReporting.reportCriticalError('Unsupported database upgrade', 'Attempted to upgrade the measurement database from version $oldVersion to version $newVersion, which is not supported. This action failed to avoid data loss. Please contact the app developer by opening an issue with the link below or writing an email to contact@derdilla.com.');
    }
  }

  /// Factory method to create a BloodPressureModel for a database file. This is needed to allow an async constructor.
  ///
  /// [dbPath] is the path to the folder the database is in. When [dbPath] is left empty the default database file is
  /// used. The [isFullPath] option tells the constructor not to add the default filename at the end of [dbPath].
  static Future<BloodPressureModel> create({String? dbPath, bool isFullPath = false}) async {
    final component = BloodPressureModel._create();
    await component._asyncInit(dbPath, isFullPath);
    return component;
  }

  /// Adds a new measurement at the correct chronological position in the List.
  ///
  /// This is not suitable for user inputs, as in this case export is needed as
  /// well. Consider using [BloodPressureModel.addAndExport] instead.
  Future<void> add(BloodPressureRecord measurement) async {
    if (!_database.isOpen) return;
    final existing = await _database.query('bloodPressureModel',
        where: 'timestamp = ?', whereArgs: [measurement.creationTime.millisecondsSinceEpoch],);
    if (existing.isNotEmpty) {
      await _database.update(
          'bloodPressureModel',
          {
            'systolic': measurement.systolic,
            'diastolic': measurement.diastolic,
            'pulse': measurement.pulse,
            'notes': measurement.notes,
            'needlePin': jsonEncode(measurement.needlePin),
          },
          where: 'timestamp = ?',
          whereArgs: [measurement.creationTime.millisecondsSinceEpoch],);
    } else {
      await _database.insert('bloodPressureModel', {
        'timestamp': measurement.creationTime.millisecondsSinceEpoch,
        'systolic': measurement.systolic,
        'diastolic': measurement.diastolic,
        'pulse': measurement.pulse,
        'notes': measurement.notes,
        'needlePin': jsonEncode(measurement.needlePin),
      });
    }
    notifyListeners();
  }

  /// Convenience wrapper for [add] that follows best practices.
  ///
  /// This ensures no timeout occurs by waiting for operations to finish and
  /// exports in case the [context] is provided and the option in export
  /// settings is active.
  Future<void> addAll(
    List<BloodPressureRecord> measurements,
    BuildContext? context,
  ) async {
    for (final measurement in measurements) {
      await add(measurement);
    }

    if (context == null || !context.mounted) return;
    final exportSettings = Provider.of<ExportSettings>(context, listen: false);
    if (exportSettings.exportAfterEveryEntry) {
      performExport(context);
    }
  }

  /// Adds a measurement to the model and tries to export all measurements, if [ExportSettings.exportAfterEveryEntry] is
  /// true.
  Future<void> addAndExport(BuildContext context, BloodPressureRecord record) async {
    await add(record);

    if (!context.mounted) return;
    final exportSettings = Provider.of<ExportSettings>(context, listen: false);
    if (exportSettings.exportAfterEveryEntry) {
      performExport(context);
    }
  }

  /// Try to remove the measurement at a specific timestamp from the database.
  ///
  /// When no measurement at that time exists, the operation won't fail and
  /// listeners will get notified anyways.
  Future<void> delete(DateTime timestamp) async {
    if (!_database.isOpen) return;
    _database.delete('bloodPressureModel', where: 'timestamp = ?', whereArgs: [timestamp.millisecondsSinceEpoch]);
    notifyListeners();
  }

  /// Returns all recordings in saved in a range in ascending order
  Future<UnmodifiableListView<BloodPressureRecord>> getInTimeRange(DateTime from, DateTime to) async {
    if (!_database.isOpen) return UnmodifiableListView([]);
    final dbEntries = await _database.query('bloodPressureModel',
        orderBy: 'timestamp DESC',
        where: 'timestamp BETWEEN ? AND ?',
        whereArgs: [from.millisecondsSinceEpoch, to.millisecondsSinceEpoch],); // descending
    final List<BloodPressureRecord> recordsInRange = _convert(dbEntries);
    return UnmodifiableListView(recordsInRange);
  }

  /// Querries all measurements saved in the database.
  Future<UnmodifiableListView<BloodPressureRecord>> get all async {
    if (!_database.isOpen) return UnmodifiableListView([]);
    return UnmodifiableListView(_convert(await _database.query('bloodPressureModel', columns: ['*'])));
  }

  /// Close the database.
  ///
  /// Cannot be accessed anymore.
  Future<void> close() => _database.close();

  List<BloodPressureRecord> _convert(List<Map<String, Object?>> dbResult) {
    final List<BloodPressureRecord> records = [];
    for (final e in dbResult) {
      final needlePinJson = e['needlePin'] as String?;
      final needlePin = (needlePinJson != null) ? jsonDecode(needlePinJson) : null;
      records.add(BloodPressureRecord(
          DateTime.fromMillisecondsSinceEpoch(e['timestamp'] as int),
          e['systolic'] as int?,
          e['diastolic'] as int?,
          e['pulse'] as int?,
          e['notes'].toString(),
          needlePin: (needlePin != null) ? MeasurementNeedlePin.fromJson(needlePin) : null,
      ),);
    }
    return records;
  }
}

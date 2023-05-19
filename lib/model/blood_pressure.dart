import 'package:collection/collection.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:file_saver/file_saver.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart' show XFile;
import 'dart:convert' show utf8;

class BloodPressureModel extends ChangeNotifier {
  static const maxEntries = 2E64; // https://www.sqlite.org/limits.html Nr.13
  late final Database _database;

  BloodPressureModel._create();
  Future<void> _asyncInit(String? dbPath) async {
    dbPath ??= await getDatabasesPath();

    if (dbPath != inMemoryDatabasePath) {
      dbPath = join(dbPath, 'blood_pressure.db');
    }

    _database = await openDatabase(
      dbPath,
      // runs when the database is first created
      onCreate: (db, version) {
        return db.execute('CREATE TABLE bloodPressureModel(timestamp INTEGER(14) PRIMARY KEY, systolic INTEGER, diastolic INTEGER, pulse INTEGER, notes STRING)');
      },
      version: 1,
    );
  }
  // factory method, to allow for async constructor
  static Future<BloodPressureModel> create({String? dbPath}) async {
    if (Platform.isWindows || Platform.isLinux) {
      // Initialize FFI
      sqfliteFfiInit();
      // Change the default factory
      databaseFactory = databaseFactoryFfi;
    }

    final component = BloodPressureModel._create();
    await component._asyncInit(dbPath);
    return component;
  }

  /// Adds a new measurement at the correct chronological position in the List.
  Future<void> add(BloodPressureRecord measurement) async {
    assert(_database.isOpen);

    var existing = _database.query('bloodPressureModel', where: 'timestamp = ?',
        whereArgs: [measurement.creationTime.millisecondsSinceEpoch]);
    if ((await existing).isNotEmpty) {
        await _database.update('bloodPressureModel', {
          'systolic': measurement.systolic,
          'diastolic': measurement.diastolic,
          'pulse': measurement.pulse,
          'notes': measurement.notes
        }, where: 'timestamp = ?',
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

  /// Returns the last x BloodPressureRecords from new to old.
  /// Caches new ones if necessary
  Future<UnmodifiableListView<BloodPressureRecord>> getLastX(int count) async {
    List<BloodPressureRecord> lastMeasurements = [];

    var dbEntries = await _database.query('bloodPressureModel',
        orderBy: 'timestamp DESC', limit: count); // de
    for (var e in dbEntries) {
      lastMeasurements.add(BloodPressureRecord(
          DateTime.fromMillisecondsSinceEpoch(e['timestamp']as int),
          e['systolic'] as int,
          e['diastolic'] as int,
          e['pulse'] as int,
          e['notes'].toString()));

    }
    return UnmodifiableListView(lastMeasurements);
  }

  /// Returns all recordings in saved in a range in ascending order
  Future<UnmodifiableListView<BloodPressureRecord>> getInTimeRange(DateTime from, DateTime to) async {
    var dbEntries = await _database.query('bloodPressureModel',
      orderBy: 'timestamp DESC',
      where: 'timestamp BETWEEN ? AND ?',
      whereArgs: [from.millisecondsSinceEpoch, to.millisecondsSinceEpoch]
    ); // descending
    // synchronous part
    List<BloodPressureRecord> recordsInRange = [];
    for (var e in dbEntries) {
      recordsInRange.add(BloodPressureRecord(
          DateTime.fromMillisecondsSinceEpoch(e['timestamp']as int),
          e['systolic'] as int,
          e['diastolic'] as int,
          e['pulse'] as int,
          e['notes'].toString())
      );
    }
    return UnmodifiableListView(recordsInRange);
  }

  Future<void> delete(DateTime timestamp) async {
    _database.delete('bloodPressureModel', where: 'timestamp = ?', whereArgs: [timestamp.millisecondsSinceEpoch]);
    notifyListeners();
  }
  
  Future<int> get count async {
    return (await _database.rawQuery('SELECT COUNT(*) FROM bloodPressureModel'))[0]['COUNT(*)'] as int? ?? -1;
  }
  Future<int> get measurementsPerDay async {
    final c = await count;
    if (c <= 1) {
      return -1;
    }
    var firstDay = DateTime.fromMillisecondsSinceEpoch((await _database.rawQuery('SELECT timestamp FROM bloodPressureModel ORDER BY timestamp ASC LIMIT 1'))[0]['timestamp'] as int? ?? -1);
    var lastDay = DateTime.fromMillisecondsSinceEpoch((await _database.rawQuery('SELECT timestamp FROM bloodPressureModel ORDER BY timestamp DESC LIMIT 1'))[0]['timestamp'] as int? ?? -1);

    return c ~/ lastDay.difference(firstDay).inDays;

  }


  Future<int> get avgDia async {
    var res = (await _database.rawQuery('SELECT AVG(diastolic) as dia FROM bloodPressureModel'))[0]['dia'];
    int? val;
    try {
      val = (res as int?);
    } catch (e) {
      val = (res as double?)?.toInt();
    }
    return val ?? -1;
  }
  Future<int> get avgSys async {
    var res = (await _database.rawQuery('SELECT AVG(systolic) as sys FROM bloodPressureModel'))[0]['sys'];
    int? val;
    try {
      val = (res as int?);
    } catch (e) {
      val = (res as double?)?.toInt();
    }
    return val ?? -1;
  }
  Future<int> get avgPul async {
    var res = (await _database.rawQuery('SELECT AVG(pulse) as pul FROM bloodPressureModel'))[0]['pul'];
    int? val;
    try {
      val = (res as int?);
    } catch (e) {
      val = (res as double?)?.toInt();
    }
    return val ?? -1;
  }

  Future<int> get maxDia async {
    var res = (await _database.rawQuery('SELECT MAX(diastolic) as dia FROM bloodPressureModel'))[0]['dia'];
    return (res as int?) ?? -1;
  }
  Future<int> get maxSys async {
    var res = (await _database.rawQuery('SELECT MAX(systolic) as sys FROM bloodPressureModel'))[0]['sys'];
    return (res as int?) ?? -1;
  }
  Future<int> get maxPul async {
    var res = (await _database.rawQuery('SELECT MAX(pulse) as pul FROM bloodPressureModel'))[0]['pul'];
    return (res as int?) ?? -1;
  }

  Future<int> get minDia async {
    var res = (await _database.rawQuery('SELECT MIN(diastolic) as dia FROM bloodPressureModel'))[0]['dia'];
    return (res as int?) ?? -1;
  }
  Future<int> get minSys async {
    var res = (await _database.rawQuery('SELECT MIN(systolic) as sys FROM bloodPressureModel'))[0]['sys'];
    return (res as int?) ?? -1;
  }
  Future<int> get minPul async {
    var res = (await _database.rawQuery('SELECT MIN(pulse) as pul FROM bloodPressureModel'))[0]['pul'];
    return (res as int?) ?? -1;
  }

  /// outer list is type (0 -> diastolic, 1 -> systolic, 2 -> pulse)
  /// inner list index is hour of day ([0] -> 00:00-00:59; [1] -> ...)
  Future<List<List<int>>> get allAvgsRelativeToDaytime async {
    // setup vars
    List<List<int>> allDiaValuesRelativeToTime = [[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[]];
    List<List<int>> allSysValuesRelativeToTime = [[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[]];
    List<List<int>> allPulValuesRelativeToTime = [[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[]];

    // sort all data
    final dbRes = await _database.query('bloodPressureModel', columns: ['*']);
    for (var entry in dbRes) {
      DateTime ts = DateTime.fromMillisecondsSinceEpoch(entry['timestamp'] as int);
      allDiaValuesRelativeToTime[ts.hour].add(entry['diastolic'] as int);
      allSysValuesRelativeToTime[ts.hour].add(entry['systolic'] as int);
      allPulValuesRelativeToTime[ts.hour].add(entry['pulse'] as int);
    }
    for(int i = 0; i < 24; i++) {
      if (allDiaValuesRelativeToTime[i].isEmpty) {
        allDiaValuesRelativeToTime[i].add(await avgDia);
      }
      if (allSysValuesRelativeToTime[i].isEmpty) {
        allSysValuesRelativeToTime[i].add(await avgSys);
      }
      if (allPulValuesRelativeToTime[i].isEmpty) {
        allPulValuesRelativeToTime[i].add(await avgPul);
      }
    }

    // make avgs
    List<List<int>> res = [[],[],[]];
    for(int i = 0; i < 24; i++) {
      res[0].add(allDiaValuesRelativeToTime[i].average.toInt());
      res[1].add(allSysValuesRelativeToTime[i].average.toInt());
      res[2].add(allPulValuesRelativeToTime[i].average.toInt());
    }
    return res;
  }

  Future<void> save(void Function(bool success, String? msg) callback, {bool exportAsText = false}) async {
    // create csv
    String csvData = 'timestampUnixMs, systolic, diastolic, pulse, notes\n';
    List<Map<String, Object?>> allEntries = await _database.query('bloodPressureModel',
      orderBy: 'timestamp DESC');
    for (var e in allEntries) {
      csvData += '${e['timestamp']}, ${e['systolic']}, ${e['diastolic']}, ${e['pulse']}, "${e['notes']}"\n';
    }

    // save data
    String filename = 'blood_press_${DateTime.now().toIso8601String()}';
    String path = await FileSaver.instance.saveFile(
      name: filename,
      bytes: Uint8List.fromList(utf8.encode(csvData)),
      ext: 'csv',
      mimeType: MimeType.csv
    );

    // notify user about location
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      callback(true, 'Exported to: $path');
    } else if (Platform.isAndroid || Platform.isIOS) {
      var mimeType = MimeType.csv;
      if (exportAsText) {
        mimeType = MimeType.text;
      }
      Share.shareXFiles([XFile(path, mimeType: mimeType.type,)]);
      callback(true, null);
    } else {

    }
  }

  Future<void> import(void Function(bool, String?) callback) async {
    var result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        withData: true,
    );

    if (result != null) {
      var binaryContent = result.files.single.bytes;
      if (binaryContent != null) {
        final csvContents = const CsvToListConverter().convert(
            String.fromCharCodes(binaryContent),
            fieldDelimiter: ',',
            textDelimiter: '"',
            eol: '\n'
        );
        for (var i = 1; i < csvContents.length; i++) {
          var line = csvContents[i];
          BloodPressureRecord record = BloodPressureRecord(
              DateTime.fromMillisecondsSinceEpoch(line[0] as int),
              (line[1] as int),
              (line[2] as int),
              (line[3] as int),
              line[4]);
          add(record);
        }
        return callback(true, null);

      } else {
        return callback(false, 'empty file');
      }
    } else {
      return callback(false, 'no file opened');
    }
  }

  void close() {
    _database.close();
  }
}

@immutable
class BloodPressureRecord {
  final DateTime creationTime;
  final int systolic;
  final int diastolic;
  final int pulse;
  final String notes;

  const BloodPressureRecord(
      this.creationTime, this.systolic, this.diastolic, this.pulse, this.notes);
}

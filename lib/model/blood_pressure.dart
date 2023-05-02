import 'dart:collection';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:file_saver/file_saver.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert' show utf8;
import 'dart:typed_data';

class BloodPressureModel extends ChangeNotifier {
  static const maxEntries = 2E64; // https://www.sqlite.org/limits.html Nr.13
  late final Database _database;
  List<BloodPressureRecord> _allMeasurements = []; // TODO: remove cache
  var _cacheCount = 100; // how many db entries are cached on default

  BloodPressureModel._create();
  Future<void> _asyncInit() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'blood_pressure.db'),
      // runs when the database is first created
      onCreate: (db, version) {
        return db.execute('CREATE TABLE bloodPressureModel(timestamp INTEGER(14) PRIMARY KEY, systolic INTEGER, diastolic INTEGER, pulse INTEGER, notes STRING)');
      },
      version: 1,
    );
    await _cacheLast();
  }
  // factory method, to allow for async contructor
  static Future<BloodPressureModel> create() async {
    final component = BloodPressureModel._create();
    await component._asyncInit();
    return component;
  }

  Future<void> _cacheLast() async {
    var dbEntries = await _database.query('bloodPressureModel',
        orderBy: 'timestamp DESC', limit: _cacheCount); // descending
    // syncronous part
    _allMeasurements = [];
    for (var e in dbEntries) {
      _allMeasurements.add(BloodPressureRecord(
        DateTime.fromMillisecondsSinceEpoch(e['timestamp']as int), 
        e['systolic'] as int, 
        e['diastolic'] as int, 
        e['pulse'] as int, 
        e['notes'] as String));
    }
    
    notifyListeners();
  }

  /// Adds a new measurement at the correct chronological position in the List.
  Future<void> add(BloodPressureRecord measurement) async {
    assert(_database.isOpen);

    _database.rawInsert('INSERT INTO bloodPressureModel(timestamp, systolic, diastolic, pulse, notes) VALUES (?, ?, ?, ?, ?)', [
      measurement.creationTime.millisecondsSinceEpoch,
      measurement.systolic,
      measurement.diastolic,
      measurement.pulse,
      measurement.notes]);

    _cacheLast(); // hast notifyListeners()
  }

  /// Returns the last x BloodPressureRecords from new to old.
  /// Caches new ones if necessary
  UnmodifiableListView<BloodPressureRecord> getLastX(int count) {
    List<BloodPressureRecord> lastMeasurements = [];
    
    // fetch more if needed
    if (count > _cacheCount) {
      _cacheCount = count;
      _cacheLast();
    } else if (count == _cacheCount) { // small optimization
      lastMeasurements = _allMeasurements;
    } else {
      for (int i = 0; (i<count && i<_allMeasurements.length); i++) {
        lastMeasurements.add(_allMeasurements[i]);
      }
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
    // syncronous part
    List<BloodPressureRecord> recordsInRange = [];
    for (var e in dbEntries) {
      recordsInRange.add(BloodPressureRecord(
          DateTime.fromMillisecondsSinceEpoch(e['timestamp']as int),
          e['systolic'] as int,
          e['diastolic'] as int,
          e['pulse'] as int,
          e['notes'] as String));
    }
    return UnmodifiableListView(recordsInRange);
  }

  Future<void> save(BuildContext context) async { // TODO: passing context is not clean keep UI code out of model
    // create csv
    String csvData = 'timestampUnixMs, systolic, diastolic, pulse, notes\n';
    List<Map<String, Object?>> allEntries = await _database.query('bloodPressureModel',
      orderBy: 'timestamp DESC');
    for (var e in allEntries) {
      csvData += '${e['timestamp']}, ${e['systolic']}, ${e['diastolic']}, ${e['pulse']}, "${e['notes']}"\n';
    }

    // save data
    print(csvData);
    String path = await FileSaver.instance.saveFile(
      name: 'blood_press_${DateTime.now().toIso8601String()}',
      bytes: Uint8List.fromList(utf8.encode(csvData)),
      ext: 'csv',
      mimeType: MimeType.csv
    );

    // notify user about location
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Exported to: $path')));
    } else if (Platform.isAndroid || Platform.isIOS) {
      Share.shareFiles([path], mimeTypes: [MimeType.csv.type]);
    } else {

    }


  }
  

/* TODO:
  - bool deleteFromTime (timestamp)
  - bool changeAtTime (newRecord)
   */


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

  @override
  int compareTo(BloodPressureRecord other) {
    if (creationTime.isBefore(other.creationTime)) {
      return -1;
    } else if (creationTime.isAfter(other.creationTime)) {
      return 1;
    } else {
      return 0;
    }
  }
}
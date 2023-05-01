import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';

class BloodPressureModel extends ChangeNotifier {
  static const maxEntries = 2E64; // https://www.sqlite.org/limits.html Nr.13
  late final Database _database;
  List<BloodPressureRecord> _allMeasurements = [];
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

  // All measurements (might get slow after some time)
  UnmodifiableListView<BloodPressureRecord> get allMeasurements => UnmodifiableListView(_allMeasurements);

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

    _cacheLast();
  }

  /// Returns the last x BloodPressureRecords from new to old
  /// caches new ones if necessary
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
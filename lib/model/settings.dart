
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

class Settings extends ChangeNotifier {
  static const maxEntries = 2E64; // https://www.sqlite.org/limits.html Nr.13
  late final Database _database;

  late int _graphStepSize;

  Settings._create();
  Future<void> _asyncInit() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'settings.db'),
      // runs when the database is first created
      onCreate: (db, version) {
        return db.execute('CREATE TABLE settings(key STRING PRIMARY KEY, value STRING)');
      },
      version: 1,
    );
    await _loadSettings();
  }
  // factory method, to allow for async contructor
  static Future<Settings> create() async {
    final component = Settings._create();
    await component._asyncInit();
    return component;
  }

  Future<Object?> _getSetting(String key) async {
    final r = await _database.query('settings', where: 'key = ?', whereArgs: [key]);
    if (r.isNotEmpty) {
      return r[0]['value'];
    }
  }

  Future<void> _saveSetting(String key, Object value) async {
    if ((await _database.query('settings', where: 'key = ?', whereArgs: [key])).isEmpty) {
      _database.insert('settings', {'key': key, 'value': value});
    } else {
      _database.update('settings', {'value': value}, where: 'key = ?', whereArgs: [key]);
    }
  }

  Future<void> _loadSettings() async {
    var pGraphStepSize = _getSetting('_graphStepSize');
    // var ...

    _graphStepSize = (await pGraphStepSize as int?) ?? TimeStep.day;
    // ...
  }

  int get graphStepSize {
    return _graphStepSize;
  }
  set graphStepSize(int newStepSize) {
    _graphStepSize = newStepSize;
    _saveSetting('_graphStepSize', newStepSize);
    notifyListeners();
  }

}

class TimeStep {
  static const options = [0, 1, 2, 3];

  static const day = 0;
  static const month = 1;
  static const year = 2;
  static const lifetime = 3;

  static String getName(int opt) {
    switch (opt) {
      case day:
        return 'day';
      case month:
        return 'month';
      case year:
        return 'year';
      case lifetime:
        return 'lifetime';
    }
    return 'invalid';
  }
}

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
  late DateTime _graphStart;
  late DateTime _graphEnd;
  late bool _followSystemDarkMode;
  late bool _darkMode;
  late MaterialColor _accentColor;
  late MaterialColor _sysColor;
  late MaterialColor _diaColor;
  late MaterialColor _pulColor;
  late bool _allowManualTimeInput;

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
    var pGraphStart = _getSetting('_graphStart');
    var pGraphEnd = _getSetting('_graphEnd');
    var pFollowSystemDarkMode = _getSetting('_followSystemDarkMode');
    var pDarkMode = _getSetting('_darkMode');
    var pAccentColor = _getSetting('_accentColor');
    var pSysColor = _getSetting('_sysColor');
    var pDiaColor = _getSetting('_diaColor');
    var pPulColor = _getSetting('_pulColor');
    var pAllowManualTimeInput = _getSetting('_allowManualTimeInput');
    // var ...

    _graphStepSize = (await pGraphStepSize as int?) ?? TimeStep.day;
    _graphStart = DateTime.fromMillisecondsSinceEpoch((await pGraphStart as int?) ?? -1);
    _graphEnd = DateTime.fromMillisecondsSinceEpoch((await pGraphEnd as int?) ?? -1);
    _followSystemDarkMode = ((await pFollowSystemDarkMode as int?) ?? "1") == "1" ? true : false;
    _darkMode = ((await pDarkMode as int?) ?? 1) == 1 ? true : false;
    _accentColor = createMaterialColor(await pAccentColor as int? ?? 0xFF009688);
    _sysColor = createMaterialColor(await pSysColor as int? ?? 0xFF009688);
    _diaColor = createMaterialColor(await pDiaColor as int? ?? 0xFF4CAF50);
    _pulColor = createMaterialColor(await pPulColor as int? ?? 0xFFF44336);
    _allowManualTimeInput = ((await pAllowManualTimeInput as int?) ?? 1) == 1 ? true : false;
    // ...
    return;
  }

  MaterialColor createMaterialColor(int value) {
    final color = Color(value);
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(value, swatch);
  }

  int get graphStepSize {
    return _graphStepSize;
  }
  set graphStepSize(int newStepSize) {
    _graphStepSize = newStepSize;
    _saveSetting('_graphStepSize', newStepSize);
    notifyListeners();
  }

  DateTime get graphStart {
    return _graphStart;
  }
  set graphStart(DateTime newGraphStart) {
    _graphStart = newGraphStart;
    _saveSetting('_graphStart', newGraphStart.millisecondsSinceEpoch);
    notifyListeners();
  }

  DateTime get graphEnd {
    return _graphEnd;
  }
  set graphEnd(DateTime newGraphEnd) {
    _graphEnd = newGraphEnd;
    _saveSetting('_graphEnd', newGraphEnd.millisecondsSinceEpoch);
    notifyListeners();
  }
  bool get followSystemDarkMode {
    return _followSystemDarkMode;
  }
  set followSystemDarkMode(bool newSetting) {
    _followSystemDarkMode = newSetting;
    _saveSetting('_followSystemDarkMode', newSetting ? "1" : "0");
    notifyListeners();
  }
  bool get darkMode {
    return _darkMode;
  }
  set darkMode(bool newSetting) {
    _darkMode = newSetting;
    _saveSetting('_darkMode', newSetting ? 1 : 0);
    notifyListeners();
  }
  MaterialColor get accentColor {
    return _accentColor;
  }
  set accentColor(MaterialColor newColor) {
    _accentColor = newColor;
    _saveSetting('_accentColor', newColor.value);
    notifyListeners();
  }
  MaterialColor get diaColor {
    return _diaColor;
  }
  set diaColor(MaterialColor newColor) {
    _diaColor = newColor;
    _saveSetting('_diaColor', newColor.value);
    notifyListeners();
  }
  MaterialColor get sysColor {
    return _sysColor;
  }
  set sysColor(MaterialColor newColor) {
    _sysColor = newColor;
    _saveSetting('_sysColor', newColor.value);
    notifyListeners();
  }
  MaterialColor get pulColor {
    return _pulColor;
  }
  set pulColor(MaterialColor newColor) {
    _pulColor = newColor;
    _saveSetting('_pulColor', newColor.value);
    notifyListeners();
  }
  bool get allowManualTimeInput {
    return _allowManualTimeInput;
  }
  set allowManualTimeInput(bool newSetting) {
    _allowManualTimeInput = newSetting;
    _saveSetting('_allowManualTimeInput', newSetting ? 1 : 0);
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
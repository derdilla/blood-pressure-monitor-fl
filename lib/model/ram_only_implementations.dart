import 'dart:collection';

import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:blood_pressure_app/model/export_import.dart';
import 'package:blood_pressure_app/model/settings_store.dart';
import 'package:file_saver/file_saver.dart' show MimeType;
import 'package:flutter/material.dart';

class RamBloodPressureModel extends ChangeNotifier implements BloodPressureModel {
  final List<BloodPressureRecord> _records = [];

  @override
  Future<void> add(BloodPressureRecord measurement) async {
    _records.add(measurement);
    notifyListeners();
  }

  @override
  Future<void> delete(DateTime timestamp) async {
    _records.removeWhere((element) => element.creationTime.isAtSameMomentAs(timestamp));
  }

  @override
  Future<UnmodifiableListView<BloodPressureRecord>> getInTimeRange(DateTime from, DateTime to) async {
    List<BloodPressureRecord> recordsInTime = [];
    for (final e in _records) {
      if (e.creationTime.isAfter(from) && e.creationTime.isBefore(to)) {
        recordsInTime.add(e);
      }
    }
    return UnmodifiableListView(recordsInTime);
  }

  @override
  Future<UnmodifiableListView<BloodPressureRecord>> get all async => UnmodifiableListView(_records);

  @override
  void close() {}
}

class RamSettings extends ChangeNotifier implements Settings {
  MaterialColor _accentColor = Colors.pink;
  bool _allowManualTimeInput = true;
  int _animationSpeed = 150;
  bool _confirmDeletion = true;
  bool _darkMode = true;
  String _dateFormatString = 'yyyy-MM-dd  HH:mm';
  MaterialColor _diaColor = Colors.pink;
  int _diaWarn = 80;
  DateTime? _displayDataEnd;
  DateTime? _displayDataStart;
  bool _followSystemDarkMode = true;
  double _graphLineThickness = 3;
  TimeStep _graphStepSize = TimeStep.day;
  double _iconSize = 30;
  MaterialColor _pulColor = Colors.pink;
  MaterialColor _sysColor = Colors.pink;
  int _sysWarn = 120;
  bool _useExportCompatability = false;
  bool _validateInputs = true;
  int _graphTitlesCount = 5;
  ExportFormat _exportFormat = ExportFormat.csv;
  String _csvFieldDelimiter = ',';
  String _csvTextDelimiter = '"';
  List<String> _exportAddableItems = ['isoUTCTime'];
  bool _exportCsvHeadline = true;
  bool _exportCustomEntries = false;
  List<String> _exportItems = ['timestampUnixMs', 'systolic', 'diastolic', 'pulse', 'notes'];
  MimeType _exportMimeType = MimeType.csv;
  String _defaultExportDir = '';
  bool _exportAfterEveryEntry = false;
  bool _allowMissingValues = false;
  Locale? _language;

  RamSettings() {
    _accentColor = createMaterialColor(0xFF009688);
    _diaColor = createMaterialColor(0xFF4CAF50);
    _pulColor = createMaterialColor(0xFFF44336);
    _sysColor = createMaterialColor(0xFF009688);
  }

  @override
  int get diaWarn {
    return _diaWarn;
  }

  @override
  set diaWarn(int newWarn) {
    _diaWarn = newWarn;
    notifyListeners();
  }

  @override
  DateTime get displayDataStart {
    final s = _displayDataStart ?? getMostRecentDisplayIntervall()[0];
    if(s.millisecondsSinceEpoch < 0) {
      changeStepSize(TimeStep.last7Days);
    }
    return s;
  }

  @override
  set displayDataStart(DateTime newGraphStart) {
    _displayDataStart = newGraphStart;
    notifyListeners();
  }

  @override
  DateTime get displayDataEnd {
    final s = _displayDataEnd ?? getMostRecentDisplayIntervall()[1];
    if(s.millisecondsSinceEpoch < 0) {
      changeStepSize(TimeStep.last7Days);
    }
    return s;
  }

  @override
  set displayDataEnd(DateTime newGraphEnd) {
    _displayDataEnd = newGraphEnd;
    notifyListeners();
  }

  @override
  int get sysWarn {
    return _sysWarn;
  }

  @override
  set sysWarn(int newWarn) {
    _sysWarn = newWarn;
    notifyListeners();
  }

  @override
  MaterialColor get accentColor => _accentColor;

  @override
  set accentColor(MaterialColor value) {
    _accentColor = value;
    notifyListeners();
  }

  @override
  bool get allowManualTimeInput => _allowManualTimeInput;

  @override
  set allowManualTimeInput(bool value) {
    _allowManualTimeInput = value;
    notifyListeners();
  }

  @override
  int get animationSpeed => _animationSpeed;

  @override
  set animationSpeed(int value) {
    _animationSpeed = value;
    notifyListeners();
  }

  @override
  bool get confirmDeletion => _confirmDeletion;

  @override
  set confirmDeletion(bool value) {
    _confirmDeletion = value;
    notifyListeners();
  }

  @override
  bool get darkMode => _darkMode;

  @override
  set darkMode(bool value) {
    _darkMode = value;
    notifyListeners();
  }

  @override
  String get dateFormatString => _dateFormatString;

  @override
  set dateFormatString(String value) {
    _dateFormatString = value;
    notifyListeners();
  }

  @override
  MaterialColor get diaColor => _diaColor;

  @override
  set diaColor(MaterialColor value) {
    _diaColor = value;
    notifyListeners();
  }

  @override
  bool get followSystemDarkMode => _followSystemDarkMode;

  @override
  set followSystemDarkMode(bool value) {
    _followSystemDarkMode = value;
    notifyListeners();
  }

  @override
  double get graphLineThickness => _graphLineThickness;

  @override
  set graphLineThickness(double value) {
    _graphLineThickness = value;
    notifyListeners();
  }

  @override
  TimeStep get graphStepSize => _graphStepSize;

  @override
  set graphStepSize(TimeStep value) {
    _graphStepSize = value;
    notifyListeners();
  }

  @override
  double get iconSize => _iconSize;

  @override
  set iconSize(double value) {
    _iconSize = value;
    notifyListeners();
  }

  @override
  MaterialColor get pulColor => _pulColor;

  @override
  set pulColor(MaterialColor value) {
    _pulColor = value;
    notifyListeners();
  }

  @override
  MaterialColor get sysColor => _sysColor;

  @override
  set sysColor(MaterialColor value) {
    _sysColor = value;
    notifyListeners();
  }

  @override
  bool get validateInputs => _validateInputs;

  @override
  set validateInputs(bool value) {
    _validateInputs = value;
    notifyListeners();
  }

  @override
  int get graphTitlesCount => _graphTitlesCount;

  @override
  set graphTitlesCount(int value) {
    _graphTitlesCount = value;
    notifyListeners();
  }

  @override
  ExportFormat get exportFormat => _exportFormat;

  @override
  set exportFormat(ExportFormat value) {
    _exportFormat = value;
    notifyListeners();
  }

  bool get useExportCompatability => _useExportCompatability;

  set useExportCompatability(bool value) {
    _useExportCompatability = value;
    notifyListeners();
  }

  @override
  String get csvFieldDelimiter => _csvFieldDelimiter;

  @override
  set csvFieldDelimiter(String value) {
    _csvFieldDelimiter = value;
    notifyListeners();
  }

  @override
  String get csvTextDelimiter => _csvTextDelimiter;

  @override
  set csvTextDelimiter(String value) {
    _csvTextDelimiter = value;
    notifyListeners();
  }

  @override
  List<String> get exportAddableItems => _exportAddableItems;

  @override
  set exportAddableItems(List<String> value) {
    _exportAddableItems = value;
    notifyListeners();
  }

  @override
  bool get exportCsvHeadline => _exportCsvHeadline;

  @override
  set exportCsvHeadline(bool value) {
    _exportCsvHeadline = value;
    notifyListeners();
  }

  @override
  bool get exportCustomEntries => _exportCustomEntries;

  @override
  set exportCustomEntries(bool value) {
    _exportCustomEntries = value;
    notifyListeners();
  }

  @override
  List<String> get exportItems => _exportItems;

  @override
  set exportItems(List<String> value) {
    _exportItems = value;
    notifyListeners();
  }

  @override
  MimeType get exportMimeType => _exportMimeType;

  @override
  set exportMimeType(MimeType value) {
    _exportMimeType = value;
    notifyListeners();
  }

  @override
  String get defaultExportDir => _defaultExportDir;

  @override
  set defaultExportDir(String value) {
    _defaultExportDir = value;
    notifyListeners();
  }

  @override
  bool get exportAfterEveryEntry => _exportAfterEveryEntry;

  @override
  set exportAfterEveryEntry(bool value) {
    _exportAfterEveryEntry = value;
    notifyListeners();
  }

  @override
  bool get allowMissingValues => _allowMissingValues;

  @override
  set allowMissingValues(bool value) {
    _allowMissingValues = value;
    notifyListeners();
  }

  @override
  Locale? get language => _language;

  @override
  set language(Locale? value) {
    _language = value;
    notifyListeners();
  }

  @override
  void changeStepSize(TimeStep value) {
    graphStepSize = value;
    final newInterval = getMostRecentDisplayIntervall();
    displayDataStart = newInterval[0];
    displayDataEnd = newInterval[1];
  }

  // directional step either 1 or -1
  @override
  void moveDisplayDataByStep(int directionalStep) {
    final oldStart = displayDataStart;
    final oldEnd = displayDataEnd;
    switch (graphStepSize) {
      case TimeStep.day:
        displayDataStart = oldStart.copyWith(day: oldStart.day + directionalStep);
        displayDataEnd = oldEnd.copyWith(day: oldEnd.day + directionalStep);
        break;
      case TimeStep.week:
      case TimeStep.last7Days:
        displayDataStart = oldStart.copyWith(day: oldStart.day + directionalStep * 7);
        displayDataEnd = oldEnd.copyWith(day: oldEnd.day + directionalStep * 7);
        break;
      case TimeStep.month:
        displayDataStart = oldStart.copyWith(month: oldStart.month + directionalStep);
        displayDataEnd = oldEnd.copyWith(month: oldEnd.month + directionalStep);
        break;
      case TimeStep.year:
        displayDataStart = oldStart.copyWith(year: oldStart.year + directionalStep);
        displayDataEnd = oldEnd.copyWith(year: oldEnd.year + directionalStep);
        break;
      case TimeStep.lifetime:
        displayDataStart = DateTime.fromMillisecondsSinceEpoch(0);
        displayDataEnd = DateTime.now();
        break;
      case TimeStep.last30Days:
        displayDataStart = oldStart.copyWith(day: oldStart.day + directionalStep * 30);
        displayDataEnd = oldEnd.copyWith(day: oldEnd.day + directionalStep * 30);
        break;
      case TimeStep.custom:
        final step = oldStart.difference(oldEnd) * directionalStep;
        displayDataStart = oldStart.add(step);
        displayDataEnd = oldEnd.add(step);
        break;
    }
  }

  @override
  List<DateTime> getMostRecentDisplayIntervall() {
    final now = DateTime.now();
    switch (graphStepSize) {
      case TimeStep.day:
        final start = DateTime(now.year, now.month, now.day);
        return [start, start.copyWith(day: now.day + 1)];
      case TimeStep.week:
        final start = DateTime(now.year, now.month, now.day - (now.weekday - 1)); // monday
        return [start, start.copyWith(day: start.day + DateTime.sunday)]; // end of sunday
      case TimeStep.month:
        final start = DateTime(now.year, now.month);
        return [start, start.copyWith(month: now.month + 1)];
      case TimeStep.year:
        final start = DateTime(now.year);
        return [start, start.copyWith(year: now.year + 1)];
      case TimeStep.lifetime:
        final start = DateTime.fromMillisecondsSinceEpoch(0);
        return [start, now];
      case TimeStep.last7Days:
        final start = now.copyWith(day: now.day-7);
        return [start, now];
      case TimeStep.last30Days:
        final start = now.copyWith(day: now.day-30);
        return [start, now];
      case TimeStep.custom:
        return [DateTime.fromMillisecondsSinceEpoch(-1), DateTime.fromMillisecondsSinceEpoch(-1)]; // TODO
    }
  }
}

import 'dart:collection';

import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:blood_pressure_app/model/export_import.dart';
import 'package:blood_pressure_app/model/settings_store.dart';
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
  Future<int> get count async => _records.length;

  @override
  Future<int> get avgDia async => _records.map((e) => e.diastolic).reduce((a, b) => a + b) ~/ _records.length;

  @override
  Future<int> get avgPul async => _records.map((e) => e.pulse).reduce((a, b) => a + b) ~/ _records.length;

  @override
  Future<int> get avgSys async => _records.map((e) => e.systolic).reduce((a, b) => a + b) ~/ _records.length;

  @override
  Future<int> get maxDia async => _records.reduce((a, b) => (a.diastolic >= b.diastolic) ? a : b).diastolic;

  @override
  Future<int> get maxPul async => _records.reduce((a, b) => (a.pulse >= b.pulse) ? a : b).pulse;

  @override
  Future<int> get maxSys async => _records.reduce((a, b) => (a.systolic >= b.systolic) ? a : b).systolic;

  @override
  Future<int> get minDia async => _records.reduce((a, b) => (a.diastolic <= b.diastolic) ? a : b).diastolic;

  @override
  Future<int> get minPul async => _records.reduce((a, b) => (a.pulse <= b.pulse) ? a : b).pulse;

  @override
  Future<int> get minSys async => _records.reduce((a, b) => (a.systolic <= b.systolic) ? a : b).systolic;

  @override
  Future<DateTime> get firstDay async {
    _records.sort((a, b) => a.creationTime.compareTo(b.creationTime));
    return _records.first.creationTime;
  }

  @override
  Future<DateTime> get lastDay async {
    _records.sort((a, b) => a.creationTime.compareTo(b.creationTime));
    return _records.last.creationTime;
  }

  @override
  void close() {}
}

class RamSettings extends ChangeNotifier implements Settings {
  MaterialColor _accentColor = Colors.pink;
  int _age = 30;
  bool _allowManualTimeInput = true;
  int _animationSpeed = 150;
  bool _confirmDeletion = true;
  bool _darkMode = true;
  String _dateFormatString = 'yyyy-MM-dd  HH:mm';
  MaterialColor _diaColor = Colors.pink;
  double _diaWarn = 80;
  DateTime? _displayDataEnd;
  DateTime? _displayDataStart;
  bool _followSystemDarkMode = true;
  double _graphLineThickness = 3;
  int _graphStepSize = TimeStep.day;
  double _iconSize = 30;
  bool _overrideWarnValues = false;
  MaterialColor _pulColor = Colors.pink;
  MaterialColor _sysColor = Colors.pink;
  double _sysWarn = 120;
  bool _useExportCompatability = false;
  bool _validateInputs = true;
  int _graphTitlesCount = 5;
  ExportFormat _exportFormat = ExportFormat.csv;

  RamSettings() {
    _accentColor = createMaterialColor(0xFF009688);
    _diaColor = createMaterialColor(0xFF4CAF50);
    _pulColor = createMaterialColor(0xFFF44336);
    _sysColor = createMaterialColor(0xFF009688);
  }

  @override
  double get diaWarn {
    if (!overrideWarnValues) {
      return BloodPressureWarnValues.getUpperDiaWarnValue(age).toDouble();
    }
    return _diaWarn;
  }

  @override
  set diaWarn(double newWarn) {
    _diaWarn = newWarn;
    notifyListeners();
  }

  @override
  DateTime get displayDataStart {
    return _displayDataStart ?? getMostRecentDisplayIntervall()[0];
  }

  @override
  set displayDataStart(DateTime newGraphStart) {
    _displayDataStart = newGraphStart;
    notifyListeners();
  }

  @override
  DateTime get displayDataEnd {
    return _displayDataEnd ?? getMostRecentDisplayIntervall()[1];
  }

  @override
  set displayDataEnd(DateTime newGraphEnd) {
    _displayDataEnd = newGraphEnd;
    notifyListeners();
  }

  @override
  double get sysWarn {
    if (!overrideWarnValues) {
      return BloodPressureWarnValues.getUpperSysWarnValue(age).toDouble();
    }
    return _sysWarn;
  }

  @override
  set sysWarn(double newWarn) {
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
  int get age => _age;

  @override
  set age(int value) {
    _age = value;
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
  int get graphStepSize => _graphStepSize;

  @override
  set graphStepSize(int value) {
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
  bool get overrideWarnValues => _overrideWarnValues;

  @override
  set overrideWarnValues(bool value) {
    _overrideWarnValues = value;
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
  bool get useExportCompatability => _useExportCompatability;

  @override
  set useExportCompatability(bool value) {
    _useExportCompatability = value;
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

  @override
  void changeStepSize(int value) {
    graphStepSize = value;
    final newInterval = getMostRecentDisplayIntervall();
    displayDataStart = newInterval[0];
    displayDataEnd = newInterval[1];
  }

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
      default:
        assert(false);
        final start = DateTime.fromMillisecondsSinceEpoch(0);
        return [start, now];
    }
  }
}

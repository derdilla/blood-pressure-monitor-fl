import 'dart:collection';

import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:blood_pressure_app/model/export_import.dart';
import 'package:blood_pressure_app/model/export_options.dart';
import 'package:blood_pressure_app/model/settings_store.dart';
import 'package:file_saver/file_saver.dart' show MimeType;
import 'package:flutter/material.dart';

import 'horizontal_graph_line.dart';

class RamBloodPressureModel extends ChangeNotifier implements BloodPressureModel {
  final List<BloodPressureRecord> _records = [];
  
  static RamBloodPressureModel fromEntries(List<BloodPressureRecord> records) {
    final m = RamBloodPressureModel();
    for (var e in records) {
      m.add(e);
    }
    return m;
  }

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
  MaterialColor _pulColor = Colors.pink;
  MaterialColor _sysColor = Colors.pink;
  int _sysWarn = 120;
  bool _useExportCompatability = false;
  bool _validateInputs = true;
  int _graphTitlesCount = 5;
  ExportFormat _exportFormat = ExportFormat.csv;
  String _csvFieldDelimiter = ',';
  String _csvTextDelimiter = '"';
  bool _exportCsvHeadline = true;
  bool _exportCustomEntries = false;
  List<String> _exportItems = ['timestampUnixMs', 'systolic', 'diastolic', 'pulse', 'notes'];
  MimeType _exportMimeType = MimeType.csv;
  String _defaultExportDir = '';
  bool _exportAfterEveryEntry = false;
  bool _allowMissingValues = false;
  Locale? _language;
  bool _drawRegressionLines = false;

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
  bool get exportCsvHeadline => _exportCsvHeadline;

  @override
  set exportCsvHeadline(bool value) {
    _exportCsvHeadline = value;
    notifyListeners();
  }

  @override
  bool get exportCustomEntriesCsv => _exportCustomEntries;

  @override
  set exportCustomEntriesCsv(bool value) {
    _exportCustomEntries = value;
    notifyListeners();
  }

  @override
  List<String> get exportItemsCsv => _exportItems;

  @override
  set exportItemsCsv(List<String> value) {
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
  bool get drawRegressionLines => _drawRegressionLines;

  @override
  set drawRegressionLines(bool value) {
    _drawRegressionLines = value;
    notifyListeners();
  }

  double _exportPdfHeaderHeight = 20;
  @override
  double get exportPdfHeaderHeight {
    return _exportPdfHeaderHeight;
  }
  @override
  set exportPdfHeaderHeight(double value) {
    _exportPdfHeaderHeight = value;
    notifyListeners();
  }

  double _exportPdfCellHeight = 15;
  @override
  double get exportPdfCellHeight {
    return _exportPdfCellHeight;
  }
  @override
  set exportPdfCellHeight(double value) {
    _exportPdfCellHeight = value;
    notifyListeners();
  }

  double _exportPdfHeaderFontSize = 10;

  @override
  double get exportPdfHeaderFontSize {
    return _exportPdfHeaderFontSize;
  }

  @override
  set exportPdfHeaderFontSize(double value) {
    _exportPdfHeaderFontSize = value;
    notifyListeners();
  }

  double _exportPdfCellFontSize = 8;

  @override
  double get exportPdfCellFontSize {
    return _exportPdfCellFontSize;
  }

  @override
  set exportPdfCellFontSize(double value) {
    _exportPdfCellFontSize = value;
    notifyListeners();
  }

  bool _exportPdfExportTitle = true;

  @override
  bool get exportPdfExportTitle {
    return _exportPdfExportTitle;
  }

  @override
  set exportPdfExportTitle(bool value) {
    _exportPdfExportTitle = value;
    notifyListeners();
  }

  bool _exportPdfExportStatistics = false;

  @override
  bool get exportPdfExportStatistics {
    return _exportPdfExportStatistics;
  }

  @override
  set exportPdfExportStatistics(bool value) {
    _exportPdfExportStatistics = value;
    notifyListeners();
  }

  bool _exportPdfExportData = true;

  @override
  bool get exportPdfExportData {
    return _exportPdfExportData;
  }

  @override
  set exportPdfExportData(bool value) {
    _exportPdfExportData = value;
    notifyListeners();
  }

  bool _startWithAddMeasurementPage = false;

  @override
  bool get startWithAddMeasurementPage {
    return _startWithAddMeasurementPage;
  }

  @override
  set startWithAddMeasurementPage(bool value) {
    _startWithAddMeasurementPage = value;
    notifyListeners();
  }

  bool _exportCustomEntriesPdf = false;

  @override
  bool get exportCustomEntriesPdf {
    return _exportCustomEntriesPdf;
  }

  @override
  set exportCustomEntriesPdf(bool value) {
    _exportCustomEntriesPdf = value;
    notifyListeners();
  }

  List<String> _exportItemsPdf = ExportFields.defaultPdf;

  @override
  List<String> get exportItemsPdf {
    return _exportItemsPdf;
  }

  @override
  set exportItemsPdf(List<String> value) {
    _exportItemsPdf = value;
    notifyListeners();
  }

  Iterable<HorizontalGraphLine> _horizontalGraphLines = [];

  @override
  Iterable<HorizontalGraphLine> get horizontalGraphLines {
    return _horizontalGraphLines;
  }

  @override
  set horizontalGraphLines(Iterable<HorizontalGraphLine> value) {
    _horizontalGraphLines = value;
    notifyListeners();
  }

  bool _useLegacyList = false;

  @override
  bool get useLegacyList {
    return _useLegacyList;
  }

  @override
  set useLegacyList(bool value) {
    _useLegacyList = value;
    notifyListeners();
  }

  @override
  void changeStepSize(TimeStep value) {
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
        displayDataStart = DateTime.fromMillisecondsSinceEpoch(1);
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
        final start = DateTime.fromMillisecondsSinceEpoch(1);
        return [start, now];
      case TimeStep.last7Days:
        final start = now.copyWith(day: now.day-7);
        return [start, now];
      case TimeStep.last30Days:
        final start = now.copyWith(day: now.day-30);
        return [start, now];
      case TimeStep.custom:
        // fallback, TimeStep will be reset by getter
        return [DateTime.fromMillisecondsSinceEpoch(-1), DateTime.fromMillisecondsSinceEpoch(-1)];
    }
  }
}

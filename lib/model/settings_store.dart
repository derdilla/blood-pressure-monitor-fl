import 'dart:convert';

import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:blood_pressure_app/model/export_import.dart';
import 'package:blood_pressure_app/model/export_options.dart';
import 'package:blood_pressure_app/model/horizontal_graph_line.dart';
import 'package:file_saver/file_saver.dart' show MimeType;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends ChangeNotifier {
  late final SharedPreferences _prefs;
  final PackageInfo _packageInfo;

  DateTime? _displayDataStart;
  DateTime? _displayDataEnd;
  
  Settings._create(this._packageInfo);
  // factory method, to allow for async constructor
  static Future<Settings> create([PackageInfo? packageInfo]) async {
    final component = Settings._create(packageInfo ?? (await PackageInfo.fromPlatform()));
    component._prefs = await SharedPreferences.getInstance();
    await component._update();
    return component;
  }

  Future<void> _update() async {
    final keys = _prefs.getKeys();
    List<Future> toAwait = [];

    // delete old keys
    if (keys.contains('age')) {
      final lastAge = _prefs.getInt('age') ?? 30;
      sysWarn = BloodPressureWarnValues.getUpperSysWarnValue(lastAge);
      diaWarn = BloodPressureWarnValues.getUpperDiaWarnValue(lastAge);
      toAwait.add(_prefs.remove('age'));
    }
    if (keys.contains('overrideWarnValues')) {
      toAwait.add(_prefs.remove('overrideWarnValues'));
    }
    if (keys.contains('exportLimitDataRange')) {
      toAwait.add(_prefs.remove('exportLimitDataRange'));
    }
    if (keys.contains('exportDataRangeStartEpochMs')) {
      toAwait.add(_prefs.remove('exportDataRangeStartEpochMs'));
    }
    if (keys.contains('exportDataRangeEndEpochMs')) {
      toAwait.add(_prefs.remove('exportDataRangeEndEpochMs'));
    }
    if (keys.contains('exportAddableItems')) {
      toAwait.add(_prefs.remove('exportAddableItems'));
    }
    if (keys.contains('exportCustomEntries')) {
      await _prefs.setBool('exportCustomEntriesCsv', _prefs.getBool('exportCustomEntries') ?? false);
      toAwait.add(_prefs.remove('exportCustomEntries'));
    }
    if (keys.contains('exportItems')) {
      await _prefs.setStringList('exportItemsCsv', _prefs.getStringList('exportItems') ?? ExportFields.defaultCsv);
      toAwait.add(_prefs.remove('exportItems'));
    }

    // reset variables for new version. Necessary for reusing variable names in new version and avoid having unexpected
    // breaking values in the preferences
    switch (_prefs.getInt('lastAppVersion')) {
      case null:
        toAwait.add(_prefs.remove('exportCsvHeadline'));
        toAwait.add(_prefs.remove('exportCustomEntries'));
        toAwait.add(_prefs.remove('exportItems'));
        toAwait.add(_prefs.remove('exportMimeType'));
    }

    for (var e in toAwait) {
      await e;
    }
    await _prefs.setInt('lastAppVersion', int.parse(_packageInfo.buildNumber));
    return;
  }

  TimeStep get graphStepSize {
    int stepInt = _prefs.getInt('graphStepSize') ?? 0;
    switch (stepInt) {
      case 0:
        return TimeStep.day;
      case 1:
        return TimeStep.month;
      case 2:
        return TimeStep.year;
      case 3:
        return TimeStep.lifetime;
      case 4:
        return TimeStep.week;
      case 5:
        return TimeStep.last7Days;
      case 6:
        return TimeStep.last30Days;
      case 7:
        return TimeStep.custom;
    }
    assert(false);
    return TimeStep.day;
  }

  set graphStepSize(TimeStep newStepSize) {
    _prefs.setInt('graphStepSize', ((){
      switch (newStepSize) {
        case TimeStep.day:
          return 0;
        case TimeStep.month:
          return 1;
        case TimeStep.year:
          return 2;
        case TimeStep.lifetime:
          return 3;
        case TimeStep.week:
          return 4;
        case TimeStep.last7Days:
          return 5;
        case TimeStep.last30Days:
          return 6;
        case TimeStep.custom:
          return 7;
      }
    })());


    notifyListeners();
  }

  void changeStepSize(TimeStep value) {
    graphStepSize = value;
    final newInterval = getMostRecentDisplayIntervall();
    displayDataStart = newInterval[0];
    displayDataEnd = newInterval[1];
  }

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
        final step = oldEnd.difference(oldStart) * directionalStep;
        displayDataStart = oldStart.add(step);
        displayDataEnd = oldEnd.add(step);
        break;
    }
  }

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

  DateTime get displayDataStart {
    final s = _displayDataStart ?? getMostRecentDisplayIntervall()[0];
    if(s.millisecondsSinceEpoch < 1) {
      changeStepSize(TimeStep.last7Days);
    }
    return s;
  }

  set displayDataStart(DateTime newGraphStart) {
    _displayDataStart = newGraphStart;
    notifyListeners();
  }

  DateTime get displayDataEnd {
    final s = _displayDataEnd ?? getMostRecentDisplayIntervall()[1];
    if(s.millisecondsSinceEpoch < 1) {
      changeStepSize(TimeStep.last7Days);
    }
    return s;
  }

  set displayDataEnd(DateTime newGraphEnd) {
    _displayDataEnd = newGraphEnd;
    notifyListeners();
  }

  bool get followSystemDarkMode {
    return _prefs.getBool('followSystemDarkMode') ?? true;
  }

  set followSystemDarkMode(bool newSetting) {
    _prefs.setBool('followSystemDarkMode', newSetting);
    notifyListeners();
  }

  bool get darkMode {
    return _prefs.getBool('darkMode') ?? true;
  }

  set darkMode(bool newSetting) {
    _prefs.setBool('darkMode', newSetting);
    notifyListeners();
  }

  MaterialColor get accentColor {
    return createMaterialColor(_prefs.getInt('accentColor') ?? 0xFF009688);
  }

  set accentColor(MaterialColor newColor) {
    _prefs.setInt('accentColor', newColor.value);
    notifyListeners();
  }

  MaterialColor get diaColor {
    return createMaterialColor(_prefs.getInt('diaColor') ?? 0xFF4CAF50);
  }

  set diaColor(MaterialColor newColor) {
    _prefs.setInt('diaColor', newColor.value);
    notifyListeners();
  }

  MaterialColor get sysColor {
    return createMaterialColor(_prefs.getInt('sysColor') ?? 0xFF009688);
  }

  set sysColor(MaterialColor newColor) {
    _prefs.setInt('sysColor', newColor.value);
    notifyListeners();
  }

  MaterialColor get pulColor {
    return createMaterialColor(_prefs.getInt('pulColor') ?? 0xFFF44336);
  }

  set pulColor(MaterialColor newColor) {
    _prefs.setInt('pulColor', newColor.value);
    notifyListeners();
  }

  bool get allowManualTimeInput {
    return _prefs.getBool('allowManualTimeInput') ?? true;
  }

  set allowManualTimeInput(bool newSetting) {
    _prefs.setBool('allowManualTimeInput', newSetting);
    notifyListeners();
  }

  String get dateFormatString {
    return _prefs.getString('dateFormatString') ?? 'yyyy-MM-dd  HH:mm';
  }

  set dateFormatString(String newFormatString) {
    _prefs.setString('dateFormatString', newFormatString);
    notifyListeners();
  }

  double get iconSize {
    return _prefs.getInt('iconSize')?.toDouble() ?? 30;
  }

  set iconSize(double newSize) {
    _prefs.setInt('iconSize', newSize.toInt());
    notifyListeners();
  }

  int get sysWarn {
    return _prefs.getInt('sysWarn') ?? 120;
  }

  set sysWarn(int newWarn) {
    _prefs.setInt('sysWarn', newWarn);
    notifyListeners();
  }

  int get diaWarn {
    return _prefs.getInt('diaWarn') ?? 80;
  }

  set diaWarn(int newWarn) {
    _prefs.setInt('diaWarn', newWarn);
    notifyListeners();
  }

  bool get validateInputs {
    return _prefs.getBool('validateInputs') ?? true;
  }

  set validateInputs(bool validateInputs) {
    _prefs.setBool('validateInputs', validateInputs);
    notifyListeners();
  }

  bool get allowMissingValues {
    return _prefs.getBool('allowMissingValues') ?? false;
  }

  set allowMissingValues(bool allowMissingValues) {
    _prefs.setBool('allowMissingValues', allowMissingValues);
    notifyListeners();
  }

  double get graphLineThickness {
    return _prefs.getDouble('graphLineThickness') ?? 3;
  }

  set graphLineThickness(double newThickness) {
    _prefs.setDouble('graphLineThickness', newThickness);
    notifyListeners();
  }

  int get animationSpeed {
    return _prefs.getInt('animationSpeed') ?? 150;
  }

  set animationSpeed(int newSpeed) {
    _prefs.setInt('animationSpeed', newSpeed);
    notifyListeners();
  }

  bool get confirmDeletion {
    return _prefs.getBool('confirmDeletion') ?? true;
  }

  set confirmDeletion(bool confirmDeletion) {
    _prefs.setBool('confirmDeletion', confirmDeletion);
    notifyListeners();
  }

  int get graphTitlesCount {
    return _prefs.getInt('titlesCount') ?? 5;
  }

  set graphTitlesCount(int newCount) {
    _prefs.setInt('titlesCount', newCount);
    notifyListeners();
  }

  ExportFormat get exportFormat {
    switch (_prefs.getInt('exportFormat') ?? 0) {
      case 0:
        return ExportFormat.csv;
      case 1:
        return ExportFormat.pdf;
      case 2:
        return ExportFormat.db;
      default:
        assert(false);
        return ExportFormat.csv;
    }
  }
  
  set exportFormat(ExportFormat format) {
    switch (format) {
      case ExportFormat.csv:
        _prefs.setInt('exportFormat', 0);
        break;
      case ExportFormat.pdf:
        _prefs.setInt('exportFormat', 1);
        break;
      case ExportFormat.db:
        _prefs.setInt('exportFormat', 2);
        break;
      default:
        assert(false);
    }
    notifyListeners();
  }
  
  String get csvFieldDelimiter {
    return _prefs.getString('csvFieldDelimiter') ?? ',';
  }
  
  set csvFieldDelimiter(String value) {
    _prefs.setString('csvFieldDelimiter', value);
    notifyListeners();
  }

  String get csvTextDelimiter {
    return _prefs.getString('csvTextDelimiter') ?? '"';
  }

  set csvTextDelimiter(String value) {
    _prefs.setString('csvTextDelimiter', value);
    notifyListeners();
  }

  MimeType get exportMimeType {
    switch (_prefs.getInt('exportMimeType') ?? 0) {
      case 0:
        return MimeType.csv;
      case 1:
        return MimeType.text;
      case 2:
        return MimeType.pdf;
      case 3:
        return MimeType.other;
      default:
        throw UnimplementedError();
    }
  }
  set exportMimeType(MimeType value) {
    switch (value) {
      case MimeType.csv:
        _prefs.setInt('exportMimeType', 0);
        break;
      case MimeType.text:
        _prefs.setInt('exportMimeType', 1);
        break;
      case MimeType.pdf:
        _prefs.setInt('exportMimeType', 2);
        break;
      case MimeType.other:
        _prefs.setInt('exportMimeType', 3);
        break;
      default:
        throw UnimplementedError();
    }
    notifyListeners();
  }

  bool get exportCustomEntriesCsv {
    return _prefs.getBool('exportCustomEntriesCsv') ?? false;
  }

  set exportCustomEntriesCsv(bool value) {
    _prefs.setBool('exportCustomEntriesCsv', value);
    notifyListeners();
  }

  List<String> get exportItemsCsv {
    return _prefs.getStringList('exportItemsCsv') ?? ExportFields.defaultCsv;
  }

  set exportItemsCsv(List<String> value) {
    _prefs.setStringList('exportItemsCsv', value);
    notifyListeners();
  }

  bool get exportCsvHeadline {
    return _prefs.getBool('exportCsvHeadline') ?? true;
  }

  set exportCsvHeadline(bool value) {
    _prefs.setBool('exportCsvHeadline', value);
    notifyListeners();
  }

  String get defaultExportDir {
    return _prefs.getString('defaultExportDir') ?? '';
  }
  set defaultExportDir (String value) {
    _prefs.setString('defaultExportDir', value);
    notifyListeners();
  }

  bool get exportAfterEveryEntry {
    return _prefs.getBool('exportAfterEveryEntry') ?? false;
  }

  set exportAfterEveryEntry(bool value) {
    _prefs.setBool('exportAfterEveryEntry', value);
    notifyListeners();
  }

  Locale? get language {
    final value = _prefs.getString('language');
    if (value?.isEmpty ?? true) return null;
    return Locale(value ?? 'en');
  }

  set language (Locale? value) {
    _prefs.setString('language', value?.languageCode ?? '');
    notifyListeners();
  }

  bool get drawRegressionLines {
    return _prefs.getBool('drawRegressionLines') ?? false;
  }

  set drawRegressionLines(bool value) {
    _prefs.setBool('drawRegressionLines', value);
    notifyListeners();
  }

  double get exportPdfHeaderHeight {
    return _prefs.getDouble('exportPdfHeaderHeight') ?? 20;
  }

  set exportPdfHeaderHeight(double value) {
    _prefs.setDouble('exportPdfHeaderHeight', value);
    notifyListeners();
  }
  double get exportPdfCellHeight {
    return _prefs.getDouble('exportPdfCellHeight') ?? 15;
  }

  set exportPdfCellHeight(double value) {
    _prefs.setDouble('exportPdfCellHeight', value);
    notifyListeners();
  }

  double get exportPdfHeaderFontSize {
    return _prefs.getDouble('exportPdfHeaderFontSize') ?? 10;
  }

  set exportPdfHeaderFontSize(double value) {
    _prefs.setDouble('exportPdfHeaderFontSize', value);
    notifyListeners();
  }

  double get exportPdfCellFontSize {
    return _prefs.getDouble('exportPdfCellFontSize') ?? 8;
  }

  set exportPdfCellFontSize(double value) {
    _prefs.setDouble('exportPdfCellFontSize', value);
    notifyListeners();
  }

  bool get exportPdfExportTitle {
    return _prefs.getBool('exportPdfExportTitle') ?? true;
  }

  set exportPdfExportTitle(bool value) {
    _prefs.setBool('exportPdfExportTitle', value);
    notifyListeners();
  }

  bool get exportPdfExportStatistics {
    return _prefs.getBool('exportPdfExportStatistics') ?? false;
  }

  set exportPdfExportStatistics(bool value) {
    _prefs.setBool('exportPdfExportStatistics', value);
    notifyListeners();
  }

  /// whether to add a section with all entries to pdf export
  bool get exportPdfExportData {
    return _prefs.getBool('exportPdfExportData') ?? true;
  }

  set exportPdfExportData(bool value) {
    _prefs.setBool('exportPdfExportData', value);
    notifyListeners();
  }

  bool get startWithAddMeasurementPage {
    return _prefs.getBool('startWithAddMeasurementPage') ?? false;
  }

  set startWithAddMeasurementPage(bool value) {
    _prefs.setBool('startWithAddMeasurementPage', value);
    notifyListeners();
  }

  bool get exportCustomEntriesPdf {
    return _prefs.getBool('exportCustomEntriesPdf') ?? false;
  }

  set exportCustomEntriesPdf(bool value) {
    _prefs.setBool('exportCustomEntriesPdf', value);
    notifyListeners();
  }

  List<String> get exportItemsPdf {
    return _prefs.getStringList('exportItemsPdf') ?? ExportFields.defaultPdf;
  }

  set exportItemsPdf(List<String> value) {
    _prefs.setStringList('exportItemsPdf', value);
    notifyListeners();
  }

  Iterable<HorizontalGraphLine> get horizontalGraphLines {
    final linesStr = _prefs.getStringList('horizontalGraphLines') ?? [];
    return linesStr.map((e) => HorizontalGraphLine.fromJson(jsonDecode(e)));
  }

  set horizontalGraphLines(Iterable<HorizontalGraphLine> value) {
    _prefs.setStringList('horizontalGraphLines', value.map((e) => jsonEncode(e)).toList());
    notifyListeners();
  }
}

enum TimeStep {
  day,
  month,
  year,
  lifetime,
  week,
  last7Days,
  last30Days,
  custom;

  static const options = [TimeStep.day, TimeStep.week, TimeStep.month, TimeStep.year, TimeStep.lifetime, TimeStep.last7Days, TimeStep.last30Days, TimeStep.custom];

  static String getName(TimeStep opt, BuildContext context) {
    switch (opt) {
      case TimeStep.day:
        return AppLocalizations.of(context)!.day;
      case TimeStep.month:
        return AppLocalizations.of(context)!.month;
      case TimeStep.year:
        return AppLocalizations.of(context)!.year;
      case TimeStep.lifetime:
        return AppLocalizations.of(context)!.lifetime;
      case TimeStep.week:
        return AppLocalizations.of(context)!.week;
      case TimeStep.last7Days:
        return AppLocalizations.of(context)!.last7Days;
      case TimeStep.last30Days:
        return AppLocalizations.of(context)!.last30Days;
      case TimeStep.custom:
        return AppLocalizations.of(context)!.custom;
    }
  }
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

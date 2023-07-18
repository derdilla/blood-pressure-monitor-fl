import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:blood_pressure_app/model/export_import.dart';
import 'package:file_saver/file_saver.dart' show MimeType;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends ChangeNotifier {
  late final SharedPreferences _prefs;

  DateTime? _displayDataStart;
  DateTime? _displayDataEnd;
  
  Settings._create();
  // factory method, to allow for async constructor
  static Future<Settings> create() async {
    final component = Settings._create();
    component._prefs = await SharedPreferences.getInstance();
    await component._update();
    return component;
  }

  Future<void> _update() async {
    final keys = _prefs.getKeys();
    List<Future> toAwait = [];

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

    for (var e in toAwait) {
      await e;
    }
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
    }
    assert(false);
    return TimeStep.day;
  }

  set graphStepSize(TimeStep newStepSize) {
    switch (newStepSize) {
      case TimeStep.day:
        _prefs.setInt('graphStepSize', 0);
        break;
      case TimeStep.month:
        _prefs.setInt('graphStepSize', 1);
        break;
      case TimeStep.year:
        _prefs.setInt('graphStepSize', 2);
        break;
      case TimeStep.lifetime:
        _prefs.setInt('graphStepSize', 3);
        break;
      case TimeStep.week:
        _prefs.setInt('graphStepSize', 4);
        break;
      case TimeStep.last7Days:
        _prefs.setInt('graphStepSize', 5);
        break;
      case TimeStep.last30Days:
        _prefs.setInt('graphStepSize', 6);
        break;
      default:
        assert(false);
    }
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
        displayDataStart = DateTime.fromMillisecondsSinceEpoch(0);
        displayDataEnd = DateTime.now();
        break;
      case TimeStep.last30Days:
        displayDataStart = oldStart.copyWith(day: oldStart.day + directionalStep * 30);
        displayDataEnd = oldEnd.copyWith(day: oldEnd.day + directionalStep * 30);
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
        final start = DateTime.fromMillisecondsSinceEpoch(0);
        return [start, now];
      case TimeStep.last7Days:
        final start = now.copyWith(day: now.day-7);
        return [start, now];
      case TimeStep.last30Days:
        final start = now.copyWith(day: now.day-30);
        return [start, now];
      default:
        assert(false);
        final start = DateTime.fromMillisecondsSinceEpoch(0);
        return [start, now];
    }
  }

  DateTime get displayDataStart {
    return _displayDataStart ?? getMostRecentDisplayIntervall()[0];
  }

  set displayDataStart(DateTime newGraphStart) {
    _displayDataStart = newGraphStart;
    notifyListeners();
  }

  DateTime get displayDataEnd {
    return _displayDataEnd ?? getMostRecentDisplayIntervall()[1];
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

  bool get exportCustomEntries {
    return _prefs.getBool('exportCustomEntries') ?? false;
  }

  set exportCustomEntries(bool value) {
    _prefs.setBool('exportCustomEntries', value);
    notifyListeners();
  }
  
  List<String> get exportAddableItems {
    return _prefs.getStringList('exportAddableItems') ?? ['isoUTCTime'];
  }

  set exportAddableItems(List<String> value) {
    _prefs.setStringList('exportAddableItems', value);
    notifyListeners();
  }
  List<String> get exportItems {
    return _prefs.getStringList('exportItems') ?? ['timestampUnixMs', 'systolic', 'diastolic', 'pulse', 'notes'];
  }

  set exportItems(List<String> value) {
    _prefs.setStringList('exportItems', value);
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
}

enum TimeStep {
  day,
  month,
  year,
  lifetime,
  week,
  last7Days,
  last30Days;

  static const options = [TimeStep.day, TimeStep.week, TimeStep.month, TimeStep.year, TimeStep.lifetime, TimeStep.last7Days, TimeStep.last30Days];

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

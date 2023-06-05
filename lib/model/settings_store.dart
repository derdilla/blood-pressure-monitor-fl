import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:flutter/material.dart';
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
    return component;
  }

  int get graphStepSize {
    return _prefs.getInt('graphStepSize') ?? TimeStep.day;
  }
  set graphStepSize(int newStepSize) {
    _prefs.setInt('graphStepSize', newStepSize);
    notifyListeners();
  }

  void changeStepSize(int value) {
    graphStepSize = value;
    final newInterval = getMostRecentDisplayIntervall();
    displayDataStart = newInterval[0];
    displayDataEnd = newInterval[1];
  }

  void moveDisplayDataByStep(int directionalStep) {
    final oldStart = displayDataStart;
    final oldEnd =displayDataEnd;
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
        return [start,  start.copyWith(month: now.month + 1)];
      case TimeStep.year:
        final start = DateTime(now.year);
        return [start,  start.copyWith(year: now.year + 1)];
      case TimeStep.lifetime:
        final start = DateTime.fromMillisecondsSinceEpoch(0);
        return [start,  now];
      default:
        assert(false);
        final start = DateTime.fromMillisecondsSinceEpoch(0);
        return [start,  now];
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
  bool get useExportCompatability {
    return _prefs.getBool('useExportCompatability') ?? false;
  }
  set useExportCompatability(bool useExportCompatability) {
    _prefs.setBool('useExportCompatability', useExportCompatability);
    notifyListeners();
  }
  double get iconSize {
    return _prefs.getInt('iconSize')?.toDouble() ?? 30;
  }
  set iconSize(double newSize) {
    _prefs.setInt('iconSize', newSize.toInt());
    notifyListeners();
  }

  double get sysWarn {
    if (!overrideWarnValues) {
      return BloodPressureWarnValues.getUpperSysWarnValue(age).toDouble();
    }
    return _prefs.getInt('sysWarn')?.toDouble() ?? 120;
  }
  set sysWarn(double newWarn) {
    _prefs.setInt('sysWarn', newWarn.toInt());
    notifyListeners();
  }

  double get diaWarn {
    if (!overrideWarnValues) {
      return BloodPressureWarnValues.getUpperDiaWarnValue(age).toDouble();
    }
    return _prefs.getInt('diaWarn')?.toDouble() ?? 80;
  }
  set diaWarn(double newWarn) {
    _prefs.setInt('diaWarn', newWarn.toInt());
    notifyListeners();
  }

  int get age {
    return _prefs.getInt('age') ?? 30;
  }
  set age(int newAge) {
    _prefs.setInt('age', newAge.toInt());
    notifyListeners();
  }

  bool get overrideWarnValues {
    return _prefs.getBool('overrideWarnValues') ?? false;
  }
  set overrideWarnValues(bool overrideWarnValues) {
    _prefs.setBool('overrideWarnValues', overrideWarnValues);
    notifyListeners();
  }

  bool get validateInputs {
    return _prefs.getBool('validateInputs') ?? true;
  }
  set validateInputs(bool validateInputs) {
    _prefs.setBool('validateInputs', validateInputs);
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
}

class TimeStep {
  static const options = [0, 4, 1, 2, 3];

  static const day = 0;
  static const month = 1;
  static const year = 2;
  static const lifetime = 3;
  static const week = 4;

  TimeStep._create();

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
      case week:
        return 'week';
    }
    return 'invalid';
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
import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends ChangeNotifier {
  late final SharedPreferences _prefs;

  Settings._create();
  // factory method, to allow for async constructor
  static Future<Settings> create() async {
    final component = Settings._create();
    component._prefs = await SharedPreferences.getInstance();
    return component;
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
    return _prefs.getInt('graphStepSize') ?? TimeStep.day;
  }
  set graphStepSize(int newStepSize) {
    _prefs.setInt('graphStepSize', newStepSize);
    notifyListeners();
  }

  DateTime get displayDataStart {
    return DateTime.fromMillisecondsSinceEpoch(_prefs.getInt('graphStart') ?? -1);
  }
  set displayDataStart(DateTime newGraphStart) {
    _prefs.setInt('graphStart', newGraphStart.millisecondsSinceEpoch);
    notifyListeners();
  }

  DateTime get displayDataEnd {
    return DateTime.fromMillisecondsSinceEpoch(_prefs.getInt('graphEnd') ?? -1);
  }
  set displayDataEnd(DateTime newGraphEnd) {
    _prefs.setInt('graphEnd', newGraphEnd.millisecondsSinceEpoch);
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
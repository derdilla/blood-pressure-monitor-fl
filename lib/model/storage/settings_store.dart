import 'dart:convert';

import 'package:flutter/material.dart';

/// Stores settings that are directly controllable by the user through the Settings screen.
///
/// This class should not be used to save persistent state that the user doesn't know about. To do this use one of the
/// other classes in the storage directory or add a table to config_db and create your own class.
///
/// Steps for expanding this class:
/// - [ ] Add private variable with default value
/// - [ ] Add getter and setter, where setter calls `notifyListeners()`
/// - [ ] Add as nullable to constructor definition and if != null assign it to the private variable in the body
/// - [ ] Add parsable representation (string, boolean or integer) to the .toMap
/// - [ ] Parse it in the .fromMap factory method
/// - [ ] Make sure edge cases are handled in .fromMap (does not exist (update), not parsable (user))
class Settings extends ChangeNotifier {
  /// Creates a settings object with the default values.
  ///
  /// When the values should be set consider using the factory methods.
  Settings({
    Locale? language,
    MaterialColor? accentColor,
    MaterialColor? sysColor,
    MaterialColor? diaColor,
    MaterialColor? pulColor,
    String? dateFormatString,
    double? graphLineThickness,
    int? animationSpeed,
    int? sysWarn,
    int? diaWarn,
    bool? allowManualTimeInput,
    bool? confirmDeletion,
    bool? darkMode,
    bool? followSystemDarkMode,
    bool? validateInputs,
    bool? allowMissingValues,
    bool? drawRegressionLines,
    bool? startWithAddMeasurementPage,
    bool? useLegacyList,
  }) {
    if (accentColor != null) _accentColor = accentColor;
    if (sysColor != null) _sysColor = sysColor;
    if (diaColor != null) _diaColor = diaColor;
    if (pulColor != null) _pulColor = pulColor;
    if (allowManualTimeInput != null) _allowManualTimeInput = allowManualTimeInput;
    if (confirmDeletion != null) _confirmDeletion = confirmDeletion;
    if (darkMode != null) _darkMode = darkMode;
    if (dateFormatString != null) _dateFormatString = dateFormatString;
    if (animationSpeed != null) _animationSpeed = animationSpeed;
    if (sysWarn != null) _sysWarn = sysWarn;
    if (diaWarn != null) _diaWarn = diaWarn;
    if (graphLineThickness != null) _graphLineThickness = graphLineThickness;
    if (followSystemDarkMode != null) _followSystemDarkMode = followSystemDarkMode;
    if (validateInputs != null) _validateInputs = validateInputs;
    if (allowMissingValues != null) _allowMissingValues = allowMissingValues;
    if (drawRegressionLines != null) _drawRegressionLines = drawRegressionLines;
    if (startWithAddMeasurementPage != null) _startWithAddMeasurementPage = startWithAddMeasurementPage;
    if (useLegacyList != null) _useLegacyList = useLegacyList;
    _language = language; // No check here, as null is the default as well. In general values should not be null
  }

  factory Settings.fromMap(Map<String, dynamic> map) => Settings(
    accentColor: _parseMaterialColor(map['accentColor']),
    sysColor: _parseMaterialColor(map['sysColor']),
    diaColor: _parseMaterialColor(map['diaColor']),
    pulColor: _parseMaterialColor(map['pulColor']),
    allowManualTimeInput: _parseBool(map['allowManualTimeInput']),
    confirmDeletion: _parseBool(map['confirmDeletion']),
    darkMode: _parseBool(map['darkMode']),
    dateFormatString: _parseString(map['dateFormatString']),
    animationSpeed: _parseInt(map['animationSpeed']),
    sysWarn: _parseInt(map['sysWarn']),
    diaWarn: _parseInt(map['diaWarn']),
    graphLineThickness: _parseDouble(map['graphLineThickness']),
    followSystemDarkMode: _parseBool(map['followSystemDarkMode']),
    validateInputs: _parseBool(map['validateInputs']),
    allowMissingValues: _parseBool(map['allowMissingValues']),
    drawRegressionLines: _parseBool(map['drawRegressionLines']),
    startWithAddMeasurementPage: _parseBool(map['startWithAddMeasurementPage']),
    useLegacyList: _parseBool(map['useLegacyList']),
    language: _parseLocale(map['language'])
  );
      
  factory Settings.fromJson(String json) => Settings.fromMap(jsonDecode(json));

  Map<String, dynamic> toMap() => <String, dynamic>{
      'accentColor': accentColor.value,
      'sysColor': sysColor.value,
      'diaColor': diaColor.value,
      'pulColor': pulColor.value,
      'dateFormatString': dateFormatString,
      'graphLineThickness': graphLineThickness,
      'animationSpeed': animationSpeed,
      'sysWarn': sysWarn,
      'diaWarn': diaWarn,
      'allowManualTimeInput': allowManualTimeInput,
      'confirmDeletion': confirmDeletion,
      'darkMode': darkMode,
      'followSystemDarkMode': followSystemDarkMode,
      'allowMissingValues': allowMissingValues,
      'drawRegressionLines': drawRegressionLines,
      'startWithAddMeasurementPage': startWithAddMeasurementPage,
      'useLegacyList': useLegacyList,
      'language': _serializeLocale(language),
    };

  String toJson() => jsonEncode(toMap());

  Locale? _language; // default null
  /// When the value is null, 
  Locale? get language => _language;
  set language(Locale? value) {
    _language = value;
    notifyListeners();
  }

  MaterialColor _accentColor = Colors.teal;
  MaterialColor get accentColor => _accentColor;
  set accentColor(MaterialColor newColor) {
    _accentColor = newColor;
    notifyListeners();
  }

  MaterialColor _sysColor = Colors.teal;
  MaterialColor get sysColor => _sysColor;
  set sysColor(MaterialColor newColor) {
    _sysColor = newColor;
    notifyListeners();
  }

  MaterialColor _diaColor = Colors.green;
  MaterialColor get diaColor => _diaColor;
  set diaColor(MaterialColor newColor) {
    _diaColor = newColor;
    notifyListeners();
  }

  MaterialColor _pulColor = Colors.red;
  MaterialColor get pulColor => _pulColor;
  set pulColor(MaterialColor newColor) {
    _pulColor = newColor;
    notifyListeners();
  }

  String _dateFormatString = 'yyyy-MM-dd  HH:mm';
  String get dateFormatString => _dateFormatString;
  set dateFormatString(String value) {
    _dateFormatString = value;
    notifyListeners();
  }

  double _graphLineThickness = 3;
  double get graphLineThickness => _graphLineThickness;
  set graphLineThickness(double value) {
    _graphLineThickness = value;
    notifyListeners();
  }

  int _animationSpeed = 150;
  int get animationSpeed => _animationSpeed;
  set animationSpeed(int value) {
    _animationSpeed = value;
    notifyListeners();
  }

  int _sysWarn = 120;
  int get sysWarn => _sysWarn;
  set sysWarn(int value) {
    _sysWarn = value;
    notifyListeners();
  }

  int _diaWarn = 80;
  int get diaWarn => _diaWarn;
  set diaWarn(int value) {
    _diaWarn = value;
    notifyListeners();
  }

  bool _allowManualTimeInput = true;
  bool get allowManualTimeInput => _allowManualTimeInput;
  set allowManualTimeInput(bool value) {
    _allowManualTimeInput = false;
    notifyListeners();
  }

  bool _confirmDeletion = true;
  bool get confirmDeletion => _confirmDeletion;
  set confirmDeletion(bool value) {
    _confirmDeletion = value;
    notifyListeners();
  }

  bool _darkMode = true;
  bool get darkMode => _darkMode;
  set darkMode(bool value) {
    _darkMode = value;
    notifyListeners();
  }


  bool _followSystemDarkMode = true;
  bool get followSystemDarkMode => _followSystemDarkMode;
  set followSystemDarkMode(bool value) {
    _followSystemDarkMode = value;
    notifyListeners();
  }

  bool _validateInputs = true;
  bool get validateInputs => _validateInputs;
  set validateInputs(bool value) {
    _validateInputs = value;
    notifyListeners();
  }

  bool _allowMissingValues = false;
  bool get allowMissingValues => _allowMissingValues;
  set allowMissingValues(bool value) {
    _allowMissingValues = value;
    notifyListeners();
  }

  bool _drawRegressionLines = false;
  bool get drawRegressionLines => _drawRegressionLines;
  set drawRegressionLines(bool value) {
    _drawRegressionLines = value;
    notifyListeners();
  }

  bool _startWithAddMeasurementPage = false;
  bool get startWithAddMeasurementPage => _startWithAddMeasurementPage;
  set startWithAddMeasurementPage(bool value) {
    _startWithAddMeasurementPage = value;
    notifyListeners();
  }

  bool _useLegacyList = false;
  bool get useLegacyList => _useLegacyList;
  set useLegacyList(bool value) {
    _useLegacyList = value;
    notifyListeners();
  }
  
// When adding fields notice the checklist at the top.
}

MaterialColor? _parseMaterialColor(dynamic value) {
  if (value is MaterialColor) return value;
  if (value == null) return null;
  
  late final Color color;
  if (value is Color) {
    color = value;
  } else if (value is int) {
    color = Color(value);
  } else if (value is String) {
    final int? parsedValue = int.tryParse(value);
    if (parsedValue == null) return null;
    color = Color(parsedValue);
  } else {
    assert(false);
    return null;
  }
  
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

/// Parses all forms of a boolean someone might put in a a boolean.
bool? _parseBool(dynamic value) {
  if (value is bool) return value;
  if (value == 'true' || value == 1) return true;
  if (value == 'false' || value == 0) return false;
  return null;
}

int? _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  return null;
}

double? _parseDouble(dynamic value) {
  if (value is double) return value;
  if (value is String) return double.tryParse(value);
  return null;
}

String? _parseString(dynamic value) {
  if (value is String) return value;
  if (value is int || value is double || value is bool) return value.toString();
  return null;
}

String _serializeLocale(Locale? value) {
  if (value == null) return 'NULL';
  return value.languageCode;
}

Locale? _parseLocale(dynamic value) {
  if (value == 'NULL') return null;
  return Locale(value);
}



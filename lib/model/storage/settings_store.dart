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
/// - [ ] Add parsable representation (as String, Integer or Boolean) to the .toMap
/// - [ ] Parse it in the .fromMap factory method
/// - [ ] Make sure edge cases are handled in .fromMap (does not exist (update), not parsable (user))
class Settings extends ChangeNotifier {
  /// Creates a settings object with the default values.
  ///
  /// When the values should be set consider using the factory methods.
  Settings({
    MaterialColor? accentColor,
    MaterialColor? sysColor,
    MaterialColor? diaColor,
    MaterialColor? pulColor,
  }) {
    if (accentColor != null) _accentColor = accentColor;
    if (sysColor != null) _sysColor = sysColor;
    if (diaColor != null) _diaColor = diaColor;
    if (pulColor != null) _pulColor = pulColor;
  }

  factory Settings.fromMap(Map<String, dynamic> map) => Settings(
    accentColor: _parseMaterialColor(map['accentColor']),
    sysColor: _parseMaterialColor(map['sysColor']),
    diaColor: _parseMaterialColor(map['diaColor']),
    pulColor: _parseMaterialColor(map['pulColor']),
  );
      
  factory Settings.fromJson(String json) => Settings.fromMap(jsonDecode(json));

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'accentColor': accentColor.value,
      'sysColor': sysColor.value,
      'diaColor': diaColor.value,
      'pulColor': pulColor.value,
    };
  }

  String toJson() => jsonEncode(toMap());

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



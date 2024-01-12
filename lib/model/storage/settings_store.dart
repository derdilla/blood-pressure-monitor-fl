import 'dart:collection';
import 'dart:convert';

import 'package:blood_pressure_app/model/blood_pressure/medicine/medicine.dart';
import 'package:blood_pressure_app/model/horizontal_graph_line.dart';
import 'package:blood_pressure_app/model/storage/convert_util.dart';
import 'package:flutter/material.dart';

/// Stores settings that are directly controllable by the user through the settings screen.
///
/// This class should not be used to save persistent state that the user doesn't know about.
///
/// The [storage] library comment has more information on the architecture for adding persistent fields.
class Settings extends ChangeNotifier {
  /// Creates a settings object with the default values.
  ///
  /// When the values should be set consider using the factory methods.
  Settings({
    Locale? language,
    Color? accentColor,
    Color? sysColor,
    Color? diaColor,
    Color? pulColor,
    List<HorizontalGraphLine>? horizontalGraphLines,
    String? dateFormatString,
    double? graphLineThickness,
    double? needlePinBarWidth,
    int? animationSpeed,
    int? sysWarn,
    int? diaWarn,
    int? lastVersion,
    bool? allowManualTimeInput,
    bool? confirmDeletion,
    ThemeMode? themeMode,
    bool? validateInputs,
    bool? allowMissingValues,
    bool? drawRegressionLines,
    bool? startWithAddMeasurementPage,
    bool? useLegacyList,
    bool? bottomAppBars,
    List<Medicine>? medications,
    int? highestMedIndex,
  }) {
    if (accentColor != null) _accentColor = accentColor;
    if (sysColor != null) _sysColor = sysColor;
    if (diaColor != null) _diaColor = diaColor;
    if (pulColor != null) _pulColor = pulColor;
    if (allowManualTimeInput != null) _allowManualTimeInput = allowManualTimeInput;
    if (confirmDeletion != null) _confirmDeletion = confirmDeletion;
    if (themeMode != null) _themeMode = themeMode;
    if (dateFormatString != null) _dateFormatString = dateFormatString;
    if (animationSpeed != null) _animationSpeed = animationSpeed;
    if (sysWarn != null) _sysWarn = sysWarn;
    if (diaWarn != null) _diaWarn = diaWarn;
    if (graphLineThickness != null) _graphLineThickness = graphLineThickness;
    if (needlePinBarWidth != null) _needlePinBarWidth = needlePinBarWidth;
    if (validateInputs != null) _validateInputs = validateInputs;
    if (allowMissingValues != null) _allowMissingValues = allowMissingValues;
    if (drawRegressionLines != null) _drawRegressionLines = drawRegressionLines;
    if (startWithAddMeasurementPage != null) _startWithAddMeasurementPage = startWithAddMeasurementPage;
    if (useLegacyList != null) _useLegacyList = useLegacyList;
    if (horizontalGraphLines != null) _horizontalGraphLines = horizontalGraphLines;
    if (lastVersion != null) _lastVersion = lastVersion;
    if (bottomAppBars != null) _bottomAppBars = bottomAppBars;
    if (medications != null) _medications.addAll(medications);
    if (highestMedIndex != null) _highestMedIndex = highestMedIndex;
    _language = language; // No check here, as null is the default as well.
  }

  factory Settings.fromMap(Map<String, dynamic> map) {
    final settingsObject = Settings(
      accentColor: ConvertUtil.parseColor(map['accentColor']),
      sysColor: ConvertUtil.parseColor(map['sysColor']),
      diaColor: ConvertUtil.parseColor(map['diaColor']),
      pulColor: ConvertUtil.parseColor(map['pulColor']),
      allowManualTimeInput: ConvertUtil.parseBool(map['allowManualTimeInput']),
      confirmDeletion: ConvertUtil.parseBool(map['confirmDeletion']),
      themeMode: ConvertUtil.parseThemeMode(map['themeMode']),
      dateFormatString: ConvertUtil.parseString(map['dateFormatString']),
      animationSpeed: ConvertUtil.parseInt(map['animationSpeed']),
      sysWarn: ConvertUtil.parseInt(map['sysWarn']),
      diaWarn: ConvertUtil.parseInt(map['diaWarn']),
      graphLineThickness: ConvertUtil.parseDouble(map['graphLineThickness']),
      validateInputs: ConvertUtil.parseBool(map['validateInputs']),
      allowMissingValues: ConvertUtil.parseBool(map['allowMissingValues']),
      drawRegressionLines: ConvertUtil.parseBool(map['drawRegressionLines']),
      startWithAddMeasurementPage: ConvertUtil.parseBool(map['startWithAddMeasurementPage']),
      useLegacyList: ConvertUtil.parseBool(map['useLegacyList']),
      language: ConvertUtil.parseLocale(map['language']),
      horizontalGraphLines: ConvertUtil.parseList<String>(map['horizontalGraphLines'])?.map((e) =>
          HorizontalGraphLine.fromJson(jsonDecode(e)),).toList(),
      needlePinBarWidth: ConvertUtil.parseDouble(map['needlePinBarWidth']),
      lastVersion: ConvertUtil.parseInt(map['lastVersion']),
      bottomAppBars: ConvertUtil.parseBool(map['bottomAppBars']),
      medications: ConvertUtil.parseList<String>(map['medications'])?.map((e) =>
          Medicine.fromJson(jsonDecode(e)),).toList(),
      highestMedIndex: ConvertUtil.parseInt(map['highestMedIndex']),
    );

    // update
    if (ConvertUtil.parseBool(map['followSystemThemeMode']) == false) { // when this is true the default is the same
      settingsObject.themeMode = (ConvertUtil.parseBool(map['themeMode']) ?? true) ? ThemeMode.dark : ThemeMode.light;
    }
    return settingsObject;
  }

  factory Settings.fromJson(String json) {
    try {
      return Settings.fromMap(jsonDecode(json));
    } catch (exception) {
      return Settings();
    }
  }

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
      'themeMode': themeMode.serialize(),
      'validateInputs': validateInputs,
      'allowMissingValues': allowMissingValues,
      'drawRegressionLines': drawRegressionLines,
      'startWithAddMeasurementPage': startWithAddMeasurementPage,
      'useLegacyList': useLegacyList,
      'language': ConvertUtil.serializeLocale(language),
      'horizontalGraphLines': horizontalGraphLines.map(jsonEncode).toList(),
      'needlePinBarWidth': _needlePinBarWidth,
      'lastVersion': lastVersion,
      'bottomAppBars': bottomAppBars,
      'medications': medications.map(jsonEncode).toList(),
      'highestMedIndex': highestMedIndex,
    };

  String toJson() => jsonEncode(toMap());

  Locale? _language;
  /// Language to use the app in.
  ///
  /// When the value is null, the device default language is chosen.
  Locale? get language => _language;
  set language(Locale? value) {
    _language = value;
    notifyListeners();
  }

  Color _accentColor = Colors.teal;
  Color get accentColor => _accentColor;
  set accentColor(Color newColor) {
    _accentColor = newColor;
    notifyListeners();
  }

  Color _sysColor = Colors.teal;
  Color get sysColor => _sysColor;
  set sysColor(Color newColor) {
    _sysColor = newColor;
    notifyListeners();
  }

  Color _diaColor = Colors.green;
  Color get diaColor => _diaColor;
  set diaColor(Color newColor) {
    _diaColor = newColor;
    notifyListeners();
  }

  Color _pulColor = Colors.red;
  Color get pulColor => _pulColor;
  set pulColor(Color newColor) {
    _pulColor = newColor;
    notifyListeners();
  }

  List<HorizontalGraphLine> _horizontalGraphLines = [];
  List<HorizontalGraphLine> get horizontalGraphLines => _horizontalGraphLines;
  // TODO: change so it is similar to medicine
  set horizontalGraphLines(List<HorizontalGraphLine> value) {
    _horizontalGraphLines = value;
    notifyListeners();
  }

  String _dateFormatString = 'yyyy-MM-dd HH:mm';
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
  /// Time in which animations run. Higher = slower.
  ///
  /// Usually between 0 and 1000.
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

  int _lastVersion = 0;
  int get lastVersion => _lastVersion;
  set lastVersion(int value) {
    _lastVersion = value;
    notifyListeners();
  }

  bool _allowManualTimeInput = true;
  bool get allowManualTimeInput => _allowManualTimeInput;
  set allowManualTimeInput(bool value) {
    _allowManualTimeInput = value;
    notifyListeners();
  }

  bool _confirmDeletion = true;
  bool get confirmDeletion => _confirmDeletion;
  set confirmDeletion(bool value) {
    _confirmDeletion = value;
    notifyListeners();
  }

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;
  set themeMode(ThemeMode value) {
    _themeMode = value;
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

  double _needlePinBarWidth = 5;
  double get needlePinBarWidth => _needlePinBarWidth;
  set needlePinBarWidth(double value) {
    _needlePinBarWidth = value;
    notifyListeners();
  }

  bool _bottomAppBars = false;
  /// Whether to put the app bar in dialoges at the bottom of the screen.
  bool get bottomAppBars => _bottomAppBars;
  set bottomAppBars(bool value) {
    _bottomAppBars = value;
    notifyListeners();
  }
  
  final List<Medicine> _medications = [];
  UnmodifiableListView<Medicine> get medications => 
      UnmodifiableListView(_medications);
  void addMedication(Medicine medication) {
    _medications.add(medication);
    _highestMedIndex += 1;
    notifyListeners();
  }
  void removeMedicationAt(int index) {
    assert(index >= 0 && index < _medications.length);
    _medications.removeAt(index);
    notifyListeners();
  }

  int _highestMedIndex = 0;
  /// Total amount of medicines created.
  int get highestMedIndex => _highestMedIndex;
  
// When adding fields notice the checklist at the top.
}

extension Serialization on ThemeMode {
  int serialize() {
    switch(this) {
      case ThemeMode.system:
        return 0;
      case ThemeMode.dark:
        return 1;
      case ThemeMode.light:
        return 2;
    }
  }
}


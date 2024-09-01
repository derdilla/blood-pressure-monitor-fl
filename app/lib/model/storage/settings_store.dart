import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:blood_pressure_app/model/blood_pressure/medicine/medicine.dart';
import 'package:blood_pressure_app/model/blood_pressure/pressure_unit.dart';
import 'package:blood_pressure_app/model/horizontal_graph_line.dart';
import 'package:blood_pressure_app/model/storage/convert_util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Stores settings that are directly controllable by the user through the
/// settings screen.
///
/// This class should not be used to save persistent state of individual app
/// components and screens.
///
/// The `storage.dart` library comment has more information on the architecture
/// for adding persistent fields.
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
    PressureUnit? preferredPressureUnit,
    List<String>? knownBleDev,
    int? highestMedIndex,
    bool? bleInput,
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
    if (preferredPressureUnit != null) _preferredPressureUnit = preferredPressureUnit;
    if (highestMedIndex != null) _highestMedIndex = highestMedIndex;
    if (knownBleDev != null) _knownBleDev = knownBleDev;
    if (bleInput != null) _bleInput = bleInput;
    _language = language; // No check here, as null is the default as well.
  }

  /// Create a instance from a map created by [toMap].
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
      knownBleDev: ConvertUtil.parseList<String>(map['knownBleDev']),
      bleInput: ConvertUtil.parseBool(map['bleInput']),
    );

    // update
    if (ConvertUtil.parseBool(map['followSystemThemeMode']) == false) { // when this is true the default is the same
      settingsObject.themeMode = (ConvertUtil.parseBool(map['themeMode']) ?? true) ? ThemeMode.dark : ThemeMode.light;
    }
    return settingsObject;
  }

  /// Create a instance from a [String] created by [toJson].
  factory Settings.fromJson(String json) {
    try {
      return Settings.fromMap(jsonDecode(json));
    } catch (exception) {
      return Settings();
    }
  }

  /// Serialize the object to a restoreable map.
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
    'useLegacyList': compactList,
    'language': ConvertUtil.serializeLocale(language),
    'horizontalGraphLines': horizontalGraphLines.map(jsonEncode).toList(),
    'needlePinBarWidth': _needlePinBarWidth,
    'lastVersion': lastVersion,
    'bottomAppBars': bottomAppBars,
    'medications': medications.map(jsonEncode).toList(),
    'highestMedIndex': highestMedIndex,
    'preferredPressureUnit': preferredPressureUnit.encode(),
    'knownBleDev': knownBleDev,
    'bleInput': bleInput,
  };

  /// Serialize the object to a restoreable string.
  String toJson() => jsonEncode(toMap());

  /// Copy all values from another instance.
  void copyFrom(Settings other) {
    _language = other._language;
    _accentColor = other._accentColor;
    _sysColor = other._sysColor;
    _diaColor = other._diaColor;
    _pulColor = other._pulColor;
    _horizontalGraphLines = other._horizontalGraphLines;
    _dateFormatString = other._dateFormatString;
    _graphLineThickness = other._graphLineThickness;
    _needlePinBarWidth = other._needlePinBarWidth;
    _animationSpeed = other._animationSpeed;
    _sysWarn = other._sysWarn;
    _diaWarn = other._diaWarn;
    _lastVersion = other._lastVersion;
    _allowManualTimeInput = other._allowManualTimeInput;
    _confirmDeletion = other._confirmDeletion;
    _themeMode = other._themeMode;
    _validateInputs = other._validateInputs;
    _allowMissingValues = other._allowMissingValues;
    _drawRegressionLines = other._drawRegressionLines;
    _startWithAddMeasurementPage = other._startWithAddMeasurementPage;
    _useLegacyList = other._useLegacyList;
    _bottomAppBars = other._bottomAppBars;
    _preferredPressureUnit = other._preferredPressureUnit;
    _knownBleDev = other._knownBleDev;
    _bleInput = other._bleInput;
    _medications.clear();
    _medications.addAll(other._medications);
    _highestMedIndex = other._highestMedIndex;
    notifyListeners();
  }

  /// Reset all fields to their default values.
  void reset() => copyFrom(Settings());

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
  /// The primary theme color of the app.
  Color get accentColor => _accentColor;
  set accentColor(Color newColor) {
    _accentColor = newColor;
    notifyListeners();
  }

  Color _sysColor = Colors.teal;
  /// The color of the systolic line in graphs and list headlines.
  Color get sysColor => _sysColor;
  set sysColor(Color newColor) {
    _sysColor = newColor;
    notifyListeners();
  }

  Color _diaColor = Colors.green;
  /// The color of the diastolic line in graphs and list headlines.
  Color get diaColor => _diaColor;
  set diaColor(Color newColor) {
    _diaColor = newColor;
    notifyListeners();
  }

  Color _pulColor = Colors.red;
  /// The color of the pulse line in graphs and list headlines.
  Color get pulColor => _pulColor;
  set pulColor(Color newColor) {
    _pulColor = newColor;
    notifyListeners();
  }

  List<HorizontalGraphLine> _horizontalGraphLines = [];
  /// Lines that are drawn horizontally in the graph that indicate height.
  List<HorizontalGraphLine> get horizontalGraphLines => _horizontalGraphLines;
  // TODO: change so it is similar to medicine
  set horizontalGraphLines(List<HorizontalGraphLine> value) {
    _horizontalGraphLines = value;
    notifyListeners();
  }

  String _dateFormatString = 'yyyy-MM-dd HH:mm';
  /// The time format to use when a human readable time is required.
  String get dateFormatString => _dateFormatString;
  set dateFormatString(String value) {
    _dateFormatString = value;
    notifyListeners();
  }

  double _graphLineThickness = 3;
  /// The width of value lines in the graph.
  ///
  /// Does not apply for all markers.
  double get graphLineThickness => _graphLineThickness;
  set graphLineThickness(double value) {
    _graphLineThickness = value;
    notifyListeners();
  }

  int _animationSpeed = 150;
  /// Time in which animations run. Higher => slower.
  ///
  /// Usually between 0 and 1000.
  int get animationSpeed => _animationSpeed;
  set animationSpeed(int value) {
    _animationSpeed = value;
    notifyListeners();
  }

  int _sysWarn = 120;
  /// The height from which to highlight the area below for the systolic line
  /// in the graph.
  int get sysWarn => _sysWarn;
  set sysWarn(int value) {
    _sysWarn = value;
    notifyListeners();
  }

  int _diaWarn = 80;
  /// The height from which to highlight the area below for the diastolic line
  /// in the graph.
  int get diaWarn => _diaWarn;
  set diaWarn(int value) {
    _diaWarn = value;
    notifyListeners();
  }

  int _lastVersion = 0;
  /// (META) The last version to which settings are upgraded.
  ///
  /// Gets to the latest version on app start, after upgrades have run.
  int get lastVersion => _lastVersion;
  set lastVersion(int value) {
    _lastVersion = value;
    notifyListeners();
  }

  bool _allowManualTimeInput = true;
  /// Whether to show the time editor on the add entry page.
  bool get allowManualTimeInput => _allowManualTimeInput;
  set allowManualTimeInput(bool value) {
    _allowManualTimeInput = value;
    notifyListeners();
  }

  bool _confirmDeletion = true;
  /// Whether to show a dialoge that requires confirmation before deleting
  /// entries.
  bool get confirmDeletion => _confirmDeletion;
  set confirmDeletion(bool value) {
    _confirmDeletion = value;
    notifyListeners();
  }

  ThemeMode _themeMode = ThemeMode.system;
  /// What color theme the whole app should use.
  ThemeMode get themeMode => _themeMode;
  set themeMode(ThemeMode value) {
    _themeMode = value;
    notifyListeners();
  }


  bool _validateInputs = true;
  /// Whether to run any validators on values inputted on add measurement page.
  bool get validateInputs => _validateInputs;
  set validateInputs(bool value) {
    _validateInputs = value;
    notifyListeners();
  }

  bool _allowMissingValues = false;
  /// Whether to allow not filling all fields on the add measurement page.
  ///
  /// When this is true [validateInputs] must be set to false in order for this
  /// to take effect.
  bool get allowMissingValues => _allowMissingValues;
  set allowMissingValues(bool value) {
    _allowMissingValues = value;
    notifyListeners();
  }

  bool _drawRegressionLines = false;
  /// Whether to draw trend lines on the graph.
  bool get drawRegressionLines => _drawRegressionLines;
  set drawRegressionLines(bool value) {
    _drawRegressionLines = value;
    notifyListeners();
  }

  bool _startWithAddMeasurementPage = false;
  /// Whether to show the add measurement page on app launch.
  bool get startWithAddMeasurementPage => _startWithAddMeasurementPage;
  set startWithAddMeasurementPage(bool value) {
    _startWithAddMeasurementPage = value;
    notifyListeners();
  }

  bool _useLegacyList = false;
  /// Whether to use the compact list with swipe deletion.
  bool get compactList => _useLegacyList;
  set compactList(bool value) {
    _useLegacyList = value;
    notifyListeners();
  }

  double _needlePinBarWidth = 5;
  /// The width the color of measurements should have on the graph.
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

  PressureUnit _preferredPressureUnit = PressureUnit.mmHg;
  /// Preferred unit to display and enter measurements in.
  PressureUnit get preferredPressureUnit => _preferredPressureUnit;
  set preferredPressureUnit(PressureUnit value) {
    _preferredPressureUnit = value;
    notifyListeners();
  }

  bool _bleInput = true;
  /// Whether to show bluetooth input on add measurement page.
  bool get bleInput => (Platform.isAndroid || Platform.isIOS || Platform.isMacOS
    || (kDebugMode && Platform.environment['FLUTTER_TEST'] == 'true'))
      && _bleInput;
  set bleInput(bool value) {
    _bleInput = value;
    notifyListeners();
  }

  List<String> _knownBleDev = [];
  /// Bluetooth devices that previously connected.
  ///
  /// The exact value that is stored here is determined in [DeviceScanCubit].
  UnmodifiableListView<String> get knownBleDev =>
      UnmodifiableListView(_knownBleDev);
  set knownBleDev(List<String> value) {
    _knownBleDev = value;
    notifyListeners();
  }

  final List<Medicine> _medications = [];
  /// All medications ever added.
  ///
  /// This includes medications that got hidden. To obtain medications for a
  /// selection, do `settings.medications.where((e) => !e.hidden)`.
  @Deprecated('use health_data_store')
  UnmodifiableListView<Medicine> get medications =>
    UnmodifiableListView(_medications);

  int _highestMedIndex = 0;
  /// Total amount of medicines created.
  int get highestMedIndex => _highestMedIndex;
  
// When adding fields notice the checklist at the top.
}

/// Extension to add a serialize method that can be restored by
/// [ConvertUtil.parseThemeMode].
extension Serialization on ThemeMode {
  /// Turns enum into a restoreable integer.
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

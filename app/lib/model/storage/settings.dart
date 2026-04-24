import 'dart:collection';
import 'dart:convert';

import 'package:blood_pressure_app/config.dart';
import 'package:blood_pressure_app/features/bluetooth/logic/device_scan_cubit.dart';
import 'package:blood_pressure_app/model/blood_pressure/pressure_unit.dart';
import 'package:blood_pressure_app/model/horizontal_graph_line.dart';
import 'package:blood_pressure_app/model/bluetooth_input_mode.dart';
import 'package:blood_pressure_app/model/storage/convert_util.dart';
import 'package:blood_pressure_app/model/storage/types/bluetooth_input_mode_setting.dart';
import 'package:blood_pressure_app/model/storage/types/color_setting.dart';
import 'package:blood_pressure_app/model/storage/types/horizontal_graph_line_list_setting.dart';
import 'package:blood_pressure_app/model/storage/types/locale_setting.dart';
import 'package:blood_pressure_app/model/storage/types/pressure_unit_setting.dart';
import 'package:blood_pressure_app/model/storage/types/string_list_setting.dart';
import 'package:blood_pressure_app/model/storage/types/theme_mode_setting.dart';
import 'package:blood_pressure_app/model/storage/types/weight_unit_setting.dart';
import 'package:blood_pressure_app/model/weight_unit.dart';
import 'package:flutter/material.dart';

import 'package:settings_annotation/settings_annotation.dart';

part 'settings.store.dart';

/// Stores settings that are directly controllable by the user through the
/// settings screen.
@GenerateSettings()
class _SettingsSpec extends ChangeNotifier {
  /// Language to use the app in.
  ///
  /// When the value is null, the device default language is chosen.
  final Setting<Locale?> language = LocaleSetting(initialValue: null);

  /// The primary theme color of the app.
  final Setting<Color> accentColor = ColorSetting(initialValue: Colors.teal);

  /// The color of the systolic line in graphs and list headlines.
  final Setting<Color> sysColor = ColorSetting(initialValue: Colors.teal);

  /// The color of the diastolic line in graphs and list headlines.
  final Setting<Color> diaColor = ColorSetting(initialValue: Colors.green);

  /// The color of the pulse line in graphs and list headlines.
  final Setting<Color> pulColor = ColorSetting(initialValue: Colors.red);

  /// Lines that are drawn horizontally in the graph that indicate height.
  final Setting<List<HorizontalGraphLine>> horizontalGraphLines =
      HorizontalGraphLineListSetting(initialValue: []);

  /// The time format to use when a human readable time is required.
  final dateFormatString = Setting<String>(initialValue: 'yyyy-MM-dd HH:mm');

  /// The width of value lines in the graph.
  ///
  /// Does not apply for all markers.
  final graphLineThickness = Setting<double>(initialValue: 3);

  /// Time in which animations run. Higher => slower.
  ///
  /// Usually between 0 and 1000.
  final animationSpeed = Setting<int>(initialValue: 150);

  /// The height from which to highlight the area below for the systolic line
  /// in the graph.
  final sysWarn = Setting<int>(initialValue: 120);

  /// The height from which to highlight the area below for the diastolic line
  /// in the graph.
  final diaWarn = Setting<int>(initialValue: 80);

  /// (META) The last version to which settings are upgraded.
  ///
  /// Gets to the latest version on app start, after upgrades have run.
  final lastVersion = Setting<int>(initialValue: 0);

  /// Whether to show the time editor on the add entry page.
  final allowManualTimeInput = Setting<bool>(initialValue: true);

  /// Whether to show a dialog that requires confirmation before deleting
  /// entries.
  final confirmDeletion = Setting<bool>(initialValue: true);

  /// What color theme the whole app should use.
  final Setting<ThemeMode> themeMode = ThemeModeSetting(initialValue: ThemeMode.system);

  /// Whether to run any validators on values inputted on add measurement page.
  final validateInputs = Setting<bool>(initialValue: true);

  /// Whether to allow not filling all fields on the add measurement page.
  ///
  /// When this is true [validateInputs] must be set to false in order for this
  /// to take effect.
  final allowMissingValues = Setting<bool>(initialValue: false);

  /// Whether to draw trend lines on the graph.
  final drawRegressionLines = Setting<bool>(initialValue: false);

  /// Whether to show the add measurement page on app launch.
  final startWithAddMeasurementPage = Setting<bool>(initialValue: false);

  /// Whether to use the compact list with swipe deletion.
  final compactList = Setting<bool>(
    name: 'useLegacyList',
    intialValue: false,
  );

  /// The width the color of measurements should have on the graph.
  final needlePinBarWidth = Setting<double>(intialValue: 5);

  /// Whether to put the app bar in dialogs at the bottom of the screen.
  final bottomAppBars = Setting<bool>(intialValue: false);

  /// Preferred unit to display and enter measurements in.
  final Setting<PressureUnit> preferredPressureUnit = PressureUnitSetting(
    initialValue: PressureUnit.mmHg,
  );

  /// Whether to show bluetooth input on add measurement page.
  final Setting<BluetoothInputMode> bleInput = BluetoothInputModeSetting(
    initialValue: BluetoothInputMode.disabled,
  );

  /// Whether to show weight related features.
  final weightInput = Setting<bool>(initialValue: false);


  /// Bluetooth devices that previously connected.
  ///
  /// The exact value that is stored here is determined in [DeviceScanCubit].
  final Setting<List<String>> knownBleDev = StringListSetting(
      initialValue: []);

  /// Preferred unit for bodyweight.
  final Setting<WeightUnit> weightUnit = WeightUnitSetting(
    initialValue: WeightUnit.kg,
  );

  /// Whether to autofill the time the bluetooth device reports.
  ///
  /// This was introduced because the system time tends to be more accurate.
  final trustBLETime = Setting<bool>(initialValue: true);

  /// Whether to warn the user when the time the bluetooth device reports is far
  /// in the past and [trustBLETime] is true.
  final showBLETimeTrustDialog = Setting<bool>(initialValue: true);

  /// Days after which to interrupt line graphs. Disabled when zero
  final interruptGraphAfterNDays = Setting<int>(initialValue: 10);
}

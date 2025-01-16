import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Different modes for the bluetooth input field.
enum BluetoothInputMode {
  /// No bluetooth input.
  disabled,
  /// The established bluetooth input.
  oldBluetoothInput,
  /// The new bluetooth input with flutter_blue_plus backend.
  newBluetoothInputOldLib,
  /// The new bluetooth input with bluetooth_low_energy backend.
  newBluetoothInputCrossPlatform;

  /// Turn object into [deserialize]able number.
  int serialize() => switch(this) {
    BluetoothInputMode.disabled => 0,
    BluetoothInputMode.oldBluetoothInput => 1,
    BluetoothInputMode.newBluetoothInputOldLib => 2,
    BluetoothInputMode.newBluetoothInputCrossPlatform => 3,
  };

  /// Try to create an object from [serialize]d form.
  static BluetoothInputMode? deserialize(int? value) => switch (value) {
    0 => BluetoothInputMode.disabled,
    1 => BluetoothInputMode.oldBluetoothInput,
    2 => BluetoothInputMode.newBluetoothInputOldLib,
    3 => BluetoothInputMode.newBluetoothInputCrossPlatform,
    _ => null,
  };

  /// Determine the matching localization.
  String localize(AppLocalizations localizations) => switch(this) {
    BluetoothInputMode.disabled => localizations.disabled,
    BluetoothInputMode.oldBluetoothInput => localizations.oldBluetoothInput,
    BluetoothInputMode.newBluetoothInputOldLib => localizations.newBluetoothInputOldLib,
    BluetoothInputMode.newBluetoothInputCrossPlatform => localizations.newBluetoothInputCrossPlatform,
  };
}

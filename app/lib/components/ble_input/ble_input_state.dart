import 'package:blood_pressure_app/components/ble_input/measurement_characteristic.dart';
import 'package:blood_pressure_app/model/blood_pressure/record.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

/// State of a component for inputting measurements through ble devices
sealed class BleInputState {}

/// The ble input field is inactive (not opened).
class BleInputClosed extends BleInputState {}

/// Doesn't have permission for bluetooth access.
///
/// The UI should show a warning to allow bluetooth and potentially location
/// permissions.
class BleInputPermissionFailure extends BleInputState {}

/// Scanning for devices.
class BleInputLoadInProgress extends BleInputState {}
/// Could not start bluetooth search.
///
/// Most permissions errors should be covered by [BleInputPermissionFailure] so
/// this might not be actionable by the user.
class BleInputLoadFailure extends BleInputState {}
/// Found devices.
class BleInputLoadSuccess extends BleInputState {
  BleInputLoadSuccess(this.availableDevices);

  final List<DiscoveredDevice> availableDevices;
}

/// Connecting to device.
class BleConnectInProgress extends BleInputState {}
/// Couldn't connect to device or closed connection.
class BleConnectFailed extends BleInputState {}
/// Is connected with device.
class BleConnectSuccess extends BleInputState {}

/// Received information about an blood pressure measurement.
class BleMeasurementInProgress extends BleInputState {}

/// A measurement was taken through the bluetooth device.
class BleMeasurementSuccess extends BleInputState {
  /// A measurement that was taken through the bluetooth device.
  BleMeasurementSuccess(this.record, {
    this.bodyMoved,
    this.cuffLoose,
    this.irregularPulse,
    this.measurementStatus,
    this.improperMeasurementPosition,
  });

  /// Measured blood pressure data.
  final BloodPressureRecord record;

  /// Whether body movement was detected during measurement.
  bool? bodyMoved;

  /// Whether the cuff was too loose during measurement.
  bool? cuffLoose;

  /// Whether irregular pulse was detected.
  bool? irregularPulse;

  /// The range the pulse rate was in.
  MeasurementStatus? measurementStatus;

  /// Whether the measurement was taken at an improper position.
  bool? improperMeasurementPosition;
}

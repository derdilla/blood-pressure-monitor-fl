import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_utils.dart';

/// Current state of bluetooth adapter/sensor
enum BluetoothAdapterState {
  /// Use of bluetooth adapter not authorized
  unauthorized,
  /// Use of bluetooth adapter not possible, f.e. because there is none
  unfeasible,
  /// Use of bluetooth adapter disabled
  disabled,
  /// Use of bluetooth adapter unknown
  initial,
  /// Bluetooth adapter ready to be used
  ready;
}

/// Util to parse backend adapter states to [BluetoothAdapterState]
abstract class BluetoothAdapterStateParser<BackendState> extends StreamDataParserCached<BackendState, BluetoothAdapterState> {
  @override
  BluetoothAdapterState get initialState => BluetoothAdapterState.initial;
}

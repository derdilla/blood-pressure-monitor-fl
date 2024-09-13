part of 'bluetooth_backend.dart';

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

/// Transforms the backend's bluetooth adapter state stream to emit [BluetoothAdapterState]'s
///
/// Can normally be used directly, backends should only inject a customized BluetoothStateParser
class BluetoothAdapterStateStreamTransformer<BackendState, BASP extends BluetoothAdapterStateParser<BackendState>>
  extends StreamDataParserTransformer<BackendState, BluetoothAdapterState, BASP> {
  /// Create a BluetoothAdapterStateStreamTransformer
  ///
  /// [stateParser] The BluetoothStateParser that provides the backend logic to convert BackendState to BluetoothAdapterState
  BluetoothAdapterStateStreamTransformer({ required super.stateParser, super.sync, super.cancelOnError });
}

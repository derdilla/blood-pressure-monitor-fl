part of 'bluetooth_backend.dart';

/// Current state of bluetooth adapter/sensor
enum BluetoothAdapterState {
  /// @see BluetoothAdapterStateUnauthorized
  unauthorized,
  /// @see BluetoothAdapterStateUnfeasible
  unfeasible,
  /// @see BluetoothAdapterStateDisabled
  disabled,
  /// @see BluetoothAdapterStateInitial
  initial,
  /// @see BluetoothAdapterStateReady
  ready;
}

/// Bluetooth adapter state parser base class
abstract class BluetoothStateParser<T> {
  BluetoothAdapterState _lastKnownState = BluetoothAdapterState.initial;

  /// The last known adapter state
  BluetoothAdapterState get lastKnownState => _lastKnownState;

  /// Method to be implemented by backend that converts the raw bluetooth adapter state to our BluetoothState
  BluetoothAdapterState parse(T rawState);

  /// Internal method to cache the last adapter state value, backends should only implement parse not this method
  BluetoothAdapterState parseAndCache(T rawState) {
    _lastKnownState = parse(rawState);
    return _lastKnownState;
  }
}

/// Transforms a bluetooth adapter state stream to emit BluetoothAdapterState's
/// Can normally be used directly, backend's should only inject a customized stateParser
class BluetoothAdapterStateStreamTransformer<S,T> extends BluetoothStreamTransformer<S, BluetoothAdapterState> {
  /// constructor
  BluetoothAdapterStateStreamTransformer({ required BluetoothStateParser<T> stateParser, super.sync, super.cancelOnError }) {
    _stateParser = stateParser;
  }

  late BluetoothStateParser _stateParser;

  @override
  void onData(S data) {
    final BluetoothAdapterState state = _stateParser.parseAndCache(data);
    sendData(state);
  }
}

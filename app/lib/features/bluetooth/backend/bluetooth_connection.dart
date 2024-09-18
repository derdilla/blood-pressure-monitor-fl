
import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_state.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_utils.dart';

/// State of the bluetooth connection of a device
enum BluetoothConnectionState {
  /// Device is connected
  connected,
  /// Device is disconnect
  disconnected;
}

/// Bluetooth connection state parser base class
///
/// This is a separate helper class as factory or static methods cannot be abstract,
/// so even though this class only has one method it's useful to enforce the types
abstract class BluetoothConnectionStateParser<BackendConnectionState> extends StreamDataParser<BackendConnectionState, BluetoothConnectionState> {}

/// Transforms the backend's bluetooth adapter state stream to emit [BluetoothAdapterState]'s
///
/// Can normally be used directly, backends should only inject a customized [BluetoothAdapterStateParser]
class BluetoothConnectionStateStreamTransformer<BackendConnectionState, BASP extends BluetoothConnectionStateParser<BackendConnectionState>>
  extends StreamDataParserTransformer<BackendConnectionState, BluetoothConnectionState, BASP> {
  /// Create a [BluetoothConnectionStateStreamTransformer] instance
  ///
  /// [stateParser] The [BluetoothConnectionStateParser] that provides the backend specific logic to convert [BackendConnectionState] to [BluetoothConnectionState]
  BluetoothConnectionStateStreamTransformer({ required super.stateParser, super.sync, super.cancelOnError });
}

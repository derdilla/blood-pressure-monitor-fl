import 'package:collection/collection.dart';

/// Bluetooth Base UUID from Bluetooth Core Spec
///
/// The full 128-bit value of a 16-bit or 32-bit UUID may be computed by a simple arithmetic
/// operation.
/// 128_bit_value = 16_bit_value × 296 + Bluetooth_Base_UUID
/// 128_bit_value = 32_bit_value × 296 + Bluetooth_Base_UUID
const bluetoothBaseUuid = '00000000-0000-1000-8000-00805F9B34FB';

/// Generic BluetoothUuid representation
abstract class BluetoothUuid<BackendUuid> {
  /// constructor
  BluetoothUuid({ required this.uuid}): assert(uuid.toString().length == 36);

  /// Create a BluetoothUuid from a string
  BluetoothUuid.fromString(String uuid):
    assert(uuid.isNotEmpty, 'This static method is abstract'),
    uuid = bluetoothBaseUuid as BackendUuid // satisfy linter
    {
      throw AssertionError('This static method is abstract');
    }

  /// The backend specific uuid
  final BackendUuid uuid;

  /// Whether this uuid is an official bluetooth core spec uuid
  bool get isBluetoothUuid => uuid.toString().toUpperCase().endsWith(bluetoothBaseUuid.substring(8));

  @override
  String toString() => uuid.toString();

  /// Returns the 16 bit value of the UUID if uuid is from bluetooth core spec, otherwise full id
  ///
  /// The 16-bit Attribute UUID replaces the x’s in the following:
  ///   0000xxxx-0000-1000-8000-00805F9B34FB
  String get shortId {
    final uuid = toString();
    assert(uuid.length == 36);

    if (isBluetoothUuid) {
      return '0x${uuid.substring(4, 8)}';
    }

    return uuid;
  }

  @override
  bool operator ==(Object other) => switch (other.runtimeType) {
    final BluetoothUuid other => toString() == other.toString(),
    final BluetoothService other => toString() == other.uuid.toString(),
    final BluetoothCharacteristic other => toString() == other.uuid.toString(),
    _ => false,
  };

  @override
  int get hashCode => super.hashCode * 17;
}

/// Generic BluetoothService representation
abstract class BluetoothService<BackendService, BC extends BluetoothCharacteristic> {
  /// Initialize bluetooth service wrapper class
  BluetoothService({ required this.uuid, required this.source });

  /// UUID of the service
  final BluetoothUuid uuid;
  /// Backend source for the service
  final BackendService source;

  /// Get all characteristics for this service
  List<BC> get characteristics;

  /// Returns the characteristic with requested [uuid], returns null if
  /// requested [uuid] was not found
  Future<BC?> getCharacteristicByUuid(BluetoothUuid uuid) async => characteristics.firstWhereOrNull((service) => service.uuid == uuid);

  @override
  String toString() => 'BluetoothService{uuid: 0x${uuid.shortId}, source: ${source.runtimeType}}';

  @override
  bool operator ==(Object other) => (other is BluetoothService)
    && toString() == other.toString();

  @override
  int get hashCode => super.hashCode * 17;
}

/// Characteristic representation
abstract class BluetoothCharacteristic<BackendCharacteristic> {
  /// Initialize bluetooth characteristic wrapper class
  BluetoothCharacteristic({ required this.uuid, required this.source });

  /// UUID of the characteristic
  final BluetoothUuid uuid;
  /// Backend source for the characteristic
  final BackendCharacteristic source;

  /// Whether the characteristic can be read
  bool get canRead;

  /// Whether the characteristic can be written to
  bool get canWrite;

  /// Whether the characteristic can be written to without a response
  bool get canWriteWithoutResponse;

  /// Whether the characteristic permits notifications for it's value, without a response to indicate receipt of the notification.
  bool get canNotify;

  /// Whether the characteristic permits notifications for it's value, with a response to indicate receipt of the notification
  bool get canIndicate;

  @override
  String toString() => 'BluetoothCharacteristic{uuid: ${uuid.shortId}, source: ${source.runtimeType}, '
    'canRead: $canRead, canWrite: $canWrite, canWriteWithoutResponse: $canWriteWithoutResponse, '
    'canNotify: $canNotify, canIndicate: $canIndicate}';

  @override
  bool operator ==(Object other) => (other is BluetoothCharacteristic)
    && toString() == other.toString();

  @override
  int get hashCode => super.hashCode * 17;
}

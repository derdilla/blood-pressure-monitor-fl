part of 'bluetooth_backend.dart';

/// BluetoothUuid representation
abstract class BluetoothUuid<T> {
  /// constructor
  BluetoothUuid({ required T uuid}) {
    _uuid = uuid;
  }

  /// Create a BluetoothUuid from a string
  BluetoothUuid.fromString(String uuid);

  late T _uuid;

  /// The backend specific uuid
  T get uuid => _uuid;

  @override
  String toString() => _uuid.toString();

  @override
  bool operator == (Object other) {
    if (other is BluetoothUuid) {
      return toString() == other.toString();
    }

    return false;
  }

  @override
  int get hashCode => super.hashCode * 17;
}

/// Service representation
abstract class BluetoothService<BackendService, BC extends BluetoothCharacteristic> {
  /// constructor
  BluetoothService({ required BluetoothUuid uuid, required BackendService source }) {
    _uuid = uuid;
    _source = source;
  }

  late BluetoothUuid _uuid;
  late BackendService _source;

  /// UUID of the service
  BluetoothUuid get uuid => _uuid;

  /// Backend source for the service
  BackendService get source => _source;

  /// Get all characteristics for this service
  List<BC> get characteristics;

  /// Returns the characteristic with requested uuid
  Future<BC?> getCharacteristicByUuid(BluetoothUuid uuid) async {
    try {
      return characteristics.firstWhere((service) => service.uuid == uuid);
    } on StateError {
      return null;
    }
  }

  @override
  String toString() => 'BluetoothService{uuid: $uuid, source: $source}';

  @override
  bool operator == (Object other) {
    if (other is BluetoothService) {
      return toString() == other.toString();
    }

    if (other is BluetoothUuid) {
      return _uuid.toString() == other.toString();
    }

    return false;
  }

  @override
  int get hashCode => super.hashCode * 17;
}

/// Characteristic representation
abstract class BluetoothCharacteristic<BackendCharacteristic> {
  /// constructor
  BluetoothCharacteristic({ required BluetoothUuid uuid, required BackendCharacteristic source }) {
    _uuid = uuid;
    _source = source;
  }

  late BluetoothUuid _uuid;
  late BackendCharacteristic _source;

  /// UUID of the characteristic
  BluetoothUuid get uuid => _uuid;

  /// Backend source for the characteristic
  BackendCharacteristic get source => _source;

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
  String toString() => 'BluetoothCharacteristic{uuid: $uuid, source: $source, '
    'canRead: $canRead, canWrite: $canWrite, canWriteWithoutResponse: $canWriteWithoutResponse, '
    'canNotify: $canNotify, canIndicate: $canIndicate}';

  @override
  bool operator == (Object other) {
    if (other is BluetoothCharacteristic) {
      return toString() == other.toString();
    }

    if (other is BluetoothUuid) {
      return _uuid.toString() == other.toString();
    }

    return false;
  }

  @override
  int get hashCode => super.hashCode * 19;
}

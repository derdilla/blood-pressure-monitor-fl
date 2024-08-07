import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'fake_service.dart';

class FakeDevice implements BluetoothDevice {
  FakeDevice() {
    Timer.periodic(Duration(seconds: 2), (timer) {
      _connectedController.add(_connected ? BluetoothConnectionState.connected : BluetoothConnectionState.disconnected);
    });
  }

  bool _connected = false;
  StreamController<BluetoothConnectionState> _connectedController = StreamController.broadcast();


  List<BluetoothService> _services = [
    FakeBleBPService(),
  ];

  String _platformName = 'test device 1234';

  AdvertisementData createFakeData() => AdvertisementData(
    advName: advName,
    txPowerLevel: null,
      appearance: null,
      connectable: true,
      manufacturerData: {},
      serviceData: {},
      serviceUuids: [],
  );

  @override
  String get advName => platformName;

  @override
  // TODO: implement bondState
  Stream<BluetoothBondState> get bondState => throw UnimplementedError();

  @override
  void cancelWhenDisconnected(StreamSubscription subscription, {bool next = false, bool delayed = false}) {
    // TODO: implement cancelWhenDisconnected
  }

  @override
  Future<void> clearGattCache() {
    // TODO: implement clearGattCache
    throw UnimplementedError();
  }

  @override
  Future<void> connect({Duration timeout = const Duration(seconds: 35), int? mtu = 512, bool autoConnect = false}) async {
    print('CALLED CONNECT');
    _connected = true;
    final state = _connected
        ? BluetoothConnectionState.connected
        : BluetoothConnectionState.disconnected;
    _connectedController.add(state);
  }

  @override
  Stream<BluetoothConnectionState> get connectionState => _connectedController.stream;

  @override
  Future<void> createBond({int timeout = 90}) {
    // TODO: implement createBond
    throw UnimplementedError();
  }

  @override
  Future<void> disconnect({int timeout = 35, bool queue = true, int androidDelay = 2000,}) async {
    print('CALLED DISCONNECT:');
    debugPrintStack();
    _connected = false;
    final state = _connected
        ? BluetoothConnectionState.connected
        : BluetoothConnectionState.disconnected;
    _connectedController.add(state);
  }

  @override
  DisconnectReason? get disconnectReason => null;

  @override
  Future<List<BluetoothService>> discoverServices({bool subscribeToServicesChanged = true, int timeout = 15}) async {
    assert(_connected);
    return _services;
  }

  @override
  // TODO: implement id
  DeviceIdentifier get id => throw UnimplementedError();

  @override
  bool get isAutoConnectEnabled => false;

  @override
  bool get isConnected => _connected;

  @override
  bool get isDisconnected => !_connected;

  @override
  // TODO: implement isDiscoveringServices
  Stream<bool> get isDiscoveringServices => throw UnimplementedError();

  @override
  // TODO: implement localName
  String get localName => throw UnimplementedError();

  @override
  // TODO: implement mtu
  Stream<int> get mtu => throw UnimplementedError();

  @override
  // TODO: implement mtuNow
  int get mtuNow => throw UnimplementedError();

  @override
  // TODO: implement name
  String get name => throw UnimplementedError();

  @override
  // TODO: implement onServicesReset
  Stream<void> get onServicesReset => throw UnimplementedError();

  @override
  Future<void> pair() {
    // TODO: implement pair
    throw UnimplementedError();
  }

  @override
  String get platformName => _platformName;

  @override
  // TODO: implement prevBondState
  BluetoothBondState? get prevBondState => throw UnimplementedError();

  @override
  Future<int> readRssi({int timeout = 15}) {
    // TODO: implement readRssi
    throw UnimplementedError();
  }

  @override
  // TODO: implement remoteId
  DeviceIdentifier get remoteId => throw UnimplementedError();

  @override
  Future<void> removeBond({int timeout = 30}) {
    // TODO: implement removeBond
    throw UnimplementedError();
  }

  @override
  Future<void> requestConnectionPriority({required ConnectionPriority connectionPriorityRequest}) {
    // TODO: implement requestConnectionPriority
    throw UnimplementedError();
  }

  @override
  Future<int> requestMtu(int desiredMtu, {double predelay = 0.35, int timeout = 15}) {
    // TODO: implement requestMtu
    throw UnimplementedError();
  }

  @override
  Stream<List<BluetoothService>> get services => Stream.value(_services);

  @override
  List<BluetoothService> get servicesList => _services;

  @override
  Stream<List<BluetoothService>> get servicesStream => Stream.value(_services);

  @override
  Future<void> setPreferredPhy({required int txPhy, required int rxPhy, required PhyCoding option}) {
    // TODO: implement setPreferredPhy
    throw UnimplementedError();
  }

  @override
  Stream<BluetoothConnectionState> get state => connectionState;

}

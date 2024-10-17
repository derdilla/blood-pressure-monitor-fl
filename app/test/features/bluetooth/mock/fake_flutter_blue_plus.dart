import 'dart:async';

import 'package:blood_pressure_app/features/bluetooth/backend/flutter_blue_plus/flutter_blue_plus_mockable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'fake_device.dart';

/// Wrapper for FlutterBluePlus in order to easily mock it
/// Wraps all calls for testing purposes
class FakeFlutterBluePlus extends FlutterBluePlusMockable {
  FakeFlutterBluePlus(): assert(kDebugMode);

  final BluetoothAdapterState _kFakeAdapterState = BluetoothAdapterState.on;
  final List<ScanResult> _kFakeScanResults = [
    ScanResult(
      device: FakeDevice(),
      advertisementData: FakeDevice().createFakeData(),
      rssi: 123,
      timeStamp: DateTime.now()
    )
  ];

  StreamController<List<ScanResult>> _fakeScanResultsEmiter = StreamController.broadcast();
  Timer? _fakeScanResultsEmitTimer;

  @override
  BluetoothAdapterState get adapterStateNow => BluetoothAdapterState.on;

  StreamController<bool> _isScanning = StreamController.broadcast();
  bool _scanningNow = false;

  @override
  Stream<bool> get isScanning => _isScanning.stream;

  @override
  bool get isScanningNow => _scanningNow;

  @override
  List<ScanResult> get lastScanResults => _kFakeScanResults;

  @override
  Stream<List<ScanResult>> get scanResults => _fakeScanResultsEmiter.stream;

  @override
  Stream<List<ScanResult>> get onScanResults => _fakeScanResultsEmiter.stream;

  @override
  BluetoothEvents get events => throw UnimplementedError();

  @override
  Stream<BluetoothAdapterState> get adapterState => Stream.value(_kFakeAdapterState);

  @override
  List<BluetoothDevice> get connectedDevices => throw UnimplementedError();

  @override
  Future<List<BluetoothDevice>> systemDevices(List<Guid> withServices) => throw UnimplementedError();

  @override
  Future<List<BluetoothDevice>> get bondedDevices => throw UnimplementedError();

  @override
  Future<void> setOptions({bool showPowerAlert = true,}) => throw UnimplementedError();

  @override
  Future<void> turnOn({int timeout = 60}) async {}

  @override
  Future<void> startScan({
    List<Guid> withServices = const [],
    List<String> withRemoteIds = const [],
    List<String> withNames = const [],
    List<String> withKeywords = const [],
    List<MsdFilter> withMsd = const [],
    List<ServiceDataFilter> withServiceData = const [],
    Duration? timeout,
    Duration? removeIfGone,
    bool continuousUpdates = false,
    int continuousDivisor = 1,
    bool oneByOne = false,
    AndroidScanMode androidScanMode = AndroidScanMode.lowLatency,
    bool androidUsesFineLocation = false,
  }) async {
    assert(_fakeScanResultsEmitTimer == null);
    _scanningNow = true;
    _fakeScanResultsEmitTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      _fakeScanResultsEmiter.add(_kFakeScanResults);
    });
  }

  @override
  Future<void> stopScan() async {
    _scanningNow = false;
    _fakeScanResultsEmitTimer!.cancel();
  }

  @override
  void cancelWhenScanComplete(StreamSubscription subscription) =>
      FlutterBluePlus.cancelWhenScanComplete(subscription); // TODO: figure out if useful


  @override
  Future<PhySupport> getPhySupport() => throw UnimplementedError();
}
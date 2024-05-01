import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BeforeScanning {
  late StreamSubscription<BluetoothAdapterState> _adapterStateStateSubscription;

  // Must be: `on`
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;

  init() {
    _adapterStateStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      setState(() {
        _adapterState = state;
      });
    });
  }

  dispose() {
    _adapterStateStateSubscription.cancel();
  }

  enableBluetooth() {
    try {
      if (Platform.isAndroid) {
        await FlutterBluePlus.turnOn();
      }
    } catch (e) {
      Snackbar.show(ABC.a, prettyException("Error Turning On:", e), success: false);
    }
  }
}

class ScanningPhase {
  List<BluetoothDevice> _systemDevices = [];
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  late StreamSubscription<bool> _isScanningSubscription;

  initState() {
    super.initState();

    _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
      _scanResults = results;
    }, onError: (e) {
      Snackbar.show(ABC.b, prettyException("Scan Error:", e), success: false);
    });

    _isScanningSubscription = FlutterBluePlus.isScanning.listen((state) {
      _isScanning = state;
    });
  }

  dispose() {
    _scanResultsSubscription.cancel();
    _isScanningSubscription.cancel();
    super.dispose();
  }

  onScanPressed() async {
    try {
      _systemDevices = await FlutterBluePlus.systemDevices;
    } catch (e) {
      Snackbar.show(ABC.b, prettyException("System Devices Error:", e), success: false);
    }
    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    } catch (e) {
      Snackbar.show(ABC.b, prettyException("Start Scan Error:", e), success: false);
    }
  }

  onStopPressed() async {
    try {
      FlutterBluePlus.stopScan();
    } catch (e) {
      Snackbar.show(ABC.b, prettyException("Stop Scan Error:", e), success: false);
    }
  }
}

class DeviceInfo {

  userInfo() {
    widget.result._device.platformName.isNotEmpty
        ? widget.result._device.platformName
        : widget.result._device.remoteId.str
  }

  bool get isConnectable => widget.result.advertisementData.connectable;

  connect() {
    _device.connectAndUpdateStream().catchError((e) {
      Snackbar.show(ABC.c, prettyException("Connect Error:", e), success: false);
    });
  }
}

class DeviceConnection {
  late StreamSubscription<BluetoothConnectionState> _connectionStateSubscription;
  late StreamSubscription<bool> _isConnectingSubscription;
  late StreamSubscription<bool> _isDisconnectingSubscription;
  late StreamSubscription<int> _mtuSubscription;

  // https://github.com/boskokg/flutter_blue_plus/blob/master/example/lib/screens/device_screen.dart
}
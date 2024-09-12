import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// Wrapper for FlutterBluePlus in order to easily mock it
/// Wraps all calls for testing purposes
class FlutterBluePlusMockable {
  LogLevel get logLevel => FlutterBluePlus.logLevel;

  /// Checks whether the hardware supports Bluetooth
  Future<bool> get isSupported => FlutterBluePlus.isSupported;

  /// The current adapter state
  BluetoothAdapterState get adapterStateNow => FlutterBluePlus.adapterStateNow;

  /// Return the friendly Bluetooth name of the local Bluetooth adapter
  Future<String> get adapterName => FlutterBluePlus.adapterName;

  /// returns whether we are scanning as a stream
  Stream<bool> get isScanning => FlutterBluePlus.isScanning;

  /// are we scanning right now?
  bool get isScanningNow => FlutterBluePlus.isScanningNow;

  /// the most recent scan results
  List<ScanResult> get lastScanResults => FlutterBluePlus.lastScanResults;

  /// a stream of scan results
  /// - if you re-listen to the stream it re-emits the previous results
  /// - the list contains all the results since the scan started
  /// - the returned stream is never closed.
  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;

  /// This is the same as scanResults, except:
  /// - it *does not* re-emit previous results after scanning stops.
  Stream<List<ScanResult>> get onScanResults => FlutterBluePlus.onScanResults;

  /// Get access to all device event streams
  BluetoothEvents get events => FlutterBluePlus.events;

  /// Gets the current state of the Bluetooth module
  Stream<BluetoothAdapterState> get adapterState =>
      FlutterBluePlus.adapterState;

  /// Retrieve a list of devices currently connected to your app
  List<BluetoothDevice> get connectedDevices =>
      FlutterBluePlus.connectedDevices;

  /// Retrieve a list of devices currently connected to the system
  /// - The list includes devices connected to by *any* app
  /// - You must still call device.connect() to connect them to *your app*
  Future<List<BluetoothDevice>> get systemDevices =>
      FlutterBluePlus.systemDevices;

  /// Retrieve a list of bonded devices (Android only)
  Future<List<BluetoothDevice>> get bondedDevices =>
      FlutterBluePlus.bondedDevices;

  /// Set configurable options
  ///   - [showPowerAlert] Whether to show the power alert (iOS & MacOS only). i.e. CBCentralManagerOptionShowPowerAlertKey
  ///       To set this option you must call this method before any other method in this package.
  ///       See: https://developer.apple.com/documentation/corebluetooth/cbcentralmanageroptionshowpoweralertkey
  ///       This option has no effect on Android.
  Future<void> setOptions({
    bool showPowerAlert = true,
  }) => FlutterBluePlus.setOptions(showPowerAlert: showPowerAlert);
  
  /// Turn on Bluetooth (Android only),
  Future<void> turnOn({int timeout = 60}) => 
      FlutterBluePlus.turnOn(timeout: timeout);

  /// Start a scan, and return a stream of results
  /// Note: scan filters use an "or" behavior. i.e. if you set `withServices` & `withNames` we
  /// return all the advertisments that match any of the specified services *or* any of the specified names.
  ///   - [withServices] filter by advertised services
  ///   - [withRemoteIds] filter for known remoteIds (iOS: 128-bit guid, android: 48-bit mac address)
  ///   - [withNames] filter by advertised names (exact match)
  ///   - [withKeywords] filter by advertised names (matches any substring)
  ///   - [withMsd] filter by manfacture specific data
  ///   - [withServiceData] filter by service data
  ///   - [timeout] calls stopScan after a specified duration
  ///   - [removeIfGone] if true, remove devices after they've stopped advertising for X duration
  ///   - [continuousUpdates] If `true`, we continually update 'lastSeen' & 'rssi' by processing
  ///        duplicate advertisements. This takes more power. You typically should not use this option.
  ///   - [continuousDivisor] Useful to help performance. If divisor is 3, then two-thirds of advertisements are
  ///        ignored, and one-third are processed. This reduces main-thread usage caused by the platform channel.
  ///        The scan counting is per-device so you always get the 1st advertisement from each device.
  ///        If divisor is 1, all advertisements are returned. This argument only matters for `continuousUpdates` mode.
  ///   - [oneByOne] if `true`, we will stream every advertistment one by one, possibly including duplicates.
  ///        If `false`, we deduplicate the advertisements, and return a list of devices.
  ///   - [androidScanMode] choose the android scan mode to use when scanning
  ///   - [androidUsesFineLocation] request `ACCESS_FINE_LOCATION` permission at runtime
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
  }) => FlutterBluePlus.startScan(
    withServices: withServices,
    withRemoteIds: withRemoteIds,
    withNames: withNames,
    withKeywords: withKeywords,
    withMsd: withMsd,
    withServiceData: withServiceData,
    timeout: timeout,
    removeIfGone: removeIfGone,
    continuousUpdates: continuousUpdates,
    continuousDivisor: continuousDivisor,
    oneByOne: oneByOne,
    androidScanMode: androidScanMode,
    androidUsesFineLocation: androidUsesFineLocation,
  );

  /// Stops a scan for Bluetooth Low Energy devices
  Future<void> stopScan() => FlutterBluePlus.stopScan();

  /// Register a subscription to be canceled when scanning is complete.
  /// This function simplifies cleanup, to prevent creating duplicate stream subscriptions.
  ///   - this is an optional convenience function
  ///   - prevents accidentally creating duplicate subscriptions before each scan
  void cancelWhenScanComplete(StreamSubscription subscription) =>
      FlutterBluePlus.cancelWhenScanComplete(subscription);

  /// Sets the internal FlutterBlue log level
  Future<void> setLogLevel(LogLevel level, {bool color = true}) =>
      FlutterBluePlus.setLogLevel(level, color: color);

  /// Request Bluetooth PHY support
  Future<PhySupport> getPhySupport() => FlutterBluePlus.getPhySupport();
}

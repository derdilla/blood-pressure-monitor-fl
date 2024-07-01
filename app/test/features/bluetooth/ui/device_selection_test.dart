import 'dart:ui';

import 'package:blood_pressure_app/features/bluetooth/ui/device_selection.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../util.dart';
@GenerateNiceMocks([
  MockSpec<BluetoothDevice>(),
  MockSpec<ScanResult>(),
])
import 'device_selection_test.mocks.dart';

void main() {
  testWidgets('Connects with one element', (WidgetTester tester) async {
    final dev = MockBluetoothDevice();
    when(dev.platformName).thenReturn('Test device with long name (No.124356)');

    final scanRes = MockScanResult();
    when(scanRes.device).thenReturn(dev);

    final List<BluetoothDevice> accepted = [];
    await tester.pumpWidget(materialApp(DeviceSelection(
      scanResults: [ scanRes ],
      onAccepted: accepted.add,
    )));

    expect(find.text('Test device with long name (No.124356)'), findsOneWidget);
    final localizations = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(localizations.connect), findsOneWidget);

    expect(accepted, isEmpty);
    await tester.tap(find.text(localizations.connect));
    expect(accepted.length, 1);
    expect(accepted, contains(dev));


    await tester.tap(find.text('Test device with long name (No.124356)'));
    expect(accepted.length, 2);
    expect(accepted, containsAllInOrder([dev, dev]));
  });

  testWidgets('Shows multiple elements', (WidgetTester tester) async {
    ScanResult getDev(String name) {
      final dev = MockBluetoothDevice();
      when(dev.platformName).thenReturn(name);

      final scanRes = MockScanResult();
      when(scanRes.device).thenReturn(dev);

      return scanRes;
    }

    await tester.pumpWidget(materialApp(DeviceSelection(
      scanResults: [
        getDev('dev1'),
        getDev('dev2'),
        getDev('dev3'),
      ],
      onAccepted: (dev) => fail('No entry tapped'),
    )));

    expect(find.text('dev1'), findsOneWidget);
    expect(find.text('dev2'), findsOneWidget);
    expect(find.text('dev3'), findsOneWidget);
    final localizations = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(localizations.connect), findsNWidgets(3));
  });
  // Inside ListView
}

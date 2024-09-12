import 'dart:ui';

import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_backend.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/mock/mock_manager.dart';
import 'package:blood_pressure_app/features/bluetooth/ui/device_selection.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../util.dart';

void main() {
  testWidgets('Connects with one element', (WidgetTester tester) async {
    final dev = MockBluetoothDevice(MockBluetoothManager(), 'Test device with long name (No.124356)');

    final List<BluetoothDevice> accepted = [];
    await tester.pumpWidget(materialApp(DeviceSelection(
      scanResults: [ dev ],
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
    BluetoothDevice getDev(String name) => MockBluetoothDevice(MockBluetoothManager(), name);

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

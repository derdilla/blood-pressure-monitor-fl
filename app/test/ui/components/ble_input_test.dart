import 'dart:typed_data';

import 'package:blood_pressure_app/components/ble_input/ble_input.dart';
import 'package:blood_pressure_app/components/ble_input/ble_input_bloc.dart';
import 'package:blood_pressure_app/components/ble_input/ble_input_events.dart';
import 'package:blood_pressure_app/components/ble_input/ble_input_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_test/flutter_test.dart';

import 'util.dart';

class _MockBlock extends Bloc<BleInputEvent, BleInputState> implements BleInputBloc {
  _MockBlock(super.initialState);
}

void main() {
  testWidgets('should display closed state', (tester) async {
    await tester.pumpWidget(materialApp(BleInput(bloc: _MockBlock(BleInputClosed()))));
    expect(find.byIcon(Icons.bluetooth), findsOneWidget);
    expect(find.byType(IconButton), findsOneWidget);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
  testWidgets('should display loaded state without devices', (tester) async {
    await tester.pumpWidget(materialApp(BleInput(bloc: _MockBlock(BleInputLoadSuccess([])))));
    final localizations = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(localizations.errBleNoDev), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
  testWidgets('should display loaded state with device', (tester) async {
    await tester.pumpWidget(materialApp(BleInput(bloc: _MockBlock(BleInputLoadSuccess([
      DiscoveredDevice(
        id: 'id',
        name: 'name',
        serviceData: const {},
        manufacturerData: Uint8List(2),
        rssi: 123,
        serviceUuids: [Uuid.parse('1810')],
        connectable: Connectable.available,
      ),
    ])))));
    expect(find.byType(ListView), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.text('name'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  // BleInputLoadSuccess([DiscoveredDevice(id: 'id', name: 'name', serviceData: {}, manufacturerData: Uint8List(2), rssi: 123, serviceUuids: [], connectable: Connectable.available)])
}

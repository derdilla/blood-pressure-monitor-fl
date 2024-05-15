
import 'dart:async';
import 'dart:ui';

import 'package:bloc_test/bloc_test.dart';
import 'package:blood_pressure_app/bluetooth/bluetooth_cubit.dart';
import 'package:blood_pressure_app/components/bluetooth_input/closed_bluetooth_input.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/widgets.dart';

class MockBluetoothCubit extends MockCubit<BluetoothState>
    implements BluetoothCubit {}

void main() {
  testWidgets('should show states correctly', (WidgetTester tester) async {
    final states = StreamController<BluetoothState>.broadcast();

    final cubit = MockBluetoothCubit();
    whenListen(cubit, states.stream, initialState: BluetoothInitial);

    int startCount = 0;
    await tester.pumpWidget(ClosedBluetoothInput(
      bluetoothCubit: cubit,
      onStarted: () {
        startCount++;
      }
    ));

    expect(find.byType(SizedBox), findsOneWidget);
    expect(find.byWidgetPredicate((widget) => true), findsOneWidget);


    states.sink.add(BluetoothUnfeasible());
    await tester.pump();
    expect(find.byType(SizedBox), findsOneWidget);
    expect(find.byWidgetPredicate((widget) => true), findsOneWidget);

    await tester.tap(find.byType(ClosedBluetoothInput));
    expect(startCount, 0);


    states.sink.add(BluetoothUnauthorized());
    await tester.pump();
    final localizations = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(localizations.errBleNoPerms), findsOneWidget);

    await tester.tap(find.byType(ClosedBluetoothInput));
    expect(startCount, 0);


    states.sink.add(BluetoothDisabled());
    await tester.pump();
    expect(find.text(localizations.bluetoothDisabled), findsOneWidget);

    await tester.tap(find.byType(ClosedBluetoothInput));
    expect(startCount, 0);


    states.sink.add(BluetoothDisabled());
    await tester.pump();
    expect(find.text(localizations.bluetoothInput), findsOneWidget);

    await tester.tap(find.byType(ClosedBluetoothInput));
    expect(startCount, 1);
  });
}

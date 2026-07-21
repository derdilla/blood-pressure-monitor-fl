import 'package:blood_pressure_app/features/input/forms/add_entry_form.dart';
import 'package:blood_pressure_app/features/input/forms/add_multiple_entries_form.dart';
import 'package:blood_pressure_app/l10n/app_localizations.dart';
import 'package:blood_pressure_app/model/bluetooth_input_mode.dart';
import 'package:blood_pressure_app/model/combined_entry.dart';
import 'package:blood_pressure_app/model/storage/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../model/blood_pressure_analyzer_test.dart';
import '../../../util.dart';

void main() {
  testWidgets("doesn't update time from ble if setting isn't set", (tester) async {
    final key = GlobalKey<AddMultipleEntriesFormState>();
    final initialTime = DateTime.now();

    await tester.pumpWidget(appBase(AddMultipleEntriesForm(key: key,
      initialValue: [CombinedEntry(time: initialTime)],
      mockBleInput: (callback) => ListTile(
        onTap: () => callback([mockRecord(time: DateTime(2000))]),
        title: Text('mockBleInput'),
      ),
    ),
      settings: Settings(
        bleInput: BluetoothInputMode.disabled,
        trustBLETime: false,
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('mockBleInput'));
    final returnedEntry = key.currentState!.save();
    expect(returnedEntry!.first.time.isAfter(DateTime(2000)), isTrue);
    expect(returnedEntry.first.time, initialTime);

    // also check if the hint dialog isn't incorrectly displayed
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('updates time from ble if setting is set', (tester) async {
    final key = GlobalKey<AddMultipleEntriesFormState>();
    final initialTime = DateTime.now();

    await tester.pumpWidget(appBase(AddMultipleEntriesForm(key: key,
      initialValue: [CombinedEntry(time: initialTime)],
      mockBleInput: (callback) => ListTile(
        onTap: () => callback([mockRecord(time: DateTime(2000))]),
        title: Text('mockBleInput'),
      ),
    ),
      settings: Settings(
        bleInput: BluetoothInputMode.disabled,
        trustBLETime: true,
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('mockBleInput'));
    final returnedEntry = key.currentState!.save();
    expect(returnedEntry!.first.time, equals(DateTime(2000)));
  });

  testWidgets('shows warning if time from ble is too old', (tester) async {
    final localizations = await AppLocalizations.delegate.load(const Locale('en'));
    await tester.pumpWidget(appBase(AddMultipleEntriesForm(
      mockBleInput: (callback) => ListTile(
        onTap: () => callback([mockRecord(time: DateTime(2000))]),
        title: Text('mockBleInput'),
      ),
    ),
      settings: Settings(
        bleInput: BluetoothInputMode.disabled,
        trustBLETime: true,
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    await tester.tap(find.text('mockBleInput'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.textContaining('The bluetooth device reported a time off by'), findsOneWidget);
    expect(find.text(localizations.btnConfirm), findsOneWidget);

    await tester.tap(find.text(localizations.btnConfirm));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);

    // reopens the next time
    await tester.tap(find.text('mockBleInput'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
  });

  testWidgets('allows disabling warning if time from ble is too old', (tester) async {
    final localizations = await AppLocalizations.delegate.load(const Locale('en'));
    await tester.pumpWidget(appBase(AddMultipleEntriesForm(
      mockBleInput: (callback) => ListTile(
        onTap: () => callback([mockRecord(time: DateTime(2000))]),
        title: Text('mockBleInput'),
      ),
    ),
      settings: Settings(
        bleInput: BluetoothInputMode.disabled,
        trustBLETime: true,
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    await tester.tap(find.text('mockBleInput'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.textContaining('The bluetooth device reported a time off by'), findsOneWidget);
    expect(find.text(localizations.dontShowAgain), findsOneWidget);

    await tester.tap(find.text(localizations.dontShowAgain));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    await tester.tap(find.text('mockBleInput'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('entering multiple measurements displays list', (tester) async {
    final key = GlobalKey<AddMultipleEntriesFormState>();
    final testMeasurements = [
      mockRecord(time: DateTime(2000), sys: 123),
      mockRecord(time: DateTime(2001), sys: 234),
      mockRecord(time: DateTime(2002), sys: 345),
    ];
    await tester.pumpWidget(appBase(AddMultipleEntriesForm(
      key: key,
      mockBleInput: (callback) => ListTile(
        onTap: () => callback(testMeasurements),
        title: Text('mockBleInput'),
      ),
    ),
      settings: Settings(
        bleInput: BluetoothInputMode.disabled,
        trustBLETime: true,
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(AddEntryForm), findsOneWidget);
    expect(find.text('234'), findsNothing);

    await tester.tap(find.text('mockBleInput'));
    await tester.pumpAndSettle();

    expect(find.text('mockBleInput'), findsNothing);
    expect(find.byType(AddEntryForm), findsNothing);
    expect(find.text('234'), findsOneWidget);

    final returnedEntry = key.currentState!.save();
    expect(returnedEntry?.length, testMeasurements.length);
    expect(returnedEntry?.map((e) => e.record), equals(testMeasurements));
  });

}

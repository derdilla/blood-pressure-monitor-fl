import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:blood_pressure_app/model/ram_only_implementations.dart';
import 'package:blood_pressure_app/model/settings_store.dart';
import 'package:blood_pressure_app/screens/add_measurement.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  group("Add measurements page", () {
    group('normal mode', () {
      testWidgets('smoke test', (tester) async {
        await _initPage(tester, const AddMeasurementPage());
        expect(find.text('Systolic'), findsOneWidget);
        expect(find.text('SAVE'), findsOneWidget);
      });
      testWidgets('should start empty', (tester) async {
        await _initPage(tester, const AddMeasurementPage());
        final sysInput = tester.widget<TextFormField>(
            find.descendant(of: find.byKey(const Key('txtSys')), matching: find.byType(TextFormField)));
        expect(sysInput.initialValue, '');
        final diaInput = tester.widget<TextFormField>(
            find.descendant(of: find.byKey(const Key('txtDia')), matching: find.byType(TextFormField)));
        expect(diaInput.initialValue, '');
        final pulInput = tester.widget<TextFormField>(
            find.descendant(of: find.byKey(const Key('txtPul')), matching: find.byType(TextFormField)));
        expect(pulInput.initialValue, '');
        final noteInput = tester.widget<TextFormField>(find.byKey(const Key('txtNote')));
        expect(noteInput.initialValue, '');
      });
    });
    group('edit mode', () {
      testWidgets('smoke test', (tester) async {
        final record = BloodPressureRecord(DateTime.now(), 123, 89, 56, 'simple test note');
        await _initPage(tester, AddMeasurementPage.edit(record),
            model: RamBloodPressureModel.fromEntries([record])
        );
        expect(find.text('Systolic'), findsOneWidget);
        expect(find.text('SAVE'), findsOneWidget);
      });
      testWidgets('should prefill', (tester) async {
        final record = BloodPressureRecord(DateTime.now(), 123, 89, 56, 'simple test note');
        await _initPage(tester, AddMeasurementPage.edit(record),
            model: RamBloodPressureModel.fromEntries([record])
        );

        final sysInput = tester.widget<TextFormField>(
            find.descendant(of: find.byKey(const Key('txtSys')), matching: find.byType(TextFormField)));
        expect(sysInput.initialValue, record.systolic.toString());
        final diaInput = tester.widget<TextFormField>(
            find.descendant(of: find.byKey(const Key('txtDia')), matching: find.byType(TextFormField)));
        expect(diaInput.initialValue, record.diastolic.toString());
        final pulInput = tester.widget<TextFormField>(
            find.descendant(of: find.byKey(const Key('txtPul')), matching: find.byType(TextFormField)));
        expect(pulInput.initialValue, record.pulse.toString());
        final noteInput = tester.widget<TextFormField>(find.byKey(const Key('txtNote')));
        expect(noteInput.initialValue, record.notes);
      });
      testWidgets('should not delete on cancel', (tester) async {
        final record = BloodPressureRecord(DateTime.now(), 123, 89, 56, 'simple test note');
        final model = RamBloodPressureModel.fromEntries([record]);
        await _initPage(tester, AddMeasurementPage.edit(record), model: model);
        expect((await model.all).first, record);

        expect(find.byKey(const Key ('txtNote')), findsOneWidget);
        await tester.enterText(find.byKey(const Key ('txtNote')), 'edited text');

        expect(find.byKey(const Key('btnCancel')), findsOneWidget);
        await tester.tap(find.byKey(const Key('btnCancel')));
        await tester.pumpAndSettle();
        expect((await model.all).first.notes, 'simple test note');
        expect((await model.all).first, record);
      });
      testWidgets('should save changes', (tester) async {
        final record = BloodPressureRecord(DateTime.now(), 123, 89, 56, 'simple test note');
        final model = RamBloodPressureModel.fromEntries([record]);
        await _initPage(tester, AddMeasurementPage.edit(record), model: model);
        expect((await model.all).first, record);

        expect(find.byKey(const Key ('txtNote')), findsOneWidget);
        await tester.enterText(find.byKey(const Key ('txtNote')), 'edited text');

        expect(find.byKey(const Key('btnSave')), findsOneWidget);
        await tester.tap(find.byKey(const Key('btnSave')));
        await tester.pumpAndSettle();
        expect((await model.all).first.notes, 'edited text');
      });
    });
  });
}

Future<void> _initPage(WidgetTester widgetTester, Widget pageWidget, {Settings? settings, BloodPressureModel? model}) async {
  await widgetTester.pumpWidget(
    MaterialApp(
      home: MultiProvider(
          providers: [
            ChangeNotifierProvider<Settings>(create: (_) => settings ?? RamSettings()),
            ChangeNotifierProvider<BloodPressureModel>(create: (_) => model ?? RamBloodPressureModel()),
          ],
          child: Localizations(
            delegates: AppLocalizations.localizationsDelegates,
            locale: const Locale('en'),
            child: pageWidget,
          )
      )
    ),
  );

  await widgetTester.pumpAndSettle();
}


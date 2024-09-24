import 'package:blood_pressure_app/features/input/add_bodyweight_dialoge.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:blood_pressure_app/model/weight_unit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_data_store/health_data_store.dart';

import '../../util.dart';

void main() {
  testWidgets('shows weight input weight', (tester) async {
    await tester.pumpWidget(materialApp(const AddBodyweightDialoge()));
    final localizations = await AppLocalizations.delegate.load(const Locale('en'));

    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.text(localizations.weight), findsOneWidget);
    expect(find.text('kg'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), '123.45');
  });
  testWidgets('error on invalid input', (tester) async {
    await tester.pumpWidget(materialApp(const AddBodyweightDialoge()));
    final localizations = await AppLocalizations.delegate.load(const Locale('en'));

    expect(find.text(localizations.errNaN), findsNothing);

    await tester.enterText(find.byType(TextFormField), 'invalid input');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.text(localizations.errNaN), findsOneWidget);
  });
  testWidgets('creates weight from input', (tester) async {
    Weight? res;
    await tester.pumpWidget(materialApp(Builder(
      builder: (context) => GestureDetector(
        onTap: () async => res = await showDialog<Weight>(context: context, builder: (_) => const AddBodyweightDialoge()),
        child: const Text('X'),
      ),
    )));
    await tester.tap(find.text('X'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), '123.45');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(res, Weight.kg(123.45));
  });
  testWidgets('respects preferred weight unit', (tester) async {
    Weight? res;
    await tester.pumpWidget(materialApp(Builder(
      builder: (context) => GestureDetector(
        onTap: () async => res = await showDialog<Weight>(context: context, builder: (_) => const AddBodyweightDialoge()),
        child: const Text('X'),
      ),
    ), settings: Settings(weightUnit: WeightUnit.st)));
    await tester.tap(find.text('X'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), '123.45');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(res, WeightUnit.st.store(123.45));
  });
}

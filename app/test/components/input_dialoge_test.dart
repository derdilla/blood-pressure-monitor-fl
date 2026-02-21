import 'package:blood_pressure_app/components/input_dialoge.dart';
import 'package:blood_pressure_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../util.dart';

void main() {
  group('InputDialoge', () {
    testWidgets('should initialize without errors', (tester) async {
      await tester.pumpWidget(materialApp(const InputDialoge()));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const MaterialApp(
          localizationsDelegates: [AppLocalizations.delegate,], locale: Locale('en'),
          home: InputDialoge(
            hintText: 'test hint',
            initialValue: 'initial text',
          ),
      ),);
      expect(tester.takeException(), isNull);
      expect(find.byType(InputDialoge), findsOneWidget);
    });
    testWidgets('should show prefilled text', (tester) async {
      await tester.pumpWidget(materialApp(const InputDialoge(
        hintText: 'test hint',
        initialValue: 'initial text',
      ),),);
      expect(find.text('initial text'), findsOneWidget);
      expect(find.text('test hint'), findsNWidgets(2));
    });
    testWidgets('should show validator errors', (tester) async {
      await tester.pumpWidget(materialApp(InputDialoge(
        initialValue: 'initial text',
        validator: (_) => 'test error',
      ),),);
      final localizations = await AppLocalizations.delegate.load(const Locale('en'));

      expect(find.text(localizations.btnConfirm), findsOneWidget);
      await tester.tap(find.text(localizations.btnConfirm));
      await tester.pumpAndSettle();

      expect(find.byType(InputDialoge), findsOneWidget);
      expect(find.text('test error'), findsOneWidget);
    });
    testWidgets('should send current text to validator', (tester) async {
      int validatorCalls = 0;
      await tester.pumpWidget(materialApp(InputDialoge(
        initialValue: 'initial text',
        validator: (value) {
          expect(value, 'initial text');
          validatorCalls += 1;
          return null;
        },
      ),),);
      final localizations = await AppLocalizations.delegate.load(const Locale('en'));

      expect(validatorCalls, 0);

      expect(find.text(localizations.btnConfirm), findsOneWidget);
      await tester.tap(find.text(localizations.btnConfirm));
      await tester.pumpAndSettle();

      expect(validatorCalls, 1);

      expect(find.byType(InputDialoge), findsNothing);
    });
  });
  group('showInputDialoge', () {
    testWidgets('should start with input focused', (tester) async {
      await loadDialoge(tester, (context) => showInputDialoge(context, initialValue: 'testval'));

      expect(find.byType(InputDialoge), findsOneWidget);
      final primaryFocus = FocusManager.instance.primaryFocus;
      expect(primaryFocus?.context?.widget, isNotNull);
      final focusedTextField = find.ancestor(
        of: find.byWidget(primaryFocus!.context!.widget),
        matching: find.byType(TextField),
      );
      expect(find.descendant(of: focusedTextField, matching: find.text('testval')), findsOneWidget);
    });
    testWidgets('should allow entering a value', (tester) async {
      String? result = 'init';
      await loadDialoge(tester, (context) async => result = await showInputDialoge(context));
      final localizations = await AppLocalizations.delegate.load(const Locale('en'));

      expect(find.byType(InputDialoge), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'inputted text');
      expect(find.text(localizations.btnConfirm), findsOneWidget);
      await tester.tap(find.text(localizations.btnConfirm));
      await tester.pumpAndSettle();

      expect(result, 'inputted text');
    });
    testWidgets('should not return value on cancel', (tester) async {
      String? result = 'init';
      await loadDialoge(tester, (context) async => result = await showInputDialoge(context, initialValue: 'test'));
      final localizations = await AppLocalizations.delegate.load(const Locale('en'));

      expect(find.byType(InputDialoge), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'inputted text');
      expect(find.text(localizations.btnCancel), findsOneWidget);
      await tester.tap(find.text(localizations.btnCancel));
      await tester.pumpAndSettle();

      expect(result, null);
    });
  });
  group('showNumberInputDialoge', () {
    testWidgets('should start with input focused', (tester) async {
      await loadDialoge(tester, (context) => showNumberInputDialoge(context, initialValue: 123));

      expect(find.byType(InputDialoge), findsOneWidget);
      expect(find.text('123'), findsOneWidget);

      final primaryFocus = FocusManager.instance.primaryFocus;
      expect(primaryFocus?.context?.widget, isNotNull);
      final focusedTextField = find.ancestor(
        of: find.byWidget(primaryFocus!.context!.widget),
        matching: find.byType(TextField),
      );
      expect(find.descendant(of: focusedTextField, matching: find.text('123')), findsOneWidget);
    });
    testWidgets('should allow entering a number', (tester) async {
      double? result = -1;
      await loadDialoge(tester, (context) async => result = await showNumberInputDialoge(context));
      final localizations = await AppLocalizations.delegate.load(const Locale('en'));

      expect(find.byType(InputDialoge), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      await tester.enterText(find.byType(TextField), '123.76');
      expect(find.text(localizations.btnConfirm), findsOneWidget);
      await tester.tap(find.text(localizations.btnConfirm));
      await tester.pumpAndSettle();

      expect(result, 123.76);
    });
    testWidgets('should not allow entering text', (tester) async {
      double? result = -1;
      await loadDialoge(tester, (context) async => result = await showNumberInputDialoge(context));
      final localizations = await AppLocalizations.delegate.load(const Locale('en'));

      expect(find.byType(InputDialoge), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'test');
      expect(find.text(localizations.btnConfirm), findsOneWidget);
      await tester.tap(find.text(localizations.btnConfirm));
      await tester.pumpAndSettle();

      expect(find.byType(InputDialoge), findsOneWidget); // unclosable through confirm
      expect(find.text(localizations.errNaN), findsOneWidget);

      expect(find.text(localizations.btnCancel), findsOneWidget);
      await tester.tap(find.text(localizations.btnCancel));
      await tester.pumpAndSettle();

      expect(result, null);
    });
  });
}

import 'package:blood_pressure_app/components/dialogues/input_dialogue.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'util.dart';

void main() {
  group('InputDialogue', () {
    testWidgets('should initialize without errors', (widgetTester) async {
      await widgetTester.pumpWidget(materialApp(const InputDialogue()));
      expect(widgetTester.takeException(), isNull);
      await widgetTester.pumpWidget(const MaterialApp(
          localizationsDelegates: [AppLocalizations.delegate,], locale: Locale('en'),
          home: InputDialogue(
            hintText: 'test hint',
            initialValue: 'initial text',
          )
      ));
      expect(widgetTester.takeException(), isNull);
      expect(find.byType(InputDialogue), findsOneWidget);
    });
    testWidgets('should show prefilled text', (widgetTester) async {
      await widgetTester.pumpWidget(materialApp(const InputDialogue(
        hintText: 'test hint',
        initialValue: 'initial text',
      )));
      expect(find.text('initial text'), findsOneWidget);
      expect(find.text('test hint'), findsNWidgets(2));
    });
    testWidgets('should show validator errors', (widgetTester) async {
      await widgetTester.pumpWidget(materialApp(InputDialogue(
        initialValue: 'initial text',
        validator: (_) => 'test error',
      )));
      final localizations = await AppLocalizations.delegate.load(const Locale('en'));

      expect(find.text(localizations.btnConfirm), findsOneWidget);
      await widgetTester.tap(find.text(localizations.btnConfirm));
      await widgetTester.pumpAndSettle();

      expect(find.byType(InputDialogue), findsOneWidget);
      expect(find.text('test error'), findsOneWidget);
    });
    testWidgets('should send current text to validator', (widgetTester) async {
      int validatorCalls = 0;
      await widgetTester.pumpWidget(materialApp(InputDialogue(
        initialValue: 'initial text',
        validator: (value) {
          expect(value, 'initial text');
          validatorCalls += 1;
          return null;
        },
      )));
      final localizations = await AppLocalizations.delegate.load(const Locale('en'));

      expect(validatorCalls, 0);

      expect(find.text(localizations.btnConfirm), findsOneWidget);
      await widgetTester.tap(find.text(localizations.btnConfirm));
      await widgetTester.pumpAndSettle();

      expect(validatorCalls, 1);

      expect(find.byType(InputDialogue), findsNothing);
    });
  });
  group('showInputDialogue', () {
    testWidgets('should start with input focused', (widgetTester) async {
      await loadDialogue(widgetTester, (context) => showInputDialogue(context, initialValue: 'testval'));

      expect(find.byType(InputDialogue), findsOneWidget);
      final primaryFocus = FocusManager.instance.primaryFocus;
      expect(primaryFocus?.context?.widget, isNotNull);
      final focusedTextField = find.ancestor(
        of: find.byWidget(primaryFocus!.context!.widget),
        matching: find.byType(TextField),
      );
      expect(find.descendant(of: focusedTextField, matching: find.text('testval')), findsOneWidget);
    });
    testWidgets('should allow entering a value', (widgetTester) async {
      String? result = 'init';
      await loadDialogue(widgetTester, (context) async => result = await showInputDialogue(context));
      final localizations = await AppLocalizations.delegate.load(const Locale('en'));

      expect(find.byType(InputDialogue), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      await widgetTester.enterText(find.byType(TextField), 'inputted text');
      expect(find.text(localizations.btnConfirm), findsOneWidget);
      await widgetTester.tap(find.text(localizations.btnConfirm));
      await widgetTester.pumpAndSettle();

      expect(result, 'inputted text');
    });
    testWidgets('should not return value on cancel', (widgetTester) async {
      String? result = 'init';
      await loadDialogue(widgetTester, (context) async => result = await showInputDialogue(context, initialValue: 'test'));
      final localizations = await AppLocalizations.delegate.load(const Locale('en'));

      expect(find.byType(InputDialogue), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      await widgetTester.enterText(find.byType(TextField), 'inputted text');
      expect(find.text(localizations.btnCancel), findsOneWidget);
      await widgetTester.tap(find.text(localizations.btnCancel));
      await widgetTester.pumpAndSettle();

      expect(result, null);
    });
  });
  group('showNumberInputDialogue', () {
    testWidgets('should start with input focused', (widgetTester) async {
      await loadDialogue(widgetTester, (context) => showNumberInputDialogue(context, initialValue: 123));

      expect(find.byType(InputDialogue), findsOneWidget);
      expect(find.text('123'), findsOneWidget);

      final primaryFocus = FocusManager.instance.primaryFocus;
      expect(primaryFocus?.context?.widget, isNotNull);
      final focusedTextField = find.ancestor(
        of: find.byWidget(primaryFocus!.context!.widget),
        matching: find.byType(TextField),
      );
      expect(find.descendant(of: focusedTextField, matching: find.text('123')), findsOneWidget);
    });
    testWidgets('should allow entering a number', (widgetTester) async {
      double? result = -1;
      await loadDialogue(widgetTester, (context) async => result = await showNumberInputDialogue(context));
      final localizations = await AppLocalizations.delegate.load(const Locale('en'));

      expect(find.byType(InputDialogue), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      await widgetTester.enterText(find.byType(TextField), '123.76');
      expect(find.text(localizations.btnConfirm), findsOneWidget);
      await widgetTester.tap(find.text(localizations.btnConfirm));
      await widgetTester.pumpAndSettle();

      expect(result, 123.76);
    });
    testWidgets('should not allow entering text', (widgetTester) async {
      double? result = -1;
      await loadDialogue(widgetTester, (context) async => result = await showNumberInputDialogue(context));
      final localizations = await AppLocalizations.delegate.load(const Locale('en'));

      expect(find.byType(InputDialogue), findsOneWidget);

      await widgetTester.enterText(find.byType(TextField), 'test');
      expect(find.text(localizations.btnConfirm), findsOneWidget);
      await widgetTester.tap(find.text(localizations.btnConfirm));
      await widgetTester.pumpAndSettle();

      expect(find.byType(InputDialogue), findsOneWidget); // unclosable through confirm
      expect(find.text(localizations.errNaN), findsOneWidget);

      expect(find.text(localizations.btnCancel), findsOneWidget);
      await widgetTester.tap(find.text(localizations.btnCancel));
      await widgetTester.pumpAndSettle();

      expect(result, null);
    });
  });
}
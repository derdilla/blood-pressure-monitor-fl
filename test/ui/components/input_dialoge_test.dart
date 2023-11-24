import 'package:blood_pressure_app/components/dialoges/input_dialoge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InputDialoge', () {
    testWidgets('should initialize without errors', (widgetTester) async {
      await widgetTester.pumpWidget(const MaterialApp(
          localizationsDelegates: [AppLocalizations.delegate,],
          locale: Locale('en'),
          home: InputDialoge()
      ));
      expect(widgetTester.takeException(), isNull);
      await widgetTester.pumpWidget(const MaterialApp(
          localizationsDelegates: [AppLocalizations.delegate,], locale: Locale('en'),
          home: InputDialoge(
            hintText: 'test hint',
            initialValue: 'initial text',
          )
      ));
      expect(widgetTester.takeException(), isNull);
      expect(find.byType(InputDialoge), findsOneWidget);
    });
    testWidgets('should show prefilled text', (widgetTester) async {
      await widgetTester.pumpWidget(const MaterialApp(
          localizationsDelegates: [AppLocalizations.delegate,], locale: Locale('en'),
          home: InputDialoge(
            hintText: 'test hint',
            initialValue: 'initial text',
          )
      ));
      expect(find.text('initial text'), findsOneWidget);
      expect(find.text('test hint'), findsNWidgets(2));
    });
  });
  group('showInputDialoge', () {
    testWidgets('should start with input focused', (widgetTester) async {
      await widgetTester.pumpWidget(MaterialApp(
          localizationsDelegates: const [AppLocalizations.delegate,], locale: const Locale('en'),
          home: Builder(builder: (BuildContext context) => TextButton(onPressed:
              () => showInputDialoge(context, initialValue: 'testval'), child: const Text('X')))
      ));
      await widgetTester.tap(find.text('X'));
      await widgetTester.pumpAndSettle();

      expect(find.byType(InputDialoge), findsOneWidget);
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
      await widgetTester.pumpWidget(MaterialApp(
          localizationsDelegates: const [AppLocalizations.delegate,], locale: const Locale('en'),
          home: Builder(builder: (BuildContext context) => TextButton(onPressed:
              () async {
                result = await showInputDialoge(context);
              }, child: const Text('X')))
      ));
      final localizations = await AppLocalizations.delegate.load(const Locale('en'));
      await widgetTester.tap(find.text('X'));
      await widgetTester.pumpAndSettle();

      expect(find.byType(InputDialoge), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      await widgetTester.enterText(find.byType(TextField), 'inputted text');
      expect(find.text(localizations.btnConfirm), findsOneWidget);
      await widgetTester.tap(find.text(localizations.btnConfirm));
      await widgetTester.pumpAndSettle();

      expect(result, 'inputted text');
    });
    testWidgets('should not return value on cancel', (widgetTester) async {
      String? result = 'init';
      await widgetTester.pumpWidget(MaterialApp(
          localizationsDelegates: const [AppLocalizations.delegate,], locale: const Locale('en'),
          home: Builder(builder: (BuildContext context) => TextButton(onPressed:
              () async {
            result = await showInputDialoge(context, initialValue: 'test');
          }, child: const Text('X')))
      ));
      final localizations = await AppLocalizations.delegate.load(const Locale('en'));
      await widgetTester.tap(find.text('X'));
      await widgetTester.pumpAndSettle();

      expect(find.byType(InputDialoge), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      await widgetTester.enterText(find.byType(TextField), 'inputted text');
      expect(find.text(localizations.btnCancel), findsOneWidget);
      await widgetTester.tap(find.text(localizations.btnCancel));
      await widgetTester.pumpAndSettle();

      expect(result, null);
    });
  });
  group('showNumberInputDialoge', () {
    testWidgets('should start with input focused', (widgetTester) async {
      await widgetTester.pumpWidget(MaterialApp(
          localizationsDelegates: const [AppLocalizations.delegate,], locale: const Locale('en'),
          home: Builder(builder: (BuildContext context) => TextButton(onPressed:
              () => showNumberInputDialoge(context, initialValue: 123), child: const Text('X')))
      ));
      await widgetTester.tap(find.text('X'));
      await widgetTester.pumpAndSettle();

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
    testWidgets('should allow entering a number', (widgetTester) async {
      double? result = -1;
      await widgetTester.pumpWidget(MaterialApp(
          localizationsDelegates: const [AppLocalizations.delegate,], locale: const Locale('en'),
          home: Builder(builder: (BuildContext context) => TextButton(onPressed:
              () async {
            result = await showNumberInputDialoge(context);
          }, child: const Text('X')))
      ));
      final localizations = await AppLocalizations.delegate.load(const Locale('en'));
      await widgetTester.tap(find.text('X'));
      await widgetTester.pumpAndSettle();

      expect(find.byType(InputDialoge), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      await widgetTester.enterText(find.byType(TextField), '123.76');
      expect(find.text(localizations.btnConfirm), findsOneWidget);
      await widgetTester.tap(find.text(localizations.btnConfirm));
      await widgetTester.pumpAndSettle();

      expect(result, 123.76);
    });
    testWidgets('should not allow entering text', (widgetTester) async {
      double? result = -1;
      await widgetTester.pumpWidget(MaterialApp(
          localizationsDelegates: const [AppLocalizations.delegate,], locale: const Locale('en'),
          home: Builder(builder: (BuildContext context) => TextButton(onPressed:
              () async {
            result = await showNumberInputDialoge(context);
          }, child: const Text('X')))
      ));
      final localizations = await AppLocalizations.delegate.load(const Locale('en'));
      await widgetTester.tap(find.text('X'));
      await widgetTester.pumpAndSettle();

      expect(find.byType(InputDialoge), findsOneWidget);

      await widgetTester.enterText(find.byType(TextField), 'test');
      expect(find.text(localizations.btnConfirm), findsOneWidget);
      await widgetTester.tap(find.text(localizations.btnConfirm));
      await widgetTester.pumpAndSettle();

      expect(find.byType(InputDialoge), findsOneWidget); // unclosable through confirm
      expect(find.text(localizations.errNaN), findsOneWidget);

      expect(find.text(localizations.btnCancel), findsOneWidget);
      await widgetTester.tap(find.text(localizations.btnCancel));
      await widgetTester.pumpAndSettle();

      expect(result, null);
    });
  });
}
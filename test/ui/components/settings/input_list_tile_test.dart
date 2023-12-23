import 'package:blood_pressure_app/components/dialoges/input_dialoge.dart';
import 'package:blood_pressure_app/components/settings/input_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InputListTile', () {
    testWidgets('should show fields', (widgetTester) async {
      await widgetTester.pumpWidget(_materialApp(InputListTile(
        label: 'test title',
        value: 'initial',
        onSubmit: (String newValue) {
          assert(false, 'should not be called');
        },
      )));
      expect(widgetTester.takeException(), isNull);
      expect(find.text('test title'), findsOneWidget);
      expect(find.text('initial'), findsOneWidget);
    });
    testWidgets('should allow canceling edit', (widgetTester) async {
      await widgetTester.pumpWidget(_materialApp(InputListTile(
        label: 'test title',
        value: 'initial',
        onSubmit: (String newValue) {
          assert(false, 'should not be called');
        },
      )));

      expect(find.byType(InputDialoge), findsNothing);
      await widgetTester.tap(find.byType(InputListTile));
      await widgetTester.pumpAndSettle();

      expect(find.byType(InputDialoge), findsOneWidget);
      await widgetTester.tapAt(const Offset(0, 0));
      await widgetTester.pumpAndSettle();

      expect(find.byType(InputDialoge), findsNothing);
    });
    testWidgets('should prefill value on edit', (widgetTester) async {
      await widgetTester.pumpWidget(_materialApp(InputListTile(
        label: 'test title',
        value: 'initial',
        onSubmit: (String newValue) {
          assert(false, 'should not be called');
        },
      )));

      expect(find.text('initial'), findsOneWidget);
      await widgetTester.tap(find.byType(InputListTile));
      await widgetTester.pumpAndSettle();

      expect(find.text('initial'), findsNWidgets(2));
    });
    testWidgets('should allow editing values', (widgetTester) async {
      int callCount = 0;
      await widgetTester.pumpWidget(_materialApp(InputListTile(
        label: 'test title',
        value: 'initial',
        onSubmit: (String newValue) {
          callCount += 1;
          expect(newValue, 'changed');
        },
      )));

      expect(find.text('initial'), findsOneWidget);
      await widgetTester.tap(find.byType(InputListTile));
      await widgetTester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      await widgetTester.enterText(find.byType(TextField), 'changed');
      await widgetTester.tap(find.text('OK'));
      await widgetTester.pumpAndSettle();

      expect(find.byType(InputDialoge), findsNothing);
      expect(callCount, 1);
    });
  });
}

Widget _materialApp(Widget child) {
  return MaterialApp(
    localizationsDelegates: const [AppLocalizations.delegate,],
    locale: const Locale('en'),
    home: Scaffold(body:child),
  );
}
import 'package:blood_pressure_app/components/dialoges/enter_timeformat_dialoge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'util.dart';

void main() {
  group('EnterTimeFormatDialoge', () {
    testWidgets('should initialize without errors', (widgetTester) async {
      await widgetTester.pumpWidget(materialApp(const EnterTimeFormatDialoge(initialValue: 'yyyy-MM-dd HH:mm',)));
      expect(widgetTester.takeException(), isNull);
      expect(find.byType(EnterTimeFormatDialoge), findsOneWidget);
    });
    testWidgets('should prefill time format', (widgetTester) async {
      await widgetTester.pumpWidget(materialApp( const EnterTimeFormatDialoge(initialValue: 'yyyy-MM-dd HH:mm',)));
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);
      expect(find.descendant(of: textField, matching: find.text('yyyy-MM-dd HH:mm')), findsOneWidget);
    });
    testWidgets('should show preview', (widgetTester) async {
      await widgetTester.pumpWidget(materialApp(EnterTimeFormatDialoge(
          initialValue: 'yyyy-MM-dd HH:mm',
          previewTime: DateTime(2023, 7, 23, 8, 20),
        ),
      ),);
      expect(find.text('2023-07-23 08:20'), findsOneWidget);
      
      // other time formats
      expect(find.byType(TextField), findsOneWidget);
      await widgetTester.enterText(find.byType(TextField), 'QQQQ + LLLL');
      await widgetTester.pumpAndSettle();
      expect(find.text('3rd quarter + July'), findsOneWidget);
    });
    testWidgets('should close page on close button pressed', (widgetTester) async {
      await widgetTester.pumpWidget(materialApp(const EnterTimeFormatDialoge(initialValue: 'yyyy-MM-dd HH:mm',)));

      expect(find.byType(EnterTimeFormatDialoge), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
      await widgetTester.tap(find.byIcon(Icons.close));
      await widgetTester.pumpAndSettle();
      expect(find.byType(EnterTimeFormatDialoge), findsNothing);
    });
    testWidgets('should not allow saving empty time formats', (widgetTester) async {
      await widgetTester.pumpWidget(materialApp(const EnterTimeFormatDialoge(initialValue: 'yyyy-MM-dd HH:mm',)));

      await widgetTester.enterText(find.byType(TextField), '');
      await widgetTester.pumpAndSettle();
      expect(find.text('Please enter a value'), findsOneWidget);

      expect(find.byType(EnterTimeFormatDialoge), findsOneWidget);
      await widgetTester.tap(find.text('SAVE'));
      expect(find.byType(EnterTimeFormatDialoge), findsOneWidget);
    });
  });

  group('showTimeFormatPickerDialoge', () {
    testWidgets('should return null on close', (widgetTester) async {
      String? result = 'notnull';
      await loadDialoge(widgetTester,
              (context) async => result = await showTimeFormatPickerDialoge(context, 'yyyy-MM-dd HH:mm', false),);

      expect(find.byIcon(Icons.close), findsOneWidget);
      await widgetTester.tap(find.byIcon(Icons.close));
      await widgetTester.pumpAndSettle();

      expect(result, null);
    });
    testWidgets('should return value on save', (widgetTester) async {
      String? result;
      await loadDialoge(widgetTester,
              (context) async => result = await showTimeFormatPickerDialoge(context, 'yyyy-MM-dd HH:mm', false),);

      expect(find.text('SAVE'), findsOneWidget);
      await widgetTester.tap(find.text('SAVE'));
      await widgetTester.pumpAndSettle();

      expect(result, 'yyyy-MM-dd HH:mm');
    });
    testWidgets('should return modified value on save', (widgetTester) async {
      String? result;
      await loadDialoge(widgetTester,
              (context) async => result = await showTimeFormatPickerDialoge(context, 'yyyy-MM-dd HH:mm', false),);

      await widgetTester.enterText(find.byType(TextField), 'test text!');
      await widgetTester.pumpAndSettle();

      expect(find.text('SAVE'), findsOneWidget);
      await widgetTester.tap(find.text('SAVE'));
      await widgetTester.pumpAndSettle();

      expect(result, 'test text!');
    });
  });
}
import 'package:blood_pressure_app/features/settings/enter_timeformat_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../util.dart';

void main() {
  group('EnterTimeFormatDialog', () {
    testWidgets('should initialize without errors', (tester) async {
      await tester.pumpWidget(materialApp(const EnterTimeFormatDialog(initialValue: 'yyyy-MM-dd HH:mm',)));
      expect(tester.takeException(), isNull);
      expect(find.byType(EnterTimeFormatDialog), findsOneWidget);
    });
    testWidgets('should prefill time format', (tester) async {
      await tester.pumpWidget(materialApp( const EnterTimeFormatDialog(initialValue: 'yyyy-MM-dd HH:mm',)));
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);
      expect(find.descendant(of: textField, matching: find.text('yyyy-MM-dd HH:mm')), findsOneWidget);
    });
    testWidgets('should show preview', (tester) async {
      await tester.pumpWidget(materialApp(EnterTimeFormatDialog(
          initialValue: 'yyyy-MM-dd HH:mm',
          previewTime: DateTime(2023, 7, 23, 8, 20),
        ),
      ),);
      expect(find.text('2023-07-23 08:20'), findsOneWidget);
      
      // other time formats
      expect(find.byType(TextField), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'QQQQ + LLLL');
      await tester.pumpAndSettle();
      expect(find.text('3rd quarter + July'), findsOneWidget);
    });
    testWidgets('should close page on close button pressed', (tester) async {
      await tester.pumpWidget(materialApp(const EnterTimeFormatDialog(initialValue: 'yyyy-MM-dd HH:mm',)));

      expect(find.byType(EnterTimeFormatDialog), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.byType(EnterTimeFormatDialog), findsNothing);
    });
    testWidgets('should not allow saving empty time formats', (tester) async {
      await tester.pumpWidget(materialApp(const EnterTimeFormatDialog(initialValue: 'yyyy-MM-dd HH:mm',)));

      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();
      expect(find.text('Please enter a value'), findsOneWidget);

      expect(find.byType(EnterTimeFormatDialog), findsOneWidget);
      await tester.tap(find.text('SAVE'));
      expect(find.byType(EnterTimeFormatDialog), findsOneWidget);
    });
  });

  group('showTimeFormatPickerDialog', () {
    testWidgets('should return null on close', (tester) async {
      String? result = 'notnull';
      await loadDialog(tester,
              (context) async => result = await showTimeFormatPickerDialog(context, 'yyyy-MM-dd HH:mm', false),);

      expect(find.byIcon(Icons.close), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(result, null);
    });
    testWidgets('should return value on save', (tester) async {
      String? result;
      await loadDialog(tester,
              (context) async => result = await showTimeFormatPickerDialog(context, 'yyyy-MM-dd HH:mm', false),);

      expect(find.text('SAVE'), findsOneWidget);
      await tester.tap(find.text('SAVE'));
      await tester.pumpAndSettle();

      expect(result, 'yyyy-MM-dd HH:mm');
    });
    testWidgets('should return modified value on save', (tester) async {
      String? result;
      await loadDialog(tester,
              (context) async => result = await showTimeFormatPickerDialog(context, 'yyyy-MM-dd HH:mm', false),);

      await tester.enterText(find.byType(TextField), 'test text!');
      await tester.pumpAndSettle();

      expect(find.text('SAVE'), findsOneWidget);
      await tester.tap(find.text('SAVE'));
      await tester.pumpAndSettle();

      expect(result, 'test text!');
    });
  });
}

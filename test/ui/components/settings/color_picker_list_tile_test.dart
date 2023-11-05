import 'package:blood_pressure_app/components/color_picker.dart';
import 'package:blood_pressure_app/components/settings/color_picker_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ColorSelectionListTile', () {
    testWidgets('should initialize without errors', (widgetTester) async {
      await widgetTester.pumpWidget(_materialApp(ColorSelectionListTile(
        title: const Text('Test'),
        onMainColorChanged: (Color value) {  },
        initialColor: Colors.teal,)));
    });
    testWidgets('should preview color', (widgetTester) async {
      await widgetTester.pumpWidget(_materialApp(ColorSelectionListTile(
        title: const Text('Test'),
        onMainColorChanged: (Color value) {  },
        initialColor: Colors.teal,)));

      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(widgetTester.widget(find.byType(CircleAvatar)), isA<CircleAvatar>().having(
              (p0) => p0.backgroundColor, 'display color', Colors.teal));
    });
    testWidgets('should show colorPicker on tap', (widgetTester) async {
      await widgetTester.pumpWidget(_materialApp(ColorSelectionListTile(
        title: const Text('Test'),
        onMainColorChanged: (Color value) {  },
        initialColor: Colors.teal,)));

      expect(find.byType(ColorPicker), findsNothing);
      await widgetTester.tap(find.byType(ListTile));
      await widgetTester.pumpAndSettle();
      expect(find.byType(ColorPicker), findsOneWidget);
    });
    testWidgets('should notify on color changed', (widgetTester) async {
      int callCount = 0;
      await widgetTester.pumpWidget(_materialApp(ColorSelectionListTile(
        title: const Text('Test'),
        onMainColorChanged: (Color value) {
          callCount += 1;
          expect(value, Colors.red);
        },
        initialColor: Colors.teal,)));

      expect(find.byType(ColorPicker), findsNothing);
      await widgetTester.tap(find.byType(ListTile));
      await widgetTester.pumpAndSettle();
      expect(find.byType(ColorPicker), findsOneWidget);

      // tap red (color list offset by one)
      await widgetTester.tap(find.byType(InkWell).at(3));
      await widgetTester.pumpAndSettle();
      expect(find.byType(ColorPicker), findsNothing);

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
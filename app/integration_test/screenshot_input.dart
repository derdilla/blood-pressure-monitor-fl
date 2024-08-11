
import 'package:blood_pressure_app/app.dart';
import 'package:blood_pressure_app/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'util.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Screenshot input dialoge', (WidgetTester tester) async {
    final localizations = await AppLocalizations.delegate.load(const Locale('en'));
    const double settingsScrollAmount = 200.0;

    await tester.pumpWidget(App());
    await tester.pumpAndSettle();
    await tester.pumpUntil(() => find.byType(AppHome).hasFound);
    // home

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();
    // settings

    await tester.scrollUntilVisible(find.text(localizations.medications), settingsScrollAmount);
    await tester.tap(find.text(localizations.medications));
    await tester.pumpAndSettle();
    // medication manager
    await tester.tap(find.text(localizations.addMedication));
    await tester.pumpAndSettle();
    // add medication
    await tester.enterText(find.byType(TextFormField).at(0), 'Metolazone');
    await tester.pumpAndSettle();
    await tester.tap(find.text(localizations.color));
    await tester.pumpAndSettle();
    await tester.tap(find.byElementPredicate(_colored(Colors.teal)));
    await tester.pumpAndSettle();

    await tester.tap(find.text(localizations.btnSave));
    await tester.pumpAndSettle();
    // medication manager
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    // settings
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    // home

    await tester.enterMeasurement(sys: 119, dia: 75, pul: 65,
      note: 'Enter measurements faster than anywhere else!',
      color: Colors.yellow,
      save: false,
    );
    await tester.tap(find.text(localizations.noMedication));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Metolazone'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(4), '1.5');

    await tester.pumpAndSettle();
    await binding.convertFlutterSurfaceToImage();
    await tester.pump();
    await binding.takeScreenshot('01-example_add');
  });
}

extension on WidgetTester {
  Future<void> enterMeasurement({
    int? sys,
    int? dia,
    int? pul,
    String? note,
    Color? color,
    bool save = true,
  }) async {
    final localizations = await AppLocalizations.delegate.load(const Locale('en'));

    await tap(find.byIcon(Icons.add));
    await pumpAndSettle();
    if (sys != null) await enterText(find.byType(TextFormField).at(0), '$sys');
    if (dia != null) await enterText(find.byType(TextFormField).at(1), '$dia');
    if (pul != null) await enterText(find.byType(TextFormField).at(2), '$pul');
    if (note != null) await enterText(find.byType(TextFormField).at(3), '$note');
    if (color != null) {
      await tap(find.text(localizations.color));
      await pumpAndSettle();
      await tap(find.byElementPredicate(_colored(color)));
      await pumpAndSettle();
    }

    if (save) {
      await tap(find.text(localizations.btnSave));
      await pumpAndSettle();
    }
  }
}

bool Function(Element e) _colored(Color color) => (e) =>
  e.widget is Container &&
    (e.widget as Container).decoration is BoxDecoration &&
      ((e.widget as Container).decoration as BoxDecoration).color == color;

// Copy of app method
ThemeData _buildTheme(ColorScheme colorScheme) {
  final inputBorder = OutlineInputBorder(
    borderSide: BorderSide(
      width: 3,
      // Through black background outlineVariant has enough contrast.
      color: (colorScheme.brightness == Brightness.dark)
          ? colorScheme.outlineVariant
          : colorScheme.outline,
    ),
    borderRadius: BorderRadius.circular(20),
  );

  return ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true,
    inputDecorationTheme: InputDecorationTheme(
      errorMaxLines: 5,
      border: inputBorder,
      enabledBorder: inputBorder,
    ),
    scaffoldBackgroundColor: colorScheme.brightness == Brightness.dark
        ? Colors.black
        : Colors.white,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(15),
          bottomLeft: Radius.circular(15),
        ),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}

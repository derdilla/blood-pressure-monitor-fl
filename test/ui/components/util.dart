import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';


Widget materialApp(Widget child) {
  return MaterialApp(
    localizationsDelegates: const [AppLocalizations.delegate,],
    locale: const Locale('en'),
    home: Scaffold(body:child),
  );
}

/// Open a dialogue through a button press.
///
/// Example usage:
/// ```dart
/// dynamic returnedValue = false;
/// await loadDialogue(widgetTester, (context) async => returnedValue =
///    await showAddExportColumnDialogue(context, Settings(),
///      UserColumn('initialInternalIdentifier', 'csvTitle', 'formatPattern')
/// ));
/// ```
Future<void> loadDialogue(WidgetTester tester, void Function(BuildContext context) dialogueStarter, { String dialogueStarterText = 'X' }) async {
  await tester.pumpWidget(materialApp(Builder(builder: (context) =>
      TextButton(onPressed: () => dialogueStarter(context), child: Text(dialogueStarterText)))));
  await tester.tap(find.text(dialogueStarterText));
  await tester.pumpAndSettle();
}
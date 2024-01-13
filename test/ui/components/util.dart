import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';


Widget materialApp(Widget child) => MaterialApp(
    localizationsDelegates: const [AppLocalizations.delegate,],
    locale: const Locale('en'),
    home: Scaffold(body:child),
  );

/// Open a dialoge through a button press.
///
/// Example usage:
/// ```dart
/// dynamic returnedValue = false;
/// await loadDialoge(widgetTester, (context) async => returnedValue =
///    await showAddExportColumnDialoge(context, Settings(),
///      UserColumn('initialInternalIdentifier', 'csvTitle', 'formatPattern')
/// ));
/// ```
Future<void> loadDialoge(WidgetTester tester, void Function(BuildContext context) dialogeStarter, { String dialogeStarterText = 'X' }) async {
  await tester.pumpWidget(materialApp(Builder(builder: (context) =>
      TextButton(onPressed: () => dialogeStarter(context), child: Text(dialogeStarterText)),),),);
  await tester.tap(find.text(dialogeStarterText));
  await tester.pumpAndSettle();
}

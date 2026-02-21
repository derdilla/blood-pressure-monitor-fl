import 'package:blood_pressure_app/components/confirm_deletion_dialoge.dart';
import 'package:blood_pressure_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../util.dart';

void main() {
  testWidgets('shows entire content', (tester) async {
    await loadDialoge(tester, showConfirmDeletionDialoge);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(TextButton),
    ), findsOneWidget);
    expect(find.bySubtype<ElevatedButton>(), findsOneWidget);

    final localizations = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(localizations.confirmDelete), findsOneWidget);
    expect(find.text(localizations.confirmDeleteDesc), findsOneWidget);
    expect(find.text(localizations.btnCancel), findsOneWidget);
    expect(find.text(localizations.btnConfirm), findsOneWidget);

    expect(find.descendant(
      of: find.bySubtype<ElevatedButton>(),
      matching: find.byIcon(Icons.delete_forever),
    ), findsOneWidget);
    expect(find.descendant(
      of: find.bySubtype<ElevatedButton>(),
      matching: find.text(localizations.btnConfirm),
    ), findsOneWidget);
  });
}

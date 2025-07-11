import 'package:blood_pressure_app/features/export_import/export_button.dart';
import 'package:blood_pressure_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../util.dart';

void main() {
  testWidgets('Shows share icon and text when sharing', (tester) async {
    final localizations = await AppLocalizations.delegate.load(const Locale('en'));
    await tester.pumpWidget(materialApp(ExportButton(share: true)));

    expect(find.byIcon(Icons.file_download_outlined), findsNothing);
    expect(find.byIcon(Icons.share), findsOneWidget);
    expect(find.text(localizations.export), findsNothing);
    expect(find.text(localizations.btnShare), findsOneWidget);
  });
  testWidgets('Shows download icon and export text when not sharing', (tester) async {
    final localizations = await AppLocalizations.delegate.load(const Locale('en'));
    await tester.pumpWidget(materialApp(ExportButton(share: false)));

    expect(find.byIcon(Icons.file_download_outlined), findsOneWidget);
    expect(find.byIcon(Icons.share), findsNothing);
    expect(find.text(localizations.export), findsOneWidget);
    expect(find.text(localizations.btnShare), findsNothing);
  });
}

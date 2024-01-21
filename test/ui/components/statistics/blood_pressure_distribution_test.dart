import 'package:blood_pressure_app/components/statistics/blood_pressure_distribution.dart';
import 'package:blood_pressure_app/components/statistics/value_distribution.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../model/export_import/record_formatter_test.dart';
import '../util.dart';

void main() {
  testWidgets('should show allow navigation to view all widgets', (widgetTester) async {
    await widgetTester.pumpWidget(materialApp(BloodPressureDistribution(
      records: const [],
      settings: Settings(),
    ),),);

    final localizations = await AppLocalizations.delegate.load(const Locale('en'));

    expect(find.text(localizations.sysLong), findsOneWidget);
    expect(find.text(localizations.diaLong), findsOneWidget);
    expect(find.text(localizations.pulLong), findsOneWidget);

    expect(find.byKey(const Key('sys-dist')), findsOneWidget);
    expect(find.byKey(const Key('dia-dist')), findsNothing);
    expect(find.byKey(const Key('pul-dist')), findsNothing);

    await widgetTester.tap(find.text(localizations.diaLong));
    await widgetTester.pumpAndSettle();
    expect(find.byKey(const Key('sys-dist')), findsNothing);
    expect(find.byKey(const Key('dia-dist')), findsOneWidget);
    expect(find.byKey(const Key('pul-dist')), findsNothing);
    
    await widgetTester.tap(find.text(localizations.pulLong));
    await widgetTester.pumpAndSettle();
    expect(find.byKey(const Key('sys-dist')), findsNothing);
    expect(find.byKey(const Key('dia-dist')), findsNothing);
    expect(find.byKey(const Key('pul-dist')), findsOneWidget);
  });
  testWidgets('should report records to ValueDistribution', (widgetTester) async {
    await widgetTester.pumpWidget(materialApp(BloodPressureDistribution(
      records: [
        mockRecord(sys: 123),
        mockRecord(dia: 123),
        mockRecord(dia: 124),
        mockRecord(pul: 123),
        mockRecord(pul: 124),
        mockRecord(pul: 125),
      ],
      settings: Settings(
        sysColor: Colors.red,
        diaColor: Colors.green,
        pulColor: Colors.blue,
      ),
    ),),);

    final localizations = await AppLocalizations.delegate.load(const Locale('en'));

    await widgetTester.tap(find.text(localizations.sysLong));
    await widgetTester.pumpAndSettle();
    expect(find.byType(ValueDistribution), paints
        ..line(color: Colors.red.shade500)
        ..line(color: Colors.white70),
    );

    await widgetTester.tap(find.text(localizations.diaLong));
    await widgetTester.pumpAndSettle();
    expect(find.byType(ValueDistribution), paints
      ..line(color: Colors.green.shade500)
      ..line(color: Colors.green.shade500)
      ..line(color: Colors.white70),
    );

    await widgetTester.tap(find.text(localizations.pulLong));
    await widgetTester.pumpAndSettle();
    expect(find.byType(ValueDistribution), paints
      ..line(color: Colors.blue.shade500)
      ..line(color: Colors.blue.shade500)
      ..line(color: Colors.blue.shade500)
      ..line(color: Colors.white70),
    );

  });
}

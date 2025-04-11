import 'package:blood_pressure_app/features/statistics/blood_pressure_distribution.dart';
import 'package:blood_pressure_app/features/statistics/value_distribution.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:flutter/material.dart';
import 'package:blood_pressure_app/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../model/analyzer_test.dart';
import '../../util.dart';

void main() {
  testWidgets('should show allow navigation to view all widgets', (tester) async {
    await tester.pumpWidget(materialApp(BloodPressureDistribution(records: [])));

    final localizations = await AppLocalizations.delegate.load(const Locale('en'));

    expect(find.text(localizations.sysLong), findsOneWidget);
    expect(find.text(localizations.diaLong), findsOneWidget);
    expect(find.text(localizations.pulLong), findsOneWidget);

    expect(find.byKey(const Key('sys-dist')), findsOneWidget);
    expect(find.byKey(const Key('dia-dist')), findsNothing);
    expect(find.byKey(const Key('pul-dist')), findsNothing);

    await tester.tap(find.text(localizations.diaLong));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('sys-dist')), findsNothing);
    expect(find.byKey(const Key('dia-dist')), findsOneWidget);
    expect(find.byKey(const Key('pul-dist')), findsNothing);
    
    await tester.tap(find.text(localizations.pulLong));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('sys-dist')), findsNothing);
    expect(find.byKey(const Key('dia-dist')), findsNothing);
    expect(find.byKey(const Key('pul-dist')), findsOneWidget);
  });
  testWidgets('should report records to ValueDistribution', (tester) async {
    await tester.pumpWidget(materialApp(
      BloodPressureDistribution(
        records: [
          mockRecord(sys: 123),
          mockRecord(dia: 123),
          mockRecord(dia: 124),
          mockRecord(pul: 123),
          mockRecord(pul: 124),
          mockRecord(pul: 125),
        ],
      ),
      settings: Settings(
        sysColor: Colors.red,
        diaColor: Colors.green,
        pulColor: Colors.blue,
      ),
    ),);

    final localizations = await AppLocalizations.delegate.load(const Locale('en'));

    await tester.tap(find.text(localizations.sysLong));
    await tester.pumpAndSettle();
    expect(find.byType(ValueDistribution), paints
        ..line(color: Colors.red.shade500)
        ..line(color: Colors.white70),
    );

    await tester.tap(find.text(localizations.diaLong));
    await tester.pumpAndSettle();
    expect(find.byType(ValueDistribution), paints
      ..line(color: Colors.green.shade500)
      ..line(color: Colors.green.shade500)
      ..line(color: Colors.white70),
    );

    await tester.tap(find.text(localizations.pulLong));
    await tester.pumpAndSettle();
    expect(find.byType(ValueDistribution), paints
      ..line(color: Colors.blue.shade500)
      ..line(color: Colors.blue.shade500)
      ..line(color: Colors.blue.shade500)
      ..line(color: Colors.white70),
    );
  });
}

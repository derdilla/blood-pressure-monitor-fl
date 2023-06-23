import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:blood_pressure_app/model/ram_only_implementations.dart';
import 'package:blood_pressure_app/model/settings_store.dart';
import 'package:blood_pressure_app/screens/statistics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  group("page should display data", () {
    testWidgets('should load page', (widgetTester) async {
      await _initStatsPage(widgetTester, []);
      expect(find.text('Statistics'), findsOneWidget);
    });
    testWidgets("should report measurement count", (widgetTester) async {
      await _initStatsPage(widgetTester, [
        for (int i = 0; i<50; i++)
          BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(i), 40+i, 60+i, 30+i, 'Test comment $i'),
      ]);
      final measurementCountWidget = find.byKey(const Key('measurementCount'));
      expect(measurementCountWidget, findsOneWidget);
      expect(find.descendant(of: measurementCountWidget, matching: find.text('50')), findsOneWidget);
    });
  });
}

Future<void> _initStatsPage(WidgetTester widgetTester, List<BloodPressureRecord> records) async {
  final model = RamBloodPressureModel();
  final settings = RamSettings();

  for (var r in records) {
    model.add(r);
  }

  await widgetTester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<Settings>(create: (_) => settings),
        ChangeNotifierProvider<BloodPressureModel>(create: (_) => model),
      ],
      child: Localizations(
        delegates: AppLocalizations.localizationsDelegates,
        locale: const Locale('en'),
        child: const StatisticsPage(),
      )
  ));
  await widgetTester.pumpAndSettle();
}
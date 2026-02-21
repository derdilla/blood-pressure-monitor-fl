import 'package:blood_pressure_app/features/measurement_list/measurement_list.dart';
import 'package:blood_pressure_app/features/measurement_list/measurement_list_entry.dart';
import 'package:blood_pressure_app/l10n/app_localizations.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../model/export_import/record_formatter_test.dart';
import '../../util.dart';

void main() {
  testWidgets('contains all elements in time range', (tester) async {
    await tester.pumpWidget(materialApp(
      MeasurementList(
        entries: [
          mockEntry(time: DateTime(2020), sys: 2020),
          mockEntry(time: DateTime(2021), sys: 2021),
          mockEntry(time: DateTime(2022), sys: 2022),
          mockEntry(time: DateTime(2023), sys: 2023),
        ],
      ),
    ));
    expect(find.byType(MeasurementListRow), findsNWidgets(4));
    expect(find.text('2020'), findsOneWidget);
    expect(find.text('2021'), findsOneWidget);
    expect(find.text('2022'), findsOneWidget);
    expect(find.text('2023'), findsOneWidget);
  });
  testWidgets('entries are ordered in reversed passed order', (tester) async {
    await tester.pumpWidget(materialApp(
      MeasurementList(
        entries: [
          mockEntry(time: DateTime.fromMillisecondsSinceEpoch(4000), sys: 1),
          mockEntry(time: DateTime.fromMillisecondsSinceEpoch(2000), sys: 2),
          mockEntry(time: DateTime.fromMillisecondsSinceEpoch(1000), sys: 3),
        ],
      ),
    ));
    expect(find.byType(MeasurementListRow), findsNWidgets(3));
    // coordinates starting at top left
    final top = tester.getCenter(find.text('1')).dy;
    final center = tester.getCenter(find.text('2')).dy;
    final bottom = tester.getCenter(find.text('3')).dy;
    expect(bottom, greaterThan(center));
    expect(top, lessThan(center));
  });
  testWidgets('entries are ordered in reversed chronological order', (tester) async {
    final localizations = await AppLocalizations.delegate.load(const Locale('en'));
    await tester.pumpWidget(materialApp(
      MeasurementList(
        entries: [
          mockEntry(time: DateTime.fromMillisecondsSinceEpoch(2000), sys: 2),
        ],
      ),
      settings: Settings(
        sysColor: Colors.blue,
        diaColor: Colors.purple,
        pulColor: Colors.indigo,
      )
    ));
    expect(
      find.byWidgetPredicate((widget) =>
        widget is Text
        && widget.data == localizations.sysLong
        && widget.style?.color == Colors.blue),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate((widget) =>
        widget is Text
        && widget.data == localizations.diaLong
        && widget.style?.color == Colors.purple),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate((widget) =>
        widget is Text
        && widget.data == localizations.pulLong
        && widget.style?.color == Colors.indigo),
      findsOneWidget,
    );
  });
}

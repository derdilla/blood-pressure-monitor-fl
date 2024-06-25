import 'package:blood_pressure_app/components/measurement_list/measurement_list.dart';
import 'package:blood_pressure_app/components/measurement_list/measurement_list_entry.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../model/export_import/record_formatter_test.dart';
import '../util.dart';

void main() {
  testWidgets('contains all elements in time range', (tester) async {
    await tester.pumpWidget(materialApp(
      MeasurementList(
        settings: Settings(),
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
  testWidgets('entries are ordered in reversed chronological order', (tester) async {
    await tester.pumpWidget(materialApp(
      MeasurementList(
        settings: Settings(),
        entries: [
          mockEntry(time: DateTime.fromMillisecondsSinceEpoch(2000), sys: 2),
          mockEntry(time: DateTime.fromMillisecondsSinceEpoch(4000), sys: 1),
          mockEntry(time: DateTime.fromMillisecondsSinceEpoch(1000), sys: 3),
        ],
      ),
    ));
    expect(find.byType(MeasurementListRow), findsNWidgets(3));
    final top = await tester.getCenter(find.text('1')).dy;
    final center = await tester.getCenter(find.text('2')).dy;
    final bottom = await tester.getCenter(find.text('3')).dy;
    expect(bottom, greaterThan(center));
    expect(center, greaterThan(top));
  });
}

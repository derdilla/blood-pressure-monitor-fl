import 'dart:ui';

import 'package:blood_pressure_app/data_util/interval_picker.dart';
import 'package:blood_pressure_app/features/home/navigation_action_buttons.dart';
import 'package:blood_pressure_app/features/measurement_list/compact_measurement_list.dart';
import 'package:blood_pressure_app/features/measurement_list/measurement_list.dart';
import 'package:blood_pressure_app/features/statistics/value_graph.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:blood_pressure_app/screens/home_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../model/analyzer_test.dart';
import '../util.dart';

void main() {
  final TestWidgetsFlutterBinding binding = TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows graph above list in phone mode', (tester) async {
    await binding.setSurfaceSize(const Size(400, 800));

    await tester.pumpWidget(await appBaseWithData(const AppHome()));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationActionButtons), findsOneWidget);

    expect(find.byType(BloodPressureValueGraph), findsOneWidget);
    expect(find.byType(IntervalPicker), findsOneWidget);
    expect(find.byType(MeasurementList), findsOneWidget);

    expect(
      tester.getCenter(find.byType(BloodPressureValueGraph)).dy,
      lessThan(tester.getCenter(find.byType(IntervalPicker)).dy)
    );
    expect(
        tester.getCenter(find.byType(IntervalPicker)).dy,
        lessThan(tester.getCenter(find.byType(MeasurementList)).dy)
    );
  });

  testWidgets('only shows graph in landscape more', (tester) async {
    await binding.setSurfaceSize(const Size(800, 400));

    await tester.pumpWidget(await appBaseWithData(const AppHome(),
      records: [mockRecord(sys: 123)],
    ));
    await tester.pumpAndSettle();

    expect(find.byType(BloodPressureValueGraph), findsOneWidget);
    expect(find.byType(NavigationActionButtons), findsNothing);
    expect(find.byType(IntervalPicker), findsNothing);
    expect(find.byType(MeasurementList), findsNothing);
  });

  testWidgets('respects compact list setting', (tester) async {
    await binding.setSurfaceSize(const Size(400, 800));

    final s = Settings(useLegacyList: false);
    await tester.pumpWidget(await appBaseWithData(const AppHome(), settings: s));
    await tester.pumpAndSettle();

    expect(find.byType(MeasurementList), findsOneWidget);
    expect(find.byType(CompactMeasurementList), findsNothing);

    s.compactList = true;
    await tester.pump();

    expect(find.byType(MeasurementList), findsNothing);
    expect(find.byType(CompactMeasurementList), findsOneWidget);
  });
}

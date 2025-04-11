import 'package:blood_pressure_app/features/input/forms/date_time_form.dart';
import 'package:flutter/material.dart';
import 'package:blood_pressure_app/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import '../../../util.dart';

void main() {
  testWidgets('saves entered values', (WidgetTester tester) async {
    final key = GlobalKey<DateTimeFormState>();
    final initialTime = DateTime(2025,02,28,10,10);
    await tester.pumpWidget(materialApp(DateTimeForm(key: key, initialValue: initialTime)));
    final localizations = await AppLocalizations.delegate.load(const Locale('en'));

    expect(find.text(localizations.date), findsOneWidget);
    expect(find.text(localizations.time), findsOneWidget);
    expect(key.currentState!.validate(), true);
    expect(find.byType(InputDecorator), findsNWidgets(2));

    final dateFormated = DateFormat('yyyy-MM-dd').format(initialTime);
    final timeOfDayFormated = DateFormat('HH:mm').format(initialTime);
    expect(find.text(dateFormated), findsOneWidget);
    expect(find.text(timeOfDayFormated), findsOneWidget);

    await tester.tap(find.text(dateFormated));
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsOneWidget);
    await tester.tap(find.text('19'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.text(dateFormated), findsNothing);
    expect(find.text(DateFormat('yyyy-MM-dd').format(DateTime(2025,02,19))), findsOneWidget);
    expect(find.text(timeOfDayFormated), findsOneWidget);

    await tester.tap(find.text(timeOfDayFormated));
    await tester.pumpAndSettle();
    expect(find.byType(TimePickerDialog), findsOneWidget);
    final dialCenter = tester.getCenter(find.byKey(const ValueKey<String>('time-picker-dial')));
    await tester.tapAt(Offset(dialCenter.dx, dialCenter.dy + 10)); // 6 AM
    await tester.pumpAndSettle();
    await tester.tapAt(Offset(dialCenter.dx - 10, dialCenter.dy));  // 45
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.text(DateFormat('yyyy-MM-dd').format(DateTime(2025,02,19))), findsOneWidget);
    expect(find.text(timeOfDayFormated), findsNothing);
    expect(find.text(DateFormat('HH:mm').format(DateTime(2025,2,19,6,45))), findsOneWidget);

    expect(key.currentState!.validate(), true);
    expect(key.currentState!.save(), DateTime(2025,2,19,6,45));
  });

  testWidgets('shows errors on bad inputs', (WidgetTester tester) async {
    final key = GlobalKey<DateTimeFormState>();
    final initialTime = DateTime.now();
    await tester.pumpWidget(materialApp(DateTimeForm(key: key, initialValue: initialTime)));
    final localizations = await AppLocalizations.delegate.load(const Locale('en'));

    expect(find.text(localizations.errTimeAfterNow), findsNothing);

    await tester.tap(find.text(DateFormat('HH:mm').format(initialTime)));
    await tester.pumpAndSettle();
    final dialCenter = tester.getCenter(find.byKey(const ValueKey<String>('time-picker-dial')));
    await tester.tapAt(Offset(dialCenter.dx - 3, dialCenter.dy - 9.5));
    await tester.tap(find.text('PM')); // 11 PM
    await tester.pumpAndSettle();
    await tester.tapAt(Offset(dialCenter.dx - 3, dialCenter.dy - 9.5)); // 55
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(key.currentState!.save(), null);
    expect(key.currentState!.validate(), false);
    await tester.pumpAndSettle();
    expect(find.text(localizations.errTimeAfterNow), findsOneWidget);
  });

  testWidgets('loads values into fields', (WidgetTester tester) async {
    final key = GlobalKey<DateTimeFormState>();
    final initialTime = DateTime(2025,02,28,10,10);
    final newTime = DateTime(2022,11,1,2,3);
    await tester.pumpWidget(materialApp(DateTimeForm(key: key, initialValue: initialTime)));

    expect(find.text(DateFormat('yyyy-MM-dd').format(initialTime)), findsOneWidget);
    expect(find.text(DateFormat('HH:mm').format(initialTime)), findsOneWidget);
    expect(find.text(DateFormat('yyyy-MM-dd').format(newTime)), findsNothing);
    expect(find.text(DateFormat('HH:mm').format(newTime)), findsNothing);

    key.currentState!.fillForm(DateTime(2022,11,1,2,3));
    await tester.pumpAndSettle();

    expect(find.text(DateFormat('yyyy-MM-dd').format(initialTime)), findsNothing);
    expect(find.text(DateFormat('HH:mm').format(initialTime)), findsNothing);
    expect(find.text(DateFormat('yyyy-MM-dd').format(newTime)), findsOneWidget);
    expect(find.text(DateFormat('HH:mm').format(newTime)), findsOneWidget);
  });
}

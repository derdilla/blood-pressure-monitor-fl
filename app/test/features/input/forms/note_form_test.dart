import 'package:blood_pressure_app/features/input/forms/note_form.dart';
import 'package:blood_pressure_app/features/settings/tiles/color_picker_list_tile.dart';
import 'package:blood_pressure_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../util.dart';
import '../../settings/tiles/color_picker_list_tile_test.dart';

void main() {
  testWidgets('saves entered text', (WidgetTester tester) async {
    final key = GlobalKey<NoteFormState>();
    await tester.pumpWidget(materialApp(NoteForm(key: key)));
    final localizations = await AppLocalizations.delegate.load(const Locale('en'));

    expect(find.text(localizations.addNote), findsOneWidget);
    expect(key.currentState!.validate(), true);

    await tester.enterText(find.byType(TextField), 'some test note!');

    expect(key.currentState!.validate(), true);
    expect(key.currentState!.save(), ('some test note!', null));
  });

  testWidgets('saves entered color and text', (WidgetTester tester) async {
    final key = GlobalKey<NoteFormState>();
    await tester.pumpWidget(materialApp(NoteForm(key: key)));
    final localizations = await AppLocalizations.delegate.load(const Locale('en'));

    expect(find.text(localizations.addNote), findsOneWidget);
    expect(key.currentState!.validate(), true);

    await tester.enterText(find.byType(TextField), 'some test note!');
    await tester.tap(find.byType(ColorSelectionListTile));
    await tester.pump();
    await tester.tap(find.byElementPredicate(findColored(Colors.red)));

    expect(key.currentState!.validate(), true);
    expect(key.currentState!.save(), ('some test note!', Colors.red));
  });

  testWidgets('loads initial values', (WidgetTester tester) async {
    await tester.pumpWidget(materialApp(NoteForm(
      initialValue: ('Some note text from test', Colors.cyan),
    )));
    await tester.pumpAndSettle();
    expect(find.text('Some note text from test'), findsOneWidget);
    await tester.tap(find.byElementPredicate(findColored(Colors.cyan)));
  });

  testWidgets('saves only filled inputs', (WidgetTester tester) async {
    final key = GlobalKey<NoteFormState>();
    await tester.pumpWidget(materialApp(NoteForm(key: key)));
    expect(key.currentState!.save(), isNull);
  });

  testWidgets('saves prefilled inputs', (WidgetTester tester) async {
    final v = ('Some note text from test', Colors.cyan);

    final key = GlobalKey<NoteFormState>();
    await tester.pumpWidget(materialApp(NoteForm(key: key, initialValue: v)));
    expect(key.currentState!.save(), v);
  });
}

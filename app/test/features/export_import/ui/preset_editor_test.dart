import 'dart:async';

import 'package:blood_pressure_app/features/export_import/model/column.dart';
import 'package:blood_pressure_app/features/export_import/model/export_preset.dart';
import 'package:blood_pressure_app/features/export_import/ui/columns_config/preset_editor.dart';
import 'package:blood_pressure_app/l10n/app_localizations.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../util.dart';

void main() {
  testWidgets('reorders columns correctly', (tester) async {
    final editor = CustomPreset([
      NativeColumn.systolic.internalIdentifier,
      NativeColumn.diastolic.internalIdentifier,
    ]);
    final onUpdate = Completer();
    editor.addListener(onUpdate.complete);
    await tester.pumpWidget(materialApp(PresetEditor(editor: editor)));
    final localizations = await AppLocalizations.delegate.load(const Locale('en'));

    expect(editor.columns[0], NativeColumn.systolic.internalIdentifier);
    expect(editor.columns[1], NativeColumn.diastolic.internalIdentifier);

    final start = tester.getCenter(find.dragHandle(localizations.sysLong));

    expect(onUpdate.isCompleted, false);
    final drag = await tester.startGesture(start);
    await tester.pump(kPressTimeout);
    await drag.moveBy(const Offset(0, 40));
    await tester.pumpAndSettle();
    await drag.up();
    await tester.pumpAndSettle();

    await onUpdate.future.timeout(Duration(seconds: 1));
    expect(editor.columns[1], NativeColumn.systolic.internalIdentifier);
    expect(editor.columns[0], NativeColumn.diastolic.internalIdentifier);
  });

  testWidgets('removes columns on button press', (tester) async {
    final editor = CustomPreset([
      NativeColumn.systolic.internalIdentifier,
      NativeColumn.diastolic.internalIdentifier,
    ]);
    await tester.pumpWidget(materialApp(PresetEditor(editor: editor)));

    expect(editor.columns, hasLength(2));
    await tester.tap(find.byIcon(Icons.remove_circle_outline).first);
    await tester.pumpAndSettle();
    expect(editor.columns, hasLength(1));
  });

  testWidgets('can add columns', (tester) async {
    final editor = CustomPreset([]);
    await tester.pumpWidget(materialApp(PresetEditor(editor: editor)));
    final localizations = await AppLocalizations.delegate.load(const Locale('en'));

    expect(editor.columns, isEmpty);
    expect(find.byType(Dialog), findsNothing);
    expect(find.text(localizations.pulLong), findsNothing);
    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsOneWidget);

    await tester.tap(find.text(localizations.pulLong));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);
    expect(editor.columns, hasLength(1));
  });

  testWidgets('removes correct field when multiple with same name are available', (tester) async {
    final editor = CustomPreset([
      NativeColumn.systolic.internalIdentifier,
      NativeColumn.systolic.internalIdentifier,
    ]);
    await tester.pumpWidget(materialApp(PresetEditor(editor: editor)));

    expect(editor.columns, hasLength(2));
    await tester.tap(find.byIcon(Icons.remove_circle_outline).first);
    await tester.pumpAndSettle();
    expect(editor.columns, hasLength(1));
  });
}

extension on CommonFinders {
  Finder dragHandle(String title) => descendant(
    matching: find.byType(ReorderableDragStartListener),
    of: find.ancestor(
      matching: find.byType(ListTile),
      of: find.text(title),
    ),
  );
}


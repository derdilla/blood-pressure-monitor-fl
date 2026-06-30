import 'package:blood_pressure_app/features/export_import/model/column.dart';
import 'package:blood_pressure_app/features/export_import/model/export_preset.dart';
import 'package:blood_pressure_app/l10n/app_localizations.dart';
import 'package:blood_pressure_app/model/storage/storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class PresetEditor extends  StatelessWidget {
  const PresetEditor({super.key, required this.editor});

  final CustomPreset editor;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(16, 5, 16, 16),
    decoration: BoxDecoration(
      border: Border.all(color: Theme.of(context).textTheme.labelLarge?.color ?? Colors.teal),
      borderRadius: const BorderRadius.all(Radius.circular(10)),
    ),
    child: ListenableBuilder(
      listenable: editor,
      builder: (context, _) => ReorderableListView.builder(
        itemBuilder: (context, idx) {
          if (idx >= editor.columns.length) {
            return ListTile(
              key: const Key('add field'),
              leading: const Icon(Icons.add),
              title: Text(AppLocalizations.of(context)!.addEntry),
              onTap: () => addField(context),
            );
          }
          return ListTile(
            key: Key(editor.columns[idx] + idx.toString()),
            title: Text(columnTitle(context, editor.columns[idx])),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: AppLocalizations.of(context)!.remove,
                  onPressed: () {
                    editor.removeUserColumn(idx);
                  },
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                ReorderableDragStartListener(
                  index: idx,
                  child: const Icon(Icons.drag_handle),
                ),
              ],
            ),
          );
        },
        itemCount: editor.columns.length + 1,
        onReorderItem: editor.reorderUserColumns,
        buildDefaultDragHandles: false,
        dragStartBehavior: DragStartBehavior.down,
      )
    ),
  );

  String columnTitle(BuildContext context, String columnId) {
      final column = context.watch<ExportColumnsManager>()
          .firstWhere((c) => c.internalIdentifier == columnId);
      assert(column != null, 'A forgotten column was selected that will not be able to encode data');
      return column?.userTitle(AppLocalizations.of(context)!) ?? 'Unknown column';
  }

  void addField(BuildContext context) async {
    final column = await showDialog<ExportColumn?>(context: context, builder: (context) =>
        SimpleDialog(
          title: Text(AppLocalizations.of(context)!.addEntry),
          insetPadding: const EdgeInsets.symmetric(
            vertical: 64,
          ),
          children: context.watch<ExportColumnsManager>().getAllColumns().map((column) =>
              ListTile(
                title: Text(column.userTitle(AppLocalizations.of(context)!)),
                onTap: () => Navigator.pop(context, column),
              ),
          ).toList(),
        ),
    );
    if (column != null) editor.addUserColumn(column);
  }
}

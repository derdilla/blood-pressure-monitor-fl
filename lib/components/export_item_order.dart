
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ExportItemsCustomizer extends StatelessWidget {
  final List<String> exportItems;
  final List<String> exportAddableItems;
  final FutureOr<void> Function(List<String> exportItems, List<String> exportAddableItems) onReorder;

  const ExportItemsCustomizer({super.key, required this.exportItems, required this.exportAddableItems,
      required this.onReorder});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(25),
      padding: const EdgeInsets.all(20),
      height: 420,
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).textTheme.labelLarge?.color ?? Colors.teal),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      clipBehavior: Clip.hardEdge,
      child: ReorderableListView(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        onReorder: _onReorderList,
        children: <Widget>[
          for (int i = 0; i < exportItems.length; i += 1)
            ListTile(
              key: Key('l_${exportItems[i]}'),
              title: Text(exportItems[i]),
              trailing: const Icon(Icons.drag_handle),
            ),
          _buildListSectionDivider(context),
          for (int i = 0; i < exportAddableItems.length; i += 1)
            ListTile(
              key: Key('ul_${exportAddableItems[i]}'),
              title: Opacity(opacity: 0.7,child: Text(exportAddableItems[i]),),
              trailing: const Icon(Icons.drag_handle),
            ),
        ],
      ),
    );
  }

  Widget _buildListSectionDivider(BuildContext context) {
    return IgnorePointer(
      key: UniqueKey(),
      child: Opacity(
        opacity: 0.7,
        child: Row(
            children: <Widget>[
              const Expanded(
                  child: Divider()
              ),
              Container(
                  padding: const EdgeInsets.all(10),
                  child: const Icon(Icons.arrow_downward)
              ),
              Text(AppLocalizations.of(context)!.exportHiddenFields),
              Container(
                  padding: const EdgeInsets.all(10),
                  child: const Icon(Icons.arrow_downward)
              ),
              const Expanded(
                  child: Divider()
              ),
            ]
        ),
      ),
    );
  }

  _onReorderList(oldIndex, newIndex) {
    /**
     * We have a list of items that is structured like the following:
     * [ exportItems.length, 1, exportAddableItems.length ]
     *
     * So oldIndex is either (0 <= oldIndex < exportItems.length) or
     * ((exportItems.length + 1) <= oldIndex < (exportItems.length + 1 + exportAddableItems.length))
     * newIndex is in the range (0 <= newIndex < (exportItems.length + 1 + exportAddableItems.length))
     *
     * In case the entry is moved upwards on the list the new position needs to have 1 subtracted because there
     * is an entry missing above it now.
     *
     * If the newIndex is (0 <= newIndex < (exportItems.length + 1)) the Item got moved above the divider.
     * The + 1 is needed to compensate for moving the item one position above the divider and thereby replacing
     * its index.
     */
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final String item;
    if (0 <= oldIndex && oldIndex < exportItems.length) {
      item = exportItems.removeAt(oldIndex);
    } else if ((exportItems.length + 1) <= oldIndex && oldIndex < (exportItems.length + 1 + exportAddableItems.length)) {
      item = exportAddableItems.removeAt(oldIndex - (exportItems.length + 1));
    } else {
      assert(false, 'oldIndex outside expected boundaries');
      return;
    }

    if (newIndex < (exportItems.length + 1)) {
      exportItems.insert(newIndex, item);
    } else {
      newIndex -= (exportItems.length + 1);
      exportAddableItems.insert(newIndex, item);
    }

    onReorder(exportItems, exportAddableItems);
  }
}


// 100 - 80 + (50 / 80 * (100 % 50))
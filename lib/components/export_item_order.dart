
import 'dart:async';

import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:function_tree/function_tree.dart';

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

class ExportColumn {
  static const _functionRegex = r'\{\{([^}]*)}}';

  /// pure name as in the title of the csv file and for internal purposes. Should not contain special characters and spaces.
  final String internalColumnName;
  /// Display title of the column. Possibly localized
  final String columnTitle;
  /// Pattern to create the field contents from: TODO implement input and documentation
  late final String formatPattern;
  final List<MultiVariableFunction> _parsedFunctions = [];

  /// Example: ExportColumn(internalColumnName: 'pulsePressure', columnTitle: 'Pulse pressure', formatPattern: '{{SYS-DIA}}')
  ExportColumn({required this.internalColumnName, required this.columnTitle, required String formatPattern}) {
    this.formatPattern = formatPattern.replaceAll('{{}}', '');

    final mathSnippets = RegExp(_functionRegex).allMatches(this.formatPattern);
    for (final m in mathSnippets) {
      assert(m.groupCount == 1, 'If a math block is found content is expected');
      final function = m.group(0)!.toMultiVariableFunction(['SYS', 'DIA', 'PUL']);
      _parsedFunctions.add(function);
    }
  }

  String formatRecord(BloodPressureRecord record) {
    var fieldContents = formatPattern;

    int matchIndex = 0;
    fieldContents = fieldContents.replaceAllMapped(RegExp(_functionRegex), (m) {
      assert (_parsedFunctions.length > matchIndex);
      final result = _parsedFunctions[matchIndex].call({
        'SYS' : record.systolic ?? -1,
        'DIA': record.diastolic ?? -1,
        'PUL': record.pulse ?? -1
      }) as double;
      matchIndex++;
      return result.toString();
    });

    /*
    fieldContents.replaceAll('\$SYS', record.systolic.toString());
    fieldContents.replaceAll('\$DIA', record.diastolic.toString());
    fieldContents.replaceAll('\$PUL', record.pulse.toString());
    */

    return fieldContents;
  }
}


// 100 - 80 + (50 / 80 * (100 % 50))
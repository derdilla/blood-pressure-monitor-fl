
import 'dart:async';

import 'package:badges/badges.dart' as badges;
import 'package:blood_pressure_app/components/consistent_future_builder.dart';
import 'package:blood_pressure_app/model/export_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../model/settings_store.dart';

class ExportItemsCustomizer extends StatefulWidget {
  final List<String> exportItems;
  final List<String> exportAddableItems;
  final FutureOr<void> Function(List<String> exportItems, List<String> exportAddableItems) onReorder;

  const ExportItemsCustomizer({super.key, required this.exportItems, required this.exportAddableItems,
      required this.onReorder});

  @override
  State<ExportItemsCustomizer> createState() => _ExportItemsCustomizerState();
}

class _ExportItemsCustomizerState extends State<ExportItemsCustomizer> {
  // hack so that FutureBuilder doesn't always rebuild
  Future<ExportConfigurationModel>? _future;

  @override
  Widget build(BuildContext context) {
    _future ??= ExportConfigurationModel.get(Provider.of<Settings>(context, listen: false), AppLocalizations.of(context)!);
    return ConsistentFutureBuilder(
      future: _future!,
      onData: (BuildContext context, ExportConfigurationModel result) {
        final formats = result.availableFormats;
        return badges.Badge(
          badgeStyle: badges.BadgeStyle(
            badgeColor: Theme.of(context).colorScheme.background,
            padding: const EdgeInsets.all(10)
          ),
          position: badges.BadgePosition.bottomEnd(bottom: 3, end: 3),
          badgeContent: Container(
          decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.onBackground),
              shape: BoxShape.circle
          ),
          child: IconButton(
            tooltip: 'add exportformat',
            onPressed:() {},
            icon: const Icon(Icons.add),
          ),
          ),
          child: Container(
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
                for (int i = 0; i < widget.exportItems.length; i += 1)
                  ListTile(
                    key: Key('l_${widget.exportItems[i]}'),
                    title: Text(formats[widget.exportItems[i]]?.columnTitle ?? widget.exportItems[i]),
                    trailing: const Icon(Icons.drag_handle),
                  ),
                _buildListSectionDivider(context),
                for (int i = 0; i < widget.exportAddableItems.length; i += 1)
                  ListTile(
                    key: Key('ul_${widget.exportAddableItems[i]}'),
                    title: Opacity(opacity: 0.7,child: Text(widget.exportAddableItems[i]),),
                    trailing: const Icon(Icons.drag_handle),
                  ),
              ],
            ),
          ),
        );
      },
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
    if (0 <= oldIndex && oldIndex < widget.exportItems.length) {
      item = widget.exportItems.removeAt(oldIndex);
    } else if ((widget.exportItems.length + 1) <= oldIndex && oldIndex < (widget.exportItems.length + 1 + widget.exportAddableItems.length)) {
      item = widget.exportAddableItems.removeAt(oldIndex - (widget.exportItems.length + 1));
    } else {
      assert(false, 'oldIndex outside expected boundaries');
      return;
    }

    if (newIndex < (widget.exportItems.length + 1)) {
      widget.exportItems.insert(newIndex, item);
    } else {
      newIndex -= (widget.exportItems.length + 1);
      widget.exportAddableItems.insert(newIndex, item);
    }

    widget.onReorder(widget.exportItems, widget.exportAddableItems);
  }
}


// 100 - 80 + (50 / 80 * (100 % 50))
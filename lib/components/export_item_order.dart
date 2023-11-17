
import 'dart:async';

import 'package:badges/badges.dart' as badges;
import 'package:blood_pressure_app/components/consistent_future_builder.dart';
import 'package:blood_pressure_app/model/export_import/column.dart';
import 'package:blood_pressure_app/model/export_options.dart';
import 'package:blood_pressure_app/model/storage/storage.dart';
import 'package:blood_pressure_app/screens/subsettings/export_column_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class ExportItemsCustomizer extends StatefulWidget {
  final List<ExportColumn> shownItems;
  final List<ExportColumn> disabledItems;
  final FutureOr<void> Function(List<ExportColumn> exportItems, List<ExportColumn> exportAddableItems) onReorder;

  const ExportItemsCustomizer({super.key, required this.shownItems, required this.disabledItems,
      required this.onReorder});

  @override
  State<ExportItemsCustomizer> createState() => _ExportItemsCustomizerState();
}

class _ExportItemsCustomizerState extends State<ExportItemsCustomizer> {
  @override
  Widget build(BuildContext context) {
    return ConsistentFutureBuilder(
      future: ExportConfigurationModel.get(AppLocalizations.of(context)!),
      cacheFuture: true,
      onData: (BuildContext context, ExportConfigurationModel result) {
        return _buildAddItemBadge(context, result,
          child: _buildManagePresetsBadge(context, result,
            child:_buildList(context, result)
          )
        );
      },
    );
  }

  Container _buildList(BuildContext context, ExportConfigurationModel exportConfigModel) {
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
          shrinkWrap: true,
          onReorder: _onReorderList,
          children: <Widget>[
            for (int i = 0; i < widget.shownItems.length; i += 1)
              ListTile(
                  key: Key('l_${widget.shownItems[i].internalName}'),
                  title: Text(widget.shownItems[i].columnTitle),
                  trailing: _buildListItemTrailing( context, widget.shownItems[i], exportConfigModel),
                  contentPadding: EdgeInsets.zero
              ),
            _buildListSectionDivider(context),
            for (int i = 0; i < widget.disabledItems.length; i += 1)
              (widget.disabledItems[i].hidden) ? SizedBox.shrink(key: Key('ul_${widget.disabledItems[i].internalName}'),)
              : ListTile(
                key: Key('ul_${widget.disabledItems[i].internalName}'),
                title: Opacity(
                  opacity: 0.7,
                  child: Text(widget.disabledItems[i].columnTitle),
                ),
                trailing: _buildListItemTrailing(context, widget.disabledItems[i], exportConfigModel),
                contentPadding: EdgeInsets.zero
              ),
          ],
        ),
      );
  }

  Widget _buildAddItemBadge(BuildContext context, ExportConfigurationModel result, {required Widget child}) {
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
          tooltip: AppLocalizations.of(context)!.addExportformat,
          onPressed:() {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const EditExportColumnPage()));
          },
          icon: const Icon(Icons.add),
        ),
      ),
      child: child,
    );
  }

  Widget _buildManagePresetsBadge(BuildContext context, ExportConfigurationModel result, {required Widget child}) {
    final exportConfigurations = result.exportConfigurations;
    return badges.Badge(
      position: badges.BadgePosition.topEnd(top: 3, end: 3),
      badgeStyle: badges.BadgeStyle(
        badgeColor: Theme.of(context).colorScheme.background,
        padding: const EdgeInsets.all(5)
      ),
      badgeContent: PopupMenuButton<int>(
        icon: const Icon(Icons.collections_bookmark),
        itemBuilder: (BuildContext context) {
          return [
            for (var i = 0; i< exportConfigurations.length; i++)
              PopupMenuItem<int>(value: i, child: Text(exportConfigurations[i].$1)),
          ];
        },
        onSelected: (value) {
          final exportSettings = Provider.of<ExportSettings>(context, listen: false);
          if (exportSettings.exportFormat == ExportFormat.csv) {
            Provider.of<CsvExportSettings>(context, listen: false).customFields = exportConfigurations[value].$2;
          } else {
            assert(exportSettings.exportFormat == ExportFormat.pdf);
            Provider.of<PdfExportSettings>(context, listen: false).customFields = exportConfigurations[value].$2;
          }
        },
      ),
      child: child,
    );
  }

  Widget _buildListItemTrailing(BuildContext context, ExportColumn data, ExportConfigurationModel config) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (data.editable)
          IconButton(
            onPressed: () async {
              setState(() {
                config.delete(data);
              });
            },
            tooltip: AppLocalizations.of(context)!.delete,
            icon: const Icon(Icons.delete),
            color: Colors.red,
          ),
        IconButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
              EditExportColumnPage(
                initialDisplayName: data.columnTitle,
                initialInternalName: data.internalName,
                initialFormatPattern: data.formatPattern,
                editable: data.editable,
              )
            ));
          },
          tooltip: AppLocalizations.of(context)!.edit,
          icon: const Icon(Icons.edit)
        ),
        const Icon(Icons.drag_handle),
      ],
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

    final ExportColumn item;
    if (0 <= oldIndex && oldIndex < widget.shownItems.length) {
      item = widget.shownItems.removeAt(oldIndex);
    } else if ((widget.shownItems.length + 1) <= oldIndex && oldIndex < (widget.shownItems.length + 1 + widget.disabledItems.length)) {
      item = widget.disabledItems.removeAt(oldIndex - (widget.shownItems.length + 1));
    } else {
      assert(false, 'oldIndex outside expected boundaries');
      return;
    }

    if (newIndex < (widget.shownItems.length + 1)) {
      widget.shownItems.insert(newIndex, item);
    } else {
      newIndex -= (widget.shownItems.length + 1);
      widget.disabledItems.insert(newIndex, item);
    }

    widget.onReorder(widget.shownItems, widget.disabledItems);
  }
}

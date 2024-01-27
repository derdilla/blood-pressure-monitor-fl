import 'package:blood_pressure_app/components/dialoges/add_export_column_dialoge.dart';
import 'package:blood_pressure_app/model/export_import/column.dart';
import 'package:blood_pressure_app/model/storage/export_columns_store.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

/// Page that shows all export columns and allows adding and editing custom
/// ones.
class ExportColumnsManagementScreen extends StatelessWidget {
  /// Create a page for listing, editing and adding export columns.
  const ExportColumnsManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
      ),
      body: Consumer<ExportColumnsManager>(
        builder: (context, columnsManager, child) => ListView(
          children: [
            ExpansionTile(
              title: Text(localizations.buildIn,
                style: Theme.of(context).textTheme.titleLarge!,),
              children: [
                for (final column in columnsManager.getAllUnmodifiableColumns())
                  ListTile(
                    title: Text(column.userTitle(localizations)),
                    subtitle: column.formatPattern == null ? null : Text(column.formatPattern!),
                  ),
              ],
            ),
            ExpansionTile(
              initiallyExpanded: true,
              title: Text(localizations.custom,
                style: Theme.of(context).textTheme.titleLarge!,),
              children: [
                for (final column in columnsManager.userColumns.values)
                  ListTile(
                    title: Text(column.userTitle(localizations)),
                    subtitle: Text(column.formatPattern.toString()),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () async {
                            final settings = Provider.of<Settings>(context, listen: false);
                            final editedColumn = await showAddExportColumnDialoge(context, settings, column);
                            if (editedColumn != null) {
                              columnsManager.addOrUpdate(editedColumn);
                            }
                          },
                        ),
                        IconButton(
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(context: context,
                              builder: (context) => AlertDialog(
                                title: Text(AppLocalizations.of(context)!.confirmDelete),
                                actions: [
                                  ElevatedButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: Text(AppLocalizations.of(context)!.btnCancel),),
                                  ElevatedButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: Text(AppLocalizations.of(context)!.btnConfirm),),
                                ],
                              ),
                            ) ?? false;
                            if (confirmed) {
                              columnsManager.deleteUserColumn(column.internalIdentifier);
                            }
                          },
                          icon: const Icon(Icons.delete),
                        ),
                      ],
                    ),
                  ),
                ListTile(
                  leading: const Icon(Icons.add),
                  title: Text(localizations.addExportformat),
                  onTap: () async{
                    final settings = Provider.of<Settings>(context, listen: false);
                    ExportColumn? editedColumn = await showAddExportColumnDialoge(context, settings);
                    if (editedColumn != null) {
                      while (columnsManager.userColumns.containsKey(editedColumn!.internalIdentifier)) {
                        if (editedColumn is UserColumn) {
                          editedColumn = UserColumn.explicit('${editedColumn.internalIdentifier}I', editedColumn.csvTitle, editedColumn.formatPattern!);
                        } else {
                          assert(editedColumn is TimeColumn, 'Creation of other types not supported in dialoge.');
                          editedColumn = TimeColumn.explicit('${editedColumn.internalIdentifier}I', editedColumn.csvTitle, editedColumn.formatPattern!);
                        }
                      }
                      columnsManager.addOrUpdate(editedColumn);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

}
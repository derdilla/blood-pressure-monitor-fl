import 'package:blood_pressure_app/components/dialoges/add_export_column_dialoge.dart';
import 'package:blood_pressure_app/model/export_import/column.dart';
import 'package:blood_pressure_app/model/storage/export_columns_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

/// Page that shows all export columns and allows adding and editing custom ones.
class ExportColumnsManagementScreen extends StatelessWidget {
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
                  )
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
                    trailing: const Icon(Icons.edit),
                    onTap: () async {
                      final editedColumn = await showAddExportColumnDialoge(context, column);
                      if (editedColumn != null) {
                        columnsManager.addOrUpdate(editedColumn);
                      } // TODO: deleting
                    },
                  ),
                ListTile(
                  leading: const Icon(Icons.add),
                  title: Text(localizations.addExportformat),
                  onTap: () async{
                    UserColumn? editedColumn = await showAddExportColumnDialoge(context);
                    if (editedColumn != null) {
                      while (columnsManager.userColumns.containsKey(editedColumn!.internalIdentifier)) {
                        editedColumn = UserColumn('${editedColumn.internalIdentifier}I', editedColumn.csvTitle, editedColumn.formatPattern!);
                      }
                      columnsManager.addOrUpdate(editedColumn);
                    }
                  },
                )
              ],
            )
          ],
        )
      ),
    );
  }

}
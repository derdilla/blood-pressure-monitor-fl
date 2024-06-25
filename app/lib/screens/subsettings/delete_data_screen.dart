import 'package:blood_pressure_app/components/dialoges/confirm_deletion_dialoge.dart';
import 'package:blood_pressure_app/model/storage/export_columns_store.dart';
import 'package:blood_pressure_app/model/storage/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:health_data_store/health_data_store.dart';

/// Screen that allows mass deleting data entered in the app.
class DeleteDataScreen extends StatefulWidget {
  /// Create screen that allows mass data deletion.
  const DeleteDataScreen({super.key});

  @override
  State<DeleteDataScreen> createState() => _DeleteDataScreenState();
}

class _DeleteDataScreenState extends State<DeleteDataScreen> {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.delete),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(localizations.deleteAllSettings),
            trailing: const Icon(Icons.delete_forever),
            onTap: () async {
              final messanger = ScaffoldMessenger.of(context);
              if (await showConfirmDeletionDialoge(context, localizations.warnDeletionUnrecoverable)) {
                context.read<Settings>().reset();
                context.read<ExportSettings>().reset();
                context.read<CsvExportSettings>().reset();
                context.read<PdfExportSettings>().reset();
                context.read<IntervallStoreManager>().reset();
                context.read<ExportColumnsManager>().reset();
                messanger.showSnackBar(SnackBar(
                  content: Text(localizations.deletionConfirmed),
                ));
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.timeline),
            title: Text(localizations.deleteAllMeasurements),
            trailing: const Icon(Icons.delete_forever),
            onTap: () async {
              final messanger = ScaffoldMessenger.of(context);
              if (await showConfirmDeletionDialoge(context, localizations.warnDeletionUnrecoverable)) {
                final repo = RepositoryProvider.of<BloodPressureRepository>(context);
                final previousRecords = await repo.get(DateRange.all());
                for (final record in previousRecords) {
                  await repo.remove(record);
                }
                messanger.showSnackBar(SnackBar(
                  content: Text(localizations.deletionConfirmed),
                  action: SnackBarAction(
                    label: localizations.btnUndo,
                    onPressed: () => Future.forEach(previousRecords, repo.add),
                  ),
                ));
              }
            },
          ),
          // FIXME: delete notes
          ListTile(
            leading: const Icon(Icons.medication),
            title: Text(localizations.deleteAllMedicineIntakes),
            trailing: const Icon(Icons.delete_forever),
            onTap: () async {
              if (await showConfirmDeletionDialoge(context, localizations.warnDeletionUnrecoverable)) {
                final repo = context.read<MedicineIntakeRepository>();
                final allIntakes = await repo.get(DateRange(start: DateTime.fromMillisecondsSinceEpoch(0), end: DateTime.now()));
                for (final intake in allIntakes) {
                  await repo.remove(intake);
                }
                final messanger = ScaffoldMessenger.of(context);
                messanger.showSnackBar(SnackBar(
                  content: Text(localizations.deletionConfirmed),
                ));
              }
            },
          ),
        ],
      ),
    );
  }
}

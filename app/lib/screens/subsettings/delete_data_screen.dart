import 'package:blood_pressure_app/model/blood_pressure/model.dart';
import 'package:blood_pressure_app/model/storage/export_columns_store.dart';
import 'package:blood_pressure_app/model/storage/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:health_data_store/health_data_store.dart';
import 'package:provider/provider.dart';

/// Screen that allows
class DeleteDataScreen extends StatefulWidget {
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
        title: const Text('Delete data'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.timeline),
            title: Text(localizations.deleteAllMeasurements),
            trailing: const Icon(Icons.delete_forever),
            onTap: () async {
              final messanger = ScaffoldMessenger.of(context);
              if (await _showDeleteDialoge(context, localizations)) {
                final model = context.read<BloodPressureModel>();
                final previousRecords = await model.all;
                for (final record in previousRecords) {
                  await model.delete(record.creationTime);
                }
                messanger.showSnackBar(SnackBar(
                  content: Text(localizations.deletionConfirmed),
                  action: SnackBarAction(
                    label: localizations.btnUndo,
                    onPressed: () => model.addAll(previousRecords, context),
                  ),
                ));
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(localizations.deleteAllSettings),
            trailing: const Icon(Icons.delete_forever),
            onTap: () async {
              final messanger = ScaffoldMessenger.of(context);
              if (await _showDeleteDialoge(context, localizations)) {
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
            leading: const Icon(Icons.medication),
            title: Text(localizations.deleteAllMedicineIntakes),
            trailing: const Icon(Icons.delete_forever),
            onTap: () async {
              if (await _showDeleteDialoge(context, localizations)) {
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

  /// Show dialoge to confirm irrevocable deletion.
  Future<bool> _showDeleteDialoge(BuildContext context, AppLocalizations localizations) async => await showDialog<bool>(context: context, builder: (context) =>
    AlertDialog(
      title: Text(localizations.confirmDelete),
      content: Text(localizations.warnDeletionUnrecoverable),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.btnCancel),),
        Theme(
          data: ThemeData.from(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.red, brightness: Theme.of(context).brightness),
              useMaterial3: true,
          ),
          child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context, true),
              icon: const Icon(Icons.delete_forever),
              label: Text(AppLocalizations.of(context)!.btnConfirm),
          ),
        ),
      ],
    ),
  ) ?? false;
}

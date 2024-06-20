import 'package:blood_pressure_app/components/dialoges/add_measurement_dialoge.dart';
import 'package:blood_pressure_app/model/blood_pressure/pressure_unit.dart';
import 'package:blood_pressure_app/model/storage/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:health_data_store/health_data_store.dart';
import 'package:intl/intl.dart';

/// Display of a blood pressure measurement data.
class MeasurementListRow extends StatelessWidget {
  /// Create a display of a measurements.
  const MeasurementListRow({super.key,
    required this.data,
    required this.settings,
  });

  /// The measurement to display.
  final FullEntry data;

  /// Settings that determine general behavior.
  final Settings settings;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final formatter = DateFormat(settings.dateFormatString);
    return ExpansionTile(
      // Leading color possible
      title: _buildRow(formatter),
      childrenPadding: const EdgeInsets.only(bottom: 10),
      backgroundColor: data.color == null ? null : Color(data.color!).withAlpha(30),
      collapsedShape: data.color == null ? null : Border(
        left: BorderSide(color: Color(data.color!), width: 8)
      ),
      children: [
        ListTile(
          subtitle: Text(formatter.format(data.time)),
          title: Text(localizations.timestamp),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => context.createEntry(data),
                icon: const Icon(Icons.edit),
                tooltip: localizations.edit,
              ),
              IconButton(
                onPressed: () => _deleteEntry(settings, context, localizations),
                icon: const Icon(Icons.delete),
                tooltip: localizations.delete,
              ),
            ],
          ),
        ),
        if (data.note?.isNotEmpty ?? false)
          ListTile(
            title: Text(localizations.note),
            subtitle: Text(data.note!),
          ),
        for (final MedicineIntake intake in data.$3)
          ListTile(
            title: Text(intake.medicine.designation),
            subtitle: Text('${intake.dosis.mg}mg'), // TODO: setting for unit
            iconColor: intake.medicine.color == null ? null : Color(intake.medicine.color!),
            leading: Icon(Icons.medication),
            trailing: IconButton(
              onPressed: () async {
                final intakeRepo = RepositoryProvider.of<MedicineIntakeRepository>(context);
                if (!settings.confirmDeletion || await showConfirmDeletionDialoge(context)) {
                  await intakeRepo.remove(intake);
                }
                // TODO: undo
              },
              color: Theme.of(context).listTileTheme.iconColor,
              icon: const Icon(Icons.delete),
            ),
          ), // TODO: test
        // FIXME: remove other medicine tiles
      ],
    );
  }

  Row _buildRow(DateFormat formatter) { // TODO: is intake present
    String formatNum(num? num) => (num ?? '-').toString();
    String formatPressure(Pressure? num) => switch(settings.preferredPressureUnit) {
      PressureUnit.mmHg => formatNum(num?.mmHg),
      PressureUnit.kPa => formatNum(num?.kPa),
    };
    return Row(
      children: [
        Expanded(
          flex: 30,
          child: Text(formatPressure(data.sys)),
        ),
        Expanded(
          flex: 30,
          child: Text(formatPressure(data.dia)),
        ),
        Expanded(
          flex: 30,
          child: Text(formatNum(data.pul)),
        ),
        if (data.$3.isNotEmpty)
          Expanded(
            flex: 10,
            child: Icon(Icons.medication),
          ),
      ],
    );
  }

  void _deleteEntry(Settings settings, BuildContext context, AppLocalizations localizations) async {
    final bpRepo = RepositoryProvider.of<BloodPressureRepository>(context);
    final noteRepo = RepositoryProvider.of<NoteRepository>(context);
    final messanger = ScaffoldMessenger.of(context);
    bool confirmedDeletion = true;
    if (settings.confirmDeletion) {
      confirmedDeletion = await showConfirmDeletionDialoge(context);
    }

    if (confirmedDeletion) { // TODO: move out of model
      await bpRepo.remove(data.$1);
      await noteRepo.remove(data.$2);
      messanger.removeCurrentSnackBar();
      messanger.showSnackBar(SnackBar(
        content: Text(localizations.deletionConfirmed),
        action: SnackBarAction(
          label: localizations.btnUndo,
          onPressed: () async {
            await bpRepo.add(data.$1);
            await noteRepo.add(data.$2);
          },
        ),
      ),);
    }
  }
}

/// Show a dialoge that prompts the user to confirm a deletion.
///
/// Returns whether it is ok to proceed with deletion.
Future<bool> showConfirmDeletionDialoge(BuildContext context) async => // TODO: move to own file
  await showDialog<bool>(context: context,
    builder: (context) => AlertDialog(
      title: Text(AppLocalizations.of(context)!.confirmDelete),
      content: Text(AppLocalizations.of(context)!.confirmDeleteDesc),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(AppLocalizations.of(context)!.btnCancel),
        ),
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

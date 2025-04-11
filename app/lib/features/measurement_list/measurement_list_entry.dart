import 'package:blood_pressure_app/components/confirm_deletion_dialoge.dart';
import 'package:blood_pressure_app/components/nullable_text.dart';
import 'package:blood_pressure_app/components/pressure_text.dart';
import 'package:blood_pressure_app/data_util/entry_context.dart';
import 'package:blood_pressure_app/model/storage/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blood_pressure_app/l10n/app_localizations.dart';
import 'package:health_data_store/health_data_store.dart';
import 'package:intl/intl.dart';

/// Display of a blood pressure measurement data.
class MeasurementListRow extends StatelessWidget {
  /// Create a display of a measurements.
  const MeasurementListRow({super.key,
    required this.data,
    required this.onRequestEdit,
  });

  /// The measurement to display.
  final FullEntry data;

  /// Called when the user taps on the edit icon.
  final void Function() onRequestEdit; // TODO: consider removing in favor of context methods

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final settings = context.watch<Settings>();
    final formatter = DateFormat(settings.dateFormatString);
    return ExpansionTile(
      // Leading color possible
      title: _buildRow(formatter),
      childrenPadding: const EdgeInsets.only(bottom: 10),
      backgroundColor: data.color == null ? null : Color(data.color!).withAlpha(30),
      collapsedShape: data.color == null ? null : Border(
        left: BorderSide(color: Color(data.color!), width: 8),
      ),
      children: [
        ListTile(
          subtitle: Text(formatter.format(data.time)),
          title: Text(localizations.timestamp),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: onRequestEdit,
                icon: const Icon(Icons.edit),
                tooltip: localizations.edit,
              ),
              IconButton(
                onPressed: () => context.deleteEntry(data),
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
            leading: Icon(Icons.medication,
              color: intake.medicine.color == null ? null : Color(intake.medicine.color!)),
            trailing: IconButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final intakeRepo = RepositoryProvider.of<MedicineIntakeRepository>(context);
                if (!settings.confirmDeletion || await showConfirmDeletionDialoge(context)) {
                  await intakeRepo.remove(intake);
                }
                messenger.removeCurrentSnackBar();
                messenger.showSnackBar(SnackBar(
                  content: Text(localizations.deletionConfirmed),
                  action: SnackBarAction(
                    label: localizations.btnUndo,
                    onPressed: () => intakeRepo.add(intake),
                  ),
                ));
              },
              icon: const Icon(Icons.delete),
            ),
          ),
      ],
    );
  }

  Row _buildRow(DateFormat formatter) => Row(
    children: [
      Expanded(
        flex: 30,
        child: PressureText(data.sys),
      ),
      Expanded(
        flex: 30,
        child: PressureText(data.dia),
      ),
      Expanded(
        flex: 30,
        child: NullableText((data.pul?.toString())),
      ),
      Expanded(
        flex: 10,
        child: data.$3.isNotEmpty ? Icon(Icons.medication) : SizedBox.shrink(),
      ),
    ],
  );
}

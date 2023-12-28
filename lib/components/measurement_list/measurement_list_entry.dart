import 'package:blood_pressure_app/components/dialoges/add_measurement_dialoge.dart';
import 'package:blood_pressure_app/model/blood_pressure/model.dart';
import 'package:blood_pressure_app/model/blood_pressure/record.dart';
import 'package:blood_pressure_app/model/storage/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MeasurementListRow extends StatelessWidget {
  const MeasurementListRow({super.key, required this.record, required this.settings});

  final BloodPressureRecord record;
  final Settings settings;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final formatter = DateFormat(settings.dateFormatString);
    return ExpansionTile(
      // Leading color possible
      title: buildRow(formatter),
      childrenPadding: const EdgeInsets.only(bottom: 10),
      backgroundColor: record.needlePin?.color.withAlpha(30),
      collapsedShape: record.needlePin != null ? Border(left: BorderSide(color: record.needlePin!.color, width: 8)) : null,
      children: [
        ListTile(
          subtitle: Text(formatter.format(record.creationTime)),
          title: Text(localizations.timestamp),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () async {
                  final model = Provider.of<BloodPressureModel>(context, listen: false);
                  final entry = await showAddEntryDialoge(context,
                      Provider.of<Settings>(context, listen: false));
                  if (entry?.$1 != null) {
                    if (context.mounted) {
                      model.addAndExport(context, entry!.$1!);
                    } else {
                      model.add(entry!.$1!);
                    }
                  }
                  if (entry?.$2 != null) {
                    // TODO: save medicine intake
                  }
                },
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
        if (record.notes.isNotEmpty)
          ListTile(
            title: Text(localizations.note),
            subtitle: Text(record.notes),
          )
      ],
    );
  }

  Row buildRow(DateFormat formatter) {
    String formatNum(int? num) => (num ?? '-').toString();
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(formatNum(record.systolic)),
        ),
        Expanded(
          flex: 3,
          child: Text(formatNum(record.diastolic)),
        ),
        Expanded(
          flex: 3,
          child: Text(formatNum(record.pulse)),
        ),
      ]
    );
  }

  void _deleteEntry(Settings settings, BuildContext context, AppLocalizations localizations) async {
    final model = Provider.of<BloodPressureModel>(context, listen: false);
    final messanger = ScaffoldMessenger.of(context);
    bool confirmedDeletion = false;
    if (settings.confirmDeletion) {
      confirmedDeletion = await showDialog<bool>(context: context,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.confirmDelete),
            content: Text(AppLocalizations.of(context)!.confirmDeleteDesc),
            actions: [
              ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(AppLocalizations.of(context)!.btnCancel)),
              ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(AppLocalizations.of(context)!.btnConfirm)),
            ],
          )
      ) ?? false;
    } else {
      confirmedDeletion = true;
    }

    if (confirmedDeletion) {
      model.delete(record.creationTime);
      messanger.removeCurrentSnackBar();
      messanger.showSnackBar(SnackBar(
        duration: const Duration(seconds: 5),
        content: Text(localizations.deletionConfirmed),
        action: SnackBarAction(
          label: localizations.btnUndo,
          onPressed: () => model.add(record),
        ),
      ));
    }
  }
}

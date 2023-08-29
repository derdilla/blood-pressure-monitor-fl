import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:blood_pressure_app/model/settings_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// TODO: finish
class MeasurementListRow extends StatelessWidget {
  final BloodPressureRecord record;

  const MeasurementListRow({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return Consumer<Settings>(
      builder: (context, settings, child) {
        final formatter = DateFormat(settings.dateFormatString);
        return ExpansionTile(
          // Leading color possible
          title: buildRow(formatter),
          childrenPadding: EdgeInsets.only(bottom: 10),
          children: [
            Row(
              children: [
                Text(formatter.format(record.creationTime), textAlign: TextAlign.right,),
                const Spacer(),
                const MeasurementItemMenu()
              ],
            ),
           if (record.notes.isNotEmpty)
             Align(
               alignment: Alignment.centerLeft,
               child: Text(record.notes),
             )
          ],
        );
      },
    );
  }

  Row buildRow(DateFormat formatter) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(record.systolic.toString()),
        ),
        Expanded(
          flex: 3,
          child: Text(record.diastolic.toString()),
        ),
        Expanded(
          flex: 3,
          child: Text(record.pulse.toString()),
        ),
      ]
    );
  }
}

class MeasurementItemMenu extends StatelessWidget {
  const MeasurementItemMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return PopupMenuButton<MeasurementItemMenuOption>( // TODO: implement
      itemBuilder: (context) => [
        PopupMenuItem<MeasurementItemMenuOption>(
          value: MeasurementItemMenuOption.edit,
          child: Text(localizations.edit),
        ),
        PopupMenuItem<MeasurementItemMenuOption>(
          value: MeasurementItemMenuOption.delete,
          child: Text(localizations.delete),
        ),
      ],
    );
  }
}

enum MeasurementItemMenuOption {
  edit,
  delete
}
import 'package:blood_pressure_app/components/measurement_list/measurement_list_entry.dart';
import 'package:blood_pressure_app/model/blood_pressure/record.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MeasurementList extends StatelessWidget {
  const MeasurementList({super.key, required this.settings, required this.records});

  final Settings settings;
  final List<BloodPressureRecord> records;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          children: [
            Row(
              children: [
                const Expanded(
                  flex: 4,
                  child: SizedBox()),
                Expanded(
                    flex: 30,
                    child: Text(localizations.sysLong,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.bold, color: settings.sysColor))),
                Expanded(
                    flex: 30,
                    child: Text(localizations.diaLong,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.bold, color: settings.diaColor))),
                Expanded(
                    flex: 30,
                    child: Text(localizations.pulLong,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.bold, color: settings.pulColor))),
                const Expanded(
                    flex: 20,
                    child: SizedBox()),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Divider(
              height: 0,
              thickness: 2,
              color: Theme.of(context).colorScheme.primaryContainer,
            )
          ]
        ),
        Expanded(
          child: ListView.builder(
            // Fix actions blocked by floating buttons on different screens
            // and font sizes by adding empty offset to bottom.
            padding: const EdgeInsets.only(bottom: 300),
            itemCount: records.length,
            itemBuilder: (context, idx) {
              return MeasurementListRow(
                record: records[idx],
                settings: settings,
              );
            },
          ),
        )
      ]
    );
  }
}
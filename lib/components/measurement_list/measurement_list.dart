import 'package:blood_pressure_app/components/measurement_list/measurement_list_entry.dart';
import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:blood_pressure_app/model/storage/intervall_store.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:blood_pressure_app/screens/blood_pressure_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MeasurementList extends StatelessWidget {
  const MeasurementList({super.key, required this.settings});

  final Settings settings;

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MeasurementListHeader(settings: settings,),
          Expanded(
              child: BloodPressureBuilder(
                rangeType: IntervallStoreManagerLocation.mainPage,
                onData: (context, data) {
                  return MeasurementListEntries(
                    entries: data,
                    settings: settings,
                  );
                },
              )
          )
        ]
    );
  }
}


class MeasurementListEntries extends StatelessWidget {
  const MeasurementListEntries({super.key, required this.entries, required this.settings});

  final List<BloodPressureRecord> entries;

  final Settings settings;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // Fix actions blocked by floating buttons on different screens and font sizes
      padding: const EdgeInsets.only(bottom: 300),
      itemCount: entries.length,
      itemBuilder: (context, idx) {
        return MeasurementListRow(
          record: entries[idx],
          settings: settings,
        );
      },
    );
  }
}

class MeasurementListHeader extends StatelessWidget {
  const MeasurementListHeader({super.key, required this.settings});

  final Settings settings;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Column(
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
        ]);
  }

}
import 'package:blood_pressure_app/components/measurement_list/intake_list_entry.dart';
import 'package:blood_pressure_app/components/measurement_list/measurement_list_entry.dart';
import 'package:blood_pressure_app/model/blood_pressure/medicine/intake_history.dart';
import 'package:blood_pressure_app/model/blood_pressure/medicine/medicine_intake.dart';
import 'package:blood_pressure_app/model/blood_pressure/record.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class MeasurementList extends StatelessWidget {
  const MeasurementList({super.key,
    required this.settings,
    required this.records,
    required this.intakes,
  });

  final Settings settings;

  /// Records to display.
  final List<BloodPressureRecord> records;

  /// Medicine intakes to list.
  ///
  /// Will get merged with blood pressure records.
  final List<MedicineIntake> intakes;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final entries = [];
    entries.addAll(records);
    entries.addAll(intakes);
    entries.sort((e1, e2) {
      if (e2 is BloodPressureRecord && e1 is BloodPressureRecord) return e2.creationTime.compareTo(e1.creationTime);
      if (e2 is BloodPressureRecord && e1 is MedicineIntake) return e2.creationTime.compareTo(e1.timestamp);
      if (e2 is MedicineIntake && e1 is BloodPressureRecord) return e2.timestamp.compareTo(e1.creationTime);
      if (e2 is MedicineIntake && e1 is MedicineIntake) return e2.timestamp.compareTo(e1.timestamp);
      assert(false);
      return 0;
    });
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          children: [
            Row(
              children: [
                const Expanded(
                  flex: 4,
                  child: SizedBox(),),
                Expanded(
                    flex: 30,
                    child: Text(localizations.sysLong,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.bold, color: settings.sysColor),),),
                Expanded(
                    flex: 30,
                    child: Text(localizations.diaLong,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.bold, color: settings.diaColor),),),
                Expanded(
                    flex: 30,
                    child: Text(localizations.pulLong,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.bold, color: settings.pulColor),),),
                const Expanded(
                    flex: 20,
                    child: SizedBox(),),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Divider(
              height: 0,
              thickness: 2,
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
          ],
        ),
        Expanded(
          child: ListView.builder(
            // Fix actions blocked by floating buttons on different screens
            // and font sizes by adding empty offset to bottom.
            padding: const EdgeInsets.only(bottom: 300),
            itemCount: entries.length,
            itemBuilder: (context, idx) {
              if (entries[idx] is BloodPressureRecord) {
                return MeasurementListRow(
                  record: entries[idx],
                  settings: settings,
                );
              } else {
                assert(entries[idx] is MedicineIntake);
                return IntakeListEntry(
                  intake: entries[idx],
                  settings: settings,
                  delete: () {
                    // TODO: move out of model
                    final history = Provider.of<IntakeHistory>(context, listen: false);
                    history.deleteIntake(entries[idx]);
                  },
                );
              }

            },
          ),
        ),
      ],
    );
  }
}
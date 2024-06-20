import 'package:blood_pressure_app/components/measurement_list/measurement_list_entry.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:health_data_store/health_data_store.dart';

/// List that renders measurements and medicine intakes.
///
/// Contains a headline with information about the meaning of "columns".
class MeasurementList extends StatelessWidget {
  /// Create a list to display measurements and intakes.
  const MeasurementList({super.key,
    required this.settings,
    required this.records,
    required this.notes,
    required this.intakes,
  });

  /// Settings that determine general behavior.
  final Settings settings;

  /// Records to display.
  final List<BloodPressureRecord> records;

  /// Complementary notes info to show.
  final List<Note> notes;

  /// Medicine intake info to show.
  final List<MedicineIntake> intakes;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final List<FullEntry> entries = [];
    for (final r in records) {
      final n = notes.where((n) => n.time == r.time).firstOrNull ?? Note(time: r.time);
      final i = intakes.where((n) => n.time == r.time).toList();
      entries.add((r, n, i));
    }
    Set<DateTime> times = entries.map((e) => e.time).toSet();
    final remainingNotes = notes.where((n) => !times.contains(n.time));
    for (final n in remainingNotes) {
      final i = intakes.where((n) => n.time == n.time).toList();
      entries.add((BloodPressureRecord(time: n.time), n, i));
    }
    times = entries.map((e) => e.time).toSet();
    final remainingIntakes = intakes.where((i) => !times.contains(i.time));
    for (final i in groupBy(remainingIntakes, (i) => i.time).values) {
      entries.add((BloodPressureRecord(time: i.first.time), Note(time: i.first.time), i));
    }
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
            itemBuilder: (context, idx) => MeasurementListRow(
              data: entries[idx],
              settings: settings,
            ),
          ),
        ),
      ],
    );
  }
}

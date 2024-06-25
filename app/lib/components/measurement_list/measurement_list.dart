import 'package:blood_pressure_app/components/dialoges/add_measurement_dialoge.dart';
import 'package:blood_pressure_app/components/measurement_list/measurement_list_entry.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
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
    required this.entries,
  });

  /// Settings that determine general behavior.
  final Settings settings;

  /// Entries sorted with newest comming first.
  final List<FullEntry> entries;

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
              onRequestEdit: () => context.createEntry(entries[idx]),
            ),
          ),
        ),
      ],
    );
  }
}

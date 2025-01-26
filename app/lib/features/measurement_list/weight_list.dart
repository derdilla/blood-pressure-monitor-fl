import 'package:blood_pressure_app/components/confirm_deletion_dialoge.dart';
import 'package:blood_pressure_app/data_util/entry_context.dart';
import 'package:blood_pressure_app/data_util/repository_builder.dart';
import 'package:blood_pressure_app/model/storage/storage.dart';
import 'package:blood_pressure_app/model/weight_unit.dart';
import 'package:flutter/material.dart';
import 'package:health_data_store/health_data_store.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// List of weights recorded in the contexts [BodyweightRepository].
class WeightList extends StatelessWidget {
  /// Create a list of weights
  const WeightList({super.key, required this.rangeType});

  /// The location from which the displayed interval is taken.
  final IntervalStoreManagerLocation rangeType;

  @override
  Widget build(BuildContext context) {
    final format = DateFormat(context.select<Settings, String>((s) => s.dateFormatString));
    final weightUnit = context.select((Settings s) => s.weightUnit);
    return RepositoryBuilder<BodyweightRecord, BodyweightRepository>(
      rangeType: rangeType,
      onData: (context, records) {
        records.sort((a, b) => b.time.compareTo(a.time));
        return ListView.builder(
          itemCount: records.length,
          itemBuilder: (context, idx) => ListTile(
            title: Text(_buildWeightText(weightUnit, records[idx].weight)),
            subtitle: Text(format.format(records[idx].time)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () async {
                    final repo = context.read<BodyweightRepository>();
                    if ((!context.read<Settings>().confirmDeletion) || await showConfirmDeletionDialoge(context)) {
                      await repo.remove(records[idx]);
                    }
                  },
                ),
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => context.createEntry((
                  timestamp: records[idx].time,
                  note: null,
                  record: null,
                  intake: null,
                  weight: records[idx],
                  )),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _buildWeightText(WeightUnit u, Weight w) {
    String weightStr = u.extract(w).toStringAsFixed(2);
    if (weightStr.endsWith('0')) weightStr = weightStr.substring(0, weightStr.length - 1);
    if (weightStr.endsWith('0')) weightStr = weightStr.substring(0, weightStr.length - 1);
    if (weightStr.endsWith('.')) weightStr = weightStr.substring(0, weightStr.length - 1);

    return '$weightStr ${u.name}';
  }
}

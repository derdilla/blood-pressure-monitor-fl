import 'package:blood_pressure_app/components/confirm_deletion_dialoge.dart';
import 'package:blood_pressure_app/data_util/repository_builder.dart';
import 'package:blood_pressure_app/model/storage/storage.dart';
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
    return RepositoryBuilder<BodyweightRecord, BodyweightRepository>(
      rangeType: rangeType,
      onData: (context, records) {
        records.sort((a, b) => b.time.compareTo(a.time));
        return ListView.builder(
          itemCount: records.length,
          itemBuilder: (context, idx) => ListTile(
            title: Text(_buildWeightText(records[idx].weight)),
            subtitle: Text(format.format(records[idx].time)),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final repo = context.read<BodyweightRepository>();
                if ((!context.read<Settings>().confirmDeletion) || await showConfirmDeletionDialoge(context)) {
                  await repo.remove(records[idx]);
                }
              }
            ),
          ),
        );
      },
    );
  }

  String _buildWeightText(Weight w) {
    String weightStr = w.kg.toStringAsFixed(2);
    if (weightStr.endsWith('0')) weightStr = weightStr.substring(0, weightStr.length - 1);
    if (weightStr.endsWith('0')) weightStr = weightStr.substring(0, weightStr.length - 1);
    if (weightStr.endsWith('.')) weightStr = weightStr.substring(0, weightStr.length - 1);
    // TODO: preferred weight unit
    return '$weightStr kg';
  }
}

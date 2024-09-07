import 'package:blood_pressure_app/data_util/repository_builder.dart';
import 'package:blood_pressure_app/model/storage/storage.dart';
import 'package:flutter/material.dart';
import 'package:health_data_store/health_data_store.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// List of weights recorded in the contexts [BodyweightRepository].
class BodyweightList extends StatelessWidget {
  /// Create a list of weights
  const BodyweightList({super.key, required this.rangeType});

  final IntervalStoreManagerLocation rangeType;

  @override
  Widget build(BuildContext context) {
    final format = DateFormat(context.select<Settings, String>((s) => s.dateFormatString));
    return RepositoryBuilder<BodyweightRecord, BodyweightRepository>(
      rangeType: rangeType,
      onData: (context, records) => ListView.builder(
        itemCount: records.length,
        itemBuilder: (context, idx) => ListTile(
          title: Text('${records[idx].weight.kg.toStringAsFixed(2)} kg'), // TODO: prefered unit
          subtitle: Text(format.format(records[idx].time))
        ),
      ),
    );
  }
}

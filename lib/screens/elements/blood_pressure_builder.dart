import 'dart:collection';

import 'package:blood_pressure_app/components/consistent_future_builder.dart';
import 'package:blood_pressure_app/model/blood_pressure/model.dart';
import 'package:blood_pressure_app/model/blood_pressure/record.dart';
import 'package:blood_pressure_app/model/storage/intervall_store.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Shorthand class for getting the blood pressure values.
class BloodPressureBuilder extends StatelessWidget {
  /// Create a loader for the measurements in the current range.
  const BloodPressureBuilder({
    super.key,
    required this.onData,
    required this.rangeType,
  });

  /// The build strategy once the measurement are loaded.
  final Widget Function(BuildContext context, UnmodifiableListView<BloodPressureRecord> records) onData;

  /// Which measurements to load.
  final IntervallStoreManagerLocation rangeType;
  
  @override
  Widget build(BuildContext context) => Consumer<BloodPressureModel>(
      builder: (context, model, child) =>
        Consumer<IntervallStoreManager>(
          builder: (context, intervallManager, child) {
            final range = intervallManager.get(rangeType).currentRange;
            return ConsistentFutureBuilder<UnmodifiableListView<BloodPressureRecord>>(
              future: model.getInTimeRange(range.start, range.end),
              onData: onData,
            );
          },
        ),
    );
  
}

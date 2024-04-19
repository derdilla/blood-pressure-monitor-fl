import 'dart:collection';

import 'package:blood_pressure_app/components/repository_builder.dart';
import 'package:blood_pressure_app/model/storage/intervall_store.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:health_data_store/health_data_store.dart';

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
  Widget build(BuildContext context) =>
    RepositoryBuilder<BloodPressureRecord, BloodPressureRepository>(
      rangeType: rangeType,
      // TODO: Figure out why type safety isn't possible. (see home_screen for more info)
      onData: (context, List<dynamic> data) =>
        onData(context, UnmodifiableListView(data.cast())),
  );
  
}

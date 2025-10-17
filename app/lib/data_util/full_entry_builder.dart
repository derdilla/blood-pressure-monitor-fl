import 'package:blood_pressure_app/data_util/repository_builder.dart';
import 'package:blood_pressure_app/model/storage/interval_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_data_store/health_data_store.dart';

/// Shorthand class for getting a [rangeType]s [FullEntry] values.
class FullEntryBuilder extends StatelessWidget {
  /// Create a loader for getting a [rangeType]s [FullEntry] values.
  ///
  /// Provide either [onEntries] or [onData].
  const FullEntryBuilder({
    super.key,
    this.onEntries,
    this.onData,
    required this.rangeType,
  }) : assert((onEntries == null) != (onData == null), 'Provide either of the builders.');

  /// Builder using a sorted list of full entries.
  final Widget Function(BuildContext context, List<FullEntry> entries)? onEntries;

  /// Builder using data from the main categories.
  final Widget Function(BuildContext context, List<BloodPressureRecord> records, List<MedicineIntake> intakes, List<Note> notes)? onData;

  /// Range type to load entries from.
  final IntervalStoreManagerLocation rangeType;

  @override
  Widget build(BuildContext context) => RepositoryBuilder<BloodPressureRecord, BloodPressureRepository>(
    rangeType: rangeType,
    onData: (context, records) => RepositoryBuilder<MedicineIntake, MedicineIntakeRepository>(
      rangeType: rangeType,
      onData: (BuildContext context, List<MedicineIntake> intakes) => RepositoryBuilder<Note, NoteRepository>(
        rangeType: rangeType,
        onData: (BuildContext context, List<Note> notes) {
          final manager = context.watch<IntervalStoreManager>();
          final timeLimitRange = manager.get(rangeType).timeLimitRange;
          if (timeLimitRange != null) {
            records = records.where((r) {
              final time = TimeOfDay.fromDateTime(r.time);
              return time.isAfter(timeLimitRange.start) && time.isBefore(timeLimitRange.end);
            }).toList();
            intakes = intakes.where((i) {
              final time = TimeOfDay.fromDateTime(i.time);
              return time.isAfter(timeLimitRange.start) && time.isBefore(timeLimitRange.end);
            }).toList();
            notes = notes.where((n) {
              final time = TimeOfDay.fromDateTime(n.time);
              return time.isAfter(timeLimitRange.start) && time.isBefore(timeLimitRange.end);
            }).toList();
          }

          if (onData != null) return onData!(context, records, intakes, notes);

          final entries = FullEntryList.merged(records, notes, intakes);
          entries.sort((a, b) => b.time.compareTo(a.time)); // newest first
          return onEntries!(context, entries);
        },
      ),
    ),
  );
}

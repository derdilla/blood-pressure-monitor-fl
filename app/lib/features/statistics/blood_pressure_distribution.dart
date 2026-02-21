import 'package:blood_pressure_app/features/statistics/value_distribution.dart';
import 'package:blood_pressure_app/l10n/app_localizations.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:health_data_store/health_data_store.dart';
import 'package:provider/provider.dart';

/// Viewer for [ValueDistribution]s from [BloodPressureRecord]s.
///
/// Displays a tab bar with different value distributions for available sys, dia
/// and pul values from [BloodPressureRecord]s.
class BloodPressureDistribution extends StatefulWidget {
  /// Create a [ValueDistribution] viewer of the data of measurements.
  const BloodPressureDistribution({
    super.key,
    required this.records,
  });

  /// All records to include in statistics computations.
  ///
  /// When a records includes null values, those values are left out for
  /// computing this statistic. This means that no filtering of passed records
  /// is required.
  final Iterable<BloodPressureRecord> records;

  @override
  State<BloodPressureDistribution> createState() =>
      _BloodPressureDistributionState();
}

class _BloodPressureDistributionState extends State<BloodPressureDistribution>
    with TickerProviderStateMixin {

  late final TabController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 3, vsync: this);
    _controller.addListener(() => setState((){}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(50),
          ),
          child: TabBar.secondary(
            labelPadding: const EdgeInsets.symmetric(vertical: 16),
            indicator: BoxDecoration(
              color: switch(_controller.index) {
                0 => context.watch<Settings>().sysColor,
                1 => context.watch<Settings>().diaColor,
                2 => context.watch<Settings>().pulColor,
                _ => Theme.of(context).colorScheme.primaryContainer,
              },
              borderRadius: BorderRadius.circular(50),
            ),
            dividerHeight: 0,
            controller: _controller,
            tabs: [
              Text(localizations.sysLong),
              Text(localizations.diaLong),
              Text(localizations.pulLong),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _controller,
            children: [
              // Preferred pressure unit can be ignored as values are relative.
              ValueDistribution(
                key: const Key('sys-dist'),
                values: widget.records.map((e) => e.sys?.mmHg).whereNotNull(),
                color: context.select<Settings, Color>((s) => s.sysColor),
              ),
              ValueDistribution(
                key: const Key('dia-dist'),
                values: widget.records.map((e) => e.dia?.mmHg).whereNotNull(),
                color: context.select<Settings, Color>((s) => s.diaColor),
              ),
              ValueDistribution(
                key: const Key('pul-dist'),
                values: widget.records.map((e) => e.pul).whereNotNull(),
                color: context.select<Settings, Color>((s) => s.pulColor),
              ),
            ],
          ),
        ),
      ],
    );
  }

}

import 'package:blood_pressure_app/features/statistics/value_distribution.dart';
import 'package:blood_pressure_app/l10n/app_localizations.dart';
import 'package:blood_pressure_app/model/blood_pressure/pressure_unit.dart';
import 'package:blood_pressure_app/model/storage/settings.dart';
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

  late final TabController _valueTypeCtrl;
  late final TabController _modeCtrl;
  
  @override
  void initState() {
    super.initState();
    _valueTypeCtrl = TabController(length: 3, vsync: this);
    _modeCtrl = TabController(length: 2, vsync: this);
    _valueTypeCtrl.addListener(() => setState((){}));
    _modeCtrl.addListener(() => setState((){}));
  }

  @override
  void dispose() {
    _valueTypeCtrl.dispose();
    _modeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<Settings>();
    final localizations = AppLocalizations.of(context)!;
    return Column(
      spacing: 4.0,
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
              color: switch(_valueTypeCtrl.index) {
                0 => settings.sysColor,
                1 => settings.diaColor,
                2 => settings.pulColor,
                _ => Theme.of(context).colorScheme.primaryContainer,
              },
              borderRadius: BorderRadius.circular(50),
            ),
            dividerHeight: 0,
            controller: _valueTypeCtrl,
            tabs: [
              Text(localizations.sysLong),
              Text(localizations.diaLong),
              Text(localizations.pulLong),
            ],
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(50),
          ),
          child: TabBar.secondary(
            labelPadding: const EdgeInsets.symmetric(vertical: 12),
            indicator: BoxDecoration(
              color: Theme.of(context).highlightColor,
              borderRadius: BorderRadius.circular(50),
            ),
            dividerHeight: 0,
            controller: _modeCtrl,
            tabs: [
              Text(localizations.average),
              Text(localizations.median),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _valueTypeCtrl,
            children: [
              // Preferred pressure unit can be ignored as values are relative.
              ValueDistribution(
                key: const Key('sys-dist'),
                values: widget.records.map((e) => e.sys
                  ?.inUnit(settings.preferredPressureUnit)).nonNulls.toList(),
                color: context.select<Settings, Color>((s) => s.sysColor),
                mode: _modeFromIndex(_modeCtrl.index),
              ),
              ValueDistribution(
                key: const Key('dia-dist'),
                values: widget.records.map((e) => e.dia
                  ?.inUnit(settings.preferredPressureUnit)).nonNulls.toList(),
                color: context.select<Settings, Color>((s) => s.diaColor),
                mode: _modeFromIndex(_modeCtrl.index),
              ),
              ValueDistribution(
                key: const Key('pul-dist'),
                values: widget.records.map((e) => e.pul).nonNulls.toList(),
                color: context.select<Settings, Color>((s) => s.pulColor),
                mode: _modeFromIndex(_modeCtrl.index),
              ),
            ],
          ),
        ),
      ],
    );
  }

  GraphMode _modeFromIndex(int index) => switch (index) {
    0 => GraphMode.avgerage,
    1 => GraphMode.median,
    _ => GraphMode.avgerage,
  };

}

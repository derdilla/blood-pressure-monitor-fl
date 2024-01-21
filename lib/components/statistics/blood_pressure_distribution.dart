// TODO: test

import 'package:blood_pressure_app/components/statistics/value_distribution.dart';
import 'package:blood_pressure_app/model/blood_pressure/record.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Manager of [ValueDistribution]s for multiple [BloodPressureRecord]s.
class BloodPressureDistribution extends StatefulWidget {
  /// Create a manager for [ValueDistribution] for a records.
  const BloodPressureDistribution({
    super.key,
    required this.records,
    required this.settings,
  });

  /// All records to include in statistics computations.
  final Iterable<BloodPressureRecord> records;

  /// Settings used to determine colors.
  final Settings settings;

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
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(50),
            ),
            indicatorWeight: 0,
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
              ValueDistribution(
                key: const Key('sys-dist'),
                values: widget.records.map((e) => e.systolic).whereNotNull(),
                color: widget.settings.sysColor,
              ),
              ValueDistribution(
                key: const Key('dia-dist'),
                values: widget.records.map((e) => e.diastolic).whereNotNull(),
                color: widget.settings.diaColor,
              ),
              ValueDistribution(
                key: const Key('pul-dist'),
                values: widget.records.map((e) => e.pulse).whereNotNull(),
                color: widget.settings.pulColor,
              ),
            ],
          ),
        )
        // TODO: content
      ],
    );
  }
  
}
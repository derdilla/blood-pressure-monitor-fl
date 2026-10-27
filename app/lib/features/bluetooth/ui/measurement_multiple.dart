import 'dart:math';

import 'package:blood_pressure_app/features/bluetooth/logic/characteristics/ble_measurement_data.dart';
import 'package:blood_pressure_app/features/bluetooth/ui/input_card.dart';
import 'package:blood_pressure_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Indication of a successful bluetooth read that returned multiple measurements.
///
class MeasurementMultiple extends StatelessWidget {
  /// Indicate a successful read while taking a bluetooth measurement.
  const MeasurementMultiple({
    super.key,
    required this.onClosed,
    required this.onSelect,
    required this.onSelectAll,
    required this.measurements,
    this.reviewNotice,
  });

  /// All measurements decoded from bluetooth.
  final List<BleMeasurementData> measurements;

  final String? reviewNotice;

  /// Called when the user requests closing.
  final void Function() onClosed;

  /// Called when user selects a measurement
  final void Function(BleMeasurementData data) onSelect;

  /// Called when the user chooses to import every measurement at once.
  final void Function(List<BleMeasurementData> data) onSelectAll;

  Widget _buildReviewNotice(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber, color: colors.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(child: Text(reviewNotice!,
              style: TextStyle(color: colors.onErrorContainer))),
        ],
      ),
    );
  }

  Widget _buildMeasurementTile(
    BuildContext context,
    int index,
    BleMeasurementData data,
  ) {
    final localizations = AppLocalizations.of(context)!;
    return ListTile(
      title: Text(
        data.timestamp?.toIso8601String() ??
            localizations.measurementIndex(index + 1),
      ),
      subtitle: Text(() {
        String str = '';
        if (data.userID != null) {
          str += '${localizations.userID}: ${data.userID}, ';
        }
        str +=
            '${localizations.bloodPressure}: ${data.systolic.round()}/${data.diastolic.round()}';
        if (data.pulse != null) {
          str += ', ${localizations.pulLong}: ${data.pulse?.round()}';
        }
        return str;
      }()),
      trailing: FilledButton(
        onPressed: () => onSelect(data),
        child: Text(localizations.select),
      ),
      onTap: () => onSelect(data),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Sort measurements so latest measurement is on top of the list
    final sortedMeasurements = measurements.toList()
      ..sort((a, b) {
        final aTimestamp = a.timestamp?.microsecondsSinceEpoch;
        final bTimestamp = b.timestamp?.microsecondsSinceEpoch;

        if (aTimestamp == bTimestamp) {
          return 0;
        }

        if (aTimestamp == null) {
          return 1;
        }

        if (bTimestamp == null) {
          return -1;
        }

        return aTimestamp > bTimestamp ? -1 : 1;
      });

    final localizations = AppLocalizations.of(context)!;
    final importAllButton = Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: () => onSelectAll(sortedMeasurements),
          icon: const Icon(Icons.download),
          label: Text(localizations.importAll(measurements.length)),
        ),
      ),
    );
    return InputCard(
      onClosed: onClosed,
      title: Text(
        localizations.selectMeasurementTitle,
        maxLines: reviewNotice != null ? 1 : null,
        overflow: reviewNotice != null ? TextOverflow.ellipsis : null,
      ),
      child: reviewNotice != null
          ? LayoutBuilder(
              builder: (context, constraints) => ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: min(
                    400.0,
                    constraints.hasBoundedHeight
                        ? constraints.maxHeight
                        : MediaQuery.of(context).size.height,
                  ),
                ),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    _buildReviewNotice(context),
                    importAllButton,
                    for (final (index, data) in sortedMeasurements.indexed)
                      _buildMeasurementTile(context, index, data),
                  ],
                ),
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                importAllButton,
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: min(400.0, MediaQuery.of(context).size.height),
                  ),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (final (index, data) in sortedMeasurements.indexed)
                        _buildMeasurementTile(context, index, data),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

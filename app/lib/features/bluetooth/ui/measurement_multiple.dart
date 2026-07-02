import 'package:blood_pressure_app/features/bluetooth/logic/characteristics/ble_measurement_data.dart';
import 'package:blood_pressure_app/features/bluetooth/ui/input_card.dart';
import 'package:blood_pressure_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Indication of a successful bluetooth read that returned multiple measurements.
///
class MeasurementMultiple extends StatelessWidget {
  /// Indicate a successful read while taking a bluetooth measurement.
  const MeasurementMultiple({super.key,
    required this.onClosed,
    required this.onSelect,
    required this.onSelectAll,
    required this.measurements,
  });

  /// All measurements decoded from bluetooth.
  final List<BleMeasurementData> measurements;

  /// Called when the user requests closing.
  final void Function() onClosed;

  /// Called when user selects a measurement
  final void Function(BleMeasurementData data) onSelect;

  /// Called when the user chooses to import every measurement at once.
  final void Function(List<BleMeasurementData> data) onSelectAll;
  
  Widget _buildMeasurementTile(BuildContext context, int index, BleMeasurementData data) {
    final localizations = AppLocalizations.of(context)!;
    return ListTile(
      title: Text(data.timestamp?.toIso8601String() ?? localizations.measurementIndex(index + 1)),
      subtitle: Text(() {
        String str = '';
        if (data.userID != null) {
          str += '${localizations.userID}: ${data.userID}, ';
        }
        str += '${localizations.bloodPressure}: ${data.systolic.round()}/${data.diastolic.round()}';
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
    measurements.sort((a, b) {
      final aTimestamp = a.timestamp?.microsecondsSinceEpoch;
      final bTimestamp = b.timestamp?.microsecondsSinceEpoch;

      if (aTimestamp == bTimestamp) {
        // don't sort when a & b are equal (either both null or equal value)
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
  return InputCard(
      onClosed: onClosed,
      title: Text(localizations.selectMeasurementTitle),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => onSelectAll(measurements),
                icon: const Icon(Icons.download),
                label: Text(localizations.importAll(measurements.length)),
              ),
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 300),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final (index, data) in measurements.indexed)
                    _buildMeasurementTile(context, index, data),
                ]
              ),
            ),
          ),
        ],
      ),
    );
  }
}

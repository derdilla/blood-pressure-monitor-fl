import 'package:blood_pressure_app/features/bluetooth/logic/characteristics/ble_measurement_data.dart';
import 'package:blood_pressure_app/features/bluetooth/ui/input_card.dart';
import 'package:blood_pressure_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Indication of a successful bluetooth measurement.
class MeasurementSuccess extends StatelessWidget {
  /// Indicate a successful while taking a bluetooth measurement.
  const MeasurementSuccess({super.key,
    required this.onTap,
    required this.data,
  });

  /// Data decoded from bluetooth.
  final BleMeasurementData data;

  /// Called when the user requests closing.
  final void Function() onTap;
  
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: InputCard(
      onClosed: onTap,
      child: Center(
        child: ListTileTheme(
          data: const ListTileThemeData(
            iconColor: Colors.orange,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.done, color: Colors.green),
              const SizedBox(height: 8,),
              Text(AppLocalizations.of(context)!.measurementSuccess,
                style: Theme.of(context).textTheme.titleMedium,),
              const SizedBox(height: 8,),
              ListTile(
                title: Text(AppLocalizations.of(context)!.meanArterialPressure),
                subtitle: Text(data.meanArterialPressure.round().toString()),
              ),
              if (data.userID != null)
                ListTile(
                  title: Text(AppLocalizations.of(context)!.userID),
                  subtitle: Text(data.userID!.toString()),
                ),
              if (data.status?.bodyMovementDetected ?? false)
                ListTile(
                  title: Text(AppLocalizations.of(context)!.bodyMovementDetected),
                  leading: const Icon(Icons.directions_walk),
                ),
              if (data.status?.cuffTooLose ?? false)
                ListTile(
                  title: Text(AppLocalizations.of(context)!.cuffTooLoose),
                  leading: const Icon(Icons.space_bar),
                ),
              if (data.status?.improperMeasurementPosition ?? false)
                ListTile(
                  title: Text(AppLocalizations.of(context)!.improperMeasurementPosition),
                  leading: const Icon(Icons.emoji_people),
                ),
              if (data.status?.irregularPulseDetected ?? false)
                ListTile(
                  title: Text(AppLocalizations.of(context)!.irregularPulseDetected),
                  leading: const Icon(Icons.heart_broken),
                ),
              if (data.status?.pulseRateExceedsUpperLimit ?? false)
                ListTile(
                  title: Text(AppLocalizations.of(context)!.pulseRateExceedsUpperLimit),
                  leading: const Icon(Icons.monitor_heart),
                ),
              if (data.status?.pulseRateIsLessThenLowerLimit ?? false)
                ListTile(
                  title: Text(AppLocalizations.of(context)!.pulseRateLessThanLowerLimit),
                  leading: const Icon(Icons.monitor_heart),
                ),
            ],
          ),
        ),
      ),
    ),
  );
  
}

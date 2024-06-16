import 'package:blood_pressure_app/bluetooth/characteristics/ble_measurement_data.dart';
import 'package:blood_pressure_app/components/bluetooth_input/input_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
          data: ListTileThemeData(
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
                title: Text('Mean arterial pressure'), // TODO: localizations and testing
                subtitle: Text(data.meanArterialPressure.toString()),
              ),
              if (data.userID != null)
                ListTile(
                  title: Text('User ID'),
                  subtitle: Text(data.userID!.toString()),
                ),
              if (data.status?.bodyMovementDetected ?? false)
                ListTile(
                  title: Text('Body movement detected'),
                  leading: Icon(Icons.directions_walk),
                ),
              if (data.status?.cuffTooLose ?? false)
                ListTile(
                  title: Text('Cuff too loose'),
                  leading: Icon(Icons.space_bar),
                ),
              if (data.status?.improperMeasurementPosition ?? false)
                ListTile(
                  title: Text('Improper measurement position'),
                  leading: Icon(Icons.emoji_people),
                ),
              if (data.status?.irregularPulseDetected ?? false)
                ListTile(
                  title: Text('Irregular pulse detected'),
                  leading: Icon(Icons.heart_broken),
                ),
              if (data.status?.pulseRateExceedsUpperLimit ?? false)
                ListTile(
                  title: Text('Pulse rate exceeds upper limit'),
                  leading: Icon(Icons.monitor_heart),
                ),
              if (data.status?.pulseRateIsLessThenLowerLimit ?? false)
                ListTile(
                  title: Text('Pulse rate is less than lower limit'),
                  leading: Icon(Icons.monitor_heart),
                ),
              const SizedBox(height: 8,),
            ],
          ),
        ),
      ),
    ),
  );
  
}

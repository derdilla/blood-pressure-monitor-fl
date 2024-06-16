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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.done, color: Colors.green),
            const SizedBox(height: 8,),
            Text(AppLocalizations.of(context)!.measurementSuccess),
            const SizedBox(height: 8,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              children: [
                Expanded(child: Text('Mean arterial pressure')), // TODO: localizations and testing
                Text(data.meanArterialPressure.toString()),
              ],
            ),
            if (data.userID != null)
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                children: [
                  Expanded(child: Text('userID')),
                  Text(data.userID!.toString()),
                ],
              ),
            if (data.status?.bodyMovementDetected ?? false)
              ListTile(title: Text('bodyMovementDetected')),
            if (data.status?.cuffTooLose ?? false)
              ListTile(title: Text('cuffTooLose')),
            if (data.status?.improperMeasurementPosition ?? false)
              ListTile(title: Text('improperMeasurementPosition')),
            if (data.status?.irregularPulseDetected ?? false)
              ListTile(title: Text('irregularPulseDetected')),
            if (data.status?.pulseRateExceedsUpperLimit ?? false)
              ListTile(title: Text('pulseRateExceedsUpperLimit')),
            if (data.status?.pulseRateIsLessThenLowerLimit ?? false)
              ListTile(title: Text('pulseRateIsLessThenLowerLimit')),
            const SizedBox(height: 8,),
          ],
        ),
      ),
    ),
  );
  
}

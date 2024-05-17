import 'package:blood_pressure_app/components/bluetooth_input/input_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Indication of a successful bluetooth measurement.
class MeasurementSuccess extends StatelessWidget {
  /// Indicate a successful while taking a bluetooth measurement.
  const MeasurementSuccess({super.key, required this.onTap});

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
          ],
        ),
      ),
    ),
  );
  
}

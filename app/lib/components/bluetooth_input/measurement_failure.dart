import 'package:blood_pressure_app/components/bluetooth_input/input_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Indication of a failure while taking a bluetooth measurement.
class MeasurementFailure extends StatelessWidget {
  /// Indicate a failure while taking a bluetooth measurement.
  const MeasurementFailure({super.key, required this.onTap});

  /// Called when the user requests closing.
  final void Function() onTap;

  // TODO: test
  
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: InputCard(
      onClosed: onTap,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(height: 8,),
            Text(AppLocalizations.of(context)!.errMeasurementRead),
            const SizedBox(height: 4,),
            Text(AppLocalizations.of(context)!.tapToClose),
            const SizedBox(height: 8,),
          ],
        ),
      ),
    ),
  );
  
}

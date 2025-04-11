import 'package:blood_pressure_app/features/bluetooth/ui/input_card.dart';
import 'package:blood_pressure_app/logging.dart';
import 'package:flutter/material.dart';
import 'package:blood_pressure_app/l10n/app_localizations.dart';

/// Indication of a failure while taking a bluetooth measurement.
class MeasurementFailure extends StatelessWidget with TypeLogger {
  /// Indicate a failure while taking a bluetooth measurement.
  const MeasurementFailure({super.key, required this.onTap, required this.reason});

  /// Called when the user requests closing.
  final void Function() onTap;
  /// Likely reason why the measurement failed
  final String reason;

  @override
  Widget build(BuildContext context) {
    logger.warning('MeasurementFailure reason: $reason');
    return GestureDetector(
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
}

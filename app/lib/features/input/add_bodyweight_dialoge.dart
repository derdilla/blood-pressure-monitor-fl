import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:health_data_store/health_data_store.dart';

/// A simple dialoge to enter one weight value in kg.
///
/// Returns a [Weight] on submission.
class AddBodyweightDialoge extends StatelessWidget {
  /// Create a simple dialoge to enter one weight value in kg.
  const AddBodyweightDialoge({super.key});

  @override
  Widget build(BuildContext context) => Dialog(
    child: TextFormField(
      autofocus: true,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.weight,
        suffix: const Text('kg'),
      ),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        if (value == null
          || value.isEmpty
          || double.tryParse(value) == null
        ) {
          return AppLocalizations.of(context)!.errNaN;
        }
        return null;
      },
      onFieldSubmitted: (text) => Navigator.of(context).pop(Weight.kg(double.parse(text))),
    ),
  );
}

import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 2.0),
      child: TextFormField(
        autofocus: true,
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context)!.weight,
          suffix: Text(context.select((Settings s) => s.weightUnit).name),
        ),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9,.]'))],
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        autovalidateMode: AutovalidateMode.onUnfocus,
        validator: (value) {
          if (value == null
            || value.isEmpty
            || double.tryParse(value) == null
          ) {
            return AppLocalizations.of(context)!.errNaN;
          }
          return null;
        },
        onFieldSubmitted: (String text) {
          final value = double.tryParse(text);
          if (value != null) {
            final weight = context.read<Settings>().weightUnit.store(value);
            Navigator.of(context).pop(weight);
          }
        },
      ),
    ),
  );
}

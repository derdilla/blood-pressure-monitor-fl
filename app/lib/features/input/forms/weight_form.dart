import 'package:blood_pressure_app/features/input/forms/form_base.dart';
import 'package:blood_pressure_app/model/storage/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:health_data_store/health_data_store.dart';
import 'package:provider/provider.dart';

/// A form to enter [Weight] in the preferred unit.
class WeightForm extends FormBase<Weight> {
  /// Create a form to enter [Weight] in the preferred unit.
  const WeightForm({super.key, super.initialValue});

  @override
  FormStateBase<Weight, WeightForm> createState() => WeightFormState();
}

/// State of a form to enter [Weight] in the preferred unit.
class WeightFormState extends FormStateBase<Weight, WeightForm> {
  final TextEditingController _controller = TextEditingController();

  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      final w = context.read<Settings>().weightUnit.extract(widget.initialValue!);
      _controller.text = w.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  bool validate() {
    if (_controller.text.isEmpty
        || double.tryParse(_controller.text) == null
    ) {
      setState(() => _error = AppLocalizations.of(context)!.errNaN);
      return false;
    } else {
      _error = null;
      return true;
    }
  }

  @override
  Weight? save() {
    if(validate()) {
      return context.read<Settings>().weightUnit.store(double.tryParse(_controller.text) ?? 0.0);
    }
    return null;
  }

  @override
  bool isEmptyInputFocused() {
    // TODO: implement isEmptyInputFocused
    return false;
  }

  @override
  Widget build(BuildContext context) => TextField(
    decoration: InputDecoration(
      labelText: AppLocalizations.of(context)!.weight,
      suffix: Text(context.select((Settings s) => s.weightUnit).name),
      errorText: _error,
    ),
    inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9,.]'))],
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
  );
}

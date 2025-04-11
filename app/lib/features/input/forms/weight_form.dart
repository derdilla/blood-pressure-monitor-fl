import 'package:blood_pressure_app/features/input/forms/form_base.dart';
import 'package:blood_pressure_app/model/storage/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:blood_pressure_app/l10n/app_localizations.dart';
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
    if (_controller.text.isNotEmpty && double.tryParse(_controller.text) == null) {
      setState(() => _error = AppLocalizations.of(context)!.errNaN);
      return false;
    }
    setState(() => _error = null);
    return true;
  }

  @override
  Weight? save() {
    if((validate(), double.tryParse(_controller.text)) case (true, final double x)) {
      return context.read<Settings>().weightUnit.store(x);
    }
    return null;
  }

  @override
  bool isEmptyInputFocused() => false;

  @override
  void fillForm(Weight? value) {
    if (value == null) {
      _controller.text = '';
    } else {
      final w = context.read<Settings>().weightUnit.extract(widget.initialValue!);
      _controller.text = w.toString();
    }
  }

  @override
  Widget build(BuildContext context) => TextField(
    decoration: InputDecoration(
      labelText: AppLocalizations.of(context)!.weight,
      suffix: Text(context.select((Settings s) => s.weightUnit).name),
      errorText: _error,
    ),
    controller: _controller,
    inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9,.]'))],
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
  );
}

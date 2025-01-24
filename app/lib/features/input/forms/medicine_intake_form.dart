import 'package:blood_pressure_app/features/input/forms/form_base.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:health_data_store/health_data_store.dart';

/// Form to enter medicine intakes.
class MedicineIntakeForm extends FormBase<(Medicine, Weight)> {
  /// Create form to enter medicine intakes.
  MedicineIntakeForm({super.key,
    super.initialValue,
    required this.meds,
  }) : assert(meds.isNotEmpty);

  /// All selectable medicines.
  final List<Medicine> meds;

  @override
  FormStateBase<(Medicine, Weight), MedicineIntakeForm> createState() =>
    MedicineIntakeFormState();
}

/// State of form to enter medicine intakes.
class MedicineIntakeFormState extends FormStateBase<(Medicine, Weight), MedicineIntakeForm> {
  final _controller = TextEditingController();

  Medicine? _leadingMed;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.meds.length == 1) _leadingMed = widget.meds.first;
    _controller.text = _leadingMed?.dosis?.mg.toString() ?? '';

    if (widget.initialValue != null) {
      _leadingMed = widget.initialValue!.$1;
      _controller.text = widget.initialValue!.$2.mg.toString();
    }
  }

  @override
  bool validate() {
    if (_leadingMed != null && double.tryParse(_controller.text) == null) {
      setState(() => _error = AppLocalizations.of(context)!.errNaN);
      return false;
    }
    setState(() => _error = null);
    return true;
  }

  @override
  (Medicine, Weight)? save() {
    if (_leadingMed == null || !validate()) return null;
    return (_leadingMed!, Weight.mg(double.parse(_controller.text)));
  }

  @override
  bool isEmptyInputFocused() => false;

  @override
  Widget build(BuildContext context) {
    if (_leadingMed != null) {
      return TextField(
        decoration: InputDecoration(
          helperText: _leadingMed!.designation,
          labelText: AppLocalizations.of(context)!.dosis,
          prefixIcon: Icon(Icons.medication,
            color: _leadingMed!.color == null ? null : Color(_leadingMed!.color!)),
          suffixIcon: widget.meds.length == 1 ? null : IconButton(
            onPressed: () => setState(() => _leadingMed = null),
            icon: Icon(Icons.close),
          ),
          errorText: _error,
        ),
        controller: _controller,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9,.]'))],
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
      );
    }
    return Column(
      children: [
        for (final m in widget.meds)
          ListTile(
            leading: Icon(Icons.medication, color: m.color == null ? null : Color(m.color!)),
            title: Text(m.designation),
            onTap: () => setState(() {
              _leadingMed = m;
              _controller.text = _leadingMed?.dosis?.mg.toString() ?? '';
            }),
          ),
      ],
    );
  }
}

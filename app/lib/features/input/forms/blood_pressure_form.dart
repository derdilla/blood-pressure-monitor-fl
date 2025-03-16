import 'package:blood_pressure_app/features/input/forms/form_base.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

/// Form to enter freeform text and select color.
class BloodPressureForm extends FormBase<({int? sys, int? dia, int? pul})> {
  /// Create form to enter freeform text and select color.
  const BloodPressureForm({super.key,
    super.initialValue,
  });

  @override
  BloodPressureFormState createState() => BloodPressureFormState();
}

/// State of form to enter freeform text and select color.
class BloodPressureFormState extends FormStateBase<({int? sys, int? dia, int? pul}), BloodPressureForm> {
  final _formKey = GlobalKey<FormState>();

  final _sysFocusNode = FocusNode();
  final _diaFocusNode = FocusNode();
  final _pulFocusNode = FocusNode();

  late final TextEditingController _sysController;
  late final TextEditingController _diaController;
  late final TextEditingController _pulController;

  @override
  void initState() {
    super.initState();
    _sysController = TextEditingController(text: widget.initialValue?.sys?.toString() ?? '');
    _diaController = TextEditingController(text: widget.initialValue?.dia?.toString() ?? '');
    _pulController = TextEditingController(text: widget.initialValue?.pul?.toString() ?? '');
    _sysFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _sysFocusNode.dispose();
    _diaFocusNode.dispose();
    _pulFocusNode.dispose();
    _sysController.dispose();
    _diaController.dispose();
    _pulController.dispose();
    super.dispose();
  }

  @override
  bool validate() {
    if (_sysController.text.isEmpty
        && _diaController.text.isEmpty
        && _pulController.text.isEmpty) {
      return true;
    }
    return _formKey.currentState?.validate() ?? false;
  }

  @override
  ({int? sys, int? dia, int? pul})? save() {
    if (!validate()
      || (int.tryParse(_sysController.text) == null
      && int.tryParse(_diaController.text) == null
      && int.tryParse(_pulController.text) == null)) {
      return null;
    }
    return (
      sys: int.tryParse(_sysController.text),
      dia: int.tryParse(_diaController.text),
      pul: int.tryParse(_pulController.text),
    );
  }

  @override
  bool isEmptyInputFocused() => (_diaFocusNode.hasFocus && _diaController.text.isEmpty)
   || (_pulFocusNode.hasFocus && _pulController.text.isEmpty);

  @override
  void fillForm(({int? dia, int? pul, int? sys})? value) => setState(() {
    if (value == null) {
        _sysController.text = '';
        _diaController.text = '';
        _pulController.text = '';
    } else {
      if (value.dia != null) _diaController.text = value.dia.toString();
      if (value.pul != null) _pulController.text = value.pul.toString();
      if (value.sys != null) _sysController.text = value.sys.toString();
    }
  });

  Widget _buildValueInput({
    String? labelText,
    FocusNode? focusNode,
    TextEditingController? controller,
    String? Function(String?)? validator,
  }) => Expanded(
    child: TextFormField(
      focusNode: focusNode,
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: (String value) {
        if (value.isNotEmpty
            && (int.tryParse(value) ?? -1) > 40) {
          FocusScope.of(context).nextFocus();
        }
      },
      validator: (String? value) {
        final settings = context.read<Settings>();
        if (!settings.allowMissingValues
            && (value == null
                || value.isEmpty
                || int.tryParse(value) == null)) {
          return AppLocalizations.of(context)!.errNaN;
        } else if (settings.validateInputs
            && (int.tryParse(value ?? '') ?? -1) <= 30) {
          return AppLocalizations.of(context)!.errLt30;
        } else if (settings.validateInputs
            && (int.tryParse(value ?? '') ?? 0) >= 400) {
          // https://pubmed.ncbi.nlm.nih.gov/7741618/
          return AppLocalizations.of(context)!.errUnrealistic;
        }
        return validator?.call(value);
      },
      decoration: InputDecoration(
        labelText: labelText,
      ),
      style: Theme.of(context).textTheme.bodyLarge,
    ),
  );

  @override
  Widget build(BuildContext context) => Form(
    key: _formKey,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildValueInput(
          focusNode: _sysFocusNode,
          controller: _sysController,
          labelText: AppLocalizations.of(context)!.sysLong,
        ),
        const SizedBox(width: 8,),
        _buildValueInput(
          labelText: AppLocalizations.of(context)!.diaLong,
          controller: _diaController,
          focusNode: _diaFocusNode,
          validator: (value) {
            if (context.read<Settings>().validateInputs
              && (int.tryParse(value ?? '') ?? 0)
                >= (int.tryParse(_sysController.text) ?? 1)) {
              return AppLocalizations.of(context)?.errDiaGtSys;
            }
            return null;
          },
        ),
        const SizedBox(width: 8,),
        _buildValueInput(
          controller: _pulController,
          focusNode: _pulFocusNode,
          labelText: AppLocalizations.of(context)!.pulLong,
        ),
      ],
    ),
  );
}

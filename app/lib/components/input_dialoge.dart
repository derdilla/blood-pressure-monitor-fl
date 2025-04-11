import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:blood_pressure_app/l10n/app_localizations.dart';

/// Alert dialoge for prompting single value input from the user.
class InputDialoge extends StatefulWidget {
  /// Creates an [AlertDialog] with an text input field.
  ///
  /// Pops the context after value submission with object of type [String?].
  const InputDialoge({super.key,
    this.hintText,
    this.initialValue,
    this.inputFormatters,
    this.keyboardType,
    this.validator,});

  /// Initial content of the input field.
  final String? initialValue;

  /// Supporting text describing the input field.
  final String? hintText;

  /// Optional input validation and formatting overrides.
  final List<TextInputFormatter>? inputFormatters;

  /// The type of keyboard to use for editing the text.
  final TextInputType? keyboardType;

  /// Validation function called after submit.
  ///
  /// When the validator returns null the dialoge completes normally,
  /// in case of receiving a String it will be displayed to the user
  /// and pressing of the submit button will be ignored.
  ///
  /// It is still possible to cancel a dialoge in case the validator fails.
  final String? Function(String)? validator;

  @override
  State<InputDialoge> createState() => _InputDialogeState();
}

class _InputDialogeState extends State<InputDialoge> {
  final controller = TextEditingController();
  final focusNode = FocusNode();

  String? errorText;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) controller.text = widget.initialValue!;
    focusNode.requestFocus();
  }

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return AlertDialog(
      content: TextField(
        controller: controller,
        focusNode: focusNode,
        inputFormatters: widget.inputFormatters,
        keyboardType: widget.keyboardType,
        decoration: InputDecoration(
          hintText: widget.hintText,
          labelText: widget.hintText,
          errorText: errorText,
        ),
        onSubmitted: _onSubmit,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(localizations.btnCancel),
        ),
        ElevatedButton(
          onPressed: () => _onSubmit(controller.text),
          child: Text(localizations.btnConfirm),),
      ],
    );
  }

  void _onSubmit(String value) {
    final validationResult = widget.validator?.call(value);
    if (validationResult != null) {
      setState(() {
        errorText = validationResult;
      });
      return;
    }
    Navigator.pop(context, value);
  }
}

/// Creates a dialoge for prompting a single user input.
///
/// Add supporting text describing the input field through [hintText].
/// [initialValue] specifies the initial input field content.
Future<String?> showInputDialoge(BuildContext context, {String? hintText, String? initialValue}) async =>
  showDialog<String?>(context: context, builder: (context) =>
      InputDialoge(hintText: hintText, initialValue: initialValue,),);

/// Creates a dialoge that only allows int and double inputs.
///
/// Variables behave similar to [showInputDialoge].
Future<double?> showNumberInputDialoge(BuildContext context, {String? hintText, num? initialValue}) async {
  final result = await showDialog<String?>(context: context, builder: (context) =>
    InputDialoge(
      hintText: hintText,
      initialValue: initialValue?.toString(),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'([0-9]+(\.([0-9]*))?)')),],
      keyboardType: TextInputType.number,
      validator: (text) {
        double? value = double.tryParse(text);
        value ??= int.tryParse(text)?.toDouble();
        if (text.isEmpty || value == null) {
          return AppLocalizations.of(context)!.errNaN;
        }
        return null;
      },
    ),);

  double? value = double.tryParse(result ?? '');
  value ??= int.tryParse(result ?? '')?.toDouble();
  return value;
}

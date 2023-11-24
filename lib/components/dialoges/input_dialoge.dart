import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Dialoge for prompting single value input from the user.
class InputDialoge extends StatefulWidget {
  /// Creates an [AlertDialog] with an text input field.
  ///
  /// Pops the context after value submission with object of type [String?].
  const InputDialoge({super.key,
    this.inputFormatters,
    this.keyboardType,
    this.hintText,
    this.initialValue});

  /// Initial content of the input field.
  final String? initialValue;

  /// Supporting text describing the input field.
  final String? hintText;

  /// Optional input validation and formatting overrides.
  final List<TextInputFormatter>? inputFormatters;

  final TextInputType? keyboardType;

  @override
  State<InputDialoge> createState() => _InputDialogeState();
}

class _InputDialogeState extends State<InputDialoge> {
  final controller = TextEditingController();
  final focusNode = FocusNode();

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
          labelText: widget.hintText
        ),
        onSubmitted: _onSubmit,
      ),
      actions: [
        ElevatedButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: Text(localizations.btnCancel)),
        ElevatedButton(
            onPressed: () => _onSubmit(controller.text),
            child: Text(localizations.btnConfirm)),
      ],
    );
  }

  void _onSubmit(String value) {
    Navigator.of(context).pop(value);
  }
}

/// Creates a dialoge for prompting a single user input.
Future<String?> showInputDialoge(BuildContext context, {String? hintText, String? initialValue}) async =>
  showDialog<String?>(context: context, builder: (context) =>
      InputDialoge(hintText: hintText, initialValue: initialValue,));
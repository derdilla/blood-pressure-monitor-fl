import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class InputDialoge extends StatefulWidget {
  final String hintText;
  final String? initialValue;

  /// Gets called when the user submits the text field or presses the submit button.
  final void Function(String text) onSubmit;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;

  const InputDialoge({super.key,
    required this.hintText,
    required this.onSubmit,
    this.inputFormatters,
    this.keyboardType,
    this.initialValue});

  @override
  State<InputDialoge> createState() => _InputDialogeState();
}

class _InputDialogeState extends State<InputDialoge> {
  final formKey = GlobalKey<FormState>();
  final controller = TextEditingController();
  final inputFocusNode = FocusNode();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }


  @override
  void initState() {
    super.initState();
    controller.text = widget.initialValue ?? '';
  }

  @override
  Widget build(BuildContext context) {
    inputFocusNode.requestFocus();
    return AlertDialog(
      content: TextFormField(
        key: formKey,
        focusNode: inputFocusNode,
        controller: controller,
        inputFormatters: widget.inputFormatters,
        keyboardType: widget.keyboardType,
        decoration: InputDecoration(
          hintText: widget.hintText
        ),
        onFieldSubmitted: widget.onSubmit,
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            widget.onSubmit(controller.text);
          },
          child: Text(AppLocalizations.of(context)!.btnConfirm)
        )
      ],
    );
  }
}

typedef NumberInputResult = void Function(double result);

class NumberInputDialoge extends StatelessWidget {
  final String hintText;
  final NumberInputResult onParsableSubmit;
  final String? initialValue;

  const NumberInputDialoge({
    super.key,
    required this.hintText,
    required this.onParsableSubmit,
    this.initialValue});

  @override
  Widget build(BuildContext context) {
    return InputDialoge(
      hintText: hintText,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'([0-9]+(\.([0-9]*))?)')),],
      keyboardType: TextInputType.number,
      initialValue: initialValue,
      onSubmit: (text) {
        double? value = double.tryParse(text);
        value ??= int.tryParse(text)?.toDouble();
        if (text.isEmpty || value == null) {
          return;
        }
        onParsableSubmit(value);
      }
    );
  }
}

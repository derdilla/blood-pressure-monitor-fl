import 'package:blood_pressure_app/model/settings_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

// TODO: redo dialoges in flutter style
class InputDialoge extends StatefulWidget {
  final String hintText;
  final void Function(String text) onSubmit;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;

  const InputDialoge({super.key, required this.hintText, required this.onSubmit, this.inputFormatters, this.keyboardType});

  @override
  State<InputDialoge> createState() => _InputDialogeState();
}

class _InputDialogeState extends State<InputDialoge> {
  final formKey = GlobalKey<FormState>();
  final controller = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: TextFormField(
        key: formKey,
        controller: controller,
        inputFormatters: widget.inputFormatters,
        keyboardType: widget.keyboardType,
        decoration: InputDecoration(hintText: widget.hintText),
      ),
      actions: [
        Consumer<Settings>(builder: (context, settings, child) {
          return ElevatedButton(
              onPressed: () {
                widget.onSubmit(controller.text);
              },
              child: Text(AppLocalizations.of(context)!.btnConfirm)
          );
        }),

      ],
    );
  }
}

class NumberInputDialoge extends StatelessWidget {
  final String hintText;
  final void Function(int text) onParsableSubmit;

  const NumberInputDialoge({super.key, required this.hintText, required this.onParsableSubmit});

  @override
  Widget build(BuildContext context) {
    return InputDialoge(
      hintText: hintText,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      keyboardType: TextInputType.number,
      onSubmit: (text) {
        if (text.isEmpty || (int.tryParse(text) == null)) {
          return;
        }
        int value = int.parse(text);
        onParsableSubmit(value);
      }
    );
  }
}

import 'package:blood_pressure_app/components/dialoges/input_dialoge.dart';
import 'package:flutter/material.dart';

/// A list tile for exposing editable strings.
class InputListTile extends StatelessWidget {
  /// Creates a list tile that allows editing a string
  const InputListTile({super.key,
    required this.label,
    required this.value,
    required this.onSubmit});

  /// Short label describing the required field contents.
  ///
  /// This will be both the title of the list tile as well as the hint text in the input dialoge.
  final String label;

  /// Current content of the input field.
  final String value;

  /// Gets called when the user submits a new value
  final void Function(String text) onSubmit;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      subtitle: Text(value.toString()),
      trailing: const Icon(Icons.edit),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => InputDialoge(
            initialValue: value,
            hintText: label,
            onSubmit: (value) {
              Navigator.of(context).pop();
              onSubmit(value);
            },
          ),
        );
      },
    );
  }

}
import 'package:blood_pressure_app/components/color_picker.dart';
import 'package:blood_pressure_app/components/dialoges/input_dialoge.dart';
import 'package:flutter/material.dart';

/// A [ListTile] that shows a color preview and allows changing it.
class ColorSelectionListTile extends StatelessWidget {
  /// Creates a ListTile with a color preview that opens a color picker on tap.
  const ColorSelectionListTile(
      {super.key,
      required this.title,
      required this.onMainColorChanged,
      required this.initialColor,
      this.subtitle});

  /// The primary label of the list tile.
  final Widget title;
  
  /// Additional content displayed below the title.
  final Widget? subtitle;

  /// Gets called when a color gets successfully picked.
  final ValueChanged<Color> onMainColorChanged;

  /// Initial color displayed in the preview.
  final Color initialColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: title,
      subtitle: subtitle,
      leading: CircleAvatar(
        backgroundColor: initialColor,
        radius: 12,
      ),
      onTap: () async {
        final color = await showColorPickerDialog(context, initialColor);
        if (color != null) onMainColorChanged(color);
      },
    );
  }
}

/// A [ListTile] with a [Slider] attached to it. 
class SliderListTile extends StatelessWidget {
  /// Creates a [ListTile] with an attached [Slider].
  const SliderListTile({
    super.key, 
    required this.title,
    required this.onChanged,
    required this.value,
    required this.min,
    required this.max,
    this.stepSize = 1,
    this.leading,
    this.trailing});
  
  /// The primary content of the list tile.
  final Widget title;
  
  /// A widget to display before the title.
  final Widget? leading;
  
  /// A widget to display after the title.
  final Widget? trailing;

  /// Minimum selectable value on the slider.
  final double min;

  /// Maximum selectable value on the slider.
  final double max;
  
  /// Amount of steps the slider supports.
  final double stepSize;
  
  /// Current position of the slider thumb.
  /// 
  /// Should be a value that is selectable through by the user.
  final double value;

  /// Called during a drag when the user is selecting a new value for the slider
  /// by dragging.
  final void Function(double newValue) onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: title,
      leading: leading,
      trailing: trailing,
      subtitle: SizedBox(
        height: 30,
        child: Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min) ~/ stepSize,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

/// Widget for editing numbers in a list tile.
class NumberInputListTile extends StatelessWidget {
  /// Creates a widget for editing numbers in a list tile.
  const NumberInputListTile(
      {super.key,
        required this.label,
        this.leading,
        this.initialValue,
        required this.onParsableSubmit,});

  /// Short label describing the required field contents.
  /// 
  /// This will be both the title of the list tile as well as the hint text in the input dialoge. 
  final String label;

  /// Widget to display before the label in the list tile.
  final Widget? leading;

  /// Initial content of the input field.
  final num? initialValue;

  /// Gets called once the user submits a new valid number to the field.
  final NumberInputResult onParsableSubmit;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      subtitle: Text(initialValue.toString()),
      leading: leading,
      trailing: const Icon(Icons.edit),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => NumberInputDialoge(
            initialValue: initialValue?.toString(),
            hintText: label,
            onParsableSubmit: (value) {
              Navigator.of(context).pop();
              onParsableSubmit(value);
            },
          ),
        );
      },
    );
  }
}

/// A list tile for exposing editable strings.
class InputListTile extends StatelessWidget {
  /// Creates a list tile that allows editing a string
  const InputListTile({super.key,
    required this.label,
    required this.initialValue,
    required this.onSubmit});

  /// Short label describing the required field contents.
  ///
  /// This will be both the title of the list tile as well as the hint text in the input dialoge.
  final String label;

  /// Initial content of the input field.
  final String initialValue;

  /// Gets called when the user submits a new value
  final void Function(String text) onSubmit;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      subtitle: Text(initialValue.toString()),
      trailing: const Icon(Icons.edit),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => InputDialoge(
            initialValue: initialValue,
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

/// A ListTile that allows choosing from a dropdown.
class DropDownListTile<T> extends StatelessWidget {
  /// Creates a list tile that allows choosing an item from a dropdown.
  ///
  /// Using this is equivalent to using a [ListTile] with a trailing [DropdownButton]. Please refer to those classes for 
  /// argument definitions.
  const DropDownListTile({
    required this.title,
    required this.value,
    required this.onChanged,
    required this.items,
    this.leading,
    this.subtitle,
    super.key});
  
  final Widget title;
  final Widget? subtitle;
  final Widget? leading;

  final T value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T? value) onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: title,
      subtitle: subtitle,
      leading: leading,
      trailing: DropdownButton<T>(
        value: value,
        items: items,
        onChanged: onChanged,
      ),
    );
  }
}

class SettingsSection extends StatelessWidget {
  final Widget title;
  final List<Widget> children;

  const SettingsSection({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(top: 15),
          child: Align(
            alignment: const Alignment(-0.93, 0),
            child: DefaultTextStyle(
                style: Theme.of(context).textTheme.titleMedium!,
                child: title),
          ),
        ),
        Container(
          padding: const EdgeInsets.only(left: 10, right: 20), // TODO: remove
          child: Column(
            children: children,
          ),
        )
      ],
    );
  }
}

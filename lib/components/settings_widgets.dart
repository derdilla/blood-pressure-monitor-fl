import 'package:blood_pressure_app/components/color_picker.dart';
import 'package:blood_pressure_app/components/dialoges/input_dialoge.dart';
import 'package:flutter/material.dart';

class SettingsTile extends StatelessWidget {
  final Widget title;
  final void Function(BuildContext context) onPressed;
  final Widget? leading;
  final Widget? description;
  final Widget? trailing;
  final bool disabled;

  const SettingsTile(
      {super.key,
      required this.title,
      this.leading,
      this.trailing,
      required this.onPressed,
      this.description,
      this.disabled = false});

  @override
  Widget build(BuildContext context) {
    // TODO: use Proper disabled widget, convert to ListTile
    if (disabled) return const SizedBox.shrink();

    var lead = SizedBox(
      width: 40,
      child: leading ?? const SizedBox.shrink(),
    );
    var trail = trailing ?? const SizedBox.shrink();
    return InkWell(
      onTap: () => onPressed(context),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: 48, maxWidth: MediaQuery.of(context).size.width),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            lead,
            const SizedBox(
              width: 15,
            ),
            if (description != null)
              Expanded(
                flex: 10,
                child: Container(
                  padding: const EdgeInsets.only(top: 5, bottom: 5),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      title,
                      DefaultTextStyle(
                          style: const TextStyle(color: Colors.grey, ),
                          child: description ?? const SizedBox.shrink()
                      )
                    ],
                  ),
                ),
              ),
            if (description == null)
              title,
            const Spacer(),
            //const Expanded(child: SizedBox.shrink()),
            trail
          ],
        ),
      ),
    );
  }
}

/// A ListTile that shows a color preview and allows changing it.
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

class SliderSettingsTile extends StatefulWidget {
  final Widget title;
  final void Function(double newValue) onChanged;
  final Widget? leading;
  final Widget? description;
  final Widget? trailing;
  final bool disabled;
  final double start;
  final double end;
  final double stepSize;
  final double initialValue;

  const SliderSettingsTile(
      {super.key,
      required this.title,
      required this.onChanged,
      required this.initialValue,
      required this.start,
      required this.end,
      this.stepSize = 1,
      this.description,
      this.leading,
      this.trailing,
      this.disabled = false});

  @override
  State<StatefulWidget> createState() => _SliderSettingsTileState();
}

class _SliderSettingsTileState extends State<SliderSettingsTile> {
  late double _value = -1;

  _SliderSettingsTileState();

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.disabled) return const SizedBox.shrink();

    var lead = SizedBox(
      width: 40,
      child: widget.leading ?? const SizedBox.shrink(),
    );
    var trail = widget.trailing ?? const SizedBox.shrink();

    return SizedBox(
      height: 50,
      child: Row(
        children: [
          lead,
          const SizedBox(
            width: 15,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width - 150,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widget.title,
                Flexible(
                    child: DefaultTextStyle(
                        style: const TextStyle(color: Colors.grey),
                        overflow: TextOverflow.visible,
                        child: widget.description ?? const SizedBox.shrink())),
                const SizedBox(
                  height: 7,
                ),
                Expanded(
                    child: Slider(
                  value: _value,
                  onChanged: (newValue) {
                    setState(() {
                      _value = newValue;
                    });
                    widget.onChanged(newValue);
                  },
                  min: widget.start,
                  max: widget.end,
                  divisions: (widget.end - widget.start) ~/ widget.stepSize,
                )),
              ],
            ),
          ),
          const Expanded(child: SizedBox.shrink()),
          trail
        ],
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
  /// Using this is equivalent to using a [ListTile] with a trailing [DropdownButton].
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
          padding: const EdgeInsets.only(left: 10, right: 20),
          child: Column(
            children: children,
          ),
        )
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';

class SettingsTile extends StatelessWidget {
  final Widget title;
  final void Function(BuildContext context) onPressed;
  final Widget? leading;
  final Widget? description;
  final Widget? trailing;
  final bool disabled;

  const SettingsTile({super.key, required this.title, this.leading, this.trailing, required this.onPressed, this.description, this.disabled = false});

  @override
  Widget build(BuildContext context) {
    if (disabled) return const SizedBox.shrink();

    var lead = SizedBox(
      width: 40,
      child: leading ?? const SizedBox.shrink(),
    );
    var trail = trailing ?? const SizedBox.shrink();

    return InkWell(
      onTap: () => onPressed(context),
      child: SizedBox(
        height: 45,
        child: Row(
          children: [
            lead,
            const SizedBox(width: 15,),
            SizedBox(
              child: (() {
              if (description != null) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    title,
                    Flexible(
                        child: DefaultTextStyle(
                            style: const TextStyle(color: Colors.grey),
                            overflow: TextOverflow.visible,
                            child: description ?? const SizedBox.shrink()
                        )
                    )
                  ],
                );
              }
              return title;
            })(),),
            const Expanded(child: SizedBox.shrink()),
            trail
          ],
        ),
      ),
    );
  }
}


class ColorSelectionSettingsTile extends StatelessWidget {
  final Widget title;
  final ValueChanged<ColorSwatch?>? onMainColorChanged;
  final MaterialColor initialColor;
  final Widget? leading;
  final Widget? trailing;
  final Widget? description;
  final bool disabled;

  const ColorSelectionSettingsTile({super.key, required this.title, required this.onMainColorChanged, required this.initialColor, this.leading, this.trailing, this.description, this.disabled = false});

  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      leading: Container(
        width: 25.0,
        height: 25.0,
        decoration: BoxDecoration(
          color: initialColor,
          shape: BoxShape.circle,
        ),
      ),
      title: title,
      trailing: trailing,
      description: description,
      disabled: disabled,
      onPressed: (context) {
        showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              contentPadding: const EdgeInsets.all(6.0),
              title: const Text('select color'),
              content: MaterialColorPicker(
                selectedColor: initialColor,
                onMainColorChange: (color) {
                  onMainColorChanged?.call(color);
                  Navigator.of(context).pop();
                },
              ),
              actions: [
                TextButton(
                  onPressed: Navigator.of(context).pop,
                  child: const Text('CLOSE'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class SwitchSettingsTile extends StatelessWidget {
  final Widget title;
  final void Function(bool newValue) onToggle;
  final Widget? leading;
  final Widget? description;
  final bool? initialValue;
  final bool disabled;

  const SwitchSettingsTile({super.key, required this.title, required this.onToggle,
    this.leading, this.description, this.initialValue, this.disabled = false});

  @override
  Widget build(BuildContext context) {
    var s = Switch(
      value: initialValue ?? false,
      onChanged:  onToggle,
    );
    return SettingsTile(
      title: title,
      onPressed: (BuildContext context) {
        s.value != s.value;
      },
      leading: leading,
      description: description,
      disabled: disabled,
      trailing: s,
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

  const SliderSettingsTile({
    super.key,
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
      height: 70,
      child: Row(
        children: [
          lead,
          const SizedBox(width: 15,),
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
                        child: widget.description ?? const SizedBox.shrink()
                    )
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
                      divisions: (widget.end-widget.start)~/widget.stepSize,
                    )
                )
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

class InputSettingsTile extends StatelessWidget {
  final Widget title;
  final Widget? leading;
  final Widget? description;
  final bool disabled;

  final double inputWidth;
  final String? initialValue;
  final InputDecoration? decoration;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const InputSettingsTile({super.key, required this.title, required this.inputWidth, this.leading, this.description, this.disabled = false, this.initialValue, this.decoration, this.validator, this.keyboardType, this.inputFormatters});

  @override
  Widget build(BuildContext context) {
    final focusNode = FocusNode();

    return SettingsTile(
      title: title,
      description: description,
      onPressed: (context) {
        focusNode.requestFocus();
      },
      trailing: Row(
        children: [
          SizedBox(
            width: inputWidth,
            child: TextFormField(
              initialValue: initialValue,
              decoration: decoration,
              validator: validator,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              focusNode: focusNode,
            ),
          ),
          const SizedBox(width: 20,),
        ],
      ),
      leading: leading,
      disabled: disabled,
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
                style: (Theme.of(context).textTheme.bodyMedium ?? const TextStyle())
                    .copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                child: title
            ),
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

import 'package:blood_pressure_app/model/settings.dart';
import 'package:flutter/material.dart';
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
    if (disabled) return SizedBox.shrink();

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
            (() {
              if (description != null) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    title,
                    DefaultTextStyle(
                        style: const TextStyle(color: Colors.grey),
                        child: description ?? const SizedBox.shrink()
                    )
                  ],
                );
              }
              return title;
            })(),
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
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Column(
            children: children,
          ),
        )
      ],
    );
  }
}

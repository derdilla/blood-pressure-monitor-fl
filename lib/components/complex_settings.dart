import 'package:blood_pressure_app/model/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:settings_ui/settings_ui.dart';

class ColorSelectionTile {
  final ValueChanged<ColorSwatch?>? onMainColorChanged;
  final MaterialColor initialColor;
  final Widget title;

  const ColorSelectionTile({required this.title, required this.onMainColorChanged, required this.initialColor});


  SettingsTile build(BuildContext context) {
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
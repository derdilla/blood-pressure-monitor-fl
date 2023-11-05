import 'package:blood_pressure_app/components/color_picker.dart';
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
import 'package:blood_pressure_app/components/color_picker.dart';
import 'package:flutter/material.dart';

/// A [ListTile] that shows a color preview and allows changing it.
class ColorSelectionListTile extends StatelessWidget {
  /// Creates a [ListTile] with a color preview that opens a color picker on tap.
  ///
  /// This allows also allows picking the color [Colors.transparent], which can be used as a null color.
  const ColorSelectionListTile(
      {super.key,
        required this.title,
        required this.onMainColorChanged,
        required this.initialColor,
        this.subtitle,
        this.shape});

  /// The primary label of the list tile.
  final Widget title;

  /// Additional content displayed below the title.
  final Widget? subtitle;

  /// Gets called when a color gets successfully picked.
  final ValueChanged<Color> onMainColorChanged;

  /// Initial color displayed in the preview.
  final Color initialColor;

  /// Defines the tile's [InkWell.customBorder] and [Ink.decoration] shape.
  final ShapeBorder? shape;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: title,
      subtitle: subtitle,
      shape: shape,
      leading: (initialColor == Colors.transparent) ? null : CircleAvatar(
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
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// A list of colors in circles where one can be selected at a time.
class ColorPicker extends StatefulWidget {
  /// Create a widget to select one color from a list.
  const ColorPicker({super.key,
    required this.onColorSelected,
    this.availableColors,
    this.initialColor,
    this.showTransparentColor = true,
    this.circleSize = 50
  });

  /// Colors to choose from.
  ///
  /// Defaults to [ColorPicker.allColors].
  final List<Color>? availableColors;

  /// Color that starts out highlighted.
  ///
  /// When [initialColor] is null the transparent color is selected. When [showTransparentColor] is false as well no
  /// color is selected.
  final Color? initialColor;

  /// Called after a click on a color.
  final FutureOr<void> Function(Color? color) onColorSelected;

  /// Controls whether a option for selecting that no color is displayed.
  final bool showTransparentColor;

  /// List of all material colors and black/white
  static final List<Color> allColors = [
    const Color(0xFFFFFFFF),
    const Color(0xFF000000),
    Colors.red,
    Colors.redAccent,
    Colors.pink,
    Colors.pinkAccent,
    Colors.purple,
    Colors.purpleAccent,
    Colors.deepPurple,
    Colors.deepPurpleAccent,
    Colors.indigo,
    Colors.indigoAccent,
    Colors.blue,
    Colors.blueAccent,
    Colors.lightBlue,
    Colors.lightBlueAccent,
    Colors.cyan,
    Colors.cyanAccent,
    Colors.teal,
    Colors.tealAccent,
    Colors.green,
    Colors.greenAccent,
    Colors.lightGreen,
    Colors.lightGreenAccent,
    Colors.lime,
    Colors.limeAccent,
    Colors.yellow,
    Colors.yellowAccent,
    Colors.amber,
    Colors.amberAccent,
    Colors.orange,
    Colors.orangeAccent,
    Colors.deepOrange,
    Colors.deepOrangeAccent,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey
  ];

  /// Size of the color circles.
  final double circleSize;

  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  /// Currently selected color.
  late Color _selected;
  late final List<Color> availableColors;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialColor ?? Colors.transparent;
    availableColors = widget.availableColors ?? ColorPicker.allColors;
  }
  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        for (final color in availableColors)
            InkWell(
              onTap: () {
                setState(() {
                  _selected = color;
                  widget.onColorSelected(_selected);
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: _selected == color ? Theme.of(context).disabledColor : Colors.transparent,
                  shape: BoxShape.circle,),
                padding: const EdgeInsets.all(5),
                child: Container(
                  height: widget.circleSize,
                  width: widget.circleSize,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle,),
                ),
              ),
            ),
        if (widget.showTransparentColor)
          InkWell(
            onTap: () {
              setState(() {
                _selected = Colors.transparent;
                widget.onColorSelected(_selected);
              });
            },
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: _selected == Colors.transparent ? Theme.of(context).disabledColor : Colors.transparent,
                shape: BoxShape.circle,),
              child: SizedBox(
                height: widget.circleSize,
                width: widget.circleSize,
                child: const Icon(Icons.block),
              ),
            ),
          ),
      ],
    );
  }
}

/// Shows a dialog with a ColorPicker and with an cancel button inside.
///
/// Returns the selected color or null when cancel is pressed.
Future<Color?> showColorPickerDialog(BuildContext context, [Color? initialColor]) async {
  return await showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        contentPadding: const EdgeInsets.all(6.0),
        content: ColorPicker(
          initialColor: initialColor,
          onColorSelected: (color) {
            Navigator.of(context).pop(color);
          }
        ),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: Text(AppLocalizations.of(context)!.btnCancel),
          ),
        ],
      );
    },
  );
}
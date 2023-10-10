import 'dart:async';

import 'package:flutter/material.dart';

class ColorPicker extends StatefulWidget {
  const ColorPicker({super.key,
    this.availableColors,
    this.initialColor,
    required this.onColorSelected,
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

  @override
  void initState() {
    super.initState();
    _selected = widget.initialColor ?? Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    final availableColors = widget.availableColors ?? ColorPicker.allColors;
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
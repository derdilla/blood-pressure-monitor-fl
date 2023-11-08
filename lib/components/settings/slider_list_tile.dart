import 'package:flutter/material.dart';

/// A [ListTile] with a [Slider] attached to it.
class SliderListTile extends StatelessWidget {
  /// Creates a [ListTile] with an attached [Slider].
  const SliderListTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.onChanged,
    required this.value,
    required this.min,
    required this.max,
    this.stepSize = 1,
    this.leading,
    this.trailing});

  /// The primary content of the list tile.
  final Widget title;

  /// A widget to display below the title.
  final Widget? subtitle;

  /// A widget to display before the title.
  final Widget? leading;

  /// A widget to display after the title.
  final Widget? trailing;

  /// Minimum selectable value on the slider.
  final double min;

  /// Maximum selectable value on the slider.
  final double max;

  /// Amount of units after which a selectable step is placed on the slider.
  final double stepSize;

  /// Current position of the slider thumb.
  ///
  /// Should be a value that is selectable by the user.
  final double value;

  /// Called during a drag when the user is selecting a new value for the slider by dragging.
  final void Function(double newValue) onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: title,
      leading: leading,
      trailing: trailing,
      subtitle: (subtitle == null) ? _buildSlider() : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          subtitle!,
          _buildSlider()
        ],
      ),
    );
  }

  Widget _buildSlider() => SizedBox(
      height: 30,
      child: Slider(
        value: value,
        min: min,
        max: max,
        divisions: (max - min) ~/ stepSize,
        onChanged: onChanged,
      ),
    );

}
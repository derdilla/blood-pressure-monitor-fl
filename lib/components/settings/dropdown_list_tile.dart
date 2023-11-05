import 'package:flutter/material.dart';

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
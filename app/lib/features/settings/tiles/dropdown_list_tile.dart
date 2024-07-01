import 'package:flutter/material.dart';

/// A [ListTile] that allows choosing from a dropdown.
class DropDownListTile<T> extends StatefulWidget {
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
    super.key,});

  /// Primary description of the tile.
  final Widget title;

  /// Secondary description below the title.
  final Widget? subtitle;

  /// A widget to display before the title.
  final Widget? leading;

  /// The value of the currently selected [DropdownMenuItem].
  final T? value;

  /// A list of items the user can select.
  final List<DropdownMenuItem<T>> items;

  /// Called when the selection changes.
  final void Function(T? value) onChanged;

  @override
  State<DropDownListTile<T>> createState() => _DropDownListTileState<T>();
}

class _DropDownListTileState<T> extends State<DropDownListTile<T>> {
  final focusNode = FocusNode();


  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListTile(
      title: widget.title,
      subtitle: widget.subtitle,
      leading: widget.leading,
      onTap: focusNode.requestFocus,
      trailing: DropdownButton<T>(
        focusNode: focusNode,
        value: widget.value,
        items: widget.items,
        onChanged: widget.onChanged,
      ),
    );
}

import 'package:blood_pressure_app/features/input/forms/form_base.dart';
import 'package:blood_pressure_app/features/settings/tiles/color_picker_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Form to enter freeform text and select color.
class NoteForm extends FormBase<(String?, Color?)> {
  /// Create form to enter freeform text and select color.
  const NoteForm({super.key});

  @override
  NoteFormState createState() => NoteFormState();
}

/// State of form to enter freeform text and select color.
class NoteFormState extends FormStateBase<(String?, Color?), NoteForm> {
  late final TextEditingController _controller;

  final FocusNode _focusNode = FocusNode();

  Color? _color;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue?.$1);
    _color = widget.initialValue?.$2;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  bool validate() => true;

  @override
  (String?, Color?)? save() => (_controller.text.isEmpty ? null : _controller.text, _color);

  @override
  bool isEmptyInputFocused() => _focusNode.hasFocus && _controller.text.isEmpty;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: TextFormField(
          focusNode: _focusNode,
          controller: _controller,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.addNote,
          ),
          minLines: 1,
          maxLines: 4,
        ),
      ),
      InputDecorator(
        decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
        ),
        child: ColorSelectionListTile(
          title: Text(AppLocalizations.of(context)!.color, style: Theme.of(context).textTheme.bodyLarge,),
          onMainColorChanged: (Color value) => setState(() {
            _color = (value == Colors.transparent) ? null : value;
          }),
          initialColor: _color ?? Colors.transparent,
        ),
      ),
    ],
  );
}

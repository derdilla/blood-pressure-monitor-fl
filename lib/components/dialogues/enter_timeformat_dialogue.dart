import 'package:blood_pressure_app/screens/subsettings/export_import/export_field_format_documentation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';

/// Dialogue that explains the time format and pops the context with either null or a time format string.
class EnterTimeFormatDialogue extends StatefulWidget {
  /// Create dialogue for entering time formats as used by the [DateFormat] class.
  const EnterTimeFormatDialogue({super.key, required this.initialValue, this.previewTime});

  /// Text that is initially in time format field.
  final String initialValue;

  /// Timestamp used to generate time format preview.
  ///
  /// When previewTime is null [DateTime.now] will be used.
  final DateTime? previewTime;

  @override
  State<EnterTimeFormatDialogue> createState() => _EnterTimeFormatDialogueState();
}

class _EnterTimeFormatDialogueState extends State<EnterTimeFormatDialogue> {
  final timeFormatFieldController = TextEditingController();
  final focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    timeFormatFieldController.text = widget.initialValue;
    timeFormatFieldController.addListener(() => setState(() {}));
    focusNode.requestFocus();
  }

  @override
  void dispose() {
    timeFormatFieldController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop(null);
          },
          icon: const Icon(Icons.close)
        ),
        actions: [
          TextButton(
            onPressed: () {
              if(timeFormatFieldController.text.isNotEmpty) {
                Navigator.of(context).pop(timeFormatFieldController.text);
              }
            },
            child: Text(localizations.btnSave)
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Markdown(
                shrinkWrap: true,
                onTapLink: getLinkTapHandler(context),
                physics: const NeverScrollableScrollPhysics(),
                data: localizations.enterTimeFormatDesc
              ),
              Text(DateFormat(timeFormatFieldController.text).format(widget.previewTime ?? DateTime.now())),
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: timeFormatFieldController,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: localizations.enterTimeFormatString,
                    errorText: timeFormatFieldController.text.isEmpty ? localizations.errNoValue : null,
                  ),
                ),
              ),
            ],
          ),
        )
      ),
    );
  }
}

/// Shows a dialogue that explains the ICU DateTime format and allows editing [initialTimeFormat] with a preview.
///
/// When canceled null is returned.
Future<String?> showTimeFormatPickerDialogue(BuildContext context, String initialTimeFormat) =>
    showDialog<String?>(context: context, builder: (context) => Dialog.fullscreen(
        child: EnterTimeFormatDialogue(initialValue: initialTimeFormat),
    ));
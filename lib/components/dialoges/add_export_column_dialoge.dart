import 'package:blood_pressure_app/components/measurement_list/measurement_list_entry.dart';
import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:blood_pressure_app/model/export_import/column.dart';
import 'package:blood_pressure_app/model/export_import/record_formatter.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:blood_pressure_app/screens/subsettings/export_import/export_field_format_documentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Dialoge widget for creating and editing a [UserColumn].
///
/// For further documentation please refer to [showAddExportColumnDialoge].
class AddExportColumnDialoge extends StatefulWidget {
  /// Create a widget for creating and editing a [UserColumn].
  const AddExportColumnDialoge({super.key, this.initialColumn, required this.settings});

  final ExportColumn? initialColumn;

  final Settings settings;

  @override
  State<AddExportColumnDialoge> createState() => _AddExportColumnDialogeState();
}

class _AddExportColumnDialogeState extends State<AddExportColumnDialoge> {
  final formKey = GlobalKey<FormState>();

  /// Csv column title used to compute internal identifier in case [widget.initialColumn] is null.
  late String csvTitle;

  /// Pattern for the preview and for column creation on save.
  late String formatPattern;

  @override
  void initState() {
    super.initState();
    csvTitle = widget.initialColumn?.csvTitle ?? '';
    formatPattern = widget.initialColumn?.formatPattern ?? '';
  }


  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        leading: IconButton(
            onPressed: () => Navigator.of(context).pop(null),
            icon: const Icon(Icons.close)
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                formKey.currentState!.save();
                final column = (widget.initialColumn != null) ?
                  UserColumn.explicit(widget.initialColumn!.internalIdentifier, csvTitle, formatPattern) :
                  UserColumn(csvTitle, csvTitle, formatPattern);

                Navigator.pop(context, column);
              }
            },
            child: Text(localizations.btnSave)
          )
        ],
      ),
      body: Form(
        key: formKey,
        child: ListView(
          children: [
            TextFormField(
              initialValue: csvTitle,
              decoration: getInputDecoration(localizations.csvTitle),
              validator: (value) => (value != null && value.isNotEmpty) ? null : localizations.errNoValue,
              onSaved: (value) => setState(() {csvTitle = value!;}),
            ),
            const SizedBox(height: 8,),
            TextFormField(
              initialValue: formatPattern,
              onChanged: (value) => setState(() {
                formatPattern = value;
              }),
              decoration: getInputDecoration(localizations.fieldFormat).copyWith(
                suffixIcon: IconButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => InformationScreen(text: localizations.exportFieldFormatDocumentation)));
                    },
                    icon: const Icon(Icons.info_outline)
                ),
              ),
              validator: (value) => (value != null && value.isNotEmpty) ? null : localizations.errNoValue,
              onSaved: (value) => setState(() {formatPattern = value!;}),
            ),
            const SizedBox(height: 8,),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20)
              ),
              child: (){
                  final record = BloodPressureRecord(DateTime.now(), 123, 78, 65, 'test note');
                  final formatter = ScriptedFormatter(formatPattern);
                  final text = formatter.encode(record);
                  final decoded = formatter.decode(text);
                  return Column(
                    children: [
                      MeasurementListRow(record: record, settings: widget.settings,),
                      const SizedBox(height: 8,),
                      const Icon(Icons.arrow_downward),
                      const SizedBox(height: 8,),
                      text.isNotEmpty ? Text(text) :
                        Text(localizations.errNoValue, style: const TextStyle(fontStyle: FontStyle.italic),),
                      const SizedBox(height: 8,),
                      const Icon(Icons.arrow_downward),
                      const SizedBox(height: 8,),
                      Text(decoded.toString())
                    ],
                  );
                }()
              ),
          ],
        ),

      ),
    );
  }

  InputDecoration getInputDecoration(String? labelText) {
    final border = OutlineInputBorder(
        borderSide: BorderSide(
          width: 3,
          color: Theme.of(context).primaryColor,
        ),
        borderRadius: BorderRadius.circular(20)
    );
    return InputDecoration(
      hintText: labelText,
      labelText: labelText,
      errorMaxLines: 5,
      border: border,
      enabledBorder: border,
    );
  }
}

/// Shows a dialoge containing a export column editor.
///
/// In case [initialColumn] is null fields are initially empty.
/// When initialColumn is provided, it is ensured that the
/// returned column has the same [UserColumn.internalIdentifier].
///
/// The dialoge allows entering a csv title and a format
/// pattern from which it generates a preview encoding and
/// shows values decode able.
///
/// Internal identifier and display title are generated from
/// the CSV title. There is no check whether a userColumn
/// with the generated title exists.
Future<UserColumn?> showAddExportColumnDialoge(BuildContext context, Settings settings, [ExportColumn? initialColumn]) =>
    showDialog<UserColumn?>(context: context, builder: (context) => Dialog.fullscreen(
      child: AddExportColumnDialoge(initialColumn: initialColumn, settings: settings,),
    ));
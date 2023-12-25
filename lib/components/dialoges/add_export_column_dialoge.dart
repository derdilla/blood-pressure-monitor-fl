import 'package:blood_pressure_app/components/measurement_list/measurement_list_entry.dart';
import 'package:blood_pressure_app/model/blood_pressure/record.dart';
import 'package:blood_pressure_app/model/export_import/column.dart';
import 'package:blood_pressure_app/model/export_import/record_formatter.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:blood_pressure_app/screens/subsettings/export_import/export_field_format_documentation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

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

class _AddExportColumnDialogeState extends State<AddExportColumnDialoge> with SingleTickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();

  /// Csv column title used to compute internal identifier in case [widget.initialColumn] is null.
  late String csvTitle;

  /// Pattern for record formatting preview and for column creation on save.
  String? recordPattern;

  /// Pattern for time formatting and time column creation
  String? timePattern;

  /// Kind of column created
  ///
  /// Determines whether [recordPattern] or [timePattern] is active.
  late _FormatterType type;

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    csvTitle = widget.initialColumn?.csvTitle ?? '';

    if (widget.initialColumn is TimeColumn) {
      type = _FormatterType.time;
      timePattern = widget.initialColumn?.formatPattern;
    } else {
      type = _FormatterType.record;
      recordPattern = widget.initialColumn?.formatPattern;
    }

    _controller = AnimationController(
      value: (type == _FormatterType.record) ? 1 : 0,
      duration: Duration(milliseconds: widget.settings.animationSpeed),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
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
                late ExportColumn column;
                if (type == _FormatterType.record) {
                  assert(recordPattern != null, 'validator should check');
                  column = (widget.initialColumn != null)
                      ? UserColumn.explicit(widget.initialColumn!.internalIdentifier, csvTitle, recordPattern!)
                      : UserColumn(csvTitle, csvTitle, recordPattern!);
                  Navigator.pop(context, column);
                } else {
                  assert(type == _FormatterType.time);
                  assert(timePattern != null, 'validator should check');
                  column = (widget.initialColumn != null)
                      ? TimeColumn.explicit(widget.initialColumn!.internalIdentifier, csvTitle, timePattern!)
                      : TimeColumn(csvTitle, timePattern!);
                  Navigator.pop(context, column);
                }
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
            SegmentedButton(
              onSelectionChanged: (v) {
                assert(v.length == 1);
                setState(() {
                  type = v.first;
                  switch (type) {
                    case _FormatterType.record:
                      _controller.forward();
                    case _FormatterType.time:
                      _controller.reverse();
                  }
                });
              },
              segments: [
                ButtonSegment(
                    value: _FormatterType.record,
                    label: Text(localizations.recordFormat)
                ),
                ButtonSegment(
                    value: _FormatterType.time,
                    label: Text(localizations.timeFormat)
                ),
              ],
              selected: { type }
            ),
            const SizedBox(height: 8,),
            Stack(
              children: [
                SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset.zero,
                    end: const Offset(1.1, 0.0),
                  ).animate(CurvedAnimation(
                    parent: _controller,
                    curve: Curves.easeIn,
                  )),
                  child: _createTimeFormatInput(localizations, context),
                ),
                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(-1.1, 0.0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _controller,
                    curve: Curves.easeIn,
                  )),
                  child: _createRecordFormatInput(localizations, context),
                ),
              ],
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
                  final formatter = (type == _FormatterType.record) ? ScriptedFormatter(recordPattern ?? '')
                      : ScriptedTimeFormatter(timePattern ?? '');
                  final text = formatter.encode(record);
                  final decoded = formatter.decode(text);
                  return Column(
                    children: [
                      (type == _FormatterType.record) ? MeasurementListRow(record: record, settings: widget.settings,)
                          : Text(DateFormat('MMM d, y - h:m.s').format(record.creationTime)),
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

  Column _createFormatInput(AppLocalizations localizations,
      BuildContext context,
      String inputHint,
      String inputDocumentation,
      String initialValue,
      void Function(String) onChanged,
      String? Function(String?) validator
      ) {
    return Column(
      children: [
        TextFormField(
          initialValue: initialValue,
          onChanged: onChanged,
          decoration: getInputDecoration(inputHint).copyWith(
            suffixIcon: IconButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => InformationScreen(text: inputDocumentation)));
                },
                icon: const Icon(Icons.info_outline)
            ),
          ),
          validator: validator,
          onSaved: (value) => onChanged),
      ],
    );
  }

  Column _createRecordFormatInput(AppLocalizations localizations, BuildContext context) =>
      _createFormatInput(localizations,
          context,
          localizations.fieldFormat,
          localizations.exportFieldFormatDocumentation,
          recordPattern ?? '',
          (value) => setState(() {
            recordPattern = value;
          }),
          (value) => (type == _FormatterType.time || value != null && value.isNotEmpty) ? null
              : localizations.errNoValue
      );
  
  Column _createTimeFormatInput(AppLocalizations localizations, BuildContext context) =>
      _createFormatInput(localizations,
          context,
          localizations.timeFormat,
          localizations.enterTimeFormatDesc,
          timePattern ?? '',
          (value) => setState(() {
            timePattern = value;
          }),
          (value) => (type == _FormatterType.record || (value != null && value.isNotEmpty)) ? null
            : localizations.errNoValue
      );

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

enum _FormatterType {
  record,
  time,
}

/// Shows a dialoge containing a export column editor to create a [UserColumn] or [TimeColumn].
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
Future<ExportColumn?> showAddExportColumnDialoge(BuildContext context, Settings settings, [ExportColumn? initialColumn]) =>
    showDialog<ExportColumn?>(context: context, builder: (context) => Dialog.fullscreen(
      child: AddExportColumnDialoge(initialColumn: initialColumn, settings: settings,),
    ));
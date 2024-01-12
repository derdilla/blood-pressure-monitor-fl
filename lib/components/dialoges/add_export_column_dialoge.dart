import 'package:blood_pressure_app/components/dialoges/fullscreen_dialoge.dart';
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
  const AddExportColumnDialoge({super.key,
    this.initialColumn,
    required this.settings,
  });

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
    return FullscreenDialoge(
      actionButtonText: localizations.btnSave,
      onActionButtonPressed: _saveForm,
      bottomAppBar: widget.settings.bottomAppBars,
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity == null) return;
          if (details.primaryVelocity! < -500 && type == _FormatterType.record) {
            _changeMode(_FormatterType.time);
          }
          if (details.primaryVelocity! > 500 && type == _FormatterType.time) {
            _changeMode(_FormatterType.record);
          }
        },
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: csvTitle,
                decoration: InputDecoration(
                  labelText: localizations.csvTitle,
                ),
                validator: (value) => (value != null && value.isNotEmpty) ? null : localizations.errNoValue,
                onSaved: (value) => setState(() {csvTitle = value!;}),
              ),
              const SizedBox(height: 8,),
              SegmentedButton(
                onSelectionChanged: (v) {
                  assert(v.length == 1);
                  _changeMode(v.first);
                },
                segments: [
                  ButtonSegment(
                      value: _FormatterType.record,
                      label: Text(localizations.recordFormat),
                  ),
                  ButtonSegment(
                      value: _FormatterType.time,
                      label: Text(localizations.timeFormat),
                  ),
                ],
                selected: { type },
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
                    ),),
                    child: _createTimeFormatInput(localizations, context),
                  ),
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(-1.1, 0.0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _controller,
                      curve: Curves.easeIn,
                    ),),
                    child: _createRecordFormatInput(localizations, context),
                  ),
                ],
              ),
              const SizedBox(height: 8,),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: (){
                    final record = BloodPressureRecord(DateTime.now(), 123, 78, 65, 'test note');
                    final formatter = (type == _FormatterType.record) ? ScriptedFormatter(recordPattern ?? '')
                        : ScriptedTimeFormatter(timePattern ?? '');
                    final text = formatter.encode(record);
                    final decoded = formatter.decode(text);
                    return Column(
                      children: [
                        if (type == _FormatterType.record) MeasurementListRow(record: record, settings: widget.settings,) else Text(DateFormat('MMM d, y - h:m.s').format(record.creationTime)),
                        const SizedBox(height: 8,),
                        const Icon(Icons.arrow_downward),
                        const SizedBox(height: 8,),
                        if (text.isNotEmpty) Text(text) else Text(localizations.errNoValue, style: const TextStyle(fontStyle: FontStyle.italic),),
                        const SizedBox(height: 8,),
                        const Icon(Icons.arrow_downward),
                        const SizedBox(height: 8,),
                        Text(decoded.toString()),
                      ],
                    );
                  }(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Column _createFormatInput(AppLocalizations localizations,
      BuildContext context,
      String labelText,
      String inputDocumentation,
      String initialValue,
      void Function(String) onChanged,
      String? Function(String?) validator,
      ) => Column(
      children: [
        TextFormField(
          initialValue: initialValue,
          onChanged: onChanged,
          decoration: InputDecoration(
            labelText: labelText,
            suffixIcon: IconButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => InformationScreen(text: inputDocumentation),),);
                },
                icon: const Icon(Icons.info_outline),
            ),
          ),
          validator: validator,
          onSaved: (value) => onChanged,),
      ],
    );

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
            : localizations.errNoValue,
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
            : localizations.errNoValue,
      );

  void _saveForm() {
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
  }

  void _changeMode(_FormatterType type) {
    setState(() {
      this.type = type;
      switch (type) {
        case _FormatterType.record:
          _controller.forward();
        case _FormatterType.time:
          _controller.reverse();
      }
    });
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
    ),);
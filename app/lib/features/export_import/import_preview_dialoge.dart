
import 'dart:math';

import 'package:blood_pressure_app/components/custom_banner.dart';
import 'package:blood_pressure_app/components/fullscreen_dialoge.dart';
import 'package:blood_pressure_app/model/export_import/column.dart';
import 'package:blood_pressure_app/model/export_import/csv_record_parsing_actor.dart';
import 'package:blood_pressure_app/model/storage/export_columns_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:health_data_store/health_data_store.dart';

/// A preview that allows customizing columns used for csv data import.
///
/// Pops the scope with a list of measurements on save ([List<BloodPressureRecord>?]).
class ImportPreviewDialoge extends StatefulWidget {
  /// Create a preview of how the app would import csv with options.
  const ImportPreviewDialoge({super.key,
    required this.bottomAppBar,
    required this.initialActor, 
    required this.columnsManager,
  });

  /// Whether to move the app bar to the bottom of the screen.
  final bool bottomAppBar;
  
  /// The columns available for selection.
  final ExportColumnsManager columnsManager;

  /// The actor to manage importing.
  final CsvRecordParsingActor initialActor;

  @override
  State<ImportPreviewDialoge> createState() => _ImportPreviewDialogeState();
}

class _ImportPreviewDialogeState extends State<ImportPreviewDialoge> {
  static const int _kRowLimit = 30;

  late CsvRecordParsingActor _actor;

  late final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

  bool _showingError = false;

  /// Whether to limit shown rows to [_kRowLimit] for faster rendering.
  bool _limitRows = true;

  @override
  void initState() {
    super.initState();
    _actor = widget.initialActor;
    SchedulerBinding.instance.addPostFrameCallback((_) => _updateBanner());
  }

  void _updateBanner() {
    if (_showingError) {
      _showingError = false;
      messenger.removeCurrentMaterialBanner();
    }
    final err = _actor.attemptParse().error;
    if (err != null) {
      final localizations = AppLocalizations.of(context)!;
      messenger.showMaterialBanner(CustomBanner(
        content: Text(err.localize(localizations),
          style: TextStyle(color: Theme.of(context).colorScheme.error),),
      ),);
      _showingError = true;
    }
  }

  @override
  Widget build(BuildContext context) => FullscreenDialoge(
    bottomAppBar: widget.bottomAppBar,
    actionButtonText: AppLocalizations.of(context)!.import,
    onActionButtonPressed: (_showingError) ? null : () {
      final result = _actor.attemptParse();
      if (result.hasError()) return;
      Navigator.pop<List<FullEntry>>(context, result.getOr((e) => null));
    },
    actions: [
      CheckboxMenuButton(
        value: _actor.hasHeadline,
        onChanged: (state) => setState(() {
          _actor.hasHeadline = state ?? true;
          _actor.attemptParse();
        }),
        child: Text(AppLocalizations.of(context)!.titleInCsv),
      ),
    ],
    body: SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int colIdx = 0; colIdx < _actor.columnNames.length; colIdx++)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  DropdownButton(
                    items: [
                      DropdownMenuItem(
                        child: Text(
                          MaterialLocalizations.of(context).keyboardKeySelect,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      for (final parser in widget.columnsManager.getAllColumns())
                        DropdownMenuItem(
                          value: parser,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(parser.csvTitle),
                                if (parser.formatPattern != null)
                                  Text(parser.formatPattern!, style: Theme.of(context).textTheme.labelSmall,),
                              ],
                            ),
                          ),
                        ),
                    ],
                    value: _actor.columnParsers[colIdx],
                    onChanged: (parser) {
                      setState(() {
                        _actor.changeColumnParser(colIdx, parser);
                      });
                      _updateBanner();
                    },
                  ),
                  const Divider(),
                  for (int rowIdx = 0; rowIdx < (_limitRows
                      ? min(_actor.dataLines.length, _kRowLimit)
                      : _actor.dataLines.length); rowIdx++)
                    _buildCell(
                      rowIdx,
                      _actor.dataLines[rowIdx][colIdx],
                      _actor.columnParsers[colIdx],
                    ),
                  if (_limitRows && _kRowLimit < _actor.dataLines.length)
                    Align(
                      alignment: AlignmentDirectional.center,
                      child: TextButton(
                        onPressed: () => setState(() {_limitRows = false;}),
                        child: const Text('…'),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    ),
  );

  Widget _buildCell(int lineNumber, String csvContent, ExportColumn? parser) {
    Widget buildContent(String txt, [Color? color]) => Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 6,
        horizontal: 4,
      ),
      child: Text(txt, style: TextStyle(color: color,),),
    );

    final localizations = AppLocalizations.of(context)!;
    final parsed = parser?.decode(csvContent);
    if (parsed?.$2 == null) {
      return Tooltip(
        message: localizations.errParseFailedDecodingField(
          lineNumber,
          parsed?.$1.localize(localizations) ?? csvContent,
        ),
        child: buildContent(csvContent, Theme.of(context).colorScheme.error),
      );
    }

    var text = parsed!.$2.toString();
    if (text.isEmpty) text = '-';
    return Tooltip(
      message: csvContent,
      child: buildContent(text),
    );
  }
}

/// Shows a dialoge to preview import of a csv file
Future<List<FullEntry>?> showImportPreview(
  BuildContext context,
  CsvRecordParsingActor initialActor,
  ExportColumnsManager columnsManager,
  bool bottomAppBar,) =>
  showDialog<List<FullEntry>>(
    context: context, builder: (context) =>
    ImportPreviewDialoge(
      bottomAppBar: bottomAppBar,
      initialActor: initialActor,
      columnsManager: columnsManager,
    ),
  );

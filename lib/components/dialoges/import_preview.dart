
import 'package:blood_pressure_app/components/dialoges/fullscreen_dialoge.dart';
import 'package:blood_pressure_app/model/export_import/column.dart';
import 'package:blood_pressure_app/model/export_import/csv_record_parsing_actor.dart';
import 'package:blood_pressure_app/model/storage/export_columns_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ImportPreview extends StatefulWidget {

  const ImportPreview({super.key,
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
  State<ImportPreview> createState() => _ImportPreviewState();
}

class _ImportPreviewState extends State<ImportPreview> {
  late CsvRecordParsingActor _actor;

  @override
  void initState() {
    super.initState();
    _actor = widget.initialActor;
  }

  @override
  Widget build(BuildContext context) => FullscreenDialoge(
    actionButtonText: AppLocalizations.of(context)!.import,
    bottomAppBar: widget.bottomAppBar,
    body: SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int colIdx = 0; colIdx < _actor.columnNames.length; colIdx++)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                            padding: EdgeInsets.only(top: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(parser.csvTitle),
                                if (parser.formatPattern != null)
                                  Text(parser.formatPattern!, style: Theme.of(context).textTheme.labelSmall,),
                              ],
                            ),
                          ), // TODO: consider more info
                        ),
                    ],
                    value: _actor.columnParsers[_actor.columnNames[colIdx]],
                    onChanged: (parser) {
                      setState(() {
                        _actor.changeColumnParser(_actor.columnNames[colIdx], parser);
                      });
                    },
                  ),
                  const Divider(),
                  for (int rowIdx = 0; rowIdx < _actor.dataLines.length; rowIdx++) // TODO rework if needed (parsed?)
                    _buildCell(
                      rowIdx,
                      _actor.dataLines[rowIdx][colIdx],
                      _actor.columnParsers[_actor.columnNames[colIdx]],
                    ),
                ],
              ),
          ],
        ),
      ),
    ),
  );

  Widget _buildCell(int lineNumber, String csvContent, ExportColumn? parser) {
    final localizations = AppLocalizations.of(context)!;
    final parsed = parser?.decode(csvContent);
    if (parsed?.$2 == null) {
      return Tooltip(
        message: localizations.errParseFailedDecodingField(
          lineNumber,
          parsed?.$1.localize(localizations) ?? csvContent,
        ),
        child: Text(csvContent, style: TextStyle(
          color: Theme.of(context).colorScheme.error,
        ),),
      );
    }

    // TODO: time formatting, more fitting localizations

    var text = parsed!.$2.toString();
    if (text.isEmpty) text = '-';
    return Tooltip(
      message: csvContent,
      child: Text(text),
    );
  }
}

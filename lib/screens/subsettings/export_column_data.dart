import 'package:blood_pressure_app/components/consistent_future_builder.dart';
import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:blood_pressure_app/model/export_import/legacy_column.dart';
import 'package:blood_pressure_app/model/export_options.dart';
import 'package:blood_pressure_app/screens/subsettings/export_field_format_documentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class  EditExportColumnPage extends StatefulWidget {
  final String? initialInternalName;
  final String? initialDisplayName;
  final String? initialFormatPattern;
  final bool editable;
  
  const EditExportColumnPage({super.key, this.initialDisplayName, this.initialInternalName, 
    this.initialFormatPattern, this.editable = true});

  @override
  State<EditExportColumnPage> createState() => _EditExportColumnPageState();
}

class _EditExportColumnPageState extends State<EditExportColumnPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _internalName;
  String? _displayName;
  String? _formatPattern;
  bool _editedInternalName = false;
  var _internalNameKeyNr = 0;


  @override
  void initState() {
    super.initState();
    _internalName = widget.initialInternalName;
    _displayName = widget.initialDisplayName;
    _formatPattern= widget.initialFormatPattern;
  }

  _EditExportColumnPageState();
  
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return ConsistentFutureBuilder(
      future: ExportConfigurationModel.get(localizations),
      lastChildWhileWaiting: true,
      onData: (BuildContext context, ExportConfigurationModel exportConfigurationModel) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(60.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!widget.editable)
                      Text(localizations.errCantEditThis),
                    Opacity(
                      opacity: widget.editable ? 1 : 0.7,
                      child: IgnorePointer(
                        ignoring: !widget.editable,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              key: const Key('displayName'),
                              initialValue: _displayName,
                              decoration: InputDecoration(label: Text(localizations.displayTitle)),
                              onChanged: (String? value) {
                                if (value != null && value.isNotEmpty) {
                                  setState(() {
                                    _displayName = value;
                                  });
                                  if (_editedInternalName || (widget.initialInternalName != null)) return;
                                  final asciiName = value.replaceAll(RegExp(r'[^A-Za-z0-9 ]'), '');
                                  final internalName = asciiName.replaceAllMapped(RegExp(r' (.)'), (match) {
                                    return match.group(1)!.toUpperCase();
                                  }).replaceAll(' ', '');
                                  setState(() {
                                    _internalNameKeyNr++;
                                    _internalName = internalName;
                                  });
                                }
                              },
                            ),
                            TextFormField(
                              key: Key('internalName$_internalNameKeyNr'), // it should update when display name is changed without unfocussing on edit
                              initialValue: _internalName,
                              decoration: InputDecoration(label: Text(localizations.internalName)),
                              enabled: (widget.initialInternalName == null),
                              validator: (String? value) {
                                if (value == null || value.isEmpty || RegExp(r'[^A-Za-z0-9]').hasMatch(value)) {
                                  return localizations.errOnlyLatinCharactersAndArabicNumbers;
                                }
                                if (exportConfigurationModel.availableFormatsMap.keys.contains(value)) {
                                  return localizations.errExportColumnWithThisNameAlreadyExists;
                                }
                                return null;
                              },
                              onChanged: (String? value) {
                                if (value != null && value.isNotEmpty && !RegExp(r'[^A-Za-z0-9]').hasMatch(value)) {
                                  setState(() {
                                    _internalName = value;
                                    _editedInternalName = true;
                                  });
                                }
                              },
                            ),
                            TextFormField(
                              key: const Key('formatPattern'),
                              initialValue: _formatPattern,
                              decoration: InputDecoration(
                                label: Text(localizations.fieldFormat),
                                suffixIcon: IconButton(
                                    onPressed: () {
                                      Navigator.of(context).push(MaterialPageRoute(
                                          builder: (context) => InformationScreen(text: localizations.exportFieldFormatDocumentation)));
                                    },
                                    icon: const Icon(Icons.info_outline)
                                ),
                              ),
                              maxLines: 6,
                              minLines: 1,
                              validator: (String? value) {
                                if (value == null || value.isEmpty) {
                                  return localizations.errNoValue;
                                } else if (_internalName != null && _displayName != null) {
                                  try {
                                    final column = LegacyExportColumn(internalName: _internalName!, columnTitle: _displayName!, formatPattern: value);
                                    column.formatRecord(BloodPressureRecord(DateTime.now(), 100, 80, 60, ''));
                                    _formatPattern = value;
                                  } catch (e) {
                                    _formatPattern = null;
                                    return e.toString();
                                  }
                                }
                                return null;
                              },
                              onChanged: (value) => setState(() {_formatPattern = value;}),
                            ),
                            const SizedBox(height: 12,),
                            Text(localizations.result),
                            Text(((){try {
                              final column = LegacyExportColumn(internalName: _internalName!, columnTitle: _displayName!, formatPattern: _formatPattern!);
                              return column.formatRecord(BloodPressureRecord(DateTime.now(), 100, 80, 60, 'test'));
                            } catch (e) {
                              return '-';
                            }})()),
                            const SizedBox(height: 24,),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        TextButton(
                            key: const Key('btnCancel'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },

                            child: Text(localizations.btnCancel)
                        ),
                        const Spacer(),
                        FilledButton.icon(
                          key: const Key('btnSave'),
                          icon: const Icon(Icons.save),
                          label: Text(localizations.btnSave),
                          onPressed: (widget.editable) ? (() async {
                            if (_formKey.currentState?.validate() ?? false) {
                              final navigator = Navigator.of(context);
                              exportConfigurationModel.addOrUpdate(LegacyExportColumn(
                                  internalName: _internalName!,
                                  columnTitle: _displayName!,
                                  formatPattern: _formatPattern!
                              ));
                              navigator.pop();
                            }
                          }) : null,
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        )
      ),
    );
  }
}
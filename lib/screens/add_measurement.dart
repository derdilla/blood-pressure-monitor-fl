import 'package:blood_pressure_app/components/date_time_picker.dart';
import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:blood_pressure_app/model/export_import.dart';
import 'package:blood_pressure_app/model/export_options.dart';
import 'package:blood_pressure_app/model/storage/export_settings_store.dart';
import 'package:blood_pressure_app/model/storage/intervall_store.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AddMeasurementPage extends StatefulWidget {
  final DateTime? initTime;
  final int? initSys;
  final int? initDia;
  final int? initPul;
  final String? initNote;
  final MeasurementNeedlePin? initNeedlePin;
  final bool isEdit;

  const AddMeasurementPage(
      {super.key,
      this.initTime,
      this.initSys,
      this.initDia,
      this.initPul,
      this.initNote,
      this.initNeedlePin,
      this.isEdit = false,});

  static AddMeasurementPage edit(BloodPressureRecord record) {
    return AddMeasurementPage(
      initTime: record.creationTime,
      initSys: record.systolic,
      initDia: record.diastolic,
      initPul: record.pulse,
      initNote: record.notes,
      initNeedlePin: record.needlePin,
      isEdit: true,
    );
  }

  @override
  State<AddMeasurementPage> createState() => _AddMeasurementPageState();
}

class _AddMeasurementPageState extends State<AddMeasurementPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late DateTime _time;
  late int? _systolic;
  late int? _diastolic;
  late int? _pulse;
  late String? _note;
  late MeasurementNeedlePin? _needlePin;

  final _sysFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _time = widget.initTime ?? DateTime.now();
    _systolic = widget.initSys;
    _diastolic = widget.initDia;
    _pulse = widget.initPul;
    _note = widget.initNote;
    _needlePin = widget.initNeedlePin;
  }


  @override
  void dispose() {
    super.dispose();
    _sysFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _sysFocusNode.requestFocus();
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      body: Center(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(60.0),
              child: Consumer<Settings>(builder: (context, settings, child) {
                return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (settings.allowManualTimeInput)
                        buildTimeInput(context, settings, localizations),
                      ValueInput(
                          key: const Key('txtSys'),
                          initialValue: (_systolic ?? '').toString(),
                          hintText: localizations.sysLong,
                          basicValidation: !settings.allowMissingValues,
                          preValidation: (v) => _systolic = int.tryParse(v ?? ''),
                          focusNode: _sysFocusNode,
                          additionalValidator: (String? value) {
                            _systolic = int.tryParse(value ?? '');
                            return null;
                          }
                      ),
                      ValueInput(
                          key: const Key('txtDia'),
                          initialValue: (_diastolic ?? '').toString(),
                          hintText: localizations.diaLong,
                          basicValidation: !settings.allowMissingValues,
                          preValidation: (v) => _diastolic = int.tryParse(v ?? ''),
                          additionalValidator: (String? value) {
                            if (settings.validateInputs && (int.tryParse(value ?? '') ?? 0) >= (_systolic ?? 1)) {
                              return AppLocalizations.of(context)?.errDiaGtSys;
                            }
                            _diastolic = int.tryParse(value ?? '');
                            return null;
                          }
                      ),
                      ValueInput(
                          key: const Key('txtPul'),
                          initialValue: (_pulse ?? '').toString(),
                          hintText: localizations.pulLong,
                          basicValidation: !settings.allowMissingValues,
                          preValidation: (v) => _pulse = int.tryParse(v ?? ''),
                          additionalValidator: (String? value) {
                            if (settings.validateInputs && (int.tryParse(value ?? '') ?? 0) >= 600) { // https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3273956/
                              return AppLocalizations.of(context)?.errUnrealistic;
                            }
                            _pulse = int.tryParse(value ?? '');
                            return null;
                          }
                      ),
                      TextFormField(
                        key: const Key('txtNote'),
                        initialValue: (_note ?? '').toString(),
                        minLines: 1,
                        maxLines: 4,
                        decoration: InputDecoration(hintText: AppLocalizations.of(context)?.addNote),
                        validator: (String? value) {
                          _note = value;
                          return null;
                        },
                      ),
                      buildNeedlePin(localizations, context),
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
                            onPressed: () async {
                              if ((_formKey.currentState?.validate() ?? false) ||
                                  (_systolic == null && _diastolic == null && _pulse == null &&
                                      (_note != null || _needlePin != null))){
                                final settings = Provider.of<ExportSettings>(context, listen: false);
                                final intervalls = Provider.of<IntervallStoreManager>(context, listen: false);
                                final model = Provider.of<BloodPressureModel>(context, listen: false);
                                final navigator = Navigator.of(context);

                                if (widget.isEdit) {
                                  await model.delete(widget.initTime!);
                                }
                                await model.add(BloodPressureRecord(_time, _systolic, _diastolic, _pulse, _note ?? '',
                                needlePin: _needlePin));
                                if (settings.exportAfterEveryEntry && context.mounted) {
                                  final exporter = Exporter.load(context, await model.all, await ExportConfigurationModel.get(localizations));
                                  exporter.export();
                                }
                                // ensures the most recent entry is visible when adding measurements to avoid confusion
                                intervalls.mainPage.setToMostRecentIntervall();
                                navigator.pop();
                              }
                            },
                          )
                        ],
                      )
                    ]);
                }
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildNeedlePin(AppLocalizations localizations, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 25),
      child: OutlinedButton.icon(
        icon: const Icon(Icons.palette),
        label: Text(localizations.color),
        style: OutlinedButton.styleFrom(
          backgroundColor: _needlePin?.color.withAlpha(50),
          side: (_needlePin != null) ? BorderSide(color: _needlePin!.color) : null
        ),
        onPressed: () async {
          final color = await showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                contentPadding: const EdgeInsets.all(6.0),
                content: MaterialColorPicker(
                  circleSize: 53,
                  onMainColorChange: (color) {
                    Navigator.of(context).pop(color);
                  },
                ),
                actions: [
                  TextButton(
                    onPressed: Navigator.of(context).pop,
                    child: Text(localizations.btnCancel),
                  ),
                ],
              );
            },
          );
          setState(() {
            _needlePin = (color is MaterialColor) ? MeasurementNeedlePin(color) : null;
          });
        },

      )
    );
  }

  Widget buildTimeInput(BuildContext context, Settings settings, AppLocalizations localizations) {
    final formatter = DateFormat(settings.dateFormatString);
    return GestureDetector(
      onTap: () async {
        final now = DateTime.now();
        final selectionEnd = now.copyWith(minute: now.minute+5);
        final messenger = ScaffoldMessenger.of(context);
        var selectedTime = await showDateTimePicker(
            context: context,
            firstDate: DateTime.fromMillisecondsSinceEpoch(1),
            lastDate: selectionEnd,
            initialDate: _time);
        if (selectedTime != null) {
          if (settings.validateInputs && selectedTime.isAfter(selectionEnd)) {
            messenger.showSnackBar(SnackBar(content: Text(localizations.errTimeAfterNow)));
            if (selectedTime.hour > now.hour) selectedTime = selectedTime.copyWith(hour: now.hour);
            if (selectedTime.minute > now.minute) selectedTime = selectedTime.copyWith(minute: now.minute);
          } // validation for first date is not needed here as intervall starts at 00:00
          setState(() {
            _time = selectedTime!;
          });
        }
      },
      child: Column(
        children: [
          Row(children: [Text(formatter.format(_time)), const Spacer(), const Icon(Icons.edit)]),
          const SizedBox(height: 3,),
          Divider(
            color: Theme.of(context).disabledColor,
            thickness: 1,
          )
        ],
      ),
    );
  }
}

class ValueInput extends StatelessWidget {
  final String initialValue;
  final String hintText;
  final FocusNode? focusNode;
  final bool basicValidation;
  final void Function(String?)? preValidation;
  final FormFieldValidator<String> additionalValidator;
  final int? minLines;
  final int? maxLines;

  const ValueInput({super.key, required this.initialValue, required this.hintText, this.focusNode, this.basicValidation = true,
    this.preValidation, required this.additionalValidator, this.minLines, this.maxLines});

  @override
  Widget build(BuildContext context) {
    return Consumer<Settings>(builder: (context, settings, child) {
      return TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(hintText: hintText),
        minLines: minLines,
        maxLines: maxLines,
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
        focusNode: focusNode,
        onChanged: (String? value) {
          if (value != null && value.isNotEmpty && (int.tryParse(value) ?? -1) > 40) {
            FocusScope.of(context).nextFocus();
          }
        },
        validator: (String? value) {
          if (preValidation != null) preValidation!(value);
          if (basicValidation) {
            if (value == null || value.isEmpty || (int.tryParse(value) == null)) {
              return AppLocalizations.of(context)?.errNaN;
            } else if (settings.validateInputs && (int.tryParse(value) ?? -1) <= 30) {
              return AppLocalizations.of(context)?.errLt30;
            } else if (settings.validateInputs && (int.tryParse(value)??0) >= 400) {
              // https://pubmed.ncbi.nlm.nih.gov/7741618/
              return AppLocalizations.of(context)?.errUnrealistic;
            }
          }
          return additionalValidator(value);
        },
      );
    });
  }
}

import 'package:blood_pressure_app/components/date_time_picker.dart';
import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:blood_pressure_app/model/export_import.dart';
import 'package:blood_pressure_app/model/settings_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AddMeasurementPage extends StatefulWidget {
  final DateTime? initTime;
  final int? initSys;
  final int? initDia;
  final int? initPul;
  final String? initNote;
  final bool addInitialValuesOnCancel;

  const AddMeasurementPage(
      {super.key,
      this.initTime,
      this.initSys,
      this.initDia,
      this.initPul,
      this.initNote,
      this.addInitialValuesOnCancel = false});

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

  final _sysFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _time = widget.initTime ?? DateTime.now();
    _systolic = widget.initSys;
    _diastolic = widget.initDia;
    _pulse = widget.initPul;
    _note = widget.initNote;
  }

  @override
  Widget build(BuildContext context) {
    _sysFocusNode.requestFocus();
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
                      (() {
                        final formatter = DateFormat(settings.dateFormatString);
                        if (settings.allowManualTimeInput) {
                          return GestureDetector(
                            onTap: () async {
                              final now = DateTime.now();
                              final selectionEnd = now.copyWith(minute: now.minute+5);
                              final messenger = ScaffoldMessenger.of(context);
                              final errTimeAfterNow = AppLocalizations.of(context)!.errTimeAfterNow;
                              var selectedTime = await showDateTimePicker(
                                  context: context,
                                  firstDate: DateTime.fromMillisecondsSinceEpoch(0),
                                  lastDate: selectionEnd,
                                  initialDate: _time);
                              if (selectedTime != null) {
                                if (settings.validateInputs && selectedTime.isAfter(selectionEnd)) {
                                  messenger.showSnackBar(SnackBar(content: Text(errTimeAfterNow)));
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
                        } else {
                          return const SizedBox.shrink();
                        }
                      })(),
                      ValueInput(
                          key: const Key('txtSys'),
                          initialValue: (_systolic ?? '').toString(),
                          hintText: AppLocalizations.of(context)!.sysLong,
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
                          hintText: AppLocalizations.of(context)!.diaLong,
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
                          hintText: AppLocalizations.of(context)!.pulLong,
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
                        initialValue: (_note ?? '').toString(),
                        decoration: InputDecoration(hintText: AppLocalizations.of(context)?.addNote),
                        validator: (String? value) {
                          _note = value;
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      Row(
                        children: [
                          TextButton(
                            key: const Key('btnCancel'),
                            onPressed: () {
                              if (widget.addInitialValuesOnCancel) {
                                assert(widget.initTime != null);
                                Provider.of<BloodPressureModel>(context, listen: false).add(BloodPressureRecord(
                                    widget.initTime ?? DateTime.now(),
                                    widget.initSys,
                                    widget.initDia,
                                    widget.initPul,
                                    widget.initNote));
                              }
                              Navigator.of(context).pop();
                            },

                            child: Text(AppLocalizations.of(context)!.btnCancel)
                          ),
                          const Spacer(),
                          FilledButton.icon(
                            key: const Key('btnSave'),
                            icon: const Icon(Icons.save),
                            label: Text(AppLocalizations.of(context)!.btnSave),
                            onPressed: () async {
                              if ((_formKey.currentState?.validate() ?? false) ||
                                  (_systolic == null && _diastolic == null && _pulse == null && _note != null)){
                                final settings = Provider.of<Settings>(context, listen: false);
                                final model = Provider.of<BloodPressureModel>(context, listen: false);
                                final navigator = Navigator.of(context);

                                await model.add(BloodPressureRecord(_time, _systolic, _diastolic, _pulse, _note));
                                if (settings.exportAfterEveryEntry && context.mounted) {
                                  final exporter = Exporter(context);
                                  exporter.export();
                                }
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
}

class ValueInput extends StatelessWidget {
  final String initialValue;
  final String hintText;
  final FocusNode? focusNode;
  final bool basicValidation;
  final void Function(String?)? preValidation;
  final FormFieldValidator<String> additionalValidator;

  const ValueInput({super.key, required this.initialValue, required this.hintText, this.focusNode, this.basicValidation = true,
    this.preValidation, required this.additionalValidator});

  @override
  Widget build(BuildContext context) {
    return Consumer<Settings>(builder: (context, settings, child) {
      return TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(hintText: hintText),
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

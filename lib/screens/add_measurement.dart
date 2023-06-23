import 'package:blood_pressure_app/components/date_time_picker.dart';
import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:blood_pressure_app/model/settings_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AddMeasurementPage extends StatefulWidget {
  final DateTime? initTime;
  final int initSys;
  final int initDia;
  final int initPul;
  final String initNote;
  final bool isEdit;

  const AddMeasurementPage(
      {super.key,
      this.initTime,
      this.initSys = -1,
      this.initDia = -1,
      this.initPul = -1,
      this.initNote = '',
      this.isEdit = false});

  @override
  State<AddMeasurementPage> createState() => _AddMeasurementPageState();
}

class _AddMeasurementPageState extends State<AddMeasurementPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late DateTime _time;
  late int _systolic;
  late int _diastolic;
  late int _pulse;
  late String _note;

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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Consumer<Settings>(builder: (context, settings, child) {
                    final formatter = DateFormat(settings.dateFormatString);
                    if (settings.allowManualTimeInput) {
                      return GestureDetector(
                        onTap: () async {
                          var selectedTime = await showDateTimePicker(
                              context: context,
                              firstDate: DateTime.fromMillisecondsSinceEpoch(0),
                              lastDate: DateTime.now().copyWith(second: DateTime.now().second + 1),
                              initialDate: _time);
                          if (selectedTime != null) {
                            setState(() {
                              _time = selectedTime;
                            });
                          }
                        },
                        child: Column(
                          children: [
                            Row(
                              children: [Text(formatter.format(_time)), const Spacer(), const Icon(Icons.edit)],
                            ),
                            const SizedBox(
                              height: 3,
                            ),
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
                  }),
                  Consumer<Settings>(builder: (context, settings, child) {
                    return TextFormField(
                      key: const Key('txtSys'),
                      initialValue: widget.isEdit ? _systolic.toString() : '',
                      decoration: InputDecoration(hintText: AppLocalizations.of(context)?.sysLong),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                      focusNode: _sysFocusNode,
                      onChanged: (String? value) {
                        // to next field
                        if (value != null && value.isNotEmpty && (int.tryParse(value) ?? -1) > 40) {
                          FocusScope.of(context).nextFocus();
                        }
                      },
                      validator: (String? value) {
                        if (value == null || value.isEmpty || (int.tryParse(value) == null)) {
                          return AppLocalizations.of(context)?.errNaN;
                        } else if (settings.validateInputs && (int.tryParse(value) ?? -1) <= 30) {
                          return AppLocalizations.of(context)?.errLt30;
                        } else if (settings.validateInputs && (int.tryParse(value) ?? 1000) >= 400) {
                          // exceeding this value is unlikely: https://pubmed.ncbi.nlm.nih.gov/7741618/
                          return AppLocalizations.of(context)?.errUnrealistic;
                        } else {
                          _systolic = int.tryParse(value) ?? -1;
                        }
                        return null;
                      },
                    );
                  }),
                  Consumer<Settings>(builder: (context, settings, child) {
                    return TextFormField(
                      key: const Key('txtDia'),
                      initialValue: widget.isEdit ? _diastolic.toString() : '',
                      decoration: InputDecoration(hintText: AppLocalizations.of(context)?.diaLong),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                      onChanged: (String? value) {
                        // to next field
                        if (value != null && value.isNotEmpty && (int.tryParse(value) ?? -1) > 40) {
                          FocusScope.of(context).nextFocus();
                        }
                      },
                      validator: (String? value) {
                        if (value == null || value.isEmpty || (int.tryParse(value) == null)) {
                          return AppLocalizations.of(context)?.errNaN;
                        } else if (settings.validateInputs && (int.tryParse(value) ?? -1) <= 30) {
                          return AppLocalizations.of(context)?.errLt30;
                        } else if (settings.validateInputs && (int.tryParse(value) ?? 1000) >= 400) {
                          // exceeding this value is unlikely: https://pubmed.ncbi.nlm.nih.gov/7741618/
                          return AppLocalizations.of(context)?.errUnrealistic;
                        } else if (settings.validateInputs && (int.tryParse(value) ?? -1) >= _systolic) {
                          return AppLocalizations.of(context)?.errDiaGtSys;
                        } else {
                          _diastolic = int.tryParse(value) ?? -1;
                        }
                        return null;
                      },
                    );
                  }),
                  Consumer<Settings>(builder: (context, settings, child) {
                    return TextFormField(
                      key: const Key('txtPul'),
                      initialValue: widget.isEdit ? _pulse.toString() : '',
                      decoration: InputDecoration(hintText: AppLocalizations.of(context)?.pulLong),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                      onChanged: (String? value) {
                        // to next field
                        if (value != null && value.isNotEmpty && (int.tryParse(value) ?? -1) > 35) {
                          FocusScope.of(context).nextFocus();
                        }
                      },
                      validator: (String? value) {
                        if (value == null || value.isEmpty || (int.tryParse(value) == null)) {
                          return AppLocalizations.of(context)?.errNaN;
                        } else if (settings.validateInputs && (int.tryParse(value) ?? -1) <= 30) {
                          return AppLocalizations.of(context)?.errLt30;
                        } else if (settings.validateInputs && (int.tryParse(value) ?? 1000) >= 600) {
                          // exceeding this value is unlikely: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3273956/
                          return AppLocalizations.of(context)?.errUnrealistic;
                        } else {
                          _pulse = int.tryParse(value) ?? -1;
                        }
                        return null;
                      },
                    );
                  }),
                  TextFormField(
                    initialValue: widget.isEdit ? _note.toString() : '',
                    decoration: InputDecoration(hintText: AppLocalizations.of(context)?.addNote),
                    validator: (String? value) {
                      _note = value ?? "";
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                          key: const Key('btnCancel'),
                          onPressed: () {
                            if (widget.isEdit) {
                              Provider.of<BloodPressureModel>(context, listen: false).add(BloodPressureRecord(
                                  widget.initTime ?? DateTime.now(),
                                  widget.initSys,
                                  widget.initDia,
                                  widget.initPul,
                                  widget.initNote));
                            }
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).unselectedWidgetColor),
                          child: Text(AppLocalizations.of(context)!.btnCancel)),
                      const Spacer(),
                      ElevatedButton(
                          key: const Key('btnSave'),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              Provider.of<BloodPressureModel>(context, listen: false)
                                  .add(BloodPressureRecord(_time, _systolic, _diastolic, _pulse, _note));
                              Navigator.of(context).pop();
                            }
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
                          child: Text(AppLocalizations.of(context)!.btnSave))
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

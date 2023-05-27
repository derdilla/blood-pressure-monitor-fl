import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:blood_pressure_app/model/settings_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';


class AddMeasurementPage extends StatefulWidget {
  final DateTime? initTime;
  final int initSys;
  final int initDia;
  final int initPul;
  final String initNote;
  final bool isEdit;

  const AddMeasurementPage({super.key,
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
          child: Container(
            padding: const EdgeInsets.all(60.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Consumer<Settings>(
                    builder: (context, settings, child) {
                      final formatter = DateFormat(settings.dateFormatString);
                      if(settings.allowManualTimeInput) {
                        return TextFormField(
                          initialValue: formatter.format(_time),
                          decoration: const InputDecoration(
                              hintText: 'time'
                          ),
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a value';
                            } else {
                              try {
                                _time = formatter.parse(value);
                              } on FormatException {
                                return 'date format: ${formatter.pattern}';
                              }
                            }
                            return null;
                          },
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    }
                ),
                Consumer<Settings>(
                  builder: (context, settings, child) {
                    return TextFormField(
                      initialValue: widget.isEdit ? _systolic.toString() : '',
                      decoration: const InputDecoration(
                          hintText: 'systolic'
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      focusNode: _sysFocusNode,
                      onChanged: (String? value) {
                        // to next field
                        if ( value != null && value.isNotEmpty &&
                            (int.tryParse(value) ?? -1) > 40) {
                          FocusScope.of(context).nextFocus();
                        }
                      },
                      validator: (String? value) {
                        if (value == null || value.isEmpty
                            || (int.tryParse(value) == null)) {
                          return 'Please enter a Number';
                        } else if (settings.validateInputs && (int.tryParse(value) ?? -1) <= 30) {
                          return 'Number < 30? Turn off validation in settings!';
                        } else if (settings.validateInputs && (int.tryParse(value) ?? 1000) >= 400) { // exceeding this value is unlikely: https://pubmed.ncbi.nlm.nih.gov/7741618/
                          return 'Unrealistic value? Turn off validation in settings!';
                        } else {
                          _systolic = int.tryParse(value) ?? -1;
                        }
                        return null;
                      },
                    );
                  }
                ),
                Consumer<Settings>(
                  builder: (context, settings, child) {
                    return TextFormField(
                      initialValue: widget.isEdit ? _diastolic.toString() : '',
                      decoration: const InputDecoration(
                          hintText: 'diastolic'
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      onChanged: (String? value) {
                        // to next field
                        if ( value != null && value.isNotEmpty &&
                            (int.tryParse(value) ?? -1) > 40) {
                          FocusScope.of(context).nextFocus();
                        }
                      },
                      validator: (String? value) {
                        if (value == null || value.isEmpty
                            || (int.tryParse(value) == null)) {
                          return 'Please enter a Number';
                        } else if (settings.validateInputs && (int.tryParse(value) ?? -1) <= 30) {
                          return 'Number < 30? Turn off validation in settings!';
                        } else if (settings.validateInputs && (int.tryParse(value) ?? 1000) >= 400) { // exceeding this value is unlikely: https://pubmed.ncbi.nlm.nih.gov/7741618/
                          return 'Unrealistic value? Turn off validation in settings!';
                        } else {
                          _diastolic = int.tryParse(value) ?? -1;
                        }
                        return null;
                      },
                    );
                  }
                ),
                Consumer<Settings>(
                  builder: (context, settings, child) {
                    return TextFormField(
                      initialValue: widget.isEdit ? _pulse.toString() : '',
                      decoration: const InputDecoration(
                          hintText: 'pulse'
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      onChanged: (String? value) {
                        // to next field
                        if ( value != null && value.isNotEmpty &&
                            (int.tryParse(value) ?? -1) > 35) {
                          FocusScope.of(context).nextFocus();
                        }
                      },
                      validator: (String? value) {
                        if (value == null || value.isEmpty
                            || (int.tryParse(value) == null)) {
                          return 'Please enter a Number';
                        } else if (settings.validateInputs && (int.tryParse(value) ?? -1) <= 30) {
                          return 'Number < 30? Turn off validation in settings!';
                        } else if (settings.validateInputs && (int.tryParse(value) ?? 1000) >= 600) { // exceeding this value is unlikely: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3273956/
                          return 'Unrealistic value? Turn off validation in settings!';
                        } else {
                          _pulse = int.tryParse(value) ?? -1;
                        }
                        return null;
                      },
                    );
                  }
                ),
                TextFormField(
                  initialValue: widget.isEdit ? _note.toString() : '',
                  decoration: const InputDecoration(
                      hintText: 'note (optional)'
                  ),
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
                        onPressed: () {
                          if (widget.isEdit) {
                            Provider.of<BloodPressureModel>(context, listen: false).add(
                                BloodPressureRecord(widget.initTime ?? DateTime.now(), widget.initSys, widget.initDia, widget.initPul, widget.initNote)
                            );
                          }
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).unselectedWidgetColor
                        ),
                        child: const Text('CANCEL')
                    ),
                    const Spacer(),
                    ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            Provider.of<BloodPressureModel>(context, listen: false).add(
                                BloodPressureRecord(_time, _systolic, _diastolic, _pulse, _note)
                            );
                            Navigator.of(context).pop();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor
                        ),
                        child: const Text('SAVE')
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
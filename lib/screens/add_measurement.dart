import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:blood_pressure_app/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';


class AddMeasurementPage extends StatefulWidget {
  const AddMeasurementPage({super.key});

  @override
  State<AddMeasurementPage> createState() => _AddMeasurementPageState();
}

class _AddMeasurementPageState extends State<AddMeasurementPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int _systolic = -1;
  int _diastolic = -1;
  int _pulse = -1;
  String _note = "";


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Form(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.all(80.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'systolic'
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  validator: (String? value) {
                    if (value == null || value.isEmpty
                        || (double.tryParse(value) == null)) {
                      return 'Please enter a Number';
                    }
                    return null;
                  },
                  onSaved: (String? value) {
                    if (value != null && value.isNotEmpty
                        || (double.tryParse(value ?? "-1") != null)) {
                      _systolic = double.tryParse(value ?? "-1") as int;
                    }
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                      hintText: 'diastolic'
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  validator: (String? value) {
                    if (value == null || value.isEmpty
                        || (double.tryParse(value) == null)) {
                      return 'Please enter a Number';
                    }
                    return null;
                  },
                  onSaved: (String? value) {
                    if (value != null && value.isNotEmpty
                        || (double.tryParse(value ?? "-1") != null)) {
                      _diastolic = double.tryParse(value ?? "-1") as int;
                    }
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                      hintText: 'pulse'
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  validator: (String? value) {
                    if (value == null || value.isEmpty
                        || (double.tryParse(value) == null)) {
                      return 'Please enter a Number';
                    }
                    return null;
                  },
                  onSaved: (String? value) {
                    if (value != null && value.isNotEmpty
                        || (double.tryParse(value ?? "-1") != null)) {
                      _pulse = double.tryParse(value ?? "-1") as int;
                    }
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                      hintText: 'note (optional)'
                  ),
                  onSaved: (String? value) {
                    _note = value ?? "";
                  },
                ),
                const SizedBox(
                  height: 24,
                ),
                ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Provider.of<BloodPressureModel>(context, listen: false).add(
                          BloodPressureRecord(DateTime.now(), _systolic, _diastolic, _pulse, _note)
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AppHome()),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor
                    ),
                    child: const Text('SAVE'))
              ],
            ),
          ),
        ),
      ),
    );
  }

}
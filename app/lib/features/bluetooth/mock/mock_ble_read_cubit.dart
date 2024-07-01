import 'package:blood_pressure_app/bluetooth/characteristics/ble_measurement_data.dart';
import 'package:blood_pressure_app/bluetooth/characteristics/ble_measurement_status.dart';
import 'package:blood_pressure_app/bluetooth/logic/ble_read_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class MockBleReadCubit extends Cubit<BleReadState> implements BleReadCubit {
  MockBleReadCubit(): super(BleReadSuccess(
    BleMeasurementData(
      systolic: 123,
      diastolic: 456,
      pulse: 67,
      meanArterialPressure: 123456,
      isMMHG: true,
      userID: 3,
      status: BleMeasurementStatus(
        bodyMovementDetected: true,
        cuffTooLose: true,
        irregularPulseDetected: true,
        pulseRateInRange: true,
        pulseRateExceedsUpperLimit: true,
        pulseRateIsLessThenLowerLimit: true,
        improperMeasurementPosition: true,
      ),
      timestamp: DateTime.now(),
    ),
  ));

  @override
  Guid get characteristicUUID => throw UnimplementedError();

  @override
  Guid get serviceUUID => throw UnimplementedError();

}

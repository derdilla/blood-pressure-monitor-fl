import 'package:blood_pressure_app/components/ble_input/ble_input_bloc.dart';
import 'package:blood_pressure_app/components/ble_input/ble_input_events.dart';
import 'package:blood_pressure_app/components/ble_input/ble_input_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BleInput extends StatelessWidget{
  final bloc = BleInputBloc();

  BleInput({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<BleInputBloc, BleInputState>(
    bloc: bloc,
    builder: (BuildContext context, BleInputState state) {
      final localizations = AppLocalizations.of(context)!;
      return switch (state) {
        BleInputClosed() => IconButton(
          icon: const Icon(Icons.bluetooth),
          onPressed: () => bloc.add(BleInputOpened()),
        ),
        BleInputLoadInProgress() => _buildTwoElementCard(context,
          const CircularProgressIndicator(),
          Text(localizations.scanningDevices),
        ),
        BleInputLoadFailure() => _buildTwoElementCard(context,
          const Icon(Icons.bluetooth_disabled),
           Text('Failed loading input devices. Ensure the app has all neccessary permissions.'),
          onTap: () => bloc.add(BleInputOpened()),
        ),
        BleInputLoadSuccess() => state.availableDevices.isEmpty // TODO: card
          ? Text('No compatible BLE GATT devices found.')
          : ListView.builder(
            itemCount: state.availableDevices.length,
            itemBuilder: (context, idx) => ListTile(
              title: Text(state.availableDevices[idx].name),
              trailing: state.availableDevices[idx].connectable == Connectable.available
                ? Icon(Icons.bluetooth_audio)
                : Icon(Icons.bluetooth_disabled),
              onTap: () => bloc.add(BleInputDeviceSelected(state.availableDevices[idx])),
            ),
          ),
        BleInputPermissionFailure() => _buildTwoElementCard(context,
          const Icon(Icons.bluetooth_disabled),
          Text('Permissions error. Please allow all bluetooth permissions.'
              ' You also need the location permission on pre-Android 12 devices.'),
          onTap: () => bloc.add(BleInputOpened()),
        ),
        BleConnectInProgress() => _buildTwoElementCard(context,
          const CircularProgressIndicator(),
          Text('Connecting to bluetooth device'),
        ),
        BleConnectFailed() => _buildTwoElementCard(context,
          const Icon(Icons.bluetooth_disabled),
          Text('Connection to bluetooth device failed :('),
          onTap: () => bloc.add(BleInputOpened()),
        ),
        BleConnectSuccess() => _buildTwoElementCard(context,
          const Icon(Icons.bluetooth_connected),
          Text('Connected to device, waiting for measurement'),
        ),
        BleMeasurementInProgress() => _buildTwoElementCard(context,
          const CircularProgressIndicator(),
          Text('Handeling incomming measurement'),
        ),
        BleMeasurementSuccess() => _buildTwoElementCard(context,
          const Icon(Icons.done, color: Colors.lightGreen,),
          Text('Recieved measurement:'
              '\n${state.record}'
              '\nCuff loose: ${state.cuffLoose}'
              '\nIrregular pulse: ${state.irregularPulse}'
              '\nBody moved: ${state.bodyMoved}'
              '\nWrong measurement position: ${state.improperMeasurementPosition}'
              '\nMeasurement status: ${state.measurementStatus}'
          ),
        ),
      };
    },
  );
  // TODO: add method for quitting

  /// Wrap open connection menu in card.
  Widget _buildMainCard(BuildContext context, Widget child) => Container(
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(24),
    ),
    width: MediaQuery.of(context).size.width,
    height: MediaQuery.of(context).size.width,
    padding: const EdgeInsets.all(24),
    margin: const EdgeInsets.all(8),
    child: child,
  );

  Widget _buildTwoElementCard(
    BuildContext context,
    Widget top,
    Widget bottom, {
    void Function()? onTap,
  }) => InkWell(
    onTap: onTap,
    child: _buildMainCard(context, Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [top, const SizedBox(height: 8,), bottom,],
      ),
    )),
  );
}

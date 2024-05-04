import 'package:blood_pressure_app/components/ble_input/ble_input_bloc.dart';
import 'package:blood_pressure_app/components/ble_input/ble_input_events.dart';
import 'package:blood_pressure_app/components/ble_input/ble_input_state.dart';
import 'package:blood_pressure_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

/// An interactive way to add measurements over bluetooth.
class BleInput extends StatefulWidget {
  /// Create an interactive bluetooth measurement adder.
  const BleInput({super.key, this.bloc});

  /// Logic implementation of this input form.
  final BleInputBloc? bloc; // Configurable for testing.

  @override
  State<BleInput> createState() => _BleInputState();
}

class _BleInputState extends State<BleInput> {

  late final BleInputBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = widget.bloc ?? BleInputBloc();
  }

  @override
  Widget build(BuildContext context) => SizeChangedLayoutNotifier(
    child: BlocBuilder<BleInputBloc, BleInputState>(
      bloc: bloc,
      builder: (BuildContext context, BleInputState state) {
        debugLog.add('${DateTime.now()} - STATE:${state.runtimeType}');
        final localizations = AppLocalizations.of(context)!;
        return switch (state) {
          BleInputClosed() => IconButton(
            icon: const Icon(Icons.bluetooth),
            onPressed: () => bloc.add(OpenBleInput()),
          ),
          BleInputLoadInProgress() => _buildTwoElementCard(context,
            const CircularProgressIndicator(),
            Text(localizations.scanningDevices),
          ),
          BleInputLoadFailure() => _buildTwoElementCard(context,
            const Icon(Icons.bluetooth_disabled),
            Text(localizations.errBleCantOpen),
            onTap: () => bloc.add(OpenBleInput()),
          ),
          BleInputLoadSuccess() => _buildLoadSuccess(state),
          BleInputPermissionFailure() => _buildTwoElementCard(context,
            const Icon(Icons.bluetooth_disabled),
            Text(localizations.errBleNoPerms),
            onTap: () => bloc.add(OpenBleInput()),
          ),
          BleConnectInProgress() => _buildTwoElementCard(context,
            const CircularProgressIndicator(),
            Text(localizations.bleConnecting),
          ),
          BleConnectFailed() => _buildTwoElementCard(context,
            const Icon(Icons.bluetooth_disabled),
            Text(localizations.errBleCouldNotConnect),
            onTap: () => bloc.add(OpenBleInput()),
          ),
          BleConnectSuccess() => _buildTwoElementCard(context,
            const Icon(Icons.bluetooth_connected),
            Text(localizations.bleConnected),
          ),
          BleMeasurementInProgress() => _buildTwoElementCard(context,
            const CircularProgressIndicator(),
            Text(localizations.bleProcessing),
          ),
          BleMeasurementSuccess() => _buildTwoElementCard(context,
            const Icon(Icons.done, color: Colors.lightGreen,),
            Text('Received measurement:' // TODO: rework this process
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
    ),
  );

  Widget _buildLoadSuccess(BleInputLoadSuccess state) {
    debugLog.add('BleInputLoadSuccess:${state.availableDevices}');
    // List of available ble devices
    final localizations = AppLocalizations.of(context)!;
    if (state.availableDevices.isEmpty) {
      return _buildTwoElementCard(context,
        const Icon(Icons.info),
        Text(localizations.errBleNoDev),
        onTap: () => bloc.add(OpenBleInput()),
      );
    }
    return SizedBox(
      height: 250,
      child: _buildMainCard(context, ListView.builder(
        itemCount: state.availableDevices.length,
        itemBuilder: (context, idx) => ListTile(
          title: Text(state.availableDevices[idx].name),
          trailing: state.availableDevices[idx].connectable == Connectable.available
              ? const Icon(Icons.bluetooth_audio)
              : const Icon(Icons.bluetooth_disabled),
          onTap: () => bloc.add(BleInputDeviceSelected(state.availableDevices[idx])),
        ),
      ),),
    );
  }

  Widget _buildMainCard(BuildContext context, Widget child) => Card.outlined(
    color: Theme.of(context).cardColor,
    // borderRadius: BorderRadius.circular(24),
    // width: MediaQuery.of(context).size.width,
    // height: MediaQuery.of(context).size.width,
    // padding: const EdgeInsets.all(24),
    margin: const EdgeInsets.all(8),
    child: Stack(
      children: [
        Padding( // content
          padding: const EdgeInsets.all(24),
          child: child,
        ),
        Align(
          alignment: Alignment.topRight,
          child: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => bloc.add(CloseBleInput()),
          ),
        ),
      ],
    ),
  );

  /// Builds the full card but with two centered elements.
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
    ),),
  );
}

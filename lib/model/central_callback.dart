import 'package:blood_pressure_app/components/consistent_future_builder.dart';
import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:blood_pressure_app/model/export_import.dart';
import 'package:blood_pressure_app/model/export_options.dart';
import 'package:blood_pressure_app/model/storage/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

/// Central place to put code that needs to be called from multiple places.
///
/// This solution is suboptimal, as it doesn't utilize the framework. Before falling back to this for implementing
/// callbacks, a solution using the framework should be considered. This solution at least allows for simple usage
/// in the rest of the code.
class CentralCallback {
  CentralCallback._create(
      this._context,
      this._exportSettings,
      this._bloodPressureModel,
      this._exportConfigurationModel,
      this._intervallStoreManager);

  static CentralCallback? _instance;

  /// CentralCallback instance.
  ///
  /// This is null until [CentralCallback.init] is called.
  static CentralCallback? get instance => _instance;

  /// Creates [CentralCallback.instance] object with values passed on first call.
  ///
  /// Subsequent calls will be ignored.
  static Future<void> init(BuildContext context) async {
    if (instance != null) return;
    assert (context.mounted, 'Expects valid context');
    if (!context.mounted) return;

    final loc = AppLocalizations.of(context)!;
    final exportSet = Provider.of<ExportSettings>(context, listen: false);
    final bpModel = Provider.of<BloodPressureModel>(context, listen: false);
    final intervalls = Provider.of<IntervallStoreManager>(context, listen: false);
    _instance = CentralCallback._create(context, exportSet, bpModel, await ExportConfigurationModel.get(loc),intervalls);
    return;
  }
  
  final BuildContext _context;
  final ExportSettings _exportSettings;
  final BloodPressureModel _bloodPressureModel;
  final ExportConfigurationModel _exportConfigurationModel;
  final IntervallStoreManager _intervallStoreManager;

  void onMeasurementAdded(BloodPressureRecord record) async {
    final r = _intervallStoreManager.exportPage.currentRange;
    final allMeasurements = await _bloodPressureModel.getInTimeRange(r.start, r.end);

    assert(_context.mounted);
    if (_exportSettings.exportAfterEveryEntry && _context.mounted) {
      final exporter = Exporter.load(_context, allMeasurements, _exportConfigurationModel);
    exporter.export();
  }
  }
}

class CentralCallbackInitializer extends StatelessWidget {
  /// Create a widget that ensures that CentralCallback is initialized before the [child] is visible.
  const CentralCallbackInitializer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => ConsistentFutureBuilder(future: CentralCallback.init(context),
      onData: (context, _) => child, onWaiting: const SizedBox.shrink(),);
}
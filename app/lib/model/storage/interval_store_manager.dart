import 'dart:convert';

import 'package:blood_pressure_app/model/storage/types/interval_storage_setting.dart';
import 'package:flutter/material.dart';
import 'package:settings_annotation/settings_annotation.dart';

part 'interval_store_manager.store.dart';

/// stores the interval objects that are needed in the app and provides named access to them.
@GenerateSettings()
class _IntervalStoreManagerSpec {
  final Setting<IntervalStorage> mainPage = IntervalStorageSetting();
  final Setting<IntervalStorage> exportPage = IntervalStorageSetting();
  final Setting<IntervalStorage> statsPage = IntervalStorageSetting();

}

extension IntervalStoreManagerUtil on IntervalStoreManager {
  IntervalStorage get(IntervalStoreManagerLocation type) => switch (type) {
    IntervalStoreManagerLocation.mainPage => mainPage,
    IntervalStoreManagerLocation.exportPage => exportPage,
    IntervalStoreManagerLocation.statsPage => statsPage,
  };
}

/// Locations supported by [IntervalStoreManager].
enum IntervalStoreManagerLocation {
  /// List on home screen.
  mainPage,
  /// All exported data.
  exportPage,
  /// Data for all statistics.
  statsPage,
}

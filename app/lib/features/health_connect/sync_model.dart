import 'package:flutter/foundation.dart';

abstract class SyncModel extends ChangeNotifier {
  bool get syncing;

  double get progress;

  Future<void> syncWeight();
}

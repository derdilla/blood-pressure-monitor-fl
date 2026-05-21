import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:settings_annotation/src/deep_setting.dart';

void main() {
  test('Notifies on inner value change', () {
    final s = DeepSetting(initialValue: B());
    addTearDown(s.dispose);

    int notifyCount = 0;
    s.addListener(() => notifyCount++);

    expect(notifyCount, equals(0));
    s.value.notify();
    expect(notifyCount, equals(1));

    s.value = B();
    expect(notifyCount, equals(2));

    s.value.notify();
    expect(notifyCount, equals(3));
  });
}

class B with ChangeNotifier {
  void notify() => notifyListeners();
}

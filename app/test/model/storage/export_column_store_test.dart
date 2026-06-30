import 'package:blood_pressure_app/features/export_import/model/column.dart';
import 'package:blood_pressure_app/model/storage/export_columns_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('resolves duplicate columns correctly', () {
    final store = ExportColumnsManager();
    final c = <UserColumn>[];
    for(int i = 0; i < 3; i++) {
      c.add(UserColumn('id$i', 'csvTitle$i', '$i'));
      final res = store.addOrUpdate(c[i]);
      expect(res, true);
    }

    expect(store.resolveColumns([c[0].internalIdentifier,
          c[1].internalIdentifier, c[2].internalIdentifier]),
      equals(c));
    expect(
      store.resolveColumns([c[2].internalIdentifier, c[1].internalIdentifier]),
      equals([c[2], c[1]]));
    expect(
        store.resolveColumns([c[2].internalIdentifier, c[1].internalIdentifier,
          c[2].internalIdentifier, c[2].internalIdentifier]),
        equals([c[2], c[1], c[2], c[2]]),
    );
  });
}

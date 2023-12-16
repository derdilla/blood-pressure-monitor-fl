
import 'package:blood_pressure_app/model/export_import/column.dart';
import 'package:blood_pressure_app/model/storage/export_columns_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExportColumnsManager', () {
    test('should allow adding columns', () async {
      final manager = ExportColumnsManager();
      final c1 = UserColumn('test', 'test', '\$SYS');
      final c2 = UserColumn('test2', 'test2', '234');
      manager.addOrUpdate(c1);
      manager.addOrUpdate(c2);
      manager.addOrUpdate(UserColumn('test', 'testx', ''));

      expect(manager.userColumns.length, 2);
      expect(manager.userColumns[c1.internalIdentifier]?.csvTitle, 'testx');
      expect(manager.userColumns[c2.internalIdentifier]?.csvTitle, 'test2');
    });

    test('should be restoreable from json', () async { // TODO: consider moving to json_serialization_test and adding crash tests
      final init = ExportColumnsManager();
      final c2 = UserColumn('test2', 'test2', '234');
      init.addOrUpdate(UserColumn('test', 'test', '\$SYS'));
      init.addOrUpdate(c2);

      final fromJson = ExportColumnsManager.fromJson(init.toJson());

      expect(fromJson.userColumns.length, init.userColumns.length);
      expect(fromJson.userColumns.keys, init.userColumns.keys);
      expect(fromJson.userColumns[c2.internalIdentifier]?.internalIdentifier,
          init.userColumns[c2.internalIdentifier]?.internalIdentifier);
      expect(fromJson.userColumns[c2.internalIdentifier]?.csvTitle,
          init.userColumns[c2.internalIdentifier]?.csvTitle);
      expect(fromJson.userColumns[c2.internalIdentifier]?.formatPattern,
          init.userColumns[c2.internalIdentifier]?.formatPattern);
      expect(fromJson.toJson(), init.toJson());
    });
  });
}
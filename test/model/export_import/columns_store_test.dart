
import 'package:blood_pressure_app/model/export_import/column.dart';
import 'package:blood_pressure_app/model/storage/export_columns_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExportColumnsManager', () {
    test('should allow adding columns', () async {
      final manager = ExportColumnsManager();
      manager.addOrUpdate(UserColumn('test', 'test', '\$SYS'));
      manager.addOrUpdate(UserColumn('test2', 'test2', '234'));
      manager.addOrUpdate(UserColumn('test', 'test', ''));

      expect(manager.userColumns.length, 2);
      expect(manager.userColumns['test']?.csvTitle, 'test');
      expect(manager.userColumns['test2']?.csvTitle, 'test2');
    });

    test('should be restoreable from json', () async { // TODO: consider moving to json_serialization_test and adding crash tests
      final init = ExportColumnsManager();
      init.addOrUpdate(UserColumn('test', 'test', '\$SYS'));
      init.addOrUpdate(UserColumn('test2', 'test2', '234'));

      final fromJson = ExportColumnsManager.fromJson(init.toJson());

      expect(fromJson.userColumns.length, init.userColumns.length);
      expect(fromJson.userColumns.keys, init.userColumns.keys);
      expect(fromJson.userColumns['test2']?.internalIdentifier, init.userColumns['test2']?.internalIdentifier);
      expect(fromJson.userColumns['test2']?.csvTitle, init.userColumns['test2']?.csvTitle);
      expect(fromJson.userColumns['test2']?.formatPattern, init.userColumns['test2']?.formatPattern);
      expect(fromJson.toJson(), init.toJson());
    });
  });
}
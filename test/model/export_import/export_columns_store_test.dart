
import 'package:blood_pressure_app/model/export_import/column.dart';
import 'package:blood_pressure_app/model/storage/export_columns_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExportColumnsManager', () {
    test('should get user column by id', () {
      final manager = ExportColumnsManager();
      final column = UserColumn('customColumn', '', '');
      manager.addOrUpdate(column);
      final returnedColumn = manager.getColumn(column.internalIdentifier);
      expect(returnedColumn, column);
    });
    test('should get NativeColumn by id', () {
      final manager = ExportColumnsManager();
      final column = NativeColumn.allColumns.first;
      final returnedColumn = manager.getColumn(column.internalIdentifier);
      expect(returnedColumn, column);
    });
    test('should get BuildInColumn by id', () {
      final manager = ExportColumnsManager();
      final column = BuildInColumn.allColumns.first;
      final returnedColumn = manager.getColumn(column.internalIdentifier);
      expect(returnedColumn, column);
    });
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

    test('should restore TimeColumns from configurations', () {
      final initialManager = ExportColumnsManager();
      initialManager.addOrUpdate(TimeColumn('testA', 'dd'));
      initialManager.addOrUpdate(TimeColumn('testB', 'mmm'));
      initialManager.addOrUpdate(TimeColumn('testC', 'asdsa'));

      expect(initialManager.userColumns.length, 3);
      expect(initialManager.userColumns.values, everyElement(isA<TimeColumn>()));

      final fromJson = ExportColumnsManager.fromJson(initialManager.toJson());
      expect(fromJson.userColumns.length, 3);
      expect(fromJson.userColumns.values, everyElement(isA<TimeColumn>()));
    });
  });
}

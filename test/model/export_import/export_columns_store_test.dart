
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
  });
}

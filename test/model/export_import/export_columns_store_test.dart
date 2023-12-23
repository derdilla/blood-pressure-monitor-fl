
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

    test('should delete columns', () {
      final manger = ExportColumnsManager();
      final c1 = UserColumn('test', 'test', '\$SYS');
      final c2 = TimeColumn('testA', 'dd');
      manger.addOrUpdate(c1);
      manger.addOrUpdate(c2);

      expect(manger.userColumns.length, 2);
      expect(() => manger.deleteUserColumn('none'), throwsAssertionError);
      expect(manger.userColumns.length, 2);

      manger.deleteUserColumn(c1.internalIdentifier);
      expect(manger.userColumns.length, 1);
      expect(() => manger.deleteUserColumn(c1.internalIdentifier), throwsAssertionError);
      expect(manger.userColumns.length, 1);

      manger.deleteUserColumn(c2.internalIdentifier);
      expect(manger.userColumns.length, 0);
    });

    test('should include all columns in firstWhere search', () {
      final manger = ExportColumnsManager();
      final c1 = UserColumn('test', 'test', '\$SYS');
      final c2 = TimeColumn('testA', 'dd');
      manger.addOrUpdate(c1);
      manger.addOrUpdate(c2);

      expect(manger.firstWhere((p0) => p0.internalIdentifier == c1.internalIdentifier), c1);
      expect(manger.firstWhere((p0) => p0.internalIdentifier == c2.internalIdentifier), c2);
      expect(manger.firstWhere((p0) => p0.csvTitle == c2.csvTitle), c2);
      expect(manger.firstWhere((p0) => p0.formatPattern == c1.formatPattern), c1);

      expect(manger.firstWhere((p0) => p0.csvTitle == NativeColumn.timestampUnixMs.csvTitle), NativeColumn.timestampUnixMs);
      expect(manger.firstWhere((p0) => p0.internalIdentifier == BuildInColumn.pulsePressure.internalIdentifier), BuildInColumn.pulsePressure);

      expect(manger.firstWhere((p0) => p0.internalIdentifier == 'non existent'), null);
    });

    test('should get all columns', () {
      final manager = ExportColumnsManager();

      expect(manager.getAllColumns().length, NativeColumn.allColumns.length + BuildInColumn.allColumns.length);

      manager.addOrUpdate(UserColumn('test', '', ''));
      expect(manager.getAllColumns().length, NativeColumn.allColumns.length + BuildInColumn.allColumns.length + 1);
    });

    test('should get only unmodifiable columns', () {
      final manager = ExportColumnsManager();

      expect(manager.getAllUnmodifiableColumns().length, NativeColumn.allColumns.length + BuildInColumn.allColumns.length);

      manager.addOrUpdate(UserColumn('test', '', ''));
      expect(manager.getAllUnmodifiableColumns().length, NativeColumn.allColumns.length + BuildInColumn.allColumns.length);
    });
  });
}

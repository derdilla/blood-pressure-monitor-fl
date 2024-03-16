
import 'package:blood_pressure_app/model/export_import/column.dart';
import 'package:blood_pressure_app/model/export_import/export_configuration.dart';
import 'package:blood_pressure_app/model/storage/export_columns_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('should not throw errors', () {
    ActiveExportColumnConfiguration();
    ActiveExportColumnConfiguration(activePreset: ExportImportPreset.myHeart);
    ActiveExportColumnConfiguration(activePreset: ExportImportPreset.none, userSelectedColumnIds: ['a','b','c']);
    ActiveExportColumnConfiguration(userSelectedColumnIds: ['a','b','c']);
  });

  test('should return correct columns depending on mode', () {
    final config = ActiveExportColumnConfiguration(
        activePreset: ExportImportPreset.bloodPressureApp,
        userSelectedColumnIds: ['userColumn.a', 'userColumn.b', 'userColumn.c'],
    );
    expect(config.getActiveColumns(ExportColumnsManager()), everyElement(isA<NativeColumn>()));

    config.activePreset = ExportImportPreset.myHeart;
    expect(config.getActiveColumns(ExportColumnsManager()), anyElement(isA<BuildInColumn>()));
    expect(config.getActiveColumns(ExportColumnsManager()), isNot(anyElement(isA<NativeColumn>())));

    config.activePreset = ExportImportPreset.none;
    final manager = ExportColumnsManager();
    manager.addOrUpdate(UserColumn('a', 'testA', ''));
    manager.addOrUpdate(UserColumn('b', 'testB', ''));
    manager.addOrUpdate(UserColumn('c', 'testC', ''));
    expect(config.getActiveColumns(manager).length, 3);
    expect(config.getActiveColumns(manager), everyElement(isA<UserColumn>()));
  });

  test('should notify listeners', () {
    final config = ActiveExportColumnConfiguration();
    int callCount = 0;
    config.addListener(() {
      callCount += 1;
    });
    config.activePreset = ExportImportPreset.bloodPressureApp;
    expect(callCount, 1);
  });
}

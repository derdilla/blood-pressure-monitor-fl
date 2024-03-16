import 'package:health_data_store/src/database_manager.dart';
import 'package:sqflite_common/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:test/test.dart';

void main() {
  group('DatabaseManager', () {
    setUpAll(() => databaseFactory = databaseFactoryFfi);
    test('should initialize without issues', () async {
      final db = await DatabaseManager.load(await openDatabase(
        inMemoryDatabasePath,
      ));
      expect(db.db.isOpen, isTrue);
    });
    test('should close', () async {
      final db = await DatabaseManager.load(await openDatabase(
        inMemoryDatabasePath,
      ));
      expect(db.db.isOpen, isTrue);
      await db.close();
      expect(db.db.isOpen, isFalse);
    });
    // TODO: test more
    throw UnimplementedError('TODO');
  });
}

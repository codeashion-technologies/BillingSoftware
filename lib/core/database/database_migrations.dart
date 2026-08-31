import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../constants/database_constants.dart';
import 'database_tables.dart';

abstract final class DatabaseMigrations {
  static Future<void> onCreate(Database database, int version) async {
    await database.execute(DatabaseTables.schemaMigrations);
    await database.insert(DatabaseConstants.schemaMigrationsTable, {
      'version': version,
      'applied_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> onUpgrade(
    Database database,
    int oldVersion,
    int newVersion,
  ) async {
    for (var version = oldVersion + 1; version <= newVersion; version++) {
      await database.insert(DatabaseConstants.schemaMigrationsTable, {
        'version': version,
        'applied_at': DateTime.now().toIso8601String(),
      });
    }
  }
}

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../constants/database_constants.dart';
import 'database_tables.dart';

abstract final class DatabaseMigrations {
  static Future<void> onCreate(Database database, int version) async {
    await database.execute(DatabaseTables.schemaMigrations);
    await database.execute(DatabaseTables.credentials);
    await _seedCredentials(database);
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
      if (version == 2) {
        await database.execute(DatabaseTables.credentials);
        await _seedCredentials(database);
      }
      await database.insert(DatabaseConstants.schemaMigrationsTable, {
        'version': version,
        'applied_at': DateTime.now().toIso8601String(),
      });
    }
  }

  static Future<void> _seedCredentials(Database database) async {
    await database.insert(DatabaseConstants.credentialsTable, {
      'user_id': '3723',
      'password': 'balkrishna',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }
}

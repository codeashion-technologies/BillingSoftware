import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../constants/database_constants.dart';
import 'database_tables.dart';

abstract final class DatabaseMigrations {
  static Future<void> onCreate(Database database, int version) async {
    await database.execute(DatabaseTables.schemaMigrations);
    await database.execute(DatabaseTables.credentials);
    await database.execute(DatabaseTables.firms);
    await _seedCredentials(database);
    await _seedFirm(database);
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
      if (version == 3) {
        await database.execute(DatabaseTables.firms);
        await _seedFirm(database);
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

  static Future<void> _seedFirm(Database database) async {
    await database.insert(DatabaseConstants.firmsTable, {
      'firm_code': '3723',
      'firm_name': 'SHREE BALKRISHNA FASHION',
      'financial_year': '2026-27',
      'area': 'SACHIN',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }
}

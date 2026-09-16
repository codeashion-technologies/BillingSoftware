import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../constants/database_constants.dart';
import 'database_tables.dart';

abstract final class DatabaseMigrations {
  static Future<void> onCreate(Database database, int version) async {
    await database.execute(DatabaseTables.schemaMigrations);
    await database.execute(DatabaseTables.credentials);
    await database.execute(DatabaseTables.firms);
    await database.execute(DatabaseTables.accounts);
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
      if (version == 4) {
        await database.execute(DatabaseTables.accounts);
      }
      if (version == 5) {
        await database.execute(
          'ALTER TABLE ${DatabaseConstants.accountsTable} ADD COLUMN firm_id INTEGER NOT NULL DEFAULT 0',
        );
        for (final column in [
          'gst_status TEXT NOT NULL DEFAULT \'\'',
          'taxpayer_legal_name TEXT NOT NULL DEFAULT \'\'',
          'constitution TEXT NOT NULL DEFAULT \'\'',
          'registration_date TEXT NOT NULL DEFAULT \'\'',
          'business_nature TEXT NOT NULL DEFAULT \'\'',
          'principal_building TEXT NOT NULL DEFAULT \'\'',
          'principal_floor TEXT NOT NULL DEFAULT \'\'',
          'principal_location TEXT NOT NULL DEFAULT \'\'',
          'principal_street TEXT NOT NULL DEFAULT \'\'',
          'district TEXT NOT NULL DEFAULT \'\'',
          'pincode TEXT NOT NULL DEFAULT \'\'',
          'latitude TEXT NOT NULL DEFAULT \'\'',
          'longitude TEXT NOT NULL DEFAULT \'\'',
          'trade_nature TEXT NOT NULL DEFAULT \'\'',
          'state_jurisdiction_code TEXT NOT NULL DEFAULT \'\'',
          'state_jurisdiction TEXT NOT NULL DEFAULT \'\'',
          'central_jurisdiction_code TEXT NOT NULL DEFAULT \'\'',
          'central_jurisdiction TEXT NOT NULL DEFAULT \'\'',
          'pan_no TEXT NOT NULL DEFAULT \'\'',
        ]) {
          await database.execute(
            'ALTER TABLE ${DatabaseConstants.accountsTable} ADD COLUMN $column',
          );
        }
      }
      if (version == 6) {
        await database.execute(DatabaseTables.items);
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

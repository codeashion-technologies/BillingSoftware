import '../constants/database_constants.dart';

abstract final class DatabaseTables {
  static const schemaMigrations =
      '''
    CREATE TABLE IF NOT EXISTS ${DatabaseConstants.schemaMigrationsTable} (
      version INTEGER PRIMARY KEY,
      applied_at TEXT NOT NULL
    )
  ''';

  static const credentials =
      '''
    CREATE TABLE IF NOT EXISTS ${DatabaseConstants.credentialsTable} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id TEXT NOT NULL UNIQUE,
      password TEXT NOT NULL
    )
  ''';

  static const firms =
      '''
    CREATE TABLE IF NOT EXISTS ${DatabaseConstants.firmsTable} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      firm_code TEXT NOT NULL UNIQUE,
      firm_name TEXT NOT NULL,
      financial_year TEXT NOT NULL,
      area TEXT NOT NULL DEFAULT ''
    )
  ''';
}

import '../constants/database_constants.dart';

abstract final class DatabaseTables {
  static const schemaMigrations =
      '''
    CREATE TABLE IF NOT EXISTS ${DatabaseConstants.schemaMigrationsTable} (
      version INTEGER PRIMARY KEY,
      applied_at TEXT NOT NULL
    )
  ''';
}

import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../constants/database_constants.dart';
import '../services/local_storage_service.dart';
import 'database_migrations.dart';

class DatabaseHelper {
  DatabaseHelper({LocalStorageService? storage})
    : _storage = storage ?? LocalStorageService();

  final LocalStorageService _storage;
  Database? _database;

  Future<Database> get database async => _database ??= await _open();

  Future<Database> _open() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    final directory = await _storage.databaseDirectory;
    return openDatabase(
      path.join(directory.path, DatabaseConstants.databaseName),
      version: DatabaseConstants.databaseVersion,
      onCreate: DatabaseMigrations.onCreate,
      onUpgrade: DatabaseMigrations.onUpgrade,
    );
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}

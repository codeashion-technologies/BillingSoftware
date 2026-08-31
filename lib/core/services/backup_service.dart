import 'dart:io';

import 'package:path/path.dart' as path;

import '../constants/database_constants.dart';
import 'local_storage_service.dart';

class BackupService {
  BackupService({LocalStorageService? storage})
    : _storage = storage ?? LocalStorageService();

  final LocalStorageService _storage;

  Future<File> copyDatabaseToBackup({DateTime? timestamp}) async {
    final databaseDirectory = await _storage.databaseDirectory;
    final source = File(
      path.join(databaseDirectory.path, DatabaseConstants.databaseName),
    );
    if (!await source.exists()) {
      throw StateError('The accounting database does not exist.');
    }
    final backupDirectory = await _storage.backupsDirectory;
    final suffix = (timestamp ?? DateTime.now()).toIso8601String().replaceAll(
      ':',
      '-',
    );
    return source.copy(
      path.join(backupDirectory.path, 'accounting_$suffix.db'),
    );
  }

  Future<bool> validateDatabaseBackup(File file) async {
    if (!await file.exists()) return false;
    try {
      final handle = await file.open();
      await handle.close();
      return true;
    } on FileSystemException {
      return false;
    }
  }
}

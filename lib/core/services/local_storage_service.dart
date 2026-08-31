import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../constants/storage_constants.dart';

class LocalStorageService {
  Directory? _root;

  Future<Directory> get rootDirectory async => _root ??= await _resolveRoot();

  Future<Directory> directory(String name) async {
    final directory = Directory(path.join((await rootDirectory).path, name));
    await directory.create(recursive: true);
    return directory;
  }

  Future<Directory> get databaseDirectory =>
      directory(StorageConstants.databaseDirectory);
  Future<Directory> get backupsDirectory =>
      directory(StorageConstants.backupsDirectory);
  Future<Directory> get invoicesDirectory =>
      directory(StorageConstants.invoicesDirectory);
  Future<Directory> get documentsDirectory =>
      directory(StorageConstants.documentsDirectory);
  Future<Directory> get exportsDirectory =>
      directory(StorageConstants.exportsDirectory);
  Future<Directory> get companyDirectory =>
      directory(StorageConstants.companyDirectory);

  Future<Directory> _resolveRoot() async {
    final appData = await getApplicationSupportDirectory();
    final root = Directory(
      path.join(appData.parent.path, StorageConstants.rootDirectoryName),
    );
    return root..createSync(recursive: true);
  }
}

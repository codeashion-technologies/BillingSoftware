import 'dart:io';

class FileService {
  Future<File> copy(File source, String destinationPath) =>
      source.copy(destinationPath);

  Future<bool> exists(String filePath) => File(filePath).exists();
}

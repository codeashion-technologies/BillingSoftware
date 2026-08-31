import 'database_helper.dart';

class DatabaseInitializer {
  const DatabaseInitializer._();

  static Future<void> initialize() async {
    final helper = DatabaseHelper();
    final database = await helper.database;
    await database.rawQuery('SELECT 1');
    await helper.close();
  }
}

import '../constants/database_constants.dart';
import '../database/database_helper.dart';

class AuthenticationService {
  AuthenticationService({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper();

  final DatabaseHelper _databaseHelper;

  Future<bool> verifyCredentials({
    required String userId,
    required String password,
  }) async {
    final database = await _databaseHelper.database;
    final matches = await database.query(
      DatabaseConstants.credentialsTable,
      columns: ['id'],
      where: 'user_id = ? AND password = ?',
      whereArgs: [userId.trim(), password],
      limit: 1,
    );
    await _databaseHelper.close();
    return matches.isNotEmpty;
  }

  Future<bool> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    final database = await _databaseHelper.database;
    final updated = await database.update(
      DatabaseConstants.credentialsTable,
      {'password': newPassword},
      where: 'user_id = ? AND password = ?',
      whereArgs: [userId.trim(), currentPassword],
    );
    await _databaseHelper.close();
    return updated > 0;
  }
}

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../constants/database_constants.dart';
import '../database/database_helper.dart';
import '../../shared/models/account.dart';

class AccountService {
  AccountService({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper();

  final DatabaseHelper _databaseHelper;

  Future<Account?> findByGst(String gstNo) async {
    final database = await _databaseHelper.database;
    final rows = await database.query(
      DatabaseConstants.accountsTable,
      where: 'gst_no = ?',
      whereArgs: [gstNo.trim().toUpperCase()],
      limit: 1,
    );
    await _databaseHelper.close();
    return rows.isEmpty ? null : Account.fromMap(rows.first);
  }

  Future<void> save(Account account) async {
    final database = await _databaseHelper.database;
    await database.insert(
      DatabaseConstants.accountsTable,
      account.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await _databaseHelper.close();
  }

  Future<void> deleteByGst(String gstNo) async {
    final database = await _databaseHelper.database;
    await database.delete(
      DatabaseConstants.accountsTable,
      where: 'gst_no = ?',
      whereArgs: [gstNo.trim().toUpperCase()],
    );
    await _databaseHelper.close();
  }
}

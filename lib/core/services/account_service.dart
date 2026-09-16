import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../constants/database_constants.dart';
import '../database/database_helper.dart';
import '../../shared/models/account.dart';

class AccountService {
  AccountService({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper();

  final DatabaseHelper _databaseHelper;

  Future<Account?> findByGst(String gstNo, {int firmId = 0}) async {
    final database = await _databaseHelper.database;
    firmId = await _resolveFirmId(database, firmId);
    final rows = await database.query(
      DatabaseConstants.accountsTable,
      where: 'gst_no = ? AND firm_id = ?',
      whereArgs: [gstNo.trim().toUpperCase(), firmId],
      limit: 1,
    );
    await _databaseHelper.close();
    return rows.isEmpty ? null : Account.fromMap(rows.first);
  }

  Future<void> save(Account account) async {
    final database = await _databaseHelper.database;
    var firmId = account.firmId;
    if (firmId == 0) {
      final firmRows = await database.query(
        DatabaseConstants.firmsTable,
        columns: ['id'],
        where: 'firm_code = ?',
        whereArgs: ['3723'],
        limit: 1,
      );
      if (firmRows.isNotEmpty) firmId = firmRows.first['id'] as int;
    }
    await database.insert(DatabaseConstants.accountsTable, {
      ...account.toMap(),
      'firm_id': firmId,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    await _databaseHelper.close();
  }

  Future<void> deleteByGst(String gstNo, {int firmId = 0}) async {
    final database = await _databaseHelper.database;
    firmId = await _resolveFirmId(database, firmId);
    await database.delete(
      DatabaseConstants.accountsTable,
      where: 'gst_no = ? AND firm_id = ?',
      whereArgs: [gstNo.trim().toUpperCase(), firmId],
    );
    await _databaseHelper.close();
  }

  Future<int> _resolveFirmId(Database database, int firmId) async {
    if (firmId != 0) return firmId;
    final rows = await database.query(
      DatabaseConstants.firmsTable,
      columns: ['id'],
      where: 'firm_code = ?',
      whereArgs: ['3723'],
      limit: 1,
    );
    return rows.isEmpty ? 0 : rows.first['id'] as int;
  }
}

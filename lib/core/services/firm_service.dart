import '../constants/database_constants.dart';
import '../database/database_helper.dart';
import '../../shared/models/firm.dart';

class FirmService {
  FirmService({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper();

  final DatabaseHelper _databaseHelper;

  Future<List<Firm>> getFirms() async {
    final database = await _databaseHelper.database;
    final rows = await database.query(
      DatabaseConstants.firmsTable,
      orderBy: 'firm_name COLLATE NOCASE',
    );
    await _databaseHelper.close();
    return rows.map(Firm.fromMap).toList();
  }

  Future<Firm> createFirm({
    required String code,
    required String name,
    required String financialYear,
    required String area,
    required String password,
  }) async {
    final database = await _databaseHelper.database;
    final firmId = await database.insert(DatabaseConstants.firmsTable, {
      'firm_code': code.trim(),
      'firm_name': name.trim(),
      'financial_year': financialYear.trim(),
      'area': area.trim(),
    });
    await database.insert(DatabaseConstants.credentialsTable, {
      'user_id': code.trim(),
      'password': password,
    });
    final row = await database.query(
      DatabaseConstants.firmsTable,
      where: 'id = ?',
      whereArgs: [firmId],
      limit: 1,
    );
    await _databaseHelper.close();
    return Firm.fromMap(row.single);
  }

  Future<void> updateFirm({
    required int id,
    required String name,
    required String financialYear,
    required String area,
  }) async {
    final database = await _databaseHelper.database;
    await database.update(
      DatabaseConstants.firmsTable,
      {
        'firm_name': name.trim(),
        'financial_year': financialYear.trim(),
        'area': area.trim(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
    await _databaseHelper.close();
  }
}

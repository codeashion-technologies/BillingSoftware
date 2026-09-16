import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../constants/database_constants.dart';
import '../database/database_helper.dart';
import '../../shared/models/item.dart';

class ItemService {
  ItemService({DatabaseHelper? databaseHelper})
    : _helper = databaseHelper ?? DatabaseHelper();
  final DatabaseHelper _helper;

  Future<List<Item>> getAll({required int firmId}) async {
    final database = await _helper.database;
    final rows = await database.query(
      DatabaseConstants.itemsTable,
      where: 'firm_id = ?',
      whereArgs: [firmId],
      orderBy: 'item_name COLLATE NOCASE',
    );
    await _helper.close();
    return rows.map(Item.fromMap).toList();
  }

  Future<void> save(Item item) async {
    final database = await _helper.database;
    await database.insert(
      DatabaseConstants.itemsTable,
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await _helper.close();
  }

  Future<void> deleteById(int id) async {
    final database = await _helper.database;
    await database.delete(
      DatabaseConstants.itemsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    await _helper.close();
  }
}

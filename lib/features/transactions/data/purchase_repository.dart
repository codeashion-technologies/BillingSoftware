import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../core/database/database_helper.dart';

class PurchaseRepository {
  PurchaseRepository({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper();

  final DatabaseHelper _databaseHelper;

  Future<void> savePurchase({
    required Map<String, Object?> header,
    required List<Map<String, Object?>> lines,
  }) async {
    final database = await _databaseHelper.database;
    await database.transaction((txn) async {
      await _createTables(txn);
      final purchaseId = await txn.insert('purchase_headers', header);
      for (final line in lines) {
        await txn.insert('purchase_details', {
          ...line,
          'purchase_id': purchaseId,
        });
        await txn.insert('stock_ledger', {
          'purchase_id': purchaseId,
          'product_name': line['product_name'],
          'quantity': line['quantity'],
          'rate': line['rate'],
          'created_at': DateTime.now().toIso8601String(),
        });
      }
      await txn.insert('party_ledger', {
        'purchase_id': purchaseId,
        'party': header['party'],
        'debit': header['bill_amount'],
        'created_at': DateTime.now().toIso8601String(),
      });
    });
  }

  Future<void> _createTables(Transaction txn) async {
    await txn.execute('''
      CREATE TABLE IF NOT EXISTS purchase_headers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        voucher_no TEXT NOT NULL,
        bill_no TEXT,
        bill_date TEXT NOT NULL,
        book TEXT NOT NULL,
        party TEXT NOT NULL,
        invoice_type TEXT NOT NULL,
        broker TEXT,
        transport TEXT,
        description TEXT,
        goods_type TEXT,
        eway_bill_no TEXT,
        other_adjustment REAL NOT NULL DEFAULT 0,
        bill_amount REAL NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
    await txn.execute('''
      CREATE TABLE IF NOT EXISTS purchase_details (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        purchase_id INTEGER NOT NULL,
        sr_no INTEGER NOT NULL,
        product_name TEXT NOT NULL,
        quantity REAL NOT NULL,
        pm TEXT NOT NULL,
        rate REAL NOT NULL,
        amount REAL NOT NULL,
        discount_percent REAL NOT NULL,
        discount_amount REAL NOT NULL,
        sgst_rate REAL NOT NULL,
        cgst_rate REAL NOT NULL,
        sgst_amount REAL NOT NULL,
        cgst_amount REAL NOT NULL,
        total_amount REAL NOT NULL,
        freight REAL NOT NULL DEFAULT 0
      )
    ''');
    await txn.execute('''
      CREATE TABLE IF NOT EXISTS stock_ledger (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        purchase_id INTEGER NOT NULL,
        product_name TEXT NOT NULL,
        quantity REAL NOT NULL,
        rate REAL NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
    await txn.execute('''
      CREATE TABLE IF NOT EXISTS party_ledger (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        purchase_id INTEGER NOT NULL,
        party TEXT NOT NULL,
        debit REAL NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }
}

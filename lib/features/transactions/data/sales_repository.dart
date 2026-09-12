import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../core/database/database_helper.dart';

class SalesRepository {
  SalesRepository({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper();

  final DatabaseHelper _databaseHelper;

  Future<void> saveSale({
    required Map<String, Object?> header,
    required List<Map<String, Object?>> lines,
  }) async {
    final database = await _databaseHelper.database;
    await database.transaction((txn) async {
      await _createTables(txn);
      final saleId = await txn.insert('sales_headers', header);
      for (final line in lines) {
        await txn.insert('sales_details', {...line, 'sale_id': saleId});
        if ((line['is_no_stock'] as int? ?? 0) == 0) {
          await txn.insert('sales_stock_ledger', {
            'sale_id': saleId,
            'product_name': line['product_name'],
            'quantity':
                -((line['meters'] as num?) ?? (line['pcs'] as num?) ?? 0),
            'rate': line['rate'],
            'created_at': DateTime.now().toIso8601String(),
          });
        }
      }
      await txn.insert('sales_party_ledger', {
        'sale_id': saleId,
        'party': header['party'],
        'credit': header['bill_amount'],
        'created_at': DateTime.now().toIso8601String(),
      });
    });
  }

  Future<void> _createTables(Transaction txn) async {
    await txn.execute('''
      CREATE TABLE IF NOT EXISTS sales_headers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        voucher_no TEXT NOT NULL, bill_no TEXT NOT NULL, bill_date TEXT NOT NULL,
        book TEXT NOT NULL, party TEXT NOT NULL, invoice_type TEXT NOT NULL,
        bill_book TEXT, broker TEXT, challan_date TEXT, destination TEXT,
        credit_days INTEGER NOT NULL DEFAULT 0, challan_id TEXT, description TEXT,
        delivery TEXT, eway_bill_no TEXT, print_type TEXT, other_adjustment REAL NOT NULL DEFAULT 0,
        bill_amount REAL NOT NULL, created_at TEXT NOT NULL
      )
    ''');
    await txn.execute('''
      CREATE TABLE IF NOT EXISTS sales_details (
        id INTEGER PRIMARY KEY AUTOINCREMENT, sale_id INTEGER NOT NULL,
        sr_no INTEGER NOT NULL, product_name TEXT NOT NULL, description TEXT,
        pcs REAL NOT NULL DEFAULT 0, cut REAL NOT NULL DEFAULT 0, meters REAL NOT NULL DEFAULT 0,
        pm TEXT NOT NULL, rate REAL NOT NULL, amount REAL NOT NULL, s_rate REAL NOT NULL,
        sgst_rate REAL NOT NULL, cgst_rate REAL NOT NULL, sgst_amount REAL NOT NULL,
        cgst_amount REAL NOT NULL, net_amount REAL NOT NULL, cdp REAL NOT NULL DEFAULT 0,
        cdrs REAL NOT NULL DEFAULT 0, cdp1 REAL NOT NULL DEFAULT 0, cdrs1 REAL NOT NULL DEFAULT 0,
        r1 REAL NOT NULL DEFAULT 0, r2 REAL NOT NULL DEFAULT 0, vat_calc TEXT NOT NULL,
        is_no_stock INTEGER NOT NULL DEFAULT 0, chalan_id TEXT, ch_date TEXT, ch_no TEXT,
        l_less REAL NOT NULL DEFAULT 0, ch_book TEXT, party_no TEXT, receive_lot_no TEXT,
        greay_mtrs REAL NOT NULL DEFAULT 0, hsn_code TEXT, unit TEXT
      )
    ''');
    await txn.execute('''
      CREATE TABLE IF NOT EXISTS sales_party_ledger (
        id INTEGER PRIMARY KEY AUTOINCREMENT, sale_id INTEGER NOT NULL,
        party TEXT NOT NULL, credit REAL NOT NULL, created_at TEXT NOT NULL
      )
    ''');
    await txn.execute('''
      CREATE TABLE IF NOT EXISTS sales_stock_ledger (
        id INTEGER PRIMARY KEY AUTOINCREMENT, sale_id INTEGER NOT NULL,
        product_name TEXT NOT NULL, quantity REAL NOT NULL, rate REAL NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }
}

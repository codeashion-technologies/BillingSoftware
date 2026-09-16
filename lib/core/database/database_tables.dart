import '../constants/database_constants.dart';

abstract final class DatabaseTables {
  static const schemaMigrations =
      '''
    CREATE TABLE IF NOT EXISTS ${DatabaseConstants.schemaMigrationsTable} (
      version INTEGER PRIMARY KEY,
      applied_at TEXT NOT NULL
    )
  ''';

  static const credentials =
      '''
    CREATE TABLE IF NOT EXISTS ${DatabaseConstants.credentialsTable} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id TEXT NOT NULL UNIQUE,
      password TEXT NOT NULL
    )
  ''';

  static const firms =
      '''
    CREATE TABLE IF NOT EXISTS ${DatabaseConstants.firmsTable} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      firm_code TEXT NOT NULL UNIQUE,
      firm_name TEXT NOT NULL,
      financial_year TEXT NOT NULL,
      area TEXT NOT NULL DEFAULT ''
    )
  ''';

  static const accounts =
      '''
    CREATE TABLE IF NOT EXISTS ${DatabaseConstants.accountsTable} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      firm_id INTEGER NOT NULL DEFAULT 0,
      name TEXT NOT NULL,
      group_name TEXT NOT NULL DEFAULT '',
      address1 TEXT NOT NULL DEFAULT '',
      address2 TEXT NOT NULL DEFAULT '',
      delivery_address1 TEXT NOT NULL DEFAULT '',
      city TEXT NOT NULL DEFAULT '',
      phone TEXT NOT NULL DEFAULT '',
      state TEXT NOT NULL DEFAULT '',
      gst_no TEXT NOT NULL,
      gst_status TEXT NOT NULL DEFAULT '',
      taxpayer_legal_name TEXT NOT NULL DEFAULT '',
      constitution TEXT NOT NULL DEFAULT '',
      registration_date TEXT NOT NULL DEFAULT '',
      business_nature TEXT NOT NULL DEFAULT '',
      principal_building TEXT NOT NULL DEFAULT '',
      principal_floor TEXT NOT NULL DEFAULT '',
      principal_location TEXT NOT NULL DEFAULT '',
      principal_street TEXT NOT NULL DEFAULT '',
      district TEXT NOT NULL DEFAULT '',
      pincode TEXT NOT NULL DEFAULT '',
      latitude TEXT NOT NULL DEFAULT '',
      longitude TEXT NOT NULL DEFAULT '',
      trade_nature TEXT NOT NULL DEFAULT '',
      state_jurisdiction_code TEXT NOT NULL DEFAULT '',
      state_jurisdiction TEXT NOT NULL DEFAULT '',
      central_jurisdiction_code TEXT NOT NULL DEFAULT '',
      central_jurisdiction TEXT NOT NULL DEFAULT '',
      pan_no TEXT NOT NULL DEFAULT '',
      UNIQUE(firm_id, gst_no)
    )
  ''';

  static const items =
      '''
    CREATE TABLE IF NOT EXISTS ${DatabaseConstants.itemsTable} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      firm_id INTEGER NOT NULL DEFAULT 0,
      item_code TEXT NOT NULL,
      item_name TEXT NOT NULL,
      item_group TEXT NOT NULL DEFAULT '',
      sub_group TEXT NOT NULL DEFAULT '',
      mfg_by TEXT NOT NULL DEFAULT '',
      unit_of_measure TEXT NOT NULL DEFAULT 'PCS',
      rate_retail TEXT NOT NULL DEFAULT '',
      dealer_rate TEXT NOT NULL DEFAULT '',
      purchase_rate TEXT NOT NULL DEFAULT '',
      mrp TEXT NOT NULL DEFAULT '',
      cut_average TEXT NOT NULL DEFAULT '',
      box_pack TEXT NOT NULL DEFAULT '',
      loose_quantity TEXT NOT NULL DEFAULT '',
      hsn_code TEXT NOT NULL DEFAULT '',
      sgst TEXT NOT NULL DEFAULT '',
      cgst TEXT NOT NULL DEFAULT '',
      igst TEXT NOT NULL DEFAULT '',
      gst_calculation TEXT NOT NULL DEFAULT 'Taxable',
      hsn_description TEXT NOT NULL DEFAULT '',
      hsn_uqc TEXT NOT NULL DEFAULT '',
      rol_min TEXT NOT NULL DEFAULT '',
      rol_max TEXT NOT NULL DEFAULT '',
      opening_stock_quantity TEXT NOT NULL DEFAULT '',
      opening_stock_amount TEXT NOT NULL DEFAULT '',
      opening_stock_nos TEXT NOT NULL DEFAULT '',
      calculate_on TEXT NOT NULL DEFAULT 'Mtrs',
      rate_update TEXT NOT NULL DEFAULT 'Y',
      show_in_stock_report TEXT NOT NULL DEFAULT 'Y',
      active TEXT NOT NULL DEFAULT 'Y',
      discount TEXT NOT NULL DEFAULT '',
      remarks TEXT NOT NULL DEFAULT '',
      UNIQUE(firm_id, item_code)
    )
  ''';
}

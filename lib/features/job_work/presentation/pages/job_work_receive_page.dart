import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:sqflite_common_ffi/sqflite_common_ffi.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/database_constants.dart';
import '../../../../core/database/database_helper.dart';

class JobWorkReceivePage extends StatefulWidget {
  const JobWorkReceivePage({super.key});

  @override
  State<JobWorkReceivePage> createState() => _JobWorkReceivePageState();
}

class _JobWorkReceivePageState extends State<JobWorkReceivePage> {
  final _lotDateController = TextEditingController();
  final _purBillDateController = TextEditingController();
  final _metersController = TextEditingController();
  final _weightController = TextEditingController();
  final _markaController = TextEditingController();
  final _remarksController = TextEditingController();
  final _bookController = TextEditingController();
  final _lotNoController = TextEditingController();
  final _jobProcessController = TextEditingController();
  final _partyController = TextEditingController();
  final _purchasePartyController = TextEditingController();
  final _brokerController = TextEditingController();
  final _partyChallanController = TextEditingController();
  final _purchaseBillNoController = TextEditingController();
  final _jobRateController = TextEditingController();
  final _grayRateController = TextEditingController();
  final _jobWorkNoController = TextEditingController();
  final _qualityController = TextEditingController();
  final _bottomRemarksController = TextEditingController();
  final _lrNoController = TextEditingController();
  final _tampoNoController = TextEditingController();
  final _transportController = TextEditingController();
  final _weightFocusNode = FocusNode();
  final _markaFocusNode = FocusNode();
  final _remarksFocusNode = FocusNode();
  final _detailsFocusNode = FocusNode();

  final List<_ReceiveDetail> _details = [];
  DateTime _lotDate = DateTime.now();
  DateTime _purBillDate = DateTime.now();
  int? _selectedRow;
  bool _onlyPending = false;
  bool _jobCard = false;
  bool _special = false;
  String? _message;
  final _databaseHelper = DatabaseHelper();

  double get _totalMeters => _details.fold(0, (sum, row) => sum + row.meters);
  double get _totalWeight => _details.fold(0, (sum, row) => sum + row.weight);

  @override
  void initState() {
    super.initState();
    _setDate(_lotDateController, _lotDate);
    _setDate(_purBillDateController, _purBillDate);
  }

  @override
  void dispose() {
    _lotDateController.dispose();
    _purBillDateController.dispose();
    _metersController.dispose();
    _weightController.dispose();
    _markaController.dispose();
    _remarksController.dispose();
    for (final controller in [
      _bookController,
      _lotNoController,
      _jobProcessController,
      _partyController,
      _purchasePartyController,
      _brokerController,
      _partyChallanController,
      _purchaseBillNoController,
      _jobRateController,
      _grayRateController,
      _jobWorkNoController,
      _qualityController,
      _bottomRemarksController,
      _lrNoController,
      _tampoNoController,
      _transportController,
    ]) {
      controller.dispose();
    }
    _weightFocusNode.dispose();
    _markaFocusNode.dispose();
    _remarksFocusNode.dispose();
    _detailsFocusNode.dispose();
    super.dispose();
  }

  void _setDate(TextEditingController controller, DateTime date) {
    controller.text =
        '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  Future<void> _pickDate({required bool lotDate}) async {
    final current = lotDate ? _lotDate : _purBillDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (lotDate) {
        _lotDate = picked;
        _setDate(_lotDateController, picked);
      } else {
        _purBillDate = picked;
        _setDate(_purBillDateController, picked);
      }
    });
  }

  void _addDetail() {
    final meters = double.tryParse(_metersController.text.trim());
    final weightText = _weightController.text.trim();
    final weight = weightText.isEmpty ? 0.0 : double.tryParse(weightText);
    final marka = _markaController.text.trim();
    final remarks = _remarksController.text.trim();
    if (meters == null) {
      setState(() => _message = 'Enter a valid meter value');
      _detailsFocusNode.requestFocus();
      return;
    }
    if (weight == null) {
      setState(() => _message = 'Enter a valid weight value');
      _weightFocusNode.requestFocus();
      return;
    }
    setState(() {
      _details.add(
        _ReceiveDetail(
          serialNo: _details.length + 1,
          meters: meters,
          weight: weight,
          marka: marka,
          remarks: remarks,
        ),
      );
      _metersController.clear();
      _weightController.clear();
      _markaController.clear();
      _remarksController.clear();
      _selectedRow = null;
      _message = 'Detail added';
    });
    _detailsFocusNode.requestFocus();
  }

  void _newTransaction() {
    for (final controller in [
      _bookController,
      _lotNoController,
      _jobProcessController,
      _partyController,
      _purchasePartyController,
      _brokerController,
      _partyChallanController,
      _purchaseBillNoController,
      _jobRateController,
      _grayRateController,
      _jobWorkNoController,
      _qualityController,
      _bottomRemarksController,
      _lrNoController,
      _tampoNoController,
      _transportController,
      _metersController,
      _weightController,
      _markaController,
      _remarksController,
    ]) {
      controller.clear();
    }
    setState(() {
      _details.clear();
      _selectedRow = null;
      _onlyPending = false;
      _jobCard = false;
      _special = false;
      _message = 'New transaction';
    });
    _detailsFocusNode.requestFocus();
  }

  void _showMessage(String message) => setState(() => _message = message);

  Future<void> _save() async {
    final lotNo = _lotNoController.text.trim();
    if (lotNo.isEmpty) return _showMessage('Lot No is required');
    if (_details.isEmpty) return _showMessage('Add at least one detail row');
    try {
      final database = await _databaseHelper.database;
      await database.transaction((txn) async {
        await _createTables(txn);
        final header = _headerValues(lotNo);
        final existing = await txn.query(
          DatabaseConstants.jobWorkReceiveHeadersTable,
          where: 'lot_no = ?',
          whereArgs: [lotNo],
          limit: 1,
        );
        int headerId;
        if (existing.isEmpty) {
          headerId = await txn.insert(
            DatabaseConstants.jobWorkReceiveHeadersTable,
            header,
          );
        } else {
          headerId = existing.first['id']! as int;
          await txn.update(
            DatabaseConstants.jobWorkReceiveHeadersTable,
            header,
            where: 'lot_no = ?',
            whereArgs: [lotNo],
          );
        }
        await txn.delete(
          DatabaseConstants.jobWorkReceiveDetailsTable,
          where: 'receive_id = ?',
          whereArgs: [headerId],
        );
        for (final row in _details) {
          await txn.insert(DatabaseConstants.jobWorkReceiveDetailsTable, {
            'receive_id': headerId,
            'sr_no': row.serialNo,
            'meters': row.meters,
            'weight': row.weight,
            'marka': row.marka,
            'remarks': row.remarks,
            'is_finished': row.isFinished ? 1 : 0,
          });
        }
      });
      _showMessage('Bill saved for Lot No $lotNo');
    } on DatabaseException catch (error) {
      _showMessage('Could not save bill: $error');
    }
  }

  Map<String, Object?> _headerValues(String lotNo) => {
    'lot_no': lotNo,
    'book': _bookController.text.trim(),
    'lot_date': _lotDate.toIso8601String(),
    'job_process': _jobProcessController.text.trim(),
    'party': _partyController.text.trim(),
    'purchase_party': _purchasePartyController.text.trim(),
    'broker': _brokerController.text.trim(),
    'party_challan_no': _partyChallanController.text.trim(),
    'purchase_bill_no': _purchaseBillNoController.text.trim(),
    'purchase_bill_date': _purBillDate.toIso8601String(),
    'job_rate': double.tryParse(_jobRateController.text) ?? 0,
    'gray_rate': double.tryParse(_grayRateController.text) ?? 0,
    'job_work_no': _jobWorkNoController.text.trim(),
    'quality': _qualityController.text.trim(),
    'remarks': _bottomRemarksController.text.trim(),
    'lr_no': _lrNoController.text.trim(),
    'tampo_no': _tampoNoController.text.trim(),
    'transport': _transportController.text.trim(),
    'only_pending': _onlyPending ? 1 : 0,
    'job_card': _jobCard ? 1 : 0,
    'special': _special ? 1 : 0,
    'total_meters': _totalMeters,
    'total_weight': _totalWeight,
    'created_at': DateTime.now().toIso8601String(),
  };

  Future<void> _find() async {
    final lotNo = _lotNoController.text.trim();
    if (lotNo.isEmpty) return _showMessage('Enter Lot No to find');
    final database = await _databaseHelper.database;
    await _createTables(database);
    final rows = await database.query(
      DatabaseConstants.jobWorkReceiveHeadersTable,
      where: 'lot_no = ?',
      whereArgs: [lotNo],
      limit: 1,
    );
    if (rows.isEmpty) return _showMessage('Lot No $lotNo not found');
    final header = rows.first;
    final details = await database.query(
      DatabaseConstants.jobWorkReceiveDetailsTable,
      where: 'receive_id = ?',
      whereArgs: [header['id']],
      orderBy: 'sr_no',
    );
    void setText(TextEditingController controller, Object? value) {
      controller.text = value?.toString() ?? '';
    }

    setText(_bookController, header['book']);
    setText(_jobProcessController, header['job_process']);
    setText(_partyController, header['party']);
    setText(_purchasePartyController, header['purchase_party']);
    setText(_brokerController, header['broker']);
    setText(_partyChallanController, header['party_challan_no']);
    setText(_purchaseBillNoController, header['purchase_bill_no']);
    setText(_jobRateController, header['job_rate']);
    setText(_grayRateController, header['gray_rate']);
    setText(_jobWorkNoController, header['job_work_no']);
    setText(_qualityController, header['quality']);
    setText(_bottomRemarksController, header['remarks']);
    setText(_lrNoController, header['lr_no']);
    setText(_tampoNoController, header['tampo_no']);
    setText(_transportController, header['transport']);
    setState(() {
      _details
        ..clear()
        ..addAll(
          details.map(
            (row) => _ReceiveDetail(
              serialNo: row['sr_no']! as int,
              meters: (row['meters']! as num).toDouble(),
              weight: (row['weight']! as num).toDouble(),
              marka: row['marka']! as String,
              remarks: row['remarks']! as String,
              isFinished: row['is_finished'] == 1,
            ),
          ),
        );
      _message = 'Bill loaded for Lot No $lotNo';
    });
  }

  Future<void> _deleteBill() async {
    final lotNo = _lotNoController.text.trim();
    if (lotNo.isEmpty) return _showMessage('Enter Lot No to delete');
    final database = await _databaseHelper.database;
    await _createTables(database);
    final headers = await database.query(
      DatabaseConstants.jobWorkReceiveHeadersTable,
      columns: ['id'],
      where: 'lot_no = ?',
      whereArgs: [lotNo],
      limit: 1,
    );
    if (headers.isEmpty) return _showMessage('Lot No $lotNo not found');
    final headerId = headers.first['id'];
    await database.delete(
      DatabaseConstants.jobWorkReceiveDetailsTable,
      where: 'receive_id = ?',
      whereArgs: [headerId],
    );
    final deleted = await database.delete(
      DatabaseConstants.jobWorkReceiveHeadersTable,
      where: 'lot_no = ?',
      whereArgs: [lotNo],
    );
    if (deleted == 0) return _showMessage('Lot No $lotNo not found');
    _newTransaction();
    _showMessage('Bill deleted for Lot No $lotNo');
  }

  Future<void> _printBill() async {
    final lotNo = _lotNoController.text.trim();
    if (lotNo.isEmpty) return _showMessage('Enter Lot No to print');
    final database = await _databaseHelper.database;
    await _createTables(database);
    final headers = await database.query(
      DatabaseConstants.jobWorkReceiveHeadersTable,
      where: 'lot_no = ?',
      whereArgs: [lotNo],
      limit: 1,
    );
    if (headers.isEmpty) return _showMessage('Lot No $lotNo not found');
    final header = headers.first;
    final lines = await database.query(
      DatabaseConstants.jobWorkReceiveDetailsTable,
      where: 'receive_id = ?',
      whereArgs: [header['id']],
      orderBy: 'sr_no',
    );
    final document = pw.Document();
    document.addPage(
      pw.Page(
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'JOB WORK RECEIVE TO MILL',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              'Lot No: $lotNo    Party: ${header['party']}    Quality: ${header['quality']}',
            ),
            pw.Text(
              'Party Challan No: ${header['party_challan_no']}    Job Work No: ${header['job_work_no']}',
            ),
            pw.SizedBox(height: 12),
            pw.TableHelper.fromTextArray(
              headers: const ['Sr No', 'Meters', 'Weight', 'Marka', 'Remarks'],
              data: lines
                  .map(
                    (row) => [
                      row['sr_no'],
                      row['meters'],
                      row['weight'],
                      row['marka'],
                      row['remarks'],
                    ],
                  )
                  .toList(),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              'Total Meters: ${header['total_meters']}    Total Weight: ${header['total_weight']}',
            ),
          ],
        ),
      ),
    );
    await Printing.layoutPdf(onLayout: (_) async => document.save());
  }

  Future<void> _createTables(DatabaseExecutor database) async {
    await database.execute(
      'CREATE TABLE IF NOT EXISTS ${DatabaseConstants.jobWorkReceiveHeadersTable} (id INTEGER PRIMARY KEY AUTOINCREMENT, lot_no TEXT NOT NULL UNIQUE, book TEXT NOT NULL DEFAULT \'\', lot_date TEXT NOT NULL, job_process TEXT NOT NULL DEFAULT \'\', party TEXT NOT NULL DEFAULT \'\', purchase_party TEXT NOT NULL DEFAULT \'\', broker TEXT NOT NULL DEFAULT \'\', party_challan_no TEXT NOT NULL DEFAULT \'\', purchase_bill_no TEXT NOT NULL DEFAULT \'\', purchase_bill_date TEXT NOT NULL, job_rate REAL NOT NULL DEFAULT 0, gray_rate REAL NOT NULL DEFAULT 0, job_work_no TEXT NOT NULL DEFAULT \'\', quality TEXT NOT NULL DEFAULT \'\', remarks TEXT NOT NULL DEFAULT \'\', lr_no TEXT NOT NULL DEFAULT \'\', tampo_no TEXT NOT NULL DEFAULT \'\', transport TEXT NOT NULL DEFAULT \'\', only_pending INTEGER NOT NULL DEFAULT 0, job_card INTEGER NOT NULL DEFAULT 0, special INTEGER NOT NULL DEFAULT 0, total_meters REAL NOT NULL DEFAULT 0, total_weight REAL NOT NULL DEFAULT 0, created_at TEXT NOT NULL)',
    );
    await database.execute(
      'CREATE TABLE IF NOT EXISTS ${DatabaseConstants.jobWorkReceiveDetailsTable} (id INTEGER PRIMARY KEY AUTOINCREMENT, receive_id INTEGER NOT NULL, sr_no INTEGER NOT NULL, meters REAL NOT NULL, weight REAL NOT NULL DEFAULT 0, marka TEXT NOT NULL DEFAULT \'\', remarks TEXT NOT NULL DEFAULT \'\', is_finished INTEGER NOT NULL DEFAULT 0)',
    );
  }

  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.background,
    padding: const EdgeInsets.all(6),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _titleBar(),
        const SizedBox(height: 4),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.formBackground,
              border: Border.all(color: AppColors.border),
            ),
            padding: const EdgeInsets.all(6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _section('RECEIVE HEADER / DETAILS'),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 10,
                  runSpacing: 3,
                  children: [
                    _headerField('Book', 225, _bookController),
                    _headerField('Lot No', 170, _lotNoController),
                    _headerDateField(
                      'Lot Date',
                      _lotDateController,
                      () => _pickDate(lotDate: true),
                      175,
                    ),
                    _headerField('Job Process', 220, _jobProcessController),
                    _headerField('Party', 190, _partyController),
                    _headerField(
                      'Purchase Party',
                      225,
                      _purchasePartyController,
                    ),
                    _headerField('Broker', 220, _brokerController),
                    _headerField('Party Ch. No', 170, _partyChallanController),
                    _headerField('Pur Bill No', 175, _purchaseBillNoController),
                    _headerDateField(
                      'Pur Bill Date',
                      _purBillDateController,
                      () => _pickDate(lotDate: false),
                      175,
                    ),
                    _headerField('Job Rate', 145, _jobRateController),
                    _headerField('Gray Rate', 145, _grayRateController),
                    _headerField('JobWork No', 165, _jobWorkNoController),
                    _headerField('Quality', 205, _qualityController),
                  ],
                ),
                const SizedBox(height: 5),
                _section('DETAIL ENTRY'),
                const SizedBox(height: 4),
                _fieldRow([
                  _readOnlyNumber('Sr No', (_details.length + 1).toString()),
                  _entryField(
                    'Meters',
                    _metersController,
                    focusNode: _detailsFocusNode,
                    onSubmitted: (_) => _weightFocusNode.requestFocus(),
                  ),
                  _entryField(
                    'Weight',
                    _weightController,
                    focusNode: _weightFocusNode,
                    onSubmitted: (_) => _markaFocusNode.requestFocus(),
                  ),
                  _entryField(
                    'Marka',
                    _markaController,
                    focusNode: _markaFocusNode,
                    onSubmitted: (_) => _remarksFocusNode.requestFocus(),
                  ),
                  _entryField(
                    'Remarks',
                    _remarksController,
                    focusNode: _remarksFocusNode,
                    onSubmitted: (_) => _addDetail(),
                  ),
                ]),
                const SizedBox(height: 5),
                Expanded(child: _detailsTable()),
                const SizedBox(height: 4),
                _bottomSection(),
                const SizedBox(height: 2),
                SizedBox(
                  height: 15,
                  child: Text(
                    _message ?? '',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 10,
                    ),
                  ),
                ),
                _actionBar(),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Widget _titleBar() => Container(
    height: 34,
    alignment: Alignment.center,
    color: AppColors.primary,
    child: const Text(
      'JOB WORK RECEIVE TO MILL',
      style: TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  Widget _section(String text) => Container(
    height: 20,
    alignment: Alignment.centerLeft,
    padding: const EdgeInsets.symmetric(horizontal: 6),
    color: AppColors.secondary,
    child: Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 10,
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  Widget _fieldRow(List<Widget> children) => Row(children: children);

  Widget _fieldGap() => const SizedBox(height: 3);

  Widget _headerField(
    String label,
    double width,
    TextEditingController controller,
  ) => SizedBox(
    width: width,
    child: _labelledTextField(label, controller: controller),
  );

  Widget _headerDateField(
    String label,
    TextEditingController controller,
    VoidCallback onTap,
    double width,
  ) => SizedBox(
    width: width,
    child: _dateField(label, controller, onTap, expand: false),
  );

  Widget _field(String label, TextEditingController controller) =>
      Expanded(child: _labelledTextField(label, controller: controller));

  Widget _entryField(
    String label,
    TextEditingController controller, {
    FocusNode? focusNode,
    ValueChanged<String>? onSubmitted,
  }) => Expanded(
    child: _labelledTextField(
      label,
      controller: controller,
      focusNode: focusNode,
      onSubmitted: onSubmitted,
    ),
  );

  Widget _readOnlyNumber(String label, String value) => Expanded(
    child: SizedBox(
      height: 23,
      child: Row(
        children: [
          SizedBox(
            width: 76,
            child: Text(
              label,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Container(
              height: 23,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: AppColors.header,
                border: Border.all(color: AppColors.border),
              ),
              child: Text(value, style: const TextStyle(fontSize: 11)),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _labelledTextField(
    String label, {
    TextEditingController? controller,
    FocusNode? focusNode,
    String? initialValue,
    bool readOnly = false,
    ValueChanged<String>? onSubmitted,
  }) => SizedBox(
    height: 23,
    child: Row(
      children: [
        SizedBox(
          width: 76,
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: TextField(
            key: ValueKey(label),
            controller: controller,
            focusNode: focusNode,
            readOnly: readOnly,
            onSubmitted: onSubmitted,
            style: const TextStyle(fontSize: 11),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: readOnly
                  ? AppColors.header
                  : AppColors.inputBackground,
              hintText: initialValue,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 4,
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _dateField(
    String label,
    TextEditingController controller,
    VoidCallback onTap, {
    bool expand = true,
  }) {
    final field = SizedBox(
      height: 23,
      child: Row(
        children: [
          SizedBox(
            width: 76,
            child: Text(
              label,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: onTap,
              child: Container(
                height: 23,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        controller.text,
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                    const Icon(Icons.calendar_today, size: 12),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
    return expand ? Expanded(child: field) : field;
  }

  Widget _detailsTable() => Container(
    decoration: BoxDecoration(
      color: AppColors.tableBackground,
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      children: [
        Container(
          height: 27,
          color: AppColors.tableHeader,
          child: const Row(
            children: [
              _HeaderCell('Srno', 42),
              _HeaderCell('Meters', 72),
              _HeaderCell('Weight', 72),
              _HeaderCell('Marka', 90),
              _HeaderCell('Remarks', null),
              _HeaderCell('IsFinished', 66),
            ],
          ),
        ),
        Expanded(
          child: _details.isEmpty
              ? const Center(
                  child: Text(
                    'Enter detail row to add it here',
                    style: TextStyle(color: Color(0xFFD9DCDD), fontSize: 11),
                  ),
                )
              : ListView.builder(
                  itemCount: _details.length,
                  itemBuilder: (_, index) {
                    final row = _details[index];
                    return InkWell(
                      onTap: () => setState(() => _selectedRow = index),
                      child: Container(
                        height: 24,
                        color: _selectedRow == index
                            ? AppColors.highlight
                            : index.isEven
                            ? AppColors.tableBackground
                            : AppColors.tableAlternateRow,
                        child: Row(
                          children: [
                            _DataCell('${row.serialNo}', 42),
                            _DataCell(_number(row.meters), 72),
                            _DataCell(_number(row.weight), 72),
                            _DataCell(row.marka, 90),
                            _DataCell(row.remarks, null),
                            _DataCell(row.isFinished ? 'Yes' : 'No', 66),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    ),
  );

  String _number(double value) => value.toStringAsFixed(2);

  Widget _bottomSection() => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        flex: 3,

        child: Column(
          children: [
            _fieldRow([
              _field('Remarks (F9)', _bottomRemarksController),
              SizedBox(width: 8),
              _field('L.R No', _lrNoController),
            ]),
            _fieldGap(),
            _fieldRow([
              _field('Tampo No', _tampoNoController),
              SizedBox(width: 8),
              _field('Transport', _transportController),
            ]),
          ],
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        flex: 2,
        child: Column(
          children: [
            _readOnlyTotal('Tot Mtrs.', _number(_totalMeters)),
            _fieldGap(),
            _fieldRow([
              Expanded(child: _readOnlyTotal('Job Amount', '0.00')),
              SizedBox(width: 8),
              Expanded(child: _readOnlyTotal('Gray Amount', '0.00')),
            ]),
          ],
        ),
      ),
      const SizedBox(width: 8),
      SizedBox(
        width: 92,

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _checkOption(
              'Only Pending',
              _onlyPending,
              (value) => setState(() => _onlyPending = value),
            ),
            _checkOption(
              'Job Card',
              _jobCard,
              (value) => setState(() => _jobCard = value),
            ),
            _checkOption(
              'Special',
              _special,
              (value) => setState(() => _special = value),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _readOnlyTotal(String label, String value) =>
      _labelledTextField(label, initialValue: value, readOnly: true);

  Widget _checkOption(String label, bool value, ValueChanged<bool> onChanged) =>
      SizedBox(
        height: 21,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: Checkbox(
                value: value,
                onChanged: (next) => onChanged(next ?? false),
              ),
            ),
            SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _actionBar() => SizedBox(
    height: 29,
    child: Wrap(
      spacing: 4,
      runSpacing: 3,
      children: ['New', 'Find', 'Save', 'Cancel', 'Delete', 'Print', 'Exit']
          .map(
            (label) => OutlinedButton.icon(
              onPressed: switch (label) {
                'New' => _newTransaction,
                'Find' => _find,
                'Save' => _save,
                'Delete' => _deleteBill,
                'Cancel' => _newTransaction,
                'Print' => _printBill,
                _ => () => _showMessage('$label selected'),
              },
              icon: Icon(_icon(label), size: 12),
              label: Text(label, style: const TextStyle(fontSize: 10)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 27),
                padding: const EdgeInsets.symmetric(horizontal: 6),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          )
          .toList(),
    ),
  );

  IconData _icon(String label) => switch (label) {
    'New' => Icons.add,
    'Find' => Icons.search,
    'Save' => Icons.save_outlined,
    'Cancel' => Icons.close,
    'Delete' => Icons.delete_outline,
    'Print' => Icons.print_outlined,
    _ => Icons.exit_to_app,
  };
}

class _ReceiveDetail {
  const _ReceiveDetail({
    required this.serialNo,
    required this.meters,
    required this.weight,
    required this.marka,
    required this.remarks,
    this.isFinished = false,
  });

  final int serialNo;
  final double meters;
  final double weight;
  final String marka;
  final String remarks;
  final bool isFinished;

  _ReceiveDetail copyWith({int? serialNo}) => _ReceiveDetail(
    serialNo: serialNo ?? this.serialNo,
    meters: meters,
    weight: weight,
    marka: marka,
    remarks: remarks,
    isFinished: isFinished,
  );
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell(this.text, this.width);
  final String text;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final child = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
    return width == null
        ? Expanded(child: child)
        : SizedBox(width: width, child: child);
  }
}

class _DataCell extends StatelessWidget {
  const _DataCell(this.text, this.width);
  final String text;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final child = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 10, color: Colors.white),
      ),
    );
    return width == null
        ? Expanded(child: child)
        : SizedBox(width: width, child: child);
  }
}

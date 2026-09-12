import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_colors.dart';
import '../../data/sales_repository.dart';

class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  final _repository = SalesRepository();
  final _book = TextEditingController(text: 'Sales Book');
  final _voucher = TextEditingController(text: 'AUTO');
  final _billNo = TextEditingController();
  final _billBook = TextEditingController(text: 'Main Bill Book');
  final _party = TextEditingController();
  final _partyGst = TextEditingController();
  final _partyAddress = TextEditingController();
  final _gstin = TextEditingController();
  final _destination = TextEditingController();
  final _creditDays = TextEditingController(text: '0');
  final _broker = TextEditingController();
  final _challanId = TextEditingController();
  final _description = TextEditingController();
  final _delivery = TextEditingController();
  final _eway = TextEditingController();
  final _product = TextEditingController();
  final _detailDescription = TextEditingController();
  final _pcs = TextEditingController(text: '0');
  final _cut = TextEditingController(text: '0');
  final _meters = TextEditingController();
  final _pm = TextEditingController(text: 'MTR');
  final _rate = TextEditingController();
  final _discount = TextEditingController(text: '0');
  final _less = TextEditingController(text: '0');
  final _sgst = TextEditingController(text: '9');
  final _cgst = TextEditingController(text: '9');
  final _challanNo = TextEditingController();
  final _chBook = TextEditingController(text: 'Challan Book');
  final _partyNo = TextEditingController();
  final _lotNo = TextEditingController();
  final _greyMeters = TextEditingController(text: '0');
  final _hsn = TextEditingController();
  final _productUnit = TextEditingController(text: 'MTR');
  final _productFocus = FocusNode();
  final _metersFocus = FocusNode();
  final _rateFocus = FocusNode();

  final List<_SalesLine> _lines = [];
  DateTime _billDate = DateTime.now();
  DateTime? _challanDate;
  String _invoiceType = 'Regular';
  String _vatCalc = 'Inclusive';
  String _unit = 'MTR';
  String _printType = 'Invoice';
  double _other = 0;
  bool _isNoStock = false;
  String? _status;
  int _nextSrNo = 1;

  static const _columns = [
    'Sr No',
    'Product Name',
    'Description',
    'PCS',
    'CUT',
    'METERS',
    'PM',
    'Rate',
    'Amount',
    'SRate',
    'SGST',
    'CGST',
    'SGST Rs.',
    'CGST Rs.',
    'Amount',
    'CDP',
    'CDRS',
    'CDP1',
    'CDRs',
    'CDP1',
    'CDRs1',
    'R1',
    'R2',
    'VatCalc',
    'IS_NOStk',
    'Chalan Id',
    'Ch Date',
    'Ch No',
    'L_Less',
    'Ch Book',
    'Party No',
    'Receive LotNo',
    'Greay_Mtrs',
    'HSNCode',
    'Unit',
  ];

  @override
  void dispose() {
    for (final controller in [
      _book,
      _voucher,
      _billNo,
      _billBook,
      _party,
      _partyGst,
      _partyAddress,
      _gstin,
      _destination,
      _creditDays,
      _broker,
      _challanId,
      _description,
      _delivery,
      _eway,
      _product,
      _detailDescription,
      _pcs,
      _cut,
      _meters,
      _pm,
      _rate,
      _discount,
      _less,
      _sgst,
      _cgst,
      _challanNo,
      _chBook,
      _partyNo,
      _lotNo,
      _greyMeters,
      _hsn,
      _productUnit,
    ]) {
      controller.dispose();
    }
    _productFocus.dispose();
    _metersFocus.dispose();
    _rateFocus.dispose();
    super.dispose();
  }

  double get _basic => _lines.fold(0, (sum, line) => sum + line.taxable);
  double get _sgstTotal => _lines.fold(0, (sum, line) => sum + line.sgstRs);
  double get _cgstTotal => _lines.fold(0, (sum, line) => sum + line.cgstRs);
  double get _grandTotal => _basic + _sgstTotal + _cgstTotal + _other;
  String _number(double value) => value.toStringAsFixed(2);
  String _date(DateTime? value) => value == null
      ? ''
      : '${value.day.toString().padLeft(2, '0')}-${value.month.toString().padLeft(2, '0')}-${value.year}';

  Future<void> _pickDate(bool challan) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: challan ? (_challanDate ?? DateTime.now()) : _billDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selected != null)
      setState(() => challan ? _challanDate = selected : _billDate = selected);
  }

  void _addLine() {
    final product = _product.text.trim();
    final pcs = double.tryParse(_pcs.text) ?? 0;
    final meters = double.tryParse(_meters.text);
    final rate = double.tryParse(_rate.text);
    final discount = double.tryParse(_discount.text) ?? 0;
    final sgst = double.tryParse(_sgst.text) ?? 0;
    final cgst = double.tryParse(_cgst.text) ?? 0;
    if (product.isEmpty ||
        (pcs <= 0 && (meters == null || meters <= 0)) ||
        rate == null ||
        rate < 0) {
      setState(
        () =>
            _status = 'Enter a product, quantity or meters, and a valid rate.',
      );
      _productFocus.requestFocus();
      return;
    }
    if (discount < 0 || discount > 100 || sgst < 0 || cgst < 0) {
      setState(
        () => _status = 'Discount and GST rates must be valid percentages.',
      );
      return;
    }
    final line = _SalesLine(
      srNo: _nextSrNo,
      product: product,
      description: _detailDescription.text.trim(),
      pcs: pcs,
      cut: double.tryParse(_cut.text) ?? 0,
      meters: meters ?? 0,
      pm: _pm.text.trim(),
      rate: rate,
      discount: discount,
      sgstRate: sgst,
      cgstRate: cgst,
      vatCalc: _vatCalc,
      isNoStock: _isNoStock,
      challanId: _challanId.text.trim(),
      challanDate: _challanDate,
      challanNo: _challanNo.text.trim(),
      less: double.tryParse(_less.text) ?? 0,
      challanBook: _chBook.text.trim(),
      partyNo: _partyNo.text.trim(),
      lotNo: _lotNo.text.trim(),
      greyMeters: double.tryParse(_greyMeters.text) ?? 0,
      hsn: _hsn.text.trim(),
      unit: _unit,
    );
    setState(() {
      _lines.add(line);
      _nextSrNo++;
      _product.clear();
      _detailDescription.clear();
      _pcs.text = '0';
      _cut.text = '0';
      _meters.clear();
      _rate.clear();
      _discount.text = '0';
      _status = 'Product ${line.srNo} added.';
    });
    _productFocus.requestFocus();
  }

  void _deleteLine(int index) => setState(() {
    _lines.removeAt(index);
    for (var i = 0; i < _lines.length; i++) {
      _lines[i] = _lines[i].withSrNo(i + 1);
    }
    _nextSrNo = _lines.length + 1;
  });

  Future<void> _otherDialog() async {
    final controller = TextEditingController(text: _other.toStringAsFixed(2));
    final value = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Other (+/-)'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: true,
          ),
          decoration: const InputDecoration(labelText: 'Adjustment amount'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(context, double.tryParse(controller.text)),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value != null) setState(() => _other = value);
  }

  Future<void> _save() async {
    if (_book.text.trim().isEmpty ||
        _party.text.trim().isEmpty ||
        _billNo.text.trim().isEmpty ||
        _lines.isEmpty) {
      setState(
        () => _status =
            'Book, Bill No, Party, and at least one product are required.',
      );
      return;
    }
    try {
      await _repository.saveSale(
        header: {
          'voucher_no': _voucher.text.trim(),
          'bill_no': _billNo.text.trim(),
          'bill_date': _billDate.toIso8601String(),
          'book': _book.text.trim(),
          'party': _party.text.trim(),
          'invoice_type': _invoiceType,
          'bill_book': _billBook.text.trim(),
          'broker': _broker.text.trim(),
          'challan_date': _challanDate?.toIso8601String(),
          'destination': _destination.text.trim(),
          'credit_days': int.tryParse(_creditDays.text) ?? 0,
          'challan_id': _challanId.text.trim(),
          'description': _description.text.trim(),
          'delivery': _delivery.text.trim(),
          'eway_bill_no': _eway.text.trim(),
          'print_type': _printType,
          'other_adjustment': _other,
          'bill_amount': _grandTotal,
          'created_at': DateTime.now().toIso8601String(),
        },
        lines: _lines.map((line) => line.toMap()).toList(),
      );
      if (mounted)
        setState(() => _status = 'Sale ${_voucher.text} saved successfully.');
    } catch (error) {
      if (mounted) setState(() => _status = 'Could not save sale: $error');
    }
  }

  @override
  Widget build(BuildContext context) => Shortcuts(
    shortcuts: {
      SingleActivator(LogicalKeyboardKey.f9): const SalesOtherIntent(),
      SingleActivator(LogicalKeyboardKey.f7): const SalesFindIntent(),
    },
    child: Actions(
      actions: {
        SalesOtherIntent: CallbackAction<Intent>(
          onInvoke: (_) {
            _otherDialog();
            return null;
          },
        ),
        SalesFindIntent: CallbackAction<Intent>(
          onInvoke: (_) {
            setState(
              () => _status =
                  'Find / Multi Print is ready for transaction lookup.',
            );
            return null;
          },
        ),
      },
      child: Focus(
        autofocus: true,
        child: Container(
          color: AppColors.formBackground,
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _title(),
              const SizedBox(height: 5),
              _header(),
              const SizedBox(height: 5),
              _entry(),
              const SizedBox(height: 5),
              Expanded(child: _table()),
              const SizedBox(height: 5),
              _bottom(),
              const SizedBox(height: 5),
              _actions(),
              if (_status != null)
                SizedBox(
                  height: 18,
                  child: Text(
                    _status!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.error,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _title() => Container(
    height: 28,
    color: AppColors.primary,
    alignment: Alignment.center,
    child: const Text(
      'SALES',
      style: TextStyle(
        color: Colors.white,
        fontSize: 17,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
  Widget _header() => Container(
    padding: const EdgeInsets.all(6),
    decoration: BoxDecoration(
      border: Border.all(color: AppColors.border),
      color: const Color(0xFFE4E1A8),
    ),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth > 900
            ? (constraints.maxWidth - 30) / 4
            : 260.0;
        return Wrap(
          spacing: 10,
          runSpacing: 5,
          children: [
            _field('Book', _book, width),
            _field(
              'Balance',
              TextEditingController(text: '0.00'),
              width,
              readOnly: true,
            ),
            _field('Voucher No', _voucher, width),
            _field('Bill No', _billNo, width),
            _dateField('Bill Date', _billDate, width, () => _pickDate(false)),
            _drop(
              'Inv. Type (T/R)',
              _invoiceType,
              ['Regular', 'Tax Invoice', 'Reverse Charge'],
              width,
              (value) => setState(() => _invoiceType = value!),
            ),
            _field('Bill Book', _billBook, width),
            _field('Party', _party, width),
            _field(
              'Party Balance',
              TextEditingController(text: '0.00'),
              width,
              readOnly: true,
            ),
            _field('Party GST No.', _partyGst, width),
            _field('GSTIN', _gstin, width),
            _field('Party Address', _partyAddress, width * 2),
            _dateField(
              'Challan Dt',
              _challanDate,
              width,
              () => _pickDate(true),
            ),
            _field('To', _destination, width),
            _field(
              'Cr. Days',
              _creditDays,
              width,
              keyboardType: TextInputType.number,
            ),
            _field('Broker', _broker, width),
            _field('Challan ID', _challanId, width),
          ],
        );
      },
    ),
  );
  Widget _entry() => Container(
    padding: const EdgeInsets.symmetric(vertical: 5),
    decoration: BoxDecoration(
      border: Border.all(color: AppColors.border),
      color: AppColors.inputBackground,
    ),
    child: Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: _entryLabels(),
            ),
          ),
        ),
        const SizedBox(height: 3),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _readOnly('${_nextSrNo}', 52),
                _entryGap,
                SizedBox(
                  width: 160,
                  child: _input(
                    _product,
                    key: const ValueKey('salesProductField'),
                    focusNode: _productFocus,
                    onSubmitted: (_) => _metersFocus.requestFocus(),
                  ),
                ),
                _entryGap,
                SizedBox(width: 120, child: _input(_detailDescription)),
                _entryGap,
                SizedBox(
                  width: 58,
                  child: _input(
                    _pcs,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
                _entryGap,
                SizedBox(
                  width: 58,
                  child: _input(
                    _cut,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
                _entryGap,
                SizedBox(
                  width: 78,
                  child: _input(
                    _meters,
                    key: const ValueKey('salesMetersField'),
                    focusNode: _metersFocus,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onSubmitted: (_) => _rateFocus.requestFocus(),
                  ),
                ),
                _entryGap,
                SizedBox(
                  width: 62,
                  child: _inlineDrop(_pm, ['MTR', 'PCS', 'KG']),
                ),
                _entryGap,
                SizedBox(
                  width: 78,
                  child: _input(
                    _rate,
                    key: const ValueKey('salesRateField'),
                    focusNode: _rateFocus,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onSubmitted: (_) => _addLine(),
                  ),
                ),
                _entryGap,
                _readOnly(_previewAmount, 85),
                _entryGap,
                _readOnly(_number(double.tryParse(_sgst.text) ?? 0), 58),
                _entryGap,
                _readOnly(_number(double.tryParse(_cgst.text) ?? 0), 58),
                _entryGap,
                _readOnly(_previewNet, 92),
              ],
            ),
          ),
        ),
        const SizedBox(height: 2),
        SizedBox(
          height: 28,
          child: Row(
            children: [
              Checkbox(
                value: _isNoStock,
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: (value) =>
                    setState(() => _isNoStock = value ?? false),
              ),
              const Text(
                'IS_NOStk',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 18),
              const Text(
                'Ch Date',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 5),
              InkWell(
                onTap: () => _pickDate(true),
                child: _box(
                  _date(_challanDate),
                  trailing: const Icon(Icons.calendar_today, size: 13),
                ),
              ),
              const SizedBox(width: 18),
              const Text(
                'Ch No',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 5),
              SizedBox(width: 110, child: _input(_challanNo)),
            ],
          ),
        ),
      ],
    ),
  );
  static const _entryGap = SizedBox(width: 4);

  List<Widget> _entryLabels() => [
    const _Label('Sr No', 52),
    _entryGap,
    const _Label('Quality Name / Product Name', 160),
    _entryGap,
    const _Label('Description', 120),
    _entryGap,
    const _Label('PCS', 58),
    _entryGap,
    const _Label('CUT', 58),
    _entryGap,
    const _Label('METERS', 78),
    _entryGap,
    const _Label('PM', 62),
    _entryGap,
    const _Label('Rate', 78),
    _entryGap,
    const _Label('Amount', 85),
    _entryGap,
    const _Label('SGST', 58),
    _entryGap,
    const _Label('CGST', 58),
    _entryGap,
    const _Label('Net Amount', 92),
  ];
  String get _previewAmount {
    final quantity =
        double.tryParse(_meters.text) ?? double.tryParse(_pcs.text) ?? 0;
    return _number(quantity * (double.tryParse(_rate.text) ?? 0));
  }

  String get _previewNet {
    final amount = double.tryParse(_previewAmount) ?? 0;
    final discount = double.tryParse(_discount.text) ?? 0;
    final taxable = amount * (1 - discount / 100);
    return _number(
      taxable *
          (1 +
              ((double.tryParse(_sgst.text) ?? 0) +
                      (double.tryParse(_cgst.text) ?? 0)) /
                  100),
    );
  }

  Widget _table() => Container(
    decoration: BoxDecoration(border: Border.all(color: AppColors.border)),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: 2800,
        child: Column(
          children: [
            Container(
              height: 28,
              color: AppColors.tableHeader,
              child: Row(
                children: _columns
                    .map(
                      (column) => _TableHeader(
                        column,
                        column == 'Product Name'
                            ? 150
                            : column == 'Description'
                            ? 110
                            : 74,
                      ),
                    )
                    .toList(),
              ),
            ),
            Expanded(
              child: _lines.isEmpty
                  ? const SizedBox.expand()
                  : ListView.builder(
                      itemCount: _lines.length,
                      itemBuilder: (context, index) {
                        final line = _lines[index];
                        final values = line.values;
                        return Container(
                          color: index.isEven
                              ? AppColors.tableBackground
                              : AppColors.tableAlternateRow,
                          height: 28,
                          child: Row(
                            children: [
                              for (var i = 0; i < values.length; i++)
                                _cell(
                                  values[i],
                                  _columns[i] == 'Product Name'
                                      ? 150
                                      : _columns[i] == 'Description'
                                      ? 110
                                      : 74,
                                ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _bottom() => SizedBox(
    height: 135,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              color: const Color(0xFFE4E1A8),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _compact('Deli', _delivery)),
                    const SizedBox(width: 8),
                    Expanded(child: _compact('Desc', _description)),
                    const SizedBox(width: 8),
                    Expanded(child: _compact('E-way', _eway)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _drop(
                        'Print Type',
                        _printType,
                        ['Invoice', 'Thermal', 'Duplicate'],
                        180,
                        (value) => setState(() => _printType = value!),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _otherDialog,
                    icon: const Icon(Icons.exposure, size: 17),
                    label: const Text('(F9) Others (+/-)'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 300,
          child: Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              color: AppColors.inputBackground,
            ),
            child: Column(
              children: [
                _total('PCS', _lines.fold(0, (sum, line) => sum + line.pcs)),
                _total('Rate', _lines.fold(0, (sum, line) => sum + line.rate)),
                _total(
                  'METERS',
                  _lines.fold(0, (sum, line) => sum + line.meters),
                ),
                _total('Basic Amt', _basic),
                _total('SGST', _sgstTotal),
                _total('CGST', _cgstTotal),
                const Divider(),
                _total('BILL AMOUNT', _grandTotal, strong: true),
              ],
            ),
          ),
        ),
      ],
    ),
  );
  Widget _total(String label, double value, {bool strong = false}) => SizedBox(
    height: strong ? 18 : 14,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: strong ? 13 : 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          _number(value),
          style: TextStyle(
            fontSize: strong ? 14 : 10,
            fontWeight: FontWeight.w700,
            color: strong ? AppColors.accent : AppColors.textPrimary,
          ),
        ),
      ],
    ),
  );
  Widget _actions() => Wrap(
    spacing: 6,
    children: [
      _button('New', () {
        setState(() {
          _lines.clear();
          _nextSrNo = 1;
          _other = 0;
          _status = 'New sales entry.';
        });
        _productFocus.requestFocus();
      }, Icons.add),
      _button(
        'Find',
        () => setState(
          () => _status = 'Find / Multi Print is ready for transaction lookup.',
        ),
        Icons.search,
      ),
      _button('Save', _save, Icons.save_outlined),
      _button(
        'Cancel',
        () => setState(() => _status = 'Current operation cancelled.'),
        Icons.close,
      ),
      _button(
        'Delete',
        () => setState(() => _status = 'Select a saved sale before deleting.'),
        Icons.delete_outline,
      ),
      _button(
        'Print',
        () => setState(() => _status = 'Print preview is ready.'),
        Icons.print,
      ),
      _button('Exit', () => Navigator.maybePop(context), Icons.exit_to_app),
    ],
  );
  Widget _button(String label, VoidCallback onPressed, IconData icon) =>
      OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 14),
        label: Text(label),
      );
  Widget _field(
    String label,
    TextEditingController controller,
    double width, {
    bool readOnly = false,
    TextInputType? keyboardType,
  }) => SizedBox(
    width: width,
    child: Row(
      children: [
        SizedBox(
          width: 78,
          child: Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: _input(
            controller,
            readOnly: readOnly,
            keyboardType: keyboardType,
          ),
        ),
      ],
    ),
  );
  Widget _dateField(
    String label,
    DateTime? date,
    double width,
    VoidCallback onTap,
  ) => SizedBox(
    width: width,
    child: Row(
      children: [
        SizedBox(
          width: 78,
          child: Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: InkWell(
            onTap: onTap,
            child: _box(
              _date(date),
              trailing: const Icon(Icons.calendar_today, size: 13),
            ),
          ),
        ),
      ],
    ),
  );
  Widget _drop(
    String label,
    String value,
    List<String> values,
    double width,
    ValueChanged<String?> onChanged,
  ) => SizedBox(
    width: width,
    child: Row(
      children: [
        SizedBox(
          width: 78,
          child: Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: value,
            isDense: true,
            isExpanded: true,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 5, vertical: 4),
            ),
            items: values
                .map(
                  (item) => DropdownMenuItem(
                    value: item,
                    child: Text(
                      item,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    ),
  );
  Widget _compact(String label, TextEditingController controller) => Row(
    children: [
      Text(
        '$label: ',
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      ),
      Expanded(child: _input(controller)),
    ],
  );
  Widget _inlineDrop(TextEditingController controller, List<String> values) =>
      SizedBox(
        height: 27,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: values.contains(controller.text)
                  ? controller.text
                  : values.first,
              isDense: true,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              iconSize: 16,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 11,
              ),
              items: values
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text(
                        value,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => controller.text = value);
              },
            ),
          ),
        ),
      );
  Widget _input(
    TextEditingController controller, {
    Key? key,
    FocusNode? focusNode,
    TextInputType? keyboardType,
    ValueChanged<String>? onSubmitted,
    VoidCallback? onEditingComplete,
    bool readOnly = false,
  }) => TextField(
    key: key,
    controller: controller,
    focusNode: focusNode,
    keyboardType: keyboardType,
    onSubmitted: onSubmitted,
    onEditingComplete: onEditingComplete,
    readOnly: readOnly,
    onChanged: (_) => setState(() {}),
    style: const TextStyle(fontSize: 11),
    decoration: const InputDecoration(
      isDense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
    ),
  );
  Widget _readOnly(String value, double width) =>
      SizedBox(width: width, child: _box(value));
  Widget _box(String value, {Widget? trailing}) => Container(
    height: 27,
    padding: const EdgeInsets.symmetric(horizontal: 5),
    decoration: BoxDecoration(
      color: AppColors.inputBackground,
      border: Border.all(color: AppColors.border),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 11),
        ),
        if (trailing != null) trailing,
      ],
    ),
  );
  Widget _cell(String value, double width) => SizedBox(
    width: width,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          value,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white, fontSize: 10),
        ),
      ),
    ),
  );
}

class _SalesLine {
  const _SalesLine({
    required this.srNo,
    required this.product,
    required this.description,
    required this.pcs,
    required this.cut,
    required this.meters,
    required this.pm,
    required this.rate,
    required this.discount,
    required this.sgstRate,
    required this.cgstRate,
    required this.vatCalc,
    required this.isNoStock,
    required this.challanId,
    required this.challanDate,
    required this.challanNo,
    required this.less,
    required this.challanBook,
    required this.partyNo,
    required this.lotNo,
    required this.greyMeters,
    required this.hsn,
    required this.unit,
  });
  final int srNo;
  final String product,
      description,
      pm,
      vatCalc,
      challanId,
      challanNo,
      challanBook,
      partyNo,
      lotNo,
      hsn,
      unit;
  final double pcs,
      cut,
      meters,
      rate,
      discount,
      sgstRate,
      cgstRate,
      less,
      greyMeters;
  final bool isNoStock;
  final DateTime? challanDate;
  double get amount => (meters > 0 ? meters : pcs) * rate;
  double get discountRs => amount * discount / 100;
  double get taxable => amount - discountRs - less;
  double get sgstRs => taxable * sgstRate / 100;
  double get cgstRs => taxable * cgstRate / 100;
  double get net => taxable + sgstRs + cgstRs;
  _SalesLine withSrNo(int value) => _SalesLine(
    srNo: value,
    product: product,
    description: description,
    pcs: pcs,
    cut: cut,
    meters: meters,
    pm: pm,
    rate: rate,
    discount: discount,
    sgstRate: sgstRate,
    cgstRate: cgstRate,
    vatCalc: vatCalc,
    isNoStock: isNoStock,
    challanId: challanId,
    challanDate: challanDate,
    challanNo: challanNo,
    less: less,
    challanBook: challanBook,
    partyNo: partyNo,
    lotNo: lotNo,
    greyMeters: greyMeters,
    hsn: hsn,
    unit: unit,
  );
  List<String> get values => [
    '${srNo}',
    product,
    description,
    _f(pcs),
    _f(cut),
    _f(meters),
    pm,
    _f(rate),
    _f(amount),
    _f(rate),
    '${_f(sgstRate)}%',
    '${_f(cgstRate)}%',
    _f(sgstRs),
    _f(cgstRs),
    _f(net),
    _f(discount),
    _f(discountRs),
    '0.00',
    '0.00',
    '0.00',
    '0.00',
    '0.00',
    '0.00',
    vatCalc,
    isNoStock ? 'Yes' : 'No',
    challanId,
    challanDate == null
        ? ''
        : '${challanDate!.day}-${challanDate!.month}-${challanDate!.year}',
    challanNo,
    _f(less),
    challanBook,
    partyNo,
    lotNo,
    _f(greyMeters),
    hsn,
    unit,
  ];
  Map<String, Object?> toMap() => {
    'sr_no': srNo,
    'product_name': product,
    'description': description,
    'pcs': pcs,
    'cut': cut,
    'meters': meters,
    'pm': pm,
    'rate': rate,
    'amount': amount,
    's_rate': rate,
    'sgst_rate': sgstRate,
    'cgst_rate': cgstRate,
    'sgst_amount': sgstRs,
    'cgst_amount': cgstRs,
    'net_amount': net,
    'cdp': discount,
    'cdrs': discountRs,
    'cdp1': 0,
    'cdrs1': 0,
    'r1': 0,
    'r2': 0,
    'vat_calc': vatCalc,
    'is_no_stock': isNoStock ? 1 : 0,
    'chalan_id': challanId,
    'ch_date': challanDate?.toIso8601String(),
    'ch_no': challanNo,
    'l_less': less,
    'ch_book': challanBook,
    'party_no': partyNo,
    'receive_lot_no': lotNo,
    'greay_mtrs': greyMeters,
    'hsn_code': hsn,
    'unit': unit,
  };
}

String _f(double value) => value.toStringAsFixed(2);

class _Label extends StatelessWidget {
  const _Label(this.text, this.width);
  final String text;
  final double width;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
    ),
  );
}

class _TableHeader extends StatelessWidget {
  const _TableHeader(this.text, this.width);
  final String text;
  final double width;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    child: Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}

class SalesOtherIntent extends Intent {
  const SalesOtherIntent();
}

class SalesFindIntent extends Intent {
  const SalesFindIntent();
}

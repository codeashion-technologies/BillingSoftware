import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_colors.dart';
import '../../data/purchase_repository.dart';

class PurchasePage extends StatefulWidget {
  const PurchasePage({super.key});

  @override
  State<PurchasePage> createState() => _PurchasePageState();
}

class _PurchasePageState extends State<PurchasePage> {
  final _repository = PurchaseRepository();
  final _bookController = TextEditingController(text: 'Purchase Book');
  final _voucherController = TextEditingController(text: 'AUTO');
  final _billNoController = TextEditingController();
  final _partyController = TextEditingController();
  final _brokerController = TextEditingController();
  final _transportController = TextEditingController();
  final _lrNoController = TextEditingController();
  final _caseNoController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _ewayController = TextEditingController();
  final _productController = TextEditingController();
  final _quantityController = TextEditingController();
  final _pmController = TextEditingController(text: 'PCS');
  final _rateController = TextEditingController();
  final _discountController = TextEditingController(text: '0');
  final _sgstController = TextEditingController(text: '9');
  final _cgstController = TextEditingController(text: '9');
  final _productFocus = FocusNode();
  final _quantityFocus = FocusNode();
  final _rateFocus = FocusNode();

  final List<_PurchaseLine> _lines = [];
  DateTime _billDate = DateTime.now();
  DateTime? _lrDate;
  String _invoiceType = 'Regular';
  String _goodsType = 'Goods';
  double _otherAdjustment = 0;
  int? _editingIndex;
  String? _status;
  int _nextSrNo = 1;

  static const _accounts = [
    'Purchase Book',
    'Import Purchase',
    'Local Purchase',
  ];
  static const _parties = ['Select party', 'Alpha Industries', 'Shree Traders'];
  static const _brokers = ['No Broker', 'Rajesh Broker', 'Milan Agency'];
  static const _transports = ['Self', 'ABC Logistics', 'Shree Transport'];

  @override
  void dispose() {
    for (final controller in [
      _bookController,
      _voucherController,
      _billNoController,
      _partyController,
      _brokerController,
      _transportController,
      _lrNoController,
      _caseNoController,
      _descriptionController,
      _ewayController,
      _productController,
      _quantityController,
      _pmController,
      _rateController,
      _discountController,
      _sgstController,
      _cgstController,
    ]) {
      controller.dispose();
    }
    _productFocus.dispose();
    _quantityFocus.dispose();
    _rateFocus.dispose();
    super.dispose();
  }

  double get _basicAmount => _lines.fold(0, (sum, line) => sum + line.taxable);
  double get _sgstTotal => _lines.fold(0, (sum, line) => sum + line.sgstRs);
  double get _cgstTotal => _lines.fold(0, (sum, line) => sum + line.cgstRs);
  double get _grandTotal =>
      _basicAmount + _sgstTotal + _cgstTotal + _otherAdjustment;

  Future<void> _pickDate({required bool lrDate}) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: lrDate ? (_lrDate ?? DateTime.now()) : _billDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selected == null) return;
    setState(() => lrDate ? _lrDate = selected : _billDate = selected);
  }

  String _dateText(DateTime? date) => date == null
      ? ''
      : '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';

  void _addLine() {
    final product = _productController.text.trim();
    final quantity = double.tryParse(_quantityController.text.trim());
    final rate = double.tryParse(_rateController.text.trim());
    final discount = double.tryParse(_discountController.text.trim()) ?? 0;
    final sgst = double.tryParse(_sgstController.text.trim()) ?? 0;
    final cgst = double.tryParse(_cgstController.text.trim()) ?? 0;
    if (product.isEmpty ||
        quantity == null ||
        quantity <= 0 ||
        rate == null ||
        rate < 0) {
      setState(
        () => _status = 'Enter a product, positive quantity, and valid rate.',
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
    final line = _PurchaseLine.create(
      srNo: _nextSrNo,
      product: product,
      quantity: quantity,
      pm: _pmController.text.trim().isEmpty ? 'PCS' : _pmController.text.trim(),
      rate: rate,
      discount: discount,
      sgstRate: sgst,
      cgstRate: cgst,
    );
    setState(() {
      if (_editingIndex == null) {
        _lines.add(line);
        _nextSrNo++;
      } else {
        _lines[_editingIndex!] = line.withSrNo(_lines[_editingIndex!].srNo);
        _editingIndex = null;
      }
      _clearProductFields();
      _status = 'Product ${line.srNo} added.';
    });
    _productFocus.requestFocus();
  }

  void _clearProductFields() {
    _productController.clear();
    _quantityController.clear();
    _pmController.text = 'PCS';
    _rateController.clear();
    _discountController.text = '0';
  }

  void _deleteLine(int index) => setState(() {
    _lines.removeAt(index);
    for (var i = 0; i < _lines.length; i++) {
      _lines[i] = _lines[i].withSrNo(i + 1);
    }
    _nextSrNo = _lines.length + 1;
  });

  void _editLine(int index) {
    final line = _lines[index];
    setState(() {
      _editingIndex = index;
      _productController.text = line.product;
      _quantityController.text = _number(line.quantity);
      _pmController.text = line.pm;
      _rateController.text = _number(line.rate);
      _discountController.text = _number(line.discount);
      _sgstController.text = _number(line.sgstRate);
      _cgstController.text = _number(line.cgstRate);
      _status = 'Editing product ${line.srNo}.';
    });
    _productFocus.requestFocus();
  }

  void _newPurchase() {
    setState(() {
      _lines.clear();
      _nextSrNo = 1;
      _otherAdjustment = 0;
      _status = 'New purchase entry.';
    });
    _clearProductFields();
    _productFocus.requestFocus();
  }

  Future<void> _save() async {
    if (_partyController.text.trim().isEmpty ||
        _partyController.text == 'Select party') {
      setState(() => _status = 'Party is required before saving.');
    } else if (_lines.isEmpty) {
      setState(() => _status = 'Add at least one product before saving.');
    } else {
      try {
        await _repository.savePurchase(
          header: {
            'voucher_no': _voucherController.text.trim(),
            'bill_no': _billNoController.text.trim(),
            'bill_date': _billDate.toIso8601String(),
            'book': _bookController.text.trim(),
            'party': _partyController.text.trim(),
            'invoice_type': _invoiceType,
            'broker': _brokerController.text.trim(),
            'transport': _transportController.text.trim(),
            'description': _descriptionController.text.trim(),
            'goods_type': _goodsType,
            'eway_bill_no': _ewayController.text.trim(),
            'other_adjustment': _otherAdjustment,
            'bill_amount': _grandTotal,
            'created_at': DateTime.now().toIso8601String(),
          },
          lines: _lines
              .map(
                (line) => {
                  'sr_no': line.srNo,
                  'product_name': line.product,
                  'quantity': line.quantity,
                  'pm': line.pm,
                  'rate': line.rate,
                  'amount': line.amount,
                  'discount_percent': line.discount,
                  'discount_amount': line.discountRs,
                  'sgst_rate': line.sgstRate,
                  'cgst_rate': line.cgstRate,
                  'sgst_amount': line.sgstRs,
                  'cgst_amount': line.cgstRs,
                  'total_amount': line.total,
                },
              )
              .toList(),
        );
        if (mounted)
          setState(
            () => _status =
                'Purchase ${_voucherController.text} saved successfully.',
          );
      } catch (error) {
        if (mounted)
          setState(() => _status = 'Could not save purchase: $error');
      }
    }
  }

  Future<void> _other() async {
    final controller = TextEditingController(
      text: _otherAdjustment.toStringAsFixed(2),
    );
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
    if (value != null) setState(() => _otherAdjustment = value);
  }

  @override
  Widget build(BuildContext context) => Shortcuts(
    shortcuts: {
      SingleActivator(LogicalKeyboardKey.f9): const PurchaseOtherIntent(),
      SingleActivator(LogicalKeyboardKey.f3): const PurchasePrintIntent(),
      SingleActivator(LogicalKeyboardKey.f7): const PurchaseFindIntent(),
    },
    child: Actions(
      actions: {
        PurchaseOtherIntent: CallbackAction<Intent>(
          onInvoke: (_) {
            _other();
            return null;
          },
        ),
        PurchasePrintIntent: CallbackAction<Intent>(
          onInvoke: (_) {
            setState(
              () => _status =
                  'Print preview is not available until the purchase is saved.',
            );
            return null;
          },
        ),
        PurchaseFindIntent: CallbackAction<Intent>(
          onInvoke: (_) {
            setState(
              () => _status = 'Find purchase is ready for transaction lookup.',
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
              _titleBar(),
              const SizedBox(height: 5),
              _header(),
              const SizedBox(height: 5),
              _productEntry(),
              const SizedBox(height: 5),
              Expanded(child: _detailsTable()),
              const SizedBox(height: 5),
              _bottomSection(),
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

  Widget _titleBar() => Container(
    height: 28,
    color: AppColors.primary,
    alignment: Alignment.center,
    child: const Text(
      'PURCHASE',
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
            _headerField(
              'Book',
              _bookController,
              width,
              suggestions: _accounts,
            ),
            _headerField(
              'Balance',
              TextEditingController(text: '0.00'),
              width,
              readOnly: true,
            ),
            _headerField('Voucher No', _voucherController, width),
            _headerField('Pur. Bill No', _billNoController, width),
            _headerField(
              'Party',
              _partyController,
              width,
              suggestions: _parties,
            ),
            _headerDropDown(
              'Inv. Type (T/R)',
              _invoiceType,
              ['Regular', 'Tax Invoice', 'Reverse Charge'],
              width,
              (value) => setState(() => _invoiceType = value!),
            ),
            _dateField(
              'Bill Date',
              _billDate,
              width,
              () => _pickDate(lrDate: false),
            ),
            _headerField(
              'Broker',
              _brokerController,
              width,
              suggestions: _brokers,
            ),
            _headerField(
              'Cr. Days',
              TextEditingController(text: '0'),
              width,
              keyboardType: TextInputType.number,
            ),
            _headerField('L.R No', _lrNoController, width),
            _dateField(
              'L.R Date',
              _lrDate,
              width,
              () => _pickDate(lrDate: true),
            ),
            _headerField('Case No', _caseNoController, width),
            _headerField(
              'Transport',
              _transportController,
              width,
              suggestions: _transports,
            ),
          ],
        );
      },
    ),
  );

  Widget _headerField(
    String label,
    TextEditingController controller,
    double width, {
    List<String>? suggestions,
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
          child: suggestions == null
              ? _input(
                  controller,
                  readOnly: readOnly,
                  keyboardType: keyboardType,
                )
              : Autocomplete<String>(
                  optionsBuilder: (value) => suggestions.where(
                    (item) =>
                        item.toLowerCase().contains(value.text.toLowerCase()),
                  ),
                  onSelected: (value) => controller.text = value,
                  fieldViewBuilder: (_, textController, focusNode, __) {
                    textController.text = controller.text;
                    textController.selection = TextSelection.collapsed(
                      offset: textController.text.length,
                    );
                    return _input(
                      textController,
                      focusNode: focusNode,
                      readOnly: readOnly,
                    );
                  },
                ),
        ),
      ],
    ),
  );

  Widget _headerDropDown(
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
            value: value,
            isDense: true,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 5, vertical: 4),
            ),
            items: values
                .map(
                  (item) => DropdownMenuItem(
                    value: item,
                    child: Text(item, style: const TextStyle(fontSize: 11)),
                  ),
                )
                .toList(),
            onChanged: onChanged,
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
            child: _fieldBox(
              _dateText(date),
              trailing: const Icon(Icons.calendar_today, size: 13),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _productEntry() => Container(
    padding: const EdgeInsets.all(5),
    decoration: BoxDecoration(
      border: Border.all(color: AppColors.border),
      color: AppColors.inputBackground,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Row(
          children: [
            _EntryLabel('Sr No', 52),
            _EntryLabel('Product Name', 220),
            _EntryLabel('Quantity', 82),
            _EntryLabel('PM', 70),
            _EntryLabel('Rate', 90),
            _EntryLabel('Disc %', 78),
            _EntryLabel('Amount', 100),
            _EntryLabel('SGST', 75),
            _EntryLabel('CGST', 75),
            _EntryLabel('Net Amount', 105),
          ],
        ),
        const SizedBox(height: 3),
        Row(
          children: [
            _entryReadOnly('${_nextSrNo}', 52),
            SizedBox(
              width: 220,
              child: _input(
                _productController,
                key: const ValueKey('purchaseProductField'),
                focusNode: _productFocus,
                onSubmitted: (_) => _quantityFocus.requestFocus(),
              ),
            ),
            SizedBox(
              width: 82,
              child: _input(
                _quantityController,
                key: const ValueKey('purchaseQuantityField'),
                focusNode: _quantityFocus,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onSubmitted: (_) => _rateFocus.requestFocus(),
              ),
            ),
            SizedBox(width: 70, child: _input(_pmController)),
            SizedBox(
              width: 90,
              child: _input(
                _rateController,
                key: const ValueKey('purchaseRateField'),
                focusNode: _rateFocus,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onSubmitted: (_) => _addLine(),
              ),
            ),
            SizedBox(
              width: 78,
              child: _input(
                _discountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
            ),
            _entryReadOnly(_previewAmount, 100),
            _entryReadOnly(_sgstController.text, 75),
            _entryReadOnly(_cgstController.text, 75),
            Expanded(child: _entryReadOnly(_previewNetAmount, 105)),
          ],
        ),
      ],
    ),
  );

  String get _previewAmount {
    final q = double.tryParse(_quantityController.text) ?? 0;
    final r = double.tryParse(_rateController.text) ?? 0;
    return (q * r).toStringAsFixed(2);
  }

  String get _previewNetAmount {
    final amount = double.tryParse(_previewAmount) ?? 0;
    final discount = double.tryParse(_discountController.text) ?? 0;
    final taxable = amount * (1 - discount / 100);
    final sgst = double.tryParse(_sgstController.text) ?? 0;
    final cgst = double.tryParse(_cgstController.text) ?? 0;
    return (taxable * (1 + (sgst + cgst) / 100)).toStringAsFixed(2);
  }

  Widget _detailsTable() => Container(
    decoration: BoxDecoration(border: Border.all(color: AppColors.border)),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: 1350,
        child: Column(
          children: [
            Container(
              height: 28,
              color: AppColors.tableHeader,
              child: const Row(
                children: [
                  _TableHeader('Sr No', 52),
                  _TableHeader('ProdName', 180),
                  _TableHeader('Quantity', 75),
                  _TableHeader('PM', 60),
                  _TableHeader('Rate', 85),
                  _TableHeader('Amount', 90),
                  _TableHeader('SGST', 70),
                  _TableHeader('CGST', 70),
                  _TableHeader('SGST Rs.', 80),
                  _TableHeader('CGST Rs.', 80),
                  _TableHeader('Tot Amount', 95),
                  _TableHeader('PRate1', 75),
                  _TableHeader('CDP', 60),
                  _TableHeader('CDRs', 70),
                  _TableHeader('Freight_D', 80),
                  _TableHeader('', 120),
                ],
              ),
            ),
            Expanded(
              child: _lines.isEmpty
                  ? const SizedBox.expand()
                  : ListView.builder(
                      itemCount: _lines.length,
                      itemBuilder: (context, index) {
                        final line = _lines[index];
                        return Container(
                          color: index.isEven
                              ? AppColors.tableBackground
                              : AppColors.tableAlternateRow,
                          child: SizedBox(
                            height: 28,
                            child: Row(
                              children: [
                                _tableCell('${line.srNo}', 52),
                                _tableCell(line.product, 180),
                                _tableCell(_number(line.quantity), 75),
                                _tableCell(line.pm, 60),
                                _tableCell(_number(line.rate), 85),
                                _tableCell(_number(line.amount), 90),
                                _tableCell('${_number(line.sgstRate)}%', 70),
                                _tableCell('${_number(line.cgstRate)}%', 70),
                                _tableCell(_number(line.sgstRs), 80),
                                _tableCell(_number(line.cgstRs), 80),
                                _tableCell(_number(line.total), 95),
                                _tableCell(_number(line.rate), 75),
                                _tableCell(_number(line.discount), 60),
                                _tableCell(_number(line.discountRs), 70),
                                _tableCell('0.00', 80),
                                SizedBox(
                                  width: 120,
                                  child: Row(
                                    children: [
                                      IconButton(
                                        onPressed: () => _editLine(index),
                                        tooltip: 'Edit row',
                                        icon: const Icon(
                                          Icons.edit_outlined,
                                          size: 15,
                                          color: Colors.white,
                                        ),
                                        padding: EdgeInsets.zero,
                                      ),
                                      IconButton(
                                        onPressed: () => _deleteLine(index),
                                        tooltip: 'Delete row',
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          size: 15,
                                          color: Colors.white,
                                        ),
                                        padding: EdgeInsets.zero,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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

  Widget _bottomSection() => SizedBox(
    height: 125,
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
                    Expanded(
                      child: _compactField('Desc', _descriptionController),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _compactDropDown('Types Of Goods', _goodsType, [
                        'Goods',
                        'Services',
                      ], (value) => setState(() => _goodsType = value!)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _compactField('Eway Bill No', _ewayController),
                    ),
                  ],
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _other,
                    icon: const Icon(Icons.exposure, size: 17),
                    label: const Text('(F9) Other (+/-)'),
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
                _totalLine('Pur Amt', _basicAmount),
                _totalLine('Basic Amt', _basicAmount),
                _totalLine('SGST', _sgstTotal),
                _totalLine('CGST', _cgstTotal),
                const Divider(),
                _totalLine('BILL AMOUNT', _grandTotal, emphasized: true),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Widget _totalLine(String label, double value, {bool emphasized = false}) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: emphasized ? 13 : 11,
              fontWeight: emphasized ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
          Text(
            value.toStringAsFixed(2),
            style: TextStyle(
              fontSize: emphasized ? 15 : 11,
              fontWeight: FontWeight.w700,
              color: emphasized ? AppColors.accent : AppColors.textPrimary,
            ),
          ),
        ],
      );

  Widget _buildButton(String label, VoidCallback onPressed, {IconData? icon}) =>
      OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon ?? Icons.circle, size: 14),
        label: Text(label),
      );

  Widget _actions() => Wrap(
    spacing: 6,
    children: [
      _buildButton('New', _newPurchase, icon: Icons.add),
      _buildButton(
        'Find',
        () => setState(
          () => _status = 'Find purchase is ready for transaction lookup.',
        ),
        icon: Icons.search,
      ),
      _buildButton('Save', _save, icon: Icons.save_outlined),
      _buildButton(
        'Cancel',
        () => setState(() => _status = 'Current operation cancelled.'),
        icon: Icons.close,
      ),
      _buildButton(
        'Delete',
        () => setState(
          () => _status = 'Select a saved purchase before deleting.',
        ),
        icon: Icons.delete_outline,
      ),
      _buildButton(
        'Exit',
        () => Navigator.maybePop(context),
        icon: Icons.exit_to_app,
      ),
    ],
  );

  Widget _input(
    TextEditingController controller, {
    Key? key,
    FocusNode? focusNode,
    bool readOnly = false,
    TextInputType? keyboardType,
    ValueChanged<String>? onSubmitted,
  }) => TextField(
    key: key ?? ValueKey(controller),
    controller: controller,
    focusNode: focusNode,
    readOnly: readOnly,
    keyboardType: keyboardType,
    onSubmitted: onSubmitted,
    onChanged: (_) => setState(() {}),
    style: const TextStyle(fontSize: 11),
    decoration: const InputDecoration(
      isDense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
    ),
  );
  Widget _fieldBox(String value, {Widget? trailing}) => Container(
    height: 27,
    padding: const EdgeInsets.symmetric(horizontal: 5),
    decoration: BoxDecoration(
      color: AppColors.inputBackground,
      border: Border.all(color: AppColors.border),
    ),
    child: Row(
      children: [
        Expanded(child: Text(value, style: const TextStyle(fontSize: 11))),
        if (trailing != null) trailing,
      ],
    ),
  );
  Widget _entryReadOnly(String value, double width) =>
      SizedBox(width: width, child: _fieldBox(value));
  Widget _compactField(String label, TextEditingController controller) => Row(
    children: [
      Text(
        '$label: ',
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      ),
      Expanded(child: _input(controller)),
    ],
  );
  Widget _compactDropDown(
    String label,
    String value,
    List<String> values,
    ValueChanged<String?> onChanged,
  ) => Row(
    children: [
      Text(
        '$label: ',
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      ),
      Expanded(
        child: DropdownButtonFormField<String>(
          value: value,
          isDense: true,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 5, vertical: 4),
          ),
          items: values
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(item, style: const TextStyle(fontSize: 11)),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    ],
  );
  String _number(double value) => value.toStringAsFixed(2);
}

class _PurchaseLine {
  const _PurchaseLine({
    required this.srNo,
    required this.product,
    required this.quantity,
    required this.pm,
    required this.rate,
    required this.discount,
    required this.sgstRate,
    required this.cgstRate,
  });
  final int srNo;
  final String product;
  final double quantity;
  final String pm;
  final double rate;
  final double discount;
  final double sgstRate;
  final double cgstRate;
  double get amount => quantity * rate;
  double get discountRs => amount * discount / 100;
  double get taxable => amount - discountRs;
  double get sgstRs => taxable * sgstRate / 100;
  double get cgstRs => taxable * cgstRate / 100;
  double get total => taxable + sgstRs + cgstRs;
  _PurchaseLine withSrNo(int value) => _PurchaseLine(
    srNo: value,
    product: product,
    quantity: quantity,
    pm: pm,
    rate: rate,
    discount: discount,
    sgstRate: sgstRate,
    cgstRate: cgstRate,
  );
  factory _PurchaseLine.create({
    required int srNo,
    required String product,
    required double quantity,
    required String pm,
    required double rate,
    required double discount,
    required double sgstRate,
    required double cgstRate,
  }) => _PurchaseLine(
    srNo: srNo,
    product: product,
    quantity: quantity,
    pm: pm,
    rate: rate,
    discount: discount,
    sgstRate: sgstRate,
    cgstRate: cgstRate,
  );
}

class _EntryLabel extends StatelessWidget {
  const _EntryLabel(this.text, this.width);
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
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
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
    ),
  );
}

Widget _tableCell(String text, double width) => SizedBox(
  width: width,
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
    ),
  ),
);

class PurchaseOtherIntent extends Intent {
  const PurchaseOtherIntent();
}

class PurchasePrintIntent extends Intent {
  const PurchasePrintIntent();
}

class PurchaseFindIntent extends Intent {
  const PurchaseFindIntent();
}

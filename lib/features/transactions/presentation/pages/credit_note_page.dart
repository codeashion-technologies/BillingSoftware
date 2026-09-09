import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

class CreditNotePage extends StatefulWidget {
  const CreditNotePage({super.key, this.isDebit = false});

  final bool isDebit;

  @override
  State<CreditNotePage> createState() => _CreditNotePageState();
}

class _CreditNotePageState extends State<CreditNotePage> {
  final _noteNoController = TextEditingController();
  final _partyCodeController = TextEditingController();
  final _partyController = TextEditingController();
  final _debitCodeController = TextEditingController();
  final _debitController = TextEditingController();
  final _itemController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _remarksController = TextEditingController();
  final _billNoController = TextEditingController();
  final _billDateController = TextEditingController();

  DateTime _date = DateTime.now();
  String _baseOn = 'Sales';
  String _itemBase = 'No';
  String _reason = 'Sales Return';
  bool _skipGstr = false;
  String? _status;
  final List<_CreditNoteLine> _lines = [];

  String get _title => widget.isDebit ? 'Debit Note' : 'Credit Note';
  String get _noteLabel => widget.isDebit ? 'Debit Note No' : 'Credit Note No';
  String get _counterAccountLabel =>
      widget.isDebit ? 'Credit A/c' : 'Debit A/c';
  String get _baseOnDefault => widget.isDebit ? 'Purchase' : 'Sales';
  String get _reasonDefault =>
      widget.isDebit ? 'Purchase Return' : 'Sales Return';

  @override
  void initState() {
    super.initState();
    _baseOn = _baseOnDefault;
    _reason = _reasonDefault;
  }

  @override
  void dispose() {
    for (final controller in [
      _noteNoController,
      _partyCodeController,
      _partyController,
      _debitCodeController,
      _debitController,
      _itemController,
      _descriptionController,
      _amountController,
      _remarksController,
      _billNoController,
      _billDateController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  double get _total => _lines.fold(0, (sum, line) => sum + line.amount);
  double get _sgst => _total * .09;
  double get _cgst => _total * .09;
  double get _igst => 0;
  double get _withGst => _total + _sgst + _cgst + _igst;

  String _formatDate(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}-${value.month.toString().padLeft(2, '0')}-${value.year}';

  Future<void> _selectDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selected != null) setState(() => _date = selected);
  }

  void _addLine() {
    final amount = double.tryParse(_amountController.text.trim());
    if (_itemController.text.trim().isEmpty || amount == null) {
      setState(() => _status = 'Enter an item and a valid amount.');
      return;
    }
    setState(() {
      _lines.add(
        _CreditNoteLine(
          item: _itemController.text.trim(),
          description: _descriptionController.text.trim(),
          amount: amount,
        ),
      );
      _itemController.clear();
      _descriptionController.clear();
      _amountController.clear();
      _status = 'Item added.';
    });
  }

  void _reset() {
    for (final controller in [
      _noteNoController,
      _partyCodeController,
      _partyController,
      _debitCodeController,
      _debitController,
      _itemController,
      _descriptionController,
      _amountController,
      _remarksController,
      _billNoController,
      _billDateController,
    ]) {
      controller.clear();
    }
    setState(() {
      _lines.clear();
      _date = DateTime.now();
      _baseOn = _baseOnDefault;
      _itemBase = 'No';
      _reason = _reasonDefault;
      _skipGstr = false;
      _status = 'Form cleared.';
    });
  }

  void _setStatus(String message) => setState(() => _status = message);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.formBackground,
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionTitle(_title),
          const SizedBox(height: 5),
          _buildHeader(),
          const SizedBox(height: 5),
          _buildEntryRow(),
          const SizedBox(height: 5),
          Expanded(child: _buildItemTable()),
          const SizedBox(height: 5),
          _buildCalculationSection(),
          const SizedBox(height: 5),
          _buildActions(),
          if (_status != null)
            SizedBox(
              height: 16,
              child: Text(
                _status!,
                style: const TextStyle(fontSize: 11, color: AppColors.error),
              ),
            ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Container(
    height: 28,
    alignment: Alignment.center,
    color: AppColors.primary,
    child: Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 17,
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  Widget _buildHeader() => Container(
    padding: const EdgeInsets.all(6),
    decoration: BoxDecoration(
      border: Border.all(color: AppColors.border),
      color: const Color(0xFFE4E1A8),
    ),
    child: Column(
      children: [
        Row(
          children: [
            _label(_noteLabel),
            Expanded(child: _input(_noteNoController)),
            const SizedBox(width: 12),
            _label('Date'),
            Expanded(
              child: InkWell(
                onTap: _selectDate,
                child: _fieldBox(
                  '${_formatDate(_date)}   ',
                  trailing: const Icon(Icons.calendar_today, size: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            _label('Base On'),
            Expanded(
              child: _dropdown(_baseOn, ['Sales', 'Purchase'], (value) {
                setState(() => _baseOn = value!);
              }),
            ),
            const SizedBox(width: 12),
            _label('Item Base'),
            Expanded(
              child: _dropdown(_itemBase, ['No', 'Yes'], (value) {
                setState(() => _itemBase = value!);
              }),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            _label('Party A/c'),
            _smallInput(_partyCodeController),
            const SizedBox(width: 5),
            Expanded(child: _input(_partyController)),
            const SizedBox(width: 12),
            _label(_counterAccountLabel),
            _smallInput(_debitCodeController),
            const SizedBox(width: 5),
            Expanded(child: _input(_debitController)),
          ],
        ),
      ],
    ),
  );

  Widget _buildEntryRow() => Container(
    height: 38,
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
    decoration: BoxDecoration(
      border: Border.all(color: AppColors.border),
      color: AppColors.inputBackground,
    ),
    child: Row(
      children: [
        _fixedHeaderCell('Sr No', 55),
        Expanded(child: _input(_itemController, hint: 'Item Desc')),
        const SizedBox(width: 5),
        Expanded(child: _input(_descriptionController, hint: 'Desc')),
        const SizedBox(width: 5),
        SizedBox(width: 115, child: _input(_amountController, hint: 'Amount')),
        IconButton(
          onPressed: _addLine,
          tooltip: 'Add item',
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.add_circle_outline, size: 20),
        ),
      ],
    ),
  );

  Widget _buildItemTable() => Container(
    decoration: BoxDecoration(border: Border.all(color: AppColors.border)),
    child: Column(
      children: [
        Container(
          height: 28,
          color: AppColors.tableHeader,
          child: const Row(
            children: [
              _HeaderCell('Sno', 55),
              _HeaderCell('Qty', 75),
              _HeaderCell('Amount', 110),
              _HeaderCell('AYN', 65),
              _HeaderCell('DescD', null),
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
                    return SizedBox(
                      height: 26,
                      child: Row(
                        children: [
                          _tableCell('${index + 1}', 55),
                          _tableCell('1', 75),
                          _tableCell(line.amount.toStringAsFixed(2), 110),
                          _tableCell('Y', 65),
                          Expanded(child: _tableCell(line.description, null)),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    ),
  );

  Widget _buildCalculationSection() => SizedBox(
    height: 112,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 5,
          child: _boxedColumn([
            _compactField('Remarks', _remarksController),
            Row(
              children: [
                Expanded(child: _compactField('Bill No', _billNoController)),
                const SizedBox(width: 6),
                Expanded(child: _compactField('Bill Dt', _billDateController)),
              ],
            ),
            SizedBox(
              height: 24,
              child: Row(
                children: [
                  Checkbox(
                    visualDensity: VisualDensity.compact,
                    value: _skipGstr,
                    onChanged: (value) =>
                        setState(() => _skipGstr = value ?? false),
                  ),
                  const Text('Skip GSTR', style: TextStyle(fontSize: 11)),
                ],
              ),
            ),
          ]),
        ),
        const SizedBox(width: 6),
        Expanded(
          flex: 4,
          child: _boxedColumn([
            Row(
              children: [
                const SizedBox(
                  width: 76,
                  child: Text('Reason (GSTR-1)', style: _smallText),
                ),
                Expanded(
                  child: _dropdown(
                    _reason,
                    [_reasonDefault, 'Discount', 'Other'],
                    (value) {
                      setState(() => _reason = value!);
                    },
                  ),
                ),
              ],
            ),
          ]),
        ),
        const SizedBox(width: 6),
        Expanded(flex: 5, child: _buildTotals()),
      ],
    ),
  );

  Widget _buildTotals() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    decoration: BoxDecoration(
      border: Border.all(color: AppColors.border),
      color: AppColors.inputBackground,
    ),
    child: Column(
      children: [
        _totalLine('Bsic Amt', _total),
        _totalLine('With GST Amt', _withGst),
        Row(
          children: [
            Expanded(child: _totalLine('SGST', _sgst)),
            Expanded(child: _totalLine('CGST', _cgst)),
            Expanded(child: _totalLine('IGST', _igst)),
          ],
        ),
        Row(
          children: [
            Expanded(child: _totalLine('Round Off', 0)),
            Expanded(child: _totalLine('Bill Amount', _withGst)),
          ],
        ),
      ],
    ),
  );

  Widget _buildActions() => SizedBox(
    height: 32,
    child: Row(
      children: [
        _action('New', _reset),
        _action(
          'Find',
          () => _setStatus('Find ${_title.toLowerCase()}s by number or party.'),
        ),
        const Spacer(),
        _action('Save', () => _setStatus('$_title saved successfully.')),
        _action('Cancel', _reset),
        _action('Delete', () => _setStatus('Select a $_title to delete.')),
        _action(
          'Print',
          () => _setStatus('Preparing ${_title.toLowerCase()} for printing.'),
        ),
        _action('Exit', () => Navigator.maybePop(context)),
      ],
    ),
  );

  Widget _boxedColumn(List<Widget> children) => Container(
    padding: const EdgeInsets.all(5),
    decoration: BoxDecoration(
      border: Border.all(color: AppColors.border),
      color: AppColors.inputBackground,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    ),
  );

  Widget _compactField(String label, TextEditingController controller) => Row(
    children: [
      _label(label),
      Expanded(child: _input(controller)),
    ],
  );

  Widget _totalLine(String label, double value) => Padding(
    padding: const EdgeInsets.only(bottom: 1),
    child: Row(
      children: [
        Expanded(child: Text(label, style: _smallText)),
        SizedBox(
          width: 76,
          height: 18,
          child: _fieldBox(value.toStringAsFixed(2)),
        ),
      ],
    ),
  );

  Widget _action(String label, VoidCallback onPressed) => Padding(
    padding: const EdgeInsets.only(right: 5),
    child: OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        minimumSize: const Size(0, 28),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(label, style: const TextStyle(fontSize: 11)),
    ),
  );

  Widget _dropdown(
    String value,
    List<String> values,
    ValueChanged<String?> onChanged,
  ) => DropdownButtonFormField<String>(
    initialValue: value,
    isExpanded: true,
    isDense: true,
    decoration: const InputDecoration(
      border: OutlineInputBorder(),
      contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      filled: true,
      fillColor: Colors.white,
    ),
    items: values
        .map(
          (item) => DropdownMenuItem(
            value: item,
            child: Text(item, style: _smallText),
          ),
        )
        .toList(),
    onChanged: onChanged,
  );

  Widget _input(TextEditingController controller, {String? hint}) => TextField(
    controller: controller,
    style: const TextStyle(fontSize: 11),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 11),
      isDense: true,
      filled: true,
      fillColor: Colors.white,
      border: const OutlineInputBorder(),
      contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
    ),
  );

  Widget _smallInput(TextEditingController controller) =>
      SizedBox(width: 48, child: _input(controller));

  Widget _fieldBox(String value, {Widget? trailing}) => Container(
    height: 28,
    padding: const EdgeInsets.symmetric(horizontal: 6),
    alignment: Alignment.centerLeft,
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: AppColors.border),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(value, style: _smallText),
        ?trailing,
      ],
    ),
  );

  Widget _label(String label) =>
      SizedBox(width: 74, child: Text(label, style: _smallText));

  Widget _fixedHeaderCell(String label, double width) => SizedBox(
    width: width,
    child: Text(
      label,
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
    ),
  );

  Widget _tableCell(String value, double? width) {
    final child = Container(
      height: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(border: Border.all(color: AppColors.border)),
      child: Text(value, style: _smallText),
    );
    return width == null
        ? Expanded(child: child)
        : SizedBox(width: width, child: child);
  }
}

class _CreditNoteLine {
  const _CreditNoteLine({
    required this.item,
    required this.description,
    required this.amount,
  });
  final String item;
  final String description;
  final double amount;
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell(this.label, this.width);
  final String label;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
    return width == null
        ? Expanded(child: child)
        : SizedBox(width: width, child: child);
  }
}

const _smallText = TextStyle(fontSize: 11, color: AppColors.textPrimary);

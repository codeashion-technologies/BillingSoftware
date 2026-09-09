import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

class BankPaymentReceiptSplitPage extends StatelessWidget {
  const BankPaymentReceiptSplitPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.all(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PageHeader(),
          const SizedBox(height: 4),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Expanded(child: _BankPanel(isPayment: true)),
                const SizedBox(width: 4),
                const Expanded(child: _BankPanel(isPayment: false)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    height: 34,
    padding: const EdgeInsets.symmetric(horizontal: 8),
    decoration: BoxDecoration(
      color: AppColors.primary,
      border: Border.all(color: AppColors.border),
    ),
    child: const Center(
      child: Text(
        'Bank Payment & Receipt',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}

class _BankPanel extends StatefulWidget {
  const _BankPanel({required this.isPayment});
  final bool isPayment;

  @override
  State<_BankPanel> createState() => _BankPanelState();
}

class _BankPanelState extends State<_BankPanel> {
  final _voucherController = TextEditingController();
  final _chequeController = TextEditingController();
  final _narrationController = TextEditingController();
  final _narration2Controller = TextEditingController();
  final _amountController = TextEditingController();

  DateTime _date = DateTime.now();
  String _bank = 'Select bank';
  String _book = 'Select book';
  String _party = 'Select party';
  String _bill = 'Select bill';
  String _balance = '0.00';
  String _partyBalance = '0.00';
  bool _fullPagePrint = false;
  String? _message;

  bool get _isPayment => widget.isPayment;
  String get _title => _isPayment ? 'Bank Payment' : 'Bank Receipt';

  @override
  void dispose() {
    _voucherController.dispose();
    _chequeController.dispose();
    _narrationController.dispose();
    _narration2Controller.dispose();
    _amountController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')} ${_month(value.month)} ${value.year}';

  String _month(int month) => const [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][month - 1];

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _clear() {
    _voucherController.clear();
    _chequeController.clear();
    _narrationController.clear();
    _narration2Controller.clear();
    _amountController.clear();
    setState(() {
      _bank = 'Select bank';
      _book = 'Select book';
      _party = 'Select party';
      _bill = 'Select bill';
      _balance = '0.00';
      _partyBalance = '0.00';
      _message = 'Form cleared';
    });
  }

  void _setMessage(String message) => setState(() => _message = message);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.formBackground,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _panelHeader(),
          Expanded(child: _panelBody()),
        ],
      ),
    );
  }

  Widget _panelHeader() => Container(
    height: 30,
    alignment: Alignment.center,
    color: AppColors.primary,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );

  Widget _panelBody() => Padding(
    padding: const EdgeInsets.all(8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionLabel('Voucher details'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _textField('Voucher No', _voucherController)),
            const SizedBox(width: 9),
            Expanded(child: _dateField()),
          ],
        ),
        const SizedBox(height: 7),
        _sectionLabel('Payment details'),
        const SizedBox(height: 5),
        Row(
          children: [
            Expanded(
              child: _selectField(
                'Bank',
                _bank,
                ['HDFC', 'ICICI', 'SBI', 'Axis'],
                (value) {
                  setState(() {
                    _bank = value!;
                    _balance = '12,500.00';
                  });
                },
              ),
            ),
            const SizedBox(width: 9),
            Expanded(child: _readOnlyField('Balance', _balance)),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: _selectField('Book', _book, [
                'Cash Book',
                'Sales Book',
                'Bank Book',
              ], (value) => setState(() => _book = value!)),
            ),
            const SizedBox(width: 9),
            Expanded(child: _readOnlyField('Party Balance', _partyBalance)),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: _selectField(
                'Party',
                _party,
                ['Alpha Traders', 'Beta Industries', 'Gamma Supplies'],
                (value) {
                  setState(() {
                    _party = value!;
                    _partyBalance = '25,000.00';
                  });
                },
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: _textField('Amount', _amountController, number: true),
            ),
          ],
        ),
        const SizedBox(height: 5),
        _textField('Cheque / DD No', _chequeController),
        const SizedBox(height: 5),
        _textField('Narration', _narrationController),
        const SizedBox(height: 5),
        Row(
          children: [
            Expanded(
              child: _selectField('Bill', _bill, [
                'BILL-1001',
                'BILL-1002',
                'BILL-1003',
              ], (value) => setState(() => _bill = value!)),
            ),
            const SizedBox(width: 9),
            Expanded(child: _textField('Narration 2', _narration2Controller)),
          ],
        ),
        const SizedBox(height: 7),
        _sectionLabel('Transaction details'),
        const SizedBox(height: 5),
        Expanded(child: _transactionTable()),
        const SizedBox(height: 5),
        _actionBar(),
        if (_message != null) ...[
          const SizedBox(height: 4),
          Text(
            _message!,
            style: const TextStyle(color: AppColors.primary, fontSize: 11),
          ),
        ],
      ],
    ),
  );

  Widget _transactionTable() => Container(
    decoration: BoxDecoration(
      color: AppColors.tableBackground,
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      children: [
        Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          color: AppColors.tableHeader,
          child: const Row(
            children: [
              _TableHeader('Sr No', 48),
              _TableHeader('Cheque / DD No', 100),
              _TableHeader('Party', null),
              _TableHeader('Amount', 78, alignRight: true),
            ],
          ),
        ),
        const Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  color: Color(0xFFB9C0C2),
                  size: 20,
                ),
                SizedBox(height: 2),
                Text(
                  'No transactions yet',
                  style: TextStyle(
                    color: Color(0xFFE4E6E6),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 1),
                Text(
                  'Entries will appear here',
                  style: TextStyle(color: Color(0xFFC5CBCC), fontSize: 9),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Widget _actionBar() => SizedBox(
    height: 42,
    child: Wrap(
      spacing: 5,
      runSpacing: 5,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _button('Clear', Icons.refresh_rounded, _clear),
        _button(
          'Modify',
          Icons.edit_outlined,
          () => _setMessage('Select a voucher to modify'),
        ),
        _button(
          'Delete',
          Icons.delete_outline,
          () => _setMessage('Select a voucher to delete'),
          destructive: true,
        ),
        _button('New', Icons.add_rounded, _clear, primary: true),
        _button(
          'Find (F7)',
          Icons.search_rounded,
          () => _setMessage('Search vouchers'),
        ),
        _button('Cancel', Icons.close_rounded, _clear),
        _button(
          'Print (F3)',
          Icons.print_outlined,
          () => _setMessage('Preparing print preview'),
        ),
        _button(
          'Voucher',
          Icons.receipt_long_outlined,
          () => _setMessage('Voucher view opened'),
        ),
        _button(
          'Exit',
          Icons.logout_rounded,
          () => Navigator.maybePop(context),
        ),
        _button(
          'Voucher Amount',
          Icons.calculate_outlined,
          () => _setMessage('Voucher amount: 0.00'),
        ),
        FilterChip(
          label: const Text('Full Page Print', style: TextStyle(fontSize: 10)),
          selected: _fullPagePrint,
          onSelected: (value) => setState(() => _fullPagePrint = value),
          avatar: const Icon(Icons.check_box_outlined, size: 15),
          padding: const EdgeInsets.symmetric(horizontal: 3),
          visualDensity: VisualDensity.compact,
        ),
      ],
    ),
  );

  Widget _button(
    String label,
    IconData icon,
    VoidCallback onPressed, {
    bool primary = false,
    bool destructive = false,
  }) => OutlinedButton.icon(
    onPressed: onPressed,
    icon: Icon(icon, size: 14),
    label: Text(label, style: const TextStyle(fontSize: 9)),
    style: OutlinedButton.styleFrom(
      foregroundColor: destructive
          ? const Color(0xFFB44955)
          : primary
          ? Colors.white
          : const Color(0xFF49616A),
      backgroundColor: primary ? AppColors.primary : AppColors.inputBackground,
      side: BorderSide(
        color: destructive
            ? const Color(0xFFE5B8BD)
            : primary
            ? AppColors.primary
            : AppColors.border,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      minimumSize: const Size(0, 28),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    ),
  );

  Widget _sectionLabel(String label) => Text(
    label,
    style: const TextStyle(
      color: AppColors.textPrimary,
      fontSize: 10,
      fontWeight: FontWeight.w800,
      letterSpacing: .8,
    ),
  );

  Widget _textField(
    String label,
    TextEditingController controller, {
    bool number = false,
  }) => _labeled(
    label,
    TextField(
      controller: controller,
      keyboardType: number ? TextInputType.number : TextInputType.text,
      style: const TextStyle(fontSize: 12, color: Color(0xFF263B44)),
      decoration: _inputDecoration(),
    ),
  );

  Widget _dateField() => _labeled(
    'Date',
    InkWell(
      onTap: _selectDate,
      borderRadius: BorderRadius.circular(9),
      child: _valueBox(
        _formatDate(_date),
        const Icon(
          Icons.calendar_today_outlined,
          size: 15,
          color: AppColors.primary,
        ),
      ),
    ),
  );

  Widget _selectField(
    String label,
    String value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) => _labeled(
    label,
    DropdownButtonFormField<String>(
      initialValue: options.contains(value) ? value : null,
      isExpanded: true,
      icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
      style: const TextStyle(fontSize: 12, color: Color(0xFF263B44)),
      decoration: _inputDecoration(),
      items: options
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
    ),
  );

  Widget _readOnlyField(String label, String value) =>
      _labeled(label, _valueBox(value, null));

  Widget _labeled(String label, Widget child) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 2, bottom: 2),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      child,
    ],
  );

  InputDecoration _inputDecoration() => InputDecoration(
    isDense: true,
    filled: true,
    fillColor: AppColors.inputBackground,
    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    border: const OutlineInputBorder(
      borderRadius: BorderRadius.zero,
      borderSide: BorderSide(color: AppColors.border),
    ),
    enabledBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.zero,
      borderSide: BorderSide(color: AppColors.border),
    ),
    focusedBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.zero,
      borderSide: BorderSide(color: AppColors.primary, width: 1.3),
    ),
  );

  Widget _valueBox(String value, Widget? trailing) => Container(
    height: 28,
    padding: const EdgeInsets.symmetric(horizontal: 10),
    decoration: BoxDecoration(
      color: AppColors.inputBackground,
      border: Border.all(color: AppColors.border),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12, color: Color(0xFF263B44)),
          ),
        ),
        ?trailing,
      ],
    ),
  );
}

class _TableHeader extends StatelessWidget {
  const _TableHeader(this.label, this.width, {this.alignRight = false});
  final String label;
  final double? width;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    final child = Align(
      alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
    return width == null
        ? Expanded(child: child)
        : SizedBox(width: width, child: child);
  }
}

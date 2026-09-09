import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

class CashPaymentReceiptSplitPage extends StatelessWidget {
  const CashPaymentReceiptSplitPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 36,
              color: AppColors.primary,
              alignment: Alignment.center,
              child: const Text(
                'Cash Payment & Receipt',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: _buildPanel(
                      title: 'Cash Payment',
                      child: const _CashPaymentPanel(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildPanel(
                      title: 'Cash Receipt',
                      child: const _CashReceiptPanel(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPanel({required String title, required Widget child}) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 30,
            alignment: Alignment.center,
            color: AppColors.primary,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _CashPaymentPanel extends StatefulWidget {
  const _CashPaymentPanel();

  @override
  State<_CashPaymentPanel> createState() => _CashPaymentPanelState();
}

class _CashPaymentPanelState extends State<_CashPaymentPanel> {
  final TextEditingController _voucherNoController = TextEditingController();
  final TextEditingController _bankController = TextEditingController();
  final TextEditingController _bookController = TextEditingController();
  final TextEditingController _narration2Controller = TextEditingController();
  final TextEditingController _srNoController = TextEditingController();
  final TextEditingController _partyController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _narrationController = TextEditingController();
  final TextEditingController _billController = TextEditingController();

  String _selectedBank = 'Bank';
  String _selectedBook = 'Book';
  String _selectedParty = 'Party';
  String _selectedBill = 'Bill';
  String _balance = '0.00';
  String _partyBalance = '0.00';
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _voucherNoController.dispose();
    _bankController.dispose();
    _bookController.dispose();
    _narration2Controller.dispose();
    _srNoController.dispose();
    _partyController.dispose();
    _amountController.dispose();
    _narrationController.dispose();
    _billController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final dd = date.day.toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    return '$dd-$mm-${date.year}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE4E1A8),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _textField('Voucher No', 150, _voucherNoController),
              const SizedBox(width: 12),
              _dateField('Date', 200),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              _selectField('Bank', 210, _selectedBank, _bankOptions(), (value) {
                setState(() => _selectedBank = value ?? 'Bank');
                _balance = '12500.00';
              }),
              _readOnlyField('Balance', 170, _balance),
              _selectField('Book', 210, _selectedBook, _bookOptions(), (value) {
                setState(() => _selectedBook = value ?? 'Book');
              }),
              _textField('Narration 2', 210, _narration2Controller),
              _textField('Sr No', 150, _srNoController),
              _readOnlyField('Party Balance', 170, _partyBalance),
              _selectField('Party', 220, _selectedParty, _partyOptions(), (
                value,
              ) {
                setState(() => _selectedParty = value ?? 'Party');
                _partyBalance = '25000.00';
              }),
              _numberField('Amount', 160, _amountController),
              _textField('Narration', 210, _narrationController),
              _selectField('Bill', 180, _selectedBill, _billOptions(), (value) {
                setState(() => _selectedBill = value ?? 'Bill');
              }),
            ],
          ),
          const SizedBox(height: 10),
          const _DetailTable(title: 'Payment Details'),
          const SizedBox(height: 8),
          _bottomTotalRow(label: 'Total Payment Amount :', value: '0.00'),
          const SizedBox(height: 8),
          _bottomActionRow(),
        ],
      ),
    );
  }

  List<String> _bankOptions() => ['HDFC', 'ICICI', 'SBI', 'Cash', 'Axis'];
  List<String> _bookOptions() => [
    'Sales Book',
    'Purchase Book',
    'Cash Book',
    'Bank Book',
  ];
  List<String> _partyOptions() => [
    'Alpha Traders',
    'Beta Industries',
    'Gamma Supplies',
  ];
  List<String> _billOptions() => ['BILL-1001', 'BILL-1002', 'BILL-1003'];

  Widget _bottomActionRow() => Container(
    padding: const EdgeInsets.only(top: 4),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _actionButton('New', Icons.add),
          _actionButton('Find', Icons.search),
          _actionButton('Cancel', Icons.cancel_outlined),
          _actionButton('Print', Icons.print_outlined),
          _actionButton('Exit', Icons.exit_to_app),
          const SizedBox(width: 12),
          _actionButton('Vou Amount', Icons.calculate_outlined),
        ],
      ),
    ),
  );

  Widget _bottomTotalRow({required String label, required String value}) => Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      Text(
        label,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
      const SizedBox(width: 10),
      Container(
        width: 120,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          value,
          style: const TextStyle(
            color: AppColors.error,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ],
  );

  Widget _dateField(String label, double width) => SizedBox(
    width: width,
    child: Row(
      children: [
        SizedBox(
          width: 78,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Expanded(
          child: InkWell(
            onTap: _pickDate,
            child: Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(_selectedDate),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Icon(Icons.calendar_today, size: 14),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _textField(
    String label,
    double width,
    TextEditingController controller,
  ) => SizedBox(
    width: width,
    child: Row(
      children: [
        SizedBox(
          width: 78,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Expanded(
          child: TextField(
            controller: controller,
            textAlignVertical: TextAlignVertical.center,
            decoration: const InputDecoration(
              isDense: true,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _numberField(
    String label,
    double width,
    TextEditingController controller,
  ) => SizedBox(
    width: width,
    child: Row(
      children: [
        SizedBox(
          width: 78,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlignVertical: TextAlignVertical.center,
            decoration: const InputDecoration(
              isDense: true,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _selectField(
    String label,
    double width,
    String value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) => SizedBox(
    width: width,
    child: Row(
      children: [
        SizedBox(
          width: 78,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: options.contains(value) ? value : null,
            isExpanded: true,
            decoration: const InputDecoration(
              isDense: true,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            ),
            items: options
                .map(
                  (option) => DropdownMenuItem<String>(
                    value: option,
                    child: Text(option, style: const TextStyle(fontSize: 12)),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    ),
  );

  Widget _readOnlyField(String label, double width, String value) => SizedBox(
    width: width,
    child: Row(
      children: [
        SizedBox(
          width: 78,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _actionButton(String label, IconData icon) => Padding(
    padding: const EdgeInsets.only(right: 6),
    child: OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 15),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        minimumSize: const Size(0, 26),
      ),
    ),
  );
}

class _CashReceiptPanel extends StatefulWidget {
  const _CashReceiptPanel();

  @override
  State<_CashReceiptPanel> createState() => _CashReceiptPanelState();
}



class _CashReceiptPanelState extends State<_CashReceiptPanel> {
  final TextEditingController _voucherNoController = TextEditingController();
  final TextEditingController _srNoController = TextEditingController();
  final TextEditingController _partyController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _narrationController = TextEditingController();
  final TextEditingController _billController = TextEditingController();
  final TextEditingController _cashController = TextEditingController();
  final TextEditingController _bookController = TextEditingController();
  final TextEditingController _narration2Controller = TextEditingController();

  String _selectedParty = 'Party';
  String _selectedCash = 'Cash';
  String _selectedBook = 'Book';
  String _selectedBill = 'Bill';
  String _partyBalance = '0.00';
  String _cashBalance = '0.00';
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _voucherNoController.dispose();
    _srNoController.dispose();
    _partyController.dispose();
    _amountController.dispose();
    _narrationController.dispose();
    _billController.dispose();
    _cashController.dispose();
    _bookController.dispose();
    _narration2Controller.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final dd = date.day.toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    return '$dd-$mm-${date.year}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE4E1A8),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _textField('Voucher No', 150, _voucherNoController),
              const SizedBox(width: 12),
              _dateField('Date', 200),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              _textField('Sr No', 150, _srNoController),
              _readOnlyField('Party Balance', 170, _partyBalance),
              _selectField('Party', 220, _selectedParty, _partyOptions(), (
                value,
              ) {
                setState(() => _selectedParty = value ?? 'Party');
                _partyBalance = '18000.00';
              }),
              _numberField('Amount', 160, _amountController),
              _textField('Narration', 210, _narrationController),
              _selectField('Bill', 180, _selectedBill, _billOptions(), (value) {
                setState(() => _selectedBill = value ?? 'Bill');
              }),
              _selectField('Cash', 210, _selectedCash, _cashOptions(), (value) {
                setState(() => _selectedCash = value ?? 'Cash');
                _cashBalance = '54000.00';
              }),
              _readOnlyField('Balance', 170, _cashBalance),
              _selectField('Book', 210, _selectedBook, _bookOptions(), (value) {
                setState(() => _selectedBook = value ?? 'Book');
              }),
              _textField('Narration 2', 210, _narration2Controller),
            ],
          ),
          const SizedBox(height: 10),
          const _DetailTable(title: 'Receipt Details'),
          const SizedBox(height: 8),
          _bottomTotalRow(label: 'Total Receipt Amount :', value: '0.00'),
          const SizedBox(height: 8),
          _bottomActionRow(),
        ],
      ),
    );
  }

  List<String> _partyOptions() => [
    'Alpha Traders',
    'Beta Industries',
    'Gamma Supplies',
  ];
  List<String> _billOptions() => ['BILL-2001', 'BILL-2002', 'BILL-2003'];
  List<String> _cashOptions() => ['Cash in Hand', 'Bank', 'Petty Cash'];
  List<String> _bookOptions() => ['Cash Book', 'Sales Book', 'Bank Book'];

  Widget _bottomActionRow() => Container(
    padding: const EdgeInsets.only(top: 4),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _actionButton('New', Icons.add),
          _actionButton('Find', Icons.search),
          _actionButton('Cancel', Icons.cancel_outlined),
          _actionButton('Print', Icons.print_outlined),
          _actionButton('Exit', Icons.exit_to_app),
          const SizedBox(width: 12),
          _actionButton('Vou Amount', Icons.calculate_outlined),
        ],
      ),
    ),
  );

  Widget _bottomTotalRow({required String label, required String value}) => Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      Text(
        label,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
      const SizedBox(width: 10),
      Container(
        width: 120,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          value,
          style: const TextStyle(
            color: AppColors.error,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ],
  );

  Widget _dateField(String label, double width) => SizedBox(
    width: width,
    child: Row(
      children: [
        SizedBox(
          width: 78,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Expanded(
          child: InkWell(
            onTap: _pickDate,
            child: Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(_selectedDate),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Icon(Icons.calendar_today, size: 14),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _textField(
    String label,
    double width,
    TextEditingController controller,
  ) => SizedBox(
    width: width,
    child: Row(
      children: [
        SizedBox(
          width: 78,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Expanded(
          child: TextField(
            controller: controller,
            textAlignVertical: TextAlignVertical.center,
            decoration: const InputDecoration(
              isDense: true,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _numberField(
    String label,
    double width,
    TextEditingController controller,
  ) => SizedBox(
    width: width,
    child: Row(
      children: [
        SizedBox(
          width: 78,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlignVertical: TextAlignVertical.center,
            decoration: const InputDecoration(
              isDense: true,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _selectField(
    String label,
    double width,
    String value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) => SizedBox(
    width: width,
    child: Row(
      children: [
        SizedBox(
          width: 78,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: options.contains(value) ? value : null,
            isExpanded: true,
            decoration: const InputDecoration(
              isDense: true,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            ),
            items: options
                .map(
                  (option) => DropdownMenuItem<String>(
                    value: option,
                    child: Text(option, style: const TextStyle(fontSize: 12)),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    ),
  );

  Widget _readOnlyField(String label, double width, String value) => SizedBox(
    width: width,
    child: Row(
      children: [
        SizedBox(
          width: 78,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _actionButton(String label, IconData icon) => Padding(
    padding: const EdgeInsets.only(right: 6),
    child: OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 15),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        minimumSize: const Size(0, 26),
      ),
    ),
  );
}

class _InputMatrix extends StatelessWidget {
  const _InputMatrix();

  @override
  Widget build(BuildContext context) {
    final rows = [
      ['Cr. {jmi}', 'Dr. {uFir}', 'Cr. {jmi}', 'Dr. {uFir}'],
      ['Bank', 'Balance', 'Smo', 'Party Balance', 'Smo', 'Party Balance'],
      ['Book', 'Party', 'Amount', 'Receipt No', 'Book', 'Party'],
      ['Narration 2', 'Narration', 'Bill', 'Narration', 'Bill'],
    ];

    return Container(
      decoration: BoxDecoration(border: Border.all(color: AppColors.border)),
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++)
            Row(
              children: [
                for (int j = 0; j < rows[i].length; j++)
                  Expanded(
                    child: Container(
                      height: i == 0 ? 34 : 45,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(color: AppColors.border),
                          bottom: BorderSide(color: AppColors.border),
                        ),
                        color: i == 1 && j.isEven
                            ? const Color(0xFFE0D9EF)
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          rows[i][j],
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _DetailTable extends StatelessWidget {
  const _DetailTable({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final headers = ['Sr No', 'Account Name', 'Amount', 'Narration', 'Bill No'];
    return Container(
      decoration: BoxDecoration(border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 22,
            color: AppColors.tableHeader,
            child: Row(
              children: headers
                  .map(
                    (header) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          header,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          Container(
            height: 160,
            color: AppColors.inputBackground,
            child: const Center(
              child: Text('', style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}

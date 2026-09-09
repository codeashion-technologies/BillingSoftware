import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

class JobWorkIssuePage extends StatefulWidget {
  const JobWorkIssuePage({super.key});

  @override
  State<JobWorkIssuePage> createState() => _JobWorkIssuePageState();
}

class _JobWorkIssuePageState extends State<JobWorkIssuePage> {
  final _receiveDateController = TextEditingController();
  final _greyMetersController = TextEditingController();
  final _finishMetersController = TextEditingController();
  final _weightController = TextEditingController();
  final _markaController = TextEditingController();
  final _colourController = TextEditingController();
  final _shortLongController = TextEditingController();
  final _percentController = TextEditingController();
  final _finController = TextEditingController();
  final _amountController = TextEditingController();
  final _returnController = TextEditingController();
  final _finishFocusNode = FocusNode();
  final _weightFocusNode = FocusNode();
  final _markaFocusNode = FocusNode();
  final _colourFocusNode = FocusNode();
  final _shortLongFocusNode = FocusNode();
  final _percentFocusNode = FocusNode();
  final _finFocusNode = FocusNode();
  final _amountFocusNode = FocusNode();
  final _returnFocusNode = FocusNode();
  final _greyMetersFocusNode = FocusNode();

  final List<_IssueDetail> _details = [];
  DateTime _receiveDate = DateTime.now();
  int? _selectedRow;
  String? _message;
  bool _onlyPending = false;
  bool _jobCard = false;
  bool _special = false;

  double get _totalGreyMeters =>
      _details.fold(0, (sum, row) => sum + row.greyMeters);
  double get _totalFinishMeters =>
      _details.fold(0, (sum, row) => sum + row.finishMeters);
  double get _totalWeight => _details.fold(0, (sum, row) => sum + row.weight);

  @override
  void initState() {
    super.initState();
    _setDate(_receiveDateController, _receiveDate);
  }

  @override
  void dispose() {
    _receiveDateController.dispose();
    for (final controller in [
      _greyMetersController,
      _finishMetersController,
      _weightController,
      _markaController,
      _colourController,
      _shortLongController,
      _percentController,
      _finController,
      _amountController,
      _returnController,
    ]) {
      controller.dispose();
    }
    for (final node in [
      _finishFocusNode,
      _weightFocusNode,
      _markaFocusNode,
      _colourFocusNode,
      _shortLongFocusNode,
      _percentFocusNode,
      _finFocusNode,
      _amountFocusNode,
      _returnFocusNode,
      _greyMetersFocusNode,
    ]) {
      node.dispose();
    }
    super.dispose();
  }

  void _setDate(TextEditingController controller, DateTime date) {
    controller.text =
        '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  Future<void> _pickReceiveDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _receiveDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _receiveDate = picked;
      _setDate(_receiveDateController, picked);
    });
  }

  void _addDetail() {
    final greyText = _greyMetersController.text.trim();
    final finishText = _finishMetersController.text.trim();
    final weightText = _weightController.text.trim();
    final greyMeters = double.tryParse(greyText);
    final finishMeters = finishText.isEmpty ? 0.0 : double.tryParse(finishText);
    final weight = weightText.isEmpty ? 0.0 : double.tryParse(weightText);
    if (greyMeters == null) {
      setState(() => _message = 'Enter valid grey meters');
      _greyMetersFocusNode.requestFocus();
      return;
    }
    if (finishMeters == null) {
      setState(() => _message = 'Enter valid finish meters');
      _finishFocusNode.requestFocus();
      return;
    }
    if (weight == null) {
      setState(() => _message = 'Enter valid weight');
      _weightFocusNode.requestFocus();
      return;
    }
    setState(() {
      _details.add(
        _IssueDetail(
          serialNo: _details.length + 1,
          greyMeters: greyMeters,
          finishMeters: finishMeters,
          weight: weight,
          marka: _markaController.text.trim(),
          colour: _colourController.text.trim(),
          shortLong: _shortLongController.text.trim(),
          percent: _percentController.text.trim(),
          fin: _finController.text.trim(),
          amount: _amountController.text.trim(),
          returnValue: _returnController.text.trim(),
        ),
      );
      for (final controller in [
        _greyMetersController,
        _finishMetersController,
        _weightController,
        _markaController,
        _colourController,
        _shortLongController,
        _percentController,
        _finController,
        _amountController,
        _returnController,
      ]) {
        controller.clear();
      }
      _selectedRow = null;
      _message = 'Detail added';
    });
    _greyMetersFocusNode.requestFocus();
  }

  void _deleteSelected() {
    if (_selectedRow == null) {
      setState(() => _message = 'Select a detail row to delete');
      return;
    }
    setState(() {
      _details.removeAt(_selectedRow!);
      for (var index = 0; index < _details.length; index++) {
        _details[index] = _details[index].copyWith(serialNo: index + 1);
      }
      _selectedRow = null;
      _message = 'Detail deleted';
    });
  }

  void _newTransaction() {
    for (final controller in [
      _greyMetersController,
      _finishMetersController,
      _weightController,
      _markaController,
      _colourController,
      _shortLongController,
      _percentController,
      _finController,
      _amountController,
      _returnController,
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
    _greyMetersFocusNode.requestFocus();
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
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.formBackground,
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _section('ISSUE HEADER / DETAILS'),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 10,
                  runSpacing: 3,
                  children: [
                    _headerField('Book', 190),
                    _headerField('Party Bal.', 155),
                    _headerField('Stock Bal.', 155),
                    _headerField('Issue Challan No.', 205),
                    _headerField('Mill Party', 190),
                    _headerField('Delivery / Deli', 180),
                    _headerDateField(),
                    _headerField('Broker', 180),
                    _headerField('Cr. Days', 145),
                    _headerField('L.R No', 150),
                    _headerField('Tampo No', 160),
                    _headerField('Transport', 190),
                    _headerField('Our Lot No (F7)', 190),
                    _headerField('Party No', 150),
                    _headerField('Rec. Quality', 190),
                    _headerField('Fin. Quality', 190),
                    _headerField('Rate', 140),
                  ],
                ),
                const SizedBox(height: 5),
                _section('ISSUE DETAIL ENTRY'),
                const SizedBox(height: 4),
                _entryRow(),
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
      'JOB WORK ISSUE FROM MILL',
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

  Widget _headerField(String label, double width) =>
      SizedBox(width: width, child: _labelledField(label));

  Widget _headerDateField() => SizedBox(
    width: 180,
    child: Row(
      children: [
        const SizedBox(
          width: 76,
          child: Text(
            'Receive Date',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: InkWell(
            onTap: _pickReceiveDate,
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
                      _receiveDateController.text,
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

  Widget _entryRow() => Row(
    children: [
      _readOnlySerial(),
      _entryField(
        'Grey Mtrs',
        _greyMetersController,
        _greyMetersFocusNode,
        (_) => _finishFocusNode.requestFocus(),
      ),
      _entryField(
        'Finish Mtrs',
        _finishMetersController,
        _finishFocusNode,
        (_) => _weightFocusNode.requestFocus(),
      ),
      _entryField(
        'Weight',
        _weightController,
        _weightFocusNode,
        (_) => _markaFocusNode.requestFocus(),
      ),
      _entryField(
        'Marka',
        _markaController,
        _markaFocusNode,
        (_) => _colourFocusNode.requestFocus(),
      ),
      _entryField(
        'Colour',
        _colourController,
        _colourFocusNode,
        (_) => _shortLongFocusNode.requestFocus(),
      ),
      _entryField(
        'Short / Long',
        _shortLongController,
        _shortLongFocusNode,
        (_) => _percentFocusNode.requestFocus(),
      ),
      _entryField(
        '%',
        _percentController,
        _percentFocusNode,
        (_) => _finFocusNode.requestFocus(),
      ),
      _entryField(
        'Fin.',
        _finController,
        _finFocusNode,
        (_) => _amountFocusNode.requestFocus(),
      ),
      _entryField(
        'Amount',
        _amountController,
        _amountFocusNode,
        (_) => _returnFocusNode.requestFocus(),
      ),
      _entryField(
        'Return',
        _returnController,
        _returnFocusNode,
        (_) => _addDetail(),
      ),
    ],
  );

  Widget _readOnlySerial() => SizedBox(
    width: 70,
    child: _labelledField(
      'Sr No',
      value: '${_details.length + 1}',
      readOnly: true,
    ),
  );

  Widget _entryField(
    String label,
    TextEditingController controller,
    FocusNode focusNode,
    ValueChanged<String> onSubmitted,
  ) => Expanded(
    child: _labelledField(
      label,
      controller: controller,
      focusNode: focusNode,
      onSubmitted: onSubmitted,
    ),
  );

  Widget _labelledField(
    String label, {
    TextEditingController? controller,
    FocusNode? focusNode,
    String? value,
    bool readOnly = false,
    ValueChanged<String>? onSubmitted,
  }) => SizedBox(
    height: 23,
    child: Row(
      children: [
        SizedBox(
          width: 58,
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
            style: const TextStyle(fontSize: 10),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: readOnly
                  ? AppColors.header
                  : AppColors.inputBackground,
              hintText: value,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 4,
              ),
            ),
          ),
        ),
      ],
    ),
  );

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
              _TableHeader('Sr No', 42),
              _TableHeader('Grey Mtrs', 66),
              _TableHeader('Finish Mtrs', 72),
              _TableHeader('Weight', 62),
              _TableHeader('Marka', 65),
              _TableHeader('Colour', 65),
              _TableHeader('Short/Long', 72),
              _TableHeader('%', 35),
              _TableHeader('Fin.', 38),
              _TableHeader('Amount', 62),
              _TableHeader('Return', 58),
            ],
          ),
        ),
        Expanded(
          child: _details.isEmpty
              ? const Center(
                  child: Text(
                    'Enter issue detail to add it here',
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
                            _TableData('${row.serialNo}', 42),
                            _TableData(_number(row.greyMeters), 66),
                            _TableData(_number(row.finishMeters), 72),
                            _TableData(_number(row.weight), 62),
                            _TableData(row.marka, 65),
                            _TableData(row.colour, 65),
                            _TableData(row.shortLong, 72),
                            _TableData(row.percent, 35),
                            _TableData(row.fin, 38),
                            _TableData(row.amount, 62),
                            _TableData(row.returnValue, 58),
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
            _fieldRow([_field('Desc (F9)'), _field('Gross Amt.')]),
            const SizedBox(height: 3),
            _fieldRow([_field('Disc %'), _field('T.D.S. Rate')]),
          ],
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        flex: 2,
        child: Column(
          children: [
            _totalField('Grey Mtrs.', _number(_totalGreyMeters)),
            const SizedBox(height: 3),
            _fieldRow([
              Expanded(
                child: _totalField('Finish Mtrs.', _number(_totalFinishMeters)),
              ),
              Expanded(child: _totalField('Weight', _number(_totalWeight))),
            ]),
          ],
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        flex: 2,
        child: Column(
          children: [
            _totalField('Bill Amount', '0.00'),
            const SizedBox(height: 3),
            _fieldRow([_field('Print Type'), const Spacer()]),
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

  Widget _fieldRow(List<Widget> children) => Row(children: children);
  Widget _field(String label) => Expanded(child: _labelledField(label));
  Widget _totalField(String label, String value) =>
      _labelledField(label, value: value, readOnly: true);

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
            SizedBox(
              width: 70,
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
              onPressed: label == 'New'
                  ? _newTransaction
                  : label == 'Delete'
                  ? _deleteSelected
                  : () => setState(() => _message = '$label selected'),
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

class _IssueDetail {
  const _IssueDetail({
    required this.serialNo,
    required this.greyMeters,
    required this.finishMeters,
    required this.weight,
    required this.marka,
    required this.colour,
    required this.shortLong,
    required this.percent,
    required this.fin,
    required this.amount,
    required this.returnValue,
  });

  final int serialNo;
  final double greyMeters;
  final double finishMeters;
  final double weight;
  final String marka;
  final String colour;
  final String shortLong;
  final String percent;
  final String fin;
  final String amount;
  final String returnValue;

  _IssueDetail copyWith({int? serialNo}) => _IssueDetail(
    serialNo: serialNo ?? this.serialNo,
    greyMeters: greyMeters,
    finishMeters: finishMeters,
    weight: weight,
    marka: marka,
    colour: colour,
    shortLong: shortLong,
    percent: percent,
    fin: fin,
    amount: amount,
    returnValue: returnValue,
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
    ),
  );
}

class _TableData extends StatelessWidget {
  const _TableData(this.text, this.width);
  final String text;
  final double width;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 10),
      ),
    ),
  );
}

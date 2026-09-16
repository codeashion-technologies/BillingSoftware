import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/services/firm_session.dart';
import '../../../../core/services/item_service.dart';
import '../../../../shared/models/item.dart';
import '../widgets/item_dialogs.dart';

class ItemMasterPage extends StatefulWidget {
  const ItemMasterPage({super.key});

  @override
  State<ItemMasterPage> createState() => _ItemMasterPageState();
}

class _ItemMasterPageState extends State<ItemMasterPage> {
  final _itemCodeController = TextEditingController();
  final _itemNameController = TextEditingController();
  final _itemGroupController = TextEditingController();
  final _subGroupController = TextEditingController();
  final _mfgByController = TextEditingController();
  final _unitOfMeasureController = TextEditingController(text: 'PCS');
  final _rateRetailController = TextEditingController();
  final _dealerRateController = TextEditingController();
  final _purchaseRateController = TextEditingController();
  final _mrpController = TextEditingController();
  final _cutAverageController = TextEditingController();
  final _boxPackController = TextEditingController();
  final _looseQtyController = TextEditingController();
  final _hsnCodeController = TextEditingController();
  final _sgstController = TextEditingController();
  final _cgstController = TextEditingController();
  final _igstController = TextEditingController();
  final _gstCalculationController = TextEditingController(text: 'Taxable');
  final _hsnDescriptionController = TextEditingController();
  final _hsnUqcController = TextEditingController();
  final _rolMinController = TextEditingController();
  final _rolMaxController = TextEditingController();
  final _openingStockQtyController = TextEditingController();
  final _openingStockAmountController = TextEditingController();
  final _openingStockNosController = TextEditingController();
  final _calculateOnController = TextEditingController(text: 'Mtrs');
  final _discountController = TextEditingController();
  final _remarksController = TextEditingController();

  String _stockType = 'F';
  String _rateUpdate = 'Y';
  String _showInStockReport = 'Y';
  String _active = 'Y';

  String? _statusMessage;
  bool _isErrorStatus = false;

  @override
  void dispose() {
    _itemCodeController.dispose();
    _itemNameController.dispose();
    _itemGroupController.dispose();
    _subGroupController.dispose();
    _mfgByController.dispose();
    _unitOfMeasureController.dispose();
    _rateRetailController.dispose();
    _dealerRateController.dispose();
    _purchaseRateController.dispose();
    _mrpController.dispose();
    _cutAverageController.dispose();
    _boxPackController.dispose();
    _looseQtyController.dispose();
    _hsnCodeController.dispose();
    _sgstController.dispose();
    _cgstController.dispose();
    _igstController.dispose();
    _gstCalculationController.dispose();
    _hsnDescriptionController.dispose();
    _hsnUqcController.dispose();
    _rolMinController.dispose();
    _rolMaxController.dispose();
    _openingStockQtyController.dispose();
    _openingStockAmountController.dispose();
    _openingStockNosController.dispose();
    _calculateOnController.dispose();
    _discountController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _setStatus(String message, bool isError) {
    setState(() {
      _statusMessage = message;
      _isErrorStatus = isError;
    });
  }

  void _resetForm() {
    _itemCodeController.clear();
    _itemNameController.clear();
    _itemGroupController.clear();
    _subGroupController.clear();
    _mfgByController.clear();
    _unitOfMeasureController.text = 'PCS';
    _rateRetailController.clear();
    _dealerRateController.clear();
    _purchaseRateController.clear();
    _mrpController.clear();
    _cutAverageController.clear();
    _boxPackController.clear();
    _looseQtyController.clear();
    _hsnCodeController.clear();
    _sgstController.clear();
    _cgstController.clear();
    _igstController.clear();
    _gstCalculationController.text = 'Taxable';
    _hsnDescriptionController.clear();
    _hsnUqcController.clear();
    _rolMinController.clear();
    _rolMaxController.clear();
    _openingStockQtyController.clear();
    _openingStockAmountController.clear();
    _openingStockNosController.clear();
    _calculateOnController.text = 'Mtrs';
    _discountController.clear();
    _remarksController.clear();
    _stockType = 'F';
    _rateUpdate = 'Y';
    _showInStockReport = 'Y';
    _active = 'Y';
    _setStatus('Form cleared.', false);
  }

  Item _currentItem() => Item(
    id: null,
    firmId: FirmSession.instance.current.id,
    itemCode: _itemCodeController.text.trim(),
    itemName: _itemNameController.text.trim(),
    itemGroup: _itemGroupController.text.trim(),
    subGroup: _subGroupController.text.trim(),
    mfgBy: _mfgByController.text.trim(),
    unitOfMeasure: _unitOfMeasureController.text.trim(),
    rateRetail: _rateRetailController.text.trim(),
    dealerRate: _dealerRateController.text.trim(),
    purchaseRate: _purchaseRateController.text.trim(),
    mrp: _mrpController.text.trim(),
    cutAverage: _cutAverageController.text.trim(),
    boxPack: _boxPackController.text.trim(),
    looseQuantity: _looseQtyController.text.trim(),
    hsnCode: _hsnCodeController.text.trim(),
    sgst: _sgstController.text.trim(),
    cgst: _cgstController.text.trim(),
    igst: _igstController.text.trim(),
    gstCalculation: _gstCalculationController.text,
    hsnDescription: _hsnDescriptionController.text.trim(),
    hsnUqc: _hsnUqcController.text.trim(),
    rolMin: _rolMinController.text.trim(),
    rolMax: _rolMaxController.text.trim(),
    openingStockQuantity: _openingStockQtyController.text.trim(),
    openingStockAmount: _openingStockAmountController.text.trim(),
    openingStockNos: _openingStockNosController.text.trim(),
    calculateOn: _calculateOnController.text,
    rateUpdate: _rateUpdate,
    showInStockReport: _showInStockReport,
    active: _active,
    discount: _discountController.text.trim(),
    remarks: _remarksController.text.trim(),
  );

  Future<void> _handleSave() async {
    final itemCode = _itemCodeController.text.trim();
    final itemName = _itemNameController.text.trim();

    if (itemCode.isEmpty || itemName.isEmpty) {
      _setStatus('Item Code and Item Name are required.', true);
      return;
    }

    for (final value in [
      _rateRetailController.text,
      _dealerRateController.text,
      _purchaseRateController.text,
      _mrpController.text,
      _sgstController.text,
      _cgstController.text,
      _igstController.text,
      _discountController.text,
      _openingStockQtyController.text,
      _openingStockAmountController.text,
      _openingStockNosController.text,
    ]) {
      if (value.trim().isNotEmpty) {
        final parsed = double.tryParse(value);
        if (parsed == null) {
          _setStatus(
            'Please enter valid numeric values for all rate and stock fields.',
            true,
          );
          return;
        }
      }
    }

    try {
      await ItemService().save(_currentItem());
      _setStatus('Item saved successfully in database.', false);
    } catch (_) {
      _setStatus('Item could not be saved. Item Code may already exist.', true);
    }
  }

  Future<void> _handleFind() async {
    final item = await showDialog<Item>(
      context: context,
      builder: (_) => const ItemSelectionDialog(mode: ItemDialogMode.find),
    );
    if (!mounted) return;
    if (item == null) {
      _resetForm();
      return;
    }
    _applyItem(item);
    _setStatus('Item loaded from database.', false);
  }

  void _applyItem(Item item) {
    _itemCodeController.text = item.itemCode;
    _itemNameController.text = item.itemName;
    _itemGroupController.text = item.itemGroup;
    _subGroupController.text = item.subGroup;
    _mfgByController.text = item.mfgBy;
    _unitOfMeasureController.text = item.unitOfMeasure;
    _rateRetailController.text = item.rateRetail;
    _dealerRateController.text = item.dealerRate;
    _purchaseRateController.text = item.purchaseRate;
    _mrpController.text = item.mrp;
    _cutAverageController.text = item.cutAverage;
    _boxPackController.text = item.boxPack;
    _looseQtyController.text = item.looseQuantity;
    _hsnCodeController.text = item.hsnCode;
    _sgstController.text = item.sgst;
    _cgstController.text = item.cgst;
    _igstController.text = item.igst;
    _gstCalculationController.text = item.gstCalculation;
    _hsnDescriptionController.text = item.hsnDescription;
    _hsnUqcController.text = item.hsnUqc;
    _rolMinController.text = item.rolMin;
    _rolMaxController.text = item.rolMax;
    _openingStockQtyController.text = item.openingStockQuantity;
    _openingStockAmountController.text = item.openingStockAmount;
    _openingStockNosController.text = item.openingStockNos;
    _calculateOnController.text = item.calculateOn;
    _rateUpdate = item.rateUpdate;
    _showInStockReport = item.showInStockReport;
    _active = item.active;
    _discountController.text = item.discount;
    _remarksController.text = item.remarks;
  }

  Future<void> _handleDelete() async {
    final deleted = await showDialog<Item>(
      context: context,
      builder: (_) => const ItemSelectionDialog(mode: ItemDialogMode.delete),
    );
    if (deleted != null && mounted) {
      _resetForm();
      _setStatus('${deleted.itemName} deleted from database.', false);
    }
  }

  Future<void> _handlePrint() async {
    await showDialog<Item>(
      context: context,
      builder: (_) => const ItemSelectionDialog(mode: ItemDialogMode.print),
    );
    if (mounted) _resetForm();
  }

  void _handleExit() {
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final basicFields = [
      _buildTextField('Item Code', _itemCodeController, width: 260),
      _buildTextField('Item Name', _itemNameController, width: 260),
      _buildTextField('Item Group', _itemGroupController, width: 260),
      _buildTextField('Sub Group', _subGroupController, width: 260),
      _buildTextField('Mfg. By', _mfgByController, width: 260),
      _buildDropdownField(
        'Stock Type',
        _stockType,
        const ['F', 'R', 'T', 'S', 'L', 'C', 'O'],
        (value) {
          setState(() => _stockType = value ?? 'F');
        },
        width: 260,
      ),
    ];

    final pricingFields = [
      _buildTextField('Unit of Measure', _unitOfMeasureController, width: 220),
      _buildTextField(
        'Rate Retail',
        _rateRetailController,
        width: 220,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
      ),
      _buildTextField(
        'Dealer Rate',
        _dealerRateController,
        width: 220,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
      ),
      _buildTextField(
        'Purchase Rate',
        _purchaseRateController,
        width: 220,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
      ),
      _buildTextField(
        'MRP',
        _mrpController,
        width: 220,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
      ),
      _buildTextField(
        'Cut/Average',
        _cutAverageController,
        width: 220,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
      ),
      _buildTextField(
        'Box Pack',
        _boxPackController,
        width: 220,
        keyboardType: TextInputType.number,
      ),
      _buildTextField(
        'Loose Quantity',
        _looseQtyController,
        width: 220,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
      ),
    ];

    final gstFields = [
      _buildTextField('HSN Code', _hsnCodeController, width: 220),
      _buildTextField(
        'SGST %',
        _sgstController,
        width: 200,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
      ),
      _buildTextField(
        'CGST %',
        _cgstController,
        width: 200,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
      ),
      _buildTextField(
        'IGST %',
        _igstController,
        width: 200,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
      ),
      _buildDropdownField(
        'GST Calculation',
        _gstCalculationController.text,
        const ['Taxable', 'Exempt', 'Zero Rated'],
        (value) {
          setState(() => _gstCalculationController.text = value ?? 'Taxable');
        },
        width: 250,
      ),
      _buildTextField(
        'HSN Description (GSTR-1)',
        _hsnDescriptionController,
        width: 260,
      ),
      _buildTextField('HSN UQC (GSTR-1)', _hsnUqcController, width: 200),
    ];

    final stockFields = [
      _buildTextField(
        'ROL Min.',
        _rolMinController,
        width: 200,
        keyboardType: TextInputType.number,
      ),
      _buildTextField(
        'ROL Max.',
        _rolMaxController,
        width: 200,
        keyboardType: TextInputType.number,
      ),
      _buildTextField(
        'Opening Stock Quantity',
        _openingStockQtyController,
        width: 220,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
      ),
      _buildTextField(
        'Opening Stock Amount',
        _openingStockAmountController,
        width: 220,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
      ),
      _buildTextField(
        'Opening Stock Nos.',
        _openingStockNosController,
        width: 220,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
      ),
      _buildDropdownField(
        'Calculate On',
        _calculateOnController.text,
        const ['Mtrs', 'PCS'],
        (value) {
          setState(() => _calculateOnController.text = value ?? 'Mtrs');
        },
        width: 220,
      ),
    ];

    final settingsFields = [
      _buildDropdownField('Rate Update', _rateUpdate, const ['Y', 'N'], (
        value,
      ) {
        setState(() => _rateUpdate = value ?? 'Y');
      }, width: 200),
      _buildDropdownField(
        'Show in Stock Report',
        _showInStockReport,
        const ['Y', 'N'],
        (value) {
          setState(() => _showInStockReport = value ?? 'Y');
        },
        width: 220,
      ),
      _buildDropdownField('Active', _active, const ['Y', 'N'], (value) {
        setState(() => _active = value ?? 'Y');
      }, width: 200),
      _buildTextField(
        'Discount %',
        _discountController,
        width: 180,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
      ),
      _buildTextField('Remarks', _remarksController, width: 360),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 42,
                alignment: Alignment.center,
                color: AppColors.primary,
                child: const Text(
                  'Item Master',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    color: AppColors.formBackground,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSection('Basic Item Information', basicFields),
                        _buildSection('Unit & Pricing', pricingFields),
                        _buildSection('GST / Tax Information', gstFields),
                        _buildSection(
                          'Stock / Reorder Information',
                          stockFields,
                        ),
                        _buildSection('Additional Settings', settingsFields),
                        const SizedBox(height: 12),
                        if (_statusMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              _statusMessage!,
                              style: TextStyle(
                                color: _isErrorStatus
                                    ? AppColors.error
                                    : AppColors.success,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildActionButton('New', Icons.add, _resetForm),
                              _buildActionButton(
                                'Find',
                                Icons.search,
                                _handleFind,
                              ),
                              _buildActionButton(
                                'Save',
                                Icons.save_outlined,
                                _handleSave,
                              ),
                              _buildActionButton(
                                'Cancel',
                                Icons.cancel_outlined,
                                _resetForm,
                              ),
                              _buildActionButton(
                                'Delete',
                                Icons.delete_outline,
                                _handleDelete,
                              ),
                              _buildActionButton(
                                'Print',
                                Icons.print_outlined,
                                _handlePrint,
                              ),
                              _buildActionButton(
                                'Exit',
                                Icons.exit_to_app,
                                _handleExit,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> fields) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: AppColors.primary,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(spacing: 18, runSpacing: 12, children: fields),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          minimumSize: const Size(0, 34),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    double width = 200,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return SizedBox(
      width: width,
      child: Row(
        children: [
          SizedBox(
            width: 112,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: const InputDecoration(
                isDense: true,
                filled: true,
                fillColor: AppColors.inputBackground,
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    String value,
    List<String> options,
    ValueChanged<String?> onChanged, {
    double width = 200,
  }) {
    return SizedBox(
      width: width,
      child: Row(
        children: [
          SizedBox(
            width: 112,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: options.contains(value) ? value : options.first,
              items: options
                  .map(
                    (option) => DropdownMenuItem<String>(
                      value: option,
                      child: Text(option),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
              decoration: const InputDecoration(
                isDense: true,
                filled: true,
                fillColor: AppColors.inputBackground,
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

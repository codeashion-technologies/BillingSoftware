import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

class GstLookupResult {
  const GstLookupResult({
    required this.name,
    this.address1,
    this.address2,
    this.city,
    this.state,
    this.phone,
  });

  final String name;
  final String? address1;
  final String? address2;
  final String? city;
  final String? state;
  final String? phone;
}

class GstUtils {
  static bool isValidGstin(String value) {
    final normalized = value.trim().toUpperCase();
    if (normalized.isEmpty) return false;

    final gstinPattern = RegExp(
      r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$',
    );

    return gstinPattern.hasMatch(normalized);
  }
}

class GstLookupService {
  static Future<GstLookupResult?> fetchDetails(String gstin) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    final normalized = gstin.trim().toUpperCase();
    if (!GstUtils.isValidGstin(normalized)) {
      return null;
    }

    const mockResults = {
      '27ABCDE1234F1Z5': GstLookupResult(
        name: 'Alpha Industries Pvt. Ltd.',
        address1: '32, Business Park Road',
        address2: 'Andheri East',
        city: 'Mumbai',
        state: 'Maharashtra',
        phone: '9876543210',
      ),
      '29ABCDE1234F1Z5': GstLookupResult(
        name: 'Blue River Traders',
        address1: '45, Industrial Layout',
        address2: 'Whitefield',
        city: 'Bengaluru',
        state: 'Karnataka',
        phone: '9988776655',
      ),
    };

    return mockResults[normalized];
  }
}

class AccountMasterPage extends StatefulWidget {
  const AccountMasterPage({super.key});

  @override
  State<AccountMasterPage> createState() => _AccountMasterPageState();
}

class _AccountMasterPageState extends State<AccountMasterPage> {
  final _nameController = TextEditingController();
  final _groupController = TextEditingController();
  final _address1Controller = TextEditingController();
  final _address2Controller = TextEditingController();
  final _deliveryAddress1Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _phoneController = TextEditingController();
  final _stateController = TextEditingController();
  final _gstNoController = TextEditingController();

  bool _isLoading = false;
  String? _statusMessage;
  bool _isErrorStatus = false;

  @override
  void dispose() {
    _nameController.dispose();
    _groupController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _deliveryAddress1Controller.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    _stateController.dispose();
    _gstNoController.dispose();
    super.dispose();
  }

  Future<void> _fetchGstDetails() async {
    final gstin = _gstNoController.text.trim();

    if (!GstUtils.isValidGstin(gstin)) {
      _setStatus('Please enter a valid GST number.', true);
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = null;
      _isErrorStatus = false;
    });

    try {
      final details = await GstLookupService.fetchDetails(gstin);

      if (details == null) {
        _setStatus(
          'GST details could not be retrieved. Please enter the details manually.',
          true,
        );
        return;
      }

      final shouldOverwrite = await _confirmOverwriteIfNeeded();
      if (!shouldOverwrite) {
        setState(() {
          _isLoading = false;
          _statusMessage = 'GST details were not overwritten. You can edit the fields manually.';
          _isErrorStatus = false;
        });
        return;
      }

      setState(() {
        _nameController.text = details.name;
        _address1Controller.text = details.address1 ?? _address1Controller.text;
        _address2Controller.text = details.address2 ?? _address2Controller.text;
        _cityController.text = details.city ?? _cityController.text;
        _stateController.text = details.state ?? _stateController.text;
        _phoneController.text = details.phone ?? _phoneController.text;
        _isLoading = false;
        _statusMessage = 'GST details fetched successfully.';
        _isErrorStatus = false;
      });
    } catch (_) {
      _setStatus(
        'GST details could not be retrieved. Please enter the details manually.',
        true,
      );
    }
  }

  Future<bool> _confirmOverwriteIfNeeded() async {
    final hasAnyManualValue = [
      _nameController.text,
      _groupController.text,
      _address1Controller.text,
      _address2Controller.text,
      _deliveryAddress1Controller.text,
      _cityController.text,
      _phoneController.text,
      _stateController.text,
    ].any((value) => value.trim().isNotEmpty);

    if (!hasAnyManualValue) {
      return true;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Replace existing values?'),
        content: const Text(
          'The GST lookup has values for this account. Replace the currently entered data?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep Existing'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Replace'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  void _setStatus(String message, bool isError) {
    setState(() {
      _statusMessage = message;
      _isErrorStatus = isError;
      _isLoading = false;
    });
  }

  void _resetForm() {
    _nameController.clear();
    _groupController.clear();
    _address1Controller.clear();
    _address2Controller.clear();
    _deliveryAddress1Controller.clear();
    _cityController.clear();
    _phoneController.clear();
    _stateController.clear();
    _gstNoController.clear();
    _setStatus('Form cleared.', false);
  }

  void _handleSave() {
    final name = _nameController.text.trim();
    final gstNo = _gstNoController.text.trim();

    if (name.isEmpty || gstNo.isEmpty) {
      _setStatus('Name and GST number are required before saving.', true);
      return;
    }

    _setStatus('Account saved successfully.', false);
  }

  void _handleCancel() {
    _resetForm();
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text('This will remove the current account details.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _resetForm();
      _setStatus('Account deleted.', false);
    }
  }

  void _handlePrint() {
    _setStatus('Printing account details...', false);
  }

  void _handleExit() {
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final fields = [
      _buildField('Name', _nameController, key: const ValueKey('nameField')),
      _buildField('Group', _groupController, key: const ValueKey('groupField')),
      _buildField(
        'Address 1',
        _address1Controller,
        key: const ValueKey('address1Field'),
      ),
      _buildField(
        'Address 2',
        _address2Controller,
        key: const ValueKey('address2Field'),
      ),
      _buildField(
        'Delivery Address 1',
        _deliveryAddress1Controller,
        key: const ValueKey('deliveryAddressField'),
      ),
      _buildField('City', _cityController, key: const ValueKey('cityField')),
      _buildField(
        'Phone',
        _phoneController,
        key: const ValueKey('phoneField'),
        keyboardType: TextInputType.phone,
      ),
      _buildField('State', _stateController, key: const ValueKey('stateField')),
      _buildField(
        'GST No.',
        _gstNoController,
        key: const ValueKey('gstNoField'),
        textCapitalization: TextCapitalization.characters,
        keyboardType: TextInputType.text,
      ),
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
                  'Account Master',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    color: AppColors.formBackground,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (final field in fields) ...[
                              field,
                              const SizedBox(height: 10),
                            ],
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            if (_statusMessage != null)
                              Expanded(
                                child: Text(
                                  _statusMessage!,
                                  style: TextStyle(
                                    color: _isErrorStatus
                                        ? AppColors.error
                                        : AppColors.success,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            else
                              const Expanded(child: SizedBox()),
                            const SizedBox(width: 12),
                            FilledButton.icon(
                              key: const ValueKey('fetchGstDetailsButton'),
                              onPressed: _isLoading ? null : _fetchGstDetails,
                              icon: _isLoading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.search),
                              label: Text(
                                _isLoading ? 'Fetching...' : 'Fetch Details',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildActionButton('New', Icons.add, _resetForm),
                              _buildActionButton('Find', Icons.search, () {
                                _setStatus(
                                  'Search existing account details.',
                                  false,
                                );
                              }),
                              _buildActionButton(
                                'Save',
                                Icons.save_outlined,
                                _handleSave,
                              ),
                              _buildActionButton(
                                'Cancel',
                                Icons.cancel_outlined,
                                _handleCancel,
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

  Widget _buildField(
    String label,
    TextEditingController controller, {
    Key? key,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return SizedBox(
      width: 290,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 108,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              key: key,
              controller: controller,
              keyboardType: keyboardType,
              textCapitalization: textCapitalization,
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

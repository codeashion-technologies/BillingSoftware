import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/services/account_service.dart';
import '../../../../core/services/firm_session.dart';
import '../../../../shared/models/account.dart';
import '../widgets/account_dialogs.dart';

class GstLookupResult {
  const GstLookupResult({
    required this.name,
    this.address1,
    this.address2,
    this.city,
    this.state,
    this.phone,
    this.gstNo,
    this.group,
    this.gstStatus,
    this.legalName,
    this.constitution,
    this.registrationDate,
    this.businessNature,
    this.principalBuilding,
    this.principalFloor,
    this.principalLocation,
    this.principalStreet,
    this.district,
    this.pincode,
    this.latitude,
    this.longitude,
    this.tradeNature,
    this.stateJurisdictionCode,
    this.stateJurisdiction,
    this.centralJurisdictionCode,
    this.centralJurisdiction,
    this.panNo,
  });

  final String name;
  final String? address1;
  final String? address2;
  final String? city;
  final String? state;
  final String? phone;
  final String? gstNo;
  final String? group;
  final String? gstStatus;
  final String? legalName;
  final String? constitution;
  final String? registrationDate;
  final String? businessNature;
  final String? principalBuilding;
  final String? principalFloor;
  final String? principalLocation;
  final String? principalStreet;
  final String? district;
  final String? pincode;
  final String? latitude;
  final String? longitude;
  final String? tradeNature;
  final String? stateJurisdictionCode;
  final String? stateJurisdiction;
  final String? centralJurisdictionCode;
  final String? centralJurisdiction;
  final String? panNo;
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
    final normalized = gstin.trim().toUpperCase();
    if (!GstUtils.isValidGstin(normalized)) {
      return null;
    }

    try {
      final uri = Uri.https('www.knowyourgst.com', '/developers/gstincall/', {
        'gstin': normalized,
      });
      final client = HttpClient();
      final request = await client.getUrl(uri);
      request.headers.set('passthrough', 'YmFsa3Jpc2huYTQxMzc5MTQxMDM');
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      client.close();
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final json = jsonDecode(body) as Map<String, dynamic>;
        final address = json['adress'] as Map<String, dynamic>?;
        if (json['status_code'].toString() == '1' && json['gstin'] != null) {
          final addressLine =
              [
                    address?['floor'],
                    address?['bno'],
                    address?['bname'],
                    address?['street'],
                    address?['location'],
                  ]
                  .whereType<String>()
                  .where((value) => value.trim().isNotEmpty)
                  .join(', ');
          return GstLookupResult(
            name: (json['trade-name'] ?? json['legal-name'] ?? '').toString(),
            address1: addressLine,
            address2: address?['street']?.toString(),
            city: (address?['city'] ?? address?['location'])?.toString(),
            state: address?['state']?.toString(),
            phone: null,
            gstNo: json['gstin'].toString(),
            group: json['dealer-type']?.toString(),
            gstStatus: json['status']?.toString(),
            legalName: json['legal-name']?.toString(),
            constitution: json['entity-type']?.toString(),
            registrationDate: json['registration-date']?.toString(),
            businessNature: json['business']?.toString(),
            principalBuilding: address?['bno']?.toString(),
            principalFloor: address?['floor']?.toString(),
            principalLocation: address?['location']?.toString(),
            principalStreet: address?['street']?.toString(),
            district: null,
            pincode: address?['pincode']?.toString(),
            latitude: address?['lt']?.toString(),
            longitude: address?['lg']?.toString(),
            tradeNature: json['business']?.toString(),
            stateJurisdictionCode: null,
            stateJurisdiction: null,
            centralJurisdictionCode: null,
            centralJurisdiction: null,
            panNo: json['pan']?.toString(),
          );
        }
      }
    } catch (_) {
      // Manual entry remains available when the lookup service is unavailable.
    }

    return null;
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
  final _gstStatusController = TextEditingController();
  final _legalNameController = TextEditingController();
  final _constitutionController = TextEditingController();
  final _registrationDateController = TextEditingController();
  final _businessNatureController = TextEditingController();
  final _buildingController = TextEditingController();
  final _floorController = TextEditingController();
  final _locationController = TextEditingController();
  final _streetController = TextEditingController();
  final _districtController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _tradeNatureController = TextEditingController();
  final _stateJurisdictionCodeController = TextEditingController();
  final _stateJurisdictionController = TextEditingController();
  final _centralJurisdictionCodeController = TextEditingController();
  final _centralJurisdictionController = TextEditingController();
  final _panController = TextEditingController();

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
    for (final controller in [
      _gstStatusController,
      _legalNameController,
      _constitutionController,
      _registrationDateController,
      _businessNatureController,
      _buildingController,
      _floorController,
      _locationController,
      _streetController,
      _districtController,
      _pincodeController,
      _latitudeController,
      _longitudeController,
      _tradeNatureController,
      _stateJurisdictionCodeController,
      _stateJurisdictionController,
      _centralJurisdictionCodeController,
      _centralJurisdictionController,
      _panController,
    ]) {
      controller.dispose();
    }
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
        _groupController.text = details.group ?? _groupController.text;
        _address1Controller.text = details.address1 ?? _address1Controller.text;
        _address2Controller.text = details.address2 ?? _address2Controller.text;
        _deliveryAddress1Controller.text =
            details.address1 ?? _deliveryAddress1Controller.text;
        _cityController.text = details.city ?? _cityController.text;
        _stateController.text = details.state ?? _stateController.text;
        _phoneController.text = details.phone ?? _phoneController.text;
        _gstNoController.text = details.gstNo ?? gstin;
        _gstStatusController.text = details.gstStatus ?? '';
        _legalNameController.text = details.legalName ?? '';
        _constitutionController.text = details.constitution ?? '';
        _registrationDateController.text = details.registrationDate ?? '';
        _businessNatureController.text = details.businessNature ?? '';
        _buildingController.text = details.principalBuilding ?? '';
        _floorController.text = details.principalFloor ?? '';
        _locationController.text = details.principalLocation ?? '';
        _streetController.text = details.principalStreet ?? '';
        _districtController.text = details.district ?? '';
        _pincodeController.text = details.pincode ?? '';
        _latitudeController.text = details.latitude ?? '';
        _longitudeController.text = details.longitude ?? '';
        _tradeNatureController.text = details.tradeNature ?? '';
        _stateJurisdictionCodeController.text =
            details.stateJurisdictionCode ?? '';
        _stateJurisdictionController.text = details.stateJurisdiction ?? '';
        _centralJurisdictionCodeController.text =
            details.centralJurisdictionCode ?? '';
        _centralJurisdictionController.text = details.centralJurisdiction ?? '';
        _panController.text = details.panNo ?? '';
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
    for (final controller in [
      _gstStatusController,
      _legalNameController,
      _constitutionController,
      _registrationDateController,
      _businessNatureController,
      _buildingController,
      _floorController,
      _locationController,
      _streetController,
      _districtController,
      _pincodeController,
      _latitudeController,
      _longitudeController,
      _tradeNatureController,
      _stateJurisdictionCodeController,
      _stateJurisdictionController,
      _centralJurisdictionCodeController,
      _centralJurisdictionController,
      _panController,
    ]) {
      controller.clear();
    }
    _setStatus('Form cleared.', false);
  }

  Account _currentAccount() => Account(
    id: null,
    firmId: FirmSession.instance.current.id,
    name: _nameController.text.trim(),
    group: _groupController.text.trim(),
    address1: _address1Controller.text.trim(),
    address2: _address2Controller.text.trim(),
    deliveryAddress1: _deliveryAddress1Controller.text.trim(),
    city: _cityController.text.trim(),
    phone: _phoneController.text.trim(),
    state: _stateController.text.trim(),
    gstNo: _gstNoController.text.trim().toUpperCase(),
    gstStatus: _gstStatusController.text.trim(),
    legalName: _legalNameController.text.trim(),
    constitution: _constitutionController.text.trim(),
    registrationDate: _registrationDateController.text.trim(),
    businessNature: _businessNatureController.text.trim(),
    principalBuilding: _buildingController.text.trim(),
    principalFloor: _floorController.text.trim(),
    principalLocation: _locationController.text.trim(),
    principalStreet: _streetController.text.trim(),
    district: _districtController.text.trim(),
    pincode: _pincodeController.text.trim(),
    latitude: _latitudeController.text.trim(),
    longitude: _longitudeController.text.trim(),
    tradeNature: _tradeNatureController.text.trim(),
    stateJurisdictionCode: _stateJurisdictionCodeController.text.trim(),
    stateJurisdiction: _stateJurisdictionController.text.trim(),
    centralJurisdictionCode: _centralJurisdictionCodeController.text.trim(),
    centralJurisdiction: _centralJurisdictionController.text.trim(),
    panNo: _panController.text.trim(),
  );

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    final gstNo = _gstNoController.text.trim();

    if (name.isEmpty || gstNo.isEmpty) {
      _setStatus('Name and GST number are required before saving.', true);
      return;
    }

    try {
      await AccountService().save(_currentAccount());
      _setStatus('Account saved successfully in database.', false);
    } catch (_) {
      _setStatus('Account could not be saved. Check GST number.', true);
    }
  }

  Future<void> _handleFind() async {
    final account = await showDialog<Account>(
      context: context,
      builder: (_) =>
          const AccountSelectionDialog(mode: AccountDialogMode.find),
    );
    if (!mounted) return;
    if (account == null) {
      _resetForm();
      return;
    }
    _applyAccount(account);
    _setStatus('Account loaded from database.', false);
  }

  void _applyAccount(Account account) {
    _nameController.text = account.name;
    _groupController.text = account.group;
    _address1Controller.text = account.address1;
    _address2Controller.text = account.address2;
    _deliveryAddress1Controller.text = account.deliveryAddress1;
    _cityController.text = account.city;
    _phoneController.text = account.phone;
    _stateController.text = account.state;
    _gstNoController.text = account.gstNo;
    _gstStatusController.text = account.gstStatus;
    _legalNameController.text = account.legalName;
    _constitutionController.text = account.constitution;
    _registrationDateController.text = account.registrationDate;
    _businessNatureController.text = account.businessNature;
    _buildingController.text = account.principalBuilding;
    _floorController.text = account.principalFloor;
    _locationController.text = account.principalLocation;
    _streetController.text = account.principalStreet;
    _districtController.text = account.district;
    _pincodeController.text = account.pincode;
    _latitudeController.text = account.latitude;
    _longitudeController.text = account.longitude;
    _tradeNatureController.text = account.tradeNature;
    _stateJurisdictionCodeController.text = account.stateJurisdictionCode;
    _stateJurisdictionController.text = account.stateJurisdiction;
    _centralJurisdictionCodeController.text = account.centralJurisdictionCode;
    _centralJurisdictionController.text = account.centralJurisdiction;
    _panController.text = account.panNo;
  }

  void _handleCancel() {
    _resetForm();
  }

  Future<void> _handleDelete() async {
    final deleted = await showDialog<Account>(
      context: context,
      builder: (_) =>
          const AccountSelectionDialog(mode: AccountDialogMode.delete),
    );

    if (deleted != null && mounted) {
      _resetForm();
      _setStatus('${deleted.name} deleted from database.', false);
    }
  }

  Future<void> _handlePrint() async {
    await showDialog<Account>(
      context: context,
      builder: (_) =>
          const AccountSelectionDialog(mode: AccountDialogMode.print),
    );
    if (mounted) _resetForm();
  }

  void _handleExit() {
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
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
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFF4F2C6), Color(0xFFE6EFEA)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle(
                          'Business identity',
                          Icons.business_outlined,
                        ),
                        Wrap(
                          spacing: 20,
                          runSpacing: 12,
                          children: [
                            _buildField(
                              'Name',
                              _nameController,
                              key: const ValueKey('nameField'),
                              width: 430,
                            ),
                            _buildField(
                              'Legal Name',
                              _legalNameController,
                              width: 430,
                            ),
                            _buildField(
                              'Group / Type',
                              _groupController,
                              key: const ValueKey('groupField'),
                              width: 430,
                            ),
                            _buildField(
                              'Constitution',
                              _constitutionController,
                              width: 430,
                            ),
                            _buildField(
                              'GST No.',
                              _gstNoController,
                              key: const ValueKey('gstNoField'),
                              width: 430,
                              textCapitalization: TextCapitalization.characters,
                            ),
                            _buildField(
                              'GST Status',
                              _gstStatusController,
                              width: 430,
                            ),
                            _buildField('PAN No.', _panController, width: 430),
                            _buildField(
                              'Registration Date',
                              _registrationDateController,
                              width: 430,
                            ),
                            _buildField(
                              'Business Nature',
                              _businessNatureController,
                              width: 430,
                            ),
                            _buildField(
                              'Trade Nature',
                              _tradeNatureController,
                              width: 430,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _sectionTitle(
                          'Business address',
                          Icons.location_on_outlined,
                        ),
                        Wrap(
                          spacing: 20,
                          runSpacing: 12,
                          children: [
                            _buildField(
                              'Address 1',
                              _address1Controller,
                              key: const ValueKey('address1Field'),
                              width: 880,
                              maxLines: 3,
                            ),
                            _buildField(
                              'Address 2',
                              _address2Controller,
                              key: const ValueKey('address2Field'),
                              width: 430,
                              maxLines: 2,
                            ),
                            _buildField(
                              'Delivery Address',
                              _deliveryAddress1Controller,
                              key: const ValueKey('deliveryAddressField'),
                              width: 430,
                              maxLines: 2,
                            ),
                            _buildField(
                              'Building No.',
                              _buildingController,
                              width: 280,
                            ),
                            _buildField(
                              'Floor No.',
                              _floorController,
                              width: 280,
                            ),
                            _buildField(
                              'Location',
                              _locationController,
                              width: 280,
                            ),
                            _buildField(
                              'Street',
                              _streetController,
                              width: 280,
                            ),
                            _buildField(
                              'City',
                              _cityController,
                              key: const ValueKey('cityField'),
                              width: 280,
                            ),
                            _buildField(
                              'District',
                              _districtController,
                              width: 280,
                            ),
                            _buildField(
                              'State',
                              _stateController,
                              key: const ValueKey('stateField'),
                              width: 280,
                            ),
                            _buildField(
                              'Pincode',
                              _pincodeController,
                              width: 280,
                              keyboardType: TextInputType.number,
                            ),
                            _buildField(
                              'Phone / PIN',
                              _phoneController,
                              key: const ValueKey('phoneField'),
                              width: 280,
                              keyboardType: TextInputType.phone,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _sectionTitle(
                          'Jurisdiction and coordinates',
                          Icons.account_tree_outlined,
                        ),
                        Wrap(
                          spacing: 20,
                          runSpacing: 12,
                          children: [
                            _buildField(
                              'State Jurisdiction Code',
                              _stateJurisdictionCodeController,
                              width: 430,
                            ),
                            _buildField(
                              'State Jurisdiction',
                              _stateJurisdictionController,
                              width: 430,
                            ),
                            _buildField(
                              'Central Jurisdiction Code',
                              _centralJurisdictionCodeController,
                              width: 430,
                            ),
                            _buildField(
                              'Central Jurisdiction',
                              _centralJurisdictionController,
                              width: 430,
                            ),
                            _buildField(
                              'Latitude',
                              _latitudeController,
                              width: 280,
                            ),
                            _buildField(
                              'Longitude',
                              _longitudeController,
                              width: 280,
                            ),
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

  Widget _sectionTitle(String title, IconData icon) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );

  Widget _buildField(
    String label,
    TextEditingController controller, {
    Key? key,
    double width = 430,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 5),
          TextField(
            key: key,
            controller: controller,
            keyboardType: keyboardType,
            textCapitalization: textCapitalization,
            maxLines: maxLines,
            minLines: maxLines > 1 ? 2 : 1,
            decoration: const InputDecoration(
              isDense: true,
              filled: true,
              fillColor: AppColors.inputBackground,
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

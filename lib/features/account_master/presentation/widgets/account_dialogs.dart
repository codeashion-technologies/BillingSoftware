import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../../core/services/account_service.dart';
import '../../../../core/services/firm_session.dart';
import '../../../../shared/models/account.dart';

enum AccountDialogMode { find, delete, print }

class AccountSelectionDialog extends StatefulWidget {
  const AccountSelectionDialog({required this.mode, super.key});

  final AccountDialogMode mode;

  @override
  State<AccountSelectionDialog> createState() => _AccountSelectionDialogState();
}

class _AccountSelectionDialogState extends State<AccountSelectionDialog> {
  Account? _selected;

  String get _title => switch (widget.mode) {
    AccountDialogMode.find => 'Find Account',
    AccountDialogMode.delete => 'Delete Account',
    AccountDialogMode.print => 'Print Account',
  };

  String get _actionLabel => switch (widget.mode) {
    AccountDialogMode.find => 'Find',
    AccountDialogMode.delete => 'Delete',
    AccountDialogMode.print => 'Print',
  };

  Future<void> _action() async {
    final account = _selected;
    if (account == null) return;
    if (widget.mode == AccountDialogMode.delete) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Delete Account?'),
          content: Text('Delete ${account.name} from the database?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context, true),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete'),
            ),
          ],
        ),
      );
      if (confirmed == true && account.id != null) {
        await AccountService().deleteById(account.id!);
        if (mounted) Navigator.pop(context, account);
      }
      return;
    }
    if (widget.mode == AccountDialogMode.print) {
      await showDialog<void>(
        context: context,
        builder: (_) => AccountDetailsDialog(account: account, printMode: true),
      );
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (_) => AccountDetailsDialog(account: account),
    );
    if (mounted) Navigator.pop(context, account);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(_title),
    content: SizedBox(
      width: 600,
      height: 360,
      child: FutureBuilder<List<Account>>(
        future: AccountService().getAll(
          firmId: FirmSession.instance.current.id,
        ),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final accounts = snapshot.data!;
          if (accounts.isEmpty)
            return const Center(
              child: Text('No accounts saved for this firm.'),
            );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Select an account from the current firm.'),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: accounts.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final account = accounts[index];
                    return RadioListTile<Account>(
                      value: account,
                      groupValue: _selected,
                      onChanged: (value) => setState(() => _selected = value),
                      title: Text(account.name),
                      subtitle: Text(
                        '${account.gstNo}  |  ${account.city}  |  ${account.state}',
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton.icon(
        onPressed: _selected == null ? null : _action,
        icon: Icon(
          widget.mode == AccountDialogMode.delete
              ? Icons.delete_outline
              : Icons.check,
        ),
        label: Text(_actionLabel),
      ),
    ],
  );
}

class AccountDetailsDialog extends StatelessWidget {
  const AccountDetailsDialog({
    required this.account,
    this.printMode = false,
    super.key,
  });

  final Account account;
  final bool printMode;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(printMode ? 'Print Account Details' : 'Account Details'),
    content: SizedBox(
      width: 680,
      height: 440,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _section('Business', {
              'Name': account.name,
              'Legal Name': account.legalName,
              'GST Number': account.gstNo,
              'GST Status': account.gstStatus,
              'PAN': account.panNo,
              'Constitution': account.constitution,
              'Registration Date': account.registrationDate,
              'Business Nature': account.businessNature,
              'Trade Nature': account.tradeNature,
            }),
            _section('Address', {
              'Address 1': account.address1,
              'Address 2': account.address2,
              'Building': account.principalBuilding,
              'Floor': account.principalFloor,
              'Location': account.principalLocation,
              'Street': account.principalStreet,
              'City': account.city,
              'District': account.district,
              'State': account.state,
              'Pincode': account.pincode,
              'Phone': account.phone,
            }),
            _section('Jurisdiction', {
              'State':
                  '${account.stateJurisdictionCode} ${account.stateJurisdiction}',
              'Central':
                  '${account.centralJurisdictionCode} ${account.centralJurisdiction}',
              'Coordinates': '${account.latitude}, ${account.longitude}',
            }),
          ],
        ),
      ),
    ),
    actions: [
      if (printMode)
        FilledButton.icon(
          onPressed: () => _printAccount(context),
          icon: const Icon(Icons.print),
          label: const Text('Print'),
        ),
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Close'),
      ),
    ],
  );

  Future<void> _printAccount(BuildContext context) async {
    final document = pw.Document();
    document.addPage(
      pw.MultiPage(
        build: (_) => [
          pw.Header(level: 0, text: 'Account Details'),
          pw.Text('Name: ${account.name}'),
          pw.Text('Legal Name: ${account.legalName}'),
          pw.Text('GST Number: ${account.gstNo}'),
          pw.Text('GST Status: ${account.gstStatus}'),
          pw.Text('PAN: ${account.panNo}'),
          pw.SizedBox(height: 12),
          pw.Text(
            'Address',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(account.address1),
          pw.Text(account.address2),
          pw.Text(
            '${account.city}, ${account.district}, ${account.state} - ${account.pincode}',
          ),
          pw.Text('Phone / PIN: ${account.phone}'),
          pw.SizedBox(height: 12),
          pw.Text('Business Nature: ${account.businessNature}'),
          pw.Text('Trade Nature: ${account.tradeNature}'),
          pw.Text('Registration Date: ${account.registrationDate}'),
          pw.SizedBox(height: 12),
          pw.Text(
            'State Jurisdiction: ${account.stateJurisdictionCode} ${account.stateJurisdiction}',
          ),
          pw.Text(
            'Central Jurisdiction: ${account.centralJurisdictionCode} ${account.centralJurisdiction}',
          ),
        ],
      ),
    );
    await Printing.layoutPdf(onLayout: (_) async => document.save());
    if (context.mounted) Navigator.of(context).pop();
  }

  Widget _section(String title, Map<String, String> values) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const Divider(),
        ...values.entries
            .where((entry) => entry.value.trim().isNotEmpty)
            .map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 150,
                      child: Text(
                        entry.key,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Expanded(child: Text(entry.value)),
                  ],
                ),
              ),
            ),
      ],
    ),
  );
}

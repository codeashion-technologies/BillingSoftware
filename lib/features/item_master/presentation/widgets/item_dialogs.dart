import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../../core/services/firm_session.dart';
import '../../../../core/services/item_service.dart';
import '../../../../shared/models/item.dart';

enum ItemDialogMode { find, delete, print }

class ItemSelectionDialog extends StatefulWidget {
  const ItemSelectionDialog({required this.mode, super.key});
  final ItemDialogMode mode;

  @override
  State<ItemSelectionDialog> createState() => _ItemSelectionDialogState();
}

class _ItemSelectionDialogState extends State<ItemSelectionDialog> {
  Item? _selected;

  String get _title => switch (widget.mode) {
    ItemDialogMode.find => 'Find Item',
    ItemDialogMode.delete => 'Delete Item',
    ItemDialogMode.print => 'Print Item',
  };

  Future<void> _action() async {
    final item = _selected;
    if (item == null) return;
    if (widget.mode == ItemDialogMode.delete) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Delete Item?'),
          content: Text('Delete ${item.itemName} from the database?'),
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
      if (confirmed == true && item.id != null) {
        await ItemService().deleteById(item.id!);
        if (mounted) Navigator.pop(context, item);
      }
      return;
    }
    final load = await showDialog<bool>(
      context: context,
      builder: (_) => ItemDetailsDialog(
        item: item,
        printMode: widget.mode == ItemDialogMode.print,
      ),
    );
    if (mounted)
      Navigator.pop(
        context,
        load == true && widget.mode == ItemDialogMode.find ? item : null,
      );
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(_title),
    content: SizedBox(
      width: 600,
      height: 360,
      child: FutureBuilder<List<Item>>(
        future: ItemService().getAll(firmId: FirmSession.instance.current.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final items = snapshot.data!;
          if (items.isEmpty)
            return const Center(child: Text('No items saved for this firm.'));
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Select an item from the current firm.'),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (_, index) {
                    final item = items[index];
                    return RadioListTile<Item>(
                      value: item,
                      groupValue: _selected,
                      onChanged: (value) => setState(() => _selected = value),
                      title: Text(item.itemName),
                      subtitle: Text(
                        '${item.itemCode} | ${item.itemGroup} | ${item.unitOfMeasure}',
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
          widget.mode == ItemDialogMode.delete
              ? Icons.delete_outline
              : Icons.check,
        ),
        label: Text(
          widget.mode == ItemDialogMode.delete
              ? 'Delete'
              : widget.mode == ItemDialogMode.print
              ? 'Print'
              : 'Find',
        ),
      ),
    ],
  );
}

class ItemDetailsDialog extends StatelessWidget {
  const ItemDetailsDialog({
    required this.item,
    this.printMode = false,
    super.key,
  });
  final Item item;
  final bool printMode;

  Future<void> _print(BuildContext context) async {
    final document = pw.Document();
    document.addPage(
      pw.MultiPage(
        build: (_) => [
          pw.Header(level: 0, text: 'Item Details'),
          pw.Text('Item Code: ${item.itemCode}'),
          pw.Text('Item Name: ${item.itemName}'),
          pw.Text('Group: ${item.itemGroup}'),
          pw.Text('Sub Group: ${item.subGroup}'),
          pw.Text('Unit: ${item.unitOfMeasure}'),
          pw.Text('Rate Retail: ${item.rateRetail}'),
          pw.Text('Dealer Rate: ${item.dealerRate}'),
          pw.Text('Purchase Rate: ${item.purchaseRate}'),
          pw.Text('MRP: ${item.mrp}'),
          pw.Text('HSN: ${item.hsnCode}'),
          pw.Text('SGST: ${item.sgst}  CGST: ${item.cgst}  IGST: ${item.igst}'),
          pw.Text('Opening Stock: ${item.openingStockQuantity}'),
          pw.Text('Remarks: ${item.remarks}'),
        ],
      ),
    );
    await Printing.layoutPdf(onLayout: (_) async => document.save());
    if (context.mounted) Navigator.pop(context, false);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(printMode ? 'Print Item Details' : 'Item Details'),
    content: SizedBox(
      width: 650,
      height: 440,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _section('Basic Information', {
              'Item Code': item.itemCode,
              'Item Name': item.itemName,
              'Item Group': item.itemGroup,
              'Sub Group': item.subGroup,
              'Mfg. By': item.mfgBy,
            }),
            _section('Unit & Pricing', {
              'Unit': item.unitOfMeasure,
              'Retail': item.rateRetail,
              'Dealer': item.dealerRate,
              'Purchase': item.purchaseRate,
              'MRP': item.mrp,
              'Cut/Average': item.cutAverage,
              'Box Pack': item.boxPack,
              'Loose Quantity': item.looseQuantity,
            }),
            _section('GST / Tax', {
              'HSN': item.hsnCode,
              'SGST': item.sgst,
              'CGST': item.cgst,
              'IGST': item.igst,
              'Calculation': item.gstCalculation,
              'HSN Description': item.hsnDescription,
              'UQC': item.hsnUqc,
            }),
            _section('Stock & Settings', {
              'ROL Min': item.rolMin,
              'ROL Max': item.rolMax,
              'Opening Quantity': item.openingStockQuantity,
              'Opening Amount': item.openingStockAmount,
              'Opening Nos': item.openingStockNos,
              'Calculate On': item.calculateOn,
              'Active': item.active,
              'Remarks': item.remarks,
            }),
          ],
        ),
      ),
    ),
    actions: [
      if (!printMode)
        FilledButton.icon(
          onPressed: () => Navigator.pop(context, true),
          icon: const Icon(Icons.input_outlined),
          label: const Text('Load into Form'),
        ),
      if (printMode)
        FilledButton.icon(
          onPressed: () => _print(context),
          icon: const Icon(Icons.print),
          label: const Text('Print'),
        ),
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: const Text('Close'),
      ),
    ],
  );

  Widget _section(String title, Map<String, String> values) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
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
                padding: const EdgeInsets.symmetric(vertical: 3),
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

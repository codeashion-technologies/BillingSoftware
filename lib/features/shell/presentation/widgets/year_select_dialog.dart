import 'package:flutter/material.dart';

import '../../../../core/services/firm_service.dart';
import '../../../../core/services/firm_session.dart';

class YearSelectDialog extends StatefulWidget {
  const YearSelectDialog({super.key});

  @override
  State<YearSelectDialog> createState() => _YearSelectDialogState();
}

class _YearSelectDialogState extends State<YearSelectDialog> {
  late String _selectedYear;
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selectedYear = FirmSession.instance.current.financialYear;
  }

  Future<void> _loadAndSelect(String year) async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await FirmService().updateFinancialYear(
        firmId: FirmSession.instance.current.id,
        firmCode: FirmSession.instance.current.code,
        financialYear: year,
      );
      FirmSession.instance.selectYear(year);
      if (mounted) Navigator.of(context).pop(year);
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Unable to save the financial year.';
        });
      }
    }
  }

  List<String> _availableYears(List<String> storedYears) {
    final currentYear = FirmSession.instance.current.financialYear;
    final startYear = int.tryParse(currentYear.split('-').first);
    if (startYear == null) return storedYears.toSet().toList()..sort();

    final years = <String>{...storedYears};
    for (var offset = 0; offset <= 2; offset++) {
      final year = startYear - offset;
      years.add('$year-${(year + 1).toString().substring(2)}');
    }
    return years.toList()..sort((a, b) => b.compareTo(a));
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Year Select'),
    content: SizedBox(
      width: 400,
      height: 230,
      child: FutureBuilder<List<String>>(
        future: FirmService().getFirms().then(
          (firms) =>
              _availableYears(firms.map((firm) => firm.financialYear).toList()),
        ),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final years = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Select financial year for the current firm.'),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: years.contains(_selectedYear) ? _selectedYear : null,
                decoration: const InputDecoration(
                  labelText: 'Financial Year',
                  prefixIcon: Icon(Icons.calendar_month_outlined),
                ),
                items: years
                    .map(
                      (year) =>
                          DropdownMenuItem(value: year, child: Text(year)),
                    )
                    .toList(),
                onChanged: _saving
                    ? null
                    : (year) {
                        if (year == null) return;
                        setState(() => _selectedYear = year);
                      },
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          );
        },
      ),
    ),
    actions: [
      TextButton(
        onPressed: _saving ? null : () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
      FilledButton.icon(
        onPressed: _saving || _selectedYear == null
            ? null
            : () => _loadAndSelect(_selectedYear),
        icon: _saving
            ? const SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.check),
        label: const Text('Select'),
      ),
    ],
  );
}

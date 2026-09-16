import 'package:flutter/material.dart';

import '../../../../core/services/firm_service.dart';
import '../../../../core/services/firm_session.dart';
import '../../../../shared/models/firm.dart';

class NewFirmDialog extends StatefulWidget {
  const NewFirmDialog({super.key});

  @override
  State<NewFirmDialog> createState() => _NewFirmDialogState();
}

class _NewFirmDialogState extends State<NewFirmDialog> {
  final _code = TextEditingController();
  final _name = TextEditingController();
  final _year = TextEditingController(text: '2026-27');
  final _area = TextEditingController();
  final _password = TextEditingController();
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _code.dispose();
    _name.dispose();
    _year.dispose();
    _area.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if ([
      _code,
      _name,
      _year,
      _password,
    ].any((controller) => controller.text.trim().isEmpty)) {
      setState(() => _error = 'Please fill all required fields.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final firm = await FirmService().createFirm(
        code: _code.text,
        name: _name.text,
        financialYear: _year.text,
        area: _area.text,
        password: _password.text,
      );
      if (mounted) Navigator.of(context).pop(firm);
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'User ID already exists or could not be saved.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => _FirmFormDialog(
    title: 'New User / Firm',
    codeController: _code,
    nameController: _name,
    yearController: _year,
    areaController: _area,
    passwordController: _password,
    error: _error,
    saving: _saving,
    onSave: _save,
  );
}

class EditFirmDialog extends StatefulWidget {
  const EditFirmDialog({super.key});

  @override
  State<EditFirmDialog> createState() => _EditFirmDialogState();
}

class _EditFirmDialogState extends State<EditFirmDialog> {
  Firm? _selected;

  Future<void> _edit(Firm firm) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => _EditFirmForm(firm: firm),
    );
    if (result == true && mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Edit User / Firm'),
    content: SizedBox(
      width: 440,
      height: 300,
      child: FutureBuilder<List<Firm>>(
        future: FirmService().getFirms(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final firms = snapshot.data!;
          if (firms.isEmpty)
            return const Center(child: Text('No firms found.'));
          _selected ??= firms.first;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<int>(
                value: _selected!.id,
                decoration: const InputDecoration(labelText: 'Select firm'),
                items: firms
                    .map(
                      (firm) => DropdownMenuItem(
                        value: firm.id,
                        child: Text('${firm.code} - ${firm.name}'),
                      ),
                    )
                    .toList(),
                onChanged: (firmId) {
                  if (firmId == null) return;
                  final firm = firms.firstWhere((item) => item.id == firmId);
                  setState(() => _selected = firm);
                },
              ),
              const SizedBox(height: 24),
              Text('Selected: ${_selected!.name}'),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => _edit(_selected!),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit Selected Firm'),
              ),
            ],
          );
        },
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Close'),
      ),
    ],
  );
}

class _EditFirmForm extends StatefulWidget {
  const _EditFirmForm({required this.firm});
  final Firm firm;

  @override
  State<_EditFirmForm> createState() => _EditFirmFormState();
}

class _EditFirmFormState extends State<_EditFirmForm> {
  late final TextEditingController _code = TextEditingController(
    text: widget.firm.code,
  );
  late final TextEditingController _name = TextEditingController(
    text: widget.firm.name,
  );
  late final TextEditingController _year = TextEditingController(
    text: widget.firm.financialYear,
  );
  late final TextEditingController _area = TextEditingController(
    text: widget.firm.area,
  );
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _code.dispose();
    _name.dispose();
    _year.dispose();
    _area.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty || _year.text.trim().isEmpty) {
      setState(() => _error = 'Firm name and financial year are required.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    await FirmService().updateFirm(
      id: widget.firm.id,
      name: _name.text,
      financialYear: _year.text,
      area: _area.text,
    );
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) => _FirmFormDialog(
    title: 'Edit Firm',
    codeController: _code,
    nameController: _name,
    yearController: _year,
    areaController: _area,
    error: _error,
    saving: _saving,
    onSave: _save,
    passwordController: null,
  );
}

class FirmSelectDialog extends StatelessWidget {
  const FirmSelectDialog({super.key});

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Firm Select'),
    content: SizedBox(
      width: 480,
      height: 320,
      child: FutureBuilder<List<Firm>>(
        future: FirmService().getFirms(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final firms = snapshot.data!;
          return ListView.separated(
            itemCount: firms.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final firm = firms[index];
              return ListTile(
                leading: const Icon(Icons.business_outlined),
                title: Text(firm.name),
                subtitle: Text(
                  '${firm.code}  |  ${firm.financialYear}  |  ${firm.area}',
                ),
                onTap: () {
                  FirmSession.instance.select(firm);
                  Navigator.of(context).pop(firm);
                },
              );
            },
          );
        },
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
    ],
  );
}

class _FirmFormDialog extends StatelessWidget {
  const _FirmFormDialog({
    required this.title,
    required this.codeController,
    required this.nameController,
    required this.yearController,
    required this.areaController,
    required this.passwordController,
    required this.error,
    required this.saving,
    required this.onSave,
  });

  final String title;
  final TextEditingController codeController;
  final TextEditingController nameController;
  final TextEditingController yearController;
  final TextEditingController areaController;
  final TextEditingController? passwordController;
  final String? error;
  final bool saving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(title),
    content: SizedBox(
      width: 460,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: codeController,
              enabled: passwordController != null,
              decoration: const InputDecoration(
                labelText: 'User ID / Firm Code',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Firm Name'),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: yearController,
                    decoration: const InputDecoration(
                      labelText: 'Financial Year',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: areaController,
                    decoration: const InputDecoration(labelText: 'Area'),
                  ),
                ),
              ],
            ),
            if (passwordController != null) ...[
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Login Password'),
              ),
            ],
            if (error != null) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ],
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: saving ? null : () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
      FilledButton.icon(
        onPressed: saving ? null : onSave,
        icon: const Icon(Icons.save_outlined),
        label: const Text('Save'),
      ),
    ],
  );
}

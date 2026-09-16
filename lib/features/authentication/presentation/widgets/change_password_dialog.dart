import 'package:flutter/material.dart';

import '../../../../core/services/authentication_service.dart';
import '../../../../core/services/firm_service.dart';
import '../../../../shared/models/firm.dart';

class UserSelectionDialog extends StatefulWidget {
  const UserSelectionDialog({super.key});

  @override
  State<UserSelectionDialog> createState() => _UserSelectionDialogState();
}

class _UserSelectionDialogState extends State<UserSelectionDialog> {
  Firm? _selected;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Select User'),
    content: SizedBox(
      width: 480,
      height: 320,
      child: FutureBuilder<List<Firm>>(
        future: FirmService().getFirms(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final users = snapshot.data!;
          if (users.isEmpty) {
            return const Center(child: Text('No users found.'));
          }
          return ListView.separated(
            itemCount: users.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final user = users[index];
              return RadioListTile<Firm>(
                value: user,
                groupValue: _selected,
                onChanged: (value) => setState(() => _selected = value),
                title: Text(user.name),
                subtitle: Text('User ID: ${user.code}  |  Area: ${user.area}'),
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
      FilledButton.icon(
        onPressed: _selected == null
            ? null
            : () => Navigator.of(context).pop(_selected!.code),
        icon: const Icon(Icons.arrow_forward),
        label: const Text('Continue'),
      ),
    ],
  );
}

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({this.userId = '3723', super.key});

  final String userId;

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _saving = false;
  String? _errorMessage;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    final newPassword = _newController.text;
    if (newPassword.isEmpty || _currentController.text.isEmpty) {
      setState(() => _errorMessage = 'Please fill all password fields.');
      return;
    }
    if (newPassword != _confirmController.text) {
      setState(() => _errorMessage = 'New passwords do not match.');
      return;
    }
    if (newPassword.length < 4) {
      setState(
        () => _errorMessage = 'New password must be at least 4 characters.',
      );
      return;
    }

    setState(() {
      _saving = true;
      _errorMessage = null;
    });
    final changed = await AuthenticationService().changePassword(
      userId: widget.userId,
      currentPassword: _currentController.text,
      newPassword: newPassword,
    );
    if (!mounted) return;

    if (!changed) {
      setState(() {
        _saving = false;
        _errorMessage = 'Current password is invalid.';
      });
      return;
    }
    Navigator.of(context).pop(true);
  }

  InputDecoration _decoration(
    String label,
    IconData icon,
    VoidCallback toggle,
  ) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon),
    suffixIcon: IconButton(
      onPressed: toggle,
      icon: Icon(
        label == 'Current Password'
            ? (_obscureCurrent
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined)
            : label == 'New Password'
            ? (_obscureNew
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined)
            : (_obscureConfirm
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text('Change Password - User ${widget.userId}'),
    content: SizedBox(
      width: 380,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _currentController,
            obscureText: _obscureCurrent,
            decoration: _decoration(
              'Current Password',
              Icons.lock_outline,
              () => setState(() => _obscureCurrent = !_obscureCurrent),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _newController,
            obscureText: _obscureNew,
            decoration: _decoration(
              'New Password',
              Icons.lock_reset_outlined,
              () => setState(() => _obscureNew = !_obscureNew),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _confirmController,
            obscureText: _obscureConfirm,
            decoration: _decoration(
              'Confirm Password',
              Icons.verified_user_outlined,
              () => setState(() => _obscureConfirm = !_obscureConfirm),
            ),
            onSubmitted: (_) => _changePassword(),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: _saving ? null : () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
      FilledButton.icon(
        onPressed: _saving ? null : _changePassword,
        icon: _saving
            ? const SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.save_outlined),
        label: const Text('Update Password'),
      ),
    ],
  );
}

import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/authentication_service.dart';

class AuthenticationGate extends StatefulWidget {
  const AuthenticationGate({
    required this.onAuthenticated,
    this.credentialVerifier,
    this.authenticatedChild,
    super.key,
  });

  final Future<void> Function() onAuthenticated;
  final Future<bool> Function({
    required String userId,
    required String password,
  })?
  credentialVerifier;
  final Widget? authenticatedChild;

  @override
  State<AuthenticationGate> createState() => _AuthenticationGateState();
}

class _AuthenticationGateState extends State<AuthenticationGate> {
  String? _errorMessage;
  bool _obscurePassword = true;
  late final TextEditingController _userIdController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _userIdController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final isValid = await (widget.credentialVerifier?.call(
          userId: _userIdController.text,
          password: _passwordController.text,
        ) ??
        AuthenticationService().verifyCredentials(
          userId: _userIdController.text,
          password: _passwordController.text,
        ));
    if (!mounted) return;

    if (isValid) {
      await widget.onAuthenticated();
      return;
    }

    setState(() {
      _errorMessage = 'Invalid ID or password. Please try again.';
      _passwordController.clear();
    });
  }

  Widget _loginDialog(BuildContext context) => AlertDialog(
    backgroundColor: Colors.transparent,
    elevation: 0,
    insetPadding: EdgeInsets.zero,
    contentPadding: EdgeInsets.zero,
    content: SizedBox(
      width: 840,
      height: 400,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 10,
        shadowColor: Colors.black38,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFE9F1F1),
                      Color(0xFFC8DEDF),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.account_balance_outlined,
                      size: 64,
                      color: Color(0xFF075E63),
                    ),
                    const SizedBox(height: 18),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        AppConstants.appName,
                        maxLines: 1,
                        softWrap: false,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF202B2C),
                          fontSize: 23,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Smart accounting and billing',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF536062),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 6,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Color(0xFFFFFDF4),
                      Color(0xFFE8F0ED),
                    ],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(34, 28, 34, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      AppConstants.softwareName,
                      style: const TextStyle(
                        color: Color(0xFF075E63),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Login',
                      style: TextStyle(
                        color: Color(0xFF202B2C),
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                TextField(
                  controller: _userIdController,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'ID',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                      onSubmitted: (_) => _verify(),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      tooltip: _obscurePassword
                          ? 'Show password'
                          : 'Hide password',
                      onPressed: () => setState(
                        () => _obscurePassword = !_obscurePassword,
                      ),
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                      onSubmitted: (_) => _verify(),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                    const Spacer(),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        onPressed: _verify,
                        icon: const Icon(Icons.login, size: 18),
                        label: const Text('Sign in'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => widget.authenticatedChild ??
      Center(child: _loginDialog(context));
}

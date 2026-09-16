import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../core/constants/app_constants.dart';
import '../features/authentication/presentation/widgets/authentication_gate.dart';
import 'router/app_router.dart';
import 'router/route_names.dart';
import 'theme/app_theme.dart';

class AccountingApp extends StatefulWidget {
  const AccountingApp({this.credentialVerifier, super.key});

  final Future<bool> Function({
    required String userId,
    required String password,
  })?
  credentialVerifier;

  @override
  State<AccountingApp> createState() => _AccountingAppState();
}

class _AccountingAppState extends State<AccountingApp> {
  bool _authenticated = false;

  Future<void> _openMainWindow() async {
    if (widget.credentialVerifier != null) {
      if (mounted) {
        setState(() => _authenticated = true);
      }
      return;
    }
    await windowManager.setTitleBarStyle(TitleBarStyle.normal);
    await windowManager.setMinimumSize(const Size(1024, 700));
    await windowManager.setMaximumSize(const Size(1920, 1200));
    await windowManager.setSize(const Size(1280, 800));
    await windowManager.center();
    await windowManager.setTitle(AppConstants.appName);
    if (mounted) {
      setState(() => _authenticated = true);
    }
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: AppConstants.appName,
    debugShowCheckedModeBanner: false,
    theme: AppTheme.lightTheme,
    home: AuthenticationGate(
      credentialVerifier: widget.credentialVerifier,
      onAuthenticated: _openMainWindow,
      authenticatedChild: _authenticated
          ? Navigator(
              key: const ValueKey('authenticatedNavigator'),
              initialRoute: RouteNames.home,
              onGenerateRoute: AppRouter.onGenerateRoute,
            )
          : null,
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../../../../app/router/navigation_config.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/widgets/app_status_bar.dart';
import '../../../../core/services/firm_session.dart';
import '../../../../shared/models/firm.dart';
import '../../../authentication/presentation/widgets/change_password_dialog.dart';
import '../widgets/firm_dialogs.dart';
import '../widgets/year_select_dialog.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.title, required this.child, super.key});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: Column(
      children: [
        const _InformationBar(),
        _TopMenu(title: title),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppLeftNavigation(),
              Expanded(child: child),
            ],
          ),
        ),
        const AppStatusBar(),
      ],
    ),
  );
}

class _InformationBar extends StatelessWidget {
  const _InformationBar();

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: FirmSession.instance,
    builder: (context, _) {
      final profile = FirmSession.instance.current;
      return Container(
        height: 25,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        color: AppColors.header,
        alignment: Alignment.centerLeft,
        child: Text(
          '(${profile.financialYear}) - CODEASHION TECHNOLOGIES    '
          'MILL Base Id: ${profile.code}    '
          'Client Name: ${profile.name}    Area: ${profile.area}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 11, color: AppColors.textPrimary),
        ),
      );
    },
  );
}

class _TopMenu extends StatelessWidget {
  const _TopMenu({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 31,
      decoration: BoxDecoration(
        color: AppColors.header,
        border: Border.all(color: AppColors.border),
      ),
      alignment: Alignment.centerLeft,
      child: MenuBar(
        style: const MenuStyle(
          backgroundColor: WidgetStatePropertyAll(AppColors.header),
          padding: WidgetStatePropertyAll(EdgeInsets.zero),
        ),
        children: NavigationConfig.topMenu
            .map((item) => _buildMenuItem(context, item))
            .toList(),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, AppMenuItem item) {
    final label = Text(
      item.title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );

    if (item.children.isEmpty) {
      return MenuItemButton(
        onPressed: () {
          if (item.route != null) {
            Navigator.pushReplacementNamed(context, item.route!);
          }
        },
        child: label,
      );
    }

    return SubmenuButton(
      menuChildren: item.children
          .map((child) => _buildNestedMenuItem(context, child))
          .toList(),
      child: label,
    );
  }

  Widget _buildNestedMenuItem(BuildContext context, AppMenuItem item) {
    final label = Text(
      item.title,
      style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
    );

    if (item.children.isEmpty) {
      return MenuItemButton(
        onPressed: () {
          if (item.route != null) {
            Navigator.pushReplacementNamed(context, item.route!);
          } else if (item.title == 'Change Password') {
            showDialog<bool>(
              context: context,
              builder: (_) => const ChangePasswordDialog(),
            );
          } else if (item.title == 'New User') {
            showDialog<Firm>(
              context: context,
              builder: (_) => const NewFirmDialog(),
            );
          } else if (item.title == 'Edit User') {
            showDialog<bool>(
              context: context,
              builder: (_) => const EditFirmDialog(),
            );
          } else if (item.title == 'Firm Select') {
            showDialog<Firm>(
              context: context,
              builder: (_) => const FirmSelectDialog(),
            );
          } else if (item.title == 'Year Select') {
            showDialog<String>(
              context: context,
              builder: (_) => const YearSelectDialog(),
            );
          } else if (item.title == 'Exit') {
            _confirmExit(context);
          }
        },
        child: label,
      );
    }

    return SubmenuButton(
      menuChildren: item.children
          .map((child) => _buildNestedMenuItem(context, child))
          .toList(),
      child: label,
    );
  }

  Future<void> _confirmExit(BuildContext context) async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Exit Billing Software'),
        content: const Text('Are you sure you want to exit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            icon: const Icon(Icons.exit_to_app),
            label: const Text('Exit'),
          ),
        ],
      ),
    );
    if (shouldExit == true) {
      await windowManager.close();
    }
  }
}

class AppLeftNavigation extends StatelessWidget {
  const AppLeftNavigation({super.key});

  @override
  Widget build(BuildContext context) => Container(
    width: AppDimensions.sidebarWidth,
    color: AppColors.sidebar,
    child: Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: NavigationConfig.sidebar.length,
            itemBuilder: (context, index) {
              final item = NavigationConfig.sidebar[index];
              final active =
                  ModalRoute.of(context)?.settings.name == item.route;
              return Tooltip(
                message: item.title,
                child: InkWell(
                  onTap: () =>
                      Navigator.pushReplacementNamed(context, item.route),
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: active ? AppColors.sidebarActive : null,
                      border: const Border(
                        bottom: BorderSide(color: AppColors.divider),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 4,
                          left: 0,
                          right: 0,
                          child: Icon(
                            item.icon,
                            size: 21,
                            color: AppColors.primary,
                          ),
                        ),
                        Positioned(
                          bottom: 2,
                          left: 0,
                          right: 0,
                          child: Text(
                            item.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        InkWell(
          onTap: () {},
          child: const SizedBox(
            height: 48,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.visibility_off_outlined,
                  size: 22,
                  color: AppColors.primary,
                ),
                Text(
                  'Hide',
                  style: TextStyle(fontSize: 11, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

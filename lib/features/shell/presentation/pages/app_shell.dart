import 'package:flutter/material.dart';

import '../../../../app/router/navigation_config.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/widgets/app_status_bar.dart';
import '../../../../shared/models/company_profile.dart';

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
  Widget build(BuildContext context) {
    const profile = CompanyProfile.defaults;
    return Container(
      height: 25,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      color: AppColors.header,
      alignment: Alignment.centerLeft,
      child: Text(
        '(${profile.financialYear}) - ${profile.softwareCompanyName}    '
        'MILL Base Id: ${profile.millBaseId}    '
        'Client Name: ${profile.clientName}    Area: ${profile.area}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 11, color: AppColors.textPrimary),
      ),
    );
  }
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

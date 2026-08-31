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

class _TopMenu extends StatefulWidget {
  const _TopMenu({required this.title});
  final String title;

  @override
  State<_TopMenu> createState() => _TopMenuState();
}

class _TopMenuState extends State<_TopMenu> {
  String? _openMenu;
  String? _hoveredItem;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppColors.header,
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      children: [
        SizedBox(
          height: 31,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            child: Row(
              children: NavigationConfig.topMenu
                  .map((item) => _menuButton(item))
                  .toList(),
            ),
          ),
        ),
        if (_openMenu != null) _dropdownFor(_openMenu!),
      ],
    ),
  );

  Widget _menuButton(AppMenuItem item) {
    final active = item.title == widget.title || _openMenu == item.title;
    return InkWell(
      onTap: () {
        if (item.children.isNotEmpty) {
          setState(() {
            _openMenu = _openMenu == item.title ? null : item.title;
            _hoveredItem = null;
          });
          return;
        }
        _navigate(item.route);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        alignment: Alignment.center,
        color: active ? AppColors.sidebarActive : null,
        child: Text(
          item.title,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _dropdownFor(String title) {
    final menu = NavigationConfig.topMenu.firstWhere(
      (item) => item.title == title,
    );
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(minWidth: 210, maxWidth: 360),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: menu.children.map(_dropdownItem).toList(),
              ),
            ),
            if (_hoveredItem != null)
              Flexible(child: _nestedDropdown(menu.children.firstWhere((item) => item.title == _hoveredItem))),
          ],
        ),
      ),
    );
  }

  Widget _dropdownItem(AppMenuItem item) => MouseRegion(
    onEnter: (_) => item.children.isNotEmpty
        ? setState(() => _hoveredItem = item.title)
        : null,
    child: InkWell(
      onTap: () => item.children.isEmpty
          ? _navigate(item.route)
          : setState(() => _hoveredItem = item.title),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: _hoveredItem == item.title ? AppColors.sidebarActive : null,
          border: const Border(bottom: BorderSide(color: AppColors.divider)),
        ),
        child: Row(
          children: [
            Expanded(child: Text(item.title, style: const TextStyle(fontSize: 12))),
            if (item.children.isNotEmpty) const Icon(Icons.chevron_right, size: 16),
          ],
        ),
      ),
    ),
  );

  Widget _nestedDropdown(AppMenuItem item) => Column(
    mainAxisSize: MainAxisSize.min,
    children: item.children.map((child) => InkWell(
      onTap: () => _navigate(child.route),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.divider)),
        ),
        child: Text(child.title, style: const TextStyle(fontSize: 12)),
      ),
    )).toList(),
  );

  void _navigate(String? route) {
    if (route == null) return;
    setState(() {
      _openMenu = null;
      _hoveredItem = null;
    });
    Navigator.pushReplacementNamed(context, route);
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
                Text('Hide', style: TextStyle(fontSize: 11)),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

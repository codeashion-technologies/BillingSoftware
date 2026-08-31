import 'package:flutter/material.dart';

import 'route_names.dart';

class AppNavigationItem {
  const AppNavigationItem({
    required this.title,
    required this.icon,
    required this.route,
  });

  final String title;
  final IconData icon;
  final String route;
}

class AppMenuItem {
  const AppMenuItem({
    required this.title,
    this.route,
    this.children = const [],
  });

  final String title;
  final String? route;
  final List<AppMenuItem> children;
}

abstract final class NavigationConfig {
  static const sidebar = [
    AppNavigationItem(
      title: 'User',
      icon: Icons.person_outline,
      route: RouteNames.dashboard,
    ),
    AppNavigationItem(
      title: 'Job',
      icon: Icons.work_outline,
      route: RouteNames.jobWork,
    ),
    AppNavigationItem(
      title: 'Sales',
      icon: Icons.shopping_cart_outlined,
      route: RouteNames.sales,
    ),
    AppNavigationItem(
      title: 'Purchase',
      icon: Icons.inventory_2_outlined,
      route: RouteNames.purchase,
    ),
    AppNavigationItem(
      title: 'Receipt',
      icon: Icons.account_balance_outlined,
      route: RouteNames.cashBank,
    ),
    AppNavigationItem(
      title: 'Payment',
      icon: Icons.payments_outlined,
      route: RouteNames.cashBank,
    ),
    AppNavigationItem(
      title: 'Ledger',
      icon: Icons.menu_book_outlined,
      route: RouteNames.financialReports,
    ),
    AppNavigationItem(
      title: 'Debtors',
      icon: Icons.hourglass_bottom,
      route: RouteNames.financialReports,
    ),
    AppNavigationItem(
      title: 'Creditors',
      icon: Icons.hourglass_top,
      route: RouteNames.financialReports,
    ),
    AppNavigationItem(
      title: 'GST',
      icon: Icons.receipt_long_outlined,
      route: RouteNames.financialReports,
    ),
  ];

  static const topMenu = [
    AppMenuItem(title: 'User', route: RouteNames.dashboard),
    AppMenuItem(
      title: 'Master',
      children: [
        AppMenuItem(
          title: 'Account Master',
          route: RouteNames.accountMaster,
          children: [
            AppMenuItem(title: 'Add Party', route: RouteNames.addParty),
            AppMenuItem(title: 'Find out party', route: RouteNames.findParty),
          ],
        ),
        AppMenuItem(title: 'Item Master', route: RouteNames.itemMaster),
      ],
    ),
    AppMenuItem(
      title: 'Transaction',
      children: [
        AppMenuItem(title: 'Sales', route: RouteNames.sales),
        AppMenuItem(title: 'Purchase', route: RouteNames.purchase),
      ],
    ),
    AppMenuItem(
      title: 'Cash & Bank',
      children: [
        AppMenuItem(
          title: 'Cash (Payment / Receive)',
          children: [
            AppMenuItem(title: 'Cash Receive', route: RouteNames.cashReceive),
            AppMenuItem(title: 'Cash Payment', route: RouteNames.cashPayment),
          ],
        ),
        AppMenuItem(
          title: 'Bank (Payment / Receive)',
          children: [
            AppMenuItem(title: 'Bank Receive', route: RouteNames.bankReceive),
            AppMenuItem(title: 'Bank Payment', route: RouteNames.bankPayment),
          ],
        ),
      ],
    ),
    AppMenuItem(title: 'Reports', route: RouteNames.financialReports),
    AppMenuItem(title: 'Financial Report', route: RouteNames.financialReports),
    AppMenuItem(title: 'Job Work', route: RouteNames.jobWork),
    AppMenuItem(title: 'Inventory', route: RouteNames.itemMaster),
    AppMenuItem(title: 'Utility', route: RouteNames.utilities),
    AppMenuItem(title: 'Auto Update', route: RouteNames.settings),
  ];
}

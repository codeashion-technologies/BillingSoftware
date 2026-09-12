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
    AppMenuItem(
      title: 'User',
      children: [
        AppMenuItem(title: 'New User'),
        AppMenuItem(title: 'Edit User'),
        AppMenuItem(title: 'Change Password'),
        AppMenuItem(title: 'Firm Select'),
        AppMenuItem(title: 'Year Select'),
        AppMenuItem(title: 'Calculator'),
        AppMenuItem(title: 'Exit'),
      ],
    ),
    AppMenuItem(
      title: 'Master',
      children: [
        AppMenuItem(title: 'Account Master', route: RouteNames.accountMaster),
        AppMenuItem(title: 'Item Master', route: RouteNames.itemMaster),
        AppMenuItem(title: 'Broker'),
        AppMenuItem(title: 'Transport'),
        AppMenuItem(title: 'Party Wise Print'),
        AppMenuItem(title: 'Change HSN/GST Rate – All Items'),
        AppMenuItem(title: 'Send Mail'),
      ],
    ),
    AppMenuItem(
      title: 'Transaction',
      children: [
        AppMenuItem(
          title: 'Sales',
          children: [
            AppMenuItem(title: 'Sales', route: RouteNames.sales),
            AppMenuItem(title: 'Sales Return'),
          ],
        ),
        AppMenuItem(
          title: 'Purchase',
          children: [
            AppMenuItem(title: 'Purchase', route: RouteNames.purchase),
            AppMenuItem(title: 'Purchase Return'),
            AppMenuItem(title: 'General Expenses'),
          ],
        ),
        AppMenuItem(title: 'Credit Note', route: RouteNames.creditNote),
        AppMenuItem(title: 'Debit Note', route: RouteNames.debitNote),
        AppMenuItem(title: 'Opening Balance'),
      ],
    ),
    AppMenuItem(
      title: 'Cash & Bank',
      children: [
        AppMenuItem(
          title: 'Cash Payment & Receipt',
          route: RouteNames.cashPaymentReceipt,
        ),
        AppMenuItem(
          title: 'Bank Payment & Receipt',
          route: RouteNames.bankPaymentReceipt,
        ),
        AppMenuItem(
          title: 'Journal Entry',
          children: [
            AppMenuItem(title: 'Bill Base'),
            AppMenuItem(title: 'General'),
          ],
        ),
        AppMenuItem(title: 'Bank Reconciliation'),
        AppMenuItem(title: 'Exit'),
      ],
    ),
    AppMenuItem(
      title: 'Reports',
      children: [
        AppMenuItem(
          title: 'Stock',
          children: [
            AppMenuItem(title: 'Register Summary'),
            AppMenuItem(title: 'Statement'),
            AppMenuItem(title: 'Register'),
            AppMenuItem(title: 'Register – GroupWise'),
          ],
        ),
        AppMenuItem(
          title: 'Register',
          children: [
            AppMenuItem(title: 'Bank Book'),
            AppMenuItem(title: 'Cash Book'),
            AppMenuItem(title: 'Journal Book'),
            AppMenuItem(title: 'Day Book'),
            AppMenuItem(title: 'General Expenses'),
            AppMenuItem(title: 'Cash & Bank Voucher Point'),
          ],
        ),
        AppMenuItem(
          title: 'Purchase',
          children: [
            AppMenuItem(title: 'Bill Wise Summary'),
            AppMenuItem(title: 'Bill Wise Register'),
            AppMenuItem(title: 'Item Wise Summary'),
            AppMenuItem(title: 'Monthly Summary'),
            AppMenuItem(title: 'Purchase TDS Summary'),
          ],
        ),
        AppMenuItem(
          title: 'Sales',
          children: [
            AppMenuItem(title: 'Bill Wise Summary'),
            AppMenuItem(title: 'Bill Wise Register'),
            AppMenuItem(title: 'Item Wise Summary'),
            AppMenuItem(title: 'Monthly Summary'),
            AppMenuItem(title: 'Sales TDS Summary'),
          ],
        ),
        AppMenuItem(
          title: 'Outstanding',
          children: [
            AppMenuItem(title: 'Sales Party Wise'),
            AppMenuItem(title: 'Sales Broker Wise'),
            AppMenuItem(title: 'Sales Bill Wise Details'),
            AppMenuItem(title: 'Purchase Party Wise'),
            AppMenuItem(title: 'Purchase Broker Wise'),
            AppMenuItem(title: 'Purchase Bill Wise Detail'),
            AppMenuItem(title: 'Aging Outstanding Report'),
            AppMenuItem(title: 'Sales – Purchase Interest Calculation'),
          ],
        ),
        AppMenuItem(
          title: 'GST Details Register',
          children: [
            AppMenuItem(title: 'Sales'),
            AppMenuItem(title: 'Purchase'),
            AppMenuItem(title: 'Credit/Debit Note'),
            AppMenuItem(title: 'Credit/Debit Note { All Tax }'),
          ],
        ),
        AppMenuItem(
          title: 'GST File Register',
          children: [
            AppMenuItem(title: 'GSTR-1'),
            AppMenuItem(title: 'GSTR-2 / 2A'),
            AppMenuItem(title: 'GSTR-3B'),
            AppMenuItem(title: 'GSTR-9'),
            AppMenuItem(title: 'GST Audit'),
            AppMenuItem(title: 'Book Wise Details'),
            AppMenuItem(title: 'GST Lock'),
          ],
        ),
      ],
    ),
    AppMenuItem(
      title: 'Financial Report',
      children: [
        AppMenuItem(title: 'Ledger'),
        AppMenuItem(title: 'Ledger (Challan Base)'),
        AppMenuItem(title: 'Trial Balance'),
        AppMenuItem(title: 'Trading Account'),
        AppMenuItem(title: 'Profit and Loss'),
        AppMenuItem(title: 'Balance Sheet'),
        AppMenuItem(title: 'Balance Sheet (Schedule)'),
        AppMenuItem(title: 'Trial Balance Detail'),
        AppMenuItem(title: 'Ledger (Multi)'),
        AppMenuItem(title: 'Payable/Receivable'),
        AppMenuItem(title: 'Bank Slip Print'),
        AppMenuItem(title: 'Interest Calculation'),
        AppMenuItem(title: 'TDS Head Wise Print'),
      ],
    ),
    AppMenuItem(
      title: 'Job Work',
      children: [
        AppMenuItem(
          title: 'Issue (Work Dispatch)',
          route: RouteNames.jobWorkIssue,
        ),
        AppMenuItem(
          title: 'Receive (Work Receive)',
          route: RouteNames.jobWorkReceive,
        ),
        AppMenuItem(title: 'Job Process Receive (Inward Challan)'),
        AppMenuItem(title: 'Job Process Issue (Outward Challan)'),
        AppMenuItem(title: 'Jobwork Receive (Inward)'),
        AppMenuItem(title: 'Jobwork Issue (Outward)'),
        AppMenuItem(title: 'Register'),
      ],
    ),
    AppMenuItem(
      title: 'Inventory',
      children: [
        AppMenuItem(title: 'Stock Issue'),
        AppMenuItem(title: 'Stock Receive'),
        AppMenuItem(
          title: 'Stock Register',
          children: [
            AppMenuItem(title: 'Issue'),
            AppMenuItem(title: 'Receive'),
          ],
        ),
        AppMenuItem(title: 'Godown Issue'),
        AppMenuItem(title: 'Godown Receive'),
        AppMenuItem(
          title: 'Godown Register',
          children: [
            AppMenuItem(title: 'Issue'),
            AppMenuItem(title: 'Receive'),
          ],
        ),
      ],
    ),
    AppMenuItem(
      title: 'Utility',
      children: [
        AppMenuItem(title: 'Company Profile'),
        AppMenuItem(title: 'Book Create'),
        AppMenuItem(title: 'Other Utility'),
        AppMenuItem(title: 'Outstanding Add (Last Year)'),
        AppMenuItem(title: 'Delete Last Year Bill'),
        AppMenuItem(title: 'Year'),
        AppMenuItem(title: 'Send Backup by Email'),
      ],
    ),
    AppMenuItem(
      title: 'Auto Update',
      children: [AppMenuItem(title: 'Auto Update')],
    ),
  ];
}

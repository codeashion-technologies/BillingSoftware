import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../../features/account_master/presentation/pages/account_master_page.dart';
import '../../features/cash_bank/presentation/pages/cash_payment_receipt_split_page.dart';
import '../../features/cash_bank/presentation/pages/bank_payment_receipt_split_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/item_master/presentation/pages/item_master_page.dart';
import '../../features/job_work/presentation/pages/job_work_receive_page.dart';
import '../../features/job_work/presentation/pages/job_work_issue_page.dart';
import '../../features/transactions/presentation/pages/credit_note_page.dart';
import '../../features/transactions/presentation/pages/debit_note_page.dart';
import '../../features/shell/presentation/pages/app_shell.dart';
import 'route_names.dart';

abstract final class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final route = settings.name ?? RouteNames.home;
    final page = switch (route) {
      RouteNames.home => const HomePage(),
      RouteNames.accountMaster => const AccountMasterPage(),
      RouteNames.itemMaster => const ItemMasterPage(),
      RouteNames.jobWorkReceive => const JobWorkReceivePage(),
      RouteNames.jobWorkIssue => const JobWorkIssuePage(),
      RouteNames.creditNote => const CreditNotePage(),
      RouteNames.debitNote => const DebitNotePage(),
      RouteNames.cashPaymentReceipt => const CashPaymentReceiptSplitPage(),
      RouteNames.bankPaymentReceipt => const BankPaymentReceiptSplitPage(),
      _ => PlaceholderPage(title: _titleFor(route)),
    };
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => AppShell(title: _titleFor(route), child: page),
    );
  }

  static String _titleFor(String route) => switch (route) {
    RouteNames.home => 'Home',
    RouteNames.dashboard => 'Dashboard',
    RouteNames.accountMaster => 'Account Master',
    RouteNames.itemMaster => 'Item Master',
    RouteNames.cashBank => 'Cash & Bank',
    RouteNames.jobWork => 'Job Work',
    RouteNames.jobWorkReceive => 'Job Work Receive',
    RouteNames.jobWorkIssue => 'Job Work Issue',
    RouteNames.transactions => 'Transactions',
    RouteNames.financialReports => 'Financial Reports',
    RouteNames.utilities => 'Utilities',
    RouteNames.backupRestore => 'Backup & Restore',
    RouteNames.settings => 'Settings',
    RouteNames.sales => 'Sales',
    RouteNames.purchase => 'Purchase',
    RouteNames.creditNote => 'Credit Note',
    RouteNames.debitNote => 'Debit Note',
    RouteNames.companyProfile => 'Company Profile',
    RouteNames.addParty => 'Add Party',
    RouteNames.findParty => 'Find out party',
    RouteNames.cashReceive => 'Cash Receive',
    RouteNames.cashPayment => 'Cash Payment',
    RouteNames.cashPaymentReceipt => 'Cash Payment & Receipt',
    RouteNames.bankReceive => 'Bank Receive',
    RouteNames.bankPayment => 'Bank Payment',
    RouteNames.bankPaymentReceipt => 'Bank Payment & Receipt',
    _ => 'Dashboard',
  };
}

class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({required this.title, super.key});
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 35,
          color: AppColors.primary,
          alignment: Alignment.center,
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 8),
        _FormStrip(title: title),
        const SizedBox(height: 8),
        Expanded(child: _DataGrid(title: title)),
        const SizedBox(height: 8),
        const _BottomActionBar(),
      ],
    ),
  );
}

class _FormStrip extends StatelessWidget {
  const _FormStrip({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(8),
    color: AppColors.formBackground,
    child: Wrap(
      spacing: 12,
      runSpacing: 6,
      children:
          [
            'Book',
            'Lot No',
            'Lot Date',
            'Party',
            'Broker',
            'Quality',
            'Remarks',
          ].map((label) {
            return SizedBox(
              width: label == 'Remarks' ? 280 : 150,
              height: 28,
              child: Row(
                children: [
                  SizedBox(
                    width: 62,
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    ),
  );
}

class _DataGrid extends StatelessWidget {
  const _DataGrid({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final columns = [
      'Sr No',
      'Party Name',
      'Bill No',
      'Bill Date',
      'Bill Amount',
      'Due Date',
      'Unpaid',
    ];
    return Container(
      decoration: BoxDecoration(border: Border.all(color: AppColors.border)),
      child: Column(
        children: [
          Container(
            height: 28,
            color: AppColors.tableHeader,
            child: Row(
              children: columns
                  .map(
                    (column) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Text(
                          column,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 12,
              itemBuilder: (_, index) => Container(
                height: 26,
                color: index.isEven
                    ? AppColors.tableBackground
                    : AppColors.tableAlternateRow,
                child: Row(
                  children: columns
                      .map(
                        (_) => const Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: Text(''),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar();

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: ['New', 'Find', 'Save', 'Cancel', 'Delete', 'Print', 'Exit']
          .map(
            (label) => Padding(
              padding: const EdgeInsets.only(right: 6),
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: Icon(_iconFor(label), size: 14),
                label: Text(label),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 9),
                  minimumSize: const Size(0, 28),
                ),
              ),
            ),
          )
          .toList(),
    ),
  );

  static IconData _iconFor(String label) => switch (label) {
    'New' => Icons.add,
    'Find' => Icons.search,
    'Save' => Icons.save_outlined,
    'Cancel' => Icons.close,
    'Delete' => Icons.delete_outline,
    'Print' => Icons.print_outlined,
    _ => Icons.exit_to_app,
  };
}

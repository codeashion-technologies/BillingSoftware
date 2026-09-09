// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:accounting_software/app/app.dart';
import 'package:accounting_software/app/router/navigation_config.dart';
import 'package:accounting_software/app/router/route_names.dart';
import 'package:accounting_software/app/theme/app_colors.dart';
import 'package:accounting_software/features/account_master/presentation/pages/account_master_page.dart';
import 'package:accounting_software/features/cash_bank/presentation/pages/bank_payment_receipt_split_page.dart';
import 'package:accounting_software/features/job_work/presentation/pages/job_work_receive_page.dart';
import 'package:accounting_software/features/job_work/presentation/pages/job_work_issue_page.dart';
import 'package:accounting_software/features/transactions/presentation/pages/credit_note_page.dart';
import 'package:accounting_software/features/transactions/presentation/pages/debit_note_page.dart';

void main() {
  testWidgets('application shell loads', (WidgetTester tester) async {
    await tester.pumpWidget(const AccountingApp());
    expect(find.textContaining('CODEASHION TECHNOLOGIES'), findsNWidgets(3));
    expect(find.text('Job'), findsOneWidget);
    expect(find.text('Financial Report'), findsOneWidget);
    expect(find.text('MILL BASE'), findsOneWidget);
  });

  testWidgets('master menu includes account master route', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AccountingApp());

    final masterMenu = NavigationConfig.topMenu.firstWhere(
      (item) => item.title == 'Master',
    );
    expect(
      masterMenu.children.any(
        (item) =>
            item.title == 'Account Master' &&
            item.route == RouteNames.accountMaster,
      ),
      isTrue,
    );
  });

  testWidgets('shell menu labels use readable text colors', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AccountingApp());

    final financialReportText = tester.widget<Text>(
      find.text('Financial Report'),
    );
    expect(financialReportText.style?.color, AppColors.textPrimary);

    final hideText = tester.widget<Text>(find.text('Hide'));
    expect(hideText.style?.color, AppColors.textPrimary);
  });

  testWidgets('cash payment and receipt open side by side', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Text('placeholder'))),
    );

    final cashMenu = NavigationConfig.topMenu.firstWhere(
      (item) => item.title == 'Cash & Bank',
    );
    expect(
      cashMenu.children.any(
        (item) =>
            item.title == 'Cash Payment & Receipt' &&
            item.route == RouteNames.cashPaymentReceipt,
      ),
      isTrue,
    );
  });

  testWidgets('bank payment and receipt split fits desktop layout', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: BankPaymentReceiptSplitPage())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bank Payment'), findsOneWidget);
    expect(find.text('Bank Receipt'), findsOneWidget);
    expect(find.text('No transactions yet'), findsNWidgets(2));
  });

  testWidgets('job work receive adds details and calculates totals', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: JobWorkReceivePage())),
    );

    final metersField = find.byKey(const ValueKey('Meters'));
    final weightField = find.byKey(const ValueKey('Weight'));
    final markaField = find.byKey(const ValueKey('Marka'));
    final remarksField = find.byKey(const ValueKey('Remarks'));
    expect(
      tester.getTopLeft(metersField).dy,
      tester.getTopLeft(weightField).dy,
    );
    expect(tester.getTopLeft(metersField).dy, tester.getTopLeft(markaField).dy);
    expect(
      tester.getTopLeft(metersField).dy,
      tester.getTopLeft(remarksField).dy,
    );

    await tester.tap(metersField);
    await tester.enterText(find.byKey(const ValueKey('Meters')), '125');
    await tester.testTextInput.receiveAction(TextInputAction.next);
    expect(tester.widget<TextField>(weightField).focusNode?.hasFocus, isTrue);
    await tester.enterText(find.byKey(const ValueKey('Weight')), '30.5');
    await tester.testTextInput.receiveAction(TextInputAction.next);
    expect(tester.widget<TextField>(markaField).focusNode?.hasFocus, isTrue);
    await tester.enterText(find.byKey(const ValueKey('Marka')), 'A-12');
    await tester.testTextInput.receiveAction(TextInputAction.next);
    expect(tester.widget<TextField>(remarksField).focusNode?.hasFocus, isTrue);
    await tester.enterText(find.byKey(const ValueKey('Remarks')), 'Finished');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.text('1'), findsOneWidget);
    expect(find.text('125.00'), findsNWidgets(2));
    expect(find.text('Srno'), findsOneWidget);
    expect(find.text('IsFinished'), findsOneWidget);
    expect(find.text('Taka No'), findsNothing);
    expect(tester.widget<TextField>(metersField).focusNode?.hasFocus, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('job work issue fits desktop layout', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: JobWorkIssuePage())),
    );
    await tester.pumpAndSettle();

    expect(find.text('JOB WORK ISSUE FROM MILL'), findsOneWidget);
    expect(find.text('Grey Mtrs'), findsNWidgets(2));
    expect(find.text('Finish Mtrs'), findsNWidgets(2));
    expect(find.text('Return'), findsNWidgets(2));
    expect(find.text('Taka No'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('job work issue route opens from the application shell', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AccountingApp());
    final context = tester.element(find.text('CODEASHION TECHNOLOGIES').first);

    Navigator.of(context).pushReplacementNamed(RouteNames.jobWorkIssue);
    await tester.pumpAndSettle();

    expect(find.text('JOB WORK ISSUE FROM MILL'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('credit note fits the desktop form without overflow', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: CreditNotePage())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Credit Note'), findsOneWidget);
    expect(find.text('Bsic Amt'), findsOneWidget);
    expect(find.text('Bill Amount'), findsOneWidget);
  });

  testWidgets('debit note opens with purchase defaults without overflow', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: DebitNotePage())),
    );

    expect(find.text('Debit Note'), findsOneWidget);
    expect(find.text('Purchase Return'), findsOneWidget);
  });

  testWidgets('Account Master shows GST validation and autofill flow', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AccountMasterPage()));

    final gstField = find.byKey(const ValueKey('gstNoField'));
    final fetchButton = find.byKey(const ValueKey('fetchGstDetailsButton'));

    await tester.enterText(gstField, '27ABCDE1234F1Z5');
    await tester.ensureVisible(fetchButton);
    await tester.tap(fetchButton);
    await tester.pumpAndSettle();

    final nameField = tester.widget<TextField>(
      find.byKey(const ValueKey('nameField')),
    );
    expect(nameField.controller?.text, 'Alpha Industries Pvt. Ltd.');

    final cityField = tester.widget<TextField>(
      find.byKey(const ValueKey('cityField')),
    );
    expect(cityField.controller?.text, 'Mumbai');

    final stateField = tester.widget<TextField>(
      find.byKey(const ValueKey('stateField')),
    );
    expect(stateField.controller?.text, 'Maharashtra');

    await tester.enterText(gstField, 'INVALID');
    await tester.ensureVisible(fetchButton);
    await tester.tap(fetchButton);
    await tester.pumpAndSettle();

    expect(find.text('Please enter a valid GST number.'), findsOneWidget);
  });
}

// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:accounting_software/app/app.dart';
import 'package:accounting_software/app/theme/app_colors.dart';

void main() {
  testWidgets('application shell loads', (WidgetTester tester) async {
    await tester.pumpWidget(const AccountingApp());
    expect(find.textContaining('CODEASHION TECHNOLOGIES'), findsNWidgets(3));
    expect(find.text('Job'), findsOneWidget);
    expect(find.text('Financial Report'), findsOneWidget);
    expect(find.text('MILL BASE'), findsOneWidget);
  });

  testWidgets('desktop menu bar contains the required ERP hierarchy', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AccountingApp());

    await tester.tap(find.widgetWithText(SubmenuButton, 'User'));
    await tester.pumpAndSettle();
    expect(find.text('New User'), findsOneWidget);
    expect(find.text('Edit User'), findsOneWidget);
    expect(find.text('Firm Select'), findsOneWidget);

    await tester.tap(find.widgetWithText(SubmenuButton, 'Master'));
    await tester.pumpAndSettle();
    expect(find.text('Account Master'), findsOneWidget);
    expect(find.text('Broker'), findsOneWidget);
    expect(find.text('Send Mail'), findsOneWidget);

    await tester.tap(find.widgetWithText(SubmenuButton, 'Reports'));
    await tester.pumpAndSettle();
    expect(find.text('Bank Book'), findsOneWidget);
    expect(find.text('GSTR-1'), findsOneWidget);
    expect(find.text('Stock'), findsOneWidget);
    expect(find.text('Register Summary'), findsOneWidget);
    expect(find.text('GST Audit'), findsOneWidget);
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
}

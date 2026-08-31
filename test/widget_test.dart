// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:accounting_software/app/app.dart';

void main() {
  testWidgets('application shell loads', (WidgetTester tester) async {
    await tester.pumpWidget(const AccountingApp());
    expect(find.textContaining('CODEASHION TECHNOLOGIES'), findsNWidgets(3));
    expect(find.text('Job'), findsOneWidget);
    expect(find.text('Financial Report'), findsOneWidget);
    expect(find.text('MILL BASE'), findsOneWidget);
  });

  testWidgets('master menu exposes party actions on hover', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AccountingApp());

    await tester.tap(find.text('Master'));
    await tester.pumpAndSettle();
    expect(find.text('Account Master'), findsOneWidget);
    expect(find.text('Item Master'), findsOneWidget);

    await tester.tap(find.text('Account Master'));
    await tester.pumpAndSettle();
    expect(find.text('Add Party'), findsOneWidget);
    expect(find.text('Find out party'), findsOneWidget);
  });
}

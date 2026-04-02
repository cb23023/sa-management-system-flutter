import 'package:flutter_test/flutter_test.dart';
import 'package:sa_management_system_flutter/src/app.dart';

void main() {
  testWidgets('renders login screen shell', (WidgetTester tester) async {
    await tester.pumpWidget(const SaManagementSystemApp());

    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('SA Management System'), findsNothing);
  });
}

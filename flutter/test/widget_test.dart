import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:quicknurse/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const QuickNurseApp());
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationDestination), findsNWidgets(8));
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wellbeing/main.dart';

void main() {
  testWidgets('MyApp renders supplied initial screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MyApp(initialScreen: Scaffold(body: Text('Test screen'))),
    );

    expect(find.text('Test screen'), findsOneWidget);
  });
}

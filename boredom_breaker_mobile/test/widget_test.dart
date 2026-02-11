// Basic Flutter widget test for Boredom Breaker app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:boredom_breaker_mobile/main.dart';

void main() {
  testWidgets('App smoke test - renders without crashing', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BoredomBreakerApp());

    // Verify that the app renders successfully
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

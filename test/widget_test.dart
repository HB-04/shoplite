// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shoplite/main.dart';
import 'package:shoplite/core/di/service_locator.dart';

void main() {
  testWidgets('ShopLite app smoke test', (WidgetTester tester) async {
    // Initialize ServiceLocator for testing
    await ServiceLocator().init();
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ShopLiteApp());

    // Wait for initial loading to complete
    await tester.pump();

    // Wait for async data loading to complete
    await tester.pumpAndSettle();

    // Verify that our app starts with the catalog page.
    expect(find.text('ShopLite'), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);

    // Tap the theme toggle button.
    await tester.tap(find.byIcon(Icons.dark_mode_outlined));
    await tester.pumpAndSettle();

    // The app should still show the same elements after theme toggle.
    expect(find.text('ShopLite'), findsOneWidget);
    
    // Clean up
    ServiceLocator().dispose();
  });
}

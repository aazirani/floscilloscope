// Flutter widget tests for the floscilloscope example app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:floscilloscope/floscilloscope.dart';

void main() {
  group('Floscilloscope Example App Tests', () {
    testWidgets('should render the example app with oscilloscope widgets', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());

      // Verify that the app title is displayed
      expect(find.text('Flutter Demo Home Page'), findsOneWidget);

      // Verify that both oscilloscope widgets are present
      expect(find.byType(SimpleOscilloscope), findsOneWidget);
      expect(find.byType(AlternativeSimpleOscilloscope), findsOneWidget);

      // Pump a frame to ensure all widgets are built
      await tester.pump();
    });

    testWidgets('should display oscilloscope widgets with test data', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(const MyApp());

      // Wait for the app to settle
      await tester.pumpAndSettle();

      // Verify that the oscilloscope widgets render without throwing errors
      expect(find.byType(SimpleOscilloscope), findsOneWidget);
      expect(find.byType(AlternativeSimpleOscilloscope), findsOneWidget);

      // Verify the widgets are within the expected layout structure
      expect(find.byType(Flexible), findsAtLeastNWidgets(2));
      expect(find.byType(Column), findsAtLeastNWidgets(1));
    });

    testWidgets('should handle app navigation and structure', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(const MyApp());

      // Verify the app bar is present
      expect(find.byType(AppBar), findsOneWidget);

      // Verify the scaffold structure
      expect(find.byType(Scaffold), findsOneWidget);

      // Verify the main content area has Center widgets
      expect(find.byType(Center), findsAtLeastNWidgets(1));

      // Wait for animations to complete
      await tester.pumpAndSettle();
    });
  });
}

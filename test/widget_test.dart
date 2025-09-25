// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rhythmic/screens/home_screen.dart';

void main() {
  testWidgets('HomeScreen displays correctly', (WidgetTester tester) async {
    // Build the HomeScreen directly to avoid timer issues from SplashScreen.
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );

    // Verify that the app title appears.
    expect(find.text('Rhythmic'), findsOneWidget);

    // Verify the initial BPM display.
    expect(find.text('0.0'), findsOneWidget);
    expect(find.text('BPM'), findsOneWidget);
  });
}
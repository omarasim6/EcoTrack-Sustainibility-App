import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sustainability_app/screens/home_screen.dart';

void main() {
  testWidgets('HomeScreen loads correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );

    // Check if app title appears
    expect(find.text('EcoTrack'), findsOneWidget);

    // Check if bottom nav icons exist
    expect(find.byIcon(Icons.home), findsOneWidget);
    expect(find.byIcon(Icons.person), findsOneWidget);
  });
}
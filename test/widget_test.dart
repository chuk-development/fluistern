import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fluistern_app/main.dart';

void main() {
  testWidgets('App starts successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FluisternApp());

    // Verify that the app title is present
    expect(find.text('Flüstern'), findsOneWidget);

    // Verify that the record button is present
    expect(find.byIcon(Icons.mic), findsOneWidget);
  });
}

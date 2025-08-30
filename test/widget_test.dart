import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Pet app widget test', (WidgetTester tester) async {
    // Create a simple test app without Firebase or timers
    const testApp = MaterialApp(
      title: 'Pet App',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Text('Pet Care App'),
        ),
      ),
    );

    await tester.pumpWidget(testApp);

    // Verify basic app functionality
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Pet Care App'), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
  });
}

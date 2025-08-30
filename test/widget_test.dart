import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petapp2/main.dart';
import 'package:petapp2/splash_screen.dart';

void main() {
  testWidgets('Pet app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify that our app loads without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
    
    // Verify the app title
    final MaterialApp app = tester.widget(find.byType(MaterialApp));
    expect(app.title, 'Pet App');
    
    // Verify that SplashScreen is the initial screen
    expect(find.byType(SplashScreen), findsOneWidget);
    
    // Verify debug banner is disabled
    expect(app.debugShowCheckedModeBanner, false);
  });
}

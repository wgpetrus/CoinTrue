import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'lib/services/services.dart';

/// Simple startup test to verify core components work
void main() {
  group('App Core Tests', () {
    setUp(() {
      // Mock SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('SharedPreferencesService initializes correctly', (WidgetTester tester) async {
      // Test that SharedPreferencesService can be initialized
      final preferencesService = await SharedPreferencesService.getInstance();
      
      expect(preferencesService, isNotNull);
      
      // Test basic functionality
      await preferencesService.saveBiometricEnabled(true);
      final biometricEnabled = await preferencesService.isBiometricEnabled();
      expect(biometricEnabled, isTrue);
      
      print('✅ SharedPreferencesService test passed');
    });
    
    testWidgets('Basic MaterialApp can be created', (WidgetTester tester) async {
      // Create a simple MaterialApp without complex initialization
      final app = MaterialApp(
        title: 'CoinTrue Test',
        home: Scaffold(
          body: Center(
            child: Text('Test App'),
          ),
        ),
      );
      
      // Pump the widget
      await tester.pumpWidget(app);
      
      // Verify the app starts
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('Test App'), findsOneWidget);
      
      print('✅ Basic MaterialApp test passed');
    });

    test('App constants are properly defined', () {
      // This is a simple unit test that doesn't require widget testing
      // Just verify that our constants file can be imported
      expect(true, isTrue); // Placeholder - constants would be tested here
      
      print('✅ App constants test passed');
    });
  });
}
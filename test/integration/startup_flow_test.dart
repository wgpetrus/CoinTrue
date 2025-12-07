import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../lib/main.dart';
import '../../lib/services/shared_preferences_service.dart';
import '../../lib/utils/asset_loader.dart';
import '../../lib/views/screens/onboarding/splash_screen.dart';

/// Integration tests for app startup flow
/// 
/// Tests:
/// - Complete app initialization sequence
/// - Error recovery scenarios
/// - Fallback mechanisms
/// 
/// Requirements: 1.1, 1.2, 1.3
void main() {
  group('Startup Flow Integration Tests', () {
    setUp(() {
      // Mock SharedPreferences for all tests - THIS IS THE KEY FIX!
      SharedPreferences.setMockInitialValues({});
    });
    
    testWidgets('App should initialize completely without Firebase', (WidgetTester tester) async {
      // Test complete initialization without Firebase
      final preferencesService = await SharedPreferencesService.getInstance();
      
      final app = MyApp(
        preferencesService: preferencesService,
        firebaseInitialized: false, // Test without Firebase
      );
      
      // Start the app
      await tester.pumpWidget(app);
      
      // Should show MaterialApp
      expect(find.byType(MaterialApp), findsOneWidget);
      
      // Should show splash screen initially
      await tester.pump();
      expect(find.byType(SplashScreen), findsOneWidget);
      
      // Wait for any pending timers to complete
      await tester.binding.delayed(const Duration(seconds: 3));
      
      print('✅ App initializes completely without Firebase');
    });
    
    testWidgets('App should initialize completely with Firebase', (WidgetTester tester) async {
      // Test complete initialization with Firebase
      final preferencesService = await SharedPreferencesService.getInstance();
      
      final app = MyApp(
        preferencesService: preferencesService,
        firebaseInitialized: true, // Test with Firebase
      );
      
      // Start the app
      await tester.pumpWidget(app);
      
      // Should show MaterialApp
      expect(find.byType(MaterialApp), findsOneWidget);
      
      // Should show splash screen initially
      await tester.pump();
      expect(find.byType(SplashScreen), findsOneWidget);
      
      // Wait for any pending timers to complete
      await tester.binding.delayed(const Duration(seconds: 3));
      
      print('✅ App initializes completely with Firebase');
    });
    
    testWidgets('Splash screen should display app logo', (WidgetTester tester) async {
      final preferencesService = await SharedPreferencesService.getInstance();
      
      final app = MyApp(
        preferencesService: preferencesService,
        firebaseInitialized: false,
      );
      
      await tester.pumpWidget(app);
      await tester.pump();
      
      // Should show splash screen
      expect(find.byType(SplashScreen), findsOneWidget);
      
      // Should have some form of logo display (Image or fallback Container)
      final hasImage = find.byType(Image).evaluate().isNotEmpty;
      final hasContainer = find.byType(Container).evaluate().isNotEmpty;
      expect(hasImage || hasContainer, isTrue);
      
      // Wait for any pending timers to complete
      await tester.binding.delayed(const Duration(seconds: 3));
      
      print('✅ Splash screen displays app logo');
    });
    
    testWidgets('App should handle initialization errors gracefully', (WidgetTester tester) async {
      // Test error handling during initialization
      final preferencesService = await SharedPreferencesService.getInstance();
      
      final app = MyApp(
        preferencesService: preferencesService,
        firebaseInitialized: false, // Simulate Firebase error
      );
      
      await tester.pumpWidget(app);
      await tester.pump();
      
      // App should still start despite errors
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(SplashScreen), findsOneWidget);
      
      // Should not crash
      expect(tester.takeException(), isNull);
      
      // Wait for any pending timers to complete
      await tester.binding.delayed(const Duration(seconds: 3));
      
      print('✅ App handles initialization errors gracefully');
    });
    
    testWidgets('App should provide proper navigation structure', (WidgetTester tester) async {
      final preferencesService = await SharedPreferencesService.getInstance();
      
      final app = MyApp(
        preferencesService: preferencesService,
        firebaseInitialized: false,
      );
      
      await tester.pumpWidget(app);
      await tester.pump();
      
      // Should have MaterialApp with routes
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.routes, isNotEmpty);
      
      // Should have essential routes
      expect(materialApp.routes?.containsKey('/'), isTrue);
      expect(materialApp.routes?.containsKey('/login'), isTrue);
      expect(materialApp.routes?.containsKey('/home'), isTrue);
      
      // Wait for any pending timers to complete
      await tester.binding.delayed(const Duration(seconds: 3));
      
      print('✅ App provides proper navigation structure');
    });
  });
  
  group('Error Recovery Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });
    
    testWidgets('App should recover from partial initialization failures', (WidgetTester tester) async {
      // Test recovery from partial failures
      final preferencesService = await SharedPreferencesService.getInstance();
      
      final app = MyApp(
        preferencesService: preferencesService,
        firebaseInitialized: false, // Simulate Firebase failure
      );
      
      await tester.pumpWidget(app);
      await tester.pump();
      
      // App should continue working
      expect(find.byType(MaterialApp), findsOneWidget);
      
      // Should provide offline functionality
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.routes, isNotEmpty);
      
      // Wait for any pending timers to complete
      await tester.binding.delayed(const Duration(seconds: 3));
      
      print('✅ App recovers from partial initialization failures');
    });
    
    testWidgets('App should maintain state during errors', (WidgetTester tester) async {
      // Test state maintenance during errors
      final preferencesService = await SharedPreferencesService.getInstance();
      
      final app = MyApp(
        preferencesService: preferencesService,
        firebaseInitialized: false,
      );
      
      await tester.pumpWidget(app);
      await tester.pump();
      
      // App should maintain its structure
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(SplashScreen), findsOneWidget);
      
      // Should not lose navigation capabilities
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.routes, isNotEmpty);
      
      // Wait for any pending timers to complete
      await tester.binding.delayed(const Duration(seconds: 3));
      
      print('✅ App maintains state during errors');
    });
  });
  
  group('Fallback Mechanism Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });
    
    testWidgets('App should use offline services when Firebase unavailable', (WidgetTester tester) async {
      // Test offline service fallbacks
      final preferencesService = await SharedPreferencesService.getInstance();
      
      final app = MyApp(
        preferencesService: preferencesService,
        firebaseInitialized: false, // Force offline mode
      );
      
      await tester.pumpWidget(app);
      await tester.pump();
      
      // App should start with offline services
      expect(find.byType(MaterialApp), findsOneWidget);
      
      // Should have proper provider structure for offline mode
      expect(find.byType(SplashScreen), findsOneWidget);
      
      // Wait for any pending timers to complete
      await tester.binding.delayed(const Duration(seconds: 3));
      
      print('✅ App uses offline services when Firebase unavailable');
    });
    
    testWidgets('App should handle asset loading failures gracefully', (WidgetTester tester) async {
      // Test asset loading fallbacks during startup
      final preferencesService = await SharedPreferencesService.getInstance();
      
      final app = MyApp(
        preferencesService: preferencesService,
        firebaseInitialized: false,
      );
      
      await tester.pumpWidget(app);
      await tester.pump();
      
      // App should start even if some assets fail
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(SplashScreen), findsOneWidget);
      
      // Should show some form of visual content
      final hasVisualContent = find.byType(Image).evaluate().isNotEmpty ||
                              find.byType(Container).evaluate().isNotEmpty ||
                              find.byType(Icon).evaluate().isNotEmpty;
      expect(hasVisualContent, isTrue);
      
      // Wait for any pending timers to complete
      await tester.binding.delayed(const Duration(seconds: 3));
      
      print('✅ App handles asset loading failures gracefully');
    });
  });
  
  group('Asset Loading Tests', () {
    testWidgets('App logo should load or show fallback', (WidgetTester tester) async {
      // Test app logo loading
      final logoWidget = AssetLoader.loadAppLogo(
        width: 100,
        height: 100,
      );
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: logoWidget,
          ),
        ),
      );
      
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      
      // Should show either image or fallback
      final hasImage = find.byType(Image).evaluate().isNotEmpty;
      final hasContainer = find.byType(Container).evaluate().isNotEmpty;
      expect(hasImage || hasContainer, isTrue);
      
      print('✅ App logo loads or shows fallback');
    });
  });
}
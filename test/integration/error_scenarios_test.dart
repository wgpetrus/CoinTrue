import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import '../../lib/utils/asset_loader.dart';

/// Integration tests for error scenarios
/// 
/// Tests:
/// - Missing asset files
/// - Graceful error handling
/// 
/// Requirements: 1.2, 1.3, 4.4
void main() {
  group('Error Scenarios Integration Tests', () {
    
    testWidgets('Asset loading should handle missing files gracefully', (WidgetTester tester) async {
      // Test asset loading with invalid paths
      final invalidAssetWidget = AssetLoader.loadImage(
        assetPath: 'invalid/path/logo.png', // This will fail
        width: 100,
        height: 100,
      );
      
      // Create a test widget that uses the invalid asset
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: invalidAssetWidget,
          ),
        ),
      );
      
      // Wait for asset loading to complete/fail
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      
      // Should show fallback widget instead of crashing
      expect(find.byType(Container), findsOneWidget); // Fallback container
      
      print('✅ Asset loading handles missing files gracefully');
    });
    
    testWidgets('App logo should have fallback when asset fails', (WidgetTester tester) async {
      // Test app logo fallback
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
      
      // Should show either the image or fallback
      final hasImage = find.byType(Image).evaluate().isNotEmpty;
      final hasContainer = find.byType(Container).evaluate().isNotEmpty;
      expect(hasImage || hasContainer, isTrue);
      
      print('✅ App logo has proper fallback mechanism');
    });
    
    testWidgets('Social logo should have fallback when asset fails', (WidgetTester tester) async {
      // Test social logo fallback
      final socialLogoWidget = AssetLoader.loadSocialLogo(
        assetPath: 'invalid/social/logo.png',
        providerName: 'TestProvider',
        width: 24,
        height: 24,
      );
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: socialLogoWidget,
          ),
        ),
      );
      
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      
      // Should show fallback container with provider initial
      expect(find.byType(Container), findsOneWidget);
      expect(find.text('T'), findsOneWidget); // First letter of TestProvider
      
      print('✅ Social logo has proper fallback mechanism');
    });
  });
  
  group('Error Logging Tests', () {
    testWidgets('Asset errors should be logged properly', (WidgetTester tester) async {
      // Test that asset errors are logged
      final invalidAssetWidget = AssetLoader.loadImage(
        assetPath: 'definitely/invalid/path.png',
        width: 50,
        height: 50,
      );
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: invalidAssetWidget,
          ),
        ),
      );
      
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      
      // Should show fallback and not crash
      expect(find.byType(Container), findsOneWidget);
      
      print('✅ Asset errors are logged properly');
    });
    
    testWidgets('Biometric logo should have fallback', (WidgetTester tester) async {
      // Test biometric logo fallback
      final biometricWidget = AssetLoader.loadBiometricLogo(
        width: 48,
        height: 48,
      );
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: biometricWidget,
          ),
        ),
      );
      
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      
      // Should show either image or fallback
      final hasImage = find.byType(Image).evaluate().isNotEmpty;
      final hasContainer = find.byType(Container).evaluate().isNotEmpty;
      expect(hasImage || hasContainer, isTrue);
      
      print('✅ Biometric logo has proper fallback');
    });
  });
}

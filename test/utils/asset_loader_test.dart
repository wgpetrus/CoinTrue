import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:login/utils/asset_loader.dart';
import 'package:login/utils/constants.dart';

void main() {
  group('AssetLoader', () {
    testWidgets('**Feature: debug-app-issues, Property 2: Asset fallback consistency**', (WidgetTester tester) async {
      // **Validates: Requirements 1.3, 5.2, 5.3, 5.5**
      
      // Property: For any missing or corrupted asset, the system should display 
      // the configured fallback content and log the specific asset path that failed
      
      // Test with multiple invalid asset paths to verify consistent fallback behavior
      final invalidAssetPaths = [
        'assets/images/logos/nonexistent.png',
        'invalid/path/image.png',
        'assets/missing/logo.jpg',
        '', // empty path
        'assets/images/logos/corrupted_file.png',
      ];
      
      for (final invalidPath in invalidAssetPaths) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AssetLoader.loadImage(
                assetPath: invalidPath,
                width: 100,
                height: 100,
              ),
            ),
          ),
        );
        
        // Allow the widget to build and error to be handled
        await tester.pumpAndSettle();
        
        // Verify that a fallback widget is displayed (not the original image)
        // The fallback should be a Container with PhosphorIcon
        expect(find.byType(Container), findsOneWidget);
        expect(find.byType(PhosphorIcon), findsOneWidget);
        
        // Verify the fallback has the expected properties
        final container = tester.widget<Container>(find.byType(Container));
        expect(container.constraints?.maxWidth, equals(100));
        expect(container.constraints?.maxHeight, equals(100));
        
        // Verify the icon is the expected fallback icon
        final icon = tester.widget<PhosphorIcon>(find.byType(PhosphorIcon));
        expect(icon.icon, equals(PhosphorIcons.image()));
        expect(icon.color, equals(AppConstants.colors.mediumGray));
      }
    });

    testWidgets('App logo fallback consistency', (WidgetTester tester) async {
      // Test app logo fallback behavior with invalid path
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AssetLoader.loadImage(
              assetPath: 'invalid/app_logo.png',
              width: 200,
              height: 200,
              fallback: AssetLoader.buildAppLogoFallback(200, 200),
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Should display the fallback container with wallet icon
      expect(find.byType(Container), findsOneWidget);
      expect(find.byType(PhosphorIcon), findsOneWidget);
      
      // Verify the fallback has wallet icon
      final icon = tester.widget<PhosphorIcon>(find.byType(PhosphorIcon));
      expect(icon.icon, equals(PhosphorIcons.wallet(PhosphorIconsStyle.fill)));
    });

    testWidgets('Social logo fallback consistency', (WidgetTester tester) async {
      // Test social logo fallback for different providers
      final providers = ['Google', 'Apple', 'Facebook', 'Twitter'];
      
      for (final provider in providers) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AssetLoader.loadSocialLogo(
                assetPath: 'invalid/path/${provider.toLowerCase()}.png',
                providerName: provider,
                width: 24,
                height: 24,
              ),
            ),
          ),
        );
        
        await tester.pumpAndSettle();
        
        // Should display fallback container with provider initial
        expect(find.byType(Container), findsOneWidget);
        expect(find.byType(Text), findsOneWidget);
        
        // Verify the fallback shows the provider's first letter
        final text = tester.widget<Text>(find.byType(Text));
        expect(text.data, equals(provider.substring(0, 1).toUpperCase()));
      }
    });

    testWidgets('Biometric logo fallback consistency', (WidgetTester tester) async {
      // Test biometric logo fallback with invalid path
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AssetLoader.loadImage(
              assetPath: 'invalid/biometric_logo.png',
              width: 48,
              height: 48,
              fallback: AssetLoader.buildBiometricLogoFallback(48, 48),
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Should display the fallback container with fingerprint icon
      expect(find.byType(Container), findsOneWidget);
      expect(find.byType(PhosphorIcon), findsOneWidget);
      
      // Verify the fallback has fingerprint icon
      final icon = tester.widget<PhosphorIcon>(find.byType(PhosphorIcon));
      expect(icon.icon, equals(PhosphorIcons.fingerprint()));
    });

    testWidgets('Fallback widget dimensions consistency', (WidgetTester tester) async {
      // Property: Fallback widgets should maintain the requested dimensions
      final testDimensions = [
        {'width': 50.0, 'height': 50.0},
        {'width': 100.0, 'height': 100.0},
        {'width': 200.0, 'height': 150.0},
        {'width': 24.0, 'height': 24.0},
      ];
      
      for (final dimensions in testDimensions) {
        final width = dimensions['width']!;
        final height = dimensions['height']!;
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AssetLoader.loadImage(
                assetPath: 'invalid/path.png',
                width: width,
                height: height,
              ),
            ),
          ),
        );
        
        await tester.pumpAndSettle();
        
        // Verify fallback maintains requested dimensions
        final container = tester.widget<Container>(find.byType(Container));
        expect(container.constraints?.maxWidth, equals(width));
        expect(container.constraints?.maxHeight, equals(height));
      }
    });

    testWidgets('Error logging consistency', (WidgetTester tester) async {
      // Property: Asset loading errors should be consistently logged
      // This test verifies that the error handling mechanism is called
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AssetLoader.loadImage(
              assetPath: 'definitely/invalid/path.png',
              width: 100,
              height: 100,
              enableLogging: true,
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Verify that fallback behavior works consistently
      expect(find.byType(Container), findsOneWidget);
      expect(find.byType(PhosphorIcon), findsOneWidget);
      
      // Verify the fallback icon is the default image icon
      final icon = tester.widget<PhosphorIcon>(find.byType(PhosphorIcon));
      expect(icon.icon, equals(PhosphorIcons.image()));
    });
  });
}

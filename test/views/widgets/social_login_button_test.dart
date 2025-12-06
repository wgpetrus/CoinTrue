import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:faker/faker.dart';

import 'package:login/views/widgets/common/social_login_button.dart';

void main() {
  late Faker faker;

  setUp(() {
    faker = Faker();
  });

  group('Property-Based Tests - SocialLoginButton', () {
    // Feature: autenticacao-cripto, Property 29: Desabilitação de botões durante processamento
    // Validates: Requirements 7.2
    testWidgets(
      'Property 29: Para qualquer processo de autenticação em andamento, o sistema '
      'deve desabilitar botões de ação para prevenir múltiplas submissões',
      (WidgetTester tester) async {
        // Run 100 iterations with random button configurations
        for (int i = 0; i < 100; i++) {
          // Generate random test parameters
          final randomProvider = faker.randomGenerator.boolean()
              ? SocialProvider.google
              : SocialProvider.apple;
          
          // Randomly decide if button is in loading state
          final isLoading = faker.randomGenerator.boolean();
          
          // Track if button was pressed
          bool buttonWasPressed = false;
          
          // Create callback that sets flag when called
          void onPressedCallback() {
            buttonWasPressed = true;
          }

          // Build the widget
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SocialLoginButton(
                  provider: randomProvider,
                  onPressed: onPressedCallback,
                  isLoading: isLoading,
                ),
              ),
            ),
          );

          // Find the button
          final buttonFinder = find.byType(ElevatedButton);
          expect(
            buttonFinder,
            findsOneWidget,
            reason: 'Should find exactly one ElevatedButton (iteration $i)',
          );

          // Get the button widget
          final ElevatedButton button = tester.widget(buttonFinder);

          // Assert: Verify button state based on loading status

          if (isLoading) {
            // 1. When loading, button should be disabled (onPressed should be null)
            expect(
              button.onPressed,
              isNull,
              reason: 'Button onPressed should be null when loading (iteration $i)',
            );

            // 2. Verify that tapping the button does nothing when loading
            buttonWasPressed = false;
            await tester.tap(buttonFinder);
            await tester.pump();

            expect(
              buttonWasPressed,
              isFalse,
              reason: 'Button callback should not be called when loading (iteration $i)',
            );

            // 3. Verify loading indicator is shown
            final loadingIndicatorFinder = find.byType(CircularProgressIndicator);
            expect(
              loadingIndicatorFinder,
              findsOneWidget,
              reason: 'Should show loading indicator when loading (iteration $i)',
            );

            // 4. Verify button text is replaced by spinner (no text shown)
            // The button shows ONLY the spinner when loading, not text
            final originalTextFinder = find.text(randomProvider == SocialProvider.google 
                ? 'Continuar com Google' 
                : 'Continuar com Apple');
            expect(
              originalTextFinder,
              findsNothing,
              reason: 'Should not show original text when loading (iteration $i)',
            );

            // 5. Verify button has disabled styling
            final buttonWidget = tester.widget<ElevatedButton>(buttonFinder);
            expect(
              buttonWidget.enabled,
              isFalse,
              reason: 'Button should be disabled when loading (iteration $i)',
            );

          } else {
            // When not loading, button should be enabled
            
            // 1. Button onPressed should not be null
            expect(
              button.onPressed,
              isNotNull,
              reason: 'Button onPressed should not be null when not loading (iteration $i)',
            );

            // 2. Verify that tapping the button calls the callback
            buttonWasPressed = false;
            await tester.tap(buttonFinder);
            await tester.pump();

            expect(
              buttonWasPressed,
              isTrue,
              reason: 'Button callback should be called when not loading (iteration $i)',
            );

            // 3. Verify loading indicator is NOT shown
            final loadingIndicatorFinder = find.byType(CircularProgressIndicator);
            expect(
              loadingIndicatorFinder,
              findsNothing,
              reason: 'Should not show loading indicator when not loading (iteration $i)',
            );

            // 4. Verify button shows appropriate text (not "processing")
            final processingTextFinder = find.text('Processando...');
            expect(
              processingTextFinder,
              findsNothing,
              reason: 'Should not show processing text when not loading (iteration $i)',
            );

            // 5. Verify button text matches provider
            final expectedText = randomProvider == SocialProvider.google
                ? 'Continuar com Google'
                : 'Continuar com Apple';
            
            final providerTextFinder = find.text(expectedText);
            expect(
              providerTextFinder,
              findsOneWidget,
              reason: 'Should show correct provider text when not loading (iteration $i)',
            );

            // 6. Verify button has enabled styling
            final buttonWidget = tester.widget<ElevatedButton>(buttonFinder);
            expect(
              buttonWidget.enabled,
              isTrue,
              reason: 'Button should be enabled when not loading (iteration $i)',
            );
          }

          // Additional verification: Test state transition from enabled to disabled
          // This simulates what happens when user taps button and operation starts
          
          // Reset the widget tree
          await tester.pumpWidget(Container());
          
          // Create button in enabled state
          buttonWasPressed = false;
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SocialLoginButton(
                  provider: randomProvider,
                  onPressed: onPressedCallback,
                  isLoading: false, // Start enabled
                ),
              ),
            ),
          );

          // Verify button is enabled
          final enabledButtonFinder = find.byType(ElevatedButton);
          final enabledButton = tester.widget<ElevatedButton>(enabledButtonFinder);
          expect(
            enabledButton.onPressed,
            isNotNull,
            reason: 'Button should start enabled (iteration $i)',
          );

          // Tap the button
          await tester.tap(enabledButtonFinder);
          await tester.pump();

          expect(
            buttonWasPressed,
            isTrue,
            reason: 'Button should respond to tap when enabled (iteration $i)',
          );

          // Now simulate the loading state (what happens after tap)
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SocialLoginButton(
                  provider: randomProvider,
                  onPressed: onPressedCallback,
                  isLoading: true, // Now loading
                ),
              ),
            ),
          );

          await tester.pump();

          // Verify button is now disabled
          final loadingButtonFinder = find.byType(ElevatedButton);
          final loadingButton = tester.widget<ElevatedButton>(loadingButtonFinder);
          expect(
            loadingButton.onPressed,
            isNull,
            reason: 'Button should be disabled after loading starts (iteration $i)',
          );

          // Try to tap again - should not work
          buttonWasPressed = false;
          await tester.tap(loadingButtonFinder);
          await tester.pump();

          expect(
            buttonWasPressed,
            isFalse,
            reason: 'Button should not respond to tap when loading (iteration $i)',
          );

          // Verify loading indicator is shown
          expect(
            find.byType(CircularProgressIndicator),
            findsOneWidget,
            reason: 'Should show loading indicator after loading starts (iteration $i)',
          );

          // Additional test: Verify that explicitly passing null as onPressed
          // also disables the button (even when not loading)
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SocialLoginButton(
                  provider: randomProvider,
                  onPressed: null, // Explicitly null
                  isLoading: false,
                ),
              ),
            ),
          );

          await tester.pump();

          final nullCallbackButtonFinder = find.byType(ElevatedButton);
          final nullCallbackButton = tester.widget<ElevatedButton>(nullCallbackButtonFinder);
          expect(
            nullCallbackButton.onPressed,
            isNull,
            reason: 'Button should be disabled when onPressed is null (iteration $i)',
          );

          // Clean up for next iteration
          await tester.pumpWidget(Container());
        }
      },
    );

    // Additional unit tests for button widget
    group('Unit Tests - Button States', () {
      testWidgets('should display Google logo and text when provider is Google', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SocialLoginButton(
                provider: SocialProvider.google,
                onPressed: () {},
                isLoading: false,
              ),
            ),
          ),
        );

        expect(find.text('Continuar com Google'), findsOneWidget);
      });

      testWidgets('should display Apple logo and text when provider is Apple', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SocialLoginButton(
                provider: SocialProvider.apple,
                onPressed: () {},
                isLoading: false,
              ),
            ),
          ),
        );

        expect(find.text('Continuar com Apple'), findsOneWidget);
      });

      testWidgets('should show loading indicator when isLoading is true', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SocialLoginButton(
                provider: SocialProvider.google,
                onPressed: () {},
                isLoading: true,
              ),
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        // Button shows only spinner when loading, not text
        expect(find.text('Continuar com Google'), findsNothing);
      });

      testWidgets('should be disabled when isLoading is true', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SocialLoginButton(
                provider: SocialProvider.google,
                onPressed: () {},
                isLoading: true,
              ),
            ),
          ),
        );

        final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(button.onPressed, isNull);
      });

      testWidgets('should be disabled when onPressed is null', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SocialLoginButton(
                provider: SocialProvider.google,
                onPressed: null,
                isLoading: false,
              ),
            ),
          ),
        );

        final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(button.onPressed, isNull);
      });

      testWidgets('should call onPressed callback when tapped and not loading', (tester) async {
        bool wasCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SocialLoginButton(
                provider: SocialProvider.google,
                onPressed: () {
                  wasCalled = true;
                },
                isLoading: false,
              ),
            ),
          ),
        );

        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        expect(wasCalled, isTrue);
      });

      testWidgets('should not call onPressed callback when tapped and loading', (tester) async {
        bool wasCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SocialLoginButton(
                provider: SocialProvider.google,
                onPressed: () {
                  wasCalled = true;
                },
                isLoading: true,
              ),
            ),
          ),
        );

        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        expect(wasCalled, isFalse);
      });

      testWidgets('should prevent multiple taps when loading', (tester) async {
        int tapCount = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SocialLoginButton(
                provider: SocialProvider.google,
                onPressed: () {
                  tapCount++;
                },
                isLoading: true,
              ),
            ),
          ),
        );

        // Try to tap multiple times
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // Callback should never be called
        expect(tapCount, equals(0));
      });
    });
  });
}

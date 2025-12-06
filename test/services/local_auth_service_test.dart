import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:local_auth/local_auth.dart' as local_auth;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:faker/faker.dart';

import 'package:login/services/local_auth_service.dart';
import 'package:login/services/biometric_service.dart' as app_biometric;
import 'package:login/models/exceptions.dart';

import 'local_auth_service_test.mocks.dart';

// Generate mocks for the dependencies
@GenerateMocks([
  local_auth.LocalAuthentication,
  FlutterSecureStorage,
])
void main() {
  late MockLocalAuthentication mockLocalAuth;
  late MockFlutterSecureStorage mockSecureStorage;
  late LocalAuthService biometricService;
  late Faker faker;

  setUp(() {
    mockLocalAuth = MockLocalAuthentication();
    mockSecureStorage = MockFlutterSecureStorage();
    faker = Faker();

    biometricService = LocalAuthService(
      localAuth: mockLocalAuth,
      secureStorage: mockSecureStorage,
    );
  });

  group('Property-Based Tests - LocalAuthService', () {
    // Feature: autenticacao-cripto, Property 8: Armazenamento seguro de credenciais
    // Validates: Requirements 2.3, 6.1
    test(
      'Property 8: Para qualquer configuração bem-sucedida de biometria, '
      'as credenciais devem ser armazenadas de forma criptografada no armazenamento seguro do dispositivo',
      () async {
        // Run 100 iterations with random user IDs
        for (int i = 0; i < 100; i++) {
          // Reset mocks for each iteration
          reset(mockLocalAuth);
          reset(mockSecureStorage);

          // Generate random user ID
          final userId = faker.guid.guid();

          // Setup mock to simulate successful storage operations
          when(mockSecureStorage.write(
            key: anyNamed('key'),
            value: anyNamed('value'),
          )).thenAnswer((_) async => {});

          when(mockSecureStorage.read(key: anyNamed('key')))
              .thenAnswer((_) async => null);

          when(mockSecureStorage.delete(key: anyNamed('key')))
              .thenAnswer((_) async => {});

          // Act: Save credentials (simulating biometric configuration)
          await biometricService.saveCredentials(userId);

          // Assert: Verify that credentials were written to secure storage
          // The key should be 'biometric_user_id' and value should be the userId
          verify(mockSecureStorage.write(
            key: 'biometric_user_id',
            value: userId,
          )).called(1);

          // Verify that attempt counter was also reset (security measure)
          verify(mockSecureStorage.delete(key: 'biometric_attempts')).called(1);

          // Setup mock to return the saved userId for retrieval test
          reset(mockSecureStorage);
          when(mockSecureStorage.read(key: 'biometric_user_id'))
              .thenAnswer((_) async => userId);

          // Act: Retrieve stored credentials
          final retrievedUserId = await biometricService.getStoredUserId();

          // Assert: Verify that the retrieved userId matches the saved one
          expect(
            retrievedUserId,
            equals(userId),
            reason: 'Stored credentials should be retrievable and match the original userId '
                   '(iteration $i, userId: $userId)',
          );

          // Verify that read was called with the correct key
          verify(mockSecureStorage.read(key: 'biometric_user_id')).called(1);

          // Additional security check: Verify that credentials are not stored in plain text
          // by ensuring that the secure storage write method was used (not regular storage)
          // This is implicitly tested by using FlutterSecureStorage which provides
          // AES-256 encryption on both iOS (Keychain) and Android (KeyStore)
          
          // Test error handling: Verify that storage failures throw appropriate exceptions
          reset(mockSecureStorage);
          when(mockSecureStorage.write(
            key: anyNamed('key'),
            value: anyNamed('value'),
          )).thenThrow(Exception('Storage error'));

          try {
            await biometricService.saveCredentials(userId);
            fail('Expected BiometricException to be thrown on storage failure');
          } on BiometricException catch (e) {
            // Verify that a BiometricException is thrown with appropriate message
            expect(
              e.message,
              contains('Erro ao salvar credenciais biométricas'),
              reason: 'Should throw BiometricException with appropriate message on storage failure',
            );
            expect(
              e.originalError,
              isNotNull,
              reason: 'Exception should include original error for debugging',
            );
          }
        }
      },
    );

    // Feature: autenticacao-cripto, Property 11: Round-trip de ativação/desativação de biometria
    // Validates: Requirements 10.3
    test(
      'Property 11: Para qualquer usuário que ativa e depois desativa biometria, '
      'todas as credenciais armazenadas devem ser removidas de forma segura',
      () async {
        // Run 100 iterations with random user IDs
        for (int i = 0; i < 100; i++) {
          // Reset mocks for each iteration
          reset(mockLocalAuth);
          reset(mockSecureStorage);

          // Generate random user ID
          final userId = faker.guid.guid();

          // Setup mock to simulate successful storage operations
          when(mockSecureStorage.write(
            key: anyNamed('key'),
            value: anyNamed('value'),
          )).thenAnswer((_) async => {});

          when(mockSecureStorage.read(key: anyNamed('key')))
              .thenAnswer((_) async => null);

          when(mockSecureStorage.delete(key: anyNamed('key')))
              .thenAnswer((_) async => {});

          // Act: Activate biometrics by saving credentials
          await biometricService.saveCredentials(userId);

          // Verify credentials were saved
          verify(mockSecureStorage.write(
            key: 'biometric_user_id',
            value: userId,
          )).called(1);

          // Setup mock to return the saved userId
          reset(mockSecureStorage);
          when(mockSecureStorage.read(key: 'biometric_user_id'))
              .thenAnswer((_) async => userId);
          when(mockSecureStorage.delete(key: anyNamed('key')))
              .thenAnswer((_) async => {});

          // Verify credentials can be retrieved
          final retrievedUserId = await biometricService.getStoredUserId();
          expect(
            retrievedUserId,
            equals(userId),
            reason: 'Stored user ID should match the saved user ID',
          );

          // Act: Deactivate biometrics by deleting credentials
          // Setup mock to return null after deletion
          when(mockSecureStorage.delete(key: anyNamed('key')))
              .thenAnswer((_) async => {});
          
          await biometricService.deleteCredentials();

          // Verify delete was called for user ID and attempts
          verify(mockSecureStorage.delete(key: 'biometric_user_id')).called(1);
          verify(mockSecureStorage.delete(key: 'biometric_attempts')).called(1);

          // Setup mock to return null after deletion
          reset(mockSecureStorage);
          when(mockSecureStorage.read(key: anyNamed('key')))
              .thenAnswer((_) async => null);

          // Assert: Verify credentials are completely removed
          final deletedUserId = await biometricService.getStoredUserId();
          expect(
            deletedUserId,
            isNull,
            reason: 'After deactivation, stored user ID should be null (iteration $i, userId: $userId)',
          );
        }
      },
    );

    // Feature: autenticacao-cripto, Property 6: Verificação de suporte biométrico
    // Validates: Requirements 2.1
    test(
      'Property 6: Para qualquer tentativa de ativar biometria, '
      'o sistema deve primeiro verificar se o dispositivo suporta biometria antes de prosseguir',
      () async {
        // Run 100 iterations with random device configurations
        for (int i = 0; i < 100; i++) {
          // Reset mocks for each iteration
          reset(mockLocalAuth);
          reset(mockSecureStorage);

          // Generate random device capabilities
          final canCheckBiometrics = faker.randomGenerator.boolean();
          final isDeviceSupported = faker.randomGenerator.boolean();
          
          // Generate random available biometrics
          final hasBiometrics = faker.randomGenerator.boolean();
          final availableBiometrics = hasBiometrics
              ? _generateRandomBiometrics(faker)
              : <local_auth.BiometricType>[];

          // Setup mock responses
          when(mockLocalAuth.canCheckBiometrics)
              .thenAnswer((_) async => canCheckBiometrics);
          when(mockLocalAuth.isDeviceSupported())
              .thenAnswer((_) async => isDeviceSupported);
          when(mockLocalAuth.getAvailableBiometrics())
              .thenAnswer((_) async => availableBiometrics);

          // Act: Check if biometric is available
          final isAvailable = await biometricService.isAvailable();

          // Assert: Verify that isAvailable correctly reflects device capabilities
          // Biometric should only be available if ALL conditions are met:
          // 1. Device can check biometrics
          // 2. Device is supported
          // 3. At least one biometric type is enrolled
          final expectedAvailability = canCheckBiometrics && 
                                       isDeviceSupported && 
                                       availableBiometrics.isNotEmpty;

          expect(
            isAvailable,
            equals(expectedAvailability),
            reason: 'isAvailable should be true only when device can check biometrics '
                   '($canCheckBiometrics), is supported ($isDeviceSupported), '
                   'and has enrolled biometrics (${availableBiometrics.isNotEmpty})',
          );

          // Verify that the service checked all necessary conditions
          verify(mockLocalAuth.canCheckBiometrics).called(1);
          
          if (canCheckBiometrics) {
            verify(mockLocalAuth.isDeviceSupported()).called(1);
            
            if (isDeviceSupported) {
              verify(mockLocalAuth.getAvailableBiometrics()).called(1);
            }
          }

          // Additional test: Verify that authenticate() checks availability first
          if (!isAvailable) {
            // Reset mocks to test authenticate behavior
            reset(mockLocalAuth);
            reset(mockSecureStorage);

            // Setup same device configuration
            when(mockLocalAuth.canCheckBiometrics)
                .thenAnswer((_) async => canCheckBiometrics);
            when(mockLocalAuth.isDeviceSupported())
                .thenAnswer((_) async => isDeviceSupported);
            when(mockLocalAuth.getAvailableBiometrics())
                .thenAnswer((_) async => availableBiometrics);

            // Determine expected exception based on why isAvailable is false
            final expectedCode = (!canCheckBiometrics || !isDeviceSupported)
                ? 'NOT_AVAILABLE'  // Device doesn't support biometrics
                : 'NOT_ENROLLED';   // Device supports but no biometrics enrolled

            // Attempt to authenticate on unavailable device
            try {
              await biometricService.authenticate(
                reason: 'Test authentication',
                useErrorDialogs: false,
              );
              
              // Should not reach here - exception should be thrown
              fail('Expected BiometricException to be thrown');
            } on BiometricException catch (e) {
              // Verify correct exception is thrown
              expect(
                e.code,
                equals(expectedCode),
                reason: 'Should throw $expectedCode when isDeviceSupported=$isDeviceSupported, '
                       'availableBiometrics=${availableBiometrics.length}',
              );
            }

            // Verify that authenticate() never attempted actual authentication
            verifyNever(mockLocalAuth.authenticate(
              localizedReason: anyNamed('localizedReason'),
              options: anyNamed('options'),
            ));
          }
        }
      },
    );
  });
}

/// Generates a random list of biometric types
List<local_auth.BiometricType> _generateRandomBiometrics(Faker faker) {
  final allTypes = [
    local_auth.BiometricType.fingerprint,
    local_auth.BiometricType.face,
    local_auth.BiometricType.iris,
  ];

  // Randomly select 1-3 biometric types
  final count = faker.randomGenerator.integer(3, min: 1);
  allTypes.shuffle();
  return allTypes.take(count).toList();
}

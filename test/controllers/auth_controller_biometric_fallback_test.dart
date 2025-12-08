import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:faker/faker.dart';
import 'package:login/controllers/controllers.dart';
import 'package:login/models/models.dart';
import 'package:login/models/exceptions.dart';
import 'package:login/utils/platform_helper.dart';

import 'auth_controller_test.mocks.dart';

/// Testes para fallback de biometria em plataformas não suportadas
/// 
/// Valida: Requisitos 9.3, 9.4
void main() {
  late MockAuthService mockAuthService;
  late MockBiometricService mockBiometricService;
  late MockUserRepository mockUserRepository;
  late MockPreferencesService mockPreferencesService;
  late AuthController authController;
  late Faker faker;

  setUp(() {
    mockAuthService = MockAuthService();
    mockBiometricService = MockBiometricService();
    mockUserRepository = MockUserRepository();
    mockPreferencesService = MockPreferencesService();
    faker = Faker();
    
    // Setup default behavior for preferences service
    when(mockPreferencesService.isBiometricEnabled())
        .thenAnswer((_) async => false);
    when(mockPreferencesService.getUserId())
        .thenAnswer((_) async => null);
    when(mockPreferencesService.saveBiometricEnabled(any))
        .thenAnswer((_) async => {});
    when(mockPreferencesService.saveUserId(any))
        .thenAnswer((_) async => {});
    when(mockPreferencesService.removeUserId())
        .thenAnswer((_) async => {});
    
    authController = AuthController(
      mockAuthService,
      mockBiometricService,
      mockUserRepository,
      mockPreferencesService,
    );
  });

  group('Biometric Fallback', () {
    test('platformSupportsBiometric deve retornar valor correto', () {
      final supports = authController.platformSupportsBiometric;
      expect(supports, equals(PlatformHelper.supportsBiometric));
    });

    test('deve funcionar sem biometria em plataformas não suportadas', () async {
      // Se a plataforma não suporta biometria, o controller deve funcionar normalmente
      // sem tentar usar biometria
      
      // Verifica que o getter está disponível
      expect(authController.platformSupportsBiometric, isA<bool>());
      
      // Verifica que biometricEnabled começa como false
      expect(authController.biometricEnabled, isFalse);
    });

    test('deve retornar erro apropriado ao tentar ativar biometria em plataforma não suportada', () async {
      // Este teste só é relevante se a plataforma não suporta biometria
      if (!PlatformHelper.supportsBiometric) {
        // Simula usuário autenticado
        when(mockAuthService.getCurrentUser()).thenAnswer((_) async => null);
        
        // Tenta ativar biometria
        await authController.enableBiometric();
        
        // Deve ter erro
        expect(authController.error, isNotNull);
        expect(authController.error, contains('não está disponível'));
        expect(authController.biometricEnabled, isFalse);
      }
    });

    test('deve retornar erro apropriado ao tentar fazer login com biometria em plataforma não suportada', () async {
      // Este teste só é relevante se a plataforma não suporta biometria
      if (!PlatformHelper.supportsBiometric) {
        // Tenta fazer login com biometria
        await authController.signInWithBiometric();
        
        // Deve ter erro
        expect(authController.error, isNotNull);
        expect(authController.error, contains('não está disponível'));
        expect(authController.isAuthenticated, isFalse);
      }
    });

    test('login social deve funcionar independentemente do suporte a biometria', () async {
      // Login social deve funcionar mesmo sem biometria
      final testUser = User(
        id: faker.guid.guid(),
        email: faker.internet.email(),
        provider: AuthProvider.google,
        createdAt: DateTime.now(),
        isNewUser: false,
        profileComplete: true,
      );
      
      when(mockAuthService.signInWithGoogle()).thenAnswer((_) async => testUser);
      when(mockUserRepository.userExists(any)).thenAnswer((_) async => true);
      
      await authController.signInWithGoogle();
      
      expect(authController.isAuthenticated, isTrue);
      expect(authController.currentUser, equals(testUser));
      expect(authController.error, isNull);
      
      verify(mockAuthService.signInWithGoogle()).called(1);
    });

    test('deve permitir desabilitar biometria mesmo em plataforma não suportada', () async {
      // Desabilitar biometria deve sempre funcionar (limpa dados)
      await authController.disableBiometric();
      
      expect(authController.biometricEnabled, isFalse);
      verify(mockBiometricService.deleteCredentials()).called(1);
    });
  });
}

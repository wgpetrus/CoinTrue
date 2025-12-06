import 'package:flutter_test/flutter_test.dart';
import 'package:login/utils/platform_helper.dart';

/// Testes para PlatformHelper
/// 
/// Valida: Requisitos 9.1, 9.2, 9.3, 9.4, 9.5
void main() {
  group('PlatformHelper', () {
    test('deve retornar nome da plataforma', () {
      final platformName = PlatformHelper.platformName;
      expect(platformName, isNotEmpty);
      expect(platformName, isA<String>());
    });

    test('deve retornar se é mobile', () {
      final isMobile = PlatformHelper.isMobile;
      expect(isMobile, isA<bool>());
    });

    test('deve retornar se é web', () {
      final isWeb = PlatformHelper.isWeb;
      expect(isWeb, isA<bool>());
    });

    test('deve retornar se é desktop', () {
      final isDesktop = PlatformHelper.isDesktop;
      expect(isDesktop, isA<bool>());
    });

    test('deve retornar se suporta biometria', () {
      final supportsBiometric = PlatformHelper.supportsBiometric;
      expect(supportsBiometric, isA<bool>());
      
      // Web e Desktop não devem suportar biometria
      if (PlatformHelper.isWeb || PlatformHelper.isDesktop) {
        expect(supportsBiometric, isFalse);
      }
    });

    test('deve retornar se suporta Google Sign-In', () {
      final supportsGoogle = PlatformHelper.supportsGoogleSignIn;
      expect(supportsGoogle, isA<bool>());
    });

    test('deve retornar se suporta Apple Sign-In', () {
      final supportsApple = PlatformHelper.supportsAppleSignIn;
      expect(supportsApple, isA<bool>());
      
      // Android não deve suportar Apple Sign-In
      if (PlatformHelper.isAndroid) {
        expect(supportsApple, isFalse);
      }
    });

    test('deve retornar mensagem de recurso não suportado', () {
      final message = PlatformHelper.getUnsupportedFeatureMessage('biometric');
      expect(message, isNotEmpty);
      expect(message, contains('biométrica'));
    });

    test('deve retornar mensagem de prompt biométrico', () {
      final message = PlatformHelper.getBiometricPromptMessage();
      expect(message, isNotEmpty);
      
      if (PlatformHelper.isAndroid) {
        expect(message, contains('impressão digital'));
      } else if (PlatformHelper.isIOS) {
        expect(message, contains('Face ID'));
      }
    });

    test('deve retornar mensagem de configuração biométrica', () {
      final message = PlatformHelper.getBiometricSetupMessage();
      expect(message, isNotEmpty);
      expect(message, contains('configurações'));
      
      if (PlatformHelper.isAndroid) {
        expect(message, contains('Android'));
      } else if (PlatformHelper.isIOS) {
        expect(message, contains('iOS'));
      }
    });

    test('plataformas devem ser mutuamente exclusivas', () {
      final platforms = [
        PlatformHelper.isAndroid,
        PlatformHelper.isIOS,
        PlatformHelper.isWeb,
      ];
      
      // Apenas uma plataforma deve ser verdadeira
      final trueCount = platforms.where((p) => p).length;
      expect(trueCount, lessThanOrEqualTo(1));
    });

    test('mobile deve ser Android ou iOS', () {
      if (PlatformHelper.isMobile) {
        expect(
          PlatformHelper.isAndroid || PlatformHelper.isIOS,
          isTrue,
        );
      }
    });

    test('suporte a biometria deve ser consistente com plataforma', () {
      if (PlatformHelper.supportsBiometric) {
        expect(PlatformHelper.isMobile, isTrue);
        expect(PlatformHelper.isWeb, isFalse);
        expect(PlatformHelper.isDesktop, isFalse);
      }
    });
  });
}

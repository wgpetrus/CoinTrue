import 'package:local_auth/local_auth.dart' as local_auth;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../models/models.dart';
import '../../utils/platform_helper.dart';
import 'biometric_service.dart';

/// Local implementation of BiometricService using local_auth package
/// 
/// This service handles biometric authentication using the device's
/// native biometric capabilities (fingerprint, Face ID, etc.) and
/// securely stores credentials using flutter_secure_storage.
class LocalAuthService implements BiometricService {
  final local_auth.LocalAuthentication _localAuth;
  final FlutterSecureStorage _secureStorage;

  // Storage keys
  static const String _userIdKey = 'biometric_user_id';
  static const String _attemptsKey = 'biometric_attempts';
  static const int _maxAttempts = 3;

  /// Creates a LocalAuthService with optional dependency injection
  /// 
  /// If dependencies are not provided, default instances will be used.
  LocalAuthService({
    local_auth.LocalAuthentication? localAuth,
    FlutterSecureStorage? secureStorage,
  })  : _localAuth = localAuth ?? local_auth.LocalAuthentication(),
        _secureStorage = secureStorage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
              ),
            );

  @override
  Future<bool> isAvailable() async {
    try {
      // Check if device supports biometric authentication
      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;

      if (!canCheckBiometrics) {
        return false;
      }

      // Check if device is capable of authentication
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();

      if (!isDeviceSupported) {
        return false;
      }

      // Check if at least one biometric is enrolled
      final List<BiometricType> availableBiometrics =
          await getAvailableBiometrics();

      return availableBiometrics.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      final List<local_auth.BiometricType> biometrics =
          await _localAuth.getAvailableBiometrics();

      return biometrics.map((biometric) {
        switch (biometric) {
          case local_auth.BiometricType.fingerprint:
            return BiometricType.fingerprint;
          case local_auth.BiometricType.face:
            return BiometricType.face;
          case local_auth.BiometricType.iris:
            return BiometricType.iris;
          default:
            return BiometricType.fingerprint;
        }
      }).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<bool> authenticate({
    required String reason,
    bool useErrorDialogs = true,
  }) async {
    try {
      // Check if device can check biometrics
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      if (!canCheckBiometrics) {
        throw const BiometricException.notAvailable();
      }

      // Check if device supports biometric authentication
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      if (!isDeviceSupported) {
        throw const BiometricException.notAvailable();
      }

      // Check if biometric authentication is available
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      if (availableBiometrics.isEmpty) {
        throw BiometricException(
          PlatformHelper.getBiometricSetupMessage(),
          code: 'NOT_ENROLLED',
        );
      }

      // Check attempt count
      final int attempts = await _getAttemptCount();
      if (attempts >= _maxAttempts) {
        throw const BiometricException.tooManyAttempts();
      }

      // Attempt authentication
      final bool authenticated = await _localAuth.authenticate(
        localizedReason: reason,
        options: const local_auth.AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
          biometricOnly: false, // Permite PIN/senha como fallback
        ),
      );

      if (authenticated) {
        // Reset attempt counter on success
        await _resetAttemptCount();
        return true;
      } else {
        // Increment attempt counter on failure
        await _incrementAttemptCount();
        throw const BiometricException(
          'Autenticação cancelada ou falhou. Tente novamente.',
          code: 'AUTH_FAILED',
        );
      }
    } on BiometricException {
      rethrow;
    } catch (e) {
      // Handle specific local_auth exceptions
      final errorMessage = e.toString().toLowerCase();

      if (errorMessage.contains('not available') ||
          errorMessage.contains('not supported')) {
        throw const BiometricException(
          'Biometria não disponível neste dispositivo.',
          code: 'NOT_AVAILABLE',
        );
      } else if (errorMessage.contains('not enrolled') ||
          errorMessage.contains('no biometric') ||
          errorMessage.contains('no hardware')) {
        throw const BiometricException(
          'Configure a biometria nas configurações do dispositivo primeiro.',
          code: 'NOT_ENROLLED',
        );
      } else if (errorMessage.contains('cancel') ||
          errorMessage.contains('user cancel')) {
        throw const BiometricException(
          'Autenticação cancelada.',
          code: 'CANCELLED',
        );
      } else if (errorMessage.contains('permission')) {
        throw const BiometricException(
          'Permissão negada para usar biometria.',
          code: 'PERMISSION_DENIED',
        );
      } else if (errorMessage.contains('lockout')) {
        throw const BiometricException(
          'Muitas tentativas falhadas. Aguarde alguns minutos.',
          code: 'LOCKOUT',
        );
      } else {
        throw BiometricException(
          'Erro ao autenticar: ${e.toString()}',
          code: 'UNKNOWN',
          originalError: e,
        );
      }
    }
  }

  @override
  Future<void> saveCredentials(String userId) async {
    try {
      await _secureStorage.write(
        key: _userIdKey,
        value: userId,
      );
      // Reset attempt counter when saving new credentials
      await _resetAttemptCount();
    } catch (e) {
      throw BiometricException(
        'Erro ao salvar credenciais biométricas',
        originalError: e,
      );
    }
  }

  @override
  Future<String?> getStoredUserId() async {
    try {
      return await _secureStorage.read(key: _userIdKey);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> deleteCredentials() async {
    try {
      await _secureStorage.delete(key: _userIdKey);
      await _resetAttemptCount();
    } catch (e) {
      throw BiometricException(
        'Erro ao deletar credenciais biométricas',
        originalError: e,
      );
    }
  }

  /// Gets the current attempt count from secure storage
  Future<int> _getAttemptCount() async {
    try {
      final String? attemptsStr =
          await _secureStorage.read(key: _attemptsKey);
      if (attemptsStr == null) {
        return 0;
      }
      return int.tryParse(attemptsStr) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Increments the attempt counter
  Future<void> _incrementAttemptCount() async {
    try {
      final int currentAttempts = await _getAttemptCount();
      await _secureStorage.write(
        key: _attemptsKey,
        value: (currentAttempts + 1).toString(),
      );
    } catch (e) {
      // Silently fail - don't block authentication flow
    }
  }

  /// Resets the attempt counter to zero
  Future<void> _resetAttemptCount() async {
    try {
      await _secureStorage.delete(key: _attemptsKey);
    } catch (e) {
      // Silently fail - don't block authentication flow
    }
  }
}

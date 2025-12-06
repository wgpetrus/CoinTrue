import 'dart:io';
import 'package:flutter/foundation.dart';

/// Helper class for platform-specific functionality
/// 
/// Provides utilities to detect the current platform and adjust
/// behavior accordingly for Android, iOS, Web, and other platforms.
/// 
/// Validates: Requirements 9.1, 9.2, 9.3, 9.4, 9.5
class PlatformHelper {
  /// Private constructor to prevent instantiation
  PlatformHelper._();

  /// Returns true if running on Android
  static bool get isAndroid {
    if (kIsWeb) return false;
    return Platform.isAndroid;
  }

  /// Returns true if running on iOS
  static bool get isIOS {
    if (kIsWeb) return false;
    return Platform.isIOS;
  }

  /// Returns true if running on Web
  static bool get isWeb => kIsWeb;

  /// Returns true if running on desktop (Windows, macOS, Linux)
  static bool get isDesktop {
    if (kIsWeb) return false;
    return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  }

  /// Returns true if running on mobile (Android or iOS)
  static bool get isMobile => isAndroid || isIOS;

  /// Returns true if the platform supports biometric authentication
  /// 
  /// Android: API 23+ (Marshmallow)
  /// iOS: All versions with Touch ID or Face ID
  /// Web/Desktop: Not supported
  static bool get supportsBiometric {
    if (kIsWeb) return false;
    if (isDesktop) return false;
    
    // Android API 23+ supports fingerprint
    // iOS supports Touch ID and Face ID
    return isAndroid || isIOS;
  }

  /// Returns true if the platform supports Google Sign-In
  /// 
  /// Supported on: Android, iOS, Web
  static bool get supportsGoogleSignIn {
    return isAndroid || isIOS || isWeb;
  }

  /// Returns true if the platform supports Apple Sign-In
  /// 
  /// Supported on: iOS 13+, macOS 10.15+, Web
  /// Android: Not natively supported
  static bool get supportsAppleSignIn {
    if (isWeb) return true;
    if (isIOS) return true;
    if (Platform.isMacOS) return true;
    return false;
  }

  /// Returns the platform name as a string
  static String get platformName {
    if (kIsWeb) return 'Web';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isLinux) return 'Linux';
    return 'Unknown';
  }

  /// Returns the minimum Android API level required for biometric
  static const int minAndroidApiForBiometric = 23;

  /// Returns true if running on Android with API 23+
  static bool get isAndroidWithBiometricSupport {
    if (!isAndroid) return false;
    // Note: Checking actual API level requires platform channels
    // For now, we assume API 23+ based on minSdkVersion in build.gradle
    return true;
  }

  /// Returns a user-friendly message for unsupported features
  static String getUnsupportedFeatureMessage(String feature) {
    switch (feature) {
      case 'biometric':
        if (isWeb) {
          return 'Autenticação biométrica não está disponível na versão web.';
        }
        if (isDesktop) {
          return 'Autenticação biométrica não está disponível em desktop.';
        }
        return 'Autenticação biométrica não está disponível neste dispositivo.';
      
      case 'google_signin':
        return 'Login com Google não está disponível nesta plataforma.';
      
      case 'apple_signin':
        if (isAndroid) {
          return 'Login com Apple não está disponível no Android. Use Google ou Email.';
        }
        return 'Login com Apple não está disponível nesta plataforma.';
      
      default:
        return 'Este recurso não está disponível nesta plataforma.';
    }
  }

  /// Returns platform-specific biometric prompt message
  static String getBiometricPromptMessage() {
    if (isAndroid) {
      return 'Use sua impressão digital para fazer login';
    }
    if (isIOS) {
      return 'Use Face ID ou Touch ID para fazer login';
    }
    return 'Use sua biometria para fazer login';
  }

  /// Returns platform-specific biometric setup message
  static String getBiometricSetupMessage() {
    if (isAndroid) {
      return 'Configure sua impressão digital nas configurações do Android para usar este recurso.';
    }
    if (isIOS) {
      return 'Configure Face ID ou Touch ID nas configurações do iOS para usar este recurso.';
    }
    return 'Configure a biometria nas configurações do dispositivo para usar este recurso.';
  }
}

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'constants.dart';

/// Utility class for loading assets with consistent error handling and fallbacks
class AssetLoader {
  AssetLoader._();

  /// Loads an image asset with error handling and fallback
  static Widget loadImage({
    required String assetPath,
    double? width,
    double? height,
    BoxFit? fit,
    Widget? fallback,
    bool enableLogging = true,
  }) {
    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        // Log the error for debugging
        if (enableLogging) {
          logAssetError(assetPath, error, stackTrace);
        }

        // Return custom fallback or default fallback
        return fallback ?? buildDefaultFallback(width, height);
      },
    );
  }

  /// Loads the app logo with consistent fallback
  static Widget loadAppLogo({
    double? width,
    double? height,
    BoxFit? fit,
  }) {
    return loadImage(
      assetPath: AppAssets.logoApp,
      width: width,
      height: height,
      fit: fit,
      fallback: buildAppLogoFallback(width, height),
    );
  }

  /// Loads a social provider logo with consistent fallback
  static Widget loadSocialLogo({
    required String assetPath,
    required String providerName,
    double? width,
    double? height,
    BoxFit? fit,
  }) {
    return loadImage(
      assetPath: assetPath,
      width: width,
      height: height,
      fit: fit,
      fallback: buildSocialLogoFallback(providerName, width, height),
    );
  }

  /// Loads the biometric logo with consistent fallback
  static Widget loadBiometricLogo({
    double? width,
    double? height,
    BoxFit? fit,
  }) {
    return loadImage(
      assetPath: AppAssets.logoBiometric,
      width: width,
      height: height,
      fit: fit,
      fallback: buildBiometricLogoFallback(width, height),
    );
  }

  /// Builds default fallback widget for any asset
  static Widget buildDefaultFallback(double? width, double? height) {
    final colors = AppConstants.colors;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colors.lightGray,
        borderRadius: BorderRadius.circular(8),
      ),
      child: PhosphorIcon(
        PhosphorIcons.image(),
        size: (width != null && height != null) 
            ? (width < height ? width : height) * 0.4 
            : 24,
        color: colors.mediumGray,
      ),
    );
  }

  /// Builds app logo fallback
  static Widget buildAppLogoFallback(double? width, double? height) {
    final colors = AppConstants.colors;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: PhosphorIcon(
        PhosphorIcons.wallet(PhosphorIconsStyle.fill),
        size: (width != null && height != null) 
            ? (width < height ? width : height) * 0.5 
            : 48,
        color: colors.white,
      ),
    );
  }

  /// Builds social logo fallback
  static Widget buildSocialLogoFallback(String providerName, double? width, double? height) {
    final colors = AppConstants.colors;
    final isGoogle = providerName.toLowerCase().contains('google');
    
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isGoogle ? Colors.red : colors.darkGray,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          providerName.isNotEmpty ? providerName.substring(0, 1).toUpperCase() : '?',
          style: TextStyle(
            color: colors.white,
            fontSize: (width != null && height != null) 
                ? (width < height ? width : height) * 0.4 
                : 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Builds biometric logo fallback
  static Widget buildBiometricLogoFallback(double? width, double? height) {
    final colors = AppConstants.colors;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colors.lightGray,
        borderRadius: BorderRadius.circular(8),
      ),
      child: PhosphorIcon(
        PhosphorIcons.fingerprint(),
        size: (width != null && height != null) 
            ? (width < height ? width : height) * 0.5 
            : 24,
        color: colors.mediumGray,
      ),
    );
  }

  /// Logs asset loading errors for debugging
  static void logAssetError(String assetPath, Object error, StackTrace? stackTrace) {
    debugPrint('🚨 Asset Loading Error:');
    debugPrint('   Path: $assetPath');
    debugPrint('   Error: $error');
    if (stackTrace != null) {
      debugPrint('   Stack trace: ${stackTrace.toString().split('\n').take(3).join('\n')}');
    }
    debugPrint('   Fallback widget will be displayed instead.');
  }

  /// Validates if an asset exists (for testing purposes)
  static Future<bool> validateAsset(String assetPath) async {
    try {
      await DefaultAssetBundle.of(
        // We need a context for this, so this method should be called from a widget
        // For now, we'll just return true and rely on the errorBuilder
        // In a real implementation, you might want to use a different approach
        WidgetsBinding.instance.rootElement!,
      ).load(assetPath);
      return true;
    } catch (e) {
      logAssetError(assetPath, e, null);
      return false;
    }
  }
}
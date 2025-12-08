import 'package:flutter/material.dart';
import '../../../utils/constants.dart';
import '../../../utils/asset_loader.dart';
import '../../../utils/theme_helper.dart';

/// Enum para identificar o provedor de autenticação social
enum SocialProvider {
  google,
  apple,
}

/// Widget de botão customizado para login social
/// 
/// Implementa um botão com logo, texto e cor personalizados para
/// autenticação via Google ou Apple, seguindo o Material Design
/// e as cores do aplicativo CoinTrue.
/// 
/// Requisitos: 1.1, 1.2, 7.1, 7.2
class SocialLoginButton extends StatelessWidget {
  /// Provedor de autenticação (Google ou Apple)
  final SocialProvider provider;

  /// Callback executado quando o botão é pressionado
  final VoidCallback? onPressed;

  /// Indica se o botão está em estado de loading
  final bool isLoading;

  const SocialLoginButton({
    super.key,
    required this.provider,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppConstants.strings;

    // Determina o texto e logo baseado no provedor
    final String buttonText = provider == SocialProvider.google
        ? strings.continueWithGoogle
        : strings.continueWithApple;

    final String logoAsset = provider == SocialProvider.google
        ? AppAssets.logoGoogle
        : AppAssets.logoApple;

    // Determina se o botão está desabilitado
    final bool isDisabled = onPressed == null || isLoading;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.surfaceElevated,
          disabledBackgroundColor: colors.surfaceElevated,
          foregroundColor: colors.onBackground,
          disabledForegroundColor: colors.onBackground.withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: colors.outline,
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        child: isLoading
            ? _buildLoadingState(colors)
            : _buildNormalState(logoAsset, buttonText, colors),
      ),
    );
  }

  /// Constrói o estado normal do botão com logo e texto
  Widget _buildNormalState(String logoAsset, String buttonText, AppColors colors) {
    final providerName = provider == SocialProvider.google ? 'Google' : 'Apple';
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo do provedor
        AssetLoader.loadSocialLogo(
          assetPath: logoAsset,
          providerName: providerName,
          width: 24,
          height: 24,
        ),
        const SizedBox(width: 12),
        // Texto do botão
        Flexible(
          child: Text(
            buttonText,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colors.onBackground,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Constrói o estado de loading com spinner
  Widget _buildLoadingState(AppColors colors) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(colors.onBackground),
      ),
    );
  }
}

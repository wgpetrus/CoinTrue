import 'package:flutter/material.dart';
import '../../../utils/constants.dart';

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
    final colors = AppConstants.colors;
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
          backgroundColor: colors.white,
          disabledBackgroundColor: colors.white,
          foregroundColor: colors.darkGray,
          disabledForegroundColor: colors.darkGray.withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isDisabled 
                  ? const Color(0xFFE0E0E0)
                  : const Color(0xFFE0E0E0),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo do provedor
        Image.asset(
          logoAsset,
          width: 24,
          height: 24,
          errorBuilder: (context, error, stackTrace) {
            // Fallback caso a imagem não carregue
            return Icon(
              provider == SocialProvider.google
                  ? Icons.g_mobiledata
                  : Icons.apple,
              size: 24,
              color: colors.darkGray,
            );
          },
        ),
        const SizedBox(width: 12),
        // Texto do botão
        Flexible(
          child: Text(
            buttonText,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colors.darkGray,
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
        valueColor: AlwaysStoppedAnimation<Color>(colors.darkGray),
      ),
    );
  }
}

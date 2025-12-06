import 'package:flutter/material.dart';
import '../../../utils/constants.dart';
import '../../../utils/platform_helper.dart';

/// Widget de prompt para autenticação biométrica
/// 
/// Exibe um card com ícone de biometria e texto explicativo,
/// oferecendo opções para autenticar ou pular a biometria.
/// Design clean e moderno seguindo as cores da empresa.
/// 
/// Requisitos: 2.4, 2.5
class BiometricPrompt extends StatelessWidget {
  /// Callback executado quando o usuário escolhe autenticar com biometria
  final VoidCallback onAuthenticate;

  /// Callback executado quando o usuário escolhe pular a biometria
  final VoidCallback onSkip;

  /// Indica se está em processo de autenticação
  final bool isAuthenticating;

  const BiometricPrompt({
    super.key,
    required this.onAuthenticate,
    required this.onSkip,
    this.isAuthenticating = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppConstants.colors;
    final strings = AppConstants.strings;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.yellow,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.yellow.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ícone de biometria
          _buildBiometricIcon(colors),
          const SizedBox(height: 16),
          
          // Título
          Text(
            strings.loginWithBiometric,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colors.darkGray,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          
          // Descrição
          Text(
            PlatformHelper.getBiometricPromptMessage(),
            style: TextStyle(
              fontSize: 14,
              color: colors.darkGray.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          // Botão de autenticar
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: isAuthenticating ? null : onAuthenticate,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.yellow,
                disabledBackgroundColor: colors.darkGray.withValues(alpha: 0.3),
                foregroundColor: colors.darkGray,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isAuthenticating
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(colors.darkGray),
                      ),
                    )
                  : Text(
                      'Autenticar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colors.darkGray,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          
          // Botão de pular
          TextButton(
            onPressed: isAuthenticating ? null : onSkip,
            style: TextButton.styleFrom(
              foregroundColor: colors.darkGray.withValues(alpha: 0.7),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: Text(
              strings.skipBiometric,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colors.darkGray.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói o ícone de biometria com animação
  Widget _buildBiometricIcon(AppColors colors) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: colors.yellow.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Image.asset(
          AppAssets.logoBiometric,
          width: 48,
          height: 48,
          errorBuilder: (context, error, stackTrace) {
            // Fallback para ícone padrão caso a imagem não carregue
            return Icon(
              Icons.fingerprint,
              size: 48,
              color: colors.yellowDark,
            );
          },
        ),
      ),
    );
  }
}

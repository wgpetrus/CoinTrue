import 'package:flutter/material.dart';
import '../../../utils/constants.dart';

/// Widget para exibir mensagens de erro
/// 
/// Exibe uma mensagem de erro com estilo apropriado e opção
/// de tentar novamente. Segue as cores e design da empresa.
/// 
/// Requisitos: 5.1, 5.2, 5.3, 5.4, 5.5
class ErrorMessage extends StatelessWidget {
  /// Mensagem de erro a ser exibida
  final String message;

  /// Callback opcional executado quando o usuário toca no botão de ação
  final VoidCallback? onRetry;

  /// Indica se deve exibir o botão de ação
  final bool showRetry;

  /// Texto customizado para o botão de ação (padrão: "Tentar Novamente")
  final String? retryButtonText;

  const ErrorMessage({
    super.key,
    required this.message,
    this.onRetry,
    this.showRetry = true,
    this.retryButtonText,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppConstants.colors;
    final strings = AppConstants.strings;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.error.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ícone e mensagem de erro
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ícone de erro
              Icon(
                Icons.error_outline,
                color: colors.error,
                size: 24,
              ),
              const SizedBox(width: 12),
              
              // Mensagem de erro
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.darkGray,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          
          // Botão de ação (se habilitado e callback fornecido)
          if (showRetry && onRetry != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onRetry,
                icon: Icon(
                  retryButtonText == null || retryButtonText == strings.retry
                      ? Icons.refresh
                      : Icons.close,
                  size: 18,
                  color: colors.error,
                ),
                label: Text(
                  retryButtonText ?? strings.retry,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.error,
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: colors.error,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

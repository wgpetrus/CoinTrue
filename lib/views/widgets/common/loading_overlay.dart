import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../utils/constants.dart';

/// Widget de overlay semi-transparente com spinner de loading
/// 
/// Exibe uma camada semi-transparente sobre a tela com um indicador
/// de carregamento, bloqueando interações do usuário enquanto uma
/// operação está em andamento.
/// 
/// Requisitos: 7.1, 7.2, 7.3
class LoadingOverlay extends StatelessWidget {
  /// Indica se o overlay deve ser exibido
  final bool isLoading;

  /// Widget filho que será coberto pelo overlay quando isLoading = true
  final Widget child;

  /// Mensagem opcional a ser exibida abaixo do spinner
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Widget filho (conteúdo principal)
        child,
        
        // Overlay de loading (só aparece quando isLoading = true)
        if (isLoading) _buildOverlay(context),
      ],
    );
  }

  /// Constrói o overlay semi-transparente com spinner
  Widget _buildOverlay(BuildContext context) {
    final colors = AppConstants.colors;
    final strings = AppConstants.strings;

    return Positioned.fill(
      child: Material(
        color: colors.overlay, // Semi-transparente
        child: AbsorbPointer(
          // Bloqueia todas as interações quando ativo
          absorbing: true,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: colors.darkGray.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Spinner de loading
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(colors.yellow),
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 16),
                  // Mensagem de loading
                  Text(
                    message ?? strings.pleaseWait,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: colors.darkGray,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 200.ms)
                .scale(
                  begin: const Offset(0.9, 0.9),
                  duration: 200.ms,
                  curve: Curves.easeOut,
                ),
          ),
        ),
      ),
    );
  }
}

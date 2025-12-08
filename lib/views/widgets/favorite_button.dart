import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../controllers/controllers.dart';
import '../../controllers/controllers.dart';
import '../../utils/constants.dart';

/// Botão de Favorito
/// 
/// Widget reutilizável para adicionar/remover favoritos
/// Segue o design system com animações suaves
class FavoriteButton extends StatefulWidget {
  final String cryptoSymbol;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;

  const FavoriteButton({
    super.key,
    required this.cryptoSymbol,
    this.size = 24,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  bool _isProcessing = false;

  Future<void> _toggleFavorite() async {
    if (_isProcessing) return;

    final authController = context.read<AuthController>();
    final favoritesController = context.read<FavoritesController>();
    final userId = authController.currentUser?.id;

    if (userId == null) {
      _showMessage('Faça login para adicionar favoritos');
      return;
    }

    setState(() => _isProcessing = true);

    try {
      await favoritesController.toggleFavorite(userId, widget.cryptoSymbol);
      
      final isFavorite = favoritesController.isFavorite(widget.cryptoSymbol);
      _showMessage(
        isFavorite 
          ? '⭐ Adicionado aos favoritos' 
          : 'Removido dos favoritos'
      );
    } catch (e) {
      _showMessage('Erro ao atualizar favoritos');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppConstants.colors;
    final favoritesController = context.watch<FavoritesController>();
    final isFavorite = favoritesController.isFavorite(widget.cryptoSymbol);

    return GestureDetector(
      onTap: _isProcessing ? null : _toggleFavorite,
      child: AnimatedScale(
        scale: _isProcessing ? 0.8 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(
                  begin: 0.8,
                  end: 1.0,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.elasticOut,
                )),
                child: child,
              ),
            );
          },
          child: PhosphorIcon(
            isFavorite 
              ? PhosphorIcons.star(PhosphorIconsStyle.fill)
              : PhosphorIcons.star(),
            key: ValueKey(isFavorite),
            size: widget.size,
            color: isFavorite 
              ? (widget.activeColor ?? colors.primaryDark)
              : (widget.inactiveColor ?? colors.mediumGray),
          ),
        ),
      ),
    );
  }
}

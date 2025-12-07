import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../utils/constants.dart';

/// Ícone de Criptomoeda com Cache
/// 
/// Otimizado para performance:
/// - Cache de imagens em memória e disco
/// - Placeholder durante carregamento
/// - Fallback para ícone com letra
class CachedCryptoIcon extends StatelessWidget {
  final String symbol;
  final String? imageUrl;
  final double size;

  const CachedCryptoIcon({
    super.key,
    required this.symbol,
    this.imageUrl,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppConstants.colors;

    // Se não tem URL, mostra fallback direto
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildFallback(colors);
    }

    return CachedNetworkImage(
      imageUrl: imageUrl!,
      width: size,
      height: size,
      fit: BoxFit.cover,
      placeholder: (context, url) => _buildPlaceholder(colors),
      errorWidget: (context, url, error) => _buildFallback(colors),
      memCacheWidth: (size * 2).toInt(), // Cache em resolução 2x
      memCacheHeight: (size * 2).toInt(),
      maxWidthDiskCache: (size * 3).toInt(), // Cache em disco 3x
      maxHeightDiskCache: (size * 3).toInt(),
      fadeInDuration: const Duration(milliseconds: 200),
      fadeOutDuration: const Duration(milliseconds: 100),
    );
  }

  Widget _buildPlaceholder(AppColors colors) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors.lightGray,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: SizedBox(
          width: size * 0.5,
          height: size * 0.5,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(colors.mediumGray),
          ),
        ),
      ),
    );
  }

  Widget _buildFallback(AppColors colors) {
    final color = _getCryptoColor(symbol);
    final letter = symbol.isNotEmpty ? symbol[0].toUpperCase() : '?';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          letter,
          style: TextStyle(
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
            color: colors.white,
          ),
        ),
      ),
    );
  }

  Color _getCryptoColor(String symbol) {
    final colors = AppConstants.colors;
    
    switch (symbol.toUpperCase()) {
      case 'BTC':
        return colors.bitcoin;
      case 'ETH':
        return colors.ethereum;
      case 'ADA':
        return colors.cardano;
      case 'SOL':
        return colors.solana;
      default:
        // Gera cor baseada no hash do símbolo
        final hash = symbol.hashCode;
        final hue = (hash % 360).toDouble();
        return HSLColor.fromAHSL(1.0, hue, 0.6, 0.5).toColor();
    }
  }
}

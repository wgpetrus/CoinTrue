import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../utils/constants.dart';
import '../../../utils/image_cache_manager.dart';

/// Widget padronizado para ícones de criptomoedas
/// 
/// Usa CachedNetworkImage para cache automático.
/// Fallback: círculo colorido com letra inicial.
class CryptoIcon extends StatelessWidget {
  final String symbol;
  final String? imageUrl;
  final double size;

  const CryptoIcon({
    super.key,
    required this.symbol,
    this.imageUrl,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    // Se tem URL de imagem da API, usar com cache persistente
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      debugPrint('🎨 [ICON] Loading $symbol from: $imageUrl');
      
      return ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          cacheManager: CryptoImageCacheManager.instance, // Cache customizado (30 dias)
          placeholder: (context, url) {
            debugPrint('⏳ [ICON] Loading $symbol...');
            return _buildFallbackIcon();
          },
          errorWidget: (context, url, error) {
            debugPrint('❌ [ICON] Error loading $symbol: $error');
            return _buildFallbackIcon();
          },
          fadeInDuration: const Duration(milliseconds: 300), // Transição suave
          fadeOutDuration: const Duration(milliseconds: 100),
        ),
      );
    }

    // Fallback: círculo colorido com letra
    debugPrint('⚠️ [ICON] No URL for $symbol, using fallback');
    return _buildFallbackIcon();
  }

  Widget _buildFallbackIcon() {
    final colors = AppConstants.colors;
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _getCryptoColor(symbol, colors),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          symbol.isNotEmpty ? symbol[0].toUpperCase() : '?',
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
  
  Color _getCryptoColor(String symbol, AppColors colors) {
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
        return colors.mediumGray;
    }
  }
}

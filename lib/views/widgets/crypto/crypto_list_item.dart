import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';
import '../../../models/crypto/crypto_models.dart';
import '../../../utils/constants.dart';
import 'crypto_icon.dart';

/// Widget para exibir um item de criptomoeda na lista
/// 
/// Layout: [Ícone] [Nome/Símbolo] [Preço/Variação]
class CryptoListItem extends StatelessWidget {
  final Crypto crypto;
  final VoidCallback? onTap;

  const CryptoListItem({
    super.key,
    required this.crypto,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppConstants.colors;
    final priceFormatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colors.veryLightGray,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Ícone da cripto (imagem da API ou fallback)
            CryptoIcon(
              symbol: crypto.symbol,
              imageUrl: crypto.imageUrl,
              size: 48,
            ),
            
            const SizedBox(width: 12),
            
            // Nome e símbolo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    crypto.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colors.darkGray,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    crypto.symbol,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.mediumGray,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Preço e variação
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  priceFormatter.format(crypto.currentPrice), // Preço já vem convertido para BRL
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors.darkGray,
                  ),
                ),
                const SizedBox(height: 2),
                _PercentageChange(
                  percentage: crypto.priceChange24h,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget para exibir variação percentual com cor e seta
class _PercentageChange extends StatelessWidget {
  final double percentage;
  final double fontSize;

  const _PercentageChange({
    required this.percentage,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppConstants.colors;
    final isPositive = percentage >= 0;
    final color = isPositive ? colors.success : colors.error;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PhosphorIcon(
          isPositive 
              ? PhosphorIcons.caretUp(PhosphorIconsStyle.fill)
              : PhosphorIcons.caretDown(PhosphorIconsStyle.fill),
          size: fontSize + 2,
          color: color,
        ),
        const SizedBox(width: 2),
        Text(
          '${isPositive ? '+' : ''}${percentage.toStringAsFixed(2)}%',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

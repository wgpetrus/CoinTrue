import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../controllers/crypto/crypto_controllers.dart';
import '../../../models/crypto/crypto_models.dart';
import '../../../utils/constants.dart';
import '../../screens/crypto/transaction_screen.dart';

/// Bottom Sheet para seleção de cripto (compra/venda)
/// 
/// Permite ao usuário:
/// - Buscar criptomoedas por nome ou símbolo
/// - Selecionar uma cripto para comprar ou vender
/// - Ver preço atual de cada cripto
class CryptoSelectorSheet extends StatefulWidget {
  final TransactionType type;
  
  const CryptoSelectorSheet({
    super.key,
    required this.type,
  });

  @override
  State<CryptoSelectorSheet> createState() => _CryptoSelectorSheetState();
}

class _CryptoSelectorSheetState extends State<CryptoSelectorSheet> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppConstants.colors;
    final cryptoController = context.watch<CryptoController>();
    final portfolioController = context.watch<PortfolioController>();
    
    // Filtrar criptos baseado no tipo de transação e pesquisa
    final filteredCryptos = cryptoController.cryptos.where((crypto) {
      // Para venda, mostrar apenas criptos que possuo
      if (widget.type == TransactionType.sell) {
        final hasAsset = portfolioController.assets.any((asset) => 
          asset.cryptoId == crypto.id && asset.quantity > 0);
        if (!hasAsset) return false;
      }
      
      // Filtro de pesquisa
      if (_searchQuery.isEmpty) return true;
      
      final query = _searchQuery.toLowerCase();
      return crypto.name.toLowerCase().contains(query) ||
             crypto.symbol.toLowerCase().contains(query);
    }).toList();
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(colors),
          
          // Lista de criptos
          Expanded(
            child: filteredCryptos.isEmpty
                ? _buildEmptyState(colors)
                : _buildCryptoList(filteredCryptos, colors),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHeader(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Indicador de arrasto
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.lightGray,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          
          // Título
          Text(
            widget.type == TransactionType.buy 
                ? 'Comprar Criptomoeda' 
                : 'Vender Criptomoeda',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colors.darkGray,
            ),
          ),
          const SizedBox(height: 4),
          
          // Subtítulo
          Text(
            widget.type == TransactionType.buy 
                ? 'Selecione a cripto que deseja comprar'
                : 'Selecione a cripto que deseja vender',
            style: TextStyle(
              fontSize: 13,
              color: colors.mediumGray,
            ),
          ),
          const SizedBox(height: 16),
          
          // Campo de pesquisa
          _buildSearchField(colors),
        ],
      ),
    );
  }
  
  Widget _buildSearchField(AppColors colors) {
    return Container(
      decoration: BoxDecoration(
        color: colors.lightGray,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: _searchController,
        style: TextStyle(
          fontSize: 16,
          color: colors.darkGray,
        ),
        decoration: InputDecoration(
          hintText: 'Pesquisar criptomoeda...',
          hintStyle: TextStyle(
            fontSize: 16,
            color: colors.mediumGray.withOpacity(0.7),
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: PhosphorIcon(
              PhosphorIcons.magnifyingGlass(),
              size: 20,
              color: _searchQuery.isNotEmpty 
                ? colors.primaryDark 
                : colors.mediumGray,
            ),
          ),
          suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: PhosphorIcon(
                  PhosphorIcons.x(),
                  size: 20,
                  color: colors.mediumGray,
                ),
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                    _searchQuery = '';
                  });
                },
              )
            : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }
  
  Widget _buildEmptyState(AppColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PhosphorIcon(
            PhosphorIcons.magnifyingGlass(),
            size: 64,
            color: colors.mediumGray.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma cripto encontrada',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colors.mediumGray,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tente outro termo de busca',
            style: TextStyle(
              fontSize: 14,
              color: colors.mediumGray,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCryptoList(List<Crypto> cryptos, AppColors colors) {
    final portfolioController = context.watch<PortfolioController>();
    
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: cryptos.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final crypto = cryptos[index];
        
        // Buscar quantidade disponível se for venda
        double? availableQuantity;
        if (widget.type == TransactionType.sell) {
          try {
            final asset = portfolioController.assets.firstWhere(
              (a) => a.cryptoId == crypto.id,
            );
            availableQuantity = asset.quantity;
          } catch (e) {
            // Asset não encontrado, quantidade é null
            availableQuantity = null;
          }
        }
        
        return InkWell(
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TransactionScreen(
                  crypto: crypto,
                  initialType: widget.type,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colors.veryLightGray,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Ícone da cripto
                _buildCryptoIcon(crypto, colors),
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
                      ),
                      Text(
                        crypto.symbol.toUpperCase(),
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.mediumGray,
                        ),
                      ),
                      if (availableQuantity != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Disponível: ${availableQuantity.toStringAsFixed(8)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Preço
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'R\$ ${crypto.currentPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colors.darkGray,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildCryptoIcon(Crypto crypto, AppColors colors) {
    return ClipOval(
      child: crypto.imageUrl != null
          ? Image.network(
              crypto.imageUrl!,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildFallbackIcon(crypto, colors);
              },
            )
          : _buildFallbackIcon(crypto, colors),
    );
  }
  
  Widget _buildFallbackIcon(Crypto crypto, AppColors colors) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: colors.mediumGray,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          crypto.symbol[0].toUpperCase(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

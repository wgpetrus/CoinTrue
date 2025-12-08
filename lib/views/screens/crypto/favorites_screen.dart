import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../utils/constants.dart';
import '../../../utils/theme_helper.dart';
import '../../../controllers/controllers.dart';
import '../../../controllers/crypto/crypto_controllers.dart';
import '../../../models/crypto/crypto_models.dart';
import '../../widgets/crypto/crypto_list_item.dart';
import 'crypto_detail_screen.dart';
import 'home_screen.dart';

/// Tela de Favoritos
/// 
/// Exibe apenas as criptomoedas marcadas como favoritas
/// Permite seleção múltipla para adicionar/remover favoritos em lote
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  bool _isSelectionMode = false;
  final Set<String> _selectedSymbols = {};

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final cryptoController = context.watch<CryptoController>();
    final favoritesController = context.watch<FavoritesController>();
    
    // Filtrar apenas criptos favoritas
    final favoriteCryptos = cryptoController.cryptos
        .where((crypto) => favoritesController.isFavorite(crypto.symbol))
        .toList();

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        title: Text(
          _isSelectionMode 
              ? '${_selectedSymbols.length} selecionadas'
              : 'Favoritos',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: colors.onBackground,
          ),
        ),
        leading: _isSelectionMode
            ? IconButton(
                icon: PhosphorIcon(
                  PhosphorIcons.x(),
                  size: 24,
                  color: colors.onBackground,
                ),
                onPressed: _exitSelectionMode,
              )
            : IconButton(
                icon: PhosphorIcon(
                  PhosphorIcons.arrowLeft(),
                  size: 24,
                  color: colors.onBackground,
                ),
                onPressed: () => Navigator.pop(context),
              ),
        actions: [
          if (_isSelectionMode && _selectedSymbols.isNotEmpty)
            IconButton(
              icon: PhosphorIcon(
                PhosphorIcons.trash(),
                size: 24,
                color: colors.error,
              ),
              onPressed: _removeSelectedFromFavorites,
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await cryptoController.refreshPrices();
        },
        color: colors.primary,
        child: favoriteCryptos.isEmpty
            ? _buildEmptyState(colors)
            : ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: favoriteCryptos.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final crypto = favoriteCryptos[index];
                  final isSelected = _selectedSymbols.contains(crypto.symbol);
                  
                  return _buildCryptoItem(crypto, isSelected, colors);
                },
              ).animate()
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.1, duration: 300.ms),
      ),
    );
  }

  Widget _buildCryptoItem(Crypto crypto, bool isSelected, AppColors colors) {
    return GestureDetector(
      onLongPress: () => _enterSelectionMode(crypto.symbol),
      onTap: () {
        if (_isSelectionMode) {
          _toggleSelection(crypto.symbol);
        } else {
          _navigateToDetail(crypto);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary.withOpacity(0.1) : colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? colors.primary : colors.veryLightGray,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            CryptoListItem(
              crypto: crypto,
              showFavorite: !_isSelectionMode,
              isInSelectionMode: _isSelectionMode,
              onTap: _isSelectionMode 
                  ? () => _toggleSelection(crypto.symbol)
                  : () => _navigateToDetail(crypto),
            ),
            
            // Checkbox de seleção
            if (_isSelectionMode)
              Positioned(
                right: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: AnimatedScale(
                    scale: isSelected ? 1.0 : 0.8,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isSelected ? colors.primary : colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? colors.primary : colors.mediumGray,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check,
                              size: 16,
                              color: colors.white,
                            )
                          : null,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppColors colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícone animado com fundo gradiente
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors.primary.withValues(alpha: 0.15),
                    colors.secondary.withValues(alpha: 0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: PhosphorIcon(
                  PhosphorIcons.star(PhosphorIconsStyle.fill),
                  size: 60,
                  color: colors.primary,
                ),
              ),
            ).animate()
              .fadeIn(duration: 600.ms)
              .scale(delay: 200.ms, duration: 400.ms),
            
            const SizedBox(height: 32),
            
            Text(
              'Nenhum favorito ainda',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colors.onBackground,
              ),
            ).animate()
              .fadeIn(delay: 400.ms, duration: 400.ms)
              .slideY(begin: 0.2, delay: 400.ms, duration: 400.ms),
            
            const SizedBox(height: 12),
            
            Text(
              'Adicione criptomoedas aos favoritos\npara acesso rápido',
              style: TextStyle(
                fontSize: 14,
                color: colors.mediumGray,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ).animate()
              .fadeIn(delay: 600.ms, duration: 400.ms)
              .slideY(begin: 0.2, delay: 600.ms, duration: 400.ms),
            
            const SizedBox(height: 32),
            
            ElevatedButton.icon(
              onPressed: () {
                // Voltar para home e navegar para aba de Mercados (índice 2)
                Navigator.pop(context);
                // Usar callback para mudar a aba
                final homeState = context.findAncestorStateOfType<HomeScreenState>();
                homeState?.navigateToTab(2); // Índice 2 = Mercados
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              icon: PhosphorIcon(
                PhosphorIcons.magnifyingGlass(),
                size: 20,
                color: colors.white,
              ),
              label: const Text(
                'Explorar Mercados',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ).animate()
              .fadeIn(delay: 800.ms, duration: 400.ms)
              .slideY(begin: 0.2, delay: 800.ms, duration: 400.ms),
          ],
        ),
      ),
    );
  }

  void _enterSelectionMode(String initialSymbol) {
    setState(() {
      _isSelectionMode = true;
      _selectedSymbols.add(initialSymbol);
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedSymbols.clear();
    });
  }

  void _toggleSelection(String symbol) {
    setState(() {
      if (_selectedSymbols.contains(symbol)) {
        _selectedSymbols.remove(symbol);
        
        // Sair do modo de seleção se não houver mais seleções
        if (_selectedSymbols.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedSymbols.add(symbol);
      }
    });
  }

  Future<void> _removeSelectedFromFavorites() async {
    final authController = context.read<AuthController>();
    final favoritesController = context.read<FavoritesController>();
    final userId = authController.currentUser?.id;

    if (userId == null) return;

    try {
      // Remover todos os selecionados
      for (final symbol in _selectedSymbols) {
        await favoritesController.removeFavorite(userId, symbol);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_selectedSymbols.length} favorito(s) removido(s)'),
            backgroundColor: context.colors.success,
          ),
        );
      }

      _exitSelectionMode();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Erro ao remover favoritos'),
            backgroundColor: context.colors.error,
          ),
        );
      }
    }
  }

  void _navigateToDetail(Crypto crypto) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CryptoDetailScreen(crypto: crypto),
      ),
    );
  }
}

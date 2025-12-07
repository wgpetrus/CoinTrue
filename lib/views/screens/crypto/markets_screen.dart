import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../utils/constants.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/crypto/crypto_controllers.dart';
import '../../../controllers/favorites_controller.dart';
import '../../../models/crypto/crypto_models.dart';
import '../../widgets/crypto/crypto_list_item.dart';
import 'crypto_detail_screen.dart';
import 'favorites_screen.dart';

/// Mercados Screen (Fase 4)
/// 
/// Tela de mercados com:
/// - Campo de busca
/// - Filtros (Todos, Maiores Altas, Maiores Baixas)
/// - Lista completa de criptomoedas (até 50)
class MarketsScreen extends StatefulWidget {
  const MarketsScreen({super.key});

  @override
  State<MarketsScreen> createState() => _MarketsScreenState();
}

class _MarketsScreenState extends State<MarketsScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'Todos';
  final List<String> _filters = ['Todos', 'Maiores Altas', 'Maiores Baixas'];
  List<Crypto> _searchResults = [];
  bool _isSearching = false;
  
  // Seleção múltipla
  bool _isSelectionMode = false;
  final Set<String> _selectedSymbols = {};

  @override
  void initState() {
    super.initState();
    // Carregar lista completa de criptos ao iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMarkets();
    });
  }

  Future<void> _loadMarkets() async {
    final cryptoController = context.read<CryptoController>();
    // Sempre carregar 100 criptomoedas para a tela de mercados
    // Força o carregamento mesmo se já tiver dados
    await cryptoController.loadCryptos(limit: 100, resetTimer: false);
  }

  void _performSearch(String query) {
    setState(() {
      _searchQuery = query;
      _isSearching = false;
      
      if (query.isEmpty) {
        _searchResults = [];
      } else {
        final cryptoController = context.read<CryptoController>();
        final queryLower = query.toLowerCase();
        
        _searchResults = cryptoController.cryptos.where((crypto) {
          return crypto.name.toLowerCase().contains(queryLower) ||
                 crypto.symbol.toLowerCase().contains(queryLower);
        }).toList();
      }
    });
  }

  List<Crypto> _getFilteredCryptos(List<Crypto> cryptos) {
    var filtered = cryptos;

    // Aplicar filtro
    if (_selectedFilter == 'Maiores Altas') {
      filtered = filtered.where((c) => c.priceChange24h > 0).toList();
      filtered.sort((a, b) => b.priceChange24h.compareTo(a.priceChange24h));
    } else if (_selectedFilter == 'Maiores Baixas') {
      filtered = filtered.where((c) => c.priceChange24h < 0).toList();
      filtered.sort((a, b) => a.priceChange24h.compareTo(b.priceChange24h));
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppConstants.colors;
    final cryptoController = context.watch<CryptoController>();
    
    // Usa resultados da busca se estiver buscando, senão usa a lista normal
    final cryptosToShow = _searchQuery.isNotEmpty ? _searchResults : cryptoController.cryptos;
    final filteredCryptos = _getFilteredCryptos(cryptosToShow);

    return Scaffold(
      backgroundColor: colors.white,
      appBar: AppBar(
        backgroundColor: colors.white,
        elevation: 0,
        leading: _isSelectionMode
            ? IconButton(
                icon: PhosphorIcon(
                  PhosphorIcons.x(),
                  size: 24,
                ),
                onPressed: _exitSelectionMode,
              )
            : null,
        title: Text(
          _isSelectionMode 
              ? '${_selectedSymbols.length} selecionadas'
              : 'Mercados',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: colors.darkGray,
          ),
        ),
        actions: [
          if (_isSelectionMode && _selectedSymbols.isNotEmpty)
            IconButton(
              icon: PhosphorIcon(
                PhosphorIcons.star(PhosphorIconsStyle.fill),
                size: 24,
                color: colors.primaryDark,
              ),
              onPressed: _addSelectedToFavorites,
              tooltip: 'Adicionar aos favoritos',
            )
          else if (!_isSelectionMode)
            IconButton(
              icon: PhosphorIcon(
                PhosphorIcons.star(),
                size: 24,
                color: colors.darkGray,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FavoritesScreen(),
                  ),
                );
              },
              tooltip: 'Ver favoritos',
            ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await cryptoController.refreshPrices();
          },
          color: colors.primary,
          child: Column(
            children: [
              // Campo de busca (Fase 4.2) - Melhorado
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colors.primary.withValues(alpha: 0.08),
                        colors.primary.withValues(alpha: 0.04),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _searchQuery.isNotEmpty 
                        ? colors.primary.withValues(alpha: 0.3)
                        : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: TextField(
                    onChanged: (value) {
                      _performSearch(value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Buscar criptomoeda...',
                      hintStyle: TextStyle(
                        color: colors.mediumGray,
                        fontSize: 14,
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
                                _searchQuery = '';
                                _searchResults = [];
                                _isSearching = false;
                              });
                            },
                          )
                        : _isSearching
                          ? Padding(
                              padding: const EdgeInsets.all(12),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                                ),
                              ),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),

              // Filtros (Fase 4.3)
              SizedBox(
                height: 48,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final filter = _filters[index];
                    final isSelected = _selectedFilter == filter;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? colors.primary : colors.lightGray,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            filter,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? colors.white : colors.mediumGray,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Lista de criptomoedas (Fase 4.5)
              Expanded(
                child: _isSearching
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Buscando...',
                              style: TextStyle(
                                fontSize: 14,
                                color: colors.mediumGray,
                              ),
                            ),
                          ],
                        ),
                      )
                    : _buildCryptoList(
                        cryptoController: cryptoController,
                        filteredCryptos: filteredCryptos,
                        colors: colors,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCryptoList({
    required CryptoController cryptoController,
    required List<Crypto> filteredCryptos,
    required AppColors colors,
  }) {
    if (cryptoController.isLoading && cryptoController.cryptos.isEmpty) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colors.primary.withValues(alpha: 0.1),
                colors.secondary.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: colors.primary.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colors.primary, colors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(colors.white),
                    strokeWidth: 3,
                  ),
                ),
              ).animate(
                onPlay: (controller) => controller.repeat(),
              ).scale(
                duration: 1000.ms,
                begin: const Offset(0.95, 0.95),
                end: const Offset(1.05, 1.05),
              ),
              const SizedBox(height: 24),
              Text(
                'Carregando mercados...',
                style: TextStyle(
                  color: colors.darkGray,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Aguarde um momento',
                style: TextStyle(
                  color: colors.mediumGray,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (cryptoController.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PhosphorIcon(
                PhosphorIcons.warning(PhosphorIconsStyle.fill),
                size: 48,
                color: colors.error,
              ),
              const SizedBox(height: 16),
              Text(
                cryptoController.error!,
                style: TextStyle(
                  fontSize: 14,
                  color: colors.error,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadMarkets,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.white,
                ),
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (filteredCryptos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PhosphorIcon(
                PhosphorIcons.magnifyingGlass(),
                size: 48,
                color: colors.mediumGray,
              ),
              const SizedBox(height: 16),
              Text(
                _searchQuery.isNotEmpty
                    ? 'Nenhuma criptomoeda encontrada'
                    : 'Nenhuma criptomoeda disponível',
                style: TextStyle(
                  fontSize: 14,
                  color: colors.mediumGray,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: filteredCryptos.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final crypto = filteredCryptos[index];
        final isSelected = _selectedSymbols.contains(crypto.symbol);
        
        return GestureDetector(
          onLongPress: () => _enterSelectionMode(crypto.symbol),
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
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CryptoDetailScreen(
                                crypto: crypto,
                              ),
                            ),
                          );
                        },
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
      },
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

  Future<void> _addSelectedToFavorites() async {
    final authController = context.read<AuthController>();
    final favoritesController = context.read<FavoritesController>();
    final userId = authController.currentUser?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Faça login para adicionar favoritos'),
          backgroundColor: AppConstants.colors.error,
        ),
      );
      return;
    }

    try {
      // Adicionar todos os selecionados
      for (final symbol in _selectedSymbols) {
        await favoritesController.addFavorite(userId, symbol);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_selectedSymbols.length} favorito(s) adicionado(s)'),
            backgroundColor: AppConstants.colors.success,
          ),
        );
      }

      _exitSelectionMode();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Erro ao adicionar favoritos'),
            backgroundColor: AppConstants.colors.error,
          ),
        );
      }
    }
  }
}

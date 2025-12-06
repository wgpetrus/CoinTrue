import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../utils/constants.dart';
import '../../../controllers/crypto/crypto_controllers.dart';
import '../../../models/crypto/crypto_models.dart';
import '../../widgets/crypto/crypto_list_item.dart';
import 'crypto_detail_screen.dart';

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

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchQuery = '';
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _searchQuery = query;
      _isSearching = true;
    });

    try {
      final cryptoController = context.read<CryptoController>();
      final results = await cryptoController.searchCryptos(query);
      
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      debugPrint('Error searching: $e');
      setState(() {
        _isSearching = false;
      });
    }
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
        title: Text(
          'Mercados',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: colors.darkGray,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await cryptoController.refreshPrices();
          },
          color: colors.yellow,
          child: Column(
            children: [
              // Campo de busca (Fase 4.2)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.lightGray,
                    borderRadius: BorderRadius.circular(16),
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
                          color: colors.mediumGray,
                        ),
                      ),
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
                          color: isSelected ? colors.yellow : colors.lightGray,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            filter,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? colors.darkGray : colors.mediumGray,
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
                              valueColor: AlwaysStoppedAnimation<Color>(colors.yellow),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(colors.yellow),
            ),
            const SizedBox(height: 16),
            Text(
              'Carregando mercados...',
              style: TextStyle(
                fontSize: 14,
                color: colors.mediumGray,
              ),
            ),
          ],
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
                  backgroundColor: colors.yellow,
                  foregroundColor: colors.darkGray,
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
        return CryptoListItem(
          crypto: crypto,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CryptoDetailScreen(
                  crypto: crypto,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

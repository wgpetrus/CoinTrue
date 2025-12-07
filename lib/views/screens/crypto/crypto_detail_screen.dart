import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../models/crypto/crypto_models.dart';
import '../../../utils/constants.dart';
import '../../../services/crypto/coingecko_api_service.dart';
import '../../../services/crypto/chart_cache_service.dart';
import '../../widgets/crypto/crypto_icon.dart';
import '../../widgets/crypto/animated_price_chart.dart';
import '../../widgets/favorite_button.dart';
import 'transaction_screen.dart';

/// Tela de detalhes de uma criptomoeda
/// 
/// Exibe:
/// - Header com ícone, nome, preço e variação
/// - Gráfico de preço (mockado)
/// - Estatísticas detalhadas
/// - Botões de ação (Comprar/Vender)
class CryptoDetailScreen extends StatefulWidget {
  final Crypto crypto;

  const CryptoDetailScreen({
    super.key,
    required this.crypto,
  });

  @override
  State<CryptoDetailScreen> createState() => _CryptoDetailScreenState();
}

class _CryptoDetailScreenState extends State<CryptoDetailScreen> {
  String _selectedPeriod = '24H';
  final List<String> _periods = ['24H', '7D', '1M', '1A'];
  List<FlSpot>? _chartData;
  bool _isLoadingChart = false;
  String? _chartError;
  
  // Instâncias dos serviços
  late final CoinGeckoApiService _apiService;
  late final ChartCacheService _cacheService;

  @override
  void initState() {
    super.initState();
    _apiService = CoinGeckoApiService();
    _cacheService = ChartCacheService();
    _loadChartData();
  }

  Future<void> _loadChartData() async {
    // Evita múltiplas chamadas simultâneas
    if (_isLoadingChart) {
      debugPrint('CryptoDetailScreen: Already loading chart, skipping...');
      return;
    }
    
    setState(() {
      _isLoadingChart = true;
      _chartError = null;
    });

    List<FlSpot>? finalData;
    
    try {
      // 1. Tenta buscar dados reais da API
      debugPrint('CryptoDetailScreen: Fetching from API for ${widget.crypto.id} ($_selectedPeriod)');
      final apiData = await _apiService.getChartData(widget.crypto.id, _selectedPeriod);
      debugPrint('CryptoDetailScreen: API returned ${apiData.length} points');
      
      if (apiData.isNotEmpty) {
        // Dados reais da API - salva no cache (não aguarda)
        finalData = apiData;
        _cacheService.saveChartData(widget.crypto.id, _selectedPeriod, apiData);
        debugPrint('CryptoDetailScreen: ✅ Using API data');
      }
    } catch (e) {
      debugPrint('CryptoDetailScreen: ❌ API error: $e');
    }
    
    // 2. Se API falhou, tenta cache Firebase
    if (finalData == null) {
      try {
        debugPrint('CryptoDetailScreen: Trying Firebase cache...');
        final cachedData = await _cacheService.getChartData(widget.crypto.id, _selectedPeriod);
        
        if (cachedData != null && cachedData.isNotEmpty) {
          finalData = cachedData;
          debugPrint('CryptoDetailScreen: ✅ Using cached data (${cachedData.length} points)');
        }
      } catch (e) {
        debugPrint('CryptoDetailScreen: ❌ Cache error: $e');
      }
    }
    
    // 3. Fallback final: dados mockados
    if (finalData == null) {
      finalData = _generateMockData();
      debugPrint('CryptoDetailScreen: ⚠️ Using mock data');
    }
    
    if (mounted) {
      setState(() {
        _chartData = finalData;
        _isLoadingChart = false;
        _chartError = null;
      });
    }
  }
  
  /// Gera dados mockados para o gráfico baseados no preço atual
  List<FlSpot> _generateMockData() {
    final basePrice = widget.crypto.currentPrice;
    final change = widget.crypto.priceChange24h / 100;
    final points = 20;
    
    return List.generate(points, (index) {
      final progress = index / (points - 1);
      // Simula variação com base na mudança de 24h
      final variation = (change * progress) + (0.02 * (index % 3 - 1));
      final price = basePrice * (1 + variation);
      return FlSpot(index.toDouble(), price);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppConstants.colors;
    final priceFormatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );

    return Scaffold(
      backgroundColor: colors.white,
      appBar: AppBar(
        backgroundColor: colors.white,
        elevation: 0,
        leading: IconButton(
          icon: PhosphorIcon(
            PhosphorIcons.arrowLeft(),
            size: 24,
            color: colors.darkGray,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FavoriteButton(
              cryptoSymbol: widget.crypto.symbol,
              size: 24,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            _buildHeader(widget.crypto, colors, priceFormatter),
            
            const SizedBox(height: 32),
            
            // Gráfico
            _buildChart(colors),
            
            const SizedBox(height: 32),
            
            // Estatísticas
            _buildStats(widget.crypto, colors, priceFormatter),
            
            const SizedBox(height: 32),
            
            // Botões de ação
            _buildActionButtons(colors),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Crypto crypto, AppColors colors, NumberFormat formatter) {
    return Column(
      children: [
        // Ícone
        CryptoIcon(
          symbol: crypto.symbol,
          imageUrl: crypto.imageUrl,
          size: 80,
        ),
        
        const SizedBox(height: 16),
        
        // Nome
        Text(
          crypto.name,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: colors.darkGray,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 4),
        
        // Símbolo
        Text(
          crypto.symbol,
          style: TextStyle(
            fontSize: 14,
            color: colors.mediumGray,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Preço
        Text(
          formatter.format(crypto.currentPrice), // Preço já vem convertido para BRL
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: colors.darkGray,
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Variação
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PhosphorIcon(
              crypto.priceChange24h >= 0
                  ? PhosphorIcons.caretUp(PhosphorIconsStyle.fill)
                  : PhosphorIcons.caretDown(PhosphorIconsStyle.fill),
              size: 16,
              color: crypto.priceChange24h >= 0 ? colors.success : colors.error,
            ),
            const SizedBox(width: 4),
            Text(
              '${crypto.priceChange24h >= 0 ? '+' : ''}${crypto.priceChange24h.toStringAsFixed(2)}%',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: crypto.priceChange24h >= 0 ? colors.success : colors.error,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(24h)',
              style: TextStyle(
                fontSize: 14,
                color: colors.mediumGray,
              ),
            ),
          ],
        ),
      ],
    );
  }



  Widget _buildChart(AppColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gráfico de Preço',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colors.darkGray,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Seletor de período
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _periods.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final period = _periods[index];
              final isSelected = _selectedPeriod == period;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPeriod = period;
                  });
                  _loadChartData();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? colors.primaryDark : colors.lightGray,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      period,
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
        
        // Gráfico
        Container(
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
              color: colors.primary.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: _isLoadingChart
              ? SizedBox(
                  height: 200,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(colors.primaryDark),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Carregando gráfico...',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.mediumGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : AnimatedPriceChart(
                  data: _chartData ?? [],
                  period: _selectedPeriod,
                  isPositive: widget.crypto.priceChange24h >= 0,
                ),
        ),
      ],
    );
  }

  Widget _buildStats(Crypto crypto, AppColors colors, NumberFormat formatter) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estatísticas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colors.darkGray,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Grid 2x2
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Alta 24h',
                formatter.format((crypto.high24h ?? crypto.currentPrice * 1.05) * 5.5),
                colors,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Baixa 24h',
                formatter.format((crypto.low24h ?? crypto.currentPrice * 0.95) * 5.5),
                colors,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Volume 24h',
                _formatLargeNumber((crypto.volume24h ?? 0) * 5.5),
                colors,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Market Cap',
                _formatLargeNumber((crypto.marketCap ?? 0) * 5.5),
                colors,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.primary.withValues(alpha: 0.08),
            colors.primary.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: colors.mediumGray,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colors.darkGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(AppColors colors) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TransactionScreen(
                    crypto: widget.crypto,
                    initialType: TransactionType.buy,
                  ),
                ),
              );
              
              // Se a transação foi bem-sucedida, mostrar feedback
              if (result == true && mounted) {
                // Dados já foram atualizados pelo TransactionScreen
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Comprar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 12),
        
        Expanded(
          child: OutlinedButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TransactionScreen(
                    crypto: widget.crypto,
                    initialType: TransactionType.sell,
                  ),
                ),
              );
              
              // Se a transação foi bem-sucedida, mostrar feedback
              if (result == true && mounted) {
                // Dados já foram atualizados pelo TransactionScreen
              }
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.darkGray,
              side: BorderSide(color: colors.mediumGray),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Vender',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  LineChartData _generateChartData(AppColors colors, List<FlSpot> spots) {
    return LineChartData(
      gridData: const FlGridData(show: false),
      titlesData: const FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: colors.primaryDark,
          barWidth: 3,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colors.primaryDark.withValues(alpha: 0.3),
                colors.primaryDark.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatLargeNumber(double number) {
    if (number >= 1e12) {
      return 'R\$ ${(number / 1e12).toStringAsFixed(2)}T';
    } else if (number >= 1e9) {
      return 'R\$ ${(number / 1e9).toStringAsFixed(2)}B';
    } else if (number >= 1e6) {
      return 'R\$ ${(number / 1e6).toStringAsFixed(2)}M';
    } else if (number >= 1e3) {
      return 'R\$ ${(number / 1e3).toStringAsFixed(2)}K';
    } else {
      return 'R\$ ${number.toStringAsFixed(2)}';
    }
  }
}

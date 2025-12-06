import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/crypto/crypto_controllers.dart';
import '../../../models/crypto/crypto_models.dart';
import '../../../utils/constants.dart';
import '../../widgets/crypto/crypto_icon.dart';
import 'crypto_detail_screen.dart';
import 'home_screen.dart';

/// Tela de Portfólio
/// 
/// Exibe:
/// - Card de valor total do portfólio
/// - Estatísticas (lucro/prejuízo, total investido)
/// - Lista de ativos do usuário
/// - Gráfico de distribuição (futuro)
class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {

  
  @override
  void initState() {
    super.initState();
    _loadPortfolio();
  }
  
  Future<void> _loadPortfolio() async {
    final authController = context.read<AuthController>();
    final portfolioController = context.read<PortfolioController>();
    
    if (authController.currentUser != null) {
      await portfolioController.loadPortfolio(authController.currentUser!.id);
    }
  }
  
  Future<void> _refreshPortfolio() async {
    await _loadPortfolio();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppConstants.colors;
    final portfolioController = context.watch<PortfolioController>();
    final walletController = context.watch<WalletController>();

    return Scaffold(
      backgroundColor: colors.white,
      appBar: AppBar(
        title: Text(
          'Portfólio',
          style: TextStyle(
            color: colors.darkGray,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          // Botão de ordenação
          PopupMenuButton<PortfolioSortType>(
            icon: PhosphorIcon(
              PhosphorIcons.funnelSimple(),
              color: colors.darkGray,
              size: 24,
            ),
            onSelected: (type) {
              portfolioController.sortAssets(type);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: PortfolioSortType.value,
                child: Row(
                  children: [
                    PhosphorIcon(
                      PhosphorIcons.currencyCircleDollar(),
                      size: 20,
                      color: colors.mediumGray,
                    ),
                    const SizedBox(width: 8),
                    const Text('Por valor'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: PortfolioSortType.profitLoss,
                child: Row(
                  children: [
                    PhosphorIcon(
                      PhosphorIcons.trendUp(),
                      size: 20,
                      color: colors.mediumGray,
                    ),
                    const SizedBox(width: 8),
                    const Text('Por lucro/prejuízo'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: PortfolioSortType.name,
                child: Row(
                  children: [
                    PhosphorIcon(
                      PhosphorIcons.sortAscending(),
                      size: 20,
                      color: colors.mediumGray,
                    ),
                    const SizedBox(width: 8),
                    const Text('Por nome'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: portfolioController.isLoading
          ? _buildLoading(colors)
          : portfolioController.error != null
              ? _buildError(colors, portfolioController.error!)
              : !portfolioController.hasAssets
                  ? _buildEmptyState(colors)
                  : RefreshIndicator(
                      onRefresh: _refreshPortfolio,
                      color: colors.yellow,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Card de Valor Total
                            _PortfolioValueCard(
                              totalValue: portfolioController.totalValue,
                              profitLoss: portfolioController.totalProfitLoss,
                              profitLossPercent: portfolioController.totalProfitLossPercent,
                              balance: walletController.balance,
                            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, duration: 300.ms),
                            
                            const SizedBox(height: 24),
                            
                            // Estatísticas
                            _buildStatsCards(colors, portfolioController),
                            
                            const SizedBox(height: 24),
                            
                            // Gráfico de Distribuição
                            _DistributionChart(
                              distribution: portfolioController.getDistribution(),
                              portfolioController: portfolioController,
                            ).animate().fadeIn(duration: 300.ms, delay: 200.ms).slideY(begin: 0.1, duration: 300.ms, delay: 200.ms),
                            
                            const SizedBox(height: 24),
                            
                            // Título da lista
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Meus Ativos',
                                  style: TextStyle(
                                    color: colors.darkGray,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${portfolioController.assetsCount} ${portfolioController.assetsCount == 1 ? 'ativo' : 'ativos'}',
                                  style: TextStyle(
                                    color: colors.mediumGray,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Lista de Ativos
                            ...portfolioController.assets.asMap().entries.map((entry) {
                              final index = entry.key;
                              final asset = entry.value;
                              final crypto = portfolioController.getCrypto(asset.cryptoId);
                              
                              if (crypto == null) return const SizedBox.shrink();
                              
                              return _PortfolioAssetItem(
                                asset: asset,
                                crypto: crypto,
                                currentValue: portfolioController.getAssetCurrentValue(asset),
                                profitLoss: portfolioController.getAssetProfitLoss(asset),
                                profitLossPercent: portfolioController.getAssetProfitLossPercent(asset),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CryptoDetailScreen(crypto: crypto),
                                    ),
                                  );
                                },
                              ).animate().fadeIn(
                                duration: 300.ms,
                                delay: (index * 50).ms,
                              ).slideX(
                                begin: 0.1,
                                duration: 300.ms,
                                delay: (index * 50).ms,
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
    );
  }
  
  Widget _buildLoading(AppColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(colors.yellow),
          ),
          const SizedBox(height: 16),
          Text(
            'Carregando portfólio...',
            style: TextStyle(
              color: colors.mediumGray,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildError(AppColors colors, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PhosphorIcon(
              PhosphorIcons.warningCircle(PhosphorIconsStyle.fill),
              size: 64,
              color: colors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colors.darkGray,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(
                fontSize: 14,
                color: colors.mediumGray,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _refreshPortfolio,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.yellow,
                foregroundColor: colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Tentar novamente'),
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
            PhosphorIcon(
              PhosphorIcons.briefcase(PhosphorIconsStyle.fill),
              size: 80,
              color: colors.mediumGray.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Portfólio vazio',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colors.darkGray,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Você ainda não possui nenhuma criptomoeda.\nComece comprando sua primeira cripto!',
              style: TextStyle(
                fontSize: 14,
                color: colors.mediumGray,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Navegar para Mercados usando o callback do HomeScreen
                final homeState = context.findAncestorStateOfType<HomeScreenState>();
                if (homeState != null) {
                  homeState.navigateToTab(2);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.yellow,
                foregroundColor: colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PhosphorIcon(
                    PhosphorIcons.chartLine(PhosphorIconsStyle.bold),
                    color: colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Ver Mercados',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatsCards(AppColors colors, PortfolioController controller) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Total Investido',
            value: 'R\$ ${controller.totalInvested.toStringAsFixed(2)}',
            icon: PhosphorIcons.wallet(PhosphorIconsStyle.fill),
            color: colors.mediumGray,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Lucro/Prejuízo',
            value: 'R\$ ${controller.totalProfitLoss.toStringAsFixed(2)}',
            icon: controller.totalProfitLoss >= 0
                ? PhosphorIcons.trendUp(PhosphorIconsStyle.bold)
                : PhosphorIcons.trendDown(PhosphorIconsStyle.bold),
            color: controller.totalProfitLoss >= 0 ? colors.success : colors.error,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms, delay: 100.ms).slideY(begin: 0.1, duration: 300.ms, delay: 100.ms);
  }
}

/// Card de Valor Total do Portfólio
class _PortfolioValueCard extends StatelessWidget {
  final double totalValue;
  final double profitLoss;
  final double profitLossPercent;
  final double balance;

  const _PortfolioValueCard({
    required this.totalValue,
    required this.profitLoss,
    required this.profitLossPercent,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppConstants.colors;
    final grandTotal = totalValue + balance;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF2D2D2D),
            const Color(0xFF1A1A1A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Valor Total',
                style: TextStyle(
                  color: colors.white.withValues(alpha: 0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              PhosphorIcon(
                PhosphorIcons.briefcase(PhosphorIconsStyle.fill),
                color: colors.white.withValues(alpha: 0.7),
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'R\$ ${grandTotal.toStringAsFixed(2)}',
            style: TextStyle(
              color: colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              PhosphorIcon(
                profitLoss >= 0
                    ? PhosphorIcons.caretUp(PhosphorIconsStyle.fill)
                    : PhosphorIcons.caretDown(PhosphorIconsStyle.fill),
                color: colors.white,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                _formatProfitLoss(profitLoss, profitLossPercent),
                style: TextStyle(
                  color: colors.white.withValues(alpha: 0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Em Criptos',
                    style: TextStyle(
                      color: colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'R\$ ${totalValue.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Saldo Disponível',
                    style: TextStyle(
                      color: colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'R\$ ${balance.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  /// Formata lucro/prejuízo evitando -0.00
  String _formatProfitLoss(double profitLoss, double profitLossPercent) {
    // Arredondar para evitar -0.00
    final roundedPL = profitLoss.abs() < 0.01 ? 0.0 : profitLoss;
    final roundedPercent = profitLossPercent.abs() < 0.01 ? 0.0 : profitLossPercent;
    
    final sign = roundedPL >= 0 ? '+' : '';
    return '$sign R\$ ${roundedPL.toStringAsFixed(2)} ($sign${roundedPercent.toStringAsFixed(2)}%)';
  }
}

/// Card de Estatística
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final PhosphorIconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppConstants.colors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.lightGray,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PhosphorIcon(
                icon,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: colors.mediumGray,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: colors.darkGray,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Item de Ativo do Portfólio
class _PortfolioAssetItem extends StatelessWidget {
  final PortfolioAsset asset;
  final Crypto crypto;
  final double currentValue;
  final double profitLoss;
  final double profitLossPercent;
  final VoidCallback onTap;

  const _PortfolioAssetItem({
    required this.asset,
    required this.crypto,
    required this.currentValue,
    required this.profitLoss,
    required this.profitLossPercent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppConstants.colors;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.white,
        border: Border.all(color: colors.lightGray),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Ícone
                CryptoIcon(
                  symbol: crypto.symbol,
                  imageUrl: crypto.imageUrl,
                  size: 48,
                ),
                
                const SizedBox(width: 12),
                
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        crypto.name,
                        style: TextStyle(
                          color: colors.darkGray,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${asset.quantity.toStringAsFixed(8)} ${crypto.symbol}',
                        style: TextStyle(
                          color: colors.mediumGray,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Valores
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'R\$ ${currentValue.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: colors.darkGray,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PhosphorIcon(
                          profitLoss >= 0
                              ? PhosphorIcons.caretUp(PhosphorIconsStyle.fill)
                              : PhosphorIcons.caretDown(PhosphorIconsStyle.fill),
                          color: profitLoss >= 0 ? colors.success : colors.error,
                          size: 12,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          _formatPercent(profitLossPercent),
                          style: TextStyle(
                            color: _getPercentColor(profitLossPercent, colors),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  /// Formata percentual evitando -0.00%
  String _formatPercent(double percent) {
    final rounded = percent.abs() < 0.01 ? 0.0 : percent;
    final sign = rounded > 0 ? '+' : rounded < 0 ? '' : '';
    return '$sign${rounded.toStringAsFixed(2)}%';
  }
  
  /// Retorna cor para percentual
  Color _getPercentColor(double percent, AppColors colors) {
    final rounded = percent.abs() < 0.01 ? 0.0 : percent;
    return rounded >= 0 ? colors.success : colors.error;
  }
}


/// Gráfico de Distribuição do Portfólio
class _DistributionChart extends StatefulWidget {
  final List<PortfolioDistribution> distribution;
  final PortfolioController portfolioController;

  const _DistributionChart({
    required this.distribution,
    required this.portfolioController,
  });

  @override
  State<_DistributionChart> createState() => _DistributionChartState();
}

class _DistributionChartState extends State<_DistributionChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final colors = AppConstants.colors;

    if (widget.distribution.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.white,
        border: Border.all(color: colors.lightGray),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Distribuição do Portfólio',
            style: TextStyle(
              color: colors.darkGray,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gráfico de Pizza
              SizedBox(
                width: 140,
                height: 140,
                child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              _touchedIndex = -1;
                              return;
                            }
                            _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 2,
                      centerSpaceRadius: 50,
                      sections: _buildSections(colors),
                    ),
                  ),
                ),
              const SizedBox(width: 24),
              // Legenda
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.distribution.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final crypto = widget.portfolioController.getCrypto(item.cryptoId);
                    
                    if (crypto == null) return const SizedBox.shrink();
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: _getChartColor(index, colors),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  crypto.symbol,
                                  style: TextStyle(
                                    color: colors.darkGray,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${item.percentage.toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    color: colors.mediumGray,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'R\$ ${item.value.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: colors.darkGray,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections(AppColors colors) {
    return widget.distribution.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isTouched = index == _touchedIndex;
      final radius = isTouched ? 65.0 : 55.0;
      final fontSize = isTouched ? 16.0 : 14.0;

      return PieChartSectionData(
        color: _getChartColor(index, colors),
        value: item.percentage,
        title: '${item.percentage.toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        badgeWidget: isTouched
            ? Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Text(
                  widget.portfolioController.getCrypto(item.cryptoId)?.symbol ?? '',
                  style: TextStyle(
                    color: colors.darkGray,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
        badgePositionPercentageOffset: 1.3,
      );
    }).toList();
  }

  Color _getChartColor(int index, AppColors colors) {
    // Busca a cripto pelo índice para pegar o símbolo
    if (index >= 0 && index < widget.distribution.length) {
      final item = widget.distribution[index];
      final crypto = widget.portfolioController.getCrypto(item.cryptoId);
      
      if (crypto != null) {
        // Retorna cor específica da moeda
        return _getCryptoColorBySymbol(crypto.symbol, colors);
      }
    }
    
    // Fallback: cores alternadas
    final chartColors = [
      colors.bitcoin,      // Laranja
      colors.ethereum,     // Roxo
      colors.cardano,      // Azul
      colors.solana,       // Rosa
      colors.success,      // Verde
      colors.yellow,       // Amarelo
      colors.error,        // Vermelho
      colors.mediumGray,   // Cinza
    ];
    
    return chartColors[index % chartColors.length];
  }
  
  /// Retorna cor fixa baseada no símbolo da moeda
  Color _getCryptoColorBySymbol(String symbol, AppColors colors) {
    switch (symbol.toUpperCase()) {
      case 'BTC':
        return colors.bitcoin;      // Laranja
      case 'ETH':
        return colors.ethereum;     // Roxo
      case 'ADA':
        return colors.cardano;      // Azul
      case 'SOL':
        return colors.solana;       // Rosa
      case 'USDT':
      case 'USDC':
        return colors.success;      // Verde (stablecoins)
      case 'BNB':
        return colors.yellow;       // Amarelo
      case 'XRP':
      case 'DOGE':
        return colors.error;        // Vermelho
      default:
        return colors.mediumGray;   // Cinza (outras)
    }
  }
}

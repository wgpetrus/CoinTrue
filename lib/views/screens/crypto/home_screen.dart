import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../utils/constants.dart';
import '../../../utils/responsive_layout.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/crypto/crypto_controllers.dart';
import '../../widgets/crypto/crypto_list_item.dart';
import '../../widgets/crypto/crypto_selector_sheet.dart';
import 'markets_screen.dart';
import 'portfolio_screen.dart';
import 'activity_screen.dart';
import 'crypto_detail_screen.dart';
import 'profile_screen.dart';
import 'convert_crypto_screen.dart';
import '../../../models/crypto/transaction.dart';

/// Home Screen - Tela principal após login
/// 
/// Contém:
/// - Bottom Navigation Bar
/// - Dashboard (primeira aba)
/// - Navegação para outras telas
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Lista de telas
  late final List<Widget> _screens;
  
  // Key para acessar o estado da ActivityScreen
  final GlobalKey<ActivityScreenState> _activityKey = GlobalKey<ActivityScreenState>();

  @override
  void initState() {
    super.initState();
    _screens = [
      _DashboardTab(),
      const PortfolioScreen(),
      const MarketsScreen(),
      ActivityScreen(key: _activityKey),
    ];
    
    // Iniciar auto-refresh global
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CryptoController>().startAutoUpdate();
    });
  }

  @override
  void dispose() {
    // Parar auto-refresh ao sair do app
    context.read<CryptoController>().stopAutoUpdate();
    super.dispose();
  }
  
  /// Navega para uma aba específica
  void navigateToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    // Recarregar dados quando voltar para Dashboard
    if (index == 0) {
      _reloadDashboard();
    }
    
    // Recarregar transações quando ir para Atividade
    if (index == 3) {
      _activityKey.currentState?.reloadTransactions();
    }
  }
  
  /// Recarrega dados do Dashboard
  Future<void> _reloadDashboard() async {
    final authController = context.read<AuthController>();
    final walletController = context.read<WalletController>();
    final portfolioController = context.read<PortfolioController>();
    
    final userId = authController.currentUser?.id;
    if (userId != null) {
      await walletController.loadWallet(userId);
      await portfolioController.loadPortfolio(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppConstants.colors;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: PhosphorIcons.house(),
                  activeIcon: PhosphorIcons.house(PhosphorIconsStyle.fill),
                  label: 'Início',
                  colors: colors,
                ),
                _buildNavItem(
                  index: 1,
                  icon: PhosphorIcons.briefcase(),
                  activeIcon: PhosphorIcons.briefcase(PhosphorIconsStyle.fill),
                  label: 'Portfólio',
                  colors: colors,
                ),
                // Botão central de ações
                _buildCentralActionButton(colors),
                _buildNavItem(
                  index: 2,
                  icon: PhosphorIcons.chartLine(),
                  activeIcon: PhosphorIcons.chartLine(PhosphorIconsStyle.fill),
                  label: 'Mercados',
                  colors: colors,
                ),
                _buildNavItem(
                  index: 3,
                  icon: PhosphorIcons.clockCounterClockwise(),
                  activeIcon: PhosphorIcons.clockCounterClockwise(PhosphorIconsStyle.fill),
                  label: 'Atividade',
                  colors: colors,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required PhosphorIconData icon,
    required PhosphorIconData activeIcon,
    required String label,
    required AppColors colors,
  }) {
    final isActive = _currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PhosphorIcon(
              isActive ? activeIcon : icon,
              size: 24,
              color: isActive ? colors.yellowDark : colors.mediumGray,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? colors.yellowDark : colors.mediumGray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Botão central de ações (maior e preto)
  Widget _buildCentralActionButton(AppColors colors) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _showActionsBottomSheet(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: colors.darkGray,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colors.darkGray.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: PhosphorIcon(
                  PhosphorIcons.plus(PhosphorIconsStyle.bold),
                  size: 28,
                  color: colors.white,
                ),
              ),
            )
                .animate(
                  onPlay: (controller) => controller.forward(),
                )
                .scale(
                  duration: 150.ms,
                  curve: Curves.easeOut,
                ),
          ],
        ),
      ),
    );
  }

  /// Mostra bottom sheet com opções de ações
  void _showActionsBottomSheet(BuildContext context) {
    final colors = AppConstants.colors;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            const SizedBox(height: 24),
            
            // Título
            Text(
              'Ações',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colors.darkGray,
              ),
            ),
            const SizedBox(height: 24),
            
            // Opções
            _buildActionOption(
              context: context,
              icon: PhosphorIcons.wallet(PhosphorIconsStyle.fill),
              title: 'Depositar',
              subtitle: 'Em breve',
              color: colors.info,
              enabled: false,
            ),
            const SizedBox(height: 12),
            _buildActionOption(
              context: context,
              icon: PhosphorIcons.arrowsLeftRight(PhosphorIconsStyle.fill),
              title: 'Converter',
              subtitle: 'Trocar entre criptomoedas',
              color: colors.info,
              enabled: true,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ConvertCryptoScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildActionOption(
              context: context,
              icon: PhosphorIcons.trendUp(PhosphorIconsStyle.fill),
              title: 'Comprar',
              subtitle: 'Adquirir criptomoedas',
              color: colors.success,
              enabled: true,
              onTap: () {
                Navigator.pop(context);
                _showCryptoSelectorForTransaction(context, TransactionType.buy);
              },
            ),
            const SizedBox(height: 12),
            _buildActionOption(
              context: context,
              icon: PhosphorIcons.trendDown(PhosphorIconsStyle.fill),
              title: 'Vender',
              subtitle: 'Vender suas criptomoedas',
              color: colors.error,
              enabled: true,
              onTap: () {
                Navigator.pop(context);
                _showCryptoSelectorForTransaction(context, TransactionType.sell);
              },
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      )
          .animate()
          .slideY(begin: 0.3, duration: 300.ms, curve: Curves.easeOut)
          .fadeIn(duration: 200.ms),
    );
  }

  /// Constrói uma opção de ação no bottom sheet
  Widget _buildActionOption({
    required BuildContext context,
    required PhosphorIconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool enabled,
    VoidCallback? onTap,
  }) {
    final colors = AppConstants.colors;
    
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: enabled ? colors.lightGray : colors.lightGray.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: enabled ? color.withValues(alpha: 0.2) : colors.mediumGray.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Ícone
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: enabled ? color.withValues(alpha: 0.15) : colors.mediumGray.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: PhosphorIcon(
                  icon,
                  size: 24,
                  color: enabled ? color : colors.mediumGray,
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Texto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: enabled ? colors.darkGray : colors.mediumGray,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.mediumGray,
                    ),
                  ),
                ],
              ),
            ),
            
            // Seta ou badge "Em breve"
            if (!enabled)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.mediumGray.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Em breve',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colors.mediumGray,
                  ),
                ),
              )
            else
              PhosphorIcon(
                PhosphorIcons.caretRight(PhosphorIconsStyle.bold),
                size: 20,
                color: colors.mediumGray,
              ),
          ],
        ),
      ),
    );
  }

  /// Mostra seletor de cripto para transação (compra/venda)
  void _showCryptoSelectorForTransaction(BuildContext context, TransactionType type) {
    // Carregar todas as moedas antes de mostrar o seletor
    final cryptoController = context.read<CryptoController>();
    cryptoController.loadCryptos(limit: 100, resetTimer: false);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => CryptoSelectorSheet(type: type),
    );
  }
}

/// Dashboard Tab - Primeira aba da Home
/// 
/// Conteúdo principal:
/// - Card de saldo total
/// - Cards de estatísticas
/// - Botões de ação
/// - Lista de principais criptomoedas
class _DashboardTab extends StatefulWidget {
  @override
  State<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<_DashboardTab> {
  @override
  void initState() {
    super.initState();
    // Carregar dados ao iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final cryptoController = context.read<CryptoController>();
    final walletController = context.read<WalletController>();
    final portfolioController = context.read<PortfolioController>();
    final authController = context.read<AuthController>();
    
    // Carregar criptos (top 10 por market cap para home)
    await cryptoController.loadCryptos(limit: 10);
    
    // Carregar carteira e portfólio
    final userId = authController.currentUser?.id;
    if (userId != null) {
      await walletController.loadWallet(userId);
      await portfolioController.loadPortfolio(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppConstants.colors;
    final cryptoController = context.watch<CryptoController>();
    final walletController = context.watch<WalletController>();
    final portfolioController = context.watch<PortfolioController>();
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
        title: Row(
          children: [
            // Avatar do usuário
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colors.yellow, colors.yellowDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  'U',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colors.darkGray,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Home',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colors.darkGray,
              ),
            ),
          ],
        ),
        actions: [
          // Botão de notificações
          IconButton(
            icon: PhosphorIcon(
              PhosphorIcons.bell(),
              size: 24,
              color: colors.darkGray,
            ),
            onPressed: () {
              // TODO: Implementar notificações
            },
          ),
          // Botão de configurações
          IconButton(
            icon: PhosphorIcon(
              PhosphorIcons.gear(),
              size: 24,
              color: colors.darkGray,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await cryptoController.refreshPrices();
          },
          color: colors.yellow,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Card de Saldo Total - Preto Sofisticado
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1A1A1A), Color(0xFF2D2D2D)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
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
                            'Saldo Total',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.7),
                              letterSpacing: 0.5,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: colors.yellow.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: colors.yellow.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.trending_up,
                                  size: 14,
                                  color: colors.yellowDark,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '+0.00%',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: colors.yellowDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      walletController.isLoading
                          ? Row(
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(colors.yellow),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Carregando...',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              priceFormatter.format(walletController.balance),
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: -1,
                              ),
                            ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: colors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            walletController.isLoading
                                ? 'Atualizando...'
                                : 'Disponível para negociação',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Cards de Estatísticas
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: portfolioController.hasAssets && portfolioController.totalProfitLoss >= 0
                                ? [colors.success.withValues(alpha: 0.1), colors.success.withValues(alpha: 0.05)]
                                : [colors.error.withValues(alpha: 0.1), colors.error.withValues(alpha: 0.05)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: portfolioController.hasAssets && portfolioController.totalProfitLoss >= 0
                                ? colors.success.withValues(alpha: 0.2)
                                : colors.error.withValues(alpha: 0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: portfolioController.hasAssets && portfolioController.totalProfitLoss >= 0
                                        ? colors.success.withValues(alpha: 0.15)
                                        : colors.error.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: PhosphorIcon(
                                    portfolioController.hasAssets && portfolioController.totalProfitLoss >= 0
                                        ? PhosphorIcons.trendUp(PhosphorIconsStyle.bold)
                                        : PhosphorIcons.trendDown(PhosphorIconsStyle.bold),
                                    size: 20,
                                    color: _getProfitLossColor(portfolioController, colors),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Lucro 24h',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: colors.mediumGray,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              portfolioController.hasAssets
                                  ? _formatProfitLoss(portfolioController.totalProfitLoss)
                                  : 'R\$ 0,00',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: _getProfitLossColor(portfolioController, colors),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colors.yellow.withValues(alpha: 0.1),
                              colors.yellow.withValues(alpha: 0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: colors.yellow.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: colors.yellow.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: PhosphorIcon(
                                    PhosphorIcons.briefcase(PhosphorIconsStyle.fill),
                                    size: 20,
                                    color: colors.yellowDark,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Ativos',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: colors.mediumGray,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '${portfolioController.assetsCount}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: colors.darkGray,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Seção de Criptomoedas
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Principais Criptomoedas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colors.darkGray,
                      ),
                    ),
                    Row(
                      children: [
                        if (cryptoController.isLoading)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(colors.yellowDark),
                              ),
                            ),
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: colors.success,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Ao vivo',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: colors.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Lista de criptos
                if (cryptoController.isLoading && cryptoController.cryptos.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(colors.yellow),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Carregando criptomoedas...',
                            style: TextStyle(
                              fontSize: 14,
                              color: colors.mediumGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (cryptoController.error != null)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
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
                            onPressed: () => cryptoController.loadCryptos(limit: 10),
                            child: const Text('Tentar Novamente'),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (cryptoController.cryptos.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        'Nenhuma criptomoeda encontrada',
                        style: TextStyle(
                          fontSize: 14,
                          color: colors.mediumGray,
                        ),
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cryptoController.cryptos.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final crypto = cryptoController.cryptos[index];
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
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  /// Formata lucro/prejuízo evitando -0.00
  String _formatProfitLoss(double profitLoss) {
    final roundedPL = profitLoss.abs() < 0.01 ? 0.0 : profitLoss;
    final sign = roundedPL > 0 ? '+' : roundedPL < 0 ? '' : '';
    return '$sign R\$ ${roundedPL.toStringAsFixed(2)}';
  }
  
  /// Retorna a cor correta para lucro/prejuízo
  Color _getProfitLossColor(PortfolioController controller, AppColors colors) {
    if (!controller.hasAssets) return colors.darkGray;
    final roundedPL = controller.totalProfitLoss.abs() < 0.01 ? 0.0 : controller.totalProfitLoss;
    return roundedPL >= 0 ? colors.success : colors.error;
  }
}

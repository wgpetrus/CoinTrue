import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../utils/constants.dart';
import '../../../utils/theme_helper.dart';
import '../../../controllers/controllers.dart';
import '../../../controllers/crypto/crypto_controllers.dart';
import '../../widgets/crypto/crypto_list_item.dart';
import '../../widgets/crypto/crypto_selector_sheet.dart';
import 'markets_screen.dart';
import 'portfolio_screen.dart';
import 'activity_screen.dart';
import 'crypto_detail_screen.dart';
import 'profile_screen.dart';
import 'convert_crypto_screen.dart';
import 'favorites_screen.dart';
import '../../../models/crypto/crypto_models.dart';

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
    
    // Iniciar auto-refresh global e carregar favoritos
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CryptoController>().startAutoUpdate();
      _loadFavorites();
    });
  }
  
  /// Carrega favoritos do usuário
  Future<void> _loadFavorites() async {
    final authController = context.read<AuthController>();
    final favoritesController = context.read<FavoritesController>();
    final userId = authController.currentUser?.id;
    
    if (userId != null) {
      await favoritesController.loadFavorites(userId);
    }
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
    final cryptoController = context.read<CryptoController>();
    
    // Recarregar apenas top 10 criptos para o Dashboard
    await cryptoController.loadHomeCryptos(resetTimer: false);
    
    final userId = authController.currentUser?.id;
    if (userId != null) {
      await walletController.loadWallet(userId);
      await portfolioController.loadPortfolio(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            decoration: BoxDecoration(
              color: colors.surfaceElevated,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: colors.darkGray.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: SafeArea(
              child: Container(
                height: 68,
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
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
                    // Espaço para o botão flutuante
                    const SizedBox(width: 56),
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
          // Botão flutuante central sobrepondo
          Positioned(
            top: -28,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _showActionsBottomSheet(context);
                },
                customBorder: const CircleBorder(),
                splashColor: colors.white.withOpacity(0.3),
                highlightColor: colors.white.withOpacity(0.1),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colors.primary, colors.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colors.primary.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
        ],
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
          HapticFeedback.lightImpact();
          setState(() {
            _currentIndex = index;
          });
        },
        splashColor: colors.primary.withOpacity(0.1),
        highlightColor: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ícone com animação de cor
              PhosphorIcon(
                isActive ? activeIcon : icon,
                size: 24,
                color: isActive ? colors.primary : colors.mediumGray,
              ),
              
              const SizedBox(height: 2),
              
              // Label com animação de cor e overflow protegido
              Flexible(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive ? colors.primary : colors.mediumGray,
                    letterSpacing: -0.3,
                    height: 1.0,
                  ),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              
              // Indicador de aba ativa
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.only(top: 4),
                height: 3,
                width: isActive ? 20 : 0,
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Mostra bottom sheet com opções de ações
  void _showActionsBottomSheet(BuildContext context) {
    final colors = context.colors;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: colors.surfaceElevated,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: colors.darkGray.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Indicador de arrasto melhorado
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: colors.mediumGray.withOpacity(0.3),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 24),
            
            // Título com ícone
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: PhosphorIcon(
                    PhosphorIcons.lightning(PhosphorIconsStyle.fill),
                    size: 24,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ações Rápidas',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: colors.onBackground,
                      ),
                    ),
                    Text(
                      'Escolha uma ação para continuar',
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.mediumGray,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            
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

  /// Constrói uma opção de ação no bottom sheet - Melhorado
  Widget _buildActionOption({
    required BuildContext context,
    required PhosphorIconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool enabled,
    VoidCallback? onTap,
  }) {
    final colors = context.colors;
    
    return GestureDetector(
      onTap: enabled ? () {
        HapticFeedback.lightImpact();
        onTap?.call();
      } : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: enabled ? colors.white : colors.lightGray.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: enabled 
              ? color.withOpacity(0.2) 
              : colors.mediumGray.withOpacity(0.1),
            width: 1.5,
          ),
          boxShadow: enabled ? [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ] : null,
        ),
        child: Row(
          children: [
            // Ícone melhorado
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: enabled ? LinearGradient(
                  colors: [
                    color.withOpacity(0.15),
                    color.withOpacity(0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ) : null,
                color: enabled ? null : colors.mediumGray.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: PhosphorIcon(
                  icon,
                  size: 28,
                  color: enabled ? color : colors.mediumGray,
                ),
              ),
            ),
            const SizedBox(width: 20),
            
            // Texto melhorado
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: enabled ? colors.onBackground : colors.mediumGray,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: colors.mediumGray,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            
            // Indicador visual
            if (!enabled)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colors.mediumGray.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
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
    // O seletor usa automaticamente:
    // - Para COMPRA: Lista completa de mercados (100 moedas)
    // - Para VENDA: Lista da home (10 moedas) filtrada pelo que o usuário possui
    
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
  // Seleção múltipla
  bool _isSelectionMode = false;
  final Set<String> _selectedSymbols = {};

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
    
    // Carregar apenas top 10 criptos para o Dashboard
    await cryptoController.loadHomeCryptos();
    
    // Carregar carteira e portfólio
    final userId = authController.currentUser?.id;
    if (userId != null) {
      await walletController.loadWallet(userId);
      await portfolioController.loadPortfolio(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final cryptoController = context.watch<CryptoController>();
    final walletController = context.watch<WalletController>();
    final portfolioController = context.watch<PortfolioController>();
    final priceFormatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: _isSelectionMode
            ? IconButton(
                icon: PhosphorIcon(
                  PhosphorIcons.x(),
                  size: 24,
                  color: colors.onBackground,
                ),
                onPressed: _exitSelectionMode,
              )
            : null,
        title: _isSelectionMode
            ? Text(
                '${_selectedSymbols.length} selecionadas',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colors.onBackground,
                ),
              )
            : Row(
                children: [
                  // Avatar do usuário
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [colors.primary, colors.secondary],
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
                          color: colors.white,
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
                      color: colors.onBackground,
                    ),
                  ),
                ],
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
          else if (!_isSelectionMode) ...[
            // Botão de notificações
            IconButton(
              icon: PhosphorIcon(
                PhosphorIcons.bell(),
                size: 24,
                color: colors.onBackground,
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
                color: colors.onBackground,
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
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await cryptoController.refreshPrices();
          },
          color: colors.primary,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Card de Saldo Total - Gradiente Azul → Roxo
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colors.primary, colors.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: colors.primary.withValues(alpha: 0.3),
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
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.trending_up,
                                  size: 14,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '+0.00%',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
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
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
                              colors.primary.withValues(alpha: 0.1),
                              colors.primary.withValues(alpha: 0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: colors.primary.withValues(alpha: 0.3),
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
                                    color: colors.primary.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: PhosphorIcon(
                                    PhosphorIcons.briefcase(PhosphorIconsStyle.fill),
                                    size: 20,
                                    color: colors.primaryDark,
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
                                color: colors.onBackground,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Card de Favoritos
                _buildFavoritesCard(context, colors),
                
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
                        color: colors.onBackground,
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
                                valueColor: AlwaysStoppedAnimation<Color>(colors.primaryDark),
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
                if (cryptoController.error != null)
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
                            onPressed: () => cryptoController.loadHomeCryptos(),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Tentar Novamente'),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (cryptoController.homeCryptos.isNotEmpty)
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cryptoController.homeCryptos.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final crypto = cryptoController.homeCryptos[index];
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
                      ).animate()
                        .fadeIn(
                          duration: 300.ms,
                          delay: (index * 50).ms,
                        )
                        .slideY(
                          begin: 0.1,
                          duration: 300.ms,
                          delay: (index * 50).ms,
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
    if (!controller.hasAssets) return colors.onBackground;
    final roundedPL = controller.totalProfitLoss.abs() < 0.01 ? 0.0 : controller.totalProfitLoss;
    return roundedPL >= 0 ? colors.success : colors.error;
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
          backgroundColor: context.colors.error,
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
            backgroundColor: context.colors.success,
          ),
        );
      }

      _exitSelectionMode();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Erro ao adicionar favoritos'),
            backgroundColor: context.colors.error,
          ),
        );
      }
    }
  }
  
  /// Card de acesso rápido aos favoritos
  Widget _buildFavoritesCard(BuildContext context, AppColors colors) {
    final favoritesController = context.watch<FavoritesController>();
    final favoritesCount = favoritesController.favoriteSymbols.length;
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const FavoritesScreen(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colors.primary.withOpacity(0.1),
              colors.primary.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colors.primary.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: PhosphorIcon(
                PhosphorIcons.star(PhosphorIconsStyle.fill),
                size: 24,
                color: colors.primaryDark,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Meus Favoritos',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colors.onBackground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    favoritesCount > 0
                        ? '$favoritesCount ${favoritesCount == 1 ? "criptomoeda" : "criptomoedas"}'
                        : 'Nenhuma cripto favoritada',
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.mediumGray,
                    ),
                  ),
                ],
              ),
            ),
            PhosphorIcon(
              PhosphorIcons.caretRight(),
              size: 20,
              color: colors.mediumGray,
            ),
          ],
        ),
      ),
    ).animate()
      .fadeIn(duration: 300.ms)
      .slideX(begin: -0.1, duration: 300.ms, curve: Curves.easeOut);
  }
}

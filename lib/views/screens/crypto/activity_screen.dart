import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/crypto/crypto_controllers.dart';
import '../../../models/crypto/crypto_models.dart';
import '../../../repositories/crypto/crypto_repositories.dart';
import '../../../utils/constants.dart';
import 'home_screen.dart';

/// Tela de Atividade (Histórico de Transações)
/// 
/// Exibe:
/// - Lista de todas as transações do usuário
/// - Filtros por tipo (Todas, Compras, Vendas)
/// - Filtros por período (Hoje, Semana, Mês, Tudo)
/// - Estado vazio quando não há transações
class ActivityScreen extends StatefulWidget {
  final VoidCallback? onTabSelected;
  
  const ActivityScreen({super.key, this.onTabSelected});

  @override
  State<ActivityScreen> createState() => ActivityScreenState();
}

// Tornando o State público para poder acessar de fora
class ActivityScreenState extends State<ActivityScreen> with AutomaticKeepAliveClientMixin {


  TransactionType? _selectedType;
  String _selectedPeriod = 'Tudo';
  List<Transaction> _filteredTransactions = [];
  bool _isLoading = false;
  
  @override
  bool get wantKeepAlive => true; // Mantém o estado ao trocar de aba
  
  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recarrega quando a tela fica visível novamente
    if (ModalRoute.of(context)?.isCurrent == true) {
      _loadTransactions();
    }
  }
  
  /// Método público para recarregar transações (chamado pela HomeScreen)
  void reloadTransactions() {
    _loadTransactions();
  }
  
  Future<void> _loadTransactions() async {
    if (_isLoading) return; // Evita múltiplas chamadas simultâneas
    
    setState(() {
      _isLoading = true;
    });
    
    final authController = context.read<AuthController>();
    
    if (authController.currentUser != null) {
      final walletRepository = Provider.of<WalletRepository>(context, listen: false);
      final transactions = await walletRepository.getTransactions(
        authController.currentUser!.id,
      );
      
      if (mounted) {
        setState(() {
          _filteredTransactions = _filterTransactions(transactions);
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  List<Transaction> _filterTransactions(List<Transaction> transactions) {
    var filtered = transactions;
    
    // Filtrar por tipo
    if (_selectedType != null) {
      filtered = filtered.where((t) => t.type == _selectedType).toList();
    }
    
    // Filtrar por período
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'Hoje':
        filtered = filtered.where((t) {
          return t.timestamp.year == now.year &&
                 t.timestamp.month == now.month &&
                 t.timestamp.day == now.day;
        }).toList();
        break;
      case 'Semana':
        final weekAgo = now.subtract(const Duration(days: 7));
        filtered = filtered.where((t) => t.timestamp.isAfter(weekAgo)).toList();
        break;
      case 'Mês':
        final monthAgo = now.subtract(const Duration(days: 30));
        filtered = filtered.where((t) => t.timestamp.isAfter(monthAgo)).toList();
        break;
      case 'Tudo':
        // Não filtra
        break;
    }
    
    return filtered;
  }
  
  Future<void> _refreshTransactions() async {
    await _loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Necessário para AutomaticKeepAliveClientMixin
    
    final colors = AppConstants.colors;
    final cryptoController = context.watch<CryptoController>();

    return Scaffold(
      backgroundColor: colors.white,
      appBar: AppBar(
        title: Text(
          'Atividade',
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
          // Botão de filtro
          IconButton(
            icon: PhosphorIcon(
              PhosphorIcons.funnelSimple(),
              color: colors.darkGray,
              size: 24,
            ),
            onPressed: () => _showFiltersBottomSheet(context, colors),
          ),
        ],
      ),
      body: _filteredTransactions.isEmpty
          ? _buildEmptyState(colors)
          : RefreshIndicator(
              onRefresh: _refreshTransactions,
              color: colors.yellow,
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _filteredTransactions.length,
                itemBuilder: (context, index) {
                  final transaction = _filteredTransactions[index];
                  final crypto = cryptoController.getCryptoById(transaction.cryptoId);
                  
                  return _TransactionListItem(
                    transaction: transaction,
                    crypto: crypto,
                  ).animate().fadeIn(
                    duration: 300.ms,
                    delay: (index * 30).ms,
                  ).slideX(
                    begin: 0.1,
                    duration: 300.ms,
                    delay: (index * 30).ms,
                  );
                },
              ),
            ),
    );
  }
  
  void _showFiltersBottomSheet(BuildContext context, AppColors colors) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: BoxDecoration(
            color: colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.mediumGray.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Título
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filtros',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colors.darkGray,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setModalState(() {
                        _selectedType = null;
                        _selectedPeriod = 'Tudo';
                      });
                      setState(() {
                        _selectedType = null;
                        _selectedPeriod = 'Tudo';
                      });
                      _loadTransactions();
                    },
                    child: Text(
                      'Limpar',
                      style: TextStyle(
                        color: colors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Tipo de Transação
              Text(
                'Tipo de Transação',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colors.mediumGray,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildTypeChipModal(colors, null, 'Todas', setModalState),
                  _buildTypeChipModal(colors, TransactionType.buy, 'Compras', setModalState),
                  _buildTypeChipModal(colors, TransactionType.sell, 'Vendas', setModalState),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Período
              Text(
                'Período',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colors.mediumGray,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildPeriodChipModal(colors, 'Hoje', setModalState),
                  _buildPeriodChipModal(colors, 'Semana', setModalState),
                  _buildPeriodChipModal(colors, 'Mês', setModalState),
                  _buildPeriodChipModal(colors, 'Tudo', setModalState),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Botão Aplicar
              ElevatedButton(
                onPressed: () {
                  _loadTransactions();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.yellow,
                  foregroundColor: colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Aplicar Filtros',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildTypeChipModal(AppColors colors, TransactionType? type, String label, StateSetter setModalState) {
    final isSelected = _selectedType == type;
    
    return GestureDetector(
      onTap: () {
        setModalState(() {
          _selectedType = type;
        });
        setState(() {
          _selectedType = type;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? colors.yellow : colors.lightGray,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected ? [
            BoxShadow(
              color: colors.yellow.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? colors.white : colors.mediumGray,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
  
  Widget _buildPeriodChipModal(AppColors colors, String period, StateSetter setModalState) {
    final isSelected = _selectedPeriod == period;
    
    return GestureDetector(
      onTap: () {
        setModalState(() {
          _selectedPeriod = period;
        });
        setState(() {
          _selectedPeriod = period;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? colors.yellow : colors.lightGray,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected ? [
            BoxShadow(
              color: colors.yellow.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : [],
        ),
        child: Text(
          period,
          style: TextStyle(
            color: isSelected ? colors.white : colors.mediumGray,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
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
              PhosphorIcons.clockCounterClockwise(PhosphorIconsStyle.fill),
              size: 80,
              color: colors.mediumGray.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Nenhuma transação',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colors.darkGray,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedType != null || _selectedPeriod != 'Tudo'
                  ? 'Nenhuma transação encontrada\ncom os filtros selecionados.'
                  : 'Você ainda não fez nenhuma transação.\nComece comprando sua primeira cripto!',
              style: TextStyle(
                fontSize: 14,
                color: colors.mediumGray,
              ),
              textAlign: TextAlign.center,
            ),
            if (_selectedType == null && _selectedPeriod == 'Tudo') ...[
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // Navegar para Mercados
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
          ],
        ),
      ),
    );
  }
}

/// Item de Transação na Lista
class _TransactionListItem extends StatelessWidget {
  final Transaction transaction;
  final Crypto? crypto;

  const _TransactionListItem({
    required this.transaction,
    required this.crypto,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppConstants.colors;
    final dateFormatter = DateFormat('dd/MM/yyyy HH:mm', 'pt_BR');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.white,
        border: Border.all(color: colors.lightGray),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Ícone de tipo
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getTypeColor(colors),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: PhosphorIcon(
                  _getTypeIcon(),
                  color: colors.white,
                  size: 24,
                ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        transaction.type == TransactionType.buy ? 'Compra' : 'Venda',
                        style: TextStyle(
                          color: colors.darkGray,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (crypto != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: colors.lightGray,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            crypto!.symbol,
                            style: TextStyle(
                              color: colors.mediumGray,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${transaction.quantity.toStringAsFixed(8)} ${crypto?.symbol ?? transaction.cryptoId}',
                    style: TextStyle(
                      color: colors.mediumGray,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateFormatter.format(transaction.timestamp),
                    style: TextStyle(
                      color: colors.mediumGray,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            
            // Valor
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${transaction.type == TransactionType.buy ? '-' : '+'}R\$ ${transaction.total.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: transaction.type == TransactionType.buy ? colors.error : colors.success,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'R\$ ${transaction.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: colors.mediumGray,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getTypeColor(AppColors colors) {
    return transaction.type == TransactionType.buy ? colors.success : colors.error;
  }
  
  PhosphorIconData _getTypeIcon() {
    return transaction.type == TransactionType.buy
        ? PhosphorIcons.arrowDown(PhosphorIconsStyle.bold)
        : PhosphorIcons.arrowUp(PhosphorIconsStyle.bold);
  }
}

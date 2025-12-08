import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../controllers/controllers.dart';
import '../../../controllers/crypto/crypto_controllers.dart';
import '../../../models/crypto/crypto_models.dart';
import '../../../utils/constants.dart';
import '../../widgets/crypto/crypto_icon.dart';

/// Tela de Transação (Compra/Venda)
/// 
/// Permite ao usuário comprar ou vender criptomoedas.
/// Segue UI Guidelines: cores, espaçamentos, animações.
class TransactionScreen extends StatefulWidget {
  final Crypto crypto;
  final TransactionType initialType;

  const TransactionScreen({
    super.key,
    required this.crypto,
    this.initialType = TransactionType.buy,
  });

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  
  late TransactionType _selectedType;
  double? _availableQuantity;
  double _calculatedQuantity = 0;
  double _calculatedTotal = 0;
  
  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
    _loadAvailableQuantity();
    
    _amountController.addListener(_onAmountChanged);
  }
  
  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
  
  Future<void> _loadAvailableQuantity() async {
    if (_selectedType == TransactionType.sell) {
      final authController = context.read<AuthController>();
      final transactionController = context.read<TransactionController>();
      
      if (authController.currentUser != null) {
        final quantity = await transactionController.getAvailableQuantity(
          authController.currentUser!.id,
          widget.crypto.id,
        );
        setState(() {
          _availableQuantity = quantity;
        });
      }
    }
  }
  
  void _onAmountChanged() {
    if (_amountController.text.isEmpty) {
      setState(() {
        _calculatedQuantity = 0;
        _calculatedTotal = 0;
      });
      return;
    }
    
    final amount = double.tryParse(_amountController.text);
    if (amount != null && amount > 0) {
      setState(() {
        _calculatedTotal = amount;
        _calculatedQuantity = amount / widget.crypto.currentPrice;
      });
    }
  }
  
  void _switchType(TransactionType type) {
    setState(() {
      _selectedType = type;
      _amountController.clear();
      _calculatedQuantity = 0;
      _calculatedTotal = 0;
    });
    _loadAvailableQuantity();
  }
  
  void _setMaxAmount() {
    final walletController = context.read<WalletController>();
    
    if (_selectedType == TransactionType.buy) {
      // Usar todo o saldo disponível
      _amountController.text = walletController.balance.toStringAsFixed(2);
    } else {
      // Vender tudo que possui - usa a quantidade exata disponível
      if (_availableQuantity != null && _availableQuantity! > 0) {
        // Calcula o total exato sem arredondamentos
        final total = _availableQuantity! * widget.crypto.currentPrice;
        _amountController.text = total.toStringAsFixed(2);
      }
    }
  }
  
  Future<void> _showConfirmation() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_calculatedQuantity <= 0 || _calculatedTotal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Insira um valor válido'),
          backgroundColor: AppConstants.colors.error,
        ),
      );
      return;
    }
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _ConfirmationDialog(
        crypto: widget.crypto,
        type: _selectedType,
        quantity: _calculatedQuantity,
        total: _calculatedTotal,
      ),
    );
    
    if (confirmed == true && mounted) {
      await _processTransaction();
    }
  }
  
  Future<void> _processTransaction() async {
    final authController = context.read<AuthController>();
    final transactionController = context.read<TransactionController>();
    final walletController = context.read<WalletController>();
    
    if (authController.currentUser == null) return;
    
    final userId = authController.currentUser!.id;
    
    // Mostrar loading
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _LoadingDialog(),
      );
    }
    
    bool success = false;
    
    if (_selectedType == TransactionType.buy) {
      success = await transactionController.buyTransaction(
        userId: userId,
        cryptoId: widget.crypto.id,
        quantity: _calculatedQuantity,
        price: widget.crypto.currentPrice,
      );
    } else {
      // Para venda, se estiver vendendo tudo (diferença < 0.00000001), usa quantidade exata
      double quantityToSell = _calculatedQuantity;
      if (_availableQuantity != null) {
        final difference = (_calculatedQuantity - _availableQuantity!).abs();
        if (difference < 0.00000001) {
          // Está vendendo tudo, usa quantidade exata para evitar resíduos
          quantityToSell = _availableQuantity!;
          debugPrint('TransactionScreen: Selling ALL - using exact quantity: $quantityToSell');
        }
      }
      
      success = await transactionController.sellTransaction(
        userId: userId,
        cryptoId: widget.crypto.id,
        quantity: quantityToSell,
        price: widget.crypto.currentPrice,
      );
    }
    
    // Fechar loading
    if (mounted) Navigator.pop(context);
    
    if (success) {
      // Atualizar carteira e portfólio
      await walletController.loadWallet(userId);
      
      // Atualizar portfólio se estiver disponível
      try {
        final portfolioController = context.read<PortfolioController>();
        await portfolioController.loadPortfolio(userId);
      } catch (e) {
        // Portfolio controller pode não estar disponível
      }
      
      // Mostrar sucesso e voltar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                PhosphorIcon(
                  PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  _selectedType == TransactionType.buy
                      ? 'Compra realizada com sucesso!'
                      : 'Venda realizada com sucesso!',
                ),
              ],
            ),
            backgroundColor: AppConstants.colors.success,
            duration: const Duration(seconds: 3),
          ),
        );
        Navigator.pop(context, true);
      }
    } else {
      // Mostrar erro
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                PhosphorIcon(
                  PhosphorIcons.xCircle(PhosphorIconsStyle.fill),
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    transactionController.error ?? 'Erro ao processar transação',
                  ),
                ),
              ],
            ),
            backgroundColor: AppConstants.colors.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppConstants.colors;
    final walletController = context.watch<WalletController>();
    
    return Scaffold(
      backgroundColor: colors.white,
      appBar: AppBar(
        backgroundColor: colors.white,
        elevation: 0,
        leading: IconButton(
          icon: PhosphorIcon(
            PhosphorIcons.caretLeft(PhosphorIconsStyle.bold),
            color: colors.darkGray,
            size: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _selectedType == TransactionType.buy ? 'Comprar' : 'Vender',
          style: TextStyle(
            color: colors.darkGray,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Crypto Info Card
              _buildCryptoInfoCard(colors),
              
              const SizedBox(height: 24),
              
              // Type Selector (Comprar/Vender)
              _buildTypeSelector(colors),
              
              const SizedBox(height: 24),
              
              // Available Balance/Quantity
              _buildAvailableInfo(colors, walletController),
              
              const SizedBox(height: 24),
              
              // Amount Input
              _buildAmountInput(colors),
              
              const SizedBox(height: 24),
              
              // Summary Card
              _buildSummaryCard(colors),
              
              const SizedBox(height: 32),
              
              // Action Button
              _buildActionButton(colors),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildCryptoInfoCard(AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.primary.withValues(alpha: 0.1),
            colors.primary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // Ícone
          CryptoIcon(
            symbol: widget.crypto.symbol,
            imageUrl: widget.crypto.imageUrl,
            size: 48,
          ),
          
          const SizedBox(width: 12),
          
          // Nome e Símbolo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.crypto.name,
                  style: TextStyle(
                    color: colors.darkGray,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  widget.crypto.symbol,
                  style: TextStyle(
                    color: colors.mediumGray,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // Preço
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'R\$ ${widget.crypto.currentPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  color: colors.darkGray,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${widget.crypto.priceChange24h >= 0 ? '+' : ''}${widget.crypto.priceChange24h.toStringAsFixed(2)}%',
                style: TextStyle(
                  color: widget.crypto.priceChange24h >= 0 ? colors.success : colors.error,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildTypeSelector(AppColors colors) {
    return Row(
      children: [
        Expanded(
          child: _buildTypeButton(
            colors,
            TransactionType.buy,
            'Comprar',
            PhosphorIcons.arrowDown(PhosphorIconsStyle.bold),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTypeButton(
            colors,
            TransactionType.sell,
            'Vender',
            PhosphorIcons.arrowUp(PhosphorIconsStyle.bold),
          ),
        ),
      ],
    );
  }
  
  Widget _buildTypeButton(
    AppColors colors,
    TransactionType type,
    String label,
    PhosphorIconData icon,
  ) {
    final isSelected = _selectedType == type;
    
    return GestureDetector(
      onTap: () => _switchType(type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary : colors.white,
          border: Border.all(
            color: isSelected ? colors.primary : colors.lightGray,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PhosphorIcon(
              icon,
              color: isSelected ? colors.white : colors.mediumGray,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? colors.white : colors.mediumGray,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAvailableInfo(AppColors colors, WalletController walletController) {
    if (_selectedType == TransactionType.buy) {
      return Container(
        padding: const EdgeInsets.all(12),
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
        child: Row(
          children: [
            PhosphorIcon(
              PhosphorIcons.wallet(PhosphorIconsStyle.fill),
              color: colors.mediumGray,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Saldo disponível: ',
              style: TextStyle(
                color: colors.mediumGray,
                fontSize: 14,
              ),
            ),
            Text(
              'R\$ ${walletController.balance.toStringAsFixed(2)}',
              style: TextStyle(
                color: colors.darkGray,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(12),
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
        child: Row(
          children: [
            PhosphorIcon(
              PhosphorIcons.coins(PhosphorIconsStyle.fill),
              color: colors.mediumGray,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Disponível: ',
              style: TextStyle(
                color: colors.mediumGray,
                fontSize: 14,
              ),
            ),
            Text(
              _availableQuantity != null
                  ? '${_availableQuantity!.toStringAsFixed(8)} ${widget.crypto.symbol}'
                  : 'Carregando...',
              style: TextStyle(
                color: colors.darkGray,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }
  }
  
  Widget _buildAmountInput(AppColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Quanto deseja ${_selectedType == TransactionType.buy ? 'investir' : 'vender'}?',
              style: TextStyle(
                color: colors.darkGray,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: _setMaxAmount,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'TUDO',
                style: TextStyle(
                  color: colors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          style: TextStyle(
            color: colors.darkGray,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            prefix: Text(
              'R\$ ',
              style: TextStyle(
                color: colors.darkGray,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            hintText: '0,00',
            hintStyle: TextStyle(
              color: colors.mediumGray.withValues(alpha: 0.5),
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
            filled: true,
            fillColor: colors.lightGray,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: colors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.all(20),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Insira um valor';
            }
            final amount = double.tryParse(value);
            if (amount == null || amount <= 0) {
              return 'Valor inválido';
            }
            
            final walletController = context.read<WalletController>();
            if (_selectedType == TransactionType.buy) {
              if (amount > walletController.balance) {
                return 'Saldo insuficiente';
              }
            } else {
              // Para venda, validar pela quantidade de cripto, não pelo valor em reais
              if (_availableQuantity != null && _calculatedQuantity > 0) {
                // Permite margem de erro maior (0.01%) para arredondamentos de conversão R$ -> quantidade
                // Isso evita erros quando o usuário clica em "TUDO"
                final difference = _calculatedQuantity - _availableQuantity!;
                final percentDifference = (difference / _availableQuantity!) * 100;
                
                // Se a diferença for maior que 0.01% (erro de arredondamento aceitável)
                if (difference > 0 && percentDifference > 0.01) {
                  return 'Quantidade insuficiente (${_availableQuantity!.toStringAsFixed(8)} ${widget.crypto.symbol} disponível)';
                }
              }
            }
            return null;
          },
        ),
      ],
    );
  }
  
  Widget _buildSummaryCard(AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.darkGray,
            colors.darkGray.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.darkGray.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Você vai ${_selectedType == TransactionType.buy ? 'receber' : 'vender'}',
                style: TextStyle(
                  color: colors.white.withValues(alpha: 0.9),
                  fontSize: 14,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: (_selectedType == TransactionType.buy ? colors.success : colors.error)
                      .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _selectedType == TransactionType.buy ? colors.success : colors.error,
                    width: 1,
                  ),
                ),
                child: Text(
                  _selectedType == TransactionType.buy ? 'COMPRA' : 'VENDA',
                  style: TextStyle(
                    color: _selectedType == TransactionType.buy ? colors.success : colors.error,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${_calculatedQuantity.toStringAsFixed(8)} ${widget.crypto.symbol}',
            style: TextStyle(
              color: colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Preço unitário',
                style: TextStyle(
                  color: colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                ),
              ),
              Text(
                'R\$ ${widget.crypto.currentPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  color: colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Taxa',
                style: TextStyle(
                  color: colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                ),
              ),
              Text(
                'R\$ 0,00',
                style: TextStyle(
                  color: colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButton(AppColors colors) {
    return ElevatedButton(
      onPressed: _showConfirmation,
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.primary,
        foregroundColor: colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PhosphorIcon(
            _selectedType == TransactionType.buy
                ? PhosphorIcons.shoppingCart(PhosphorIconsStyle.bold)
                : PhosphorIcons.arrowCircleUp(PhosphorIconsStyle.bold),
            color: colors.white,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            _selectedType == TransactionType.buy ? 'Confirmar Compra' : 'Confirmar Venda',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Dialog de Loading melhorado
class _LoadingDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = AppConstants.colors;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
              strokeWidth: 3,
            ),
            const SizedBox(height: 24),
            Text(
              'Processando transação...',
              style: TextStyle(
                color: colors.darkGray,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Aguarde um momento',
              style: TextStyle(
                color: colors.mediumGray,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Dialog de Confirmação
class _ConfirmationDialog extends StatelessWidget {
  final Crypto crypto;
  final TransactionType type;
  final double quantity;
  final double total;

  const _ConfirmationDialog({
    required this.crypto,
    required this.type,
    required this.quantity,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppConstants.colors;
    
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Row(
        children: [
          PhosphorIcon(
            PhosphorIcons.warningCircle(PhosphorIconsStyle.fill),
            color: colors.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Confirmar ${type == TransactionType.buy ? 'Compra' : 'Venda'}',
              style: TextStyle(
                color: colors.darkGray,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Você está prestes a ${type == TransactionType.buy ? 'comprar' : 'vender'}:',
            style: TextStyle(
              color: colors.mediumGray,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(colors, 'Criptomoeda', '${crypto.name} (${crypto.symbol})'),
          const SizedBox(height: 8),
          _buildInfoRow(colors, 'Quantidade', quantity.toStringAsFixed(8)),
          const SizedBox(height: 8),
          _buildInfoRow(colors, 'Preço unitário', 'R\$ ${crypto.currentPrice.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _buildInfoRow(colors, 'Total', 'R\$ ${total.toStringAsFixed(2)}', isTotal: true),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            'Cancelar',
            style: TextStyle(
              color: colors.mediumGray,
              fontSize: 16,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: type == TransactionType.buy ? colors.success : colors.error,
            foregroundColor: colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Text(
            'Confirmar',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildInfoRow(AppColors colors, String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colors.mediumGray,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: colors.darkGray,
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../utils/constants.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/crypto/crypto_controllers.dart';
import '../../../models/crypto/crypto.dart';
import '../../widgets/widgets.dart';

/// Tela de Conversão de Criptomoedas
/// 
/// Permite converter uma criptomoeda em outra
/// Calcula taxas e mostra preview da conversão
class ConvertCryptoScreen extends StatefulWidget {
  const ConvertCryptoScreen({super.key});

  @override
  State<ConvertCryptoScreen> createState() => _ConvertCryptoScreenState();
}

class _ConvertCryptoScreenState extends State<ConvertCryptoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  
  Crypto? _fromCrypto;
  Crypto? _toCrypto;
  double _convertedAmount = 0.0;
  double _conversionRate = 0.0;
  bool _isCalculating = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppConstants.colors;
    final cryptoController = context.watch<CryptoController>();

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
          'Converter Criptomoedas',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colors.darkGray,
          ),
        ),
      ),
      body: LoadingOverlay(
        isLoading: cryptoController.isLoading,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Card de conversão
                  _buildConversionCard(colors, cryptoController),
                  
                  const SizedBox(height: 24),
                  
                  // Informações da conversão
                  if (_fromCrypto != null && _toCrypto != null && _convertedAmount > 0)
                    _buildConversionInfo(colors),
                  
                  const SizedBox(height: 32),
                  
                  // Botão converter
                  _buildConvertButton(colors),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Card principal de conversão
  Widget _buildConversionCard(AppColors colors, CryptoController cryptoController) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.primary.withValues(alpha: 0.08),
            colors.primary.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.mediumGray.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // De (From)
          Text(
            'De',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colors.mediumGray,
            ),
          ),
          const SizedBox(height: 12),
          _buildCryptoSelector(
            colors: colors,
            cryptoController: cryptoController,
            selectedCrypto: _fromCrypto,
            onSelect: (crypto) {
              setState(() {
                _fromCrypto = crypto;
                _calculateConversion();
              });
            },
            hint: 'Selecione a criptomoeda',
          ),
          
          const SizedBox(height: 16),
          
          // Label do campo com botão Máx
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quantidade a converter',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: colors.mediumGray,
                ),
              ),
              if (_fromCrypto != null)
                GestureDetector(
                  onTap: _setMaxAmount,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: colors.primary.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'Máx',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colors.primaryDark,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Campo de valor com padding
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colors.mediumGray.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,8}')),
              ],
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colors.darkGray,
              ),
              decoration: InputDecoration(
                hintText: _fromCrypto != null 
                    ? '0.00 ${_fromCrypto!.symbol.toUpperCase()}'
                    : '0.00',
                hintStyle: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colors.mediumGray.withValues(alpha: 0.3),
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
                filled: false,
              ),
              onChanged: (value) => _calculateConversion(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Digite a quantidade';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Quantidade inválida';
                }
                return null;
              },
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Botão de inverter
          Center(
            child: GestureDetector(
              onTap: _swapCryptos,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: PhosphorIcon(
                    PhosphorIcons.arrowsDownUp(PhosphorIconsStyle.bold),
                    size: 24,
                    color: colors.white,
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Para (To)
          Text(
            'Para',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colors.mediumGray,
            ),
          ),
          const SizedBox(height: 12),
          _buildCryptoSelector(
            colors: colors,
            cryptoController: cryptoController,
            selectedCrypto: _toCrypto,
            onSelect: (crypto) {
              setState(() {
                _toCrypto = crypto;
                _calculateConversion();
              });
            },
            hint: 'Selecione a criptomoeda',
          ),
          
          const SizedBox(height: 16),
          
          // Label do valor convertido
          Text(
            'Você receberá',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: colors.mediumGray,
            ),
          ),
          const SizedBox(height: 8),
          
          // Valor convertido
          if (_isCalculating)
            const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            Text(
              _convertedAmount > 0 
                  ? '${_convertedAmount.toStringAsFixed(8)} ${_toCrypto?.symbol.toUpperCase() ?? ''}'
                  : '0.00',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _convertedAmount > 0 ? colors.darkGray : colors.mediumGray.withValues(alpha: 0.3),
              ),
            ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.1, duration: 300.ms);
  }

  /// Seletor de criptomoeda
  Widget _buildCryptoSelector({
    required AppColors colors,
    required CryptoController cryptoController,
    required Crypto? selectedCrypto,
    required Function(Crypto) onSelect,
    required String hint,
  }) {
    return InkWell(
      onTap: () => _showCryptoSelector(
        context: context,
        cryptoController: cryptoController,
        onSelect: onSelect,
        excludeCrypto: selectedCrypto == _fromCrypto ? _toCrypto : _fromCrypto,
      ),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colors.mediumGray.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            if (selectedCrypto != null) ...[
              // Ícone da cripto
              ClipOval(
                child: selectedCrypto.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: selectedCrypto.imageUrl!,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 40,
                          height: 40,
                          color: colors.lightGray,
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(colors.mediumGray),
                              ),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _getCryptoColor(selectedCrypto.symbol),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              selectedCrypto.symbol[0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _getCryptoColor(selectedCrypto.symbol),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            selectedCrypto.symbol[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedCrypto.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colors.darkGray,
                      ),
                    ),
                    Text(
                      selectedCrypto.symbol.toUpperCase(),
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.mediumGray,
                      ),
                    ),
                  ],
                ),
              ),
            ] else
              Expanded(
                child: Text(
                  hint,
                  style: TextStyle(
                    fontSize: 16,
                    color: colors.mediumGray,
                  ),
                ),
              ),
            PhosphorIcon(
              PhosphorIcons.caretDown(PhosphorIconsStyle.bold),
              size: 20,
              color: colors.mediumGray,
            ),
          ],
        ),
      ),
    );
  }

  /// Informações da conversão
  Widget _buildConversionInfo(AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.info.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            colors: colors,
            label: 'Taxa de conversão',
            value: '1 ${_fromCrypto!.symbol.toUpperCase()} = ${_conversionRate.toStringAsFixed(8)} ${_toCrypto!.symbol.toUpperCase()}',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            colors: colors,
            label: 'Taxa de serviço',
            value: '0.5%',
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: 100.ms)
        .slideY(begin: 0.1, duration: 300.ms);
  }

  Widget _buildInfoRow({
    required AppColors colors,
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: colors.darkGray.withValues(alpha: 0.7),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colors.darkGray,
          ),
        ),
      ],
    );
  }

  /// Botão de converter
  Widget _buildConvertButton(AppColors colors) {
    final isValid = _fromCrypto != null && 
                    _toCrypto != null && 
                    _amountController.text.isNotEmpty &&
                    _convertedAmount > 0;

    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: isValid ? _handleConvert : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          disabledBackgroundColor: colors.mediumGray.withValues(alpha: 0.3),
          foregroundColor: colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          'Converter',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colors.white,
          ),
        ),
      ),
    );
  }

  /// Mostra seletor de criptomoedas
  void _showCryptoSelector({
    required BuildContext context,
    required CryptoController cryptoController,
    required Function(Crypto) onSelect,
    Crypto? excludeCrypto,
  }) {
    final colors = AppConstants.colors;
    final portfolioController = context.read<PortfolioController>();
    
    // Filtrar apenas criptos que o usuário possui
    final availableCryptos = cryptoController.cryptos.where((crypto) {
      // Verificar se tem no portfólio
      final hasAsset = portfolioController.assets.any(
        (asset) => asset.cryptoId == crypto.id && asset.quantity > 0,
      );
      return hasAsset;
    }).toList();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.lightGray,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Suas Criptomoedas',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colors.darkGray,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Selecione uma cripto do seu portfólio',
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.mediumGray,
                    ),
                  ),
                ],
              ),
            ),
            
            // Lista de criptos
            Expanded(
              child: availableCryptos.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          PhosphorIcon(
                            PhosphorIcons.wallet(PhosphorIconsStyle.fill),
                            size: 64,
                            color: colors.mediumGray.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Você não possui criptomoedas',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: colors.mediumGray,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Compre criptomoedas para começar',
                            style: TextStyle(
                              fontSize: 14,
                              color: colors.mediumGray,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: availableCryptos.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final crypto = availableCryptos[index];
                        
                        // Não mostrar a cripto já selecionada no outro campo
                        if (excludeCrypto != null && crypto.id == excludeCrypto.id) {
                          return const SizedBox.shrink();
                        }
                        
                        // Buscar quantidade no portfólio
                        final asset = portfolioController.assets.firstWhere(
                          (a) => a.cryptoId == crypto.id,
                        );
                        
                        return InkWell(
                          onTap: () {
                            onSelect(crypto);
                            Navigator.pop(context);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  colors.primary.withValues(alpha: 0.06),
                                  colors.primary.withValues(alpha: 0.03),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: colors.primary.withValues(alpha: 0.15),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                ClipOval(
                                  child: crypto.imageUrl != null
                                      ? CachedNetworkImage(
                                          imageUrl: crypto.imageUrl!,
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => Container(
                                            width: 40,
                                            height: 40,
                                            color: colors.lightGray,
                                            child: Center(
                                              child: SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(colors.mediumGray),
                                                ),
                                              ),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) => Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: _getCryptoColor(crypto.symbol),
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
                                          ),
                                        )
                                      : Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: _getCryptoColor(crypto.symbol),
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
                                        ),
                                ),
                                const SizedBox(width: 12),
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
                                        'Você tem: ${asset.quantity.toStringAsFixed(8)} ${crypto.symbol.toUpperCase()}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: colors.mediumGray,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// Calcula a conversão
  void _calculateConversion() {
    if (_fromCrypto == null || _toCrypto == null || _amountController.text.isEmpty) {
      setState(() {
        _convertedAmount = 0.0;
        _conversionRate = 0.0;
      });
      return;
    }

    setState(() => _isCalculating = true);

    // Simula delay de cálculo
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      final amount = double.tryParse(_amountController.text) ?? 0.0;
      
      // Calcula o valor em BRL da cripto de origem
      final valueInBRL = amount * _fromCrypto!.currentPrice;
      
      // Calcula quantas unidades da cripto de destino pode comprar
      final converted = valueInBRL / _toCrypto!.currentPrice;
      
      // Aplica taxa de 0.5%
      final fee = converted * 0.005;
      _convertedAmount = converted - fee;
      
      // Calcula taxa de conversão para exibição
      _conversionRate = _fromCrypto!.currentPrice / _toCrypto!.currentPrice;

      setState(() => _isCalculating = false);
    });
  }

  /// Define quantidade máxima disponível
  void _setMaxAmount() {
    if (_fromCrypto == null) return;
    
    final portfolioController = context.read<PortfolioController>();
    final asset = portfolioController.assets.firstWhere(
      (a) => a.cryptoId == _fromCrypto!.id,
      orElse: () => throw Exception('Asset not found'),
    );
    
    setState(() {
      _amountController.text = asset.quantity.toStringAsFixed(8);
      _calculateConversion();
    });
  }

  /// Inverte as criptomoedas
  void _swapCryptos() {
    setState(() {
      final temp = _fromCrypto;
      _fromCrypto = _toCrypto;
      _toCrypto = temp;
      _calculateConversion();
    });
  }

  /// Processa a conversão
  Future<void> _handleConvert() async {
    if (!_formKey.currentState!.validate()) return;

    final colors = AppConstants.colors;
    final authController = context.read<AuthController>();
    final transactionController = context.read<TransactionController>();
    final portfolioController = context.read<PortfolioController>();
    
    final userId = authController.currentUser?.id;
    if (userId == null) return;
    
    // Mostra confirmação
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Conversão'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Você está convertendo:'),
            const SizedBox(height: 12),
            Text(
              '${_amountController.text} ${_fromCrypto!.symbol.toUpperCase()}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text('Para:'),
            const SizedBox(height: 8),
            Text(
              '${_convertedAmount.toStringAsFixed(8)} ${_toCrypto!.symbol.toUpperCase()}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Taxa de serviço: 0.5%',
              style: TextStyle(
                fontSize: 13,
                color: colors.mediumGray,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.white,
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    // Processar conversão
    final amount = double.parse(_amountController.text);
    
    final success = await transactionController.convertTransaction(
      userId: userId,
      fromCryptoId: _fromCrypto!.id,
      toCryptoId: _toCrypto!.id,
      fromQuantity: amount,
      fromPrice: _fromCrypto!.currentPrice,
      toPrice: _toCrypto!.currentPrice,
      feePercent: 0.5,
    );

    if (!mounted) return;

    if (success) {
      // Recarregar portfólio
      await portfolioController.loadPortfolio(userId);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Conversão realizada com sucesso!'),
          backgroundColor: colors.success,
        ),
      );
      Navigator.pop(context);
    } else {
      // Mostrar erro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(transactionController.error ?? 'Erro ao processar conversão'),
          backgroundColor: colors.error,
        ),
      );
    }
  }

  /// Retorna cor baseada no símbolo da cripto
  Color _getCryptoColor(String symbol) {
    switch (symbol.toLowerCase()) {
      case 'btc':
        return const Color(0xFFFF9800);
      case 'eth':
        return const Color(0xFF9C27B0);
      case 'ada':
        return const Color(0xFF2196F3);
      case 'sol':
        return const Color(0xFFE91E63);
      default:
        return AppConstants.colors.mediumGray;
    }
  }
}

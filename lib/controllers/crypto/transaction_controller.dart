import 'package:flutter/foundation.dart';
import '../../models/crypto/crypto_models.dart';
import '../../repositories/crypto/crypto_repositories.dart';

/// Controller para gerenciar transações de criptomoedas
/// 
/// Responsável por:
/// - Processar compras e vendas
/// - Validar saldo e quantidade
/// - Atualizar carteira e portfólio
/// - Registrar transações no Firestore
/// 
/// Segue SOLID: Depende de repositories (abstrações), não de implementações.
class TransactionController extends ChangeNotifier {
  final WalletRepository _walletRepository;
  
  // Estado
  bool _isProcessing = false;
  String? _error;
  Transaction? _lastTransaction;

  TransactionController(this._walletRepository);

  // Getters
  bool get isProcessing => _isProcessing;
  String? get error => _error;
  Transaction? get lastTransaction => _lastTransaction;

  /// Processa uma compra de criptomoeda
  /// 
  /// Valida saldo, atualiza carteira, atualiza portfólio e registra transação.
  Future<bool> buyTransaction({
    required String userId,
    required String cryptoId,
    required double quantity,
    required double price,
  }) async {
    _isProcessing = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('TransactionController: Processing BUY - $quantity $cryptoId @ R\$ $price');
      
      final total = quantity * price;
      
      // 1. Validar saldo
      final wallet = await _walletRepository.getWallet(userId);
      if (!wallet.hasSufficientBalance(total)) {
        throw Exception('Saldo insuficiente. Você tem R\$ ${wallet.balance.toStringAsFixed(2)}, mas precisa de R\$ ${total.toStringAsFixed(2)}');
      }
      
      // 2. Criar transação
      final transaction = Transaction.buy(
        userId: userId,
        cryptoId: cryptoId,
        quantity: quantity,
        price: price,
      );
      
      // 3. Atualizar carteira (subtrair saldo)
      final newBalance = wallet.balance - total;
      final updatedWallet = wallet.copyWith(balance: newBalance);
      await _walletRepository.updateWallet(userId, updatedWallet);
      
      // 4. Atualizar portfólio (adicionar ou atualizar ativo)
      await _updatePortfolioAfterBuy(userId, cryptoId, quantity, price);
      
      // 5. Registrar transação
      await _walletRepository.addTransaction(userId, transaction);
      
      _lastTransaction = transaction;
      _error = null;
      
      debugPrint('TransactionController: BUY completed successfully');
      _isProcessing = false;
      notifyListeners();
      
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('TransactionController: Error processing BUY: $e');
      _isProcessing = false;
      notifyListeners();
      return false;
    }
  }

  /// Processa uma venda de criptomoeda
  /// 
  /// Valida quantidade, atualiza carteira, atualiza portfólio e registra transação.
  Future<bool> sellTransaction({
    required String userId,
    required String cryptoId,
    required double quantity,
    required double price,
  }) async {
    _isProcessing = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('TransactionController: Processing SELL - $quantity $cryptoId @ R\$ $price');
      
      final total = quantity * price;
      
      // 1. Validar quantidade no portfólio
      final assets = await _walletRepository.getPortfolioAssets(userId);
      final asset = assets.firstWhere(
        (a) => a.cryptoId == cryptoId,
        orElse: () => throw Exception('Você não possui $cryptoId no seu portfólio'),
      );
      
      // Permite margem de erro de 0.01% para arredondamentos
      final difference = quantity - asset.quantity;
      final percentDifference = (difference / asset.quantity) * 100;
      
      if (difference > 0 && percentDifference > 0.01) {
        throw Exception('Quantidade insuficiente. Você tem ${asset.quantity.toStringAsFixed(8)} $cryptoId, mas está tentando vender ${quantity.toStringAsFixed(8)}');
      }
      
      // Se estiver vendendo tudo (diferença < 0.01%), ajusta para quantidade exata
      if (difference > 0 && percentDifference <= 0.01) {
        debugPrint('TransactionController: Adjusting quantity from $quantity to ${asset.quantity} (selling all)');
        quantity = asset.quantity;
      }
      
      // 2. Criar transação
      final transaction = Transaction.sell(
        userId: userId,
        cryptoId: cryptoId,
        quantity: quantity,
        price: price,
      );
      
      // 3. Atualizar carteira (adicionar saldo)
      final wallet = await _walletRepository.getWallet(userId);
      final newBalance = wallet.balance + total;
      final updatedWallet = wallet.copyWith(balance: newBalance);
      await _walletRepository.updateWallet(userId, updatedWallet);
      
      // 4. Atualizar portfólio (remover ou atualizar ativo)
      await _updatePortfolioAfterSell(userId, asset, quantity);
      
      // 5. Registrar transação
      await _walletRepository.addTransaction(userId, transaction);
      
      _lastTransaction = transaction;
      _error = null;
      
      debugPrint('TransactionController: SELL completed successfully');
      _isProcessing = false;
      notifyListeners();
      
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('TransactionController: Error processing SELL: $e');
      _isProcessing = false;
      notifyListeners();
      return false;
    }
  }

  /// Atualiza portfólio após compra
  Future<void> _updatePortfolioAfterBuy(
    String userId,
    String cryptoId,
    double quantity,
    double price,
  ) async {
    final assets = await _walletRepository.getPortfolioAssets(userId);
    
    // Verifica se já possui esse ativo
    final existingAssetIndex = assets.indexWhere((a) => a.cryptoId == cryptoId);
    
    if (existingAssetIndex >= 0) {
      // Atualiza ativo existente
      final existingAsset = assets[existingAssetIndex];
      final updatedAsset = existingAsset.addPurchase(
        quantity: quantity,
        price: price,
      );
      await _walletRepository.updatePortfolioAsset(userId, updatedAsset);
    } else {
      // Cria novo ativo
      final newAsset = PortfolioAsset(
        cryptoId: cryptoId,
        quantity: quantity,
        avgPrice: price,
        totalInvested: quantity * price,
        updatedAt: DateTime.now(),
      );
      await _walletRepository.updatePortfolioAsset(userId, newAsset);
    }
  }

  /// Atualiza portfólio após venda
  Future<void> _updatePortfolioAfterSell(
    String userId,
    PortfolioAsset asset,
    double quantity,
  ) async {
    final updatedAsset = asset.removeSale(quantity: quantity);
    
    debugPrint('TransactionController: After sale - Asset ${asset.cryptoId} quantity: ${updatedAsset.quantity}');
    
    // Se vendeu tudo (quantidade <= 0.00000001), remover do portfólio
    if (updatedAsset.quantity <= 0.00000001) {
      debugPrint('TransactionController: ✅ REMOVING asset ${asset.cryptoId} from portfolio (quantity: ${updatedAsset.quantity})');
      await _walletRepository.removePortfolioAsset(userId, asset.cryptoId);
      debugPrint('TransactionController: ✅ Asset ${asset.cryptoId} REMOVED from Firestore');
    } else {
      debugPrint('TransactionController: Updating asset ${asset.cryptoId} with new quantity: ${updatedAsset.quantity}');
      await _walletRepository.updatePortfolioAsset(userId, updatedAsset);
    }
  }

  /// Calcula o total de uma transação
  double calculateTotal(double quantity, double price) {
    return quantity * price;
  }

  /// Valida se pode comprar
  Future<bool> canBuy({
    required String userId,
    required double total,
  }) async {
    try {
      final wallet = await _walletRepository.getWallet(userId);
      return wallet.hasSufficientBalance(total);
    } catch (e) {
      debugPrint('TransactionController: Error checking balance: $e');
      return false;
    }
  }

  /// Valida se pode vender
  Future<bool> canSell({
    required String userId,
    required String cryptoId,
    required double quantity,
  }) async {
    try {
      final assets = await _walletRepository.getPortfolioAssets(userId);
      final asset = assets.firstWhere(
        (a) => a.cryptoId == cryptoId,
        orElse: () => throw Exception('Asset not found'),
      );
      return asset.quantity >= quantity;
    } catch (e) {
      debugPrint('TransactionController: Error checking quantity: $e');
      return false;
    }
  }

  /// Busca quantidade disponível de um ativo
  Future<double> getAvailableQuantity(String userId, String cryptoId) async {
    try {
      final assets = await _walletRepository.getPortfolioAssets(userId);
      final asset = assets.firstWhere(
        (a) => a.cryptoId == cryptoId,
        orElse: () => throw Exception('Asset not found'),
      );
      return asset.quantity;
    } catch (e) {
      debugPrint('TransactionController: Error getting quantity: $e');
      return 0.0;
    }
  }

  /// Processa uma conversão entre criptomoedas
  /// 
  /// Valida quantidade, converte entre criptos, aplica taxa e registra transação.
  Future<bool> convertTransaction({
    required String userId,
    required String fromCryptoId,
    required String toCryptoId,
    required double fromQuantity,
    required double fromPrice,
    required double toPrice,
    double feePercent = 0.5, // Taxa padrão de 0.5%
  }) async {
    _isProcessing = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('TransactionController: Processing CONVERT - $fromQuantity $fromCryptoId to $toCryptoId');
      
      // 1. Validar quantidade no portfólio
      final assets = await _walletRepository.getPortfolioAssets(userId);
      final fromAsset = assets.firstWhere(
        (a) => a.cryptoId == fromCryptoId,
        orElse: () => throw Exception('Você não possui $fromCryptoId no seu portfólio'),
      );
      
      // Permite margem de erro de 0.01% para arredondamentos
      final difference = fromQuantity - fromAsset.quantity;
      final percentDifference = (difference / fromAsset.quantity) * 100;
      
      if (difference > 0 && percentDifference > 0.01) {
        throw Exception('Quantidade insuficiente. Você tem ${fromAsset.quantity.toStringAsFixed(8)} $fromCryptoId');
      }
      
      // Se estiver convertendo tudo, ajusta para quantidade exata
      if (difference > 0 && percentDifference <= 0.01) {
        debugPrint('TransactionController: Adjusting quantity from $fromQuantity to ${fromAsset.quantity} (converting all)');
        fromQuantity = fromAsset.quantity;
      }
      
      // 2. Calcular conversão
      final conversionRate = toPrice / fromPrice;
      final convertedAmount = fromQuantity * conversionRate;
      final fee = convertedAmount * (feePercent / 100);
      final finalToQuantity = convertedAmount - fee;
      
      debugPrint('TransactionController: Conversion rate: $conversionRate');
      debugPrint('TransactionController: Converted amount: $convertedAmount');
      debugPrint('TransactionController: Fee ($feePercent%): $fee');
      debugPrint('TransactionController: Final amount: $finalToQuantity');
      
      // 3. Criar transação de conversão
      final transaction = Transaction.convert(
        userId: userId,
        fromCryptoId: fromCryptoId,
        toCryptoId: toCryptoId,
        fromQuantity: fromQuantity,
        toQuantity: finalToQuantity,
        fromPrice: fromPrice,
        toPrice: toPrice,
      );
      
      // 4. Atualizar portfólio - Remover cripto de origem
      await _updatePortfolioAfterSell(userId, fromAsset, fromQuantity);
      
      // 5. Atualizar portfólio - Adicionar cripto de destino
      // Usar preço médio ponderado para a conversão
      final avgPriceForDestination = toPrice;
      await _updatePortfolioAfterBuy(userId, toCryptoId, finalToQuantity, avgPriceForDestination);
      
      // 6. Registrar transação
      await _walletRepository.addTransaction(userId, transaction);
      
      _lastTransaction = transaction;
      _error = null;
      
      debugPrint('TransactionController: CONVERT completed successfully');
      _isProcessing = false;
      notifyListeners();
      
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('TransactionController: Error processing CONVERT: $e');
      _isProcessing = false;
      notifyListeners();
      return false;
    }
  }

  /// Limpa erro
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Reseta estado
  void reset() {
    _isProcessing = false;
    _error = null;
    _lastTransaction = null;
    notifyListeners();
  }
}

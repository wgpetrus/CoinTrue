import 'package:flutter/foundation.dart';
import '../../models/crypto/crypto_models.dart';
import '../../repositories/crypto/crypto_repositories.dart';

/// Controller para gerenciar portfólio de criptomoedas
/// 
/// Responsável por:
/// - Carregar ativos do portfólio
/// - Calcular valor total do portfólio
/// - Calcular lucro/prejuízo
/// - Atualizar preços dos ativos
/// 
/// Segue SOLID: Depende de repositories (abstrações).
class PortfolioController extends ChangeNotifier {
  final WalletRepository _walletRepository;
  final CryptoRepository _cryptoRepository;
  
  // Estado
  List<PortfolioAsset> _assets = [];
  Map<String, Crypto> _cryptoPrices = {}; // Cache de preços
  bool _isLoading = false;
  String? _error;

  PortfolioController(
    this._walletRepository,
    this._cryptoRepository,
  );

  // Getters
  List<PortfolioAsset> get assets => _assets;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasAssets => _assets.isNotEmpty;
  
  /// Valor total do portfólio
  double get totalValue {
    double total = 0;
    for (final asset in _assets) {
      final crypto = _cryptoPrices[asset.cryptoId];
      if (crypto != null) {
        total += asset.calculateCurrentValue(crypto.currentPrice);
      }
    }
    return total;
  }
  
  /// Lucro/Prejuízo total
  double get totalProfitLoss {
    double total = 0;
    for (final asset in _assets) {
      final crypto = _cryptoPrices[asset.cryptoId];
      if (crypto != null) {
        total += asset.calculateProfitLoss(crypto.currentPrice);
      }
    }
    return total;
  }
  
  /// Percentual de lucro/prejuízo total
  double get totalProfitLossPercent {
    final totalInvested = _assets.fold<double>(
      0,
      (sum, asset) => sum + asset.totalInvested,
    );
    
    if (totalInvested == 0) return 0;
    return (totalProfitLoss / totalInvested) * 100;
  }
  
  /// Total investido
  double get totalInvested {
    return _assets.fold<double>(
      0,
      (sum, asset) => sum + asset.totalInvested,
    );
  }
  
  /// Quantidade de ativos diferentes
  int get assetsCount => _assets.length;

  /// Carrega portfólio do usuário
  Future<void> loadPortfolio(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('PortfolioController: Loading portfolio for user $userId');
      
      // 1. Carregar ativos do portfólio e filtrar os com quantidade > 0
      final allAssets = await _walletRepository.getPortfolioAssets(userId);
      debugPrint('PortfolioController: Loaded ${allAssets.length} assets from Firestore');
      
      // Log de cada ativo
      for (final asset in allAssets) {
        debugPrint('  - ${asset.cryptoId}: quantity=${asset.quantity}');
      }
      
      _assets = allAssets.where((asset) => asset.quantity > 0.00000001).toList();
      debugPrint('PortfolioController: After filter: ${_assets.length} assets with quantity > 0');
      
      // 2. Carregar preços atuais das criptos
      await _loadCryptoPrices();
      
      debugPrint('PortfolioController: ✅ Portfolio loaded successfully');
      _error = null;
    } catch (e) {
      _error = 'Erro ao carregar portfólio: $e';
      debugPrint('PortfolioController: Error loading portfolio: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Carrega preços atuais das criptos do portfólio
  Future<void> _loadCryptoPrices() async {
    try {
      // Buscar todas as criptos
      final allCryptos = await _cryptoRepository.getCryptos(limit: 100);
      
      // Criar mapa de preços para os ativos do portfólio
      _cryptoPrices.clear();
      for (final asset in _assets) {
        final crypto = allCryptos.firstWhere(
          (c) => c.id == asset.cryptoId,
          orElse: () => throw Exception('Crypto ${asset.cryptoId} not found'),
        );
        _cryptoPrices[asset.cryptoId] = crypto;
      }
      
      debugPrint('PortfolioController: Loaded prices for ${_cryptoPrices.length} cryptos');
    } catch (e) {
      debugPrint('PortfolioController: Error loading crypto prices: $e');
      rethrow;
    }
  }

  /// Atualiza preços das criptos
  Future<void> refreshPrices() async {
    if (_assets.isEmpty) return;
    
    try {
      debugPrint('PortfolioController: Refreshing prices...');
      await _loadCryptoPrices();
      notifyListeners();
      debugPrint('PortfolioController: Prices refreshed');
    } catch (e) {
      debugPrint('PortfolioController: Error refreshing prices: $e');
      // Não propaga erro, mantém preços antigos
    }
  }

  /// Busca um ativo específico
  PortfolioAsset? getAsset(String cryptoId) {
    try {
      return _assets.firstWhere((a) => a.cryptoId == cryptoId);
    } catch (e) {
      return null;
    }
  }

  /// Busca preço atual de uma cripto
  Crypto? getCrypto(String cryptoId) {
    return _cryptoPrices[cryptoId];
  }

  /// Calcula valor atual de um ativo
  double getAssetCurrentValue(PortfolioAsset asset) {
    final crypto = _cryptoPrices[asset.cryptoId];
    if (crypto == null) return 0;
    return asset.calculateCurrentValue(crypto.currentPrice);
  }

  /// Calcula lucro/prejuízo de um ativo
  double getAssetProfitLoss(PortfolioAsset asset) {
    final crypto = _cryptoPrices[asset.cryptoId];
    if (crypto == null) return 0;
    return asset.calculateProfitLoss(crypto.currentPrice);
  }

  /// Calcula percentual de lucro/prejuízo de um ativo
  double getAssetProfitLossPercent(PortfolioAsset asset) {
    final crypto = _cryptoPrices[asset.cryptoId];
    if (crypto == null) return 0;
    return asset.calculateProfitLossPercent(crypto.currentPrice);
  }

  /// Calcula distribuição do portfólio (para gráfico)
  List<PortfolioDistribution> getDistribution() {
    if (_assets.isEmpty || totalValue == 0) return [];
    
    return _assets.map((asset) {
      final value = getAssetCurrentValue(asset);
      final percentage = (value / totalValue) * 100;
      
      return PortfolioDistribution(
        cryptoId: asset.cryptoId,
        value: value,
        percentage: percentage,
      );
    }).toList()
      ..sort((a, b) => b.value.compareTo(a.value)); // Ordena por valor
  }

  /// Busca melhor ativo (maior ganho percentual)
  PortfolioAsset? getBestAsset() {
    if (_assets.isEmpty) return null;
    
    PortfolioAsset? best;
    double bestPercent = double.negativeInfinity;
    
    for (final asset in _assets) {
      final percent = getAssetProfitLossPercent(asset);
      if (percent > bestPercent) {
        bestPercent = percent;
        best = asset;
      }
    }
    
    return best;
  }

  /// Busca pior ativo (maior perda percentual)
  PortfolioAsset? getWorstAsset() {
    if (_assets.isEmpty) return null;
    
    PortfolioAsset? worst;
    double worstPercent = double.infinity;
    
    for (final asset in _assets) {
      final percent = getAssetProfitLossPercent(asset);
      if (percent < worstPercent) {
        worstPercent = percent;
        worst = asset;
      }
    }
    
    return worst;
  }

  /// Ordena ativos
  void sortAssets(PortfolioSortType sortType) {
    switch (sortType) {
      case PortfolioSortType.value:
        _assets.sort((a, b) {
          final valueA = getAssetCurrentValue(a);
          final valueB = getAssetCurrentValue(b);
          return valueB.compareTo(valueA); // Decrescente
        });
        break;
      case PortfolioSortType.profitLoss:
        _assets.sort((a, b) {
          final plA = getAssetProfitLossPercent(a);
          final plB = getAssetProfitLossPercent(b);
          return plB.compareTo(plA); // Decrescente
        });
        break;
      case PortfolioSortType.name:
        _assets.sort((a, b) {
          final cryptoA = _cryptoPrices[a.cryptoId];
          final cryptoB = _cryptoPrices[b.cryptoId];
          if (cryptoA == null || cryptoB == null) return 0;
          return cryptoA.name.compareTo(cryptoB.name); // Alfabética
        });
        break;
    }
    notifyListeners();
  }

  /// Limpa erro
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Reseta estado
  void reset() {
    _assets = [];
    _cryptoPrices = {};
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}

/// Tipo de ordenação do portfólio
enum PortfolioSortType {
  value,      // Por valor
  profitLoss, // Por lucro/prejuízo
  name,       // Por nome
}

/// Distribuição do portfólio (para gráfico)
class PortfolioDistribution {
  final String cryptoId;
  final double value;
  final double percentage;

  PortfolioDistribution({
    required this.cryptoId,
    required this.value,
    required this.percentage,
  });
}

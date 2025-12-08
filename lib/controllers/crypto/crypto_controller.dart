import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../models/crypto/crypto_models.dart';
import '../../repositories/crypto/crypto_repositories.dart';

/// Controller para gerenciar criptomoedas
/// 
/// Responsável por:
/// - Carregar lista de criptomoedas via Repository
/// - Atualizar preços automaticamente
/// - Gerenciar estado de loading e erros
/// - Cache de dados separados para Home e Mercados
/// 
/// Segue SOLID: Depende de CryptoRepository (interface), não de implementação.
class CryptoController extends ChangeNotifier {
  final CryptoRepository _repository;
  
  // Estado - Listas separadas para Home e Mercados
  List<Crypto> _homeCryptos = [];      // Top 10 para Home
  List<Crypto> _marketsCryptos = [];   // Top 100 para Mercados
  bool _isLoading = false;
  String? _error;
  DateTime? _lastUpdate;
  
  // Timer para atualização automática
  Timer? _updateTimer;
  
  // Configurações (CoinGecko - balanceado para evitar rate limit)
  static const Duration updateInterval = Duration(seconds: 30); // 30 segundos

  CryptoController(this._repository);

  // Getters
  List<Crypto> get cryptos => _homeCryptos;        // Padrão retorna lista da Home
  List<Crypto> get homeCryptos => _homeCryptos;    // Top 10 para Home
  List<Crypto> get marketsCryptos => _marketsCryptos; // Top 100 para Mercados
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastUpdate => _lastUpdate;
  
  /// Carrega lista de criptomoedas para Home (Top 10)
  Future<void> loadHomeCryptos({bool resetTimer = true}) async {
    final needsReload = _homeCryptos.isEmpty || resetTimer || _error != null;
    
    if (!needsReload) {
      debugPrint('CryptoController: Using cached HOME data (${_homeCryptos.length} cryptos)');
      return;
    }
    
    debugPrint('CryptoController: Loading HOME cryptos (top 10)...');
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _homeCryptos = await _repository.getCryptos(limit: 10);
      
      if (resetTimer) {
        _lastUpdate = DateTime.now();
        debugPrint('CryptoController: HOME timer reset');
      }
      
      _error = null;
      debugPrint('CryptoController: Successfully loaded ${_homeCryptos.length} HOME cryptos');
    } catch (e) {
      _error = 'Erro ao carregar criptomoedas: $e';
      debugPrint('CryptoController: Error loading HOME cryptos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Carrega lista de criptomoedas para Mercados (Top 100)
  Future<void> loadMarketsCryptos({bool resetTimer = true}) async {
    final needsReload = _marketsCryptos.isEmpty || resetTimer || _error != null;
    
    if (!needsReload) {
      debugPrint('CryptoController: Using cached MARKETS data (${_marketsCryptos.length} cryptos)');
      return;
    }
    
    debugPrint('CryptoController: Loading MARKETS cryptos (top 100)...');
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _marketsCryptos = await _repository.getCryptos(limit: 100);
      
      if (resetTimer) {
        _lastUpdate = DateTime.now();
        debugPrint('CryptoController: MARKETS timer reset');
      }
      
      _error = null;
      debugPrint('CryptoController: Successfully loaded ${_marketsCryptos.length} MARKETS cryptos');
    } catch (e) {
      _error = 'Erro ao carregar criptomoedas: $e';
      debugPrint('CryptoController: Error loading MARKETS cryptos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Carrega lista de criptomoedas (método legado - mantido para compatibilidade)
  Future<void> loadCryptos({int limit = 10, bool resetTimer = true}) async {
    if (limit <= 10) {
      await loadHomeCryptos(resetTimer: resetTimer);
    } else {
      await loadMarketsCryptos(resetTimer: resetTimer);
    }
  }

  /// Atualiza preços das criptomoedas (FORÇA atualização, ignora cache)
  Future<void> refreshPrices() async {
    try {
      debugPrint('CryptoController: Refreshing prices (MANUAL)...');
      
      // Limpa cache para forçar nova requisição
      _repository.clearCache();
      
      // Recarrega ambas as listas
      await Future.wait([
        loadHomeCryptos(resetTimer: true),
        loadMarketsCryptos(resetTimer: true),
      ]);
      
      debugPrint('CryptoController: Prices refreshed (MANUAL)');
    } catch (e) {
      _error = 'Erro ao atualizar preços: $e';
      debugPrint('CryptoController: Error refreshing prices: $e');
      notifyListeners();
    }
  }

  /// Inicia atualização automática de preços
  void startAutoUpdate() {
    stopAutoUpdate(); // Para timer anterior se existir
    
    debugPrint('CryptoController: Starting auto-update (every ${updateInterval.inSeconds}s)');
    
    // Timer para atualizar dados
    _updateTimer = Timer.periodic(updateInterval, (_) {
      refreshPrices();
    });
  }

  /// Para atualização automática
  void stopAutoUpdate() {
    _updateTimer?.cancel();
    _updateTimer = null;
    debugPrint('CryptoController: Auto-update stopped');
  }

  /// Busca uma cripto específica por ID
  Crypto? getCryptoById(String id) {
    try {
      // Busca primeiro na lista de mercados (mais completa)
      return _marketsCryptos.firstWhere((c) => c.id == id);
    } catch (e) {
      try {
        // Se não encontrar, busca na lista da home
        return _homeCryptos.firstWhere((c) => c.id == id);
      } catch (e) {
        return null;
      }
    }
  }

  /// Busca criptomoedas por nome ou símbolo (busca na API)
  Future<List<Crypto>> searchCryptos(String query) async {
    if (query.isEmpty) return [];
    
    try {
      debugPrint('CryptoController: Searching for "$query" in API...');
      
      // Busca na API através do repository
      final results = await _repository.searchCryptos(query);
      
      debugPrint('CryptoController: Found ${results.length} results');
      return results;
    } catch (e) {
      debugPrint('CryptoController: Error searching: $e');
      
      // Fallback: busca local nas listas carregadas
      final lowerQuery = query.toLowerCase();
      
      // Combina ambas as listas e remove duplicatas
      final allCryptos = <String, Crypto>{};
      for (final crypto in _marketsCryptos) {
        allCryptos[crypto.id] = crypto;
      }
      for (final crypto in _homeCryptos) {
        allCryptos[crypto.id] = crypto;
      }
      
      final localResults = allCryptos.values.where((crypto) {
        return crypto.name.toLowerCase().contains(lowerQuery) ||
            crypto.symbol.toLowerCase().contains(lowerQuery);
      }).toList();
      
      debugPrint('CryptoController: Using local search, found ${localResults.length} results');
      return localResults;
    }
  }

  /// Limpa erro
  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    stopAutoUpdate();
    super.dispose();
  }
}

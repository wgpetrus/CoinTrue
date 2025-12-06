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
/// - Cache de dados
/// 
/// Segue SOLID: Depende de CryptoRepository (interface), não de implementação.
class CryptoController extends ChangeNotifier {
  final CryptoRepository _repository;
  
  // Estado
  List<Crypto> _cryptos = [];
  bool _isLoading = false;
  String? _error;
  DateTime? _lastUpdate;
  
  // Timer para atualização automática
  Timer? _updateTimer;
  
  // Configurações (CoinGecko - balanceado para evitar rate limit)
  static const Duration updateInterval = Duration(seconds: 30); // 30 segundos

  CryptoController(this._repository);

  // Getters
  List<Crypto> get cryptos => _cryptos;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastUpdate => _lastUpdate;
  
  /// Carrega lista de criptomoedas
  Future<void> loadCryptos({int limit = 100, bool resetTimer = true}) async {
    // Se já tem dados suficientes E não é um refresh explícito, usa cache
    // MAS: se o limite solicitado é MAIOR que o atual, sempre recarrega
    if (_cryptos.isNotEmpty && 
        _cryptos.length >= limit && 
        !resetTimer && 
        _error == null) {
      debugPrint('CryptoController: Using cached data (${_cryptos.length} cryptos)');
      return;
    }
    
    // Se tem menos moedas que o solicitado, sempre carrega mais
    if (_cryptos.isNotEmpty && _cryptos.length < limit) {
      debugPrint('CryptoController: Need more cryptos (have ${_cryptos.length}, need $limit)');
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('CryptoController: Loading $limit cryptos...');
      _cryptos = await _repository.getCryptos(limit: limit);
      
      // Só reseta o timer se for um refresh real (não navegação entre telas)
      if (resetTimer) {
        _lastUpdate = DateTime.now();
        debugPrint('CryptoController: Timer reset');
      }
      
      _error = null;
      
      debugPrint('CryptoController: Loaded ${_cryptos.length} cryptos');
    } catch (e) {
      _error = 'Erro ao carregar criptomoedas: $e';
      debugPrint('CryptoController: Error loading cryptos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Atualiza preços das criptomoedas (FORÇA atualização, ignora cache)
  Future<void> refreshPrices() async {
    try {
      debugPrint('CryptoController: Refreshing prices (MANUAL)...');
      
      // Limpa cache para forçar nova requisição
      _repository.clearCache();
      
      // Recarrega tudo do zero
      final limit = _cryptos.length > 0 ? _cryptos.length : 100;
      await loadCryptos(limit: limit);
      
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
      return _cryptos.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
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
      
      // Fallback: busca local na lista carregada
      final lowerQuery = query.toLowerCase();
      final localResults = _cryptos.where((crypto) {
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

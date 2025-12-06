import '../../models/crypto/crypto_models.dart';
import '../../services/crypto/crypto_api_service.dart';
import '../../services/crypto/coingecko_api_service.dart';
import 'crypto_repository.dart';

/// Implementação do repositório de criptomoedas
/// 
/// Usa o CryptoApiService para buscar dados da API.
/// Pode ser facilmente substituído por outra implementação (mock, cache, etc).
class CryptoRepositoryImpl implements CryptoRepository {
  final CryptoApiService _apiService;
  
  CryptoRepositoryImpl(this._apiService);
  
  @override
  Future<List<Crypto>> getCryptos({int limit = 100}) async {
    return await _apiService.getCryptos(limit: limit);
  }
  
  @override
  Future<Crypto> getCryptoById(String id) async {
    return await _apiService.getCryptoById(id);
  }
  
  @override
  Future<List<Crypto>> searchCryptos(String query) async {
    // Se for CoinGecko, usa busca na API
    final service = _apiService;
    if (service is CoinGeckoApiService) {
      return await service.searchCryptos(query);
    }
    
    // Fallback: filtra localmente
    final allCryptos = await _apiService.getCryptos(limit: 100);
    final queryLower = query.toLowerCase();
    
    return allCryptos.where((crypto) {
      return crypto.name.toLowerCase().contains(queryLower) ||
             crypto.symbol.toLowerCase().contains(queryLower);
    }).toList();
  }
  
  @override
  Future<double> getPrice(String id) async {
    return await _apiService.getPrice(id);
  }
  
  @override
  Future<Map<String, double>> getCurrentPrices(List<String> ids) async {
    return await _apiService.getCurrentPrices(ids);
  }
  
  @override
  void clearCache() {
    // Delega para o serviço se ele tiver o método
    final service = _apiService;
    if (service is CoinGeckoApiService) {
      service.clearCache();
    }
  }
}

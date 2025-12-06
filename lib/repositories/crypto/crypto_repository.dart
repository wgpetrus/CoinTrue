import '../../models/crypto/crypto_models.dart';

/// Interface do repositório de criptomoedas
/// 
/// Define o contrato para acesso a dados de criptomoedas.
/// Segue o princípio DIP (Dependency Inversion Principle) do SOLID.
abstract class CryptoRepository {
  /// Busca lista de criptomoedas
  Future<List<Crypto>> getCryptos({int limit = 100});
  
  /// Busca uma criptomoeda específica por ID
  Future<Crypto> getCryptoById(String id);
  
  /// Busca criptomoedas por nome ou símbolo
  Future<List<Crypto>> searchCryptos(String query);
  
  /// Busca preço atual de uma criptomoeda
  Future<double> getPrice(String id);
  
  /// Busca preços atuais de múltiplas criptomoedas
  Future<Map<String, double>> getCurrentPrices(List<String> ids);
  
  /// Limpa o cache (força nova requisição na próxima chamada)
  void clearCache();
}

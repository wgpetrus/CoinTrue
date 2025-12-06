import '../../models/crypto/crypto_models.dart';

/// Interface para serviços de API de criptomoedas
/// 
/// Define os métodos que qualquer implementação de API deve fornecer.
abstract class CryptoApiService {
  /// Obtém lista de criptomoedas
  Future<List<Crypto>> getCryptos({int limit = 50});

  /// Obtém uma criptomoeda específica por ID
  Future<Crypto> getCryptoById(String id);

  /// Obtém preços atuais de múltiplas criptomoedas
  Future<Map<String, double>> getCurrentPrices(List<String> ids);

  /// Obtém o preço atual de uma criptomoeda
  Future<double> getPrice(String id);
}

import 'package:flutter_test/flutter_test.dart';
import 'package:login/controllers/crypto/crypto_controllers.dart';
import 'package:login/models/crypto/crypto_models.dart';
import 'package:login/repositories/crypto/crypto_repositories.dart';

// Mock do CryptoRepository
class MockCryptoRepository implements CryptoRepository {
  final List<Crypto> _mockCryptos = [
    Crypto(
      id: 'bitcoin',
      symbol: 'BTC',
      name: 'Bitcoin',
      currentPrice: 50000.0,
      priceChange24h: 5.0,
      lastUpdated: DateTime.now(),
    ),
    Crypto(
      id: 'ethereum',
      symbol: 'ETH',
      name: 'Ethereum',
      currentPrice: 3000.0,
      priceChange24h: -2.0,
      lastUpdated: DateTime.now(),
    ),
  ];

  @override
  Future<List<Crypto>> getCryptos({int limit = 100}) async {
    return _mockCryptos.take(limit).toList();
  }

  @override
  Future<Crypto> getCryptoById(String id) async {
    return _mockCryptos.firstWhere((c) => c.id == id);
  }

  @override
  Future<double> getPrice(String id) async {
    final crypto = await getCryptoById(id);
    return crypto.currentPrice;
  }

  @override
  Future<Map<String, double>> getCurrentPrices(List<String> ids) async {
    return {
      for (var crypto in _mockCryptos.where((c) => ids.contains(c.id)))
        crypto.id: crypto.currentPrice
    };
  }

  @override
  Future<List<Crypto>> searchCryptos(String query) async {
    return _mockCryptos.where((c) =>
      c.name.toLowerCase().contains(query.toLowerCase()) ||
      c.symbol.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  @override
  void clearCache() {}
}

void main() {
  group('CryptoController', () {
    late CryptoController controller;
    late MockCryptoRepository mockRepository;

    setUp(() {
      mockRepository = MockCryptoRepository();
      controller = CryptoController(mockRepository);
    });

    tearDown(() {
      controller.dispose();
    });

    test('deve iniciar com lista vazia', () {
      expect(controller.cryptos, isEmpty);
      expect(controller.isLoading, false);
      expect(controller.error, null);
    });

    test('deve carregar criptos com sucesso', () async {
      await controller.loadCryptos();

      expect(controller.cryptos, isNotEmpty);
      expect(controller.cryptos.length, 2);
      expect(controller.isLoading, false);
      expect(controller.error, null);
    });

    test('deve respeitar o limite de criptos', () async {
      await controller.loadCryptos(limit: 1);

      expect(controller.cryptos.length, 1);
    });

    test('deve buscar cripto por ID', () async {
      await controller.loadCryptos();

      final crypto = controller.getCryptoById('bitcoin');

      expect(crypto, isNotNull);
      expect(crypto!.id, 'bitcoin');
      expect(crypto.name, 'Bitcoin');
    });

    test('deve retornar null para ID inexistente', () async {
      await controller.loadCryptos();

      final crypto = controller.getCryptoById('inexistente');

      expect(crypto, isNull);
    });

    test('deve buscar criptos por query', () async {
      final results = await controller.searchCryptos('bit');

      expect(results, isNotEmpty);
      expect(results.first.name, 'Bitcoin');
    });

    test('deve retornar lista vazia para query sem resultados', () async {
      final results = await controller.searchCryptos('xyzabc');

      expect(results, isEmpty);
    });

    test('deve limpar erro', () async {
      controller.clearError();

      expect(controller.error, null);
    });

    test('deve atualizar lastUpdate ao carregar', () async {
      expect(controller.lastUpdate, null);

      await controller.loadCryptos();

      expect(controller.lastUpdate, isNotNull);
    });
  });
}

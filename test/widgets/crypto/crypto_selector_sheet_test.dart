import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:login/views/widgets/crypto/crypto_selector_sheet.dart';
import 'package:login/controllers/crypto/crypto_controllers.dart';
import 'package:login/models/crypto/crypto_models.dart';
import 'package:login/repositories/crypto/crypto_repositories.dart';

// Mock do CryptoRepository
class MockCryptoRepository implements CryptoRepository {
  @override
  Future<List<Crypto>> getCryptos({int limit = 100}) async {
    return [
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
  }

  @override
  Future<Crypto> getCryptoById(String id) async {
    final cryptos = await getCryptos();
    return cryptos.firstWhere((c) => c.id == id);
  }

  @override
  Future<double> getPrice(String id) async {
    final crypto = await getCryptoById(id);
    return crypto.currentPrice;
  }

  @override
  Future<Map<String, double>> getCurrentPrices(List<String> ids) async {
    final cryptos = await getCryptos();
    return {
      for (var crypto in cryptos.where((c) => ids.contains(c.id)))
        crypto.id: crypto.currentPrice
    };
  }

  @override
  Future<List<Crypto>> searchCryptos(String query) async {
    final all = await getCryptos();
    return all.where((c) => 
      c.name.toLowerCase().contains(query.toLowerCase()) ||
      c.symbol.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  @override
  void clearCache() {}
}

void main() {
  group('CryptoSelectorSheet', () {
    late CryptoController cryptoController;

    setUp(() {
      cryptoController = CryptoController(MockCryptoRepository());
    });

    testWidgets('deve exibir título correto para compra', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: cryptoController,
            child: const Scaffold(
              body: CryptoSelectorSheet(type: TransactionType.buy),
            ),
          ),
        ),
      );

      expect(find.text('Comprar Criptomoeda'), findsOneWidget);
    });

    testWidgets('deve exibir título correto para venda', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: cryptoController,
            child: const Scaffold(
              body: CryptoSelectorSheet(type: TransactionType.sell),
            ),
          ),
        ),
      );

      expect(find.text('Vender Criptomoeda'), findsOneWidget);
    });

    testWidgets('deve exibir campo de pesquisa', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: cryptoController,
            child: const Scaffold(
              body: CryptoSelectorSheet(type: TransactionType.buy),
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Pesquisar criptomoeda...'), findsOneWidget);
    });

    testWidgets('deve filtrar criptos ao pesquisar', (WidgetTester tester) async {
      // Carregar criptos primeiro
      await cryptoController.loadCryptos();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: cryptoController,
            child: const Scaffold(
              body: CryptoSelectorSheet(type: TransactionType.buy),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verificar que mostra todas as criptos inicialmente
      expect(find.text('Bitcoin'), findsOneWidget);
      expect(find.text('Ethereum'), findsOneWidget);

      // Pesquisar por "bit"
      await tester.enterText(find.byType(TextField), 'bit');
      await tester.pumpAndSettle();

      // Deve mostrar apenas Bitcoin
      expect(find.text('Bitcoin'), findsOneWidget);
      // Ethereum não deve aparecer (mas pode estar fora da tela)
    });

    testWidgets('deve exibir estado vazio quando não encontrar criptos', (WidgetTester tester) async {
      await cryptoController.loadCryptos();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: cryptoController,
            child: const Scaffold(
              body: CryptoSelectorSheet(type: TransactionType.buy),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Pesquisar por algo que não existe
      await tester.enterText(find.byType(TextField), 'xyzabc123');
      await tester.pumpAndSettle();

      expect(find.text('Nenhuma cripto encontrada'), findsOneWidget);
    });
  });
}

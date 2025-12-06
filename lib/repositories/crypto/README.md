# Crypto Repositories

Camada de acesso a dados para funcionalidades de criptomoedas, seguindo o padrão Repository e princípios SOLID.

## 📋 Visão Geral

Os repositories abstraem o acesso a dados externos (APIs, Firestore) dos controllers, permitindo:
- **Testabilidade:** Fácil criar mocks para testes
- **Manutenibilidade:** Mudanças na fonte de dados não afetam controllers
- **Flexibilidade:** Trocar implementações sem alterar código cliente
- **SOLID:** Segue Dependency Inversion Principle (DIP)

---

## 🏗️ Estrutura

```
crypto/
├── crypto_repository.dart          # Interface (abstração)
├── crypto_repository_impl.dart     # Implementação (Coinbase API)
├── wallet_repository.dart          # Interface (abstração)
├── wallet_repository_impl.dart     # Implementação (Firestore)
└── crypto_repositories.dart        # Barrel file
```

---

## 📦 CryptoRepository

### Interface

```dart
abstract class CryptoRepository {
  /// Busca lista de criptomoedas
  Future<List<Crypto>> getCryptos({int limit = 50});
  
  /// Busca uma criptomoeda específica
  Future<Crypto> getCrypto(String id);
  
  /// Busca histórico de preços
  Future<List<PricePoint>> getPriceHistory(
    String cryptoId,
    TimeRange timeRange,
  );
}
```

### Implementação

```dart
class CryptoRepositoryImpl implements CryptoRepository {
  final CryptoApiService _apiService;
  
  CryptoRepositoryImpl(this._apiService);
  
  @override
  Future<List<Crypto>> getCryptos({int limit = 50}) async {
    return await _apiService.fetchCryptos(limit: limit);
  }
  
  // ... outras implementações
}
```

### Uso no Controller

```dart
class CryptoController extends ChangeNotifier {
  final CryptoRepository _repository; // Depende da abstração
  
  CryptoController(this._repository);
  
  Future<void> loadCryptos() async {
    _cryptos = await _repository.getCryptos();
    notifyListeners();
  }
}
```

### Configuração no Provider

```dart
MultiProvider(
  providers: [
    // Repository
    Provider<CryptoRepository>(
      create: (_) => CryptoRepositoryImpl(
        CoinbaseApiService(), // ou CoinGeckoApiService()
      ),
    ),
    
    // Controller
    ChangeNotifierProvider(
      create: (context) => CryptoController(
        context.read<CryptoRepository>(),
      ),
    ),
  ],
)
```

---

## 💰 WalletRepository

### Interface

```dart
abstract class WalletRepository {
  /// Busca a carteira do usuário
  Future<Wallet> getWallet(String userId);
  
  /// Atualiza a carteira do usuário
  Future<void> updateWallet(String userId, Wallet wallet);
  
  /// Busca transações do usuário
  Future<List<Transaction>> getTransactions(String userId);
  
  /// Adiciona uma nova transação
  Future<void> addTransaction(String userId, Transaction transaction);
  
  /// Busca ativos do portfólio
  Future<List<PortfolioAsset>> getPortfolioAssets(String userId);
  
  /// Atualiza um ativo do portfólio
  Future<void> updatePortfolioAsset(String userId, PortfolioAsset asset);
}
```

### Implementação

```dart
class WalletRepositoryImpl implements WalletRepository {
  final FirebaseFirestore _firestore;
  
  WalletRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;
  
  @override
  Future<Wallet> getWallet(String userId) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('wallet')
        .doc('data')
        .get();
    
    if (!doc.exists) {
      // Cria carteira inicial
      final newWallet = Wallet.initial();
      await updateWallet(userId, newWallet);
      return newWallet;
    }
    
    return Wallet.fromFirestore(doc);
  }
  
  // ... outras implementações
}
```

### Estrutura no Firestore

```
users/
  {userId}/
    wallet/
      data/                    # Documento único com saldo
        balance: 10000.00
        currency: "BRL"
        createdAt: Timestamp
        updatedAt: Timestamp
    
    portfolio/                 # Coleção de ativos
      {cryptoId}/
        quantity: 0.5
        avgPrice: 45000.00
        totalInvested: 22500.00
        updatedAt: Timestamp
    
    transactions/              # Coleção de transações
      {transactionId}/
        type: "buy"
        cryptoId: "bitcoin"
        quantity: 0.5
        price: 45000.00
        total: 22500.00
        fee: 0.00
        timestamp: Timestamp
```

### Uso no Controller

```dart
class WalletController extends ChangeNotifier {
  final WalletRepository _repository;
  
  WalletController(this._repository);
  
  Future<void> loadWallet(String userId) async {
    _wallet = await _repository.getWallet(userId);
    notifyListeners();
  }
  
  Future<void> updateBalance(String userId, double newBalance) async {
    final updatedWallet = _wallet!.copyWith(balance: newBalance);
    await _repository.updateWallet(userId, updatedWallet);
    _wallet = updatedWallet;
    notifyListeners();
  }
}
```

---

## 🧪 Testando com Mocks

### Criar Mock do Repository

```dart
class MockCryptoRepository extends Mock implements CryptoRepository {}

void main() {
  late CryptoController controller;
  late MockCryptoRepository mockRepository;
  
  setUp(() {
    mockRepository = MockCryptoRepository();
    controller = CryptoController(mockRepository);
  });
  
  test('loadCryptos deve carregar lista de criptos', () async {
    // Arrange
    final cryptos = [
      Crypto(id: 'bitcoin', name: 'Bitcoin', /* ... */),
    ];
    when(() => mockRepository.getCryptos())
        .thenAnswer((_) async => cryptos);
    
    // Act
    await controller.loadCryptos();
    
    // Assert
    expect(controller.cryptos, cryptos);
    verify(() => mockRepository.getCryptos()).called(1);
  });
}
```

---

## 🔄 Trocar Implementações

### Exemplo: Trocar API de Coinbase para CoinGecko

```dart
// Antes
Provider<CryptoRepository>(
  create: (_) => CryptoRepositoryImpl(
    CoinbaseApiService(),
  ),
),

// Depois
Provider<CryptoRepository>(
  create: (_) => CryptoRepositoryImpl(
    CoinGeckoApiService(), // Apenas troca o service
  ),
),

// Controllers não precisam mudar!
```

---

## 📝 Boas Práticas

### 1. Sempre dependa da interface, não da implementação

❌ **Errado:**
```dart
class CryptoController {
  final CryptoRepositoryImpl _repository; // Depende da implementação
}
```

✅ **Correto:**
```dart
class CryptoController {
  final CryptoRepository _repository; // Depende da interface
}
```

### 2. Use injeção de dependência

❌ **Errado:**
```dart
class CryptoController {
  final _repository = CryptoRepositoryImpl(CoinbaseApiService());
}
```

✅ **Correto:**
```dart
class CryptoController {
  final CryptoRepository _repository;
  
  CryptoController(this._repository); // Injetado
}
```

### 3. Mantenha repositories simples

Repositories devem apenas:
- Buscar dados
- Salvar dados
- Transformar dados (DTO → Model)

Não devem:
- Ter lógica de negócio
- Gerenciar estado
- Fazer validações complexas

### 4. Use cache quando apropriado

```dart
class CryptoRepositoryImpl implements CryptoRepository {
  List<Crypto>? _cachedCryptos;
  DateTime? _cacheTime;
  
  @override
  Future<List<Crypto>> getCryptos() async {
    // Verifica cache
    if (_cachedCryptos != null && 
        _cacheTime != null &&
        DateTime.now().difference(_cacheTime!) < Duration(minutes: 5)) {
      return _cachedCryptos!;
    }
    
    // Busca da API
    _cachedCryptos = await _apiService.fetchCryptos();
    _cacheTime = DateTime.now();
    return _cachedCryptos!;
  }
}
```

---

## 🚀 Criando Novos Repositories

### 1. Criar Interface

```dart
// lib/repositories/crypto/favorites_repository.dart
abstract class FavoritesRepository {
  Future<List<String>> getFavorites(String userId);
  Future<void> addFavorite(String userId, String cryptoId);
  Future<void> removeFavorite(String userId, String cryptoId);
}
```

### 2. Criar Implementação

```dart
// lib/repositories/crypto/favorites_repository_impl.dart
class FavoritesRepositoryImpl implements FavoritesRepository {
  final FirebaseFirestore _firestore;
  
  FavoritesRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;
  
  @override
  Future<List<String>> getFavorites(String userId) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .get();
    
    return doc.docs.map((d) => d.id).toList();
  }
  
  // ... outras implementações
}
```

### 3. Adicionar ao Barrel File

```dart
// lib/repositories/crypto/crypto_repositories.dart
export 'crypto_repository.dart';
export 'crypto_repository_impl.dart';
export 'wallet_repository.dart';
export 'wallet_repository_impl.dart';
export 'favorites_repository.dart';        // Novo
export 'favorites_repository_impl.dart';   // Novo
```

### 4. Configurar Provider

```dart
Provider<FavoritesRepository>(
  create: (_) => FavoritesRepositoryImpl(),
),
```

### 5. Usar no Controller

```dart
class FavoritesController extends ChangeNotifier {
  final FavoritesRepository _repository;
  
  FavoritesController(this._repository);
  
  Future<void> loadFavorites(String userId) async {
    _favorites = await _repository.getFavorites(userId);
    notifyListeners();
  }
}
```

---

## 📚 Referências

- [Repository Pattern](https://martinfowler.com/eaaCatalog/repository.html)
- [SOLID Principles](https://en.wikipedia.org/wiki/SOLID)
- [Dependency Inversion Principle](https://en.wikipedia.org/wiki/Dependency_inversion_principle)
- [Flutter Architecture](https://docs.flutter.dev/development/data-and-backend/state-mgmt/options)

---

**Última Atualização:** 04/12/2025

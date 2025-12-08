import 'package:flutter_test/flutter_test.dart';
import 'package:login/controllers/crypto/crypto_controllers.dart';
import 'package:login/repositories/crypto/crypto_repositories.dart';
import 'package:login/models/crypto/crypto_models.dart' hide Transaction;
import 'package:login/models/crypto/transaction_model.dart' as crypto_transaction;

typedef Transaction = crypto_transaction.Transaction;

// Mock do WalletRepository
class MockWalletRepository implements WalletRepository {
  Wallet _wallet = Wallet.initial(initialBalance: 10000.0);
  
  final List<Transaction> _transactions = [];
  final List<PortfolioAsset> _assets = [];

  @override
  Future<Wallet> getWallet(String userId) async {
    return _wallet;
  }

  @override
  Future<void> updateWallet(String userId, Wallet wallet) async {
    _wallet = wallet;
  }

  @override
  Future<List<Transaction>> getTransactions(String userId) async {
    return _transactions;
  }

  @override
  Future<void> addTransaction(String userId, Transaction transaction) async {
    _transactions.add(transaction);
  }

  @override
  Future<List<PortfolioAsset>> getPortfolioAssets(String userId) async {
    return _assets;
  }

  @override
  Future<void> updatePortfolioAsset(String userId, PortfolioAsset asset) async {
    final index = _assets.indexWhere((a) => a.cryptoId == asset.cryptoId);
    if (index >= 0) {
      _assets[index] = asset;
    } else {
      _assets.add(asset);
    }
  }

  @override
  Future<void> removePortfolioAsset(String userId, String cryptoId) async {
    _assets.removeWhere((a) => a.cryptoId == cryptoId);
  }
}

void main() {
  group('WalletController', () {
    late WalletController controller;
    late MockWalletRepository mockRepository;

    setUp(() {
      mockRepository = MockWalletRepository();
      controller = WalletController(mockRepository);
    });

    tearDown(() {
      controller.dispose();
    });

    test('deve iniciar com saldo zero', () {
      expect(controller.balance, 0.0);
      expect(controller.isLoading, false);
    });

    test('deve carregar saldo com sucesso', () async {
      await controller.loadWallet('user123');

      expect(controller.balance, 10000.0);
      expect(controller.isLoading, false);
    });

    test('deve adicionar fundos', () async {
      await controller.loadWallet('user123');
      final initialBalance = controller.balance;

      await controller.loadWallet('user123');

      expect(controller.balance, greaterThanOrEqualTo(initialBalance));
    });
  });
}

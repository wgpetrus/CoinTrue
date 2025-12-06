import 'package:flutter/foundation.dart';
import '../../models/crypto/crypto_models.dart';
import '../../repositories/crypto/crypto_repositories.dart';

/// Controller para gerenciar carteira do usuário
/// 
/// Responsável por:
/// - Carregar saldo do usuário via Repository
/// - Inicializar carteira com saldo inicial
/// - Atualizar saldo após transações
/// - Gerenciar moeda padrão
/// 
/// Segue SOLID: Depende de WalletRepository (interface), não de implementação.
class WalletController extends ChangeNotifier {
  final WalletRepository _repository;
  
  // Estado
  Wallet? _wallet;
  bool _isLoading = false;
  String? _error;

  WalletController(this._repository);

  // Getters
  Wallet? get wallet => _wallet;
  double get balance => _wallet?.balance ?? 0.0;
  String get currency => _wallet?.currency ?? 'BRL';
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasWallet => _wallet != null;

  /// Carrega carteira do usuário
  Future<void> loadWallet(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('WalletController: Loading wallet for user $userId');
      
      _wallet = await _repository.getWallet(userId);
      debugPrint('WalletController: Wallet loaded - Balance: ${_wallet!.balance}');
      
      _error = null;
    } catch (e) {
      _error = 'Erro ao carregar carteira: $e';
      debugPrint('WalletController: Error loading wallet: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Inicializa carteira com saldo inicial (não necessário - repository cria automaticamente)
  @Deprecated('Use loadWallet() - repository cria automaticamente se não existir')
  Future<void> initializeWallet(String userId, {double initialBalance = 10000.00}) async {
    // Repository já cria carteira automaticamente no getWallet()
    await loadWallet(userId);
  }

  /// Atualiza saldo da carteira
  Future<void> updateBalance(String userId, double newBalance) async {
    if (_wallet == null) return;

    try {
      debugPrint('WalletController: Updating balance to R\$ $newBalance');
      
      final updatedWallet = _wallet!.copyWith(
        balance: newBalance,
        updatedAt: DateTime.now(),
      );

      await _repository.updateWallet(userId, updatedWallet);

      _wallet = updatedWallet;
      debugPrint('WalletController: Balance updated successfully');
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao atualizar saldo: $e';
      debugPrint('WalletController: Error updating balance: $e');
      rethrow;
    }
  }

  /// Adiciona valor ao saldo
  Future<void> addBalance(String userId, double amount) async {
    if (_wallet == null) return;
    
    final newBalance = _wallet!.balance + amount;
    await updateBalance(userId, newBalance);
  }

  /// Subtrai valor do saldo
  Future<void> subtractBalance(String userId, double amount) async {
    if (_wallet == null) return;
    
    final newBalance = _wallet!.balance - amount;
    await updateBalance(userId, newBalance);
  }

  /// Verifica se tem saldo suficiente
  bool hasSufficientBalance(double amount) {
    return _wallet?.hasSufficientBalance(amount) ?? false;
  }

  /// Atualiza moeda padrão
  Future<void> updateCurrency(String userId, String newCurrency) async {
    if (_wallet == null) return;

    try {
      debugPrint('WalletController: Updating currency to $newCurrency');
      
      final updatedWallet = _wallet!.copyWith(
        currency: newCurrency,
        updatedAt: DateTime.now(),
      );

      await _repository.updateWallet(userId, updatedWallet);

      _wallet = updatedWallet;
      debugPrint('WalletController: Currency updated successfully');
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao atualizar moeda: $e';
      debugPrint('WalletController: Error updating currency: $e');
      rethrow;
    }
  }

  /// Limpa erro
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Reseta estado
  void reset() {
    _wallet = null;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}

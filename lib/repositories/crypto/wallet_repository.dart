import '../../models/crypto/crypto_models.dart' hide Transaction;
import '../../models/crypto/transaction.dart' as crypto_transaction;

/// Interface do repositório de carteira
/// 
/// Define o contrato para acesso a dados da carteira do usuário.
/// Segue o princípio DIP (Dependency Inversion Principle) do SOLID.
abstract class WalletRepository {
  /// Busca a carteira do usuário
  Future<Wallet> getWallet(String userId);
  
  /// Atualiza a carteira do usuário
  Future<void> updateWallet(String userId, Wallet wallet);
  
  /// Busca transações do usuário
  Future<List<crypto_transaction.Transaction>> getTransactions(String userId);
  
  /// Adiciona uma nova transação
  Future<void> addTransaction(String userId, crypto_transaction.Transaction transaction);
  
  /// Busca ativos do portfólio
  Future<List<PortfolioAsset>> getPortfolioAssets(String userId);
  
  /// Atualiza um ativo do portfólio
  Future<void> updatePortfolioAsset(String userId, PortfolioAsset asset);
  
  /// Remove um ativo do portfólio
  Future<void> removePortfolioAsset(String userId, String cryptoId);
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/crypto/crypto_models.dart' hide Transaction;
import '../../models/crypto/transaction.dart' as crypto_transaction;
import 'wallet_repository.dart';

/// Implementação do repositório de carteira usando Firestore
/// 
/// Armazena dados da carteira, transações e ativos no Firestore.
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
      // Cria carteira inicial se não existir
      final newWallet = Wallet.initial();
      await updateWallet(userId, newWallet);
      return newWallet;
    }
    
    return Wallet.fromFirestore(doc);
  }
  
  @override
  Future<void> updateWallet(String userId, Wallet wallet) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('wallet')
        .doc('data')
        .set(wallet.toFirestore(), SetOptions(merge: true));
  }
  
  @override
  Future<List<crypto_transaction.Transaction>> getTransactions(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .orderBy('timestamp', descending: true)
        .limit(100)
        .get();
    
    return snapshot.docs
        .map((doc) => crypto_transaction.Transaction.fromFirestore(doc))
        .toList();
  }
  
  @override
  Future<void> addTransaction(String userId, crypto_transaction.Transaction transaction) async {
    // Gerar ID automaticamente se estiver vazio
    final docRef = transaction.id.isEmpty
        ? _firestore
            .collection('users')
            .doc(userId)
            .collection('transactions')
            .doc() // Gera ID automaticamente
        : _firestore
            .collection('users')
            .doc(userId)
            .collection('transactions')
            .doc(transaction.id);
    
    await docRef.set(transaction.toFirestore());
  }
  
  @override
  Future<List<PortfolioAsset>> getPortfolioAssets(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('portfolio')
        .get();
    
    return snapshot.docs
        .map((doc) => PortfolioAsset.fromFirestore(doc.id, doc))
        .toList();
  }
  
  @override
  Future<void> updatePortfolioAsset(String userId, PortfolioAsset asset) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('portfolio')
        .doc(asset.cryptoId)
        .set(asset.toFirestore(), SetOptions(merge: true));
  }
  
  @override
  Future<void> removePortfolioAsset(String userId, String cryptoId) async {
    print('🔥 WalletRepository: DELETING asset $cryptoId from Firestore for user $userId');
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('portfolio')
        .doc(cryptoId)
        .delete();
    print('🔥 WalletRepository: Asset $cryptoId DELETED successfully');
  }
}

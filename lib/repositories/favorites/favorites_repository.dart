import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/models.dart';

/// Repository de Favoritos
/// 
/// Gerencia favoritos no Firestore
class FavoritesRepository {
  final FirebaseFirestore _firestore;

  FavoritesRepository(this._firestore);

  /// Adiciona cripto aos favoritos
  Future<void> addFavorite(String userId, String symbol) async {
    final favorite = FavoriteCrypto(
      symbol: symbol,
      addedAt: DateTime.now(),
    );

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(symbol)
        .set(favorite.toMap());
  }

  /// Remove cripto dos favoritos
  Future<void> removeFavorite(String userId, String symbol) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(symbol)
        .delete();
  }

  /// Carrega favoritos do usuário
  Future<List<FavoriteCrypto>> loadFavorites(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .orderBy('addedAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => FavoriteCrypto.fromMap(doc.data()))
        .toList();
  }

  /// Stream de favoritos
  Stream<List<FavoriteCrypto>> watchFavorites(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FavoriteCrypto.fromMap(doc.data()))
            .toList());
  }

  /// Verifica se cripto está nos favoritos
  Future<bool> isFavorite(String userId, String symbol) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(symbol)
        .get();

    return doc.exists;
  }
}

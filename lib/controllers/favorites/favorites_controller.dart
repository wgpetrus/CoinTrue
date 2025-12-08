import 'package:flutter/foundation.dart';
import '../../repositories/repositories.dart';

/// Controller de Favoritos
/// 
/// Gerencia:
/// - Lista de criptos favoritas
/// - Adicionar/remover favoritos
/// - Sincronização com Firestore
class FavoritesController extends ChangeNotifier {
  final FavoritesRepository _repository;

  Set<String> _favoriteSymbols = {};
  bool _isLoading = false;

  FavoritesController(this._repository);

  // Getters
  Set<String> get favoriteSymbols => _favoriteSymbols;
  bool get isLoading => _isLoading;

  /// Verifica se uma cripto é favorita
  bool isFavorite(String symbol) {
    return _favoriteSymbols.contains(symbol);
  }

  /// Carrega favoritos do usuário
  Future<void> loadFavorites(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final favorites = await _repository.loadFavorites(userId);
      _favoriteSymbols = favorites.map((f) => f.symbol).toSet();
      debugPrint('✅ Loaded ${_favoriteSymbols.length} favorites');
    } catch (e) {
      debugPrint('❌ Error loading favorites: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Adiciona cripto aos favoritos
  Future<void> addFavorite(String userId, String symbol) async {
    try {
      await _repository.addFavorite(userId, symbol);
      _favoriteSymbols.add(symbol);
      notifyListeners();
      debugPrint('⭐ Added $symbol to favorites');
    } catch (e) {
      debugPrint('❌ Error adding favorite: $e');
      rethrow;
    }
  }

  /// Remove cripto dos favoritos
  Future<void> removeFavorite(String userId, String symbol) async {
    try {
      await _repository.removeFavorite(userId, symbol);
      _favoriteSymbols.remove(symbol);
      notifyListeners();
      debugPrint('⭐ Removed $symbol from favorites');
    } catch (e) {
      debugPrint('❌ Error removing favorite: $e');
      rethrow;
    }
  }

  /// Toggle favorito
  Future<void> toggleFavorite(String userId, String symbol) async {
    if (isFavorite(symbol)) {
      await removeFavorite(userId, symbol);
    } else {
      await addFavorite(userId, symbol);
    }
  }
}

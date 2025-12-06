import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:fl_chart/fl_chart.dart';

/// Serviço de cache de dados de gráficos no Firebase
/// 
/// Salva dados de gráficos por 12 horas para usar como fallback
/// quando a API CoinGecko falhar ou atingir rate limit.
class ChartCacheService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Duração do cache: 12 horas
  static const Duration cacheDuration = Duration(hours: 12);
  
  /// Salva dados do gráfico no Firebase
  Future<void> saveChartData(
    String coinId,
    String period,
    List<FlSpot> data,
  ) async {
    try {
      final cacheKey = '${coinId}_$period';
      final expiresAt = DateTime.now().add(cacheDuration);
      
      // Converte FlSpot para Map
      final dataMap = data.map((spot) => {
        'x': spot.x,
        'y': spot.y,
      }).toList();
      
      await _firestore
          .collection('chart_cache')
          .doc(cacheKey)
          .set({
        'coinId': coinId,
        'period': period,
        'data': dataMap,
        'cachedAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(expiresAt),
      });
      
      debugPrint('ChartCache: Saved $cacheKey (${data.length} points)');
    } catch (e) {
      debugPrint('ChartCache: Error saving data: $e');
      // Não propaga erro - cache é opcional
    }
  }
  
  /// Busca dados do gráfico no Firebase
  Future<List<FlSpot>?> getChartData(String coinId, String period) async {
    try {
      final cacheKey = '${coinId}_$period';
      
      final doc = await _firestore
          .collection('chart_cache')
          .doc(cacheKey)
          .get();
      
      if (!doc.exists) {
        debugPrint('ChartCache: No cache found for $cacheKey');
        return null;
      }
      
      final data = doc.data();
      if (data == null) return null;
      
      // Verifica se expirou
      final expiresAt = (data['expiresAt'] as Timestamp?)?.toDate();
      if (expiresAt == null || DateTime.now().isAfter(expiresAt)) {
        debugPrint('ChartCache: Cache expired for $cacheKey');
        // Remove cache expirado
        _deleteChartData(cacheKey);
        return null;
      }
      
      // Converte Map para FlSpot
      final dataList = data['data'] as List<dynamic>;
      final spots = dataList.map((item) {
        final map = item as Map<String, dynamic>;
        return FlSpot(
          (map['x'] as num).toDouble(),
          (map['y'] as num).toDouble(),
        );
      }).toList();
      
      debugPrint('ChartCache: Loaded $cacheKey (${spots.length} points)');
      return spots;
    } catch (e) {
      debugPrint('ChartCache: Error loading data: $e');
      return null;
    }
  }
  
  /// Remove dados do cache
  Future<void> _deleteChartData(String cacheKey) async {
    try {
      await _firestore.collection('chart_cache').doc(cacheKey).delete();
      debugPrint('ChartCache: Deleted expired cache $cacheKey');
    } catch (e) {
      debugPrint('ChartCache: Error deleting cache: $e');
    }
  }
  
  /// Limpa todo o cache expirado (manutenção)
  Future<void> cleanExpiredCache() async {
    try {
      final now = Timestamp.now();
      final snapshot = await _firestore
          .collection('chart_cache')
          .where('expiresAt', isLessThan: now)
          .get();
      
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
      
      debugPrint('ChartCache: Cleaned ${snapshot.docs.length} expired entries');
    } catch (e) {
      debugPrint('ChartCache: Error cleaning cache: $e');
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Serviço para obter taxa de câmbio USD/BRL em tempo real
/// 
/// Usa a AwesomeAPI (brasileira, gratuita, sem necessidade de chave)
/// https://docs.awesomeapi.com.br/api-de-moedas
/// 
/// Fallback: Firestore (último valor salvo por 12h)
class ExchangeRateService {
  static const String _baseUrl = 'https://economia.awesomeapi.com.br/json/last';
  static const String _firestoreCollection = 'app_config';
  static const String _firestoreDoc = 'exchange_rate';
  
  final http.Client _client;
  final FirebaseFirestore _firestore;
  
  // Cache em memória da taxa de câmbio
  static double? _cachedRate;
  static DateTime? _cacheTime;
  static const Duration _cacheDuration = Duration(minutes: 5); // Cache local: 5 min
  static const Duration _firestoreCacheDuration = Duration(hours: 12); // Cache Firestore: 12h
  
  ExchangeRateService({
    http.Client? client,
    FirebaseFirestore? firestore,
  })  : _client = client ?? http.Client(),
        _firestore = firestore ?? FirebaseFirestore.instance;
  
  /// Obtém a taxa de câmbio USD → BRL atual
  /// 
  /// Retorna o valor em reais de 1 dólar.
  /// Exemplo: se retornar 6.0, significa que $1 USD = R$ 6,00
  /// 
  /// Estratégia de fallback:
  /// 1. Cache em memória (5 min)
  /// 2. API AwesomeAPI (tempo real)
  /// 3. Firestore (último valor salvo, 12h)
  /// 4. Fallback fixo (R$ 6,00)
  Future<double> getUsdToBrlRate({bool forceRefresh = false}) async {
    // 1. Verifica cache em memória
    if (!forceRefresh && _cachedRate != null && _cacheTime != null) {
      final cacheAge = DateTime.now().difference(_cacheTime!);
      if (cacheAge < _cacheDuration) {
        debugPrint('💱 [EXCHANGE] Using memory cache: R\$ ${_cachedRate!.toStringAsFixed(2)} (age: ${cacheAge.inMinutes}min)');
        return _cachedRate!;
      }
    }
    
    // 2. Tenta buscar da API
    try {
      debugPrint('💱 [EXCHANGE] Fetching from AwesomeAPI...');
      final startTime = DateTime.now();
      
      final response = await _client.get(
        Uri.parse('$_baseUrl/USD-BRL'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 5));
      
      final duration = DateTime.now().difference(startTime);
      debugPrint('⏱️ [EXCHANGE] Response time: ${duration.inMilliseconds}ms');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rate = double.parse(data['USDBRL']['bid']);
        
        // Salva no cache em memória
        _cachedRate = rate;
        _cacheTime = DateTime.now();
        
        // Salva no Firestore para fallback
        await _saveToFirestore(rate);
        
        debugPrint('✅ [EXCHANGE] Current rate: \$1 USD = R\$ ${rate.toStringAsFixed(2)}');
        return rate;
      } else {
        throw Exception('Exchange API error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ [EXCHANGE] API Error: $e');
      
      // 3. Tenta buscar do Firestore
      try {
        final firestoreRate = await _getFromFirestore();
        if (firestoreRate != null) {
          _cachedRate = firestoreRate;
          _cacheTime = DateTime.now();
          debugPrint('✅ [EXCHANGE] Using Firestore fallback: R\$ ${firestoreRate.toStringAsFixed(2)}');
          return firestoreRate;
        }
      } catch (firestoreError) {
        debugPrint('❌ [EXCHANGE] Firestore Error: $firestoreError');
      }
      
      // 4. Usa cache em memória antigo se houver
      if (_cachedRate != null) {
        debugPrint('⚠️ [EXCHANGE] Using old memory cache: R\$ ${_cachedRate!.toStringAsFixed(2)}');
        return _cachedRate!;
      }
      
      // 5. Fallback fixo (última opção)
      const fallbackRate = 6.0;
      debugPrint('⚠️ [EXCHANGE] Using fixed fallback: R\$ ${fallbackRate.toStringAsFixed(2)}');
      return fallbackRate;
    }
  }
  
  /// Salva a taxa no Firestore para fallback
  Future<void> _saveToFirestore(double rate) async {
    try {
      await _firestore.collection(_firestoreCollection).doc(_firestoreDoc).set({
        'rate': rate,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('💾 [EXCHANGE] Saved to Firestore: R\$ ${rate.toStringAsFixed(2)}');
    } catch (e) {
      debugPrint('⚠️ [EXCHANGE] Failed to save to Firestore: $e');
      // Não propaga erro, é apenas cache
    }
  }
  
  /// Busca a taxa do Firestore (se não estiver expirada)
  Future<double?> _getFromFirestore() async {
    try {
      final doc = await _firestore
          .collection(_firestoreCollection)
          .doc(_firestoreDoc)
          .get();
      
      if (!doc.exists) {
        debugPrint('⚠️ [EXCHANGE] No data in Firestore');
        return null;
      }
      
      final data = doc.data()!;
      final rate = (data['rate'] as num).toDouble();
      final updatedAt = (data['updatedAt'] as Timestamp).toDate();
      final age = DateTime.now().difference(updatedAt);
      
      // Verifica se não está expirado (12h)
      if (age > _firestoreCacheDuration) {
        debugPrint('⚠️ [EXCHANGE] Firestore data expired (age: ${age.inHours}h)');
        return null;
      }
      
      debugPrint('📦 [EXCHANGE] Found in Firestore: R\$ ${rate.toStringAsFixed(2)} (age: ${age.inHours}h)');
      return rate;
    } catch (e) {
      debugPrint('❌ [EXCHANGE] Error reading from Firestore: $e');
      return null;
    }
  }
  
  /// Limpa o cache (útil para forçar atualização)
  static void clearCache() {
    _cachedRate = null;
    _cacheTime = null;
    debugPrint('🗑️ [EXCHANGE] Cache cleared');
  }
  
  /// Obtém a idade do cache em minutos
  static int? getCacheAgeMinutes() {
    if (_cacheTime == null) return null;
    return DateTime.now().difference(_cacheTime!).inMinutes;
  }
}

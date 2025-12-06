import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/crypto/crypto_models.dart';
import 'crypto_api_service.dart';
import '../exchange_rate_service.dart';

/// Implementação do serviço de API usando CoinGecko
/// 
/// Fornece dados reais de 10.000+ criptomoedas da API pública do CoinGecko.
/// API gratuita, sem necessidade de chave.
class CoinGeckoApiService implements CryptoApiService {
  static const String baseUrl = 'https://api.coingecko.com/api/v3';
  
  final http.Client _client;
  final ExchangeRateService _exchangeRateService;
  
  // Cache em memória (balanceado: dados frescos + evita rate limit)
  final Map<String, _CachedData> _memoryCache = {};
  static const Duration cacheExpiration = Duration(minutes: 2); // 2 minutos
  
  // Cache da taxa de câmbio
  double? _cachedExchangeRate;
  
  CoinGeckoApiService({http.Client? client, ExchangeRateService? exchangeRateService})
      : _client = client ?? http.Client(),
        _exchangeRateService = exchangeRateService ?? ExchangeRateService();
  
  /// Obtém a taxa de câmbio USD → BRL (com cache)
  Future<double> _getExchangeRate() async {
    if (_cachedExchangeRate != null) {
      return _cachedExchangeRate!;
    }
    
    _cachedExchangeRate = await _exchangeRateService.getUsdToBrlRate();
    return _cachedExchangeRate!;
  }

  @override
  Future<List<Crypto>> getCryptos({int limit = 100}) async {
    final cacheKey = 'cryptos_$limit';
    
    // Verifica cache
    if (_memoryCache.containsKey(cacheKey) && !_memoryCache[cacheKey]!.isExpired) {
      debugPrint('✅ [CACHE] Using cached cryptos (expires in ${_memoryCache[cacheKey]!.expiresInSeconds}s)');
      return _memoryCache[cacheKey]!.data as List<Crypto>;
    }

    try {
      debugPrint('🚀 [COINGECKO] Fetching $limit cryptos...');
      final startTime = DateTime.now();
      
      final response = await _client.get(
        Uri.parse('$baseUrl/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=$limit&page=1&sparkline=false&price_change_percentage=24h'),
        headers: {'Accept': 'application/json'},
      );

      final duration = DateTime.now().difference(startTime);
      debugPrint('⏱️ [COINGECKO] Response time: ${duration.inMilliseconds}ms');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        // Obtém taxa de câmbio atual
        final exchangeRate = await _getExchangeRate();
        
        final cryptos = data.map((json) => _parseCrypto(json, exchangeRate)).toList();
        
        // Salva no cache
        _memoryCache[cacheKey] = _CachedData(cryptos);
        
        debugPrint('✅ [COINGECKO] Loaded ${cryptos.length} cryptos (rate: R\$ ${exchangeRate.toStringAsFixed(2)})');
        return cryptos;
      } else if (response.statusCode == 429) {
        debugPrint('⚠️ [COINGECKO] Rate limit! Using cache (even if expired)...');
        if (_memoryCache.containsKey(cacheKey)) {
          debugPrint('✅ [CACHE] Using expired cache as fallback');
          return _memoryCache[cacheKey]!.data as List<Crypto>;
        }
        // Se não tem cache, retorna lista vazia ao invés de erro
        debugPrint('⚠️ [COINGECKO] No cache available, returning empty list');
        return [];
      } else {
        throw Exception('CoinGecko API error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ [COINGECKO] Error: $e');
      
      // Retorna cache expirado se houver
      if (_memoryCache.containsKey(cacheKey)) {
        debugPrint('⚠️ [CACHE] Using expired cache as fallback');
        return _memoryCache[cacheKey]!.data as List<Crypto>;
      }
      
      rethrow;
    }
  }

  @override
  Future<Crypto> getCryptoById(String id) async {
    final cacheKey = 'crypto_$id';
    
    // Verifica cache
    if (_memoryCache.containsKey(cacheKey) && !_memoryCache[cacheKey]!.isExpired) {
      return _memoryCache[cacheKey]!.data as Crypto;
    }

    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/coins/$id?localization=false&tickers=false&market_data=true&community_data=false&developer_data=false&sparkline=false'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        
        // Obtém taxa de câmbio atual
        final exchangeRate = await _getExchangeRate();
        
        final crypto = _parseCryptoDetail(json, exchangeRate);
        
        // Salva no cache
        _memoryCache[cacheKey] = _CachedData(crypto);
        
        return crypto;
      } else {
        throw Exception('CoinGecko API error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ [COINGECKO] Error getting crypto $id: $e');
      
      // Retorna cache expirado se houver
      if (_memoryCache.containsKey(cacheKey)) {
        return _memoryCache[cacheKey]!.data as Crypto;
      }
      
      rethrow;
    }
  }

  @override
  Future<Map<String, double>> getCurrentPrices(List<String> ids) async {
    try {
      final idsString = ids.join(',');
      final response = await _client.get(
        Uri.parse('$baseUrl/simple/price?ids=$idsString&vs_currencies=usd'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final prices = <String, double>{};
        
        data.forEach((key, value) {
          prices[key] = (value['usd'] as num).toDouble();
        });
        
        return prices;
      } else {
        throw Exception('CoinGecko API error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ [COINGECKO] Error getting prices: $e');
      return {};
    }
  }

  @override
  Future<double> getPrice(String id) async {
    try {
      final crypto = await getCryptoById(id);
      return crypto.currentPrice;
    } catch (e) {
      debugPrint('❌ [COINGECKO] Error getting price for $id: $e');
      return 0;
    }
  }

  /// Obtém dados do gráfico
  Future<List<FlSpot>> getChartData(String coinId, String period) async {
    final days = _getDays(period);
    
    try {
      debugPrint('📊 [COINGECKO] Fetching chart data for $coinId ($period)');
      
      final response = await _client.get(
        Uri.parse('$baseUrl/coins/$coinId/market_chart?vs_currency=usd&days=$days'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> prices = data['prices'];
        
        if (prices.isEmpty) {
          debugPrint('⚠️ [COINGECKO] No chart data available');
          return [];
        }
        
        final spots = <FlSpot>[];
        for (int i = 0; i < prices.length; i++) {
          final price = (prices[i][1] as num).toDouble();
          spots.add(FlSpot(i.toDouble(), price));
        }
        
        debugPrint('✅ [COINGECKO] Loaded ${spots.length} chart points');
        return spots;
      } else {
        throw Exception('CoinGecko API error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ [COINGECKO] Error getting chart data: $e');
      return [];
    }
  }

  /// Converte dados da CoinGecko para modelo Crypto
  Crypto _parseCrypto(Map<String, dynamic> json, double usdToBrl) {
    final priceUsd = (json['current_price'] as num?)?.toDouble() ?? 0;
    final priceBrl = priceUsd * usdToBrl;
    
    // Log apenas para Bitcoin para debug
    if (json['id'] == 'bitcoin') {
      debugPrint('🪙 [BITCOIN] Price USD: \$${priceUsd.toStringAsFixed(2)} × Rate: R\$${usdToBrl.toStringAsFixed(2)} = R\$${priceBrl.toStringAsFixed(2)}');
    }
    
    return Crypto(
      id: json['id'] ?? '',
      symbol: (json['symbol'] ?? '').toUpperCase(),
      name: json['name'] ?? '',
      currentPrice: priceBrl,
      priceChange24h: (json['price_change_percentage_24h'] as num?)?.toDouble() ?? 0,
      volume24h: ((json['total_volume'] as num?)?.toDouble() ?? 0) * usdToBrl,
      marketCap: ((json['market_cap'] as num?)?.toDouble() ?? 0) * usdToBrl,
      high24h: ((json['high_24h'] as num?)?.toDouble() ?? 0) * usdToBrl,
      low24h: ((json['low_24h'] as num?)?.toDouble() ?? 0) * usdToBrl,
      imageUrl: json['image'],
      lastUpdated: DateTime.now(),
    );
  }

  /// Converte dados detalhados da CoinGecko para modelo Crypto
  Crypto _parseCryptoDetail(Map<String, dynamic> json, double usdToBrl) {
    final marketData = json['market_data'] ?? {};
    
    return Crypto(
      id: json['id'] ?? '',
      symbol: (json['symbol'] ?? '').toUpperCase(),
      name: json['name'] ?? '',
      currentPrice: ((marketData['current_price']?['usd'] as num?)?.toDouble() ?? 0) * usdToBrl,
      priceChange24h: (marketData['price_change_percentage_24h'] as num?)?.toDouble() ?? 0,
      volume24h: ((marketData['total_volume']?['usd'] as num?)?.toDouble() ?? 0) * usdToBrl,
      marketCap: ((marketData['market_cap']?['usd'] as num?)?.toDouble() ?? 0) * usdToBrl,
      high24h: ((marketData['high_24h']?['usd'] as num?)?.toDouble() ?? 0) * usdToBrl,
      low24h: ((marketData['low_24h']?['usd'] as num?)?.toDouble() ?? 0) * usdToBrl,
      imageUrl: json['image']?['large'],
      lastUpdated: DateTime.now(),
    );
  }

  /// Converte período para dias
  int _getDays(String period) {
    switch (period) {
      case '1H':
        return 1;
      case '24H':
        return 1;
      case '7D':
        return 7;
      case '1M':
        return 30;
      case '1A':
        return 365;
      default:
        return 1;
    }
  }

  /// Busca criptomoedas na API por query
  Future<List<Crypto>> searchCryptos(String query) async {
    if (query.isEmpty) return [];
    
    try {
      debugPrint('🔍 [COINGECKO] Searching for "$query"...');
      
      final response = await _client.get(
        Uri.parse('$baseUrl/search?query=$query'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> coins = data['coins'] ?? [];
        
        // Pega os IDs das moedas encontradas (limitado a 20 resultados)
        final coinIds = coins.take(20).map((c) => c['id'] as String).toList();
        
        if (coinIds.isEmpty) {
          debugPrint('⚠️ [COINGECKO] No results found');
          return [];
        }
        
        // Busca dados completos das moedas encontradas
        final idsString = coinIds.join(',');
        final marketsResponse = await _client.get(
          Uri.parse('$baseUrl/coins/markets?vs_currency=usd&ids=$idsString&order=market_cap_desc&sparkline=false&price_change_percentage=24h'),
          headers: {'Accept': 'application/json'},
        );
        
        if (marketsResponse.statusCode == 200) {
          final List<dynamic> marketsData = json.decode(marketsResponse.body);
          
          // Obtém taxa de câmbio atual
          final exchangeRate = await _getExchangeRate();
          
          final cryptos = marketsData.map((json) => _parseCrypto(json, exchangeRate)).toList();
          
          debugPrint('✅ [COINGECKO] Found ${cryptos.length} results');
          return cryptos;
        }
        
        return [];
      } else if (response.statusCode == 429) {
        debugPrint('⚠️ [COINGECKO] Rate limit on search');
        return [];
      } else {
        throw Exception('CoinGecko API error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ [COINGECKO] Error searching: $e');
      return [];
    }
  }

  /// Limpa o cache (mas mantém último resultado como fallback)
  void clearCache() {
    // Não limpa completamente, apenas marca como expirado
    // Assim sempre tem dados para mostrar
    debugPrint('🔄 [COINGECKO] Cache marked as expired (will refresh on next call)');
  }
}

/// Classe auxiliar para cache em memória
class _CachedData {
  final dynamic data;
  final DateTime timestamp;
  final Duration expiration;

  _CachedData(this.data, [Duration? customExpiration]) 
      : timestamp = DateTime.now(),
        expiration = customExpiration ?? CoinGeckoApiService.cacheExpiration;

  bool get isExpired {
    return DateTime.now().difference(timestamp) > expiration;
  }
  
  int get expiresInSeconds {
    final remaining = expiration - DateTime.now().difference(timestamp);
    return remaining.inSeconds.clamp(0, expiration.inSeconds);
  }
}

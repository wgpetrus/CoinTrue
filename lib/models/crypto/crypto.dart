import 'package:equatable/equatable.dart';

/// Modelo de Criptomoeda
/// 
/// Representa uma criptomoeda com seus dados de mercado.
/// Dados obtidos da API da Coinbase.
class Crypto extends Equatable {
  final String id;              // 'BTC', 'ETH', etc
  final String symbol;          // 'BTC', 'ETH', etc
  final String name;            // 'Bitcoin', 'Ethereum', etc
  final double currentPrice;    // Preço atual em USD
  final double priceChange24h;  // Variação percentual 24h
  final double? volume24h;      // Volume 24h (opcional)
  final double? marketCap;      // Market Cap (opcional)
  final double? high24h;        // Alta 24h (opcional)
  final double? low24h;         // Baixa 24h (opcional)
  final String? imageUrl;       // URL da imagem (opcional)
  final DateTime lastUpdated;   // Última atualização

  const Crypto({
    required this.id,
    required this.symbol,
    required this.name,
    required this.currentPrice,
    required this.priceChange24h,
    this.volume24h,
    this.marketCap,
    this.high24h,
    this.low24h,
    this.imageUrl,
    required this.lastUpdated,
  });

  /// Cria uma instância a partir de dados da API Coinbase
  factory Crypto.fromCoinbaseApi({
    required String id,
    required String symbol,
    required String name,
    required double price,
    double priceChange24h = 0.0,
    double? volume24h,
    double? marketCap,
    double? high24h,
    double? low24h,
    String? imageUrl,
  }) {
    return Crypto(
      id: id,
      symbol: symbol.toUpperCase(),
      name: name,
      currentPrice: price,
      priceChange24h: priceChange24h,
      volume24h: volume24h,
      marketCap: marketCap,
      high24h: high24h,
      low24h: low24h,
      imageUrl: imageUrl,
      lastUpdated: DateTime.now(),
    );
  }

  /// Cria uma cópia com campos atualizados
  Crypto copyWith({
    String? id,
    String? symbol,
    String? name,
    double? currentPrice,
    double? priceChange24h,
    double? volume24h,
    double? marketCap,
    double? high24h,
    double? low24h,
    String? imageUrl,
    DateTime? lastUpdated,
  }) {
    return Crypto(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      currentPrice: currentPrice ?? this.currentPrice,
      priceChange24h: priceChange24h ?? this.priceChange24h,
      volume24h: volume24h ?? this.volume24h,
      marketCap: marketCap ?? this.marketCap,
      high24h: high24h ?? this.high24h,
      low24h: low24h ?? this.low24h,
      imageUrl: imageUrl ?? this.imageUrl,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'name': name,
      'currentPrice': currentPrice,
      'priceChange24h': priceChange24h,
      'volume24h': volume24h,
      'marketCap': marketCap,
      'high24h': high24h,
      'low24h': low24h,
      'imageUrl': imageUrl,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  /// Cria uma instância a partir de JSON
  factory Crypto.fromJson(Map<String, dynamic> json) {
    return Crypto(
      id: json['id'] as String,
      symbol: json['symbol'] as String,
      name: json['name'] as String,
      currentPrice: (json['currentPrice'] as num).toDouble(),
      priceChange24h: (json['priceChange24h'] as num).toDouble(),
      volume24h: json['volume24h'] != null ? (json['volume24h'] as num).toDouble() : null,
      marketCap: json['marketCap'] != null ? (json['marketCap'] as num).toDouble() : null,
      high24h: json['high24h'] != null ? (json['high24h'] as num).toDouble() : null,
      low24h: json['low24h'] != null ? (json['low24h'] as num).toDouble() : null,
      imageUrl: json['imageUrl'] as String?,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  @override
  List<Object?> get props => [
        id,
        symbol,
        name,
        currentPrice,
        priceChange24h,
        volume24h,
        marketCap,
        high24h,
        low24h,
        imageUrl,
        lastUpdated,
      ];

  @override
  String toString() {
    return 'Crypto(id: $id, symbol: $symbol, name: $name, price: \$$currentPrice, change: $priceChange24h%)';
  }
}

/// Modelo de Criptomoeda Favorita
class FavoriteCrypto {
  final String symbol;
  final DateTime addedAt;

  const FavoriteCrypto({
    required this.symbol,
    required this.addedAt,
  });

  /// Cria a partir de um Map (Firestore)
  factory FavoriteCrypto.fromMap(Map<String, dynamic> map) {
    return FavoriteCrypto(
      symbol: map['symbol'] as String,
      addedAt: DateTime.parse(map['addedAt'] as String),
    );
  }

  /// Converte para Map (Firestore)
  Map<String, dynamic> toMap() {
    return {
      'symbol': symbol,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FavoriteCrypto && other.symbol == symbol;
  }

  @override
  int get hashCode => symbol.hashCode;
}

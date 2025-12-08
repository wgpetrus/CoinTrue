import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de Ativo no Portfólio
/// 
/// Representa uma criptomoeda que o usuário possui.
/// Armazenado no Firestore em: users/{userId}/portfolio/{cryptoId}
class PortfolioAsset extends Equatable {
  final String cryptoId;        // ID da cripto (BTC, ETH, etc)
  final double quantity;        // Quantidade possuída
  final double avgPrice;        // Preço médio de compra
  final double totalInvested;   // Total investido
  final DateTime updatedAt;     // Última atualização

  const PortfolioAsset({
    required this.cryptoId,
    required this.quantity,
    required this.avgPrice,
    required this.totalInvested,
    required this.updatedAt,
  });

  /// Cria uma instância a partir do Firestore
  factory PortfolioAsset.fromFirestore(String cryptoId, DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PortfolioAsset(
      cryptoId: cryptoId,
      quantity: (data['quantity'] as num).toDouble(),
      avgPrice: (data['avgPrice'] as num).toDouble(),
      totalInvested: (data['totalInvested'] as num).toDouble(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Converte para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'quantity': quantity,
      'avgPrice': avgPrice,
      'totalInvested': totalInvested,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Calcula o valor atual baseado no preço atual
  double calculateCurrentValue(double currentPrice) {
    return quantity * currentPrice;
  }

  /// Calcula o lucro/prejuízo
  double calculateProfitLoss(double currentPrice) {
    return calculateCurrentValue(currentPrice) - totalInvested;
  }

  /// Calcula o percentual de lucro/prejuízo
  double calculateProfitLossPercent(double currentPrice) {
    if (totalInvested == 0) return 0;
    return (calculateProfitLoss(currentPrice) / totalInvested) * 100;
  }

  /// Adiciona uma compra ao ativo
  PortfolioAsset addPurchase({
    required double quantity,
    required double price,
  }) {
    final newQuantity = this.quantity + quantity;
    final newTotalInvested = totalInvested + (quantity * price);
    final newAvgPrice = newTotalInvested / newQuantity;

    return PortfolioAsset(
      cryptoId: cryptoId,
      quantity: newQuantity,
      avgPrice: newAvgPrice,
      totalInvested: newTotalInvested,
      updatedAt: DateTime.now(),
    );
  }

  /// Remove uma venda do ativo
  PortfolioAsset removeSale({
    required double quantity,
  }) {
    final newQuantity = this.quantity - quantity;
    
    if (newQuantity <= 0) {
      // Se vendeu tudo, zera
      return PortfolioAsset(
        cryptoId: cryptoId,
        quantity: 0,
        avgPrice: 0,
        totalInvested: 0,
        updatedAt: DateTime.now(),
      );
    }

    // Mantém o preço médio, apenas reduz quantidade e total investido proporcionalmente
    final proportionSold = quantity / this.quantity;
    final newTotalInvested = totalInvested * (1 - proportionSold);

    return PortfolioAsset(
      cryptoId: cryptoId,
      quantity: newQuantity,
      avgPrice: avgPrice, // Mantém o preço médio
      totalInvested: newTotalInvested,
      updatedAt: DateTime.now(),
    );
  }

  /// Cria uma cópia com campos atualizados
  PortfolioAsset copyWith({
    String? cryptoId,
    double? quantity,
    double? avgPrice,
    double? totalInvested,
    DateTime? updatedAt,
  }) {
    return PortfolioAsset(
      cryptoId: cryptoId ?? this.cryptoId,
      quantity: quantity ?? this.quantity,
      avgPrice: avgPrice ?? this.avgPrice,
      totalInvested: totalInvested ?? this.totalInvested,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [cryptoId, quantity, avgPrice, totalInvested, updatedAt];

  @override
  String toString() {
    return 'PortfolioAsset(crypto: $cryptoId, qty: $quantity, avg: \$$avgPrice, invested: \$$totalInvested)';
  }
}

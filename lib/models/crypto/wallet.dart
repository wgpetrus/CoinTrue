import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de Carteira do Usuário
/// 
/// Representa o saldo disponível do usuário para transações.
/// Armazenado no Firestore em: users/{userId}/wallet
class Wallet extends Equatable {
  final double balance;         // Saldo em BRL
  final String currency;         // Moeda (BRL, USD, EUR)
  final DateTime createdAt;      // Data de criação
  final DateTime updatedAt;      // Última atualização

  const Wallet({
    required this.balance,
    required this.currency,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Cria uma carteira inicial com saldo padrão
  factory Wallet.initial({double initialBalance = 10000.00}) {
    final now = DateTime.now();
    return Wallet(
      balance: initialBalance,
      currency: 'BRL',
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Cria uma instância a partir do Firestore
  factory Wallet.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Wallet(
      balance: (data['balance'] as num).toDouble(),
      currency: data['currency'] as String? ?? 'BRL',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Converte para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'balance': balance,
      'currency': currency,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Cria uma cópia com campos atualizados
  Wallet copyWith({
    double? balance,
    String? currency,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Wallet(
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Adiciona valor ao saldo
  Wallet addBalance(double amount) {
    return copyWith(
      balance: balance + amount,
      updatedAt: DateTime.now(),
    );
  }

  /// Subtrai valor do saldo
  Wallet subtractBalance(double amount) {
    return copyWith(
      balance: balance - amount,
      updatedAt: DateTime.now(),
    );
  }

  /// Verifica se tem saldo suficiente
  bool hasSufficientBalance(double amount) {
    return balance >= amount;
  }

  @override
  List<Object?> get props => [balance, currency, createdAt, updatedAt];

  @override
  String toString() {
    return 'Wallet(balance: $currency ${balance.toStringAsFixed(2)})';
  }
}

import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Tipo de Transação
enum TransactionType {
  buy('buy', 'Compra'),
  sell('sell', 'Venda'),
  convert('convert', 'Conversão');

  final String code;
  final String label;
  const TransactionType(this.code, this.label);

  static TransactionType fromCode(String code) {
    return TransactionType.values.firstWhere(
      (type) => type.code == code,
      orElse: () => TransactionType.buy,
    );
  }
}

/// Status da Transação
enum TransactionStatus {
  pending('pending', 'Pendente'),
  completed('completed', 'Concluída'),
  failed('failed', 'Falhou');

  final String code;
  final String label;
  const TransactionStatus(this.code, this.label);

  static TransactionStatus fromCode(String code) {
    return TransactionStatus.values.firstWhere(
      (status) => status.code == code,
      orElse: () => TransactionStatus.completed,
    );
  }
}

/// Modelo de Transação
/// 
/// Representa uma transação de compra ou venda de criptomoeda.
/// Armazenado no Firestore em: users/{userId}/transactions/{transactionId}
class Transaction extends Equatable {
  final String id;                    // ID único da transação
  final String userId;                // ID do usuário
  final TransactionType type;         // Tipo (compra/venda/conversão)
  final String cryptoId;              // ID da cripto (origem em conversão)
  final double quantity;              // Quantidade
  final double price;                 // Preço unitário
  final double total;                 // Valor total
  final double fee;                   // Taxa
  final TransactionStatus status;     // Status
  final DateTime timestamp;           // Data/hora
  
  // Campos específicos para conversão
  final String? toCryptoId;           // ID da cripto de destino (conversão)
  final double? toQuantity;           // Quantidade recebida (conversão)
  final double? toPrice;              // Preço da cripto de destino (conversão)

  const Transaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.cryptoId,
    required this.quantity,
    required this.price,
    required this.total,
    this.fee = 0.0,
    this.status = TransactionStatus.completed,
    required this.timestamp,
    this.toCryptoId,
    this.toQuantity,
    this.toPrice,
  });

  /// Cria uma nova transação de compra
  factory Transaction.buy({
    required String userId,
    required String cryptoId,
    required double quantity,
    required double price,
  }) {
    final total = quantity * price;
    return Transaction(
      id: '', // Será gerado pelo Firestore
      userId: userId,
      type: TransactionType.buy,
      cryptoId: cryptoId,
      quantity: quantity,
      price: price,
      total: total,
      fee: 0.0,
      status: TransactionStatus.completed,
      timestamp: DateTime.now(),
    );
  }

  /// Cria uma nova transação de venda
  factory Transaction.sell({
    required String userId,
    required String cryptoId,
    required double quantity,
    required double price,
  }) {
    final total = quantity * price;
    return Transaction(
      id: '', // Será gerado pelo Firestore
      userId: userId,
      type: TransactionType.sell,
      cryptoId: cryptoId,
      quantity: quantity,
      price: price,
      total: total,
      fee: 0.0,
      status: TransactionStatus.completed,
      timestamp: DateTime.now(),
    );
  }

  /// Cria uma nova transação de conversão
  factory Transaction.convert({
    required String userId,
    required String fromCryptoId,
    required String toCryptoId,
    required double fromQuantity,
    required double toQuantity,
    required double fromPrice,
    required double toPrice,
  }) {
    final total = fromQuantity * fromPrice;
    final fee = (fromQuantity * (toPrice / fromPrice) - toQuantity) * toPrice;
    
    return Transaction(
      id: '', // Será gerado pelo Firestore
      userId: userId,
      type: TransactionType.convert,
      cryptoId: fromCryptoId,
      quantity: fromQuantity,
      price: fromPrice,
      total: total,
      fee: fee,
      status: TransactionStatus.completed,
      timestamp: DateTime.now(),
      toCryptoId: toCryptoId,
      toQuantity: toQuantity,
      toPrice: toPrice,
    );
  }

  /// Cria uma instância a partir do Firestore
  factory Transaction.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Transaction(
      id: doc.id,
      userId: data['userId'] as String,
      type: TransactionType.fromCode(data['type'] as String),
      cryptoId: data['cryptoId'] as String,
      quantity: (data['quantity'] as num).toDouble(),
      price: (data['price'] as num).toDouble(),
      total: (data['total'] as num).toDouble(),
      fee: (data['fee'] as num?)?.toDouble() ?? 0.0,
      status: TransactionStatus.fromCode(data['status'] as String? ?? 'completed'),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      toCryptoId: data['toCryptoId'] as String?,
      toQuantity: (data['toQuantity'] as num?)?.toDouble(),
      toPrice: (data['toPrice'] as num?)?.toDouble(),
    );
  }

  /// Converte para Firestore
  Map<String, dynamic> toFirestore() {
    final map = {
      'userId': userId,
      'type': type.code,
      'cryptoId': cryptoId,
      'quantity': quantity,
      'price': price,
      'total': total,
      'fee': fee,
      'status': status.code,
      'timestamp': Timestamp.fromDate(timestamp),
    };
    
    // Adiciona campos de conversão se existirem
    if (toCryptoId != null) map['toCryptoId'] = toCryptoId!;
    if (toQuantity != null) map['toQuantity'] = toQuantity!;
    if (toPrice != null) map['toPrice'] = toPrice!;
    
    return map;
  }

  /// Cria uma cópia com campos atualizados
  Transaction copyWith({
    String? id,
    String? userId,
    TransactionType? type,
    String? cryptoId,
    double? quantity,
    double? price,
    double? total,
    double? fee,
    TransactionStatus? status,
    DateTime? timestamp,
    String? toCryptoId,
    double? toQuantity,
    double? toPrice,
  }) {
    return Transaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      cryptoId: cryptoId ?? this.cryptoId,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      total: total ?? this.total,
      fee: fee ?? this.fee,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      toCryptoId: toCryptoId ?? this.toCryptoId,
      toQuantity: toQuantity ?? this.toQuantity,
      toPrice: toPrice ?? this.toPrice,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        cryptoId,
        quantity,
        price,
        total,
        fee,
        status,
        timestamp,
        toCryptoId,
        toQuantity,
        toPrice,
      ];

  @override
  String toString() {
    return 'Transaction(${type.label}: $quantity $cryptoId @ \$$price = \$$total)';
  }
}

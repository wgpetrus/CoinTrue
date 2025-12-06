# 💸 Transações

## Visão Geral

Sistema completo de transações de criptomoedas com validações, cálculo de taxas e preview.

---

## Tipos de Transações

### 1. Compra (Buy)
- Converte BRL em criptomoeda
- Valida saldo disponível
- Calcula taxa (0.5%)
- Atualiza carteira e portfólio

### 2. Venda (Sell)
- Converte criptomoeda em BRL
- Valida quantidade disponível
- Calcula taxa (0.5%)
- Atualiza carteira e portfólio

### 3. Conversão (Convert)
- Troca uma cripto por outra
- Valida quantidade disponível
- Calcula taxa (0.5%)
- Atualiza portfólio

---

## Fluxo de Transação

```
1. Usuário seleciona tipo (Comprar/Vender/Converter)
2. Seleciona criptomoeda
3. Insere valor/quantidade
4. Sistema calcula:
   - Quantidade final
   - Taxa (0.5%)
   - Total
5. Exibe preview
6. Usuário confirma
7. Sistema valida:
   - Saldo suficiente
   - Quantidade disponível
8. Executa transação
9. Atualiza:
   - Carteira
   - Portfólio
   - Histórico
10. Exibe confirmação
```

---

## Implementação

### Model

```dart
enum TransactionType { buy, sell, convert }

class Transaction {
  final String id;
  final String userId;
  final TransactionType type;
  final String cryptoId;
  final double quantity;
  final double price;
  final double total;
  final double fee;
  final DateTime timestamp;
  final String? fromCryptoId; // Para conversão
  final double? fromQuantity; // Para conversão
}
```

### Controller

```dart
class TransactionController extends ChangeNotifier {
  Future<void> buyTransaction({
    required String cryptoId,
    required double amountBRL,
  }) async {
    // 1. Validar saldo
    if (amountBRL > wallet.balance) {
      throw Exception('Saldo insuficiente');
    }
    
    // 2. Calcular
    final price = await _cryptoService.getPrice(cryptoId);
    final fee = amountBRL * 0.005; // 0.5%
    final amountAfterFee = amountBRL - fee;
    final quantity = amountAfterFee / price;
    
    // 3. Criar transação
    final transaction = Transaction(
      type: TransactionType.buy,
      cryptoId: cryptoId,
      quantity: quantity,
      price: price,
      total: amountBRL,
      fee: fee,
      timestamp: DateTime.now(),
    );
    
    // 4. Executar
    await _repository.addTransaction(userId, transaction);
    
    // 5. Atualizar carteira
    await _walletController.removeFunds(amountBRL);
    
    // 6. Atualizar portfólio
    await _portfolioController.addAsset(cryptoId, quantity, price);
    
    notifyListeners();
  }
  
  Future<void> sellTransaction({
    required String cryptoId,
    required double quantity,
  }) async {
    // Similar ao buy, mas inverte operações
  }
  
  Future<void> convertTransaction({
    required String fromCryptoId,
    required String toCryptoId,
    required double fromQuantity,
  }) async {
    // Vende fromCrypto e compra toCrypto
  }
}
```

---

## Cálculos

### Compra

```dart
// Entrada: Valor em BRL
amountBRL = 1000.00
fee = amountBRL * 0.005 = 5.00
amountAfterFee = amountBRL - fee = 995.00
price = 250000.00 (preço do BTC)
quantity = amountAfterFee / price = 0.00398 BTC

// Resultado:
// - Paga: R$ 1000.00
// - Taxa: R$ 5.00
// - Recebe: 0.00398 BTC
```

### Venda

```dart
// Entrada: Quantidade de cripto
quantity = 0.005 BTC
price = 250000.00
totalBRL = quantity * price = 1250.00
fee = totalBRL * 0.005 = 6.25
amountAfterFee = totalBRL - fee = 1243.75

// Resultado:
// - Vende: 0.005 BTC
// - Taxa: R$ 6.25
// - Recebe: R$ 1243.75
```

### Conversão

```dart
// Entrada: Quantidade de cripto origem
fromQuantity = 1.0 ETH
fromPrice = 12000.00
totalBRL = fromQuantity * fromPrice = 12000.00
fee = totalBRL * 0.005 = 60.00
amountAfterFee = totalBRL - fee = 11940.00
toPrice = 250000.00 (BTC)
toQuantity = amountAfterFee / toPrice = 0.04776 BTC

// Resultado:
// - Converte: 1.0 ETH
// - Taxa: R$ 60.00
// - Recebe: 0.04776 BTC
```

---

## Validações

### Antes da Transação

```dart
// Compra
- Saldo >= valor total
- Valor mínimo: R$ 10.00

// Venda
- Quantidade disponível no portfólio
- Quantidade mínima: 0.00001

// Conversão
- Quantidade disponível no portfólio
- Criptos diferentes (from != to)
```

### Durante a Transação

```dart
- Preço atualizado (< 30s)
- Conexão com API ativa
- Firestore disponível
```

---

## Telas

### TransactionScreen

**Componentes**
- Tabs (Comprar/Vender/Converter)
- Seletor de cripto
- Input de valor/quantidade
- Preview de cálculo
- Botão de confirmação

**Estados**
- Idle: Aguardando entrada
- Calculating: Calculando valores
- Preview: Mostrando preview
- Processing: Executando transação
- Success: Transação concluída
- Error: Erro na transação

---

## Histórico

### ActivityScreen

**Funcionalidades**
- Lista de todas as transações
- Filtro por tipo
- Filtro por período
- Detalhes da transação

**Informações Exibidas**
- Tipo (ícone colorido)
- Criptomoeda
- Quantidade
- Valor total
- Taxa
- Data e hora
- Status

---

## Firestore Schema

```
users/{userId}/
  transactions/{transactionId}/
    - type: string (buy, sell, convert)
    - cryptoId: string
    - quantity: number
    - price: number
    - total: number
    - fee: number
    - timestamp: timestamp
    - fromCryptoId: string? (conversão)
    - fromQuantity: number? (conversão)
```

---

## Testes

**Cobertura**
- ✅ Cálculo de taxas
- ✅ Validação de saldo
- ✅ Validação de quantidade
- ✅ Atualização de carteira
- ✅ Atualização de portfólio
- ✅ Criação de transação
- ✅ Tratamento de erros

---

**Última atualização:** 06/12/2025

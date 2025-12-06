# 💰 Carteira e Portfólio

## Visão Geral

Sistema completo de gestão de carteira e portfólio de criptomoedas com cálculo automático de lucro/prejuízo.

---

## Funcionalidades

### Carteira (Wallet)

**Saldo em BRL**
- Visualização do saldo disponível
- Histórico de movimentações
- Depósito/Saque (simulado)

**Gestão**
- Adicionar fundos
- Remover fundos
- Atualização em tempo real

### Portfólio

**Visão Geral**
- Saldo total investido
- Lucro/Prejuízo total
- Variação percentual
- Distribuição de ativos

**Lista de Ativos**
- Criptomoedas no portfólio
- Quantidade de cada cripto
- Valor atual
- Lucro/Prejuízo por ativo
- Variação 24h

---

## Implementação

### Models

```dart
// Wallet
class Wallet {
  final double balance;
  final String currency;
  final DateTime createdAt;
  final DateTime updatedAt;
}

// Portfolio Asset
class PortfolioAsset {
  final String cryptoId;
  final double quantity;
  final double averagePrice;
  final double totalInvested;
  final double currentValue;
  final double profitLoss;
  final double profitLossPercentage;
}
```

### Controller

```dart
class WalletController extends ChangeNotifier {
  Wallet? _wallet;
  
  Future<void> loadWallet(String userId) async {
    _wallet = await _repository.getWallet(userId);
    notifyListeners();
  }
  
  Future<void> addFunds(double amount) async {
    // Adiciona fundos à carteira
  }
}

class PortfolioController extends ChangeNotifier {
  List<PortfolioAsset> _assets = [];
  
  Future<void> loadPortfolio(String userId) async {
    _assets = await _repository.getPortfolioAssets(userId);
    notifyListeners();
  }
}
```

---

## Cálculos

### Lucro/Prejuízo

```dart
// Por ativo
profitLoss = (currentPrice * quantity) - totalInvested

// Percentual
profitLossPercentage = (profitLoss / totalInvested) * 100

// Total do portfólio
totalProfitLoss = sum(allAssets.profitLoss)
```

---

## Telas

### PortfolioScreen
- Saldo total
- Lucro/Prejuízo 24h
- Lista de ativos
- Gráfico de distribuição (futuro)

### WalletScreen (futuro)
- Saldo disponível
- Histórico de movimentações
- Adicionar/Remover fundos

---

## Firestore Schema

```
users/{userId}/
  wallet/
    - balance: number
    - currency: string
    - createdAt: timestamp
    - updatedAt: timestamp
  
  portfolio/{cryptoId}/
    - quantity: number
    - averagePrice: number
    - totalInvested: number
    - lastUpdated: timestamp
```

---

**Última atualização:** 06/12/2025

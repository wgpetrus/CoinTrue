# Design - App CoinTrue

## Arquitetura

### Padrão: MVC + Provider + SOLID

```
lib/
├── models/              # Entidades e DTOs
│   ├── crypto.dart      # Modelo de criptomoeda
│   ├── portfolio.dart   # Modelo de portfólio
│   ├── transaction.dart # Modelo de transação
│   └── market_data.dart # Dados de mercado
├── controllers/         # Lógica de negócio
│   ├── crypto_controller.dart
│   ├── portfolio_controller.dart
│   └── transaction_controller.dart
├── services/            # Serviços externos
│   ├── crypto_api_service.dart
│   └── firestore_service.dart
├── repositories/        # Acesso a dados
│   ├── crypto_repository.dart
│   └── portfolio_repository.dart
├── views/              # Interface do usuário
│   ├── screens/        # Telas completas
│   └── widgets/        # Componentes reutilizáveis
└── utils/              # Utilitários
```

---

## Modelos de Dados

### Crypto (Criptomoeda)
```dart
class Crypto {
  final String id;              // 'bitcoin'
  final String symbol;          // 'BTC'
  final String name;            // 'Bitcoin'
  final double currentPrice;    // 48574.32
  final double priceChange24h;  // 8.24 (percentual)
  final double volume24h;       // 28500000000
  final double marketCap;       // 950000000000
  final double high24h;         // 49200.00
  final double low24h;          // 47800.00
  final String imageUrl;        // URL do ícone
  final DateTime lastUpdated;
}
```

### PortfolioAsset (Ativo no Portfólio)
```dart
class PortfolioAsset {
  final String cryptoId;        // 'bitcoin'
  final double quantity;        // 0.5
  final double avgPrice;        // 45000.00 (preço médio de compra)
  final double totalInvested;   // 22500.00
  final double currentValue;    // 24287.16 (quantity * currentPrice)
  final double profitLoss;      // 1787.16
  final double profitLossPercent; // 7.94
}
```

### Transaction (Transação)
```dart
class Transaction {
  final String id;
  final String userId;
  final TransactionType type;   // buy, sell, swap
  final String cryptoId;
  final double quantity;
  final double price;           // Preço unitário
  final double total;           // Valor total
  final double fee;             // Taxa
  final DateTime timestamp;
  final TransactionStatus status; // pending, completed, failed
}

enum TransactionType { buy, sell, swap }
enum TransactionStatus { pending, completed, failed }
```

### MarketData (Dados de Mercado)
```dart
class MarketData {
  final String cryptoId;
  final List<PricePoint> priceHistory;
  final TimeRange timeRange;    // 1h, 24h, 7d, 1m, 1y, all
}

class PricePoint {
  final DateTime timestamp;
  final double price;
}

enum TimeRange { oneHour, oneDay, sevenDays, oneMonth, oneYear, all }
```

---

## Controllers

### CryptoController
**Responsabilidade:** Gerenciar lista de criptomoedas e preços

**Estado:**
- `List<Crypto> cryptos` - Lista de todas as criptos
- `List<Crypto> favorites` - Criptos favoritas
- `bool isLoading` - Estado de carregamento
- `String? error` - Mensagem de erro
- `DateTime? lastUpdate` - Última atualização

**Métodos:**
- `Future<void> loadCryptos()` - Carrega lista de criptos
- `Future<void> refreshPrices()` - Atualiza preços
- `Future<void> toggleFavorite(String cryptoId)` - Adiciona/remove favorito
- `List<Crypto> searchCryptos(String query)` - Busca criptos
- `List<Crypto> filterCryptos(CryptoFilter filter)` - Filtra (gainers/losers)

### PortfolioController
**Responsabilidade:** Gerenciar portfólio do usuário

**Estado:**
- `List<PortfolioAsset> assets` - Ativos do portfólio
- `double totalValue` - Valor total
- `double totalInvested` - Total investido
- `double profitLoss` - Lucro/prejuízo
- `double profitLossPercent` - Percentual
- `bool isLoading`
- `String? error`

**Métodos:**
- `Future<void> loadPortfolio()` - Carrega portfólio
- `Future<void> updateAssetValue(String cryptoId, double newPrice)` - Atualiza valor
- `PortfolioAsset? getAsset(String cryptoId)` - Busca ativo
- `List<PortfolioAsset> getTopAssets(int count)` - Top ativos

### TransactionController
**Responsabilidade:** Gerenciar transações

**Estado:**
- `List<Transaction> transactions` - Lista de transações
- `bool isProcessing` - Processando transação
- `String? error`

**Métodos:**
- `Future<void> loadTransactions()` - Carrega histórico
- `Future<Transaction> buyAsset(String cryptoId, double quantity)` - Comprar
- `Future<Transaction> sellAsset(String cryptoId, double quantity)` - Vender
- `Future<void> cancelTransaction(String transactionId)` - Cancelar
- `List<Transaction> filterTransactions(TransactionFilter filter)` - Filtrar

---

## Services

### CryptoApiService
**Responsabilidade:** Comunicação com API de criptomoedas

**Interface:**
```dart
abstract class CryptoApiService {
  Future<List<Crypto>> getCryptos({int limit = 50});
  Future<Crypto> getCryptoById(String id);
  Future<MarketData> getMarketData(String id, TimeRange range);
  Future<Map<String, double>> getCurrentPrices(List<String> ids);
}
```

**Implementação:**
- `CoinGeckoApiService` - Usa API do CoinGecko
- `MockCryptoApiService` - Dados mockados para testes

### FirestoreService
**Responsabilidade:** Persistência de dados no Firestore

**Coleções:**
```
users/{userId}/
  ├── portfolio/
  │   └── {cryptoId} → { quantity, avgPrice, totalInvested }
  ├── transactions/
  │   └── {transactionId} → { type, cryptoId, quantity, price, ... }
  └── favorites/
      └── {cryptoId} → { addedAt }
```

**Métodos:**
- `Future<void> savePortfolio(String userId, List<PortfolioAsset> assets)`
- `Future<List<PortfolioAsset>> loadPortfolio(String userId)`
- `Future<void> addTransaction(String userId, Transaction transaction)`
- `Future<List<Transaction>> loadTransactions(String userId)`
- `Future<void> toggleFavorite(String userId, String cryptoId)`
- `Future<List<String>> loadFavorites(String userId)`

---

## Telas (Screens)

### 1. MainScreen (Container com Bottom Nav)
**Arquivo:** `main_screen.dart`

**Componentes:**
- Bottom Navigation Bar (4 abas)
- PageView ou IndexedStack para trocar telas
- Mantém estado de cada aba

**Navegação:**
- Índice 0: DashboardScreen
- Índice 1: PortfolioScreen
- Índice 2: MarketsScreen
- Índice 3: ActivityScreen

### 2. DashboardScreen (Home)
**Arquivo:** `dashboard_screen.dart`

**Seções:**
1. **Header**
   - Avatar do usuário
   - Botão de notificações
   - Botão de configurações

2. **Card de Saldo Total**
   - Valor total do portfólio
   - Variação 24h
   - Botão de visibilidade
   - Background amarelo com gradiente

3. **Cards de Estatísticas** (Row com 2 cards)
   - Lucro 24h (valor + percentual)
   - Total de Ativos (quantidade)

4. **Botões de Ação Rápida** (Row com 3 botões circulares)
   - Enviar (ícone: arrow-up)
   - Receber (ícone: arrow-down)
   - Trocar (ícone: arrows-left-right)

5. **Seção "Principais Criptomoedas"**
   - Título "Principais"
   - Lista horizontal ou vertical de 4-6 criptos
   - Cada item: ícone, nome, preço, variação

**Widgets:**
- `BalanceCard` - Card de saldo
- `StatCard` - Card de estatística
- `ActionButton` - Botão circular de ação
- `CryptoListItem` - Item da lista de criptos

### 3. PortfolioScreen
**Arquivo:** `portfolio_screen.dart`

**Seções:**
1. **Header**
   - Título "Portfólio"
   - Botão de ordenação

2. **Card de Valor Total**
   - Valor total
   - Lucro/prejuízo total
   - Percentual

3. **Gráfico de Distribuição**
   - Donut chart com % de cada ativo
   - Legenda com cores

4. **Lista de Ativos**
   - Cada item: ícone, nome, quantidade, valor, variação
   - Ordenável por valor/nome/variação
   - Tap para ver detalhes

**Widgets:**
- `PortfolioValueCard`
- `DistributionChart`
- `PortfolioAssetItem`

### 4. MarketsScreen
**Arquivo:** `markets_screen.dart`

**Seções:**
1. **Header**
   - Campo de busca
   - Botão de filtro

2. **Filtros** (Chips horizontais)
   - Todos
   - Gainers (maiores altas)
   - Losers (maiores quedas)

3. **Lista de Criptomoedas**
   - Scroll infinito ou paginação
   - Cada item: ícone, nome, símbolo, preço, variação, volume
   - Tap para ver detalhes

**Widgets:**
- `SearchBar`
- `FilterChip`
- `CryptoMarketItem`

### 5. CryptoDetailScreen
**Arquivo:** `crypto_detail_screen.dart`

**Seções:**
1. **Header**
   - Botão voltar
   - Botão favorito
   - Ícone grande da cripto
   - Nome e símbolo
   - Preço atual
   - Variação 24h

2. **Gráfico de Preço**
   - Gráfico de linha interativo
   - Seletor de período (1H, 24H, 7D, 1M, 1A, Tudo)
   - Tooltip ao tocar

3. **Estatísticas** (Grid 2x2)
   - Alta 24h
   - Baixa 24h
   - Volume 24h
   - Market Cap

4. **Botões de Ação** (Row com 2 botões)
   - Comprar (amarelo)
   - Vender (outline)

**Widgets:**
- `CryptoHeader`
- `PriceChart`
- `PeriodSelector`
- `StatGrid`

### 6. TransactionScreen (Compra/Venda)
**Arquivo:** `transaction_screen.dart`

**Seções:**
1. **Header**
   - Botão voltar
   - Título "Comprar [Cripto]" ou "Vender [Cripto]"
   - Toggle Comprar/Vender

2. **Informações da Cripto**
   - Ícone, nome, preço atual

3. **Formulário**
   - Input de quantidade (com botões +/-)
   - Input de valor em BRL
   - Conversão automática entre quantidade e valor
   - Saldo disponível (para venda)

4. **Resumo**
   - Quantidade
   - Preço unitário
   - Taxa (se houver)
   - Total

5. **Botão de Confirmação**
   - "Comprar [valor]" ou "Vender [valor]"
   - Desabilitado se inválido

**Widgets:**
- `TransactionTypeToggle`
- `QuantityInput`
- `TransactionSummary`

### 7. ActivityScreen (Histórico)
**Arquivo:** `activity_screen.dart`

**Seções:**
1. **Header**
   - Título "Atividade"
   - Botão de filtro

2. **Filtros** (Chips horizontais)
   - Todas
   - Compras
   - Vendas
   - Trocas

3. **Lista de Transações**
   - Agrupadas por data
   - Cada item: ícone (tipo), cripto, quantidade, valor, data
   - Cores: verde (compra), vermelho (venda), azul (troca)
   - Tap para ver detalhes

4. **Estado Vazio**
   - Ilustração
   - Texto "Nenhuma transação ainda"
   - Botão "Começar a investir"

**Widgets:**
- `TransactionListItem`
- `TransactionGroupHeader`
- `EmptyState`

### 8. ProfileScreen (Configurações)
**Arquivo:** `profile_screen.dart`

**Seções:**
1. **Header**
   - Avatar grande
   - Nome
   - Email

2. **Seção Segurança**
   - Biometria (toggle)
   - Alterar senha
   - Dispositivos conectados

3. **Seção Preferências**
   - Moeda padrão (BRL, USD, EUR)
   - Notificações (toggle)
   - Tema (futuro)

4. **Seção Sobre**
   - Versão do app
   - Termos de uso
   - Política de privacidade
   - Suporte

5. **Botão Sair**
   - Vermelho, outline

**Widgets:**
- `ProfileHeader`
- `SettingsSection`
- `SettingsItem`

---

## API - Coinbase

### Endpoint Base
```
https://api.coinbase.com/v2/
```

### Autenticação
- API pública (não requer chave para dados de mercado)
- Rate limit: 10,000 requisições/hora

### Endpoints Utilizados

#### 1. Listar Criptomoedas
```
GET /currencies
```
Retorna lista de todas as moedas suportadas.

#### 2. Preços Atuais
```
GET /prices/{currency_pair}/spot
Exemplo: /prices/BTC-USD/spot
```
Retorna preço atual de uma cripto.

#### 3. Preços de Múltiplas Criptos
```
GET /exchange-rates?currency=USD
```
Retorna taxas de câmbio de todas as criptos.

#### 4. Histórico de Preços
```
GET /prices/{currency_pair}/historic?period=day
Períodos: hour, day, week, month, year, all
```
Retorna histórico de preços.

### Modelo de Resposta

**Preço Spot:**
```json
{
  "data": {
    "base": "BTC",
    "currency": "USD",
    "amount": "48574.32"
  }
}
```

**Exchange Rates:**
```json
{
  "data": {
    "currency": "USD",
    "rates": {
      "BTC": "0.000020",
      "ETH": "0.00031",
      "ADA": "0.42"
    }
  }
}
```

### CoinbaseApiService Implementation
```dart
class CoinbaseApiService implements CryptoApiService {
  static const String baseUrl = 'https://api.coinbase.com/v2';
  final http.Client client;
  
  // Cache de preços (5 minutos)
  final Map<String, CachedPrice> _priceCache = {};
  
  Future<List<Crypto>> getCryptos({int limit = 50});
  Future<Crypto> getCryptoById(String id);
  Future<Map<String, double>> getCurrentPrices(List<String> ids);
  Future<MarketData> getMarketData(String id, TimeRange range);
}
```

---

## Widgets Reutilizáveis

### CryptoIcon
**Responsabilidade:** Exibir ícone de criptomoeda

**Props:**
- `String cryptoId` - ID da cripto
- `double size` - Tamanho (padrão: 48)
- `Color? backgroundColor` - Cor de fundo

**Implementação:**
- Círculo colorido com letra inicial
- Cores específicas por cripto (Bitcoin laranja, Ethereum roxo, etc)

### PriceText
**Responsabilidade:** Exibir preço formatado

**Props:**
- `double price` - Valor
- `String currency` - Moeda (BRL, USD)
- `TextStyle? style` - Estilo customizado

**Implementação:**
- Formata com separadores de milhar
- Adiciona símbolo da moeda (R$, $)
- Exemplo: "R$ 48.574,32"

### PercentageChange
**Responsabilidade:** Exibir variação percentual

**Props:**
- `double percentage` - Percentual
- `bool showIcon` - Mostrar seta (padrão: true)
- `double fontSize` - Tamanho da fonte

**Implementação:**
- Verde para positivo, vermelho para negativo
- Seta para cima/baixo
- Sinal + ou -
- Exemplo: "+8.24%" (verde) ou "-2.15%" (vermelho)

### LoadingShimmer
**Responsabilidade:** Skeleton loading

**Props:**
- `double width`
- `double height`
- `BorderRadius? borderRadius`

**Implementação:**
- Animação shimmer da esquerda para direita
- Cor cinza claro (#F5F5F5)

### EmptyState
**Responsabilidade:** Estado vazio

**Props:**
- `String title` - Título
- `String message` - Mensagem
- `IconData icon` - Ícone
- `Widget? action` - Botão de ação (opcional)

**Implementação:**
- Centralizado verticalmente
- Ícone grande (64px)
- Texto explicativo
- Botão de ação (se fornecido)

---

## Fluxos de Navegação

### Fluxo Principal
```
SplashScreen
    ↓
LoginScreen (se não autenticado)
    ↓
MainScreen (Bottom Nav)
    ├── DashboardScreen (índice 0)
    ├── PortfolioScreen (índice 1)
    ├── MarketsScreen (índice 2)
    └── ActivityScreen (índice 3)
```

### Fluxo de Detalhes da Cripto
```
DashboardScreen/MarketsScreen/PortfolioScreen
    ↓ (tap em cripto)
CryptoDetailScreen
    ↓ (tap em Comprar/Vender)
TransactionScreen
    ↓ (confirmação)
TransactionConfirmationDialog
    ↓ (sucesso)
Volta para tela anterior + atualiza portfólio
```

### Fluxo de Configurações
```
DashboardScreen
    ↓ (tap em ícone de configurações)
ProfileScreen
    ↓ (tap em item)
    ├── BiometricSetupScreen (já existe)
    ├── ChangePasswordScreen
    ├── NotificationSettingsScreen
    └── AboutScreen
```

### Fluxo de Busca
```
MarketsScreen
    ↓ (tap em campo de busca)
SearchScreen (fullscreen)
    ↓ (digita)
Filtra resultados em tempo real
    ↓ (tap em resultado)
CryptoDetailScreen
```

---

## Estados e Tratamento de Erros

### Estados de Carregamento
1. **Initial Loading** - Primeira carga
   - Skeleton loading
   - Shimmer effect

2. **Refreshing** - Atualização
   - Pull-to-refresh indicator
   - Mantém dados antigos visíveis

3. **Loading More** - Paginação
   - Spinner no final da lista

### Estados de Erro
1. **Network Error** - Sem internet
   - Ícone de wifi desconectado
   - Mensagem: "Sem conexão com a internet"
   - Botão "Tentar novamente"
   - Usa dados em cache se disponível

2. **API Error** - Erro da API
   - Ícone de erro
   - Mensagem: "Erro ao carregar dados"
   - Botão "Tentar novamente"

3. **Empty State** - Sem dados
   - Ícone apropriado
   - Mensagem explicativa
   - Ação sugerida

### Estados de Sucesso
1. **Transaction Success**
   - Ícone de check verde
   - Mensagem: "Transação realizada com sucesso"
   - Animação de confete (opcional)
   - Auto-fecha após 2 segundos

2. **Update Success**
   - Snackbar verde
   - Mensagem curta
   - Auto-fecha após 2 segundos

---

## Animações

### Transições de Tela
- **Duração:** 300ms
- **Curve:** Curves.easeInOut
- **Tipo:** Slide horizontal (push/pop)

### Entrada de Elementos
- **Cards:** fadeIn + slideY (200ms, delay escalonado)
- **Lista:** fadeIn + slideY por item (150ms cada, delay 50ms)
- **Botões:** fadeIn + scale (200ms)

### Interações
- **Tap em botão:** scale 0.98 (150ms)
- **Tap em card:** scale 0.98 + elevação (150ms)
- **Pull-to-refresh:** Indicador nativo do Flutter

### Gráficos
- **Linha do gráfico:** Desenha da esquerda para direita (800ms)
- **Tooltip:** fadeIn + scale (200ms)

---

## Tela de Configurações (ProfileScreen) - DETALHADO

### Layout Completo

#### 1. Header (Topo)
```
┌─────────────────────────────────────┐
│  [Avatar]  Nome do Usuário          │
│            email@exemplo.com        │
│            [Editar Perfil]          │
└─────────────────────────────────────┘
```

**Componentes:**
- Avatar circular (80x80px) com gradiente amarelo
- Nome em bold, 20px
- Email em cinza médio, 14px
- Botão "Editar Perfil" (outline, pequeno)

#### 2. Seção: Conta
```
┌─────────────────────────────────────┐
│ CONTA                               │
│                                     │
│ [👤] Informações Pessoais      [>] │
│ [📧] Email e Senha             [>] │
│ [🔔] Notificações              [>] │
└─────────────────────────────────────┘
```

**Items:**
- **Informações Pessoais**
  - Navega para: EditProfileScreen
  - Permite editar: nome, telefone, data de nascimento
  
- **Email e Senha**
  - Navega para: SecurityScreen
  - Permite: alterar email, alterar senha, ver dispositivos
  
- **Notificações**
  - Navega para: NotificationSettingsScreen
  - Permite: ativar/desativar notificações por tipo

#### 3. Seção: Segurança
```
┌─────────────────────────────────────┐
│ SEGURANÇA                           │
│                                     │
│ [🔐] Biometria              [Toggle]│
│ [🔑] Autenticação em 2 Fatores [>] │
│ [📱] Dispositivos Conectados   [>] │
└─────────────────────────────────────┘
```

**Items:**
- **Biometria**
  - Toggle inline (já implementado)
  - Ativa/desativa sem navegar
  
- **Autenticação em 2 Fatores** (Futuro)
  - Navega para: TwoFactorScreen
  - Permite configurar 2FA
  
- **Dispositivos Conectados**
  - Navega para: DevicesScreen
  - Lista dispositivos, permite desconectar

#### 4. Seção: Preferências
```
┌─────────────────────────────────────┐
│ PREFERÊNCIAS                        │
│                                     │
│ [💰] Moeda Padrão          BRL  [>]│
│ [🌙] Tema                 Claro [>]│
│ [🌍] Idioma            Português[>]│
└─────────────────────────────────────┘
```

**Items:**
- **Moeda Padrão**
  - Navega para: CurrencySelectionScreen
  - Opções: BRL, USD, EUR
  - Afeta exibição de preços em todo app
  
- **Tema** (Futuro)
  - Navega para: ThemeSelectionScreen
  - Opções: Claro, Escuro, Automático
  
- **Idioma** (Futuro)
  - Navega para: LanguageSelectionScreen
  - Opções: Português, English, Español

#### 5. Seção: Sobre
```
┌─────────────────────────────────────┐
│ SOBRE                               │
│                                     │
│ [📄] Termos de Uso             [>] │
│ [🔒] Política de Privacidade   [>] │
│ [❓] Central de Ajuda          [>] │
│ [📧] Falar com Suporte         [>] │
│ [ℹ️] Versão do App        v1.0.0   │
└─────────────────────────────────────┘
```

**Items:**
- **Termos de Uso**
  - Abre WebView ou PDF
  
- **Política de Privacidade**
  - Abre WebView ou PDF
  
- **Central de Ajuda**
  - Navega para: HelpScreen
  - FAQ e tutoriais
  
- **Falar com Suporte**
  - Abre email ou chat
  
- **Versão do App**
  - Apenas informativo
  - Tap 7x para modo debug (Easter egg)

#### 6. Ações Finais (Bottom)
```
┌─────────────────────────────────────┐
│ [🗑️] Excluir Conta                  │
│                                     │
│ [🚪] Sair                            │
└─────────────────────────────────────┘
```

**Botões:**
- **Excluir Conta**
  - Vermelho, outline
  - Confirmação dupla
  - Requer senha ou biometria
  - (Já implementado na HomeScreen, mover para cá)
  
- **Sair**
  - Vermelho, outline
  - Confirmação simples
  - (Já implementado na HomeScreen, mover para cá)

### Widgets da Tela de Configurações

#### SettingsSection
```dart
class SettingsSection extends StatelessWidget {
  final String title;
  final List<SettingsItem> items;
}
```

#### SettingsItem
```dart
class SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing; // Toggle, chevron, ou texto
  final VoidCallback? onTap;
}
```

#### SettingsToggle
```dart
class SettingsToggle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
}
```

---

## Dados Mockados Iniciais

### Saldo Inicial do Usuário
- Novos usuários recebem R$ 10.000,00 de saldo simulado
- Armazenado em: `users/{userId}/wallet`
```dart
{
  "balance": 10000.00,
  "currency": "BRL",
  "createdAt": Timestamp
}
```

### Criptomoedas Principais (IDs da Coinbase)
```dart
const mainCryptos = [
  'BTC',  // Bitcoin
  'ETH',  // Ethereum
  'ADA',  // Cardano
  'SOL',  // Solana
  'USDT', // Tether
  'BNB',  // Binance Coin
  'XRP',  // Ripple
  'DOGE', // Dogecoin
];
```

---

## Estrutura Firestore Completa

```
users/
  {userId}/
    ├── profile/
    │   ├── displayName: string
    │   ├── email: string
    │   ├── photoUrl: string
    │   ├── phone: string (opcional)
    │   └── birthDate: string (opcional)
    │
    ├── wallet/
    │   ├── balance: number (R$ 10.000,00 inicial)
    │   ├── currency: string ('BRL')
    │   └── updatedAt: timestamp
    │
    ├── portfolio/
    │   └── {cryptoId}/
    │       ├── quantity: number
    │       ├── avgPrice: number
    │       ├── totalInvested: number
    │       └── updatedAt: timestamp
    │
    ├── transactions/
    │   └── {transactionId}/
    │       ├── type: string ('buy'|'sell')
    │       ├── cryptoId: string
    │       ├── quantity: number
    │       ├── price: number
    │       ├── total: number
    │       ├── fee: number
    │       ├── status: string ('completed'|'pending'|'failed')
    │       └── timestamp: timestamp
    │
    ├── favorites/
    │   └── {cryptoId}/
    │       └── addedAt: timestamp
    │
    └── settings/
        ├── currency: string ('BRL'|'USD'|'EUR')
        ├── notifications: boolean
        └── theme: string ('light'|'dark'|'auto')
```

---

## Dependências Necessárias

### pubspec.yaml
```yaml
dependencies:
  # Já existentes
  flutter:
    sdk: flutter
  provider: ^6.1.1
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
  
  # Dependências adicionais
  http: ^1.1.2              # Requisições HTTP para Coinbase API
  fl_chart: ^0.66.0         # Gráficos
  intl: ^0.18.1             # Formatação de números/datas
  cached_network_image: ^3.3.1  # Cache de imagens
  shimmer: ^3.0.0           # Skeleton loading
  pull_to_refresh: ^2.0.0   # Pull to refresh
```

---

## Próximos Passos para Implementação

### Ordem de Desenvolvimento (Tela por Tela)

1. **Preparação**
   - Adicionar dependências
   - Criar estrutura de pastas
   - Criar modelos de dados
   - Implementar CoinbaseApiService

2. **Navegação (MainScreen)**
   - Bottom Navigation Bar
   - Estrutura de navegação
   - Placeholder para cada tela

3. **Dashboard (Fase 1)**
   - Layout básico
   - Card de saldo (mockado)
   - Lista de criptos principais
   - Integração com API da Coinbase

4. **Mercados**
   - Lista completa de criptos
   - Busca
   - Filtros

5. **Detalhes da Cripto**
   - Informações
   - Gráfico de preço
   - Botões de ação

6. **Transações**
   - Formulário de compra/venda
   - Validações
   - Integração com Firestore

7. **Portfólio**
   - Lista de ativos
   - Gráfico de distribuição
   - Estatísticas

8. **Atividade**
   - Lista de transações
   - Filtros
   - Detalhes

9. **Configurações**
   - Perfil
   - Segurança
   - Preferências
   - Sobre

---

## Notas Importantes

### API da Coinbase
- **Não requer chave de API** para dados públicos
- **Rate limit:** 10,000 req/hora (suficiente)
- **Endpoints públicos:** Sim
- **CORS:** Não é problema em apps mobile
- **Documentação:** https://docs.cloud.coinbase.com/sign-in-with-coinbase/docs/api-prices

### Dados Simulados
- Transações são simuladas (não há dinheiro real)
- Saldo inicial de R$ 10.000,00 para testes
- Portfólio é armazenado no Firestore
- Preços são REAIS da API da Coinbase

### Performance
- Cache de 5 minutos para preços
- Lazy loading em listas
- Imagens cacheadas
- Skeleton loading para feedback

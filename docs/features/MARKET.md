# 📈 Mercado de Criptomoedas

## Visão Geral

Sistema de visualização de mercado com 100+ criptomoedas em tempo real via CoinGecko API.

---

## Funcionalidades

### Lista de Criptomoedas

**Dados Exibidos**
- Nome e símbolo
- Preço atual em BRL
- Variação 24h (% e valor)
- Market cap
- Volume 24h
- Ícone/Logo

**Atualização**
- Automática a cada 30 segundos
- Manual via pull-to-refresh
- Cache em memória

### Busca

**Funcionalidades**
- Busca por nome
- Busca por símbolo
- Resultados em tempo real
- Debounce de 300ms

### Filtros

**Opções**
- Todos (padrão)
- Maiores Altas (top gainers 24h)
- Maiores Baixas (top losers 24h)

### Detalhes da Cripto

**Informações**
- Preço atual
- Variação 24h
- Market cap
- Volume 24h
- Máxima/Mínima 24h
- Gráfico de preço
- Botões de ação (Comprar/Vender)

---

## Implementação

### Model

```dart
class Crypto {
  final String id;
  final String symbol;
  final String name;
  final double currentPrice;
  final double priceChange24h;
  final double priceChangePercentage24h;
  final double marketCap;
  final double volume24h;
  final String? image;
}
```

### Controller

```dart
class CryptoController extends ChangeNotifier {
  List<Crypto> _cryptos = [];
  String _filter = 'all';
  String _searchQuery = '';
  
  Future<void> loadCryptos() async {
    _cryptos = await _repository.getCryptos(limit: 100);
    notifyListeners();
  }
  
  void startAutoUpdate() {
    Timer.periodic(Duration(seconds: 30), (_) {
      loadCryptos();
    });
  }
  
  List<Crypto> get filteredCryptos {
    var list = _cryptos;
    
    // Aplicar busca
    if (_searchQuery.isNotEmpty) {
      list = list.where((c) => 
        c.name.toLowerCase().contains(_searchQuery) ||
        c.symbol.toLowerCase().contains(_searchQuery)
      ).toList();
    }
    
    // Aplicar filtro
    if (_filter == 'gainers') {
      list.sort((a, b) => 
        b.priceChangePercentage24h.compareTo(a.priceChangePercentage24h)
      );
      list = list.take(20).toList();
    } else if (_filter == 'losers') {
      list.sort((a, b) => 
        a.priceChangePercentage24h.compareTo(b.priceChangePercentage24h)
      );
      list = list.take(20).toList();
    }
    
    return list;
  }
}
```

### Service (CoinGecko API)

```dart
class CoinGeckoApiService {
  final String baseUrl = 'https://api.coingecko.com/api/v3';
  
  Future<List<Crypto>> getCryptos({int limit = 50}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/coins/markets?vs_currency=brl&per_page=$limit'),
    );
    
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => Crypto.fromJson(json)).toList();
    }
    
    throw Exception('Failed to load cryptos');
  }
  
  Future<Crypto> getCryptoById(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/coins/$id'),
    );
    
    if (response.statusCode == 200) {
      return Crypto.fromJson(json.decode(response.body));
    }
    
    throw Exception('Failed to load crypto');
  }
}
```

---

## Telas

### MarketsScreen
- Lista de criptomoedas
- Barra de busca
- Filtros (chips)
- Pull-to-refresh
- Navegação para detalhes

### CryptoDetailScreen
- Informações detalhadas
- Gráfico de preço
- Estatísticas
- Botões Comprar/Vender

---

## Cache

**Estratégia**
- Cache em memória (List<Crypto>)
- TTL: 30 segundos
- Invalidação automática
- Refresh manual disponível

**Futuro**
- Cache persistente (Hive/SharedPreferences)
- TTL configurável
- Modo offline

---

## Performance

**Otimizações**
- ListView.builder (lazy loading)
- CachedNetworkImage para logos
- Debounce na busca (300ms)
- Atualização em background

---

## API Limits

**CoinGecko Free Tier**
- 50 chamadas/minuto
- Rate limiting implementado
- Retry com backoff exponencial

---

**Última atualização:** 06/12/2025

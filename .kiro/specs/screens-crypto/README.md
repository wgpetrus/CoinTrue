# 📱 Spec Completa - App CoinTrue

## 🎯 Objetivo

Criar um app completo de visualização e gerenciamento de criptomoedas com dados **100% FUNCIONAIS** da API da Coinbase.

---

## 📁 Arquivos da Spec

### 1. requirements.md
**O QUE o sistema deve fazer**
- Requisitos funcionais detalhados
- Requisitos não-funcionais (performance, segurança)
- Priorização por fases
- **API:** Coinbase (https://api.coinbase.com/v2/)

### 2. design.md
**COMO o sistema deve ser construído**
- Arquitetura (MVC + Provider + SOLID)
- Modelos de dados
- Controllers e Services
- Layout de cada tela
- Widgets reutilizáveis
- Estrutura Firestore
- Dependências necessárias

### 3. tasks.md
**QUANDO e EM QUE ORDEM implementar**
- Plano de implementação tela por tela
- 11 fases de desenvolvimento
- Cada task com teste manual
- Ordem de execução clara
- **IMPORTANTE:** Fazer tela por tela, não tudo de uma vez!

---

## 🚀 Como Usar Esta Spec

### Passo 1: Ler os Requisitos
```bash
# Abrir e ler completamente
.kiro/specs/app-crypto/requirements.md
```
- Entender O QUE precisa ser feito
- Ver priorização (Fase 1, 2, 3, 4)
- Entender API da Coinbase

### Passo 2: Estudar o Design
```bash
# Abrir e ler completamente
.kiro/specs/app-crypto/design.md
```
- Entender COMO será construído
- Ver arquitetura e modelos
- Ver layout de cada tela
- Ver estrutura Firestore

### Passo 3: Seguir as Tasks
```bash
# Abrir e seguir passo a passo
.kiro/specs/app-crypto/tasks.md
```
- Começar pela Fase 0 (Preparação)
- Fazer UMA task por vez
- Testar CADA task antes de prosseguir
- NÃO pular fases

---

## ✅ Garantias de Funcionalidade

### 100% Funcional Significa:

#### Dados Reais
- ✅ Preços de criptomoedas: **API da Coinbase**
- ✅ Atualização automática: **A cada 30 segundos**
- ✅ Cache local: **5 minutos**
- ✅ Tratamento de erros: **Completo**

#### Transações Simuladas
- ✅ Saldo inicial: **R$ 10.000,00**
- ✅ Compra/venda: **Funciona**
- ✅ Persistência: **Firestore**
- ✅ Cálculos: **Corretos**

#### Navegação
- ✅ Bottom Nav: **4 abas**
- ✅ Transições: **Suaves**
- ✅ Estado: **Mantido**

#### UI/UX
- ✅ Design: **CoinTrue (amarelo #FFE70F)**
- ✅ Animações: **flutter_animate**
- ✅ Ícones: **Phosphor Icons**
- ✅ Loading: **Skeleton shimmer**

---

## 🔌 API da Coinbase

### Informações Importantes

**Base URL:** `https://api.coinbase.com/v2/`

**Autenticação:** Não requer (dados públicos)

**Rate Limit:** 10.000 requisições/hora

**Endpoints Principais:**
- `GET /currencies` - Lista de moedas
- `GET /prices/{pair}/spot` - Preço atual
- `GET /exchange-rates?currency=USD` - Taxas de câmbio
- `GET /prices/{pair}/historic?period=day` - Histórico

### Quando Precisar da API

**AVISAR O USUÁRIO PARA:**
1. Testar se API está acessível
2. Verificar resposta dos endpoints
3. Confirmar que dados estão corretos

**Comandos de Teste:**
```bash
# Testar moedas
curl https://api.coinbase.com/v2/currencies

# Testar preço Bitcoin
curl https://api.coinbase.com/v2/prices/BTC-USD/spot
```

---

## 📊 Estrutura do App

### Telas Principais

1. **MainScreen** - Container com Bottom Nav
   - Dashboard (Home)
   - Portfólio
   - Mercados
   - Atividade

2. **Dashboard** - Tela inicial
   - Saldo total
   - Cards de estatísticas
   - Botões de ação
   - Lista de criptos principais

3. **Mercados** - Lista completa
   - Busca
   - Filtros (Gainers/Losers)
   - Todas as criptos

4. **CryptoDetail** - Detalhes da cripto
   - Preço e variação
   - Gráfico de preço
   - Estatísticas
   - Botões Comprar/Vender

5. **Transaction** - Compra/Venda
   - Formulário
   - Validações
   - Confirmação
   - Processamento

6. **Portfolio** - Seus ativos
   - Valor total
   - Gráfico de distribuição
   - Lista de ativos

7. **Activity** - Histórico
   - Lista de transações
   - Filtros
   - Detalhes

8. **Profile** - Configurações
   - Informações do usuário
   - Segurança (biometria)
   - Preferências (moeda)
   - Sobre
   - Logout/Excluir conta

---

## 🎨 Design System

### Cores (CoinTrue)
- **Amarelo:** #FFE70F (primária)
- **Amarelo Escuro:** #FFC107 (ícones)
- **Cinza Escuro:** #545454 (textos)
- **Cinza Médio:** #9E9E9E (secundários)
- **Branco:** #FFFFFF (background)
- **Verde:** #4CAF50 (sucesso/compra)
- **Vermelho:** #F44336 (erro/venda)

### Ícones
- **Biblioteca:** Phosphor Icons
- **Tamanhos:** 16px, 20px, 24px
- **Estilo:** Regular (outline)

### Animações
- **Biblioteca:** flutter_animate
- **Duração:** 150ms (interação), 300ms (transição)
- **Curve:** Curves.easeOut

### Tipografia
- **Fonte:** System (San Francisco/Roboto)
- **Títulos:** 24px, Bold
- **Corpo:** 14px, Regular
- **Preços:** 16-36px, Bold

---

## 📦 Dependências Necessárias

```yaml
dependencies:
  # Já existentes
  flutter:
    sdk: flutter
  provider: ^6.1.1
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
  flutter_animate: ^4.5.0
  phosphor_flutter: ^2.1.0
  
  # Novas
  http: ^1.1.2              # API Coinbase
  fl_chart: ^0.66.0         # Gráficos
  intl: ^0.18.1             # Formatação
  cached_network_image: ^3.3.1  # Cache imagens
  shimmer: ^3.0.0           # Skeleton loading
```

---

## 🔥 Estrutura Firestore

```
users/{userId}/
  ├── wallet/
  │   ├── balance: 10000.00
  │   └── currency: "BRL"
  │
  ├── portfolio/
  │   └── {cryptoId}/
  │       ├── quantity: 0.5
  │       ├── avgPrice: 45000.00
  │       └── totalInvested: 22500.00
  │
  ├── transactions/
  │   └── {transactionId}/
  │       ├── type: "buy"
  │       ├── cryptoId: "BTC"
  │       ├── quantity: 0.5
  │       ├── price: 48000.00
  │       ├── total: 24000.00
  │       └── timestamp: Timestamp
  │
  └── favorites/
      └── {cryptoId}/
          └── addedAt: Timestamp
```

---

## 🎯 Próximos Passos

### 1. Começar pela Fase 0 (Preparação)
- Adicionar dependências
- Criar estrutura de pastas
- Criar modelos
- Implementar CoinbaseApiService

### 2. Fazer Tela por Tela
- NÃO fazer tudo de uma vez
- Testar CADA tela antes de prosseguir
- Confirmar funcionalidade 100%

### 3. Avisar Quando Precisar da API
- Testar endpoints
- Verificar resposta
- Confirmar dados corretos

---

## 📝 Notas Importantes

### ✅ O Que Está Pronto
- Sistema de autenticação completo
- 159 testes passando
- Biometria funcionando
- Firestore configurado

### 🔲 O Que Falta
- Todo o app de crypto (8 telas)
- Integração com API Coinbase
- Controllers e Services
- Widgets reutilizáveis

### 🎯 Meta Final
- App 100% funcional
- Dados reais da API
- Transações simuladas funcionando
- UI/UX polida
- Testes completos

---

**Data de Criação:** 3 de dezembro de 2025  
**Versão:** 1.0  
**Status:** Pronto para implementação  
**Método:** Tela por tela, 100% funcional

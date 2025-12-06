# 🚀 CoinTrue

> Aplicativo mobile completo de gestão de criptomoedas

[![Flutter](https://img.shields.io/badge/Flutter-3.32.3-blue.svg)](https://flutter.dev/)
[![Tests](https://img.shields.io/badge/Tests-181%20passing-success.svg)](./docs/testing/TESTING_STRATEGY.md)
[![Status](https://img.shields.io/badge/Status-Production%20Ready-success.svg)](./docs/PROJECT_SUMMARY.md)

---

## 📱 Sobre

Aplicativo mobile para gestão de criptomoedas com autenticação segura, transações em tempo real e portfólio completo.

### Principais Funcionalidades

- 🔐 Autenticação multi-provider (Google, Apple, Email, Biometria)
- 💰 Gestão de carteira e portfólio
- 📈 100+ criptomoedas em tempo real
- 💸 Transações (compra, venda, conversão)
- 📊 Histórico e estatísticas
- 🔔 Notificações personalizáveis

---

## 🏗️ Tecnologias

- **Flutter** 3.32.3 - Framework UI
- **Firebase** - Backend (Auth, Firestore, Cloud Messaging)
- **Provider** - State Management
- **MVC + SOLID** - Arquitetura
- **CoinGecko API** - Preços em tempo real

---

## 🚀 Início Rápido

```bash
# Clone o repositório
git clone [URL_DO_REPOSITORIO]
cd cointrue

# Instale as dependências
flutter pub get

# Execute o app
flutter run

# Execute os testes
flutter test
```

---

## 📚 Documentação

### Essenciais
- [📊 Resumo do Projeto](./docs/PROJECT_SUMMARY.md) - Status e métricas
- [📦 Instalação](./docs/getting-started/INSTALLATION.md) - Setup completo
- [🏗️ Arquitetura](./docs/architecture/OVERVIEW.md) - MVC + SOLID
- [🧪 Testes](./docs/testing/TESTING_STRATEGY.md) - 181 testes

### Funcionalidades
- [🔐 Autenticação](./docs/features/AUTHENTICATION.md) - Login e biometria
- [💰 Carteira](./docs/features/WALLET.md) - Saldo e portfólio
- [📈 Mercado](./docs/features/MARKET.md) - 100+ criptos
- [💸 Transações](./docs/features/TRANSACTIONS.md) - Compra/venda

### Índice Completo
- [📚 Índice da Documentação](./docs/INDEX.md)

---

## 📊 Status do Projeto

| Categoria | Status |
|-----------|--------|
| Desenvolvimento | ✅ Completo |
| Testes | ✅ 181 passando (100%) |
| Arquitetura | ✅ MVC + SOLID |
| Responsividade | ✅ Total |
| Segurança | ✅ Robusta |
| Documentação | ✅ Completa |
| **Produção** | ✅ **PRONTO** |

---

## 🏗️ Arquitetura

O projeto segue o padrão **MVC + SOLID**:

```
View (UI) → Controller (Estado) → Model (Dados)
```

- **MVC:** Padrão arquitetural obrigatório
- **Provider:** State management obrigatório
- **Firebase:** Backend obrigatório
- **SOLID:** Princípios aplicados em todo código

---

## 🧪 Testes

**181 testes automatizados** (100% passando)

```bash
# Todos os testes
flutter test

# Com cobertura
flutter test --coverage

# Testes específicos
flutter test test/controllers/
```

---

## 📁 Estrutura

```
lib/
├── controllers/      # Lógica de apresentação (MVC)
├── models/          # Modelos de dados
├── repositories/    # Acesso a dados
├── services/        # Serviços externos
├── utils/           # Utilitários
└── views/           # Interface do usuário
    ├── screens/     # Telas completas
    └── widgets/     # Componentes

test/                # 181 testes
docs/                # Documentação
```

---

## 🤝 Contribuindo

Leia o [Guia de Contribuição](./CONTRIBUTING.md) antes de enviar um PR.

---

## 📝 Licença

Projeto pessoal - Em desenvolvimento.

---

## 👥 Desenvolvedor

**Petrus**

---

**Desenvolvido com ❤️**

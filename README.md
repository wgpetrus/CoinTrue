# 🪙 CoinTrue

> Aplicativo mobile completo de gestão de criptomoedas com design moderno e funcionalidades avançadas

[![Flutter](https://img.shields.io/badge/Flutter-3.32.3-02569B?logo=flutter)](https://flutter.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-Latest-FFCA28?logo=firebase)](https://firebase.google.com/)
[![Status](https://img.shields.io/badge/Status-Production%20Ready-success)](./docs/STATUS.md)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](./LICENSE)

---

## 📱 Sobre o Projeto

CoinTrue é um aplicativo mobile moderno para gestão de criptomoedas, oferecendo uma experiência completa de acompanhamento de mercado, transações e gerenciamento de portfólio.

### ✨ Principais Funcionalidades

- 🔐 **Autenticação Segura** - Google, Apple, Email e Biometria
- 💰 **Carteira Digital** - Saldo inicial de R$ 10.000 para simulações
- 📈 **Mercado em Tempo Real** - 100+ criptomoedas com preços atualizados
- 💸 **Transações Completas** - Compra, venda e conversão entre criptos
- 📊 **Portfólio Detalhado** - Gráficos, estatísticas e histórico
- ⭐ **Sistema de Favoritos** - Marque suas criptos preferidas
- 🔔 **Notificações Push** - Alertas personalizáveis de preços
- 🎨 **Design Moderno** - Interface intuitiva com animações suaves
- 🌙 **Tema Claro** - Design system consistente

---

## 🏗️ Tecnologias

### Core
- **Flutter 3.32.3** - Framework multiplataforma
- **Dart 3.x** - Linguagem de programação

### Backend & Cloud
- **Firebase Auth** - Autenticação multi-provider
- **Cloud Firestore** - Banco de dados NoSQL
- **Firebase Cloud Messaging** - Notificações push
- **Firebase Storage** - Armazenamento de imagens

### APIs & Integrações
- **CoinGecko API** - Dados de mercado em tempo real
- **Google Sign-In** - Login social
- **Sign in with Apple** - Login Apple
- **Local Auth** - Autenticação biométrica

### Arquitetura & Padrões
- **MVC Pattern** - Separação de responsabilidades
- **Provider** - Gerenciamento de estado
- **Repository Pattern** - Abstração de dados
- **SOLID Principles** - Código limpo e manutenível

### UI/UX
- **Material Design 3** - Design system
- **Phosphor Icons** - Ícones modernos
- **Flutter Animate** - Animações declarativas
- **FL Chart** - Gráficos interativos
- **Cached Network Image** - Cache de imagens

---

## 🚀 Início Rápido

### Pré-requisitos

```bash
Flutter SDK: >=3.32.3
Dart SDK: >=3.5.0
```

### Instalação

```bash
# 1. Clone o repositório
git clone https://github.com/wgpetrus/CoinTrue.git
cd CoinTrue

# 2. Instale as dependências
flutter pub get

# 3. Configure o Firebase
# Adicione seus arquivos de configuração:
# - android/app/google-services.json
# - ios/Runner/GoogleService-Info.plist

# 4. Execute o app
flutter run
```

### Testes

```bash
# Executar todos os testes
flutter test

# Executar testes com cobertura
flutter test --coverage

# Executar testes de integração
flutter test integration_test/
```

---

## 📁 Estrutura do Projeto

```
lib/
├── controllers/          # Lógica de negócio (MVC)
│   ├── auth/            # Autenticação
│   ├── crypto/          # Criptomoedas
│   ├── favorites/       # Favoritos
│   └── notification/    # Notificações
├── models/              # Modelos de dados
│   ├── auth/           # Models de autenticação
│   ├── crypto/         # Models de criptomoedas
│   ├── favorites/      # Models de favoritos
│   └── notification/   # Models de notificações
├── repositories/        # Acesso a dados
│   ├── auth/           # Repositórios de auth
│   ├── crypto/         # Repositórios de crypto
│   ├── favorites/      # Repositórios de favoritos
│   └── notification/   # Repositórios de notificações
├── services/           # Serviços externos
│   ├── auth/          # Serviços de autenticação
│   ├── crypto/        # Serviços de crypto
│   ├── notification/  # Serviços de notificação
│   ├── common/        # Serviços comuns
│   └── profile/       # Serviços de perfil
├── views/             # Interface do usuário
│   ├── screens/      # Telas do app
│   └── widgets/      # Componentes reutilizáveis
└── utils/            # Utilitários e helpers
```

**Padrões de Nomenclatura:**
- Models: `[nome]_model.dart`
- Controllers: `[nome]_controller.dart`
- Services: `[nome]_service.dart`
- Repositories: `[nome]_repository.dart`
- Screens: `[nome]_screen.dart`

---

## 🎨 Design System

### Paleta de Cores

```dart
// Cores Principais
Primary (Amarelo):    #FFE70F  // Botões, destaques
Primary Dark:         #FFC107  // Ícones, variações
White:                #FFFFFF  // Backgrounds
Dark Gray:            #545454  // Textos principais
Medium Gray:          #9E9E9E  // Textos secundários

// Cores de Status
Success (Verde):      #4CAF50  // Compras, positivo
Error (Vermelho):     #F44336  // Vendas, negativo
Info (Azul):          #2196F3  // Informações
```

### Componentes

- **Botões Primários:** Fundo amarelo (#FFE70F) com texto branco
- **Botões Secundários:** Fundo branco com borda e texto escuro
- **Cards:** Border radius 16px, elevação sutil
- **Inputs:** Border radius 16px, fundo cinza claro
- **Ícones:** Phosphor Icons, tamanhos 16/20/24px

---

## 📚 Documentação

### Guias Principais
- 📖 [Documentação Completa](./docs/README.md)
- 🏗️ [Arquitetura](./docs/ARCHITECTURE.md)
- 🎨 [Guia de UI/UX](./docs/UI_GUIDE.md)
- 🧪 [Estratégia de Testes](./docs/TESTING.md)
- 🚀 [Guia de Deploy](./docs/DEPLOY.md)

### Features
- 🔐 [Autenticação](./docs/features/AUTHENTICATION.md)
- 💰 [Carteira](./docs/features/WALLET.md)
- 📈 [Mercado](./docs/features/MARKET.md)
- 💸 [Transações](./docs/features/TRANSACTIONS.md)

---

## 🎯 Status do Projeto

### ✅ Implementado

- [x] Sistema de autenticação completo
- [x] Integração com Firebase
- [x] Mercado de criptomoedas em tempo real
- [x] Sistema de transações (compra/venda/conversão)
- [x] Portfólio com gráficos
- [x] Sistema de favoritos
- [x] Notificações push
- [x] Perfil de usuário
- [x] Onboarding completo
- [x] Autenticação biométrica
- [x] Design system consistente
- [x] Animações e transições
- [x] Testes unitários e integração
- [x] Estrutura 100% organizada

### 📊 Métricas

- **Linhas de Código:** ~15.000+
- **Testes:** 181 passando
- **Cobertura:** >80%
- **Erros de Compilação:** 0
- **Warnings:** 163 (apenas sugestões de estilo)
- **Performance:** Otimizada

---

## 🤝 Contribuindo

Contribuições são bem-vindas! Por favor, leia o [CONTRIBUTING.md](./CONTRIBUTING.md) para detalhes.

### Processo

1. Fork o projeto
2. Crie uma branch (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

---

## 📝 Changelog

Veja [CHANGELOG.md](./CHANGELOG.md) para histórico de versões.

---

## 📄 Licença

Este projeto está sob a licença MIT. Veja [LICENSE](./LICENSE) para mais detalhes.

---

## 👥 Autores

- **Petrus** - *Desenvolvimento Principal* - [@wgpetrus](https://github.com/wgpetrus)

---

## 🙏 Agradecimentos

- CoinGecko pela API de dados de mercado
- Firebase pela infraestrutura
- Flutter pela framework incrível
- Comunidade open source

---

## 📞 Contato

- GitHub: [@wgpetrus](https://github.com/wgpetrus)
- Email: [seu-email@exemplo.com]

---

**Desenvolvido com ❤️ usando Flutter**

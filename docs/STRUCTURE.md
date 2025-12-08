# 🏗️ Estrutura do Projeto

Documentação completa da estrutura de pastas e organização do código.

---

## 📁 Estrutura de Pastas

```
CoinTrue/
├── lib/                          # Código fonte principal
│   ├── controllers/              # Lógica de negócio (MVC)
│   │   ├── auth/                # Controllers de autenticação
│   │   │   └── auth_controller.dart
│   │   ├── crypto/              # Controllers de criptomoedas
│   │   │   ├── crypto_controller.dart
│   │   │   ├── portfolio_controller.dart
│   │   │   ├── transaction_controller.dart
│   │   │   └── wallet_controller.dart
│   │   ├── favorites/           # Controllers de favoritos
│   │   │   └── favorites_controller.dart
│   │   ├── notification/        # Controllers de notificações
│   │   │   └── notification_controller.dart
│   │   └── controllers.dart     # Barrel export
│   │
│   ├── models/                  # Modelos de dados
│   │   ├── auth/               # Models de autenticação
│   │   │   ├── user_model.dart
│   │   │   ├── auth_state_model.dart
│   │   │   ├── biometric_config_model.dart
│   │   │   ├── user_profile_model.dart
│   │   │   └── initialization_state_model.dart
│   │   ├── crypto/             # Models de criptomoedas
│   │   │   ├── crypto_model.dart
│   │   │   ├── wallet_model.dart
│   │   │   ├── transaction_model.dart
│   │   │   └── portfolio_asset_model.dart
│   │   ├── favorites/          # Models de favoritos
│   │   │   └── favorite_crypto_model.dart
│   │   ├── notification/       # Models de notificações
│   │   │   └── notification_preferences_model.dart
│   │   ├── exceptions.dart     # Exceções customizadas
│   │   └── models.dart         # Barrel export
│   │
│   ├── repositories/           # Acesso a dados
│   │   ├── auth/              # Repositórios de autenticação
│   │   │   ├── user_repository.dart
│   │   │   ├── firebase_user_repository.dart
│   │   │   └── user_profile_repository.dart
│   │   ├── crypto/            # Repositórios de criptomoedas
│   │   │   ├── crypto_repository.dart
│   │   │   ├── crypto_repository_impl.dart
│   │   │   ├── wallet_repository.dart
│   │   │   └── wallet_repository_impl.dart
│   │   ├── favorites/         # Repositórios de favoritos
│   │   │   └── favorites_repository.dart
│   │   ├── notification/      # Repositórios de notificações
│   │   │   └── notification_preferences_repository.dart
│   │   └── repositories.dart  # Barrel export
│   │
│   ├── services/              # Serviços externos
│   │   ├── auth/             # Serviços de autenticação
│   │   │   ├── auth_service.dart
│   │   │   ├── firebase_auth_service.dart
│   │   │   ├── biometric_service.dart
│   │   │   └── local_auth_service.dart
│   │   ├── crypto/           # Serviços de criptomoedas
│   │   │   ├── crypto_api_service.dart
│   │   │   ├── coingecko_api_service.dart
│   │   │   └── chart_cache_service.dart
│   │   ├── notification/     # Serviços de notificações
│   │   │   ├── notification_service.dart
│   │   │   └── fcm_service.dart
│   │   ├── common/           # Serviços comuns
│   │   │   ├── preferences_service.dart
│   │   │   ├── shared_preferences_service.dart
│   │   │   ├── exchange_rate_service.dart
│   │   │   └── initialization_service.dart
│   │   ├── profile/          # Serviços de perfil
│   │   │   └── profile_image_service.dart
│   │   └── services.dart     # Barrel export
│   │
│   ├── views/                # Interface do usuário
│   │   ├── screens/         # Telas do aplicativo
│   │   │   ├── auth/       # Telas de autenticação
│   │   │   ├── crypto/     # Telas de criptomoedas
│   │   │   ├── onboarding/ # Telas de onboarding
│   │   │   └── screens.dart
│   │   └── widgets/        # Componentes reutilizáveis
│   │       ├── auth/      # Widgets de autenticação
│   │       ├── common/    # Widgets comuns
│   │       ├── crypto/    # Widgets de criptomoedas
│   │       ├── profile/   # Widgets de perfil
│   │       └── widgets.dart
│   │
│   ├── utils/              # Utilitários
│   │   ├── constants.dart
│   │   ├── formatters.dart
│   │   ├── validators.dart
│   │   ├── error_handler.dart
│   │   ├── platform_helper.dart
│   │   └── ...
│   │
│   ├── core/              # Configurações core
│   │   └── config/
│   │       └── firebase_options.dart
│   │
│   └── main.dart          # Entry point
│
├── test/                  # Testes
│   ├── controllers/      # Testes de controllers
│   ├── models/          # Testes de models
│   ├── repositories/    # Testes de repositories
│   ├── services/        # Testes de services
│   ├── utils/           # Testes de utils
│   └── integration/     # Testes de integração
│
├── assets/              # Assets estáticos
│   └── images/
│       └── logos/
│
├── docs/                # Documentação
│   ├── architecture/
│   ├── features/
│   ├── getting-started/
│   └── testing/
│
├── .kiro/              # Configurações Kiro
│   └── steering/
│       ├── ui-guidelines.md
│       └── animations-icons-guidelines.md
│
├── android/            # Projeto Android
├── ios/                # Projeto iOS
├── web/                # Projeto Web
├── pubspec.yaml        # Dependências
└── README.md           # Documentação principal
```

---

## 🎯 Padrões de Nomenclatura

### Arquivos

| Tipo | Padrão | Exemplo |
|------|--------|---------|
| Model | `[nome]_model.dart` | `user_model.dart` |
| Controller | `[nome]_controller.dart` | `auth_controller.dart` |
| Service | `[nome]_service.dart` | `auth_service.dart` |
| Repository | `[nome]_repository.dart` | `user_repository.dart` |
| Screen | `[nome]_screen.dart` | `login_screen.dart` |
| Widget | `[nome]_widget.dart` ou `[nome].dart` | `loading_overlay.dart` |
| Util | `[nome].dart` | `formatters.dart` |

### Classes

| Tipo | Padrão | Exemplo |
|------|--------|---------|
| Model | `[Nome]` | `class User` |
| Controller | `[Nome]Controller` | `class AuthController` |
| Service | `[Nome]Service` | `class AuthService` |
| Repository | `[Nome]Repository` | `class UserRepository` |
| Screen | `[Nome]Screen` | `class LoginScreen` |
| Widget | `[Nome]Widget` ou `[Nome]` | `class LoadingOverlay` |

---

## 📦 Organização por Domínio

### Domínios Principais

1. **auth** - Autenticação e usuários
2. **crypto** - Criptomoedas e mercado
3. **favorites** - Sistema de favoritos
4. **notification** - Notificações
5. **common** - Funcionalidades comuns
6. **profile** - Perfil do usuário

### Estrutura de um Domínio

Cada domínio segue a mesma estrutura:

```
[dominio]/
├── controllers/
│   └── [dominio]_controller.dart
├── models/
│   └── [dominio]_model.dart
├── repositories/
│   └── [dominio]_repository.dart
└── services/
    └── [dominio]_service.dart
```

---

## 🔄 Barrel Exports

Cada pasta principal tem um arquivo barrel export para simplificar imports:

```dart
// lib/models/models.dart
export 'auth/user_model.dart';
export 'auth/auth_state_model.dart';
// ...

// lib/controllers/controllers.dart
export 'auth/auth_controller.dart';
export 'crypto/crypto_controller.dart';
// ...

// lib/services/services.dart
export 'auth/auth_service.dart';
export 'crypto/crypto_api_service.dart';
// ...
```

### Uso

```dart
// ✅ Recomendado
import 'package:login/models/models.dart';
import 'package:login/controllers/controllers.dart';

// ❌ Evitar
import 'package:login/models/auth/user_model.dart';
import 'package:login/controllers/auth/auth_controller.dart';
```

---

## 🎯 Fluxo de Dados

```
View (Screen/Widget)
    ↓
Controller (Lógica de negócio)
    ↓
Repository (Abstração de dados)
    ↓
Service (API/Firebase/Local)
    ↓
Model (Estrutura de dados)
```

---

## 📝 Convenções

### Imports

Ordem de imports:
1. Dart/Flutter core
2. Packages externos
3. Arquivos do projeto

```dart
// 1. Dart/Flutter
import 'dart:async';
import 'package:flutter/material.dart';

// 2. Packages
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 3. Projeto
import '../models/models.dart';
import '../controllers/controllers.dart';
```

### Comentários

```dart
/// Documentação de classe (três barras)
class MyClass {
  // Comentário de linha única
  
  /* Comentário
     de múltiplas
     linhas */
}
```

---

## ✅ Benefícios da Estrutura

1. **Organização Clara** - Fácil encontrar arquivos
2. **Escalabilidade** - Fácil adicionar novos domínios
3. **Manutenibilidade** - Código organizado e limpo
4. **Testabilidade** - Estrutura facilita testes
5. **Colaboração** - Padrões claros para equipe

---

## 🚀 Como Adicionar Novo Domínio

```bash
# 1. Criar estrutura de pastas
mkdir -p lib/controllers/[dominio]
mkdir -p lib/models/[dominio]
mkdir -p lib/repositories/[dominio]
mkdir -p lib/services/[dominio]

# 2. Criar arquivos
touch lib/models/[dominio]/[nome]_model.dart
touch lib/controllers/[dominio]/[nome]_controller.dart
touch lib/repositories/[dominio]/[nome]_repository.dart
touch lib/services/[dominio]/[nome]_service.dart

# 3. Adicionar exports nos barrels
# Editar lib/models/models.dart
# Editar lib/controllers/controllers.dart
# etc.
```

---

**Estrutura mantida e atualizada regularmente**

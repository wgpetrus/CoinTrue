# 🏗️ Visão Geral da Arquitetura

## Padrão Arquitetural

O projeto segue o padrão **MVC (Model-View-Controller)**, combinado com os princípios **SOLID**.

---

## Diagrama de Alto Nível

```
┌─────────────────────────────────────┐
│            VIEW LAYER               │
│         (lib/views/)                │
│  - Screens (Telas completas)        │
│  - Widgets (Componentes)            │
│  - Apenas UI, sem lógica            │
└──────────────┬──────────────────────┘
               │
               │ User Actions
               ↓
┌─────────────────────────────────────┐
│         CONTROLLER LAYER            │
│       (lib/controllers/)            │
│  - ChangeNotifier                   │
│  - Provider                         │
│  - Gerencia estado                  │
│  - Lógica de apresentação           │
└──────────────┬──────────────────────┘
               │
               │ Business Logic
               ↓
┌─────────────────────────────────────┐
│          MODEL LAYER                │
│  - Models (lib/models/)             │
│  - Services (lib/services/)         │
│  - Repositories (lib/repositories/) │
│  - Dados e regras de negócio        │
└─────────────────────────────────────┘
```

---

## Estrutura de Pastas

```
lib/
├── controllers/      # Lógica de apresentação
├── models/          # Entidades de dados
├── repositories/    # Acesso a dados
├── services/        # Lógica de negócio
├── utils/           # Utilitários
└── views/           # Interface do usuário
    ├── screens/     # Telas completas
    └── widgets/     # Componentes reutilizáveis
```

---

## Camadas

### 1. View Layer (Apresentação)
- **Responsabilidade:** Interface do usuário
- **Tecnologia:** Flutter Widgets
- **Regra:** Apenas UI, sem lógica de negócio

### 2. Controller Layer (Controle)
- **Responsabilidade:** Gerenciar estado e apresentação
- **Tecnologia:** Provider + ChangeNotifier
- **Regra:** Conecta View e Model

### 3. Model Layer (Dados)
- **Responsabilidade:** Dados e regras de negócio
- **Componentes:**
  - Models: Entidades
  - Services: Lógica de negócio
  - Repositories: Acesso a dados

---

## State Management

**Padrão:** Provider (obrigatório pela empresa)

```dart
// Controller
class AuthController extends ChangeNotifier {
  // Estado
  User? _currentUser;
  
  // Getters
  User? get currentUser => _currentUser;
  
  // Métodos
  Future<void> login() async {
    // Lógica
    notifyListeners(); // Notifica views
  }
}

// View
class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    return Text(auth.currentUser?.name ?? 'Guest');
  }
}
```

---

## Backend

**Plataforma:** Firebase (obrigatório pela empresa)

- **Firebase Auth:** Autenticação
- **Firestore:** Banco de dados
- **Cloud Functions:** Lógica serverless
- **Cloud Messaging:** Notificações

---

## Princípios

### SOLID
- ✅ Single Responsibility
- ✅ Open/Closed
- ✅ Liskov Substitution
- ✅ Interface Segregation
- ✅ Dependency Inversion

### Clean Code
- ✅ Nomes descritivos
- ✅ Funções pequenas
- ✅ Comentários úteis
- ✅ Testes automatizados

---

## Fluxo de Dados

```
User Action → View → Controller → Repository → Service → API
                ↑                                          ↓
                └──────────── Response ←──────────────────┘
```

---

## Documentos Relacionados

- [Padrão MVC](./MVC_PATTERN.md)
- [Princípios SOLID](./SOLID_PRINCIPLES.md)
- [State Management](./STATE_MANAGEMENT.md)

---

**Última atualização:** 06/12/2025

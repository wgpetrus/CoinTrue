# Padrões da Empresa

> **IMPORTANTE**: Este arquivo contém os padrões específicos da empresa onde Petrus trabalha.

---

## 🏢 Informações do Projeto

**Nome**: CoinTrue  
**Tecnologia Principal**: Flutter  
**Backend**: Firebase  
**Data de Entrada**: 09/12/2025  

---

## 🎯 Padrão Arquitetural

### **MVC (Model-View-Controller) - OBRIGATÓRIO**

A empresa usa **MVC em todos os projetos**.

```
┌─────────────────────────────────────────────────────┐
│              PADRÃO MVC DA EMPRESA                  │
└─────────────────────────────────────────────────────┘

┌──────────────┐
│     VIEW     │  ← UI (Widgets, Screens)
│  (Flutter)   │
└──────┬───────┘
       │
       │ User Actions
       │
┌──────▼───────┐
│  CONTROLLER  │  ← Lógica de apresentação
│              │    Gerencia estado
│              │    Conecta View e Model
└──────┬───────┘
       │
       │ Business Logic
       │
┌──────▼───────┐
│    MODEL     │  ← Dados e regras de negócio
│              │    Repositories
│              │    Services
└──────────────┘
```

---

## 📁 Estrutura de Pastas (MVC)

### Estrutura Padrão da Empresa

```
lib/
├── models/              # MODEL - Entidades e dados
│   ├── user.dart
│   ├── product.dart
│   └── order.dart
│
├── controllers/         # CONTROLLER - Lógica de apresentação
│   ├── auth_controller.dart
│   ├── product_controller.dart
│   └── order_controller.dart
│
├── views/              # VIEW - Interface do usuário
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── login_screen.dart
│   │   └── product_screen.dart
│   └── widgets/
│       ├── custom_button.dart
│       └── product_card.dart
│
├── services/           # Serviços (API, Database, etc)
│   ├── api_service.dart
│   ├── auth_service.dart
│   └── database_service.dart
│
├── repositories/       # Acesso a dados
│   ├── user_repository.dart
│   └── product_repository.dart
│
├── utils/             # Utilitários
│   ├── constants.dart
│   ├── validators.dart
│   └── helpers.dart
│
└── main.dart
```

---

## 🎨 Implementação MVC em Flutter

### Model (Dados)

```dart
// lib/models/user.dart
class User {
  final String id;
  final String name;
  final String email;
  
  User({
    required this.id,
    required this.name,
    required this.email,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}
```

### Controller (Lógica)

```dart
// lib/controllers/auth_controller.dart
import 'package:flutter/material.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService;
  
  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  AuthController(this._authService);
  
  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _currentUser = await _authService.login(email, password);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    notifyListeners();
  }
}
```

### View (UI)

```dart
// lib/views/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            if (authController.isLoading)
              CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: () {
                  authController.login(
                    _emailController.text,
                    _passwordController.text,
                  );
                },
                child: Text('Entrar'),
              ),
            if (authController.error != null)
              Text(
                authController.error!,
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}
```

---

## 🔧 State Management

### Padrão da Empresa: **Provider**

```dart
// main.dart
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthController(AuthService()),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductController(ProductService()),
        ),
      ],
      child: MyApp(),
    ),
  );
}
```

---

## 🎯 Princípios SOLID (OBRIGATÓRIO)

### A Empresa Aplica SOLID em Todos os Projetos

Os princípios SOLID devem ser seguidos **sempre**, independente da arquitetura MVC.

**Referência completa**: Ver seção 3 de [1_DESIGN_AND_ARCHITECTURE.md](./1_DESIGN_AND_ARCHITECTURE.md)

### Resumo Aplicado ao MVC:

#### 1. Single Responsibility Principle (SRP)
- ✅ **Model**: Apenas dados e serialização
- ✅ **Controller**: Apenas lógica de apresentação e state
- ✅ **View**: Apenas UI
- ✅ **Service**: Apenas lógica de negócio
- ✅ **Repository**: Apenas acesso a dados

```dart
// ✅ BOM - Cada classe tem uma responsabilidade
class UserController extends ChangeNotifier {
  // Apenas gerencia estado e apresentação
}

class UserService {
  // Apenas lógica de negócio
}

class UserRepository {
  // Apenas acesso a dados
}
```

#### 2. Open/Closed Principle (OCP)
- ✅ Use interfaces/abstrações
- ✅ Facilita extensão sem modificar código existente

```dart
// ✅ BOM - Abstração
abstract class AuthService {
  Future<User> login(String email, String password);
}

class FirebaseAuthService implements AuthService {
  // Implementação específica
}

class SupabaseAuthService implements AuthService {
  // Outra implementação - não modifica código existente
}
```

#### 3. Liskov Substitution Principle (LSP)
- ✅ Subclasses devem poder substituir classes base

#### 4. Interface Segregation Principle (ISP)
- ✅ Interfaces pequenas e focadas
- ❌ Não criar interfaces "gordas"

#### 5. Dependency Inversion Principle (DIP)
- ✅ **CRÍTICO**: Controllers dependem de abstrações, não implementações

```dart
// ✅ BOM - Controller depende de abstração
class UserController extends ChangeNotifier {
  final AuthService _authService; // Interface, não implementação
  
  UserController(this._authService);
}

// Injeção no main.dart
MultiProvider(
  providers: [
    Provider<AuthService>(
      create: (_) => FirebaseAuthService(), // Implementação concreta
    ),
    ChangeNotifierProvider(
      create: (context) => UserController(
        context.read<AuthService>(), // Injeta abstração
      ),
    ),
  ],
)
```

### Checklist SOLID

Antes de aprovar código, verifique:

- [ ] Cada classe tem uma única responsabilidade
- [ ] Controllers dependem de interfaces, não implementações
- [ ] Services e Repositories têm interfaces
- [ ] Código é extensível sem modificação
- [ ] Injeção de dependências implementada

---

## � Fireebase (Backend Obrigatório)

### A Partir de 2026: Firebase em Todos os Projetos

**Decisão da empresa**: A partir de 2026, **todos os projetos usarão Firebase**.

**Serviços Firebase a Usar**:
- ✅ **Firebase Auth** - Autenticação
- ✅ **Firestore** - Banco de dados
- ✅ **Cloud Functions** - Backend logic
- ✅ **Cloud Storage** - Arquivos
- ✅ **Analytics** - Métricas
- ✅ **Crashlytics** - Monitoramento

**Estrutura com Firebase**:
```dart
// Services usam Firebase
class AuthServiceImpl implements AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  @override
  Future<User> login(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return User.fromFirebase(credential.user!);
  }
}

// Repositories usam Firestore
class UserRepositoryImpl implements UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  @override
  Future<User> getUser(String id) async {
    final doc = await _firestore.collection('users').doc(id).get();
    return User.fromJson(doc.data()!);
  }
}
```

**Referência Completa**: Ver [5_CLOUD.md](./5_CLOUD.md) seção 1 (Firebase)

---

## 📝 Observações Importantes

### Backend (View não faz sentido)

Nota: **"view em backend não faz muito sentido"**

Isso significa:
- Backend usa **MC** (Model-Controller)
- Não tem camada View (é API, não tem UI)
- Controller = Endpoints/Routes
- Model = Dados e lógica de negócio

**Estrutura Backend**:
```
backend/
├── models/        # Entidades e schemas
├── controllers/   # Endpoints e lógica
├── services/      # Regras de negócio
└── routes/        # Rotas da API
```

---

## ⚠️ Diferenças da Documentação Original

### O Que Muda:

**Documentação Original**:
- ❌ Sugeria Clean Architecture
- ❌ Sugeria MVVM
- ❌ Múltiplas opções

**Padrão da Empresa**:
- ✅ **MVC obrigatório**
- ✅ Provider para state management
- ✅ Estrutura de pastas específica

---

## 🎯 Para o Kiro

### Princípios Gerais

**Estes padrões são ESTRUTURAIS, não limitações**:
- ✅ MVC é a **estrutura base** (como organizar código)
- ✅ Provider é a **ferramenta de state** (como gerenciar estado)
- ✅ SOLID são **princípios** (como escrever bom código)

**Você TEM liberdade para**:
- ✅ Escolher bibliotecas específicas (http, dio, etc)
- ✅ Implementar features de formas diferentes
- ✅ Usar seu conhecimento completo
- ✅ Sugerir soluções modernas/melhores
- ✅ Escolher ferramentas de cache, networking, etc

**Você NÃO tem liberdade para**:
- ❌ Mudar arquitetura (MVC é obrigatório)
- ❌ Mudar state management (Provider é obrigatório)
- ❌ Mudar backend (**Firebase obrigatório a partir de 2026**)
- ❌ Ignorar SOLID

**Exemplo**:
```
✅ PODE: "Vou usar Dio em vez de http porque..."
✅ PODE: "Vou usar Hive para cache local porque..."
✅ PODE: "Vou implementar WebSockets para realtime porque..."

❌ NÃO PODE: "Vou usar Clean Architecture em vez de MVC"
❌ NÃO PODE: "Vou usar BLoC em vez de Provider"
❌ NÃO PODE: "Vou usar Supabase em vez de Firebase"
❌ NÃO PODE: "Vou colocar lógica de negócio na View"
```

---

### Ao Gerar Código:

**SEMPRE use MVC + SOLID** (estrutura base):
```
1. Criar Model (dados) - SRP
2. Criar Interface do Service/Repository - DIP
3. Criar Implementação do Service/Repository - SRP
4. Criar Controller (lógica + state) - SRP + DIP
5. Criar View (UI) - SRP
6. Conectar com Provider (injeção de dependências)
```

**Exemplo de Ordem de Criação**:
```dart
// 1. Model
class User { ... }

// 2. Interface (abstração)
abstract class AuthService {
  Future<User> login(String email, String password);
}

// 3. Implementação
class FirebaseAuthService implements AuthService {
  @override
  Future<User> login(String email, String password) async { ... }
}

// 4. Controller (depende de abstração)
class AuthController extends ChangeNotifier {
  final AuthService _authService; // DIP - depende de interface
  
  AuthController(this._authService);
  
  Future<void> login(String email, String password) async {
    // Usa abstração
    await _authService.login(email, password);
  }
}

// 5. View
class LoginScreen extends StatelessWidget {
  // Usa controller
}

// 6. Provider (main.dart)
MultiProvider(
  providers: [
    Provider<AuthService>(create: (_) => FirebaseAuthService()),
    ChangeNotifierProvider(
      create: (context) => AuthController(context.read<AuthService>()),
    ),
  ],
)
```

**NÃO use**:
- ❌ Clean Architecture
- ❌ MVVM
- ❌ Outras arquiteturas
- ❌ Dependências diretas de implementações (violar DIP)

**A menos que** Petrus diga explicitamente que o projeto específico pode usar outra arquitetura.

---

## 📋 Checklist de Conformidade

Antes de gerar código, verifique:

### Arquitetura MVC
- [ ] Estrutura de pastas segue padrão MVC
- [ ] Models em `lib/models/`
- [ ] Controllers em `lib/controllers/`
- [ ] Views em `lib/views/`
- [ ] Services em `lib/services/`
- [ ] Repositories em `lib/repositories/`

### State Management
- [ ] Usando Provider para state management
- [ ] Controllers estendem ChangeNotifier
- [ ] Views usam context.watch/read
- [ ] Injeção de dependências no main.dart

### SOLID
- [ ] Cada classe tem uma única responsabilidade (SRP)
- [ ] Services e Repositories têm interfaces (DIP)
- [ ] Controllers dependem de abstrações, não implementações (DIP)
- [ ] Código extensível sem modificação (OCP)
- [ ] Interfaces pequenas e focadas (ISP)

---

## 🔄 Atualização

**Última atualização**: 28/11/2025  
**Status**: Confirmado - MVC em todos os projetos

---

*Este arquivo será atualizado conforme mais informações forem obtidas no onboarding*

# 🔐 Autenticação

## Visão Geral

Sistema completo de autenticação com múltiplos provedores, biometria e proteção contra ataques.

---

## Provedores Suportados

### 1. Google Sign-In ✅
- Login com conta Google
- OAuth 2.0
- Criação automática de perfil

### 2. Apple Sign-In ✅
- Login com Apple ID
- Obrigatório para iOS
- Privacidade preservada

### 3. Email/Senha ✅
- Registro de novos usuários
- Login tradicional
- Verificação de email obrigatória
- Recuperação de senha

### 4. Biometria ✅
- Face ID (iOS)
- Touch ID (iOS)
- Fingerprint (Android)
- Configuração opcional

---

## Fluxo de Autenticação

### Login Social (Google/Apple)

```
1. Usuário clica em "Entrar com Google/Apple"
2. Abre tela de autenticação do provedor
3. Usuário autoriza o app
4. Firebase valida o token
5. Sistema verifica se é novo usuário
6. Se novo: cria perfil no Firestore
7. Se existente: carrega perfil
8. Verifica se perfil está completo
9. Se incompleto: redireciona para onboarding
10. Se completo: redireciona para home
```

### Login Email/Senha

```
1. Usuário insere email e senha
2. Sistema valida formato
3. Firebase autentica
4. Se sucesso: carrega perfil
5. Verifica email verificado
6. Se não verificado: solicita verificação
7. Se verificado: redireciona para home
```

### Biometria

```
1. Usuário abre app
2. Sistema detecta biometria configurada
3. Exibe tela de bloqueio biométrico
4. Solicita autenticação (Face ID/Touch ID/Fingerprint)
5. Se sucesso: desbloqueia app
6. Se falha: permite login manual
```

---

## Segurança

### Rate Limiting

Proteção contra força bruta:

- **Máximo:** 5 tentativas
- **Delay progressivo:** 1s, 2s, 4s, 8s, 16s
- **Bloqueio:** 15 minutos após 5 falhas
- **Reset:** Após login bem-sucedido

### Validação

- Email em formato válido
- Senha mínima (futuro: 8 caracteres)
- Sanitização de entrada
- Prevenção XSS/SQL Injection

### Tokens

- JWT tokens seguros
- Refresh automático
- Expiração configurável
- Armazenamento seguro

---

## Implementação

### Controller

```dart
class AuthController extends ChangeNotifier {
  final FirebaseAuthService _authService;
  
  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  
  // Login com Google
  Future<void> loginWithGoogle() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _currentUser = await _authService.signInWithGoogle();
      // Navegar para próxima tela
    } catch (e) {
      _error = ErrorHandler.getUserMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

### Service

```dart
class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  Future<User> signInWithGoogle() async {
    // 1. Iniciar fluxo Google
    final GoogleSignInAccount? googleUser = 
        await GoogleSignIn().signIn();
    
    // 2. Obter credenciais
    final GoogleSignInAuthentication googleAuth = 
        await googleUser!.authentication;
    
    // 3. Criar credencial Firebase
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    
    // 4. Autenticar no Firebase
    final userCredential = 
        await _auth.signInWithCredential(credential);
    
    // 5. Criar/atualizar perfil
    return await _createOrUpdateUser(userCredential.user!);
  }
}
```

---

## Gestão de Sessão

### Verificação Automática

```dart
// Ao abrir o app
Future<void> checkSession() async {
  final user = FirebaseAuth.instance.currentUser;
  
  if (user != null) {
    // Usuário logado
    await _loadUserProfile(user.uid);
    
    if (_userProfile?.profileComplete == true) {
      // Vai para home
      Navigator.pushReplacement(context, HomeScreen());
    } else {
      // Vai para onboarding
      Navigator.pushReplacement(context, OnboardingScreen());
    }
  } else {
    // Vai para login
    Navigator.pushReplacement(context, LoginScreen());
  }
}
```

### Logout

```dart
Future<void> logout() async {
  await FirebaseAuth.instance.signOut();
  await GoogleSignIn().signOut();
  _currentUser = null;
  notifyListeners();
}
```

---

## Testes

### Cobertura

- ✅ Login com Google
- ✅ Login com Apple
- ✅ Login com Email/Senha
- ✅ Logout
- ✅ Verificação de sessão
- ✅ Rate limiting
- ✅ Tratamento de erros
- ✅ Biometria

### Exemplo

```dart
test('Login com Google deve autenticar usuário', () async {
  // Arrange
  final mockService = MockFirebaseAuthService();
  final controller = AuthController(mockService);
  
  when(mockService.signInWithGoogle()).thenAnswer(
    (_) async => User(id: '123', email: 'test@gmail.com'),
  );
  
  // Act
  await controller.loginWithGoogle();
  
  // Assert
  expect(controller.currentUser, isNotNull);
  expect(controller.currentUser?.email, 'test@gmail.com');
});
```

---

## Configuração

### Firebase Console

1. Ativar Authentication
2. Habilitar provedores:
   - Google
   - Apple
   - Email/Password
3. Configurar domínios autorizados
4. Adicionar SHA-1 (Android)
5. Configurar Apple Sign-In (iOS)

### Código

```dart
// main.dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);

// Configurar Google Sign-In
GoogleSignIn(
  scopes: ['email', 'profile'],
);
```

---

## Troubleshooting

### Erro: Google Sign-In não funciona

**Solução:**
1. Verificar SHA-1 no Firebase Console
2. Baixar novo `google-services.json`
3. Rebuild do app

### Erro: Apple Sign-In não aparece

**Solução:**
1. Verificar Bundle ID
2. Configurar Sign in with Apple no Xcode
3. Adicionar capability

### Erro: Email não verificado

**Solução:**
```dart
await user.sendEmailVerification();
```

---

## Documentos Relacionados

- [Onboarding](./ONBOARDING.md)
- [Perfil do Usuário](./USER_PROFILE.md)
- [Segurança](../architecture/SECURITY.md)

---

**Última atualização:** 06/12/2025

# Documento de Design - Sistema de Autenticação

## Visão Geral

O sistema de autenticação será implementado seguindo o padrão **MVC (Model-View-Controller)**, utilizando **Provider** para gerenciamento de estado e aplicando os princípios **SOLID**. O backend será **Firebase Auth**.

O sistema permitirá login social (Google e Apple) com suporte a autenticação biométrica, garantindo segurança, usabilidade e compatibilidade multiplataforma.

### Design Visual

- **Estilo**: Material Design - Clean e moderno
- **Paleta de Cores**:
  - `#FFFFFF` - Backgrounds (light mode inicial)
  - `#545454` - Cinza escuro (textos e elementos secundários)
  - `#FFE70F` - Amarelo (botões primários e destaques)
- **Futuro**: Dark mode planejado

## Arquitetura

### Padrão MVC + Provider + SOLID

```
┌─────────────────────────────────────────────────────────┐
│           ARQUITETURA DO SISTEMA DE AUTENTICAÇÃO        │
└─────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────┐
│                    VIEW (Presentation)                    │
│  ┌────────────────┐  ┌────────────────┐                 │
│  │  LoginScreen   │  │  BiometricSetup│                 │
│  │   (Widgets)    │  │     Screen     │                 │
│  └────────┬───────┘  └────────┬───────┘                 │
│           │                    │                          │
│           └────────┬───────────┘                          │
└────────────────────┼──────────────────────────────────────┘
                     │ User Actions
                     │ context.watch/read
┌────────────────────▼──────────────────────────────────────┐
│                 CONTROLLER (State)                        │
│  ┌──────────────────────────────────────────────────┐   │
│  │         AuthController (ChangeNotifier)          │   │
│  │  - Estado de autenticação                        │   │
│  │  - Loading states                                │   │
│  │  - Gerenciamento de erros                        │   │
│  │  - Coordenação de fluxos                         │   │
│  └──────────────────┬───────────────────────────────┘   │
└─────────────────────┼───────────────────────────────────┘
                      │ Business Logic
                      │ Dependency Injection (DIP)
┌─────────────────────▼───────────────────────────────────┐
│                  MODEL (Data + Logic)                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │   Services   │  │ Repositories │  │   Entities   │ │
│  │  (Interface) │  │  (Interface) │  │    (User)    │ │
│  └──────┬───────┘  └──────┬───────┘  └──────────────┘ │
│         │                  │                            │
│  ┌──────▼───────┐  ┌──────▼───────┐                   │
│  │ Firebase Auth│  │   Biometric  │                   │
│  │   Service    │  │   Service    │                   │
│  │    (Impl)    │  │    (Impl)    │                   │
│  └──────────────┘  └──────────────┘                   │
└────────────────────────────────────────────────────────┘
```

### Estrutura de Pastas

```
lib/
├── models/
│   └── user.dart                    # Entidade User
│
├── services/
│   ├── auth_service.dart            # Interface (abstração)
│   ├── firebase_auth_service.dart   # Implementação Firebase
│   ├── biometric_service.dart       # Interface biometria
│   └── local_auth_service.dart      # Implementação biometria
│
├── repositories/
│   ├── user_repository.dart         # Interface
│   └── firebase_user_repository.dart # Implementação
│
├── controllers/
│   └── auth_controller.dart         # Controller principal
│
├── views/
│   ├── screens/
│   │   ├── login_screen.dart        # Tela de login
│   │   ├── biometric_setup_screen.dart
│   │   └── splash_screen.dart       # Verificação de sessão
│   └── widgets/
│       ├── social_login_button.dart
│       ├── biometric_prompt.dart
│       └── loading_overlay.dart
│
└── utils/
    ├── validators.dart              # Validações
    ├── constants.dart               # Constantes (cores, strings)
    └── secure_storage.dart          # Armazenamento seguro
```

## Componentes e Interfaces

### 1. Model - Entidades

#### User Entity
```dart
class User {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final AuthProvider provider; // google, apple
  final DateTime createdAt;
  final bool isNewUser;
  final bool profileComplete;
  
  User({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.provider,
    required this.createdAt,
    required this.isNewUser,
    this.profileComplete = false,
  });
}

enum AuthProvider { google, apple }
```

### 2. Services - Interfaces (Abstração - DIP)

#### AuthService Interface
```dart
abstract class AuthService {
  // Login social
  Future<User> signInWithGoogle();
  Future<User> signInWithApple();
  
  // Gerenciamento de sessão
  Future<User?> getCurrentUser();
  Future<void> signOut();
  
  // Verificação de estado
  Stream<User?> authStateChanges();
  Future<bool> isAuthenticated();
}
```

#### BiometricService Interface
```dart
abstract class BiometricService {
  // Verificação de suporte
  Future<bool> isAvailable();
  Future<List<BiometricType>> getAvailableBiometrics();
  
  // Autenticação
  Future<bool> authenticate({
    required String reason,
    bool useErrorDialogs = true,
  });
  
  // Gerenciamento de credenciais
  Future<void> saveCredentials(String userId);
  Future<String?> getStoredUserId();
  Future<void> deleteCredentials();
}

enum BiometricType { fingerprint, face, iris }
```

### 3. Repositories - Interfaces

#### UserRepository Interface
```dart
abstract class UserRepository {
  Future<User> createUser(User user);
  Future<User?> getUser(String userId);
  Future<void> updateUser(User user);
  Future<bool> userExists(String userId);
}
```

### 4. Controller - Gerenciamento de Estado

#### AuthController
```dart
class AuthController extends ChangeNotifier {
  final AuthService _authService;
  final BiometricService _biometricService;
  final UserRepository _userRepository;
  
  // Estado
  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _biometricEnabled = false;
  
  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  String? get error => _error;
  bool get biometricEnabled => _biometricEnabled;
  
  // Dependency Injection (DIP)
  AuthController(
    this._authService,
    this._biometricService,
    this._userRepository,
  );
  
  // Métodos públicos
  Future<void> signInWithGoogle();
  Future<void> signInWithApple();
  Future<void> signInWithBiometric();
  Future<void> enableBiometric();
  Future<void> disableBiometric();
  Future<void> signOut();
  Future<void> checkSession();
}
```

## Modelos de Dados

### User Model
- **id**: Identificador único do Firebase
- **email**: Email do usuário
- **displayName**: Nome de exibição (opcional)
- **photoUrl**: URL da foto de perfil (opcional)
- **provider**: Provedor de autenticação (google/apple)
- **createdAt**: Data de criação da conta
- **isNewUser**: Flag indicando se é primeiro login
- **profileComplete**: Flag indicando se completou cadastro adicional

### AuthState
- **currentUser**: Usuário atual ou null
- **isLoading**: Estado de carregamento
- **error**: Mensagem de erro ou null
- **biometricEnabled**: Se biometria está ativada

### BiometricConfig
- **enabled**: Se biometria está configurada
- **userId**: ID do usuário associado
- **lastUsed**: Última vez que foi usada

## Correctness Properties

*Uma propriedade é uma característica ou comportamento que deve ser verdadeiro em todas as execuções válidas de um sistema - essencialmente, uma declaração formal sobre o que o sistema deve fazer. As propriedades servem como ponte entre especificações legíveis por humanos e garantias de correção verificáveis por máquina.*


### Propriedades de Login Social

**Propriedade 1: Fluxo OAuth Google**
*Para qualquer* usuário que seleciona login com Google, o sistema deve iniciar o fluxo OAuth do Google e retornar um usuário autenticado ou erro específico
**Valida: Requisitos 1.1**

**Propriedade 2: Fluxo OAuth Apple**
*Para qualquer* usuário que seleciona login com Apple, o sistema deve iniciar o fluxo OAuth da Apple e retornar um usuário autenticado ou erro específico
**Valida: Requisitos 1.2**

**Propriedade 3: Criação ou recuperação de perfil**
*Para qualquer* login social bem-sucedido, o sistema deve criar um novo perfil se não existir ou recuperar o perfil existente do Firebase Auth
**Valida: Requisitos 1.3**

**Propriedade 4: Mensagens de erro em falhas**
*Para qualquer* falha de login social, o sistema deve exibir uma mensagem de erro específica e apropriada ao tipo de falha
**Valida: Requisitos 1.4**

**Propriedade 5: Detecção e redirecionamento de novo usuário**
*Para qualquer* usuário fazendo login pela primeira vez, o sistema deve criar um registro com flag isNewUser=true e redirecionar para telas de cadastro adicional
**Valida: Requisitos 1.5, 8.1, 8.2, 8.3**

### Propriedades de Autenticação Biométrica

**Propriedade 6: Verificação de suporte biométrico**
*Para qualquer* tentativa de ativar biometria, o sistema deve primeiro verificar se o dispositivo suporta biometria antes de prosseguir
**Valida: Requisitos 2.1**

**Propriedade 7: Solicitação de permissão**
*Para qualquer* dispositivo que suporta biometria, o sistema deve solicitar permissão ao usuário antes de configurar
**Valida: Requisitos 2.2**

**Propriedade 8: Armazenamento seguro de credenciais**
*Para qualquer* configuração bem-sucedida de biometria, as credenciais devem ser armazenadas de forma criptografada no armazenamento seguro do dispositivo
**Valida: Requisitos 2.3, 6.1**

**Propriedade 9: Oferta de login biométrico**
*Para qualquer* retorno ao aplicativo com biometria configurada, o sistema deve oferecer a opção de login por biometria
**Valida: Requisitos 2.4**

**Propriedade 10: Autenticação automática por biometria**
*Para qualquer* verificação biométrica bem-sucedida, o sistema deve autenticar o usuário automaticamente sem solicitar credenciais adicionais
**Valida: Requisitos 2.5**

**Propriedade 11: Round-trip de ativação/desativação de biometria**
*Para qualquer* usuário que ativa e depois desativa biometria, todas as credenciais armazenadas devem ser removidas de forma segura
**Valida: Requisitos 10.3**

### Propriedades de Gerenciamento de Sessão

**Propriedade 12: Criação de token válido**
*Para qualquer* login bem-sucedido, o sistema deve criar um token de sessão válido com assinatura e expiração corretas
**Valida: Requisitos 3.1, 6.5**

**Propriedade 13: Verificação de sessão ao reabrir**
*Para qualquer* reabertura do aplicativo, o sistema deve verificar a existência e validade do token de sessão antes de decidir o fluxo
**Valida: Requisitos 3.2**

**Propriedade 14: Restauração automática de sessão**
*Para qualquer* token de sessão válido encontrado, o sistema deve restaurar a sessão do usuário automaticamente sem solicitar nova autenticação
**Valida: Requisitos 3.3**

**Propriedade 15: Solicitação de reautenticação em expiração**
*Para qualquer* token de sessão expirado, o sistema deve solicitar nova autenticação ao usuário
**Valida: Requisitos 3.4**

**Propriedade 16: Limpeza completa no logout**
*Para qualquer* operação de logout, o sistema deve invalidar o token de sessão e limpar todos os dados de autenticação e dados sensíveis da memória e armazenamento
**Valida: Requisitos 3.5, 6.3**

### Propriedades de Validação

**Propriedade 17: Validação antes de processamento**
*Para qualquer* entrada de dados do usuário, o sistema deve validar o formato antes de processar ou enviar para o backend
**Valida: Requisitos 4.1**

**Propriedade 18: Mensagens de erro para entradas inválidas**
*Para qualquer* entrada inválida, o sistema deve exibir mensagem de erro específica e clara sobre o problema
**Valida: Requisitos 4.2**

**Propriedade 19: Validação de formato de email**
*Para qualquer* email fornecido, o sistema deve validar o formato e rejeitar emails inválidos com mensagem apropriada
**Valida: Requisitos 4.3**

**Propriedade 20: Prevenção de envio com campos vazios**
*Para qualquer* formulário com campos obrigatórios vazios, o sistema deve impedir o envio e destacar visualmente os campos que precisam ser preenchidos
**Valida: Requisitos 4.4**

### Propriedades de Tratamento de Erros

**Propriedade 21: Mensagem de erro de rede**
*Para qualquer* erro de rede durante autenticação, o sistema deve exibir mensagem informando problema de conexão
**Valida: Requisitos 5.1**

**Propriedade 22: Mensagem segura para credenciais inválidas**
*Para qualquer* tentativa com credenciais inválidas, o sistema deve exibir mensagem genérica sem revelar se o email existe ou se a senha está incorreta
**Valida: Requisitos 5.2**

**Propriedade 23: Mensagem de serviço indisponível**
*Para qualquer* indisponibilidade do Firebase, o sistema deve informar que o serviço está temporariamente indisponível
**Valida: Requisitos 5.3**

**Propriedade 24: Opção de retry em timeout**
*Para qualquer* timeout de requisição, o sistema deve permitir que o usuário tente novamente
**Valida: Requisitos 5.4**

**Propriedade 25: Tratamento de erros inesperados**
*Para qualquer* erro inesperado, o sistema deve registrar o erro em logs e exibir mensagem genérica amigável ao usuário
**Valida: Requisitos 5.5**

### Propriedades de Segurança

**Propriedade 26: Uso exclusivo de HTTPS**
*Para qualquer* transmissão de tokens ou credenciais, o sistema deve usar conexões HTTPS exclusivamente
**Valida: Requisitos 6.2**

**Propriedade 27: Delay progressivo em falhas**
*Para qualquer* sequência de múltiplas tentativas de login falhas, o sistema deve implementar delay progressivo entre tentativas para prevenir brute force
**Valida: Requisitos 6.4**

### Propriedades de Estados de Carregamento

**Propriedade 28: Indicador de carregamento em operações**
*Para qualquer* operação de autenticação iniciada, o sistema deve exibir indicador de carregamento imediatamente
**Valida: Requisitos 7.1**

**Propriedade 29: Desabilitação de botões durante processamento**
*Para qualquer* processo de autenticação em andamento, o sistema deve desabilitar botões de ação para prevenir múltiplas submissões
**Valida: Requisitos 7.2**

**Propriedade 30: Remoção de indicador ao concluir**
*Para qualquer* operação concluída (sucesso ou erro), o sistema deve remover o indicador de carregamento
**Valida: Requisitos 7.3**

**Propriedade 31: Cancelamento e restauração de estado**
*Para qualquer* operação em andamento que o usuário cancela, o sistema deve permitir o cancelamento e restaurar o estado anterior
**Valida: Requisitos 7.5**

### Propriedades de Navegação

**Propriedade 32: Redirecionamento de usuário existente**
*Para qualquer* usuário existente com perfil completo que faz login, o sistema deve redirecionar para a tela principal do aplicativo
**Valida: Requisitos 8.4**

**Propriedade 33: Redirecionamento de perfil incompleto**
*Para qualquer* usuário com perfil incompleto que faz login, o sistema deve redirecionar para completar cadastro
**Valida: Requisitos 8.5**

### Propriedades de Compatibilidade

**Propriedade 34: Fallback sem biometria**
*Para qualquer* dispositivo sem suporte a biometria, o sistema deve funcionar completamente apenas com login social
**Valida: Requisitos 9.3**

**Propriedade 35: Adaptação de funcionalidades**
*Para qualquer* versão de sistema operacional, o sistema deve adaptar as funcionalidades disponíveis de acordo com as capacidades da plataforma
**Valida: Requisitos 9.5**

### Propriedades de Persistência

**Propriedade 36: Salvamento de preferências**
*Para qualquer* ativação de biometria, o sistema deve salvar essa preferência localmente de forma persistente
**Valida: Requisitos 10.1**

**Propriedade 37: Aplicação imediata de mudanças**
*Para qualquer* alteração de preferências, o sistema deve aplicar as mudanças imediatamente sem necessidade de reiniciar o aplicativo
**Valida: Requisitos 10.4**

## Tratamento de Erros

### Categorias de Erros

#### 1. Erros de Rede
- **NetworkException**: Sem conexão com internet
- **TimeoutException**: Requisição excedeu tempo limite
- **ServerException**: Servidor retornou erro 5xx

**Tratamento**:
- Exibir mensagem clara ao usuário
- Oferecer opção de tentar novamente
- Não expor detalhes técnicos

#### 2. Erros de Autenticação
- **InvalidCredentialsException**: Credenciais inválidas
- **UserNotFoundException**: Usuário não encontrado
- **AccountDisabledException**: Conta desabilitada

**Tratamento**:
- Mensagens genéricas para não vazar informações
- Não revelar se email existe ou não
- Implementar rate limiting

#### 3. Erros de Biometria
- **BiometricNotAvailableException**: Dispositivo não suporta
- **BiometricNotEnrolledException**: Usuário não configurou no dispositivo
- **BiometricAuthFailedException**: Falha na verificação

**Tratamento**:
- Oferecer fallback para login social
- Explicar como configurar biometria no dispositivo
- Limitar tentativas

#### 4. Erros de Validação
- **ValidationException**: Dados inválidos
- **EmptyFieldException**: Campos obrigatórios vazios
- **InvalidEmailException**: Email em formato inválido

**Tratamento**:
- Validação em tempo real
- Mensagens específicas por campo
- Destacar campos com erro

### Estratégia de Logging

```dart
// Níveis de log
enum LogLevel { debug, info, warning, error, critical }

// Informações a registrar
- Timestamp
- Nível de severidade
- Mensagem
- Stack trace (para erros)
- User ID (se disponível)
- Contexto da operação
```

**Importante**: Nunca registrar dados sensíveis (senhas, tokens completos, dados biométricos)

## Estratégia de Testes

### Testes Unitários

Os testes unitários verificarão exemplos específicos e casos de borda:

#### Services
- Testar cada método de AuthService com mocks do Firebase
- Testar BiometricService com diferentes configurações de dispositivo
- Testar casos de sucesso e falha

#### Controllers
- Testar mudanças de estado
- Testar notificações aos listeners
- Testar tratamento de erros

#### Validators
- Testar validação de email com exemplos válidos e inválidos
- Testar sanitização de entrada
- Testar campos obrigatórios

#### Exemplos de Testes Unitários:
```dart
test('deve validar email corretamente', () {
  expect(Validators.isValidEmail('test@example.com'), true);
  expect(Validators.isValidEmail('invalid'), false);
});

test('deve criar usuário com dados do OAuth', () async {
  final user = await authService.signInWithGoogle();
  expect(user.provider, AuthProvider.google);
  expect(user.email, isNotEmpty);
});
```

### Testes Baseados em Propriedades (Property-Based Testing)

Os testes baseados em propriedades verificarão que as propriedades universais se mantêm verdadeiras em todas as execuções.

**Framework**: Utilizaremos **faker** para geração de dados aleatórios e **test** package do Dart para estrutura de testes.

**Configuração**: Cada teste de propriedade executará no mínimo **100 iterações** com dados aleatórios.

**Formato de Anotação**: Cada teste de propriedade será anotado com:
```dart
// Feature: autenticacao-cripto, Property X: [descrição da propriedade]
```

#### Exemplos de Testes de Propriedade:

**Propriedade 16: Limpeza completa no logout**
```dart
// Feature: autenticacao-cripto, Property 16: Limpeza completa no logout
test('para qualquer usuário autenticado, logout deve limpar todos os dados', () async {
  for (int i = 0; i < 100; i++) {
    // Arrange: criar usuário aleatório e fazer login
    final user = generateRandomUser();
    await authController.signInWithGoogle();
    
    // Act: fazer logout
    await authController.signOut();
    
    // Assert: verificar que tudo foi limpo
    expect(authController.currentUser, isNull);
    expect(await secureStorage.read(key: 'token'), isNull);
    expect(await secureStorage.read(key: 'userId'), isNull);
  }
});
```

**Propriedade 19: Validação de formato de email**
```dart
// Feature: autenticacao-cripto, Property 19: Validação de formato de email
test('para qualquer email inválido, sistema deve rejeitar', () {
  final invalidEmails = generateInvalidEmails(100);
  
  for (final email in invalidEmails) {
    expect(Validators.isValidEmail(email), false);
  }
});
```

**Propriedade 11: Round-trip de biometria**
```dart
// Feature: autenticacao-cripto, Property 11: Round-trip de ativação/desativação
test('ativar e desativar biometria deve remover credenciais', () async {
  for (int i = 0; i < 100; i++) {
    // Arrange: usuário aleatório
    final userId = generateRandomUserId();
    
    // Act: ativar biometria
    await biometricService.saveCredentials(userId);
    expect(await biometricService.getStoredUserId(), userId);
    
    // Act: desativar biometria
    await biometricService.deleteCredentials();
    
    // Assert: credenciais removidas
    expect(await biometricService.getStoredUserId(), isNull);
  }
});
```

### Testes de Integração

- Testar fluxo completo de login com Google (usando Firebase Test Lab)
- Testar fluxo completo de login com Apple
- Testar configuração e uso de biometria
- Testar persistência de sessão

### Casos de Borda (Edge Cases)

Casos específicos que serão testados:

1. **Três falhas de biometria**: Verificar fallback para login manual
2. **Reinstalação do app**: Verificar solicitação de reconfiguração
3. **Troca de dispositivo**: Verificar solicitação de nova configuração
4. **Operação demorada (>3s)**: Verificar mensagem de processamento
5. **Caracteres maliciosos**: Verificar sanitização

### Cobertura de Testes

**Meta de cobertura**:
- Services: 90%+
- Controllers: 85%+
- Validators: 95%+
- Models: 80%+

## Fluxos de Interação

### Fluxo 1: Primeiro Login com Google

```
1. Usuário abre o app
2. Sistema exibe tela de login
3. Usuário toca em "Continuar com Google"
4. Sistema inicia OAuth do Google
5. Usuário autentica no Google
6. Sistema recebe credenciais
7. Sistema verifica se usuário existe no Firebase
8. Usuário não existe → Sistema cria novo registro
9. Sistema marca isNewUser = true
10. Sistema redireciona para telas de cadastro adicional
```

### Fluxo 2: Login Existente com Biometria

```
1. Usuário abre o app
2. Sistema verifica sessão existente
3. Sessão expirada
4. Sistema detecta biometria configurada
5. Sistema exibe prompt de biometria
6. Usuário autentica com biometria
7. Sistema recupera credenciais armazenadas
8. Sistema autentica no Firebase
9. Sistema restaura sessão
10. Sistema redireciona para tela principal
```

### Fluxo 3: Configuração de Biometria

```
1. Usuário está autenticado
2. Usuário acessa configurações
3. Usuário ativa "Login com Biometria"
4. Sistema verifica suporte do dispositivo
5. Dispositivo suporta biometria
6. Sistema solicita permissão
7. Usuário concede permissão
8. Sistema solicita autenticação biométrica
9. Usuário autentica
10. Sistema armazena credenciais de forma segura
11. Sistema salva preferência
12. Sistema exibe confirmação
```

### Fluxo 4: Tratamento de Erro de Rede

```
1. Usuário tenta fazer login
2. Sistema inicia processo
3. Sistema exibe loading
4. Requisição falha (sem internet)
5. Sistema detecta NetworkException
6. Sistema remove loading
7. Sistema exibe mensagem: "Verifique sua conexão"
8. Sistema exibe botão "Tentar Novamente"
9. Usuário toca em "Tentar Novamente"
10. Sistema reinicia processo
```

## Considerações de Segurança

### Armazenamento Seguro

**Flutter Secure Storage** será usado para:
- Tokens de sessão
- User ID para biometria
- Preferências sensíveis

**Características**:
- Criptografia AES-256
- Keychain no iOS
- KeyStore no Android
- Isolado por aplicativo

### Comunicação Segura

- **HTTPS obrigatório** para todas as requisições
- **Certificate pinning** (futuro)
- **Validação de certificados SSL**

### Proteção contra Ataques

#### Brute Force
- Delay progressivo: 1s, 2s, 4s, 8s...
- Limite de tentativas por período
- Bloqueio temporário após muitas falhas

#### Man-in-the-Middle
- HTTPS exclusivo
- Validação de certificados
- Não aceitar certificados auto-assinados em produção

#### Injection
- Sanitização de todas as entradas
- Validação de formato
- Escape de caracteres especiais

### Compliance

- **LGPD**: Consentimento para armazenamento de dados biométricos
- **GDPR**: Direito ao esquecimento (deletar dados)
- **PCI-DSS**: Não armazenar dados de pagamento (futuro)

## Dependências

### Packages Flutter

```yaml
dependencies:
  # Firebase
  firebase_core: ^2.24.0
  firebase_auth: ^4.15.0
  
  # Login Social
  google_sign_in: ^6.1.5
  sign_in_with_apple: ^5.0.0
  
  # Biometria
  local_auth: ^2.1.7
  
  # Armazenamento Seguro
  flutter_secure_storage: ^9.0.0
  
  # State Management
  provider: ^6.1.1
  
  # Utilitários
  equatable: ^2.0.5
  
dev_dependencies:
  # Testes
  flutter_test:
    sdk: flutter
  mockito: ^5.4.3
  faker: ^2.1.0
  integration_test:
    sdk: flutter
```

### Configurações Necessárias

#### Android (android/app/build.gradle)
```gradle
android {
    defaultConfig {
        minSdkVersion 23 // Para biometria
    }
}
```

#### iOS (ios/Runner/Info.plist)
```xml
<key>NSFaceIDUsageDescription</key>
<string>Usamos Face ID para login rápido e seguro</string>
```

#### Firebase
- Configurar projeto no Firebase Console
- Adicionar google-services.json (Android)
- Adicionar GoogleService-Info.plist (iOS)
- Habilitar Google e Apple como provedores de autenticação

## Métricas e Monitoramento

### Métricas de Sucesso

- **Taxa de sucesso de login**: > 95%
- **Tempo médio de login**: < 3 segundos
- **Taxa de adoção de biometria**: > 60%
- **Taxa de erro**: < 2%

### Eventos a Monitorar

- `login_success` - Login bem-sucedido
- `login_failure` - Falha no login
- `biometric_enabled` - Biometria ativada
- `biometric_auth_success` - Autenticação biométrica bem-sucedida
- `biometric_auth_failure` - Falha na biometria
- `session_restored` - Sessão restaurada
- `logout` - Logout realizado

### Alertas

- Taxa de erro > 5% em 5 minutos
- Tempo de resposta > 5 segundos
- Taxa de falha de biometria > 20%

## Roadmap Futuro

### Fase 2 (Futuro)
- Dark mode
- Login com email/senha (opcional)
- Autenticação de dois fatores (2FA)
- Recuperação de senha
- Biometria para transações

### Fase 3 (Futuro)
- Login com outras redes sociais (Facebook, Twitter)
- Single Sign-On (SSO) corporativo
- Autenticação sem senha (Passkeys)
- Reconhecimento facial avançado

## Conclusão

Este design fornece uma base sólida para o sistema de autenticação da plataforma de criptomoedas, seguindo os padrões MVC + Provider + SOLID, com foco em segurança, usabilidade e compatibilidade multiplataforma. As 37 propriedades de correção definidas garantem que o sistema seja testável e verificável em todas as suas funcionalidades críticas.

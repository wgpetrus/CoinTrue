# Plano de Implementação - Sistema de Autenticação

## Visão Geral

Este plano implementa o sistema de autenticação seguindo o padrão **MVC + Provider + SOLID**, com Firebase Auth como backend. A implementação será incremental, testando funcionalidades core primeiro antes de adicionar features avançadas.

### Diálogos no chat de cada task
Os diálogos no chat de cada task (Resumos, dialogos em geral) devem ser escritos em PORTUGUES DO BRASIL.

### Logos ja implementadas nas pasta
Você pode usar as logos, ja foram inseridas na pasta -> assets/images/logo

---

## Tasks

- [x] 1. Configurar projeto e estrutura base





  - Criar estrutura de pastas MVC (models/, controllers/, views/, services/, repositories/, utils/)
  - Configurar Firebase no projeto (Android, iOS, Web)
  - Adicionar dependências no pubspec.yaml (firebase_auth, google_sign_in, sign_in_with_apple, local_auth, flutter_secure_storage, provider)
  - Criar pasta de assets para logos (assets/images/logos/)
  - Criar arquivos fictícios para logos: logo_app.png, logo_google.png, logo_apple.png, logo_biometric.png
  - Configurar permissões de biometria no AndroidManifest.xml e Info.plist
  - Criar arquivo de constantes (utils/constants.dart) com cores (#FFFFFF, #545454, #FFE70F)
  - _Requisitos: Todos_

- [x] 2. Implementar camada Model (Entidades e DTOs)




  - [x] 2.1 Criar entidade User


    - Implementar classe User com todos os campos (id, email, displayName, photoUrl, provider, createdAt, isNewUser, profileComplete)
    - Implementar enum AuthProvider (google, apple)
    - Implementar métodos toJson() e fromJson()
    - Implementar método fromFirebase() para converter FirebaseUser
    - Implementar Equatable para comparação
    - _Requisitos: 1.3, 1.5, 8.1, 8.2_

  - [x] 2.2 Criar modelos de estado


    - Implementar AuthState com estados (authenticated, unauthenticated, loading, error)
    - Implementar BiometricConfig para configurações de biometria
    - Implementar classes de exceções customizadas (NetworkException, AuthException, BiometricException, ValidationException)
    - _Requisitos: 5.1, 5.2, 5.3_

- [x] 3. Implementar camada Service (Interfaces e Implementações)




  - [x] 3.1 Criar interface AuthService


    - Definir métodos abstratos: signInWithGoogle(), signInWithApple(), getCurrentUser(), signOut(), authStateChanges(), isAuthenticated()
    - Documentar cada método com comentários
    - _Requisitos: 1.1, 1.2, 3.5_

  - [x] 3.2 Implementar FirebaseAuthService


    - Implementar signInWithGoogle() usando google_sign_in e firebase_auth
    - Implementar signInWithApple() usando sign_in_with_apple
    - Implementar getCurrentUser() para recuperar usuário atual
    - Implementar signOut() com limpeza de dados
    - Implementar authStateChanges() como Stream
    - Implementar tratamento de erros específicos (NetworkException, InvalidCredentialsException)
    - Implementar detecção de novo usuário (verificar se existe no Firestore)
    - _Requisitos: 1.1, 1.2, 1.3, 1.4, 1.5, 3.1, 3.5, 5.1, 5.2, 5.3_

  - [x] 3.3 Escrever teste de propriedade para FirebaseAuthService
















    - **Propriedade 3: Criação ou recuperação de perfil**
    - **Valida: Requisitos 1.3**
-

  - [x] 3.4 Escrever teste de propriedade para detecção de novo usuário





    - **Propriedade 5: Detecção e redirecionamento de novo usuário**
    - **Valida: Requisitos 1.5, 8.1, 8.2**

  - [x] 3.5 Criar interface BiometricService


    - Definir métodos abstratos: isAvailable(), getAvailableBiometrics(), authenticate(), saveCredentials(), getStoredUserId(), deleteCredentials()
    - Definir enum BiometricType (fingerprint, face, iris)
    - _Requisitos: 2.1, 2.2, 2.3_

  - [x] 3.6 Implementar LocalAuthService (biometria)


    - Implementar isAvailable() usando local_auth
    - Implementar getAvailableBiometrics() para listar tipos disponíveis
    - Implementar authenticate() com mensagens customizadas
    - Implementar saveCredentials() usando flutter_secure_storage
    - Implementar getStoredUserId() para recuperar credenciais
    - Implementar deleteCredentials() para remover dados
    - Implementar tratamento de erros (BiometricNotAvailableException, BiometricAuthFailedException)
    - Implementar contador de tentativas (máximo 3)
    - _Requisitos: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 6.1_
-

  - [x] 3.7 Escrever teste de propriedade para verificação de suporte





    - **Propriedade 6: Verificação de suporte biométrico**
    - **Valida: Requisitos 2.1**

-
-

  - [x] 3.8 Escrever teste de propriedade para round-trip de biometria










    - **Propriedade 11: Round-trip de ativação/desativação de biometria**
    - **Valida: Requisitos 10.3**

- [x] 4. Implementar camada Repository




  - [x] 4.1 Criar interface UserRepository


    - Definir métodos abstratos: createUser(), getUser(), updateUser(), userExists()
    - _Requisitos: 1.5, 8.2_

  - [x] 4.2 Implementar FirebaseUserRepository


    - Implementar createUser() para salvar no Firestore
    - Implementar getUser() para buscar por ID
    - Implementar updateUser() para atualizar dados
    - Implementar userExists() para verificar existência
    - Implementar tratamento de erros
    - _Requisitos: 1.5, 8.2, 8.3, 8.4, 8.5_

  - [x] 4.3 Escrever testes unitários para UserRepository






    - Testar criação de usuário
    - Testar recuperação de usuário
    - Testar atualização de usuário
    - Testar verificação de existência
    - _Requisitos: 1.5, 8.2_

- [x] 5. Implementar Validators e Utilitários




  - [x] 5.1 Criar classe Validators


    - Implementar isValidEmail() com regex
    - Implementar isNotEmpty() para campos obrigatórios
    - Implementar sanitizeInput() para remover caracteres maliciosos
    - Implementar validatePassword() (para futuro)
    - _Requisitos: 4.1, 4.2, 4.3, 4.4, 4.5_

  - [x] 5.2 Escrever teste de propriedade para validação de email








    - **Propriedade 19: Validação de formato de email**
    - **Valida: Requisitos 4.3**

  - [x] 5.3 Criar classe SecureStorage (wrapper)


    - Implementar métodos write(), read(), delete(), deleteAll()
    - Encapsular flutter_secure_storage
    - Implementar tratamento de erros
    - _Requisitos: 6.1, 6.3_

  - [x] 5.4 Criar classe Constants

    - Definir cores (AppColors.white, AppColors.darkGray, AppColors.yellow)
    - Definir strings de UI (títulos, mensagens de erro)
    - Definir configurações (timeout, max tentativas)
    - _Requisitos: Todos_

- [x] 6. Implementar Controller (Gerenciamento de Estado)




  - [x] 6.1 Criar AuthController




    - Estender ChangeNotifier
    - Implementar dependency injection (AuthService, BiometricService, UserRepository)
    - Implementar estado privado (_currentUser, _isLoading, _error, _biometricEnabled)
    - Implementar getters públicos
    - Implementar método signInWithGoogle() com loading e error handling
    - Implementar método signInWithApple() com loading e error handling
    - Implementar método signInWithBiometric() com verificação de disponibilidade
    - Implementar método enableBiometric() com solicitação de permissão
    - Implementar método disableBiometric() com limpeza de credenciais
    - Implementar método signOut() com limpeza completa
    - Implementar método checkSession() para verificar token ao iniciar app
    - Implementar método _handleNewUser() para detectar e redirecionar novos usuários
    - Implementar delay progressivo em falhas de login (1s, 2s, 4s, 8s)
    - Implementar notifyListeners() em todas as mudanças de estado
    - _Requisitos: 1.1, 1.2, 1.5, 2.1, 2.2, 2.3, 2.4, 2.5, 3.1, 3.2, 3.3, 3.4, 3.5, 6.4, 7.1, 7.2, 7.3, 8.1, 8.2, 8.3, 8.4, 8.5_

  - [x] 6.2 Escrever teste de propriedade para limpeza no logout






    - **Propriedade 16: Limpeza completa no logout**
    - **Valida: Requisitos 3.5, 6.3**

  - [x] 6.3 Escrever teste de propriedade para criação de token






    - **Propriedade 12: Criação de token válido**
    - **Valida: Requisitos 3.1, 6.5**

  - [x] 6.4 Escrever teste de propriedade para restauração de sessão






    - **Propriedade 14: Restauração automática de sessão**
    - **Valida: Requisitos 3.3**

  - [x] 6.5 Escrever testes unitários para AuthController






    - Testar mudanças de estado (loading, error, success)
    - Testar notificação de listeners
    - Testar tratamento de erros
    - Usar mocks para services
    - _Requisitos: Todos do controller_

- [x] 7. Checkpoint - Garantir que lógica core está funcionando





  - Garantir que todos os testes passam, perguntar ao usuário se surgem dúvidas.

- [x] 8. Implementar Views - Widgets Reutilizáveis





  - [x] 8.1 Criar SocialLoginButton widget


    - Implementar botão customizado com logo, texto e cor
    - Aceitar parâmetros: provider (google/apple), onPressed, isLoading
    - Aplicar Material Design com cores da empresa
    - Implementar estado de loading (desabilitar botão, mostrar spinner)
    - Implementar estado de disabled
    - _Requisitos: 1.1, 1.2, 7.1, 7.2_



  - [x] 8.2 Criar LoadingOverlay widget

    - Implementar overlay semi-transparente com spinner
    - Aceitar parâmetro: isLoading
    - Bloquear interações quando ativo

    - _Requisitos: 7.1, 7.2, 7.3_

  - [x] 8.3 Criar BiometricPrompt widget

    - Implementar card com ícone de biometria e texto explicativo
    - Aceitar parâmetros: onAuthenticate, onSkip
    - Aplicar design clean e moderno
    - _Requisitos: 2.4, 2.5_

  - [x] 8.4 Criar ErrorMessage widget


    - Implementar widget para exibir mensagens de erro
    - Aceitar parâmetros: message, onRetry
    - Aplicar cores e estilo apropriados
    - _Requisitos: 5.1, 5.2, 5.3, 5.4, 5.5_

- [x] 9. Implementar Views - Telas Principais




  - [x] 9.1 Criar SplashScreen


    - Implementar tela inicial com logo da empresa
    - Implementar verificação de sessão ao iniciar (chamar checkSession())
    - Implementar navegação automática baseada em estado:
      - Se autenticado e perfil completo → HomeScreen (futura)
      - Se autenticado e perfil incompleto → OnboardingScreen (futura)
      - Se não autenticado → LoginScreen
    - Implementar loading indicator
    - Aplicar cores da empresa (#FFFFFF background, #FFE70F logo)
    - _Requisitos: 3.2, 3.3, 3.4, 8.4, 8.5_

  - [x] 9.2 Escrever teste de propriedade para verificação de sessão





    - **Propriedade 13: Verificação de sessão ao reabrir**
    - **Valida: Requisitos 3.2**



  - [x] 9.3 Criar LoginScreen




    - Implementar UI com Material Design clean e moderno
    - Adicionar logo da empresa no topo
    - Adicionar título "Bem-vindo" e subtítulo
    - Adicionar SocialLoginButton para Google
    - Adicionar SocialLoginButton para Apple
    - Adicionar BiometricPrompt se biometria estiver configurada
    - Implementar context.watch<AuthController>() para observar estado
    - Implementar navegação baseada em estado do controller
    - Implementar exibição de ErrorMessage quando houver erro
    - Implementar LoadingOverlay quando isLoading
    - Aplicar cores da empresa (#FFFFFF background, #545454 textos, #FFE70F botões)
    - Implementar responsividade (mobile e tablet)
    - _Requisitos: 1.1, 1.2, 1.4, 2.4, 5.1, 5.2, 5.3, 7.1, 7.2, 7.3_

  - [x] 9.4 Escrever teste de propriedade para indicadores de loading






    - **Propriedade 28: Indicador de carregamento em operações**
    - **Valida: Requisitos 7.1**

  - [x] 9.5 Escrever teste de propriedade para desabilitação de botões






    - **Propriedade 29: Desabilitação de botões durante processamento**


    - **Valida: Requisitos 7.2**

  - [x] 9.6 Criar BiometricSetupScreen




    - Implementar UI explicativa sobre biometria
    - Adicionar ilustração/ícone de biometria
    - Adicionar texto explicando benefícios
    - Adicionar botão "Ativar Biometria" (cor #FFE70F)
    - Adicionar botão "Agora Não" (texto #545454)
    - Implementar chamada para enableBiometric() do controller
    - Implementar navegação após configuração
    - Implementar tratamento de erros (dispositivo não suporta, usuário não configurou)
    - Aplicar Material Design clean
    - _Requisitos: 2.1, 2.2, 2.3, 10.1_

  - [x] 9.7 Escrever teste de propriedade para armazenamento de credenciais






    - **Propriedade 8: Armazenamento seguro de credenciais**
    - **Valida: Requisitos 2.3, 6.1**

- [x] 10. Implementar Navegação e Injeção de Dependências





  - [x] 10.1 Configurar Provider no main.dart

    - Implementar MultiProvider com todos os providers
    - Criar Provider<AuthService> com FirebaseAuthService
    - Criar Provider<BiometricService> com LocalAuthService
    - Criar Provider<UserRepository> com FirebaseUserRepository
    - Criar ChangeNotifierProvider<AuthController> com injeção de dependências
    - Aplicar princípio DIP (Dependency Inversion Principle)
    - _Requisitos: Todos_


  - [x] 10.2 Configurar rotas e navegação

    - Implementar MaterialApp com rotas nomeadas
    - Definir rota inicial como SplashScreen
    - Definir rotas: /login, /biometric-setup, /home (futura), /onboarding (futura)
    - Implementar navegação condicional baseada em AuthController
    - _Requisitos: 8.3, 8.4, 8.5_

  - [x] 10.3 Implementar tema global


    - Criar ThemeData com cores da empresa
    - Definir primaryColor como #FFE70F
    - Definir backgroundColor como #FFFFFF
    - Definir textTheme com cor #545454
    - Definir buttonTheme com Material Design
    - Aplicar tema no MaterialApp
    - _Requisitos: Todos (UI)_

- [x] 11. Implementar Tratamento de Erros Global




  - [x] 11.1 Criar ErrorHandler utility


    - Implementar método handleError() que recebe Exception
    - Implementar mapeamento de exceções para mensagens de usuário
    - Implementar logging de erros (sem dados sensíveis)
    - Implementar diferentes níveis de severidade
    - _Requisitos: 5.1, 5.2, 5.3, 5.4, 5.5_

  - [x] 11.2 Escrever testes unitários para ErrorHandler






    - Testar mapeamento de NetworkException
    - Testar mapeamento de AuthException
    - Testar mapeamento de BiometricException
    - Testar mapeamento de exceções genéricas
    - _Requisitos: 5.1, 5.2, 5.3, 5.4, 5.5_

- [x] 12. Implementar Funcionalidades de Segurança





  - [x] 12.1 Implementar validação HTTPS


    - Configurar HttpClient para aceitar apenas HTTPS
    - Implementar verificação de certificados
    - Implementar tratamento de erros de certificado
    - _Requisitos: 6.2_

  - [x] 12.2 Escrever teste de propriedade para uso de HTTPS






    - **Propriedade 26: Uso exclusivo de HTTPS**
    - **Valida: Requisitos 6.2**

  - [x] 12.3 Implementar rate limiting


    - Implementar contador de tentativas de login
    - Implementar delay progressivo (1s, 2s, 4s, 8s, 16s)
    - Implementar bloqueio temporário após muitas falhas
    - Armazenar estado de rate limiting localmente
    - _Requisitos: 6.4_

  - [x] 12.4 Escrever teste de propriedade para delay progressivo
    - **Propriedade 27: Delay progressivo em falhas**
    - **Valida: Requisitos 6.4**
    - Implementado 12 testes completos para RateLimiter
    - Testa delays progressivos (1s, 2s, 4s, 8s, 16s)
    - Testa bloqueio após maxAttempts
    - Testa reset após sucesso
    - Testa expiração de bloqueio
    - Testa persistência de estado

- [x] 13. Implementar Compatibilidade Multiplataforma



  - [x] 13.1 Testar e ajustar para Android


    - Verificar login com Google funciona
    - Verificar biometria (impressão digital) funciona
    - Ajustar UI para diferentes tamanhos de tela
    - Testar em diferentes versões do Android (API 23+)
    - _Requisitos: 9.1, 9.5_

  - [x] 13.2 Testar e ajustar para iOS


    - Verificar login com Apple funciona
    - Verificar Face ID e Touch ID funcionam
    - Ajustar UI para diferentes tamanhos de iPhone/iPad
    - Testar em diferentes versões do iOS
    - _Requisitos: 9.2, 9.5_

  - [x] 13.3 Implementar fallback para plataformas sem biometria


    - Detectar se plataforma suporta biometria
    - Ocultar opções de biometria se não suportado
    - Garantir que login social funciona sem biometria
    - _Requisitos: 9.3, 9.4_

  - [ ]* 13.4 Escrever teste de propriedade para fallback
    - **Propriedade 34: Fallback sem biometria**
    - **Valida: Requisitos 9.3**

- [x] 14. Implementar Persistência de Preferências





  - [x] 14.1 Criar PreferencesService


    - Implementar usando SharedPreferences
    - Implementar métodos: saveBiometricEnabled(), isBiometricEnabled(), clear()
    - Implementar métodos para outras preferências futuras
    - _Requisitos: 10.1, 10.3, 10.4_


  - [x] 14.2 Integrar PreferencesService no AuthController

    - Salvar preferência ao ativar biometria
    - Carregar preferência ao iniciar app
    - Limpar preferências ao desativar biometria
    - Aplicar mudanças imediatamente
    - _Requisitos: 10.1, 10.3, 10.4_

  - [ ]* 14.3 Escrever teste de propriedade para salvamento de preferências
    - **Propriedade 36: Salvamento de preferências**
    - **Valida: Requisitos 10.1**

  - [ ]* 14.4 Escrever teste de propriedade para aplicação imediata
    - **Propriedade 37: Aplicação imediata de mudanças**
    - **Valida: Requisitos 10.4**

- [x] 15. Checkpoint Final - Garantir que tudo está funcionando




  - Garantir que todos os testes passam, perguntar ao usuário se surgem dúvidas.

- [ ] 16. Testes de Integração e Validação Final

  - [ ]* 16.1 Escrever teste de integração para fluxo completo de login com Google
    - Simular login com Google do início ao fim
    - Verificar criação de usuário no Firebase
    - Verificar navegação correta
    - _Requisitos: 1.1, 1.3, 1.5_

  - [ ]* 16.2 Escrever teste de integração para fluxo completo de login com Apple
    - Simular login com Apple do início ao fim
    - Verificar criação de usuário no Firebase
    - Verificar navegação correta
    - _Requisitos: 1.2, 1.3, 1.5_

  - [ ]* 16.3 Escrever teste de integração para configuração e uso de biometria
    - Simular configuração de biometria
    - Simular logout
    - Simular login com biometria
    - Verificar fluxo completo
    - _Requisitos: 2.1, 2.2, 2.3, 2.4, 2.5_

  - [ ]* 16.4 Escrever teste de integração para persistência de sessão
    - Simular login
    - Simular fechamento do app
    - Simular reabertura do app
    - Verificar que sessão foi restaurada
    - _Requisitos: 3.1, 3.2, 3.3_

  - [x] 16.5 Validar cobertura de testes



    - Executar coverage report
    - Verificar se atingiu metas (Services 90%+, Controllers 85%+, Validators 95%+)
    - Identificar gaps de cobertura
    - Adicionar testes para áreas não cobertas
    - _Requisitos: Todos_

- [ ] 17. Documentação e Preparação para Entrega
  - [ ] 17.1 Criar README.md do módulo de autenticação
    - Documentar arquitetura MVC implementada
    - Documentar como usar o AuthController
    - Documentar como adicionar novos provedores de autenticação
    - Documentar configurações necessárias (Firebase, OAuth)
    - Incluir exemplos de código
    - _Requisitos: Todos_

  - [ ] 17.2 Documentar APIs e interfaces
    - Adicionar dartdoc comments em todas as classes públicas
    - Documentar parâmetros e retornos
    - Adicionar exemplos de uso
    - Gerar documentação HTML
    - _Requisitos: Todos_

  - [ ] 17.3 Criar guia de troubleshooting
    - Documentar problemas comuns e soluções
    - Documentar erros de configuração do Firebase
    - Documentar problemas de biometria
    - Documentar problemas de OAuth
    - _Requisitos: Todos_

---

## Notas Importantes

### Estrutura de Assets

A pasta `assets/images/logos/` conterá arquivos fictícios que serão substituídos pelas logos reais:
- `logo_app.png` - Logo principal do aplicativo (usar no SplashScreen e LoginScreen)
- `logo_google.png` - Logo do Google (usar no botão de login)
- `logo_apple.png` - Logo da Apple (usar no botão de login)
- `logo_biometric.png` - Ícone de biometria (usar no BiometricPrompt e BiometricSetupScreen)

### Ordem de Implementação

A ordem das tasks foi planejada para:
1. Estabelecer fundação (Models, Services, Repositories)
2. Implementar lógica de negócio (Controller)
3. Implementar UI (Views)
4. Integrar tudo (Navegação, DI)
5. Adicionar segurança e polish
6. Testar e validar

### Princípios SOLID Aplicados

- **SRP**: Cada classe tem uma única responsabilidade
- **OCP**: Interfaces permitem extensão sem modificação
- **LSP**: Implementações podem substituir interfaces
- **ISP**: Interfaces pequenas e focadas
- **DIP**: Controller depende de abstrações, não implementações

### Testes

- Tasks marcadas com `*` são opcionais (testes)
- Testes de propriedade executam 100+ iterações
- Cada teste de propriedade é anotado com: `// Feature: autenticacao-cripto, Property X: [descrição]`
- Checkpoints garantem que funcionalidades core estão funcionando antes de prosseguir

### Próximos Passos Após Conclusão

Após completar este módulo de autenticação, os próximos módulos serão:
1. Onboarding e cadastro de dados adicionais
2. Tela principal (Home) da plataforma
3. Funcionalidades de criptomoedas (carteira, trading, etc.)
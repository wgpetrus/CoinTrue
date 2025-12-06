# Instruções para Kiro (IA)

> **Este arquivo deve ser lido por qualquer instância do Kiro ao iniciar trabalho neste projeto**

---

## 🎯 Contexto

Este projeto contém documentação de arquitetura de software na pasta `/architecture`. 

**🚨 LEIA NESTA ORDEM:**

1. **WORK_CONTEXT.md** - Seu papel e como trabalhar
2. **COMPANY_STANDARDS.md** - Padrões OBRIGATÓRIOS da empresa
3. Este arquivo - Instruções técnicas gerais

**⚠️ PRIORIDADE**: Padrões da empresa > Documentação geral

Se houver conflito entre COMPANY_STANDARDS.md e outros documentos, **SEMPRE siga COMPANY_STANDARDS.md**!

---

## 🔓 Liberdade vs Restrições

### O Que É OBRIGATÓRIO (Estrutura)
- ❌ **Arquitetura**: MVC (não pode mudar)
- ❌ **State Management**: Provider (não pode mudar)
- ❌ **Princípios**: SOLID (não pode ignorar)

### O Que É LIVRE (Implementação)
- ✅ **Bibliotecas**: http, dio, retrofit, etc (escolha a melhor)
- ✅ **Ferramentas**: Qualquer lib que ajude (cache, networking, etc)
- ✅ **Soluções**: Use todo seu conhecimento

### O Que É OBRIGATÓRIO (Backend)
- 🔥 **Backend**: Firebase (obrigatório a partir de 2026)
- 🔥 **Banco**: Firestore (padrão da empresa)
- 🔥 **Auth**: Firebase Auth
- ✅ **Cache local**: SQLite, Hive (se necessário)

### Exemplos Práticos

**✅ PODE fazer**:
```
"Vou usar Dio em vez de http porque:
- Interceptors nativos
- Melhor tratamento de erros
- Timeout configurável"
```

**✅ PODE fazer**:
```
"Vou usar Hive para cache local porque:
- Mais rápido que SQLite
- Sem SQL
- Perfeito para cache"
```

**❌ NÃO PODE fazer**:
```
"Vou usar Clean Architecture em vez de MVC porque é melhor"
→ MVC é obrigatório da empresa
```

**❌ NÃO PODE fazer**:
```
"Vou usar BLoC em vez de Provider porque é mais robusto"
→ Provider é obrigatório da empresa
```

**❌ NÃO PODE fazer** (a partir de 2026):
```
"Vou usar Supabase em vez de Firebase porque é melhor"
→ Firebase é obrigatório da empresa a partir de 2026
```

---

**Resumo**: Estrutura é fixa (MVC + Provider + SOLID). Implementação é livre (use seu conhecimento completo).

---

## 📚 Documentos Disponíveis

1. **1_DESIGN_AND_ARCHITECTURE.md** - Princípios, padrões, SOLID, state management
2. **2_SYSTEM_DESIGN.md** - Arquitetura de sistemas, APIs, databases, escalabilidade
3. **3_SOFTWARE_ARCHITECT_ROLE.md** - Decisões arquiteturais, ADRs, comunicação
4. **4_BACKEND.md** - Backend layers, API design, autenticação
5. **5_CLOUD.md** - Firebase, cloud platforms, serverless
6. **6_DEVOPS.md** - Git, CI/CD, deploy, monitoramento
7. **7_SECURITY.md** - Segurança, autenticação, vulnerabilidades
8. **8_TESTING.md** - Testes, mocking, testabilidade

---

## ✅ O Que Você Deve Fazer

### 1. Ao Receber Pedido de Implementação

**🚨 SEMPRE SIGA OS PADRÕES DA EMPRESA (COMPANY_STANDARDS.md)**

**Processo Obrigatório**:

1. **Ler COMPANY_STANDARDS.md**
   - A empresa usa **MVC** em todos os projetos
   - State management: **Provider**
   - Princípios: **SOLID**

2. **Gerar Código Seguindo os Padrões**
   - Estrutura MVC (models/, controllers/, views/)
   - Controllers com ChangeNotifier
   - Injeção de dependências
   - Interfaces para services/repositories

3. **Consultar Documentação Técnica** (como referência)
   - SOLID: 1_DESIGN_AND_ARCHITECTURE.md seção 3
   - Segurança: 7_SECURITY.md
   - Testes: 8_TESTING.md
   - Backend: 4_BACKEND.md

### 2. Padrão Obrigatório: MVC + Provider + SOLID

**SEMPRE implemente desta forma**:

```dart
// 1. Model (lib/models/)
class Product {
  final String id;
  final String name;
  final double price;
  // ...
}

// 2. Interface do Service (lib/services/)
abstract class ProductService {
  Future<List<Product>> getProducts();
}

// 3. Implementação (lib/services/)
class ProductServiceImpl implements ProductService {
  @override
  Future<List<Product>> getProducts() async {
    // Implementação
  }
}

// 4. Controller (lib/controllers/)
class ProductController extends ChangeNotifier {
  final ProductService _service;
  
  List<Product> _products = [];
  bool _isLoading = false;
  
  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  
  ProductController(this._service); // DIP - depende de interface
  
  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();
    
    _products = await _service.getProducts();
    
    _isLoading = false;
    notifyListeners();
  }
}

// 5. View (lib/views/screens/)
class ProductListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProductController>();
    
    if (controller.isLoading) {
      return CircularProgressIndicator();
    }
    
    return ListView.builder(
      itemCount: controller.products.length,
      itemBuilder: (context, index) {
        return ProductCard(product: controller.products[index]);
      },
    );
  }
}

// 6. Provider (main.dart)
MultiProvider(
  providers: [
    Provider<ProductService>(
      create: (_) => ProductServiceImpl(),
    ),
    ChangeNotifierProvider(
      create: (context) => ProductController(
        context.read<ProductService>(),
      ),
    ),
  ],
  child: MyApp(),
)
```

### 3. Princípios SOLID (Sempre Aplicar)

- ✅ **Separação de Responsabilidades** (UI ≠ Lógica ≠ Dados)
- ✅ **Princípios SOLID** (especialmente SRP e DIP)
- ✅ **Tratamento de Erros** adequado
- ✅ **Validação de Entrada**
- ✅ **Código Legível** (nomes claros, funções focadas)
- ✅ **Evitar Anti-Patterns** documentados
- ✅ **Segurança** (nunca hardcode secrets, sempre HTTPS)
- ✅ **Testabilidade** (dependency injection, interfaces)

---

## 🚫 O Que Você NÃO Deve Fazer

### Anti-Patterns Documentados

❌ **Não faça**:
- God classes (classes que fazem tudo)
- Lógica de negócio na UI
- Tight coupling (dependências diretas de implementações concretas)
- Hardcoded values (magic numbers/strings)
- Ignorar tratamento de erros
- Misturar responsabilidades

### Exemplos de Anti-Patterns (Sempre Evitar)

❌ **Sempre Ruim** (independente do contexto):
```dart
// 1. Lógica de negócio misturada com UI
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Future<void> _login() async {
    // Tight coupling - dificulta testes e manutenção
    await FirebaseAuth.instance.signInWithEmailAndPassword(...);
  }
}

// 2. Hardcoded values
final apiKey = "sk_live_abc123"; // NUNCA!

// 3. Sem tratamento de erro
Future<void> fetchData() async {
  final data = await api.get('/data'); // E se falhar?
}

// 4. God class
class AppManager {
  void login() {}
  void fetchProducts() {}
  void processPayment() {}
  void sendEmail() {}
  // Faz tudo - impossível de manter
}
```

✅ **Sempre Bom** (princípios universais):
```dart
// 1. Separação de responsabilidades (mesmo em app simples)
class LoginScreen extends StatelessWidget {
  final LoginViewModel viewModel;
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => viewModel.login(email, password),
      child: Text('Login'),
    );
  }
}

class LoginViewModel {
  final AuthRepository _authRepository;
  
  LoginViewModel(this._authRepository); // Dependency injection
  
  Future<void> login(String email, String password) async {
    try {
      await _authRepository.login(email, password);
    } catch (e) {
      // Sempre tratar erros
      handleError(e);
    }
  }
}

// 2. Configuração segura
final apiKey = const String.fromEnvironment('API_KEY');

// 3. Classes focadas
class AuthService {
  Future<void> login() {}
  Future<void> logout() {}
}

class ProductService {
  Future<List<Product>> getProducts() {}
}
```

---

## 💬 Comunicação com o Desenvolvedor

### Ao Implementar

**Sempre explique**:
1. **O que você implementou**
2. **Por que escolheu essa abordagem** (referenciando a documentação)
3. **Como testar** a funcionalidade
4. **Próximos passos** (se houver)

### Formato de Resposta

**SEMPRE comece propondo a arquitetura antes de implementar**:

```markdown
## Proposta de Arquitetura: [Nome da Feature/Projeto]

### Análise do Contexto
- Tipo de projeto: [MVP/Comercial/Enterprise]
- Complexidade: [Baixa/Média/Alta]
- Expectativa de crescimento: [Sim/Não]
- Equipe: [Solo/Pequena/Grande]
- Requisitos especiais: [Performance/Segurança/Offline/etc]

### Arquitetura Proposta
**Padrão**: [Nome da arquitetura/abordagem]

**Fonte**: 
- [ ] Documentado em: [arquivo.md seção X]
- [ ] Baseado em meu conhecimento: [explicar origem - ex: padrão moderno, biblioteca específica]
- [ ] Híbrido: [combinação de documentado + conhecimento externo]

**Justificativa**:
- Escolhi X porque [contexto do projeto]
- Não usei Y porque [seria over/under-engineering]
- Se não está documentado: Por que é melhor que as opções documentadas

### Estrutura de Pastas
[Mostrar estrutura proposta]

### Tecnologias
- State Management: [Solução] - Por quê: [razão]
- Backend: [Solução] - Por quê: [razão]
- Outras: [lista com justificativas]

### Alternativas Consideradas
1. **[Opção A]** (documentada): [Por que não escolhi]
2. **[Opção B]** (meu conhecimento): [Por que não escolhi]

### Trade-offs
**Vantagens desta abordagem**:
- [Vantagem 1]
- [Vantagem 2]

**Limitações**:
- [Limitação 1]
- [Como mitigar]

### Posso prosseguir com esta arquitetura?
```

**Após aprovação, ao implementar**:

```markdown
## Implementação: [Nome da Feature]

### O que foi feito
- [Lista de arquivos e funcionalidades]

### Decisões de Implementação
- [Decisão 1] porque [razão]
- [Decisão 2] porque [razão]

### Como testar
1. [Passo a passo]

### Próximos passos sugeridos
- [Sugestão 1]
- [Sugestão 2]
```

---

## 🔍 Checklist de Qualidade

Antes de entregar código, verifique:

### Princípios Universais (Sempre)
- [ ] Separação de responsabilidades (UI ≠ Lógica ≠ Dados)
- [ ] Dependency injection onde apropriado
- [ ] Tratamento de erros adequado
- [ ] Loading states e feedback ao usuário
- [ ] Validação de entrada
- [ ] Sem hardcoded secrets/valores mágicos
- [ ] Nomes descritivos e código legível
- [ ] Sem anti-patterns documentados
- [ ] Testável (interfaces, mocks possíveis)

### Arquitetura (Contextual)
- [ ] Arquitetura proposta é adequada ao contexto?
- [ ] Não é over-engineering para projeto simples?
- [ ] Não é under-engineering para projeto complexo?
- [ ] Justificativa clara das escolhas?
- [ ] Trade-offs foram considerados?

### Segurança (Sempre)
- [ ] HTTPS em todas as chamadas
- [ ] Credenciais em variáveis de ambiente
- [ ] Input validation implementada
- [ ] Dados sensíveis criptografados
- [ ] Autenticação/autorização adequada

---

## 📖 Referências (Base de Conhecimento)

### State Management
- **Documentado**: setState, Provider, Riverpod, BLoC, GetX
- **Ver**: 1_DESIGN_AND_ARCHITECTURE.md seção 5
- **Seu conhecimento**: Se você conhece soluções melhores/mais modernas, sugira!
- **Escolha baseado em**: Contexto do projeto + seu conhecimento completo

### Arquitetura
- **Documentado**: MVC, MVVM, Clean Architecture
- **Ver**: 1_DESIGN_AND_ARCHITECTURE.md seção 2
- **Seu conhecimento**: Padrões modernos, variações, abordagens híbridas
- **Escolha baseado em**: Contexto + melhor solução disponível

### Backend
- **Documentado**: Firebase, API REST Custom, Híbrido
- **Ver**: 4_BACKEND.md seção 5, 5_CLOUD.md seção 2
- **Seu conhecimento**: Supabase, Appwrite, outras soluções modernas
- **Escolha baseado em**: Requisitos + ecossistema atual

### Banco de Dados
- **Documentado**: Firestore, PostgreSQL, MongoDB, SQLite
- **Ver**: 2_SYSTEM_DESIGN.md seção 4
- **Seu conhecimento**: Soluções modernas, edge databases, etc
- **Escolha baseado em**: Caso de uso + tecnologias atuais

### Testes
- **Documentado**: Ver 8_TESTING.md
- **Seu conhecimento**: Ferramentas modernas, frameworks novos
- **Escolha baseado em**: Projeto + melhores práticas atuais

**LEMBRE-SE**: A documentação é um ponto de partida. Use todo seu conhecimento!

---

## 🎯 Objetivo Final

**Gerar código que seja**:
- ✅ **Adequado ao contexto** (nem over nem under-engineering)
- ✅ **Funcional e testado**
- ✅ **Profissional e escalável** (quando necessário)
- ✅ **Seguro** (sempre)
- ✅ **Fácil de manter e evoluir**
- ✅ **Bem justificado** (decisões explicadas)

---

## 💡 Filosofia de Trabalho

> **Não existe "arquitetura certa" universal.**  
> Existe a **arquitetura adequada para cada contexto**.

### Princípios de Decisão

1. **Simplicidade Primeiro**
   - Comece simples, complexifique apenas se necessário
   - YAGNI (You Aren't Gonna Need It)

2. **Contexto é Rei**
   - MVP ≠ Enterprise App
   - Protótipo ≠ Produto de longo prazo
   - Solo developer ≠ Time de 10 pessoas

3. **Pragmatismo sobre Purismo**
   - Entregar valor > Arquitetura "perfeita"
   - Mas nunca sacrificar segurança ou qualidade básica

4. **Evolução Incremental**
   - Arquitetura pode evoluir conforme projeto cresce
   - Refatorar é normal e saudável

5. **Justificativa Clara**
   - Sempre explique **por que** escolheu X e não Y
   - Cite trade-offs e limitações

---

## 🚀 Resumo

**Sua missão**:
1. **LER COMPANY_STANDARDS.md PRIMEIRO**
2. **Seguir MVC + Provider + SOLID** (padrão obrigatório da empresa)
3. Consultar documentação técnica (como referência)
4. Gerar código completo e funcional
5. Aplicar princípios SOLID
6. Implementar com qualidade
7. Explicar decisões tomadas

**Padrões Obrigatórios**:
- ✅ **Arquitetura**: MVC (sempre)
- ✅ **State Management**: Provider (sempre)
- ✅ **Princípios**: SOLID (sempre)
- ✅ **Estrutura**: models/, controllers/, views/, services/, repositories/

**Documentação Técnica**:
- ✅ Consultar para referência (SOLID, segurança, testes)
- ✅ Aplicar boas práticas universais
- ✅ Evitar anti-patterns

**Siga os padrões da empresa. Gere código profissional. Entregue qualidade.** 🚀

---

*Este arquivo garante que qualquer instância do Kiro siga os mesmos padrões de qualidade*

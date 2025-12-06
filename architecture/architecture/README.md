# Architecture Knowledge Base

## 🎯 Propósito

Esta pasta contém **documentação técnica de arquitetura de software** para ser usada como **base de conhecimento e referência** em todos os projetos Flutter/Backend/Cloud.

**🚨 IMPORTANTE**: A empresa tem **padrões obrigatórios** definidos em `COMPANY_STANDARDS.md`:
- **Arquitetura**: MVC (Model-View-Controller)
- **State Management**: Provider
- **Princípios**: SOLID

**Como usar**: Copie esta pasta `/architecture` para dentro de cada novo projeto. O Kiro lerá os padrões da empresa e gerará código seguindo esses padrões.

---

## 📚 Documentação Disponível

### 🎯 Contexto de Trabalho (LEIA PRIMEIRO)

**[WORK_CONTEXT.md](./WORK_CONTEXT.md)**
- **IMPORTANTE**: Explica o papel do Kiro e do desenvolvedor
- Como trabalhar juntos
- O que o Kiro deve gerar (código completo, não snippets)
- Nível de detalhe esperado
- Dinâmica de trabalho

**[COMPANY_STANDARDS.md](./COMPANY_STANDARDS.md)** ⭐ **PRIORIDADE MÁXIMA**
- **Padrões OBRIGATÓRIOS da empresa**
- Arquitetura: MVC (em todos os projetos)
- Estrutura de pastas específica
- State management: Provider
- **SEMPRE seguir estes padrões!**

---

### Fundamentos de Arquitetura

**[1_DESIGN_AND_ARCHITECTURE.md](./1_DESIGN_AND_ARCHITECTURE.md)**
- Princípios fundamentais (SOLID, DRY, KISS, YAGNI)
- Padrões arquiteturais (MVC, MVVM, Clean Architecture)
- Design Patterns (Factory, Repository, Singleton, Observer, Strategy)
- State Management (setState, Provider, Riverpod, BLoC, GetX)
- Estruturas de pastas recomendadas
- Anti-patterns e erros comuns
- Exemplos práticos em Flutter/Dart

### Design de Sistemas

**[2_SYSTEM_DESIGN.md](./2_SYSTEM_DESIGN.md)**
- Arquitetura de sistemas (frontend, backend, APIs, databases)
- Protocolos de comunicação (REST, GraphQL, WebSockets)
- Escalabilidade (horizontal vs vertical, load balancing)
- Estratégias de caching
- Design de banco de dados (SQL vs NoSQL, normalização, indexação)
- Firestore data modeling
- Microservices vs Monolith

### Papel do Arquiteto

**[3_SOFTWARE_ARCHITECT_ROLE.md](./3_SOFTWARE_ARCHITECT_ROLE.md)**
- Responsabilidades do arquiteto de software
- Framework de tomada de decisões
- Architecture Decision Records (ADRs)
- Comunicação com desenvolvedores, stakeholders e IAs
- Erros comuns e como evitá-los
- Estratégia de evolução de arquitetura

### Backend

**[4_BACKEND.md](./4_BACKEND.md)**
- Camadas de backend (Controller → Service → Repository)
- Design de APIs REST (boas práticas, versionamento, paginação)
- Autenticação e autorização (JWT, RBAC)
- Consistência de dados (transações, locking)
- Firebase vs API customizada
- Estratégias de escalabilidade

### Cloud

**[5_CLOUD.md](./5_CLOUD.md)**
- Firebase completo (Auth, Firestore, Functions, Storage, Hosting)
- Comparação de plataformas (Firebase vs AWS vs GCP vs Supabase)
- Serverless vs PaaS vs IaaS
- CI/CD na nuvem
- Gerenciamento de custos
- Security rules e boas práticas

### DevOps

**[6_DEVOPS.md](./6_DEVOPS.md)**
- Git workflow (branches, commits, PRs)
- CI/CD pipelines (GitHub Actions, Codemagic)
- Testes automatizados
- Monitoramento (Crashlytics, Analytics)
- Release management e versionamento
- Estratégias de rollback

### Segurança

**[7_SECURITY.md](./7_SECURITY.md)**
- Authentication vs Authorization
- Princípios de código seguro
- Gerenciamento de API keys
- Proteção de dados (encryption, HTTPS, secure storage)
- OWASP Top 10 para mobile
- Vulnerabilidades comuns e mitigações
- Checklist de segurança

### Testes

**[8_TESTING.md](./8_TESTING.md)**
- Pirâmide de testes (unit, widget, integration)
- Como projetar arquitetura testável
- Mocking e dependency injection
- Exemplos de testes em Dart/Flutter
- Integração com CI/CD
- Cobertura de testes

---

## 🤖 Como o Kiro Usa Esta Documentação

**🚨 PRIORIDADE ABSOLUTA: COMPANY_STANDARDS.md**

Quando você copiar esta pasta para um projeto e pedir para o Kiro implementar algo, ele vai:

1. **LER COMPANY_STANDARDS.md PRIMEIRO** (padrões obrigatórios da empresa)
2. **Seguir MVC + Provider + SOLID** (padrão da empresa)
3. **Consultar documentação técnica** (como referência complementar)
4. **Gerar código profissional** seguindo os padrões estabelecidos
5. **Evitar anti-patterns** sempre

### Hierarquia de Decisão

```
1. COMPANY_STANDARDS.md     ← SEMPRE seguir (MVC obrigatório)
2. WORK_CONTEXT.md          ← Como trabalhar
3. Documentação técnica     ← Referência (SOLID, segurança, testes)
```

### Exemplo de Uso Real

```
Você: "Kiro, criar app de e-commerce"

Kiro vai:
1. Ler COMPANY_STANDARDS.md
2. Ver que a empresa usa MVC + Provider + SOLID
3. Propor: "MVC com Provider, seguindo padrões da empresa"
4. Gerar estrutura:
   - lib/models/
   - lib/controllers/
   - lib/views/
   - lib/services/
   - lib/repositories/
5. Implementar com SOLID
6. Usar Provider para state management
```

**A empresa tem padrões definidos. O Kiro segue esses padrões.**

---

## 📖 Características da Documentação

### ✅ Exemplos Práticos

Todos os documentos incluem:
- ✅ Código Flutter/Dart real e funcional
- ❌ Exemplos de código ruim (anti-patterns)
- Comparações lado a lado
- Casos de uso reais

### 🎯 Focado em Produção

- Código pronto para produção
- Boas práticas da indústria
- Segurança desde o início
- Escalabilidade considerada

### 🧠 AI-Friendly

- Comentários `<!-- AI_NOTE: ... -->` para guiar IAs
- Estrutura clara e consistente
- Exemplos completos e contextualizados
- Decisões arquiteturais explicadas

---

## 🚀 Como Usar em Cada Projeto

### 1. Copiar a Pasta

```bash
# No novo projeto
cp -r /caminho/para/architecture ./architecture
```

### 2. Informar o Kiro

```
"Kiro, este projeto segue os padrões da pasta /architecture.
Consulte esses documentos ao implementar funcionalidades."
```

### 3. Desenvolver

O Kiro vai automaticamente seguir os padrões ao gerar código.

---

## 🔄 Manutenção

### Quando Atualizar

- Quando aprender novos padrões
- Quando a empresa definir padrões específicos
- Quando descobrir melhores práticas
- Após feedback de projetos

### Como Atualizar

1. Edite os documentos relevantes
2. Adicione exemplos práticos
3. Documente decisões (por que mudou)
4. Copie versão atualizada para projetos futuros

---

## 📋 Estrutura dos Documentos

Cada documento segue este formato:

```markdown
# Título

## Table of Contents
[Links para seções]

## 1. Conceito Principal
Explicação clara

### 1.1 Subtópico
Detalhes

#### ✅ Good Example
```dart
// Código bom
```

#### ❌ Bad Example
```dart
// Código ruim
```

<!-- AI_NOTE: Contexto para IAs -->
```

---

## 💡 Filosofia da Documentação

Esta documentação é baseada em:

1. **Base, Não Limite** - Documentação é ponto de partida, não teto de possibilidades
2. **Contexto sobre Dogma** - Não existe "arquitetura certa" universal, existe a adequada para cada contexto
3. **Conhecimento Completo** - Use documentação + conhecimento do Kiro + melhores práticas atuais
4. **Simplicidade Primeiro** - Comece simples, complexifique apenas se necessário (YAGNI)
5. **Pragmatismo sobre Purismo** - Entregar valor > Arquitetura "perfeita"
6. **Justificativa Clara** - Toda decisão deve ser explicada e fundamentada
7. **Evolução Incremental** - Arquitetura pode e deve evoluir conforme projeto cresce
8. **Princípios Universais** - Alguns princípios (segurança, separação de responsabilidades) sempre se aplicam
9. **Abertura a Inovação** - Se existe solução melhor (mesmo não documentada), use-a

---

## 📞 Suporte

Esta documentação é um **guia vivo**. Atualize conforme aprende e evolui como desenvolvedor.

**Lembre-se**: O Kiro em qualquer projeto pode ler e seguir esses padrões. Mantenha a documentação atualizada e clara.

---

*Documentação criada para garantir qualidade e consistência em todos os projetos*  
*Última atualização: Novembro 2025*

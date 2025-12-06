# Como Usar Esta Documentação

> **Para**: Petrus  
> **Objetivo**: Guia rápido de como usar a pasta `/architecture` em cada projeto

---

## 🎯 O Que É Isso

Esta pasta contém **documentação técnica completa** que qualquer instância do Kiro pode ler e seguir para gerar código profissional.

**Importante**: Você vai usar outra conta do Kiro nos projetos da empresa. Aquele Kiro não vai saber nada desta conversa, mas vai poder ler esses arquivos.

---

## 📦 Como Usar em Cada Projeto

### 1. Copiar a Pasta

Quando começar um novo projeto, copie esta pasta inteira:

```bash
# Opção 1: Copiar manualmente
# Copie a pasta /architecture para dentro do novo projeto

# Opção 2: Via terminal
cp -r /caminho/desta/architecture /caminho/do/novo/projeto/architecture
```

### 2. Informar o Kiro

No início do projeto, envie esta mensagem para o Kiro:

```
Kiro, este projeto tem documentação de arquitetura na pasta /architecture.

🚨 IMPORTANTE: Leia WORK_CONTEXT.md primeiro para entender seu papel.

Resumo:
- Você é o desenvolvedor principal (gera código completo)
- Eu sou o arquiteto/revisor (testo e aprovo)
- Leia INSTRUCTIONS_FOR_KIRO.md para detalhes técnicos
- Consulte a documentação técnica como referência

Vamos começar!
```

### 3. Trabalhar Normalmente

A partir daí, trabalhe normalmente. O Kiro vai:
- ✅ Consultar a documentação automaticamente
- ✅ Seguir os padrões estabelecidos
- ✅ Gerar código profissional
- ✅ Evitar anti-patterns

---

## 💬 Exemplos de Como Pedir Coisas

### Implementar Feature

```
Kiro, implementar feature de autenticação:
- Login com email/senha
- Cadastro de usuários
- Recuperação de senha
- Integração com Firebase Auth

Seguir padrão MVC da empresa (COMPANY_STANDARDS.md).
```

### Criar Estrutura

```
Kiro, criar estrutura do projeto seguindo MVC 
conforme documentado em /architecture/COMPANY_STANDARDS.md
```

### Revisar Código

```
Kiro, revisar o código do arquivo X:
- Está seguindo os padrões da documentação?
- Tem algum anti-pattern?
- Como pode ser melhorado?
```

### Corrigir Bug

```
Kiro, bug no login:
- O que acontece: [descrever]
- O que deveria: [descrever]
- Erro: [copiar erro do console]

Corrigir seguindo os padrões de tratamento de erros da documentação.
```

---

## 📚 Quando Consultar Cada Documento

### Começando o Projeto
→ **1_DESIGN_AND_ARCHITECTURE.md** - Estrutura de pastas, padrões

### Implementando Autenticação
→ **4_BACKEND.md** (seção 3) + **7_SECURITY.md** (seção 1)

### Trabalhando com Firebase
→ **5_CLOUD.md** (seção 1)

### Criando APIs
→ **4_BACKEND.md** (seção 2) + **2_SYSTEM_DESIGN.md** (seção 2)

### Implementando Testes
→ **8_TESTING.md**

### Configurando CI/CD
→ **6_DEVOPS.md**

### Dúvidas de Segurança
→ **7_SECURITY.md**

---

## 🔄 Depois do Onboarding (Dia 9)

Após o onboarding, você vai saber:
- Como a empresa trabalha
- Se tem padrões específicos
- Como é o processo de desenvolvimento

**Se a empresa tiver padrões diferentes**:

1. Abra os arquivos relevantes
2. Adicione uma seção no topo:

```markdown
## 🏢 PADRÕES DO PROJETO

[Descrever padrões específicos do projeto]

---

## Padrões Gerais (usar se empresa não especificar)

[Resto do documento]
```

3. Salve e use em todos os projetos

---

## ✅ Checklist Rápido

Para cada novo projeto:

- [ ] Copiei a pasta `/architecture` para o projeto
- [ ] Informei o Kiro sobre a documentação
- [ ] Kiro confirmou que leu as instruções
- [ ] Comecei a desenvolver

---

## 💡 Dicas Importantes

### ✅ FAÇA

- **Sempre copie a pasta** para cada projeto novo
- **Informe o Kiro** no início
- **Atualize a documentação** quando aprender algo novo
- **Consulte quando tiver dúvidas** de como fazer algo

### ❌ NÃO FAÇA

- **Não assuma** que o Kiro sabe - ele precisa ler os arquivos
- **Não pule** a etapa de informar sobre a documentação
- **Não ignore** os padrões documentados
- **Não deixe** a documentação desatualizada

---

## 🎯 Objetivo

Com esta pasta, você garante que:
- ✅ Todo projeto segue os mesmos padrões
- ✅ Qualquer Kiro pode gerar código de qualidade
- ✅ Você tem referência técnica sempre disponível
- ✅ O código é profissional e escalável

---

## 📞 Exemplo Completo de Uso

### Cenário: Novo Projeto de E-commerce

**1. Copiar documentação**
```bash
cp -r ~/architecture ~/projetos/ecommerce-app/architecture
```

**2. Abrir projeto no Kiro**
```
cd ~/projetos/ecommerce-app
code .
```

**3. Primeira mensagem para o Kiro**
```
Kiro, novo projeto de e-commerce.

🚨 IMPORTANTE: Leia /architecture/COMPANY_STANDARDS.md primeiro.

A empresa usa:
- MVC (Model-View-Controller)
- Provider (state management)
- SOLID (princípios)

Crie a estrutura do projeto seguindo esses padrões.
```

**4. Kiro responde**
```
Entendido! Li COMPANY_STANDARDS.md.

Vou seguir os padrões da empresa:
- MVC (models/, controllers/, views/)
- Provider para state management
- SOLID (interfaces, DIP, SRP)
- Estrutura documentada

Criando estrutura do projeto...
```

**5. Desenvolvimento**
```
Kiro, implementar feature de catálogo de produtos:
- Listagem de produtos
- Detalhes do produto
- Busca e filtros
- Integração com Firestore

Seguir padrão MVC da empresa.
```

**6. Kiro implementa seguindo MVC + Provider + SOLID** ✅

---

## 🚀 Pronto!

Agora você tem tudo que precisa:
- ✅ Documentação técnica completa
- ✅ Instruções para o Kiro
- ✅ Guia de como usar

**Boa sorte no onboarding dia 9!** 🎉

Depois que souber como a empresa funciona, você pode adicionar 
os padrões específicos deles nesta documentação.

---

*Qualquer dúvida, é só perguntar para qualquer Kiro: "Explica como usar a documentação em /architecture"*

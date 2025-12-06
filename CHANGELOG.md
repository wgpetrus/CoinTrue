# Changelog

Todas as mudanças notáveis neste projeto serão documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/),
e este projeto adere ao [Semantic Versioning](https://semver.org/lang/pt-BR/).

---

## [Unreleased]

### Em Desenvolvimento
- Modo escuro (dark mode)
- Gráficos avançados de análise técnica
- Alertas de preço personalizados (notificações)
- Finalizar funcionalidades de profile secreen

---

## [1.0.0] - 2025-12-06

### 🎉 Lançamento Inicial

#### Added - Autenticação
- Login com Google
- Login com Apple
- Login com Email/Senha
- Registro de novos usuários
- Recuperação de senha
- Verificação de email
- Autenticação biométrica (Face ID / Touch ID / Fingerprint)
- Tela de bloqueio biométrico obrigatória
- Rate limiting para prevenir brute force

#### Added - Criptomoedas
- Dashboard com saldo total e estatísticas
- Lista de criptomoedas em tempo real (API CoinGecko)
- Detalhes de cada criptomoeda com gráficos
- Tela de mercados completa com busca e filtros
- Atualização automática de preços (30s)
- Cache inteligente de dados
- Ícones reais das criptomoedas

#### Added - Portfólio
- Visualização de ativos do usuário
- Gráfico de distribuição (donut chart)
- Cálculo de lucro/prejuízo em tempo real
- Estatísticas de performance (24h, 7d, 30d)
- Valor total do portfólio

#### Added - Transações
- Compra simulada de criptomoedas
- Venda simulada de criptomoedas
- Conversão entre criptomoedas
- Histórico completo de transações
- Filtros por tipo (compra/venda/conversão)
- Filtros por período
- Seletor de moedas com busca

#### Added - Notificações
- Firebase Cloud Messaging (FCM)
- Notificações push
- Preferências de notificação
- Gerenciamento de permissões

#### Added - UI/UX
- Design system completo (CoinTrue)
- Cores consistentes (amarelo #FFE70F como primária)
- Phosphor Icons como padrão
- Animações com flutter_animate
- Responsividade para mobile
- Bottom navigation bar
- Botão central de ações
- Loading states
- Error handling visual

#### Added - Arquitetura
- Padrão MVC + Provider
- SOLID principles aplicados
- Dependency Injection
- Repository pattern
- Separação de responsabilidades
- Barrel files para organização

#### Added - Segurança
- HTTPS obrigatório em todas as requisições
- Firebase Auth para autenticação
- Tokens JWT gerenciados automaticamente
- Biometria com flutter_secure_storage
- Validação de entrada em formulários
- Rate limiting

#### Added - Performance
- Cache de imagens
- Cache de dados da API
- Lazy loading
- Otimização de builds
- Auto-refresh inteligente

---

## [0.3.0] - 2025-11-28

### Added
- Conversão entre criptomoedas
- Gráficos de preço melhorados
- Correções de cálculo de conversão

### Fixed
- Correção no fluxo de biometria
- Correção no cálculo de conversão
- Correções visuais na tela de conversão
- Solução final para gráficos

---

## [0.2.0] - 2025-11-20

### Added
- Botão central de ações
- Ícones reais das criptomoedas
- Implementação completa do FCM

### Fixed
- Melhorias na conversão
- Melhorias finais na conversão
- Melhoria no rate limit
- Otimizações de performance

---

## [0.1.0] - 2025-11-10

### Added
- Estrutura inicial do projeto
- Autenticação básica
- Tela de login
- Splash screen
- Onboarding

---

## Tipos de Mudanças

- `Added` - Novas funcionalidades
- `Changed` - Mudanças em funcionalidades existentes
- `Deprecated` - Funcionalidades que serão removidas
- `Removed` - Funcionalidades removidas
- `Fixed` - Correções de bugs
- `Security` - Correções de segurança

---

## Links

- [Repositório](https://github.com/seu-usuario/cointrue)
- [Issues](https://github.com/seu-usuario/cointrue/issues)
- [Pull Requests](https://github.com/seu-usuario/cointrue/pulls)

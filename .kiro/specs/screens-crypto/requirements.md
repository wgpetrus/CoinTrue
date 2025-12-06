# Requisitos - App CoinTrue

## Visão Geral

Sistema completo de visualização e gerenciamento de criptomoedas, permitindo aos usuários acompanhar preços em tempo real, gerenciar portfólio, realizar transações simuladas e visualizar histórico de atividades.

---

## 1. Dashboard (Home)

### 1.1 Saldo Total
- O sistema deve exibir o saldo total do usuário em destaque
- O saldo deve ser calculado somando todos os ativos do portfólio
- O usuário deve poder ocultar/mostrar o saldo com um botão de visibilidade
- O sistema deve exibir a variação percentual do saldo nas últimas 24h

### 1.2 Cards de Estatísticas
- O sistema deve exibir card de "Lucro 24h" com valor e percentual
- O sistema deve exibir card de "Total de Ativos" com quantidade de criptos diferentes
- Os cards devem usar cores apropriadas (verde para lucro, vermelho para prejuízo)

### 1.3 Botões de Ação Rápida
- O sistema deve fornecer botão "Enviar" para transferências
- O sistema deve fornecer botão "Receber" para receber criptos
- O sistema deve fornecer botão "Trocar" para exchanges
- Os botões devem ser circulares com ícones claros

### 1.4 Lista de Criptomoedas Principais
- O sistema deve exibir lista das principais criptomoedas (Bitcoin, Ethereum, Cardano, Solana)
- Cada item deve mostrar: ícone, nome, símbolo, preço atual, variação 24h
- A lista deve ser rolável
- O usuário deve poder tocar em uma cripto para ver detalhes

### 1.5 Atualização de Preços
- Os preços devem ser atualizados em tempo real (ou simulado)
- O sistema deve indicar visualmente quando os preços estão sendo atualizados
- O usuário deve poder puxar para atualizar (pull-to-refresh)

---

## 2. Navegação

### 2.1 Bottom Navigation Bar
- O sistema deve fornecer navegação inferior com 4 abas
- Abas: Início, Portfólio, Mercados, Atividade
- A aba ativa deve ser destacada com cor amarela (#FFE70F)
- A navegação deve manter o estado de cada tela

### 2.2 Transições
- As transições entre telas devem ser suaves (300ms)
- O sistema deve usar animações de slide horizontal

---

## 3. Portfólio

### 3.1 Visão Geral
- O sistema deve exibir o valor total do portfólio
- O sistema deve exibir gráfico de distribuição (donut chart)
- O gráfico deve usar cores específicas para cada cripto

### 3.2 Lista de Ativos
- O sistema deve listar todas as criptos que o usuário possui
- Cada item deve mostrar: ícone, nome, quantidade, valor total, variação
- A lista deve ser ordenável (por valor, por nome, por variação)
- O usuário deve poder tocar em um ativo para ver detalhes

### 3.3 Estatísticas
- O sistema deve exibir lucro/prejuízo total
- O sistema deve exibir melhor ativo (maior ganho)
- O sistema deve exibir pior ativo (maior perda)

---

## 4. Mercados

### 4.1 Lista Completa
- O sistema deve exibir lista de todas as criptomoedas disponíveis
- A lista deve incluir: ícone, nome, símbolo, preço, variação 24h, volume
- A lista deve ser paginada ou com scroll infinito

### 4.2 Busca
- O usuário deve poder buscar criptos por nome ou símbolo
- A busca deve ser em tempo real (enquanto digita)
- O sistema deve destacar o texto buscado nos resultados

### 4.3 Filtros
- O usuário deve poder filtrar por: Todos, Gainers (maiores altas), Losers (maiores quedas)
- Os filtros devem ser botões tipo chip/tab
- O filtro ativo deve ser destacado

### 4.4 Ordenação
- O usuário deve poder ordenar por: Preço, Variação 24h, Volume, Nome
- A ordenação deve ser ascendente ou descendente

---

## 5. Detalhes da Criptomoeda

### 5.1 Informações Principais
- O sistema deve exibir ícone grande da cripto
- O sistema deve exibir nome completo e símbolo
- O sistema deve exibir preço atual em destaque
- O sistema deve exibir variação 24h com cor apropriada

### 5.2 Gráfico de Preço
- O sistema deve exibir gráfico de linha do histórico de preços
- O usuário deve poder alternar entre períodos: 1H, 24H, 7D, 1M, 1A, Tudo
- O gráfico deve ser interativo (mostrar valor ao tocar)
- O gráfico deve usar gradiente suave

### 5.3 Estatísticas Detalhadas
- O sistema deve exibir: Alta 24h, Baixa 24h, Volume 24h, Market Cap
- As estatísticas devem ser organizadas em cards ou lista

### 5.4 Ações
- O sistema deve fornecer botões: Comprar, Vender, Adicionar aos Favoritos
- Os botões devem ser destacados e fáceis de acessar
- O botão de favorito deve alternar entre favoritado/não favoritado

---

## 6. Transações (Compra/Venda)

### 6.1 Formulário de Transação
- O usuário deve poder escolher o tipo: Comprar ou Vender
- O usuário deve poder inserir quantidade ou valor em reais
- O sistema deve calcular automaticamente o valor correspondente
- O sistema deve exibir taxa de transação (se houver)
- O sistema deve exibir valor total

### 6.2 Validações
- O sistema deve validar se o usuário tem saldo suficiente (para compra)
- O sistema deve validar se o usuário tem quantidade suficiente (para venda)
- O sistema deve validar valores mínimos e máximos
- O sistema deve exibir mensagens de erro claras

### 6.3 Confirmação
- O sistema deve exibir tela de confirmação antes de executar
- A confirmação deve mostrar: tipo, quantidade, preço, total
- O usuário deve poder cancelar ou confirmar
- Após confirmação, o sistema deve processar a transação

### 6.4 Feedback
- O sistema deve exibir loading durante o processamento
- O sistema deve exibir mensagem de sucesso após conclusão
- O sistema deve exibir mensagem de erro em caso de falha
- Após sucesso, o sistema deve atualizar o portfólio

---

## 7. Atividade (Histórico)

### 7.1 Lista de Transações
- O sistema deve exibir lista de todas as transações do usuário
- Cada item deve mostrar: tipo (compra/venda), cripto, quantidade, valor, data
- A lista deve ser ordenada por data (mais recente primeiro)
- O sistema deve usar ícones e cores para diferenciar tipos

### 7.2 Filtros
- O usuário deve poder filtrar por: Todas, Compras, Vendas, Trocas
- O usuário deve poder filtrar por período: Hoje, Semana, Mês, Ano, Tudo
- Os filtros devem ser combinados

### 7.3 Detalhes da Transação
- O usuário deve poder tocar em uma transação para ver detalhes
- Os detalhes devem incluir: ID, data/hora, status, taxa, hash (se aplicável)

### 7.4 Estados Vazios
- O sistema deve exibir mensagem amigável quando não houver transações
- A mensagem deve incluir ilustração e texto explicativo
- O sistema deve sugerir ação (ex: "Faça sua primeira compra")

---

## 8. Perfil/Configurações

### 8.1 Informações do Usuário
- O sistema deve exibir foto/avatar do usuário
- O sistema deve exibir nome e email
- O usuário deve poder editar informações básicas

### 8.2 Configurações de Segurança
- O usuário deve poder ativar/desativar biometria (já implementado)
- O usuário deve poder alterar senha (se aplicável)
- O usuário deve poder ver dispositivos conectados

### 8.3 Preferências
- O usuário deve poder escolher moeda padrão (BRL, USD, EUR)
- O usuário deve poder ativar/desativar notificações
- O usuário deve poder escolher tema (claro/escuro) - futuro

### 8.4 Sobre
- O sistema deve exibir versão do app
- O sistema deve fornecer links: Termos de Uso, Política de Privacidade, Suporte
- O sistema deve fornecer botão de logout
- O sistema deve fornecer botão de excluir conta

### 8.5 Saldo Inicial (Para Testes)
- Novos usuários devem receber saldo inicial de R$ 10.000,00 (simulado)
- Isso permite testar compras sem precisar adicionar dinheiro real
- O saldo é armazenado no Firestore: `users/{userId}/wallet/balance`

---

## 9. Dados e Persistência

### 9.1 Portfólio do Usuário
- O sistema deve armazenar o portfólio no Firestore
- Estrutura: userId → portfolio → [{ cryptoId, quantity, avgPrice, totalInvested }]
- O sistema deve sincronizar em tempo real

### 9.2 Transações
- O sistema deve armazenar todas as transações no Firestore
- Estrutura: userId → transactions → [{ id, type, cryptoId, quantity, price, total, fee, timestamp }]
- As transações devem ser imutáveis (não editáveis)

### 9.3 Favoritos
- O usuário deve poder marcar criptos como favoritas
- Os favoritos devem ser armazenados no Firestore
- Estrutura: userId → favorites → [cryptoId]

### 9.4 Cache Local
- O sistema deve cachear preços localmente para acesso offline
- O cache deve expirar após 5 minutos
- O sistema deve indicar quando está usando dados em cache

---

## 10. API de Preços - Coinbase

### 10.1 Fonte de Dados
- O sistema DEVE usar a **API da Coinbase** (https://api.coinbase.com/v2/)
- A API é pública e não requer autenticação para dados de mercado
- Rate limit: 10,000 requisições/hora
- **100% FUNCIONAL** - Dados reais em tempo real

### 10.2 Endpoints Utilizados
- **Listar moedas:** `GET /currencies`
- **Preço spot:** `GET /prices/{pair}/spot` (ex: BTC-USD)
- **Taxas de câmbio:** `GET /exchange-rates?currency=USD`
- **Histórico:** `GET /prices/{pair}/historic?period={day|week|month|year}`

### 10.3 Atualização
- Os preços devem ser atualizados a cada 30 segundos (quando app em foreground)
- O sistema deve pausar atualizações quando app em background
- O sistema deve retomar atualizações ao voltar para foreground
- Timer automático usando `Timer.periodic`

### 10.4 Cache Local
- O sistema deve cachear preços localmente (SharedPreferences)
- Cache expira após 5 minutos
- Usado quando offline ou erro de API

### 10.5 Tratamento de Erros
- O sistema deve tratar erros de rede graciosamente
- O sistema deve usar dados em cache quando API falhar
- O sistema deve exibir mensagem quando dados estiverem desatualizados
- Retry automático após 10 segundos em caso de erro

---

## 11. Performance

### 11.1 Carregamento
- As telas devem carregar em menos de 2 segundos
- O sistema deve usar skeleton loading para feedback visual
- O sistema deve carregar dados críticos primeiro (lazy loading)

### 11.2 Animações
- Todas as animações devem ser suaves (60 FPS)
- As animações devem ser canceláveis
- O sistema deve reduzir animações em dispositivos lentos

### 11.3 Memória
- O sistema deve liberar recursos ao sair de telas
- O sistema deve limitar cache de imagens
- O sistema deve usar paginação em listas longas

---

## 12. Acessibilidade

### 12.1 Leitores de Tela
- Todos os elementos interativos devem ter labels semânticos
- Os valores monetários devem ser lidos corretamente
- As variações devem incluir contexto (alta/baixa)

### 12.2 Contraste
- Todos os textos devem ter contraste mínimo de 4.5:1
- Os ícones devem ser distinguíveis
- Os estados (ativo/inativo) devem ser claros

### 12.3 Tamanhos
- Áreas de toque devem ter mínimo 44x44px
- Textos devem ter tamanho mínimo de 12px
- O sistema deve suportar fontes maiores do sistema

---

## 13. Multiplataforma

### 13.1 Android
- O sistema deve funcionar em Android 6.0+ (API 23+)
- O sistema deve seguir Material Design 3
- O sistema deve usar navegação por gestos

### 13.2 iOS
- O sistema deve funcionar em iOS 12+
- O sistema deve seguir Human Interface Guidelines
- O sistema deve usar navegação nativa do iOS

### 13.3 Web (Futuro)
- O sistema deve ser responsivo
- O sistema deve funcionar em navegadores modernos
- O sistema deve ter versão desktop otimizada

---

## 14. Segurança

### 14.1 Dados Sensíveis
- Valores monetários não devem ser logados
- Transações devem ser validadas no backend
- O sistema deve usar HTTPS para todas as requisições

### 14.2 Autenticação
- Todas as operações devem requerer autenticação
- Sessões expiradas devem redirecionar para login
- O sistema deve validar tokens em cada requisição

---

## 15. Testes

### 15.1 Cobertura
- Todas as funcionalidades críticas devem ter testes
- Cobertura mínima: 60%
- Testes de integração para fluxos principais

### 15.2 Tipos de Teste
- Unit tests: Models, Controllers, Services
- Widget tests: Componentes de UI
- Integration tests: Fluxos completos

---

## Priorização

### Fase 1 - MVP (Essencial)
1. ✅ Autenticação (JÁ FEITO)
2. 🔲 Navegação (Bottom Nav)
3. 🔲 Dashboard (Home)
4. 🔲 Lista de Mercados
5. 🔲 Detalhes da Cripto

### Fase 2 - Core
6. 🔲 Portfólio
7. 🔲 Transações (Compra/Venda)
8. 🔲 Histórico de Atividades

### Fase 3 - Melhorias
9. 🔲 Perfil/Configurações
10. 🔲 Favoritos
11. 🔲 Busca Avançada
12. 🔲 Notificações

### Fase 4 - Avançado
13. 🔲 Gráficos Interativos
14. 🔲 Alertas de Preço
15. 🔲 Modo Escuro
16. 🔲 Múltiplas Moedas

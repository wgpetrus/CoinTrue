# Plano de Implementação - App CoinTrue

## Visão Geral

Implementação incremental do app de criptomoedas, **tela por tela**, garantindo que cada funcionalidade esteja **100% funcional** antes de prosseguir.

### Diálogos no chat de cada task
Os diálogos no chat de cada task devem ser escritos em **PORTUGUÊS DO BRASIL**.

---

## Tasks

<!-- ### Fase 0: Preparação

- [ ] 0.1 Adicionar dependências no pubspec.yaml
- [ ] 0.2 Criar estrutura de pastas
- [ ] 0.3 Criar modelos de dados
- [ ] 0.4 Implementar CoinbaseApiService -->

<!-- ### Fase 1: Navegação e Estrutura

- [ ] 1.1 Criar MainScreen com Bottom Navigation
- [ ] 1.2 Criar placeholders para cada tela
- [ ] 1.3 Atualizar roteamento -->

<!-- ### Fase 2: Dashboard (Home) - Parte 1

- [ ] 2.1 Criar CryptoController
- [ ] 2.2 Criar WalletController
- [ ] 2.3 Implementar layout do Dashboard
- [ ] 2.4 Criar BalanceCard
- [ ] 2.5 Criar StatCards
- [ ] 2.6 Criar ActionButtons -->

<!-- ### Fase 3: Dashboard (Home) - Parte 2

- [ ] 3.1 Criar CryptoListItem widget
- [ ] 3.2 Integrar lista de criptos
- [ ] 3.3 Implementar atualização automática
- [ ] 3.4 Implementar tratamento de erros -->


<!-- ### Fase 4: Mercados

- [ ] 4.1 Criar MarketsScreen layout
- [ ] 4.2 Implementar busca
- [ ] 4.3 Implementar filtros
- [ ] 4.4 Criar CryptoMarketItem widget
- [ ] 4.5 Integrar lista completa -->

<!-- ### Fase 5: Detalhes da Cripto

- [ ] 5.1 Criar CryptoDetailScreen layout
- [ ] 5.2 Implementar estatísticas detalhadas
- [ ] 5.3 Criar PriceChart widget
- [ ] 5.4 Implementar seletor de período
- [ ] 5.5 Adicionar botões de ação -->

<!-- ### Fase 6: Transações (Compra/Venda)

- [x] 6.1 Criar TransactionController
- [x] 6.2 Criar TransactionScreen layout
- [x] 6.3 Implementar formulário
- [x] 6.4 Implementar validações
- [x] 6.5 Implementar confirmação
- [x] 6.6 Implementar processamento -->

<!-- ### Fase 7: Portfólio

- [x] 7.1 Criar PortfolioController
- [x] 7.2 Criar PortfolioScreen layout
- [x] 7.3 Criar PortfolioValueCard
- [x] 7.4 Criar PortfolioAssetItem widget
- [x] 7.5 Integrar lista de ativos
- [x] 7.6 Implementar gráfico de distribuição -->

<!-- ### Fase 8: Atividade (Histórico)

- [x] 8.1 Criar ActivityScreen layout
- [x] 8.2 Criar TransactionListItem widget
- [x] 8.3 Integrar lista de transações
- [x] 8.4 Implementar filtros
- [x] 8.5 Implementar estado vazio -->

<!-- ### Fase 9: Configurações (ProfileScreen)

- [x] 9.1 Criar ProfileScreen layout
- [x] 9.2 Implementar seção Conta
- [x] 9.3 Implementar seção Segurança
- [x] 9.4 Implementar seção Preferências
- [x] 9.5 Implementar seção Sobre
- [x] 9.6 Integrar com navegação
- [x] 9.7 Adicionar funcionalidades de Sair e Excluir Conta -->

<!-- ### Fase 10: Melhorias e Polimento

- [x] 10.1 Implementar favoritos
- [x] 10.2 Melhorar gráficos
- [x] 10.3 Adicionar animações
- [x] 10.4 Implementar pull-to-refresh
- [x] 10.5 Otimizar performance -->

### Fase 11: Testes

- [ ] 11.1 Testes unitários - Models
- [ ] 11.2 Testes unitários - Controllers
- [ ] 11.3 Testes unitários - Services
- [ ] 11.4 Testes de widget
- [ ] 11.5 Testes de integração

---

- Verificar conexão com internet
- Verificar firewall/proxy
- Verificar rate limit
- Avisar o usuário imediatamente

---

## ✅ Garantia de Funcionalidade

### Cada Task Deve:
1. Ser implementada completamente
2. Ser testada manualmente
3. Funcionar 100% antes de prosseguir
4. Ter tratamento de erros

### Dados 100% Funcionais:
- ✅ Preços: REAIS da API Coinbase
- ✅ Saldo: Simulado (R$ 10.000,00 inicial)
- ✅ Transações: Simuladas mas persistidas
- ✅ Portfólio: Calculado com preços reais

### Não Avançar Sem:
- ✅ Testar a funcionalidade atual
- ✅ Corrigir bugs encontrados
- ✅ Confirmar com o usuário

---

## 📋 Ordem de Execução

**FAZER TELA POR TELA, NÃO TUDO DE UMA VEZ!**

1. Fase 0: Preparação (base)
2. Fase 1: Navegação (estrutura)
3. Fase 2-3: Dashboard (primeira tela funcional)
4. Fase 4: Mercados
5. Fase 5: Detalhes
6. Fase 6: Transações
7. Fase 7: Portfólio
8. Fase 8: Atividade
9. Fase 9: Configurações
10. Fase 10: Melhorias
11. Fase 11: Testes

---
inclusion: always
---

# Guia de Consistência de UI - CoinTrue

## Princípios de Design

Este guia define o design system do aplicativo CoinTrue.

### Cores

#### Cores Principais
- **Azul Primário (#2563EB)**: Cor primária - fundos de botões, cards, bordas
- **Azul Escuro (#1E40AF)**: Para ícones e textos em fundo branco (melhor contraste)
- **Roxo Secundário (#7C3AED)**: Elementos secundários, gradientes
- **Cinza Escuro (#545454)**: Textos primários e títulos
- **Cinza Médio (#9E9E9E)**: Textos secundários e subtítulos
- **Cinza Claro (#F5F5F5)**: Backgrounds de cards e containers
- **Branco (#FFFFFF)**: Background principal das telas

**IMPORTANTE - Contraste:**
- ✅ Usar **Azul Escuro** para ícones e textos em fundo branco
- ✅ Usar **Azul Primário** para fundos de botões e cards
- ✅ Usar **Roxo Secundário** para elementos de destaque e gradientes
- ✅ Excelente contraste em todas as combinações (WCAG AAA)

#### Cores de Status
- **Verde (#4CAF50)**: Valores positivos, compras, sucesso
- **Vermelho (#F44336)**: Valores negativos, vendas, erros
- **Azul (#2196F3)**: Informações, links, elementos interativos secundários

#### Cores de Criptomoedas (Ícones)
- **Bitcoin**: #FF9800 (Laranja)
- **Ethereum**: #9C27B0 (Roxo)
- **Cardano**: #2196F3 (Azul)
- **Solana**: #E91E63 (Rosa/Magenta)

### Botões

#### Botões Primários (Ação Principal)
- Fundo: **AZUL PRIMÁRIO (#2563EB)**
- Texto: **BRANCO (#FFFFFF)** - SEMPRE usar branco para contraste
- Elevação: **0** (sem sombra)
- Border radius: **16px** (mais arredondado)
- Altura: **56px**
- Padding horizontal: **24px**
- Texto: Branco, peso 600, tamanho 16px
- Exemplo: Botão "+" flutuante, botões de ação

**IMPORTANTE:**
```dart
ElevatedButton.styleFrom(
  backgroundColor: colors.primary,
  foregroundColor: colors.white, // SEMPRE branco
)
```

#### Botões Secundários (Login Social, etc)
- Fundo: **BRANCO**
- Borda: **Cinza clara (#E0E0E0)** (1px)
- Elevação: **0**
- Border radius: **16px**
- Altura: **56px**
- Padding horizontal: **24px**
- Texto: Cinza escuro, peso 600, tamanho 16px

#### Botões de Filtro/Tabs
- Fundo normal: **Transparente ou Cinza muito claro (#FAFAFA)**
- Fundo ativo: **AZUL PRIMÁRIO (#2563EB)**
- Texto normal: **Cinza médio (#9E9E9E)**
- Texto ativo: **Branco**
- Border radius: **12px**
- Altura: **40px**
- Padding horizontal: **20px**
- Texto: Peso 600, tamanho 14px

#### Botões Circulares (Ícones)
- Tamanho: **48x48px** ou **56x56px**
- Border radius: **50%** (círculo perfeito)
- Fundo: Cor da ação (verde para receber, amarelo para trocar, etc)
- Ícone: Branco, 24x24px
- Elevação: **0**

#### Estados dos Botões
- **Normal**: Estilo padrão
- **Pressed**: Opacidade 0.8
- **Desabilitado**: Opacidade 0.4
- **Loading**: Spinner branco (botões primários) ou cinza (secundários)

### Logos e Ícones

#### Logo do App
- **NUNCA** usar círculo colorido ao redor
- Exibir a logo diretamente, sem containers decorativos
- Tamanhos recomendados:
  - Splash Screen: 200x200px
  - Login Screen: 180x200px (mobile), 220x220px (tablet)
  - Header: 40x40px
  - Outras telas: 120x120px (máximo)

#### Ícones de Criptomoedas
- Formato: **Círculo com letra inicial**
- Tamanho: **48x48px** (listas), **56x56px** (destaque)
- Border radius: **50%** (círculo perfeito)
- Letra: Branca, bold, tamanho 20-24px
- Background: Cor específica da cripto (Bitcoin laranja, Ethereum roxo, etc)

#### Ícones de Ação
- Tamanho: **24x24px**
- Cor: Branca (em botões coloridos) ou Cinza escuro (em backgrounds claros)
- Estilo: Outline (contorno) ou Filled (preenchido) conforme contexto

#### Ícones de Provedores (Google, Apple)
- Tamanho: 24x24px
- Sem backgrounds ou círculos ao redor
- Usar as logos oficiais dos assets

### Espaçamentos

Sistema de espaçamento baseado em múltiplos de 4px (4, 8, 12, 16, 20, 24, 32, 40, 48).

#### Padding de Telas
- Mobile: **20px** horizontal, **24px** vertical
- Tablet: **40px** horizontal, **32px** vertical
- Entre o conteúdo e as bordas da tela: **20px**

#### Espaçamento entre Elementos
- Entre título e subtítulo: **4px**
- Entre seções pequenas: **12px**
- Entre seções médias: **16px**
- Entre seções grandes: **24px**
- Entre cards na lista: **12px**
- Entre botões: **12px**
- Padding interno de cards: **16px** a **20px**
- Padding interno de botões: **16px** horizontal, **12px** vertical

### Tipografia

Fonte padrão: **System Font** (San Francisco no iOS, Roboto no Android)

#### Hierarquia de Texto

**Títulos de Página**
- Tamanho: **24px**
- Peso: **Bold (700)**
- Cor: Cinza escuro (#545454)
- Line height: 1.3
- Exemplo: "Mercados", "Portfólio", "Atividade"

**Subtítulos de Página**
- Tamanho: **14px**
- Peso: **Regular (400)**
- Cor: Cinza médio (#9E9E9E)
- Line height: 1.4
- Exemplo: "Preços em tempo real", "Suas transações"

**Valores Monetários Grandes**
- Tamanho: **32px** a **36px**
- Peso: **Bold (700)**
- Cor: Cinza escuro (#545454)
- Exemplo: "$48,574.32"

**Valores Monetários Médios**
- Tamanho: **16px** a **18px**
- Peso: **SemiBold (600)**
- Cor: Cinza escuro (#545454)
- Exemplo: Preços em listas

**Valores Monetários Pequenos**
- Tamanho: **14px**
- Peso: **Medium (500)**
- Cor: Cinza escuro (#545454)

**Porcentagens/Variações**
- Tamanho: **12px** a **14px**
- Peso: **Medium (500)**
- Cor: Verde (#4CAF50) para positivo, Vermelho (#F44336) para negativo
- Sempre com sinal + ou -
- Exemplo: "+8.24%", "-2.15%"

**Labels/Legendas**
- Tamanho: **12px**
- Peso: **Regular (400)**
- Cor: Cinza médio (#9E9E9E)
- Exemplo: "BTC", "ETH", timestamps

**Texto de Corpo**
- Tamanho: **14px**
- Peso: **Regular (400)**
- Cor: Cinza escuro (#545454)
- Line height: 1.5

**Botões**
- Tamanho: **16px**
- Peso: **SemiBold (600)**
- Cor: Depende do tipo de botão

### Cards e Containers

#### Cards Principais (Hero Card)
- Background: **Gradiente ou cor sólida** (adaptar para amarelo)
- Elevação: **4** (sombra média)
- Border radius: **24px** (bem arredondado)
- Padding interno: **24px**
- Exemplo: Card de saldo total na home

#### Cards de Lista
- Background: **Branco**
- Elevação: **0** (sem sombra)
- Border: **1px sólida, cinza muito clara (#F0F0F0)**
- Border radius: **16px**
- Padding interno: **16px**
- Espaçamento entre cards: **12px**
- Exemplo: Lista de criptomoedas, transações

#### Cards de Informação
- Background: **Cinza muito claro (#FAFAFA)** ou **Branco**
- Elevação: **0**
- Border radius: **16px**
- Padding interno: **16px** a **20px**
- Exemplo: Cards de "Lucro 24h" e "Ativos"

#### Containers de Seção
- Background: **Branco**
- Border radius: **20px** (topo) ou **0** (se ocupa tela toda)
- Padding interno: **20px**
- Margin top: **16px** (se não for primeira seção)

#### Input Fields
- Background: **Cinza muito claro (#F5F5F5)**
- Borda: **0** (sem borda no estado normal)
- Borda focada: **Azul Primário (#2563EB), 2px**
- Border radius: **16px**
- Altura: **48px** a **56px**
- Padding horizontal: **16px**
- Placeholder: Cinza médio (#9E9E9E)
- Texto: Cinza escuro (#545454), 16px

#### Search Fields
- Background: **Cinza muito claro (#F5F5F5)**
- Ícone de busca: Cinza médio, 20x20px, à esquerda
- Border radius: **16px**
- Altura: **48px**
- Padding: **16px** (com espaço para ícone)

### Navegação

#### Bottom Navigation Bar
- Background: **Branco**
- Altura: **64px** (+ safe area)
- Elevação: **8** (sombra para cima)
- Border radius: **0** (ocupa largura total)
- Ícones: **24x24px**
- Cor ícone inativo: Cinza médio (#9E9E9E)
- Cor ícone ativo: Azul Primário (#2563EB)
- Label: 12px, peso 500
- Cor label inativo: Cinza médio
- Cor label ativo: Azul Primário
- Espaçamento entre ícones: Distribuído igualmente

#### Top App Bar
- Background: **Branco** ou **Transparente**
- Altura: **56px** (+ safe area)
- Elevação: **0** (sem sombra)
- Padding horizontal: **20px**
- Logo: 40x40px (esquerda)
- Ícones de ação: 24x24px (direita)
- Espaçamento entre ícones: **12px**

### Loading States

#### Overlay de Loading
- Background: Preto com alpha 0.5
- Spinner: Azul Primário (#2563EB)
- Texto: Branco, 16px

#### Loading em Botões
- Spinner: Branco (botões primários) ou Cinza escuro (secundários)
- Tamanho: 20x20px, stroke 2.5px
- Texto: "Processando..." ou sem texto
- Botão mantém tamanho e estilo normal

#### Skeleton Loading (Listas)
- Background: Cinza muito claro (#F5F5F5)
- Animação: Shimmer da esquerda para direita
- Border radius: Igual ao elemento final

### Mensagens e Notificações

#### Snackbar de Sucesso
- Background: Verde (#4CAF50)
- Texto: Branco, 14px, peso 500
- Ícone: Check branco, 20x20px
- Border radius: 12px
- Padding: 16px horizontal, 12px vertical
- Posição: Bottom (acima da nav bar)
- Duração: 3 segundos

#### Snackbar de Erro
- Background: Vermelho (#F44336)
- Texto: Branco, 14px, peso 500
- Ícone: X ou ! branco, 20x20px
- Border radius: 12px
- Padding: 16px horizontal, 12px vertical
- Posição: Bottom (acima da nav bar)
- Duração: 4 segundos

#### Error Message Widget (Inline)
- Background: Vermelho (#F44336) com alpha 0.1
- Borda: Vermelho, 1px
- Ícone: Vermelho, 20px
- Texto: Vermelho escuro, 14px
- Border radius: 12px
- Padding: 12px

#### Badge de Notificação
- Background: Vermelho (#F44336)
- Tamanho: 8x8px (dot) ou 20x20px (com número)
- Border radius: 50% (círculo)
- Texto: Branco, 10px, bold
- Posição: Top-right do ícone

### Listas e Items

#### Item de Lista de Criptomoeda
- Altura: **72px**
- Padding: **16px**
- Background: Branco
- Border radius: 16px
- Layout: Ícone (48px) | Nome + Símbolo | Preço + Variação
- Espaçamento entre ícone e texto: **12px**
- Espaçamento entre elementos: **8px**

#### Item de Transação
- Altura: **80px**
- Padding: **16px**
- Background: Branco
- Border radius: 16px
- Layout: Ícone de ação (40px, background colorido) | Tipo + Quantidade | Valor + Data
- Ícone de ação: Verde (compra), Vermelho (venda), Azul (troca)

#### Dividers
- Cor: Cinza muito claro (#F0F0F0)
- Espessura: 1px
- Margin: 12px vertical

### Gráficos

#### Gráfico de Linha
- Cor da linha: Azul Primário (#2563EB) ou Roxo Secundário (#7C3AED)
- Espessura: 2px
- Background do gráfico: Gradiente suave da cor da linha (alpha 0.1 no topo, 0 embaixo)
- Altura: 120px a 200px
- Border radius do container: 16px

#### Gráfico de Pizza (Donut)
- Espessura do anel: 24px
- Cores: Usar cores específicas de cada cripto
- Tamanho: 120x120px
- Centro: Vazio (donut)

### Responsividade

#### Breakpoints
- Mobile: < 600px
- Tablet: >= 600px
- Desktop: >= 1024px

#### Ajustes por Dispositivo
- Mobile: 1 coluna, padding 20px
- Tablet: 2 colunas em algumas seções, padding 40px
- Desktop: Até 3 colunas, max-width 1200px centralizado

## Regras Importantes

1. **NUNCA** usar círculos coloridos ao redor de logos do app
2. **SEMPRE** usar fundos azuis em botões primários de ação
3. **SEMPRE** usar border radius de 16px em cards e botões (mais arredondado)
4. **SEMPRE** usar as cores definidas em `AppConstants.colors` (primary, primaryDark, secondary)
5. **SEMPRE** usar espaçamentos múltiplos de 4px
6. **SEMPRE** usar ícones de criptomoedas como círculos coloridos com letras
7. **SEMPRE** mostrar variações de preço com cores (verde +, vermelho -)
8. **SEMPRE** manter elevação 0 em botões (design flat)
9. **SEMPRE** usar sombras suaves apenas em cards principais
10. **SEMPRE** garantir bom contraste entre texto e fundo (WCAG AAA)
11. **SEMPRE** usar fonte system (San Francisco/Roboto)
12. **SEMPRE** alinhar elementos com grid de 4px
13. **SEMPRE** usar gradiente azul→roxo em cards hero e elementos de destaque

## Arquivos de Referência

- `lib/utils/constants.dart` - Cores (primary, primaryDark, secondary), strings e configurações
- `lib/views/widgets/social_login_button.dart` - Exemplo de botão bem implementado
- `lib/views/screens/splash_screen.dart` - Exemplo de logo sem decoração
- `lib/views/screens/login_screen.dart` - Exemplo de layout responsivo

## Paleta de Cores Atualizada

### Cores Primárias
- **primary** (#2563EB): Azul vibrante - Botões, fundos, elementos ativos
- **primaryDark** (#1E40AF): Azul profundo - Ícones e textos em fundo branco
- **secondary** (#7C3AED): Roxo - Elementos secundários, gradientes

### Uso Correto
- ✅ Botões primários: `backgroundColor: colors.primary` + `foregroundColor: colors.white`
- ✅ Ícones ativos: `colors.primaryDark`
- ✅ Gradientes hero: `colors.primary` → `colors.secondary`
- ✅ Tabs ativas: `colors.primary` com texto branco
- ✅ Focus states: `colors.primary`
- ❌ NUNCA usar yellow ou yellowDark (removidos)
- ❌ NUNCA usar texto escuro em botões com fundo colorido


## Componentes Específicos

### Card de Saldo Total (Hero)
- Background: Gradiente Azul → Roxo (linear-gradient(135deg, #2563EB 0%, #7C3AED 100%))
- Border radius: 24px
- Padding: 24px
- Elevação: 4
- Conteúdo:
  - Label "Saldo Total": 14px, branco com alpha 0.9
  - Valor: 36px, bold, branco
  - Variação: 14px, branco com alpha 0.9, com ícone de seta
  - Botões de ação: 3 botões circulares (56x56px) com ícones brancos
  - Ícone de visibilidade: Top-right, 24px, branco com alpha 0.7

### Card de Estatística (Lucro 24h, Ativos)
- Background: Cinza muito claro (#FAFAFA)
- Border radius: 16px
- Padding: 16px
- Layout vertical:
  - Label: 14px, cinza médio
  - Valor principal: 24px, bold, cinza escuro
  - Valor secundário: 12px, verde ou cinza médio

### Item de Criptomoeda
- Layout horizontal: Ícone | Conteúdo | Preço
- Ícone: Círculo 48x48px, cor específica, letra branca
- Nome: 16px, semibold, cinza escuro
- Símbolo: 12px, regular, cinza médio
- Preço: 16px, semibold, cinza escuro, alinhado à direita
- Variação: 12px, medium, verde/vermelho, alinhado à direita

### Filtros/Tabs Horizontais
- Container: Scroll horizontal se necessário
- Espaçamento entre tabs: 8px
- Tab inativo: Background transparente, texto cinza médio
- Tab ativo: Background azul primário, texto branco
- Border radius: 12px
- Padding: 12px horizontal, 8px vertical

### Search Bar
- Background: Cinza muito claro (#F5F5F5)
- Ícone de busca: Esquerda, cinza médio
- Placeholder: Cinza médio, 14px
- Border radius: 16px
- Altura: 48px
- Sem borda no estado normal

## Animações e Transições

### Transições de Tela
- Duração: 300ms
- Easing: Ease-in-out
- Tipo: Slide horizontal (push/pop)

### Hover/Press States
- Duração: 150ms
- Easing: Ease-out
- Efeito: Opacidade 0.8 ou scale 0.98

### Loading
- Spinner: Rotação contínua, 1s por volta
- Shimmer: Movimento horizontal, 1.5s por ciclo

### Scroll
- Comportamento: Smooth
- Bounce: Ativado (iOS style)

## Acessibilidade

### Tamanhos Mínimos
- Área de toque: Mínimo 44x44px
- Texto: Mínimo 12px (apenas para labels secundárias)
- Contraste: Mínimo 4.5:1 para texto normal

### Estados de Foco
- Outline: Amarelo, 2px
- Offset: 2px

### Suporte a Dark Mode
- Preparar variáveis de cor para futuro suporte
- Manter contraste adequado em ambos os modos

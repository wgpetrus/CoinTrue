---
inclusion: always
---

# Guia de Animações e Ícones - CoinTrue

## Bibliotecas Utilizadas

### Ícones
- **Material Icons** (nativo): Ícones básicos do Material Design
- **Phosphor Icons** (phosphor_flutter): Ícones modernos e consistentes - **USAR COMO PADRÃO**
- **flutter_svg**: Para logos e ícones customizados em SVG

### Animações
- **flutter_animate**: Animações declarativas simples - **USAR COMO PADRÃO**
- **lottie**: Animações complexas em JSON (After Effects)
- **Animações nativas do Flutter**: Para transições e animações customizadas

## Padrão de Uso de Ícones

### Phosphor Icons (Padrão Principal)

**Quando usar:**
- Ícones de navegação (home, portfólio, mercados, atividade)
- Ícones de ação (enviar, receber, trocar, adicionar)
- Ícones de interface (busca, filtro, configurações, notificação)
- Ícones de status (check, erro, aviso, info)

**Como usar:**
```dart
import 'package:phosphor_flutter/phosphor_flutter.dart';

// Ícone regular (outline)
PhosphorIcon(
  PhosphorIcons.house(),
  size: 24,
  color: colors.mediumGray,
)

// Ícone preenchido (fill)
PhosphorIcon(
  PhosphorIcons.house(PhosphorIconsStyle.fill),
  size: 24,
  color: colors.yellow,
)

// Ícone com peso customizado
PhosphorIcon(
  PhosphorIcons.arrowUp(PhosphorIconsStyle.bold),
  size: 20,
  color: colors.success,
)
```

**Tamanhos padrão:**
- Navegação: 24px
- Ação em botões: 20px
- Lista/Cards: 20px
- Pequenos (badges, etc): 16px

**Estilos disponíveis:**
- `regular` (padrão): Outline fino
- `fill`: Preenchido
- `bold`: Outline grosso
- `light`: Outline muito fino
- `duotone`: Dois tons

### Material Icons (Fallback)

**Quando usar:**
- Apenas quando não houver equivalente no Phosphor
- Ícones muito específicos do Material Design

```dart
Icon(
  Icons.account_balance_wallet,
  size: 24,
  color: colors.darkGray,
)
```

### SVG Icons (Logos e Customizados)

**Quando usar:**
- Logos de criptomoedas
- Logos de provedores (Google, Apple)
- Ícones customizados do design

**Como usar:**
```dart
import 'package:flutter_svg/flutter_svg.dart';

SvgPicture.asset(
  'assets/icons/bitcoin.svg',
  width: 24,
  height: 24,
  colorFilter: ColorFilter.mode(
    colors.bitcoin,
    BlendMode.srcIn,
  ),
)
```

**Estrutura de pastas:**
```
assets/
  icons/
    crypto/
      bitcoin.svg
      ethereum.svg
      cardano.svg
    social/
      google.svg
      apple.svg
  images/
    logos/
      logo_app.png
```

## Padrão de Uso de Animações

### flutter_animate (Padrão Principal)

**Quando usar:**
- Entrada de elementos na tela
- Hover/Press states
- Transições simples
- Feedback visual

**Animações padrão do projeto:**

**1. Fade In (Entrada de elementos)**
```dart
Widget.animate()
  .fadeIn(duration: 300.ms, curve: Curves.easeOut)
```

**2. Slide In (Entrada de cards/listas)**
```dart
Widget.animate()
  .slideY(begin: 0.2, duration: 300.ms, curve: Curves.easeOut)
  .fadeIn(duration: 300.ms)
```

**3. Scale (Press state de botões)**
```dart
Widget.animate(
  onPlay: (controller) => controller.repeat(reverse: true),
)
  .scale(begin: Offset(1, 1), end: Offset(0.98, 0.98), duration: 150.ms)
```

**4. Shimmer (Loading skeleton)**
```dart
Widget.animate(
  onPlay: (controller) => controller.repeat(),
)
  .shimmer(duration: 1500.ms, color: Colors.white.withOpacity(0.5))
```

**5. Bounce (Feedback de sucesso)**
```dart
Widget.animate()
  .scale(begin: Offset(0.8, 0.8), duration: 200.ms, curve: Curves.easeOut)
  .then()
  .scale(begin: Offset(1.1, 1.1), duration: 100.ms)
  .then()
  .scale(begin: Offset(1, 1), duration: 100.ms)
```

### Lottie (Animações Complexas)

**Quando usar:**
- Loading states elaborados
- Animações de sucesso/erro
- Onboarding
- Estados vazios (empty states)

**Como usar:**
```dart
import 'package:lottie/lottie.dart';

Lottie.asset(
  'assets/animations/loading.json',
  width: 200,
  height: 200,
  fit: BoxFit.contain,
)

// Com controle
Lottie.asset(
  'assets/animations/success.json',
  repeat: false,
  onLoaded: (composition) {
    controller.duration = composition.duration;
    controller.forward();
  },
)
```

**Estrutura de pastas:**
```
assets/
  animations/
    loading.json
    success.json
    error.json
    empty_state.json
```

### Animações Nativas do Flutter

**Quando usar:**
- Transições de tela
- Animações muito customizadas
- Performance crítica

**Transição de tela padrão:**
```dart
Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => NextScreen(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;
      
      var tween = Tween(begin: begin, end: end).chain(
        CurveTween(curve: curve),
      );
      
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
    transitionDuration: Duration(milliseconds: 300),
  ),
);
```

## Mapeamento de Ícones do Projeto

### Navegação (Bottom Nav)
- **Início**: `PhosphorIcons.house()`
- **Portfólio**: `PhosphorIcons.briefcase()`
- **Mercados**: `PhosphorIcons.chartLine()`
- **Atividade**: `PhosphorIcons.clockCounterClockwise()`

### Ações Principais
- **Enviar**: `PhosphorIcons.arrowUp()` em círculo verde
- **Receber**: `PhosphorIcons.arrowDown()` em círculo verde
- **Trocar**: `PhosphorIcons.arrowsLeftRight()` em círculo roxo
- **Adicionar**: `PhosphorIcons.plus()`
- **Buscar**: `PhosphorIcons.magnifyingGlass()`
- **Filtrar**: `PhosphorIcons.funnelSimple()`
- **Configurações**: `PhosphorIcons.gear()`
- **Notificação**: `PhosphorIcons.bell()`

### Status e Feedback
- **Sucesso**: `PhosphorIcons.checkCircle(PhosphorIconsStyle.fill)`
- **Erro**: `PhosphorIcons.xCircle(PhosphorIconsStyle.fill)`
- **Aviso**: `PhosphorIcons.warningCircle(PhosphorIconsStyle.fill)`
- **Info**: `PhosphorIcons.info(PhosphorIconsStyle.fill)`
- **Carregando**: `PhosphorIcons.circleNotch()` com rotação

### Transações
- **Compra**: `PhosphorIcons.arrowDown()` verde
- **Venda**: `PhosphorIcons.arrowUp()` vermelho
- **Troca**: `PhosphorIcons.arrowsLeftRight()` azul

### Outros
- **Visibilidade ON**: `PhosphorIcons.eye()`
- **Visibilidade OFF**: `PhosphorIcons.eyeSlash()`
- **Favorito**: `PhosphorIcons.star(PhosphorIconsStyle.fill)`
- **Não favorito**: `PhosphorIcons.star()`
- **Seta para cima**: `PhosphorIcons.caretUp()`
- **Seta para baixo**: `PhosphorIcons.caretDown()`

## Regras de Consistência

1. **SEMPRE** usar Phosphor Icons como primeira opção
2. **SEMPRE** usar os tamanhos padrão (16, 20, 24px)
3. **SEMPRE** usar flutter_animate para animações simples
4. **SEMPRE** usar as durações padrão (150ms, 300ms, 500ms)
5. **SEMPRE** usar Curves.easeOut para entrada, Curves.easeIn para saída
6. **NUNCA** misturar estilos de ícones na mesma tela
7. **NUNCA** usar animações muito longas (> 500ms para feedback)
8. **SEMPRE** testar animações em dispositivos reais (não só emulador)

## Performance

### Ícones
- Phosphor Icons são renderizados como IconData (muito performático)
- SVG deve ser usado apenas quando necessário
- Cache SVGs quando possível

### Animações
- flutter_animate é otimizado e performático
- Lottie pode ser pesado, usar com moderação
- Evitar muitas animações simultâneas
- Usar `RepaintBoundary` quando necessário

## Exemplos de Uso no Projeto

### Botão com ícone e animação
```dart
ElevatedButton(
  onPressed: () {},
  child: Row(
    children: [
      PhosphorIcon(
        PhosphorIcons.plus(PhosphorIconsStyle.bold),
        size: 20,
        color: Colors.white,
      ),
      SizedBox(width: 8),
      Text('Adicionar'),
    ],
  ),
).animate()
  .scale(duration: 150.ms, curve: Curves.easeOut);
```

### Card de lista com entrada animada
```dart
Card(
  child: ListTile(
    leading: PhosphorIcon(
      PhosphorIcons.currencyBtc(PhosphorIconsStyle.fill),
      size: 24,
      color: colors.bitcoin,
    ),
    title: Text('Bitcoin'),
    trailing: Text('+8.24%'),
  ),
).animate()
  .fadeIn(duration: 300.ms)
  .slideY(begin: 0.1, duration: 300.ms);
```

### Loading state
```dart
Center(
  child: PhosphorIcon(
    PhosphorIcons.circleNotch(),
    size: 48,
    color: colors.yellow,
  ).animate(
    onPlay: (controller) => controller.repeat(),
  ).rotate(duration: 1000.ms),
)
```

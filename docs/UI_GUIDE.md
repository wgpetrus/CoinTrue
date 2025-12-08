# 🎨 Guia de UI/UX

Guia completo do Design System do CoinTrue.

---

## 🎨 Paleta de Cores

### Cores Principais

```dart
// Amarelo - Cor primária
primary:        #FFE70F  // Botões, destaques, ações principais
primaryDark:    #FFC107  // Ícones, variações

// Neutras
white:          #FFFFFF  // Backgrounds, textos em fundos escuros
darkGray:       #545454  // Textos principais
mediumGray:     #9E9E9E  // Textos secundários
lightGray:      #F5F5F5  // Backgrounds de cards

// Status
success:        #4CAF50  // Verde - Compras, positivo
error:          #F44336  // Vermelho - Vendas, negativo
info:           #2196F3  // Azul - Informações

// Criptomoedas
bitcoin:        #FF9800  // Laranja
ethereum:       #9C27B0  // Roxo
cardano:        #2196F3  // Azul
solana:         #E91E63  // Rosa/Magenta
```

### Uso de Cores

| Elemento | Cor | Contraste |
|----------|-----|-----------|
| Botão Primário | Amarelo (#FFE70F) | Texto Branco |
| Botão Secundário | Branco | Texto Escuro |
| Background | Branco | - |
| Card | Cinza Claro (#F5F5F5) | - |
| Texto Principal | Cinza Escuro (#545454) | - |
| Texto Secundário | Cinza Médio (#9E9E9E) | - |

---

## 🔤 Tipografia

### Fonte
**System Font** (San Francisco no iOS, Roboto no Android)

### Hierarquia

```dart
// Títulos de Página
fontSize: 24px
fontWeight: Bold (700)
color: darkGray

// Subtítulos
fontSize: 14px
fontWeight: Regular (400)
color: mediumGray

// Valores Monetários Grandes
fontSize: 32-36px
fontWeight: Bold (700)
color: darkGray

// Valores Monetários Médios
fontSize: 16-18px
fontWeight: SemiBold (600)
color: darkGray

// Porcentagens/Variações
fontSize: 12-14px
fontWeight: Medium (500)
color: success/error (com sinal +/-)

// Labels
fontSize: 12px
fontWeight: Regular (400)
color: mediumGray

// Botões
fontSize: 16px
fontWeight: SemiBold (600)
```

---

## 🔘 Botões

### Botão Primário (Amarelo)

```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: colors.primary,      // #FFE70F
    foregroundColor: Colors.white,        // Texto BRANCO
    elevation: 0,                         // Sem sombra
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    padding: EdgeInsets.symmetric(
      horizontal: 24,
      vertical: 16,
    ),
  ),
  child: Text('Texto do Botão'),
)
```

### Botão Secundário (Branco)

```dart
OutlinedButton(
  style: OutlinedButton.styleFrom(
    backgroundColor: colors.white,
    foregroundColor: colors.darkGray,
    side: BorderSide(color: colors.mediumGray),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
  child: Text('Texto do Botão'),
)
```

### Botão de Ação (Circular)

```dart
Container(
  width: 56,
  height: 56,
  decoration: BoxDecoration(
    color: colors.success,
    shape: BoxShape.circle,
  ),
  child: Icon(
    PhosphorIcons.arrowUp(),
    color: Colors.white,
    size: 24,
  ),
)
```

---

## 📦 Cards

### Card Principal (Hero)

```dart
Container(
  padding: EdgeInsets.all(24),
  decoration: BoxDecoration(
    color: colors.primary,
    borderRadius: BorderRadius.circular(24),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 10,
        offset: Offset(0, 4),
      ),
    ],
  ),
  child: /* conteúdo */,
)
```

### Card de Lista

```dart
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: Color(0xFFF0F0F0),
      width: 1,
    ),
  ),
  child: /* conteúdo */,
)
```

---

## 🔤 Inputs

### Text Field

```dart
TextField(
  decoration: InputDecoration(
    filled: true,
    fillColor: colors.lightGray,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: colors.primary,
        width: 2,
      ),
    ),
    hintText: 'Digite aqui',
    hintStyle: TextStyle(color: colors.mediumGray),
  ),
)
```

### Search Field

```dart
TextField(
  decoration: InputDecoration(
    filled: true,
    fillColor: colors.lightGray,
    prefixIcon: Icon(
      PhosphorIcons.magnifyingGlass(),
      color: colors.mediumGray,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    hintText: 'Buscar...',
  ),
)
```

---

## 🎭 Ícones

### Biblioteca
**Phosphor Icons** (phosphor_flutter)

### Tamanhos Padrão
- **16px** - Badges, pequenos
- **20px** - Listas, cards
- **24px** - Navegação, ações
- **48px** - Ícones de criptomoedas

### Estilos
```dart
// Regular (outline)
PhosphorIcon(
  PhosphorIcons.house(),
  size: 24,
  color: colors.mediumGray,
)

// Fill (preenchido)
PhosphorIcon(
  PhosphorIcons.house(PhosphorIconsStyle.fill),
  size: 24,
  color: colors.primary,
)

// Bold
PhosphorIcon(
  PhosphorIcons.arrowUp(PhosphorIconsStyle.bold),
  size: 20,
  color: colors.success,
)
```

### Ícones de Criptomoedas

```dart
Container(
  width: 48,
  height: 48,
  decoration: BoxDecoration(
    color: colors.bitcoin, // Cor específica
    shape: BoxShape.circle,
  ),
  child: Center(
    child: Text(
      'B', // Letra inicial
      style: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
)
```

---

## 📏 Espaçamentos

### Sistema de Espaçamento
Baseado em múltiplos de **4px**

```dart
// Espaçamentos padrão
4px, 8px, 12px, 16px, 20px, 24px, 32px, 40px, 48px

// Padding de telas
Mobile:  20px horizontal, 24px vertical
Tablet:  40px horizontal, 32px vertical

// Entre elementos
Título ↔ Subtítulo:     4px
Seções pequenas:        12px
Seções médias:          16px
Seções grandes:         24px
Cards na lista:         12px
Padding interno cards:  16-20px
```

---

## ✨ Animações

### Biblioteca
**Flutter Animate** (flutter_animate)

### Animações Padrão

```dart
// Fade In
Widget.animate()
  .fadeIn(duration: 300.ms, curve: Curves.easeOut)

// Slide In
Widget.animate()
  .slideY(begin: 0.2, duration: 300.ms)
  .fadeIn(duration: 300.ms)

// Scale (Press)
Widget.animate()
  .scale(
    begin: Offset(1, 1),
    end: Offset(0.98, 0.98),
    duration: 150.ms,
  )

// Shimmer (Loading)
Widget.animate(
  onPlay: (controller) => controller.repeat(),
)
  .shimmer(
    duration: 1500.ms,
    color: Colors.white.withOpacity(0.5),
  )
```

### Durações
- **150ms** - Interações rápidas (press, hover)
- **300ms** - Transições padrão
- **500ms** - Animações complexas

---

## 📱 Responsividade

### Breakpoints

```dart
Mobile:   < 600px
Tablet:   >= 600px
Desktop:  >= 1024px
```

### Ajustes

```dart
// Mobile
padding: 20px
columns: 1

// Tablet
padding: 40px
columns: 2

// Desktop
padding: 60px
columns: 3
maxWidth: 1200px
```

---

## 🎯 Estados

### Loading

```dart
Center(
  child: CircularProgressIndicator(
    color: colors.primary,
  ),
)
```

### Error

```dart
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: colors.error.withOpacity(0.1),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: colors.error),
  ),
  child: Row(
    children: [
      Icon(PhosphorIcons.xCircle(), color: colors.error),
      SizedBox(width: 12),
      Text('Erro ao carregar'),
    ],
  ),
)
```

### Empty

```dart
Center(
  child: Column(
    children: [
      Icon(
        PhosphorIcons.tray(),
        size: 64,
        color: colors.mediumGray,
      ),
      SizedBox(height: 16),
      Text(
        'Nenhum item encontrado',
        style: TextStyle(color: colors.mediumGray),
      ),
    ],
  ),
)
```

---

## ✅ Checklist de UI

Ao criar novos componentes, verifique:

- [ ] Cores seguem a paleta definida
- [ ] Tipografia está consistente
- [ ] Espaçamentos são múltiplos de 4px
- [ ] Border radius é 16px (padrão)
- [ ] Botões primários têm texto branco
- [ ] Ícones são do Phosphor Icons
- [ ] Animações são suaves (300ms)
- [ ] Estados de loading/error/empty
- [ ] Responsivo (mobile/tablet)
- [ ] Contraste adequado (WCAG AA)

---

## 📚 Referências

- [Guia Completo de UI](.kiro/steering/ui-guidelines.md)
- [Guia de Animações](.kiro/steering/animations-icons-guidelines.md)
- [Phosphor Icons](https://phosphoricons.com/)
- [Material Design 3](https://m3.material.io/)

---

**Design consistente = Experiência de qualidade**

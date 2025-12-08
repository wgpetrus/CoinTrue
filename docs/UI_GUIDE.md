# 🎨 Guia de UI/UX

Guia completo do Design System do CoinTrue com suporte a **Light e Dark Mode**.

---

## 🎨 Paleta de Cores

### Light Mode (Padrão)

```dart
// Azul/Roxo - Cores primárias
primary:        #2563EB  // Azul vibrante - Botões, fundos, elementos ativos
primaryDark:    #1E40AF  // Azul profundo - Ícones e textos em fundo branco
secondary:      #7C3AED  // Roxo - Elementos secundários, gradientes

// Neutras
white:          #FFFFFF  // Backgrounds, textos em fundos escuros
darkGray:       #545454  // Textos principais
mediumGray:     #9E9E9E  // Textos secundários
lightGray:      #F5F5F5  // Backgrounds de cards
veryLightGray:  #F0F0F0  // Borders e dividers

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

### Dark Mode 🌙

```dart
// Backgrounds (mais escuros)
background:     #0F0F0F  // Preto OLED - Background principal
surface:        #1A1A1A  // Cinza escuro - Cards e containers
surfaceElevated: #242424  // Cinza mais claro - Cards elevados

// Textos (mais claros)
onBackground:   #E8E8E8  // Branco suave - Textos primários
onSurface:      #B0B0B0  // Cinza claro - Textos secundários
onSurfaceVariant: #8A8A8A // Cinza médio - Labels e placeholders

// Borders e dividers
outline:        #2F2F2F  // Borders sutis
outlineVariant: #1F1F1F  // Borders muito sutis

// Cores de marca (inalteradas)
primary:        #2563EB  // Azul vibrante
primaryDark:    #1E40AF  // Azul profundo
secondary:      #7C3AED  // Roxo

// Cores de status (ajustadas para dark)
success:        #4ECDC4  // Verde mais suave
error:          #FF6B6B  // Vermelho mais suave
info:           #45B7D1  // Azul mais suave
warning:        #FFD93D  // Amarelo mais suave
```

### Uso de Cores Adaptáveis

| Elemento | Light Mode | Dark Mode | Contraste |
|----------|------------|-----------|-----------|
| Background Principal | Branco (#FFFFFF) | Preto OLED (#0F0F0F) | - |
| Cards/Surface | Cinza Claro (#F5F5F5) | Cinza Escuro (#1A1A1A) | - |
| Texto Principal | Cinza Escuro (#1A1A1A) | Branco Suave (#E8E8E8) | 15.8:1 |
| Texto Secundário | Cinza Médio (#6B6B6B) | Cinza Claro (#B0B0B0) | 9.2:1 |
| Botão Primário | Azul (#2563EB) | Azul (#2563EB) | Texto Branco |
| Card Hero | Gradiente Azul→Roxo | Gradiente Azul→Roxo | Texto Branco |
| Borders | Cinza Claro (#E0E0E0) | Cinza Escuro (#2F2F2F) | - |
| Ícones Ativos | Azul Escuro (#1E40AF) | Azul Escuro (#1E40AF) | WCAG AAA |

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

### Botão Primário (Azul)

```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: colors.primary,      // #2563EB
    foregroundColor: colors.white,        // Texto BRANCO (SEMPRE)
    elevation: 0,                         // Sem sombra (flat design)
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
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        colors.primary,    // #2563EB
        colors.secondary,  // #7C3AED
      ],
    ),
    borderRadius: BorderRadius.circular(24),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 10,
        offset: Offset(0, 4),
      ),
    ],
  ),
  child: /* conteúdo com texto BRANCO */,
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
// Regular (outline) - Inativo
PhosphorIcon(
  PhosphorIcons.house(),
  size: 24,
  color: colors.mediumGray,
)

// Fill (preenchido) - Ativo
PhosphorIcon(
  PhosphorIcons.house(PhosphorIconsStyle.fill),
  size: 24,
  color: colors.primaryDark,  // Azul escuro para melhor contraste
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

## 🌙 Sistema de Temas

### Como Usar Cores Adaptáveis

```dart
import '../../../utils/theme_helper.dart';

Widget build(BuildContext context) {
  final colors = context.colors; // Extension method
  
  return Container(
    color: colors.surface,        // Adapta automaticamente
    child: Text(
      'Texto',
      style: TextStyle(
        color: colors.onSurface,   // Contraste perfeito
      ),
    ),
  );
}
```

### Toggle de Tema

```dart
import '../../widgets/common/theme_toggle.dart';

// Switch simples
ThemeToggle(style: ThemeToggleStyle.switch_)

// Botão com dropdown
ThemeToggle(style: ThemeToggleStyle.button)

// Lista de opções
ThemeToggle(style: ThemeToggleStyle.list)
```

---

## ✅ Checklist de UI

Ao criar novos componentes, verifique:

- [ ] **Cores adaptáveis:** Usar `context.colors` ao invés de cores fixas
- [ ] **Contraste WCAG AAA:** Testar em ambos os modos
- [ ] **Tipografia:** Consistente em light e dark
- [ ] **Espaçamentos:** Múltiplos de 4px
- [ ] **Border radius:** 16px (padrão)
- [ ] **Botões primários:** Fundo azul + texto BRANCO
- [ ] **Ícones:** Phosphor Icons com cores adaptáveis
- [ ] **Animações:** Suaves (300ms)
- [ ] **Estados:** Loading/error/empty em ambos os temas
- [ ] **Responsivo:** Mobile/tablet
- [ ] **Dark Mode:** Testar funcionalidade completa

---

## 📚 Referências

- [Guia Completo de UI](.kiro/steering/ui-guidelines.md)
- [Guia de Animações](.kiro/steering/animations-icons-guidelines.md)
- [Dark Mode - Guia de Migração](DARK_MODE_MIGRATION.md)
- [Dark Mode - Demo e Testes](DARK_MODE_DEMO.md)
- [Phosphor Icons](https://phosphoricons.com/)
- [Material Design 3](https://m3.material.io/)
- [WCAG AAA Guidelines](https://www.w3.org/WAI/WCAG21/Understanding/)

---

**Design consistente + Dark Mode = Experiência premium** 🌙✨

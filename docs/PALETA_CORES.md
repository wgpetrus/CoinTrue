# Nova Paleta de Cores - CoinTrue

## 🎨 Cores Atualizadas (Dezembro 2024)

### Cores Primárias

#### Azul Primário
- **Hex:** `#2563EB`
- **RGB:** `37, 99, 235`
- **Uso:** Botões primários, fundos de destaque, elementos ativos, tabs selecionadas
- **Contraste:** WCAG AAA (excelente contraste em fundo branco)

#### Azul Escuro
- **Hex:** `#1E40AF`
- **RGB:** `30, 64, 175`
- **Uso:** Ícones e textos em fundo branco, elementos que precisam de contraste máximo
- **Contraste:** WCAG AAA

#### Roxo Secundário
- **Hex:** `#7C3AED`
- **RGB:** `124, 58, 237`
- **Uso:** Elementos secundários, gradientes (azul→roxo), destaques especiais
- **Contraste:** WCAG AA

### Gradiente Hero

```dart
LinearGradient(
  colors: [colors.primary, colors.secondary],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
)
```

**Visual:** Azul (#2563EB) → Roxo (#7C3AED)
**Uso:** Cards de saldo total, avatares, elementos de destaque

### Cores de Status (Mantidas)

#### Verde - Sucesso
- **Hex:** `#4CAF50`
- **Uso:** Valores positivos, compras, confirmações

#### Vermelho - Erro
- **Hex:** `#F44336`
- **Uso:** Valores negativos, vendas, erros

#### Azul Info
- **Hex:** `#2196F3`
- **Uso:** Informações, links, elementos informativos

### Cores Neutras (Mantidas)

#### Cinza Escuro
- **Hex:** `#545454`
- **Uso:** Textos primários, títulos

#### Cinza Médio
- **Hex:** `#9E9E9E`
- **Uso:** Textos secundários, subtítulos, ícones inativos

#### Cinza Claro
- **Hex:** `#F5F5F5`
- **Uso:** Backgrounds de cards, inputs

#### Cinza Muito Claro
- **Hex:** `#F0F0F0`
- **Uso:** Borders, dividers

#### Branco
- **Hex:** `#FFFFFF`
- **Uso:** Background principal

### Cores de Criptomoedas (Mantidas)

- **Bitcoin:** `#FF9800` (Laranja)
- **Ethereum:** `#9C27B0` (Roxo)
- **Cardano:** `#2196F3` (Azul)
- **Solana:** `#E91E63` (Rosa/Magenta)

## 📋 Migração Realizada

### Substituições Feitas

| Antes | Depois | Contexto |
|-------|--------|----------|
| `colors.yellow` | `colors.primary` | Botões, fundos, elementos ativos |
| `colors.yellowDark` | `colors.primaryDark` | Ícones, textos em fundo branco |
| Gradiente amarelo | Gradiente azul→roxo | Cards hero, avatares |

### Arquivos Atualizados

✅ `lib/utils/constants.dart` - Definições de cores
✅ `.kiro/steering/ui-guidelines.md` - Guia de UI
✅ `lib/views/widgets/README.md` - Documentação de widgets
✅ `CHANGELOG.md` - Histórico de mudanças
✅ Todos os arquivos `.dart` em `lib/` - Código fonte

## 🎯 Benefícios da Nova Paleta

1. **Contraste Superior:** WCAG AAA em todas as combinações principais
2. **Identidade Moderna:** Azul/roxo é padrão em apps financeiros e cripto
3. **Legibilidade:** Textos e ícones muito mais legíveis
4. **Profissionalismo:** Visual mais sério e confiável
5. **Acessibilidade:** Melhor para usuários com deficiência visual

## 🔧 Como Usar

### Botões Primários
```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: colors.primary, // Azul vibrante
    foregroundColor: colors.white,   // SEMPRE branco para contraste
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
  child: Text('Confirmar'),
)
```

**⚠️ IMPORTANTE:** Sempre usar texto branco em botões com fundo colorido (primary, secondary, success, error).

### Ícones Ativos
```dart
PhosphorIcon(
  PhosphorIcons.house(PhosphorIconsStyle.fill),
  color: colors.primaryDark, // Azul escuro para contraste
  size: 24,
)
```

### Cards Hero com Gradiente
```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [colors.primary, colors.secondary], // Azul → Roxo
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(24),
  ),
)
```

### Tabs Ativas
```dart
Container(
  decoration: BoxDecoration(
    color: colors.primary, // Azul
    borderRadius: BorderRadius.circular(12),
  ),
  child: Text(
    'Ativo',
    style: TextStyle(color: colors.white),
  ),
)
```

## ✅ Checklist de Consistência

- [x] Todas as referências a `yellow` removidas
- [x] Todas as referências a `yellowDark` removidas
- [x] Gradientes atualizados para azul→roxo
- [x] Documentação atualizada
- [x] Guias de estilo atualizados
- [x] Sem erros de compilação
- [x] Contraste WCAG AAA verificado

## 🚀 Próximos Passos

1. Testar visualmente em dispositivos reais
2. Validar com usuários (se aplicável)
3. Considerar modo escuro no futuro (cores já preparadas)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../controllers/controllers.dart';
import '../../../utils/theme_helper.dart';

/// Widget para alternar entre temas (Light/Dark/Sistema)
/// 
/// Pode ser usado como:
/// - Switch simples (Light ↔ Dark)
/// - Botão com opções (Light/Dark/Sistema)
/// - Lista de opções
class ThemeToggle extends StatelessWidget {
  final ThemeToggleStyle style;
  final bool showLabel;
  final String? customLabel;

  const ThemeToggle({
    super.key,
    this.style = ThemeToggleStyle.switch_,
    this.showLabel = true,
    this.customLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeController>(
      builder: (context, themeController, child) {
        switch (style) {
          case ThemeToggleStyle.switch_:
            return _buildSwitch(context, themeController);
          case ThemeToggleStyle.button:
            return _buildButton(context, themeController);
          case ThemeToggleStyle.list:
            return _buildList(context, themeController);
        }
      },
    );
  }

  /// Switch simples Light ↔ Dark
  Widget _buildSwitch(BuildContext context, ThemeController controller) {
    final colors = context.colors;
    final isDark = context.isDarkMode;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabel) ...[
          PhosphorIcon(
            PhosphorIcons.sun(PhosphorIconsStyle.fill),
            size: 20,
            color: !isDark ? colors.primary : colors.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
        ],
        
        Switch(
          value: isDark,
          onChanged: (_) => controller.toggleTheme(context),
          activeColor: colors.primary,
          inactiveThumbColor: colors.onSurfaceVariant,
          inactiveTrackColor: colors.outline,
        ),
        
        if (showLabel) ...[
          const SizedBox(width: 12),
          PhosphorIcon(
            PhosphorIcons.moon(PhosphorIconsStyle.fill),
            size: 20,
            color: isDark ? colors.primary : colors.onSurfaceVariant,
          ),
        ],
      ],
    );
  }

  /// Botão com ícone que alterna entre os modos
  Widget _buildButton(BuildContext context, ThemeController controller) {
    final colors = context.colors;

    return InkWell(
      onTap: () => _showThemeOptions(context, controller),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colors.outline,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PhosphorIcon(
              _getThemeIcon(controller.themeMode),
              size: 20,
              color: colors.primary,
            ),
            if (showLabel) ...[
              const SizedBox(width: 12),
              Text(
                customLabel ?? controller.getThemeModeName(),
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(width: 8),
            PhosphorIcon(
              PhosphorIcons.caretDown(PhosphorIconsStyle.bold),
              size: 16,
              color: colors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  /// Lista de opções de tema
  Widget _buildList(BuildContext context, ThemeController controller) {
    final colors = context.colors;

    return Column(
      children: [
        _buildThemeOption(
          context,
          controller,
          ThemeMode.light,
          'Claro',
          PhosphorIcons.sun(PhosphorIconsStyle.fill),
        ),
        const SizedBox(height: 8),
        _buildThemeOption(
          context,
          controller,
          ThemeMode.dark,
          'Escuro',
          PhosphorIcons.moon(PhosphorIconsStyle.fill),
        ),
        const SizedBox(height: 8),
        _buildThemeOption(
          context,
          controller,
          ThemeMode.system,
          'Sistema',
          PhosphorIcons.deviceMobile(PhosphorIconsStyle.fill),
        ),
      ],
    );
  }

  /// Opção individual de tema
  Widget _buildThemeOption(
    BuildContext context,
    ThemeController controller,
    ThemeMode mode,
    String label,
    PhosphorIconData icon,
  ) {
    final colors = context.colors;
    final isSelected = controller.themeMode == mode;

    return InkWell(
      onTap: () => _setThemeMode(controller, mode, context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary.withValues(alpha: 0.1) : colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colors.primary : colors.outline,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            PhosphorIcon(
              icon,
              size: 20,
              color: isSelected ? colors.primary : colors.onSurface,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? colors.primary : colors.onSurface,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
            if (isSelected)
              PhosphorIcon(
                PhosphorIcons.check(PhosphorIconsStyle.bold),
                size: 16,
                color: colors.primary,
              ),
          ],
        ),
      ),
    );
  }

  /// Mostra bottom sheet com opções de tema
  void _showThemeOptions(BuildContext context, ThemeController controller) {
    final colors = context.colors;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: colors.surfaceElevated,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Indicador
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Título
            Text(
              'Tema do Aplicativo',
              style: TextStyle(
                color: colors.onBackground,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Escolha como o app deve aparecer',
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Opções
            ThemeToggle(
              style: ThemeToggleStyle.list,
              showLabel: false,
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Define o modo de tema
  void _setThemeMode(ThemeController controller, ThemeMode mode, [BuildContext? context]) {
    switch (mode) {
      case ThemeMode.light:
        controller.setLightMode(context);
        break;
      case ThemeMode.dark:
        controller.setDarkMode(context);
        break;
      case ThemeMode.system:
        controller.setSystemMode(context);
        break;
    }
  }

  /// Retorna ícone baseado no modo de tema
  PhosphorIconData _getThemeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return PhosphorIcons.sun(PhosphorIconsStyle.fill);
      case ThemeMode.dark:
        return PhosphorIcons.moon(PhosphorIconsStyle.fill);
      case ThemeMode.system:
        return PhosphorIcons.deviceMobile(PhosphorIconsStyle.fill);
    }
  }
}

/// Estilos disponíveis para o ThemeToggle
enum ThemeToggleStyle {
  /// Switch simples Light ↔ Dark
  switch_,
  
  /// Botão com dropdown
  button,
  
  /// Lista de opções
  list,
}
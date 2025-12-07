import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../utils/constants.dart';

/// Widget de item de configuração com toggle (switch)
/// 
/// Usado nas seções de configurações do perfil para opções on/off.
/// Exibe um ícone, título, subtítulo opcional e um switch.
class ProfileSettingsToggle extends StatelessWidget {
  final PhosphorIconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const ProfileSettingsToggle({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppConstants.colors;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          PhosphorIcon(
            icon,
            size: 24,
            color: colors.darkGray,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors.darkGray,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.mediumGray,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: colors.primary,
          ),
        ],
      ),
    );
  }
}

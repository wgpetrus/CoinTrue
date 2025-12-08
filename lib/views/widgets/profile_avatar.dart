import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../../controllers/controllers.dart';
import '../../utils/constants.dart';
import '../../utils/theme_helper.dart';

/// Avatar de Perfil Reutilizável
/// 
/// Mostra a foto do usuário ou fallback com inicial
/// Usado em: AppBar, Perfil, Drawer, etc.
class ProfileAvatar extends StatelessWidget {
  final double size;
  final bool showBorder;
  final VoidCallback? onTap;
  final bool showEditIcon;

  const ProfileAvatar({
    super.key,
    this.size = 40,
    this.showBorder = false,
    this.onTap,
    this.showEditIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final authController = context.watch<AuthController>();
    final user = authController.currentUser;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: showBorder ? Border.all(
                color: colors.background,
                width: 3,
              ) : null,
              boxShadow: showBorder ? [
                BoxShadow(
                  color: colors.shadow,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ] : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(size / 2),
              child: _buildAvatarContent(user, colors),
            ),
          ),
          
          // Ícone de edição
          if (showEditIcon)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: size * 0.3,
                height: size * 0.3,
                decoration: BoxDecoration(
                  color: colors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colors.background,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: PhosphorIcon(
                    PhosphorIcons.pencilSimple(PhosphorIconsStyle.bold),
                    size: size * 0.15,
                    color: colors.onPrimary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatarContent(user, AppColors colors) {
    // Se tem foto de perfil, mostra a imagem
    if (user?.profileImageUrl != null && user!.profileImageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: user.profileImageUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildFallbackAvatar(user, colors),
        errorWidget: (context, url, error) => _buildFallbackAvatar(user, colors),
        memCacheWidth: (size * 2).toInt(),
        memCacheHeight: (size * 2).toInt(),
      );
    }

    // Fallback: gradiente com inicial
    return _buildFallbackAvatar(user, colors);
  }

  Widget _buildFallbackAvatar(user, AppColors colors) {
    final initial = _getInitial(user);
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.primary, colors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
            color: colors.onPrimary,
          ),
        ),
      ),
    );
  }

  String _getInitial(user) {
    if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      return user.displayName![0].toUpperCase();
    }
    if (user?.email != null && user!.email!.isNotEmpty) {
      return user.email![0].toUpperCase();
    }
    return 'U';
  }
}

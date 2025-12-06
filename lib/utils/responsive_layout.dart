import 'package:flutter/material.dart';

/// Helper para layouts responsivos
/// 
/// Facilita a criação de layouts adaptativos para diferentes tamanhos de tela.
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1024 && desktop != null) {
          return desktop!;
        } else if (constraints.maxWidth >= 600 && tablet != null) {
          return tablet!;
        } else {
          return mobile;
        }
      },
    );
  }
}

/// Padding responsivo baseado no tamanho da tela
class ResponsivePadding {
  static EdgeInsets horizontal(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1024) {
      return const EdgeInsets.symmetric(horizontal: 80);
    } else if (width >= 600) {
      return const EdgeInsets.symmetric(horizontal: 40);
    } else {
      return const EdgeInsets.symmetric(horizontal: 20);
    }
  }

  static EdgeInsets all(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1024) {
      return const EdgeInsets.all(40);
    } else if (width >= 600) {
      return const EdgeInsets.all(32);
    } else {
      return const EdgeInsets.all(20);
    }
  }
}

/// Grid responsivo
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 1;
        if (constraints.maxWidth >= 1024) {
          crossAxisCount = 3;
        } else if (constraints.maxWidth >= 600) {
          crossAxisCount = 2;
        }

        return GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: children,
        );
      },
    );
  }
}

/// Tamanho de fonte responsivo
class ResponsiveFontSize {
  static double title(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1024) return 32;
    if (width >= 600) return 28;
    return 24;
  }

  static double subtitle(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1024) return 18;
    if (width >= 600) return 16;
    return 14;
  }

  static double body(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1024) return 16;
    if (width >= 600) return 15;
    return 14;
  }
}

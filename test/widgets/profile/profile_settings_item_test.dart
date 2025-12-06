import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:login/views/widgets/profile/profile_settings_item.dart';

void main() {
  group('ProfileSettingsItem', () {
    testWidgets('deve exibir título e ícone', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileSettingsItem(
              icon: PhosphorIcons.user(),
              title: 'Perfil',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Perfil'), findsOneWidget);
      expect(find.byType(PhosphorIcon), findsNWidgets(2)); // Ícone + seta
    });

    testWidgets('deve exibir subtítulo quando fornecido', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileSettingsItem(
              icon: PhosphorIcons.user(),
              title: 'Perfil',
              subtitle: 'Editar informações',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Perfil'), findsOneWidget);
      expect(find.text('Editar informações'), findsOneWidget);
    });

    testWidgets('deve chamar onTap quando clicado', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileSettingsItem(
              icon: PhosphorIcons.user(),
              title: 'Perfil',
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      expect(tapped, true);
    });

    testWidgets('deve exibir trailing customizado quando fornecido', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileSettingsItem(
              icon: PhosphorIcons.user(),
              title: 'Idioma',
              trailing: const Text('Português'),
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Idioma'), findsOneWidget);
      expect(find.text('Português'), findsOneWidget);
    });

    testWidgets('não deve exibir seta quando onTap é null', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileSettingsItem(
              icon: PhosphorIcons.info(),
              title: 'Versão',
              trailing: const Text('v1.0.0'),
              onTap: null,
            ),
          ),
        ),
      );

      expect(find.text('Versão'), findsOneWidget);
      expect(find.text('v1.0.0'), findsOneWidget);
      // Deve ter apenas 1 ícone (o principal, sem seta)
      expect(find.byType(PhosphorIcon), findsOneWidget);
    });
  });
}

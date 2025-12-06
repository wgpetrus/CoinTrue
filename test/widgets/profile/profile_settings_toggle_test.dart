import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:login/views/widgets/profile/profile_settings_toggle.dart';

void main() {
  group('ProfileSettingsToggle', () {
    testWidgets('deve exibir título, ícone e switch', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileSettingsToggle(
              icon: PhosphorIcons.fingerprint(),
              title: 'Biometria',
              value: false,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Biometria'), findsOneWidget);
      expect(find.byType(PhosphorIcon), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('deve exibir subtítulo quando fornecido', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileSettingsToggle(
              icon: PhosphorIcons.fingerprint(),
              title: 'Biometria',
              subtitle: 'Usar impressão digital',
              value: false,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Biometria'), findsOneWidget);
      expect(find.text('Usar impressão digital'), findsOneWidget);
    });

    testWidgets('deve refletir o valor do switch', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileSettingsToggle(
              icon: PhosphorIcons.fingerprint(),
              title: 'Biometria',
              value: true,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, true);
    });

    testWidgets('deve chamar onChanged quando switch é alterado', (WidgetTester tester) async {
      bool currentValue = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return ProfileSettingsToggle(
                  icon: PhosphorIcons.fingerprint(),
                  title: 'Biometria',
                  value: currentValue,
                  onChanged: (value) {
                    setState(() {
                      currentValue = value;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      expect(currentValue, false);

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(currentValue, true);
    });
  });
}

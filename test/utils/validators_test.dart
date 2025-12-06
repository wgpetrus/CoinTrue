import 'package:flutter_test/flutter_test.dart';
import 'package:login/utils/validators.dart';

void main() {
  group('Validators', () {
    group('isValidEmail', () {
      test('deve aceitar email válido', () {
        expect(Validators.isValidEmail('test@example.com'), true);
        expect(Validators.isValidEmail('user.name@domain.co'), true);
        expect(Validators.isValidEmail('user+tag@example.com'), true);
      });

      test('deve rejeitar email inválido', () {
        expect(Validators.isValidEmail(''), false);
        expect(Validators.isValidEmail('invalid'), false);
        expect(Validators.isValidEmail('@example.com'), false);
        expect(Validators.isValidEmail('user@'), false);
        expect(Validators.isValidEmail('user @example.com'), false);
      });

      test('deve rejeitar email null', () {
        expect(Validators.isValidEmail(null), false);
      });
    });

    group('isNotEmpty', () {
      test('deve aceitar texto válido', () {
        expect(Validators.isNotEmpty('texto'), true);
        expect(Validators.isNotEmpty('João Silva'), true);
        expect(Validators.isNotEmpty('123'), true);
      });

      test('deve rejeitar texto vazio', () {
        expect(Validators.isNotEmpty(''), false);
        expect(Validators.isNotEmpty('   '), false);
        expect(Validators.isNotEmpty(null), false);
      });
    });

    group('sanitizeInput', () {
      test('deve manter texto normal', () {
        expect(Validators.sanitizeInput('texto normal'), 'texto normal');
        expect(Validators.sanitizeInput('João Silva'), 'João Silva');
        expect(Validators.sanitizeInput('123'), '123');
      });

      test('deve remover caracteres maliciosos', () {
        expect(Validators.sanitizeInput('<script>alert("xss")</script>'), 'alert(xss)');
        expect(Validators.sanitizeInput('test;drop table'), 'testdrop table');
        expect(Validators.sanitizeInput('normal text'), 'normal text');
      });

      test('deve retornar vazio para null', () {
        expect(Validators.sanitizeInput(null), '');
        expect(Validators.sanitizeInput(''), '');
      });
    });

    group('validatePassword', () {
      test('deve aceitar qualquer senha (implementação futura)', () {
        expect(Validators.validatePassword('password123'), true);
        expect(Validators.validatePassword('MyP@ssw0rd'), true);
        expect(Validators.validatePassword('12345678'), true);
        expect(Validators.validatePassword(''), true);
        expect(Validators.validatePassword(null), true);
      });
    });

    group('validateRequiredFields', () {
      test('deve aceitar todos os campos preenchidos', () {
        expect(Validators.validateRequiredFields(['nome', 'email', 'telefone']), true);
        expect(Validators.validateRequiredFields(['João', 'test@example.com']), true);
      });

      test('deve rejeitar se algum campo vazio', () {
        expect(Validators.validateRequiredFields(['nome', '']), false);
        expect(Validators.validateRequiredFields(['', 'email']), false);
        expect(Validators.validateRequiredFields([null, 'email']), false);
      });
    });
  });
}

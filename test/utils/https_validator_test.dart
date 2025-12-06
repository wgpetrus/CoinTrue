import 'package:flutter_test/flutter_test.dart';
import 'package:faker/faker.dart';

import 'package:login/utils/https_validator.dart';

void main() {
  late Faker faker;

  setUp(() {
    faker = Faker();
  });

  group('Property-Based Tests - HttpsValidator', () {
    // Feature: autenticacao-cripto, Property 26: Uso exclusivo de HTTPS
    // Validates: Requirements 6.2
    test(
      'Property 26: Para qualquer URL HTTP, sistema deve rejeitar',
      () {
        // Generate 100 HTTP URLs and verify they are all rejected
        for (int i = 0; i < 100; i++) {
          // Generate various types of HTTP URLs
          final urlType = i % 5;
          String httpUrl;

          switch (urlType) {
            case 0:
              // Standard HTTP URL
              httpUrl = 'http://${faker.internet.domainName()}';
              break;
            case 1:
              // HTTP URL with path
              httpUrl = 'http://${faker.internet.domainName()}/${faker.lorem.word()}';
              break;
            case 2:
              // HTTP URL with query parameters
              httpUrl = 'http://${faker.internet.domainName()}?param=${faker.lorem.word()}';
              break;
            case 3:
              // HTTP URL with port
              httpUrl = 'http://${faker.internet.domainName()}:${faker.randomGenerator.integer(9999, min: 1000)}';
              break;
            case 4:
              // HTTP URL with subdomain
              httpUrl = 'http://${faker.internet.userName()}.${faker.internet.domainName()}';
              break;
            default:
              httpUrl = 'http://${faker.internet.domainName()}';
          }

          // Assert: HTTP URLs should be rejected
          expect(
            HttpsValidator.isHttpsUrl(httpUrl),
            isFalse,
            reason: 'HTTP URL "$httpUrl" should be rejected',
          );
        }
      },
    );

    test(
      'Property 26: Para qualquer URL HTTPS, sistema deve aceitar',
      () {
        // Generate 100 HTTPS URLs and verify they are all accepted
        for (int i = 0; i < 100; i++) {
          // Generate various types of HTTPS URLs
          final urlType = i % 5;
          String httpsUrl;

          switch (urlType) {
            case 0:
              // Standard HTTPS URL
              httpsUrl = 'https://${faker.internet.domainName()}';
              break;
            case 1:
              // HTTPS URL with path
              httpsUrl = 'https://${faker.internet.domainName()}/${faker.lorem.word()}';
              break;
            case 2:
              // HTTPS URL with query parameters
              httpsUrl = 'https://${faker.internet.domainName()}?param=${faker.lorem.word()}';
              break;
            case 3:
              // HTTPS URL with port
              httpsUrl = 'https://${faker.internet.domainName()}:${faker.randomGenerator.integer(9999, min: 1000)}';
              break;
            case 4:
              // HTTPS URL with subdomain
              httpsUrl = 'https://${faker.internet.userName()}.${faker.internet.domainName()}';
              break;
            default:
              httpsUrl = 'https://${faker.internet.domainName()}';
          }

          // Assert: HTTPS URLs should be accepted
          expect(
            HttpsValidator.isHttpsUrl(httpsUrl),
            isTrue,
            reason: 'HTTPS URL "$httpsUrl" should be accepted',
          );
        }
      },
    );

    test(
      'Property 26: Para qualquer URI HTTP, sistema deve rejeitar',
      () {
        // Generate 100 HTTP URIs and verify they are all rejected
        for (int i = 0; i < 100; i++) {
          final domain = faker.internet.domainName();
          final path = faker.lorem.word();
          final httpUri = Uri.parse('http://$domain/$path');

          // Assert: HTTP URIs should be rejected
          expect(
            HttpsValidator.isHttpsUri(httpUri),
            isFalse,
            reason: 'HTTP URI "$httpUri" should be rejected',
          );
        }
      },
    );

    test(
      'Property 26: Para qualquer URI HTTPS, sistema deve aceitar',
      () {
        // Generate 100 HTTPS URIs and verify they are all accepted
        for (int i = 0; i < 100; i++) {
          final domain = faker.internet.domainName();
          final path = faker.lorem.word();
          final httpsUri = Uri.parse('https://$domain/$path');

          // Assert: HTTPS URIs should be accepted
          expect(
            HttpsValidator.isHttpsUri(httpsUri),
            isTrue,
            reason: 'HTTPS URI "$httpsUri" should be accepted',
          );
        }
      },
    );

    test(
      'Property 26: Para qualquer URL sem esquema, sistema deve rejeitar',
      () {
        // Generate 100 URLs without scheme and verify they are all rejected
        for (int i = 0; i < 100; i++) {
          final urlWithoutScheme = faker.internet.domainName();

          // Assert: URLs without scheme should be rejected
          expect(
            HttpsValidator.isHttpsUrl(urlWithoutScheme),
            isFalse,
            reason: 'URL without scheme "$urlWithoutScheme" should be rejected',
          );
        }
      },
    );

    test(
      'Property 26: Para qualquer URL com esquema inválido, sistema deve rejeitar',
      () {
        // Generate 100 URLs with invalid schemes and verify they are all rejected
        final invalidSchemes = ['ftp', 'file', 'ws', 'wss', 'mailto'];

        for (int i = 0; i < 100; i++) {
          final scheme = invalidSchemes[i % invalidSchemes.length];
          final domain = faker.internet.domainName();
          final invalidUrl = '$scheme://$domain';

          // Assert: URLs with invalid schemes should be rejected
          expect(
            HttpsValidator.isHttpsUrl(invalidUrl),
            isFalse,
            reason: 'URL with invalid scheme "$invalidUrl" should be rejected',
          );
        }
      },
    );

    test(
      'Property 26: Para qualquer URL inválida que não pode ser parseada, sistema deve rejeitar',
      () {
        // Generate various URLs that cannot be parsed and verify they are all rejected
        final unparsableUrls = [
          'not a url',
          '',
          '   ',
        ];

        for (final url in unparsableUrls) {
          // Assert: Unparsable URLs should be rejected
          expect(
            HttpsValidator.isHttpsUrl(url),
            isFalse,
            reason: 'Unparsable URL "$url" should be rejected',
          );
        }
      },
    );
  });

  group('Unit Tests - HttpsValidator', () {
    group('isHttpsUrl', () {
      test('deve aceitar URLs HTTPS válidas', () {
        expect(HttpsValidator.isHttpsUrl('https://api.example.com'), isTrue);
        expect(HttpsValidator.isHttpsUrl('https://example.com/path'), isTrue);
        expect(HttpsValidator.isHttpsUrl('https://sub.example.com:443'), isTrue);
      });

      test('deve rejeitar URLs HTTP', () {
        expect(HttpsValidator.isHttpsUrl('http://api.example.com'), isFalse);
        expect(HttpsValidator.isHttpsUrl('http://example.com'), isFalse);
      });

      test('deve rejeitar URLs inválidas', () {
        expect(HttpsValidator.isHttpsUrl('not a url'), isFalse);
        expect(HttpsValidator.isHttpsUrl(''), isFalse);
        expect(HttpsValidator.isHttpsUrl('ftp://example.com'), isFalse);
      });
    });

    group('isHttpsUri', () {
      test('deve aceitar URIs HTTPS', () {
        final uri = Uri.parse('https://api.example.com');
        expect(HttpsValidator.isHttpsUri(uri), isTrue);
      });

      test('deve rejeitar URIs HTTP', () {
        final uri = Uri.parse('http://api.example.com');
        expect(HttpsValidator.isHttpsUri(uri), isFalse);
      });
    });
  });
}

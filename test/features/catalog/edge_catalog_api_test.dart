// G07 — cliente do Worker do catálogo (camada da borda): só o ISBN no pedido; erros tipados.
import 'dart:async';
import 'dart:convert';

import 'package:app_leitura/features/catalog/data/edge_catalog_api.dart';
import 'package:app_leitura/features/catalog/domain/catalog_failure.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  final base = Uri.parse('http://catalogo.teste/');

  test('200 → livro (nomes por extenso do Worker); 404 → null; o pedido leva só o ISBN', () async {
    final pedidos = <http.Request>[];
    final api = HttpEdgeCatalogApi(
      MockClient((r) async {
        pedidos.add(r);
        if (r.url.path.endsWith('9788535902778')) {
          return http.Response.bytes(
            utf8.encode(
              jsonEncode({
                'encontrado': true,
                'versao': '2026-09-30.1',
                'livro': {
                  'isbn13': '9788535902778',
                  'title': 'Dom Casmurro',
                  'subtitle': null,
                  'authors': ['Machado de Assis'],
                  'publisher': 'Penguin-Companhia',
                  'year': 2016,
                  'pages': 256,
                  'language': 'por',
                  'cover_ref': 'ol:8231432',
                  'source': 'openlibrary',
                  'source_license': 'OL-sem-direitos',
                },
              }),
            ),
            200,
          );
        }
        return http.Response('{"encontrado":false}', 404);
      }),
      base,
    );
    final b = await api.byIsbn('9788535902778');
    expect(
      [b!.title, b.authors, b.year, b.license],
      [
        'Dom Casmurro',
        ['Machado de Assis'],
        2016,
        'OL-sem-direitos',
      ],
    );
    expect(await api.byIsbn('9780000000002'), isNull);
    expect(pedidos.map((p) => (p.method, p.url.toString(), p.body)), [
      ('GET', 'http://catalogo.teste/v1/isbn/9788535902778', ''),
      ('GET', 'http://catalogo.teste/v1/isbn/9780000000002', ''),
    ]);
  });

  test(
    '429 → limite; 5xx, sem rede e tempo esgotado → offline; 400 → inesperado',
    () async {
      Future<Object?> erro(
        Future<http.Response> Function(http.Request) h,
      ) async {
        try {
          await HttpEdgeCatalogApi(MockClient(h), base).byIsbn('9788535902778');
        } on CatalogFailure catch (e) {
          return e;
        }
        return null;
      }

      expect(
        await erro((_) async => http.Response('', 429)),
        isA<CatalogQuotaExceeded>(),
      );
      expect(
        await erro((_) async => http.Response('', 503)),
        isA<CatalogOffline>(),
      );
      expect(
        await erro((r) async => throw http.ClientException('caiu', r.url)),
        isA<CatalogOffline>(),
      );
      expect(
        await erro((_) async => throw TimeoutException('x')),
        isA<CatalogOffline>(),
      );
      expect(
        await erro((_) async => http.Response('', 400)),
        isA<CatalogUnexpected>(),
      );
    },
  );
}

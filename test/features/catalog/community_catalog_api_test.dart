// G07.4 — camada da comunidade sobre o cliente REAL do Supabase com o servidor de mentira: o que vai
// na rede (só o ISBN na consulta; ISBN + título + autor + editora no envio) e os erros.
import 'package:app_leitura/features/catalog/data/community_catalog_api.dart';
import 'package:app_leitura/features/catalog/domain/catalog_failure.dart';
import 'package:app_leitura/features/catalog/domain/community.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show OtpType, SupabaseClient;

import '../account/support/fake_backend.dart';

const _isbn = '9786530000017';
const _envio = '01927a00-0000-7000-8000-0000000000d1';

Map<String, Object?> _edicao() => {
  'isbn13': _isbn,
  'title': 'Memórias do Livro',
  'subtitle': null,
  'authors': ['Ana Autora', 'Bia Coautora'],
  'publisher': 'Editora X',
  'year': null,
  'pages': null,
  'language': null,
  'cover_ref': null,
  'source': 'community',
  'source_license': 'CC0',
};

void main() {
  late FakeBackend backend;
  late SupabaseClient client;
  late SupabaseCommunityCatalogApi api;

  Future<void> montar({
    Map<String, Resposta>? respostas,
    bool logado = true,
  }) async {
    backend = FakeBackend(respostas: respostas);
    client = backend.client();
    api = SupabaseCommunityCatalogApi(client);
    if (logado) {
      await client.auth.verifyOTP(
        email: emailTeste,
        token: '123456',
        type: OtpType.email,
      );
      backend.pedidos.clear();
    }
  }

  tearDown(() => client.dispose());

  test('consulta: só o ISBN vai para a rede; volta a edição e as sugestões sem quem enviou', () async {
    await montar(
      respostas: {
        'POST /rest/v1/rpc/catalog_by_isbn': (
          200,
          {
            'edition': null,
            'pending': [
              {
                'id': _envio,
                'title': 'Memórias do Livro',
                'authors': 'Ana Autora',
                'publisher': null,
                'confirmations': 1,
                'mine': false,
                'confirmed_by_me': false,
              },
            ],
          },
        ),
      },
    );
    final r = await api.lookup(_isbn);
    expect(r.book, isNull);
    expect(r.pending.single.title, 'Memórias do Livro');
    expect(r.pending.single.canConfirm, isTrue);
    expect(backend.caminhos, ['POST /rest/v1/rpc/catalog_by_isbn']);
    expect(backend.pedidos.single.json, {'p_isbn13': _isbn});
    expect(backend.pedidos.single.jwt, client.auth.currentSession!.accessToken);
  });

  test(
    'consulta com edição aprovada: vira um CatalogBook da comunidade',
    () async {
      await montar(
        respostas: {
          'POST /rest/v1/rpc/catalog_by_isbn': (
            200,
            {'edition': _edicao(), 'pending': <Object?>[]},
          ),
        },
      );
      final r = await api.lookup(_isbn);
      expect(r.book?.authorDisplay, 'Ana Autora · Bia Coautora');
      expect(r.book?.shareable, isTrue);
    },
  );

  test(
    'envio (toque explícito): leva exatamente ISBN, título, autor e editora',
    () async {
      await montar(
        respostas: {
          'POST /rest/v1/rpc/catalog_submit': (
            200,
            {'status': 'pending', 'submission_id': _envio},
          ),
        },
      );
      final r = await api.submit(
        isbn13: _isbn,
        title: 'Memórias do Livro',
        authors: 'Ana Autora',
        publisher: 'Editora X',
      );
      expect(r, isA<ContributionPending>());
      expect(backend.pedidos.single.json, {
        'p_isbn13': _isbn,
        'p_title': 'Memórias do Livro',
        'p_authors': 'Ana Autora',
        'p_publisher': 'Editora X',
      });
    },
  );

  test('resultados do envio e da confirmação', () async {
    await montar(
      respostas: {
        'POST /rest/v1/rpc/catalog_submit': (
          200,
          {'status': 'exists', 'edition': _edicao()},
        ),
        'POST /rest/v1/rpc/catalog_confirm': (
          200,
          {'status': 'approved', 'submission_id': _envio, 'edition': _edicao()},
        ),
      },
    );
    expect(
      await api.submit(isbn13: _isbn, title: 'X', authors: 'Y'),
      isA<ContributionAlreadyInCatalog>(),
    );
    expect(
      await api.confirm(_envio),
      isA<ContributionApproved>().having(
        (a) => a.book.title,
        'livro',
        'Memórias do Livro',
      ),
    );
    expect(backend.pedidos.last.json, {'p_submission': _envio});
  });

  test('erros do servidor viram falhas do catálogo', () async {
    await montar(
      respostas: {
        'POST /rest/v1/rpc/catalog_submit': erroPostgrest(
          400,
          'P0001',
          'age_required',
        ),
        'POST /rest/v1/rpc/catalog_confirm': erroPostgrest(
          400,
          'P0001',
          'quota_exceeded',
        ),
      },
    );
    await expectLater(
      api.submit(isbn13: _isbn, title: 'X', authors: 'Y'),
      throwsA(isA<CatalogNeedsAge>()),
    );
    await expectLater(
      api.confirm(_envio),
      throwsA(isA<CatalogQuotaExceeded>()),
    );
  });

  test('sem conta: nada vai para a rede; sem rede: CatalogOffline', () async {
    await montar(logado: false);
    await expectLater(api.lookup(_isbn), throwsA(isA<CatalogNeedsAccount>()));
    expect(backend.pedidos, isEmpty);
    await client.dispose();
    await montar();
    backend.offline = true;
    await expectLater(api.lookup(_isbn), throwsA(isA<CatalogOffline>()));
  });
}

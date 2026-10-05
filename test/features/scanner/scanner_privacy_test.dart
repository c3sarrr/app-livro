// G07 — lista branca do Grátis (§4.3.7, D-74) no scanner, pela pilha real (controlador → resolvedor →
// Worker, RPCs e Edge Function sobre clientes HTTP que gravam cada pedido): ao escanear só o ISBN sai do
// aparelho; o envio à comunidade só acontece com o toque explícito e leva só ISBN, título, autor e
// editora; nada da estante (títulos, ids, outros ISBNs) vai para a rede.
import 'package:app_leitura/core/data/clock/hlc.dart';
import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/daos/library_daos.dart';
import 'package:app_leitura/core/data/database/versioning.dart';
import 'package:app_leitura/core/data/model/nullable.dart';
import 'package:app_leitura/features/catalog/application/catalog_providers.dart';
import 'package:app_leitura/features/catalog/application/isbn_resolver.dart';
import 'package:app_leitura/features/catalog/data/catalog_cache_dao.dart';
import 'package:app_leitura/features/catalog/data/community_catalog_api.dart';
import 'package:app_leitura/features/catalog/data/edge_catalog_api.dart';
import 'package:app_leitura/features/catalog/data/external_isbn_api.dart';
import 'package:app_leitura/features/scanner/application/scanned_shelf.dart';
import 'package:app_leitura/features/scanner/application/scanner_controller.dart';
import 'package:app_leitura/features/scanner/domain/scan_state.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show OtpType;

import '../../support/personal_builders.dart';
import '../account/support/fake_backend.dart';

const _isbnA = '9786586490008';
const _isbnB = '9786586490015';
const _naEstante = '9788535902778';

void main() {
  test('Grátis com conta: escanear manda só o ISBN; enviar à comunidade só no toque e só os 4 campos', () async {
    final db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false);
    final backend = FakeBackend(
      respostas: {
        'POST /rest/v1/rpc/catalog_by_isbn': (
          200,
          {'edition': null, 'pending': <Object?>[]},
        ),
        'POST /functions/v1/isbn-lookup': (404, {'encontrado': false}),
        'POST /rest/v1/rpc/catalog_submit': (
          200,
          {
            'status': 'pending',
            'submission_id': '01927a00-0000-7000-8000-0000000000e1',
          },
        ),
      },
    );
    final client = backend.client();
    final worker = <http.Request>[];
    final http.Client httpWorker = MockClient((r) async {
      worker.add(r);
      return http.Response('{"encontrado":false}', 404);
    });
    addTearDown(() async {
      await client.dispose();
      await db.close();
    });
    await client.auth.verifyOTP(
      email: emailTeste,
      token: '123456',
      type: OtpType.email,
    );
    backend.pedidos.clear();

    // a estante do Grátis tem um livro (título, id e ISBN que não podem sair do aparelho)
    final livro = livroTeste(1, title: 'Memórias Póstumas de Brás Cubas');
    await UserBooksDao(db)
        .upsert(livro.copyWith(isbn13: const Nullable(_naEstante)));
    await UserBooksDao(db).upsert(livroTeste(2, title: 'Quincas Borba'));
    final shelf = ScannedShelf(
      db: db,
      versioning: LocalVersioning(db, HlcClock(deviceId: 'aparelhoA')),
      owner: () async => usuarioTeste,
    );
    final community = SupabaseCommunityCatalogApi(client);
    final c = ProviderContainer(
      overrides: [
        scannedShelfProvider.overrideWith((ref) async => shelf),
        communityCatalogApiProvider.overrideWithValue(community),
        isbnResolverProvider.overrideWith(
          (ref) async => IsbnResolver(
            cache: CatalogCacheDao(db),
            localCatalog: () async => null,
            edge: HttpEdgeCatalogApi(
              httpWorker,
              Uri.parse('http://catalogo.teste/'),
            ),
            community: community,
            external: SupabaseExternalIsbnApi(client),
          ),
        ),
      ],
    );
    addTearDown(c.dispose);
    final sub = c.listen(scannerControllerProvider, (_, _) {});
    addTearDown(sub.close);
    final ctl = c.read(scannerControllerProvider.notifier);

    // 1. escanear: só o ISBN vai para o Worker, a comunidade e a consulta externa
    await ctl.typed(_isbnA);
    expect(c.read(scannerControllerProvider), isA<ScanNotFound>());
    expect(worker.map((r) => '${r.method} ${r.url}'), [
      'GET http://catalogo.teste/v1/isbn/$_isbnA',
    ]);
    expect(worker.single.body, isEmpty);
    expect(backend.caminhos, [
      'POST /rest/v1/rpc/catalog_by_isbn',
      'POST /functions/v1/isbn-lookup',
    ]);
    expect(backend.pedidos[0].json, {'p_isbn13': _isbnA});
    expect(backend.pedidos[1].json, {'isbn': _isbnA});

    // 2. pôr na estante SEM o toque de envio: nada sai
    final antes = (backend.pedidos.length, worker.length);
    await ctl.addTyped(title: 'Livro Novo', authors: 'Autora', share: false);
    expect(c.read(scannerControllerProvider), isA<ScanAdded>());
    expect((backend.pedidos.length, worker.length), antes);

    // 3. outro livro, agora com o toque em "Adicionar e enviar ao catálogo"
    ctl.scanAgain();
    await ctl.typed(_isbnB);
    await ctl.addTyped(
      title: 'Outro Livro',
      authors: 'Ana; Bia',
      publisher: 'Editora X',
      share: true,
    );
    final envio = backend.pedidos.last;
    expect(envio.path, '/rest/v1/rpc/catalog_submit');
    expect(envio.json, {
      'p_isbn13': _isbnB,
      'p_title': 'Outro Livro',
      'p_authors': 'Ana; Bia',
      'p_publisher': 'Editora X',
    });
    expect(
      backend.caminhos.where((p) => p.contains('catalog_submit')),
      hasLength(1),
      reason: 'só o toque explícito envia',
    );

    // 4. nada da estante saiu em pedido nenhum
    final proibidos = [
      'Memórias Póstumas',
      'Quincas Borba',
      'Livro Novo', // estava na estante e NÃO foi enviado (passo 2)
      livro.id,
      idTeste(2),
      livro.contentSha256!,
      _naEstante,
    ];
    final tudo = [
      for (final p in backend.pedidos) '${p.url} ${p.body}',
      for (final r in worker) '${r.url} ${r.body}',
    ];
    for (final t in tudo) {
      for (final x in proibidos) {
        expect(t.contains(x), isFalse, reason: '"$x" saiu do aparelho em $t');
      }
    }
    // a sincronização do Pro nunca aparece no Grátis
    expect(
      backend.caminhos.where((p) => p.contains('sync_apply_changes')),
      isEmpty,
    );
  });
}

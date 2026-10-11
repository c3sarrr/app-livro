// T04.12 — privacidade do Grátis (§4.3.7, ADR-002) no cronômetro do papel: com conta, logado, com o cliente do
// Supabase de pé e o catálogo configurado (o Worker e o `catalog.db`), o fluxo inteiro — começar, pausar, retomar e
// encerrar com o total do catálogo do aparelho — passa pelos provedores reais sobre o banco do aparelho e NÃO faz
// nenhum pedido de rede: os dois interceptadores (o do Supabase e o HTTP do catálogo) gravam cada um. O total vem do
// cache do scanner ou, fora dele, do `catalog.db` do aparelho — nunca da rede.
import 'dart:io';

import 'package:app_leitura/core/config/app_env.dart';
import 'package:app_leitura/core/data/clock/hlc.dart';
import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/daos/library_daos.dart';
import 'package:app_leitura/core/data/database/daos/reader_daos.dart';
import 'package:app_leitura/core/data/database/local_database.dart';
import 'package:app_leitura/core/data/database/versioning.dart';
import 'package:app_leitura/core/sync/sync_providers.dart';
import 'package:app_leitura/features/account/application/account_providers.dart';
import 'package:app_leitura/features/account/data/local_library.dart';
import 'package:app_leitura/features/catalog/application/catalog_providers.dart';
import 'package:app_leitura/features/catalog/data/catalog_cache_dao.dart';
import 'package:app_leitura/features/catalog/domain/catalog_book.dart';
import 'package:app_leitura/features/home/application/home_providers.dart'
    show clockProvider;
import 'package:app_leitura/features/library/domain/user_book.dart';
import 'package:app_leitura/features/reader/domain/locator.dart';
import 'package:app_leitura/features/reading_session/application/paper_timer_controller.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show OtpType;

import '../../support/personal_builders.dart';
import '../account/support/fake_backend.dart';

const _isbn = '9788535910667';
const _foraDoCache = '9788535914849';

void main() {
  late FakeBackend backend;
  late List<http.BaseRequest> pedidosHttp;
  late AppDatabase db;
  late DateTime agora;
  late ProviderContainer c;

  setUp(() async {
    backend = FakeBackend();
    final client = backend.client();
    addTearDown(client.dispose);
    await client.auth.verifyOTP(
      email: emailTeste,
      token: '123456',
      type: OtpType.email,
    );
    db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false);
    addTearDown(db.close);
    final pasta = Directory.systemTemp.createTempSync('booknest_t04_priv_');
    addTearDown(() => pasta.deleteSync(recursive: true));
    pedidosHttp = [];
    final biblioteca = LocalLibrary(db);
    await biblioteca.setActiveOwner(contaTeste);
    agora = DateTime.utc(2026, 10, 9, 12);
    c = ProviderContainer(
      overrides: [
        supabaseClientProvider.overrideWithValue(client),
        localDatabaseProvider.overrideWith((ref) async => db),
        localLibraryProvider.overrideWith((ref) async => biblioteca),
        localVersioningProvider.overrideWith(
          (ref) async => LocalVersioning(db, HlcClock(deviceId: 'aparelhoX')),
        ),
        clockProvider.overrideWithValue(() => agora),
        // o catálogo configurado: o Worker e o `catalog.db` existem, e o HTTP deles é gravado
        appEnvProvider.overrideWithValue(
          const AppEnv(catalogUrl: 'http://catalogo.teste/'),
        ),
        catalogHttpClientProvider.overrideWithValue(
          MockClient((r) async {
            pedidosHttp.add(r);
            return http.Response('{"encontrado":false}', 404);
          }),
        ),
        catalogDirProvider.overrideWith((ref) async => pasta),
      ],
    );
    addTearDown(c.dispose);
    final sub = c.listen(paperTimerProvider, (_, _) {});
    addTearDown(sub.close);
  });

  Future<UserBook> estante(int n, String isbn) async {
    final livro = UserBook(
      id: idTeste(n),
      meta: metaTeste(userId: contaTeste),
      title: 'Memórias Póstumas de Brás Cubas',
      authorDisplay: 'Machado de Assis',
      format: BookFileFormat.physical,
      status: ShelfStatus.reading,
      addedAt: DateTime.utc(2026, 9, 1, 12),
      isbn13: isbn,
    );
    await UserBooksDao(db).upsert(livro);
    return livro;
  }

  /// Começa → 5 min → pausa → 2 min parados → retoma → 3 min 42 s → encerra na pág. 120 com o total do catálogo.
  Future<int?> sessao(UserBook livro, {int? pagina}) async {
    backend.pedidos.clear();
    pedidosHttp.clear();
    final timer = c.read(paperTimerProvider.notifier);
    await c.read(paperTimerProvider.future);
    await timer.start(livro.id);
    agora = agora.add(const Duration(minutes: 5));
    await timer.pause();
    agora = agora.add(const Duration(minutes: 2)); // a pausa não conta
    await timer.resume();
    agora = agora.add(const Duration(minutes: 3, seconds: 42));
    final book = c.read(paperTimerProvider).value!.book!;
    expect(book.pagesTotal, isNull);
    final paginas = await (await c.read(paperBookSourceProvider.future))
        .catalogPages(book.isbn13!);
    await timer.end(page: pagina, pagesTotal: paginas);
    await pumpEventQueue();
    return paginas;
  }

  void semRede() {
    expect(
      backend.pedidos,
      isEmpty,
      reason: 'nada ao Supabase: ${backend.caminhos}',
    );
    expect(
      pedidosHttp,
      isEmpty,
      reason: 'nada ao catálogo: ${[for (final p in pedidosHttp) p.url]}',
    );
  }

  test('Grátis com conta: começar → pausar → retomar → encerrar (pág. 120 de 368, o total do cache do scanner) — '
      'nenhum pedido de rede, e tudo gravado no aparelho', () async {
    final livro = await estante(1, _isbn);
    // o scanner já guardou o livro no cache do catálogo (368 páginas)
    await CatalogCacheDao(db).putBook(
      const CatalogBook(
        isbn13: _isbn,
        title: 'Memórias Póstumas de Brás Cubas',
        pages: 368,
        source: 'openlibrary',
      ),
      DateTime.utc(2026, 9, 1, 12),
    );
    final paginas = await sessao(livro, pagina: 120);
    expect(paginas, 368);
    semRede();
    expect(c.read(paperTimerProvider).value!.session, isNull);
    final sessoes = await db.select(db.readingSessions).get();
    expect(sessoes, hasLength(1));
    expect(sessoes.single.activeSeconds, 8 * 60 + 42);
    expect(sessoes.single.source.code, 'timer');
    expect(sessoes.single.userId, contaTeste);
    final posicao = await ReadingPositionsDao(db).forBook(livro.id);
    expect(posicao!.locator, PaperLocator(120));
    expect((await UserBooksDao(db).byId(livro.id))!.refPagesTotal, 368);
  });

  test('fora do cache, o total vem do catalog.db do aparelho (aqui, ainda não baixado: nenhum) — e mesmo assim nenhum '
      'pedido ao Worker nem ao Supabase', () async {
    final livro = await estante(2, _foraDoCache);
    final paginas = await sessao(livro);
    expect(paginas, isNull);
    semRede();
    expect(await db.select(db.readingSessions).get(), hasLength(1));
  });
}

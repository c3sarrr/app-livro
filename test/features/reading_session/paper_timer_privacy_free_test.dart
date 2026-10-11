// T04.12 — privacidade do Grátis (§4.3.7, ADR-002) no cronômetro do papel: com conta, logado e com o cliente do
// Supabase de pé, o fluxo inteiro — começar, pausar, retomar e encerrar com o total do catálogo do aparelho — passa
// pelos provedores reais sobre o banco do aparelho e NÃO faz nenhum pedido de rede (o interceptador grava cada um).
import 'package:app_leitura/core/data/clock/hlc.dart';
import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/daos/library_daos.dart';
import 'package:app_leitura/core/data/database/daos/reader_daos.dart';
import 'package:app_leitura/core/data/database/local_database.dart';
import 'package:app_leitura/core/data/database/versioning.dart';
import 'package:app_leitura/core/sync/sync_providers.dart';
import 'package:app_leitura/features/account/application/account_providers.dart';
import 'package:app_leitura/features/account/data/local_library.dart';
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
import 'package:supabase_flutter/supabase_flutter.dart' show OtpType;

import '../../support/personal_builders.dart';
import '../account/support/fake_backend.dart';

const _isbn = '9788535910667';

void main() {
  test('Grátis com conta: começar → pausar → retomar → encerrar (pág. 120 de 368, o total do catálogo do aparelho) — '
      'nenhum pedido de rede, e tudo gravado no aparelho', () async {
    final backend = FakeBackend();
    final client = backend.client();
    addTearDown(client.dispose);
    await client.auth.verifyOTP(
      email: emailTeste,
      token: '123456',
      type: OtpType.email,
    );
    final db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false);
    addTearDown(db.close);
    final biblioteca = LocalLibrary(db);
    await biblioteca.setActiveOwner(contaTeste);
    final livro = UserBook(
      id: idTeste(1),
      meta: metaTeste(userId: contaTeste),
      title: 'Memórias Póstumas de Brás Cubas',
      authorDisplay: 'Machado de Assis',
      format: BookFileFormat.physical,
      status: ShelfStatus.reading,
      addedAt: DateTime.utc(2026, 9, 1, 12),
      isbn13: _isbn,
    );
    await UserBooksDao(db).upsert(livro);
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
    var agora = DateTime.utc(2026, 10, 9, 12);
    final c = ProviderContainer(
      overrides: [
        supabaseClientProvider.overrideWithValue(client),
        localDatabaseProvider.overrideWith((ref) async => db),
        localLibraryProvider.overrideWith((ref) async => biblioteca),
        localVersioningProvider.overrideWith(
          (ref) async => LocalVersioning(db, HlcClock(deviceId: 'aparelhoX')),
        ),
        clockProvider.overrideWithValue(() => agora),
      ],
    );
    addTearDown(c.dispose);
    final sub = c.listen(paperTimerProvider, (_, _) {});
    addTearDown(sub.close);
    backend.pedidos.clear();

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
    expect(paginas, 368);
    await timer.end(page: 120, pagesTotal: paginas);
    await pumpEventQueue();

    expect(
      backend.pedidos,
      isEmpty,
      reason: 'nada à rede: ${backend.caminhos}',
    );
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
}

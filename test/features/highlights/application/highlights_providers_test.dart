// G19.2 — a tela 25 ligada ao app: o provedor monta as dependências com o banco local, o versionamento, a conta ativa,
// o texto dos cartões pelo arquivo do livro neste aparelho, o clube (G21: o chip do cache da conta; sem servidor, nem
// ao vivo nem compartilhar), o relógio do app, o fuso e a folha de compartilhar. E o que a 25 devolve ao leitor (R13) compara por valor.
import 'dart:io';

import 'package:app_leitura/core/data/clock/hlc.dart';
import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/daos/library_daos.dart';
import 'package:app_leitura/core/data/database/local_database.dart';
import 'package:app_leitura/core/data/database/versioning.dart';
import 'package:app_leitura/core/sync/sync_providers.dart';
import 'package:app_leitura/features/account/application/account_providers.dart';
import 'package:app_leitura/features/account/data/local_library.dart';
import 'package:app_leitura/features/clubs/application/club_sources.dart'
    show ClubsHighlightsClubSource;
import 'package:app_leitura/features/clubs/application/clubs_providers.dart';
import 'package:app_leitura/features/highlights/application/card_text_source.dart';
import 'package:app_leitura/features/highlights/application/highlights_exit.dart';
import 'package:app_leitura/features/highlights/application/highlights_file_sink.dart';
import 'package:app_leitura/features/highlights/application/highlights_providers.dart';
import 'package:app_leitura/features/home/application/home_providers.dart'
    show clockProvider;
import 'package:app_leitura/features/library/application/library_import.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fixtures/mundo_2026_09_20.dart';

void main() {
  test('highlightsDepsProvider: banco, conta ativa, texto pelo arquivo, o clube do cache, relógio, fuso e compartilhar', () async {
    final db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false);
    addTearDown(db.close);
    final raiz = Directory.systemTemp.createTempSync('booknest_g19_deps_');
    addTearDown(() => raiz.deleteSync(recursive: true));
    final versioning = LocalVersioning(db, HlcClock(deviceId: 'aparelhoX'));
    final c = ProviderContainer(
      overrides: [
        localDatabaseProvider.overrideWith((ref) async => db),
        localLibraryProvider.overrideWith((ref) async => LocalLibrary(db)),
        localVersioningProvider.overrideWith((ref) async => versioning),
        booksDirProvider.overrideWithValue(() async => raiz),
        clockProvider.overrideWithValue(() => DateTime.utc(2026, 10, 9)),
        socialOwnerProvider.overrideWithValue(null),
      ],
    );
    addTearDown(c.dispose);
    final deps = await c.read(highlightsDepsProvider.future);
    expect(deps.db, same(db));
    expect(deps.repository.db, same(db));
    expect(deps.now(), DateTime.utc(2026, 10, 9));
    expect(deps.club, isA<ClubsHighlightsClubSource>());
    expect(
      await deps.club.clubOf(mundoReferencia.clube.postCompartilhadoId),
      isNull,
      reason: 'convidado: nenhum chip',
    );
    expect(deps.clubUpdates, isNull, reason: 'sem servidor');
    expect(deps.share, isNull, reason: 'sem servidor');
    expect(deps.files, isA<ShareHighlightsFileSink>());
    expect(deps.searchDelay, const Duration(milliseconds: 200));
    expect(
      deps.utcOffsetAt(DateTime.utc(2026, 10, 9)),
      DateTime.utc(2026, 10, 9).toLocal().timeZoneOffset,
    );
    final livro = mundoReferencia.domCasmurro;
    await UserBooksDao(db).upsert(livro);
    final fonte = await deps.textSourceFor(livro);
    expect(fonte, isA<EpubCardTextSource>());
    expect(
      ((fonte as EpubCardTextSource).path, fonte.sha),
      (null, livro.contentSha256 ?? ''),
      reason: 'sem o arquivo neste aparelho, o cartão fica com a citação',
    );
    expect(await deps.repository.search(livro.id, '   '), isNull);
  });

  test('a saída da 25 compara por valor (R13)', () {
    // valores de agora (não constantes): a igualdade é a do valor, não a da mesma instância
    final id = ['g', '1'].join();
    final page = int.parse('41');
    final a = HighlightsOpenAt(id, page: page);
    expect(a, HighlightsOpenAt(id, page: page));
    expect(a.hashCode, HighlightsOpenAt(id, page: page).hashCode);
    expect(a, isNot(HighlightsOpenAt(id, page: page, orphan: true)));
    expect(a, isNot(HighlightsOpenAt(id, page: page + 1)));
    expect(a, isNot(HighlightsOpenAt('${id}x', page: page)));
    final continuar = [const HighlightsContinue()].first;
    expect(continuar, equals(const HighlightsContinue()));
    expect(continuar.hashCode, const HighlightsContinue().hashCode);
    expect(a, isNot(continuar));
  });
}

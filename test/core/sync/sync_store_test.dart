// G06 — o lado do aparelho da sincronização: virar Pro reenfileira tudo do dono; recusas por relógio
// voltam quando a versão deixa de estar no futuro; livro/rótulo recusado por já existir outro igual
// no servidor vira um só quando o outro chega (ou volta à fila se o outro sumiu).
import 'dart:convert';

import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/daos/annotation_daos.dart';
import 'package:app_leitura/core/data/database/daos/kv_dao.dart';
import 'package:app_leitura/core/data/database/daos/library_daos.dart';
import 'package:app_leitura/core/data/database/daos/reader_daos.dart';
import 'package:app_leitura/core/data/database/local_sql.dart';
import 'package:app_leitura/core/sync/sync_backend.dart';
import 'package:app_leitura/core/sync/sync_store.dart';
import 'package:app_leitura/features/library/domain/user_book.dart';
import 'package:app_leitura/features/reader/annotations/domain/highlight_label.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/personal_builders.dart';
import 'support/sync_fakes.dart';

const String outraConta = '0199a7c4-2f00-7a10-8b20-0000000000ff';
final DateTime recusadoEm = DateTime.utc(2026, 10, 4, 12);

void main() {
  late DbTeste t;
  late SyncStore store;
  late List<String> apagados;

  setUp(() async {
    t = await DbTeste.abrir();
    apagados = [];
    store = SyncStore(
      t.db,
      removeFile: (p) async => apagados.add(p),
      now: () => recusadoEm,
    );
  });
  tearDown(() => t.fechar());

  Future<Set<String>> idsNaFila() async => {
    for (final r in await t.ps.getAll('SELECT data FROM ps_crud'))
      (jsonDecode(r['data'] as String) as Map)['id'] as String,
  };

  /// Recusa como a RPC devolveria, com a operação do estado atual da linha.
  Future<void> recusa(String table, String id, String error, String code) =>
      store.recordRejections(
        [SyncRejection(table: table, id: id, error: error, code: code)],
        [
          {'op': 'PUT', 'table': table, 'id': id, 'hlc': 'v'},
        ],
      );

  Future<void> arquivo(String livro, String caminho) => t.db
      .into(t.db.localFiles)
      .insert(
        LocalFilesCompanion.insert(
          userBookId: livro,
          path: caminho,
          bytes: 10,
          sha256: shaDoLivroTeste(1),
          updatedAt: t0Teste,
        ),
      );

  test('virar Pro: modo Pro e TODA linha do dono (inclusive apagada) na fila; de outra conta, não', () async {
    await UserBooksDao(t.db).upsert(livroTeste(1));
    await UserBooksDao(t.db).upsert(livroTeste(2, apagado: true));
    await AnnotationsDao(t.db).upsert(grifoTeste(3, livro: idTeste(1)));
    await UserBooksDao(t.db).upsert(livroTeste(4, dono: outraConta));
    expect(await store.isPro(), isFalse);
    expect(await store.turnPro(usuarioTeste), 3);
    expect(await store.isPro(), isTrue);
    expect(await idsNaFila(), {idTeste(1), idTeste(2), idTeste(3)});
    expect(await store.pendingUploads(), 3);
    await store.setFree();
    expect(await KvDao(t.db).get(syncModeKey), syncModeFree);
  });

  group('relógio adiantado (invalid_hlc)', () {
    const minuto = 60 * 1000;
    final base = DateTime.utc(2026, 10, 4, 12);

    test('volta à fila quando a versão deixa de estar > 5 min no futuro para o servidor', () async {
      await t.modoPro(usuarioTeste);
      final futuro = base.add(const Duration(minutes: 10));
      await UserBooksDao(t.db)
          .upsert(livroTeste(1).copyWith(meta: metaTeste(em: futuro)));
      await UserBooksDao(t.db).upsert(
        livroTeste(2, dono: outraConta).copyWith(
          meta: metaTeste(em: futuro, userId: outraConta),
        ),
      );
      await t.ps.disconnectAndClear(clearLocal: false); // fila vazia
      await recusa('user_books', idTeste(1), 'invalid_hlc', '22023');
      await recusa('user_books', idTeste(2), 'invalid_hlc', '22023');
      await recusa('user_books', idTeste(9), 'invalid_hlc', '22023'); // já saiu

      final agora = base.millisecondsSinceEpoch;
      expect(
        await store.requeueClockRejections(
          owner: usuarioTeste,
          serverNowMs: agora,
        ),
        0,
      );
      expect(await t.fila(), 0);
      expect(
        await store.rejectionCount(),
        2,
        reason: 'a da linha que saiu cai',
      );

      expect(
        await store.requeueClockRejections(
          owner: usuarioTeste,
          serverNowMs: agora + 6 * minuto,
        ),
        1,
      );
      expect(await idsNaFila(), {idTeste(1)});
      expect(
        await store.rejectionCount(),
        1,
        reason: 'a da outra conta fica para quando ela for a dona ativa',
      );
    });
  });

  group('únicos parciais do servidor (outro aparelho já mandou o mesmo arquivo/cor)', () {
    test(
      'livro recusado (23505) + o outro chega pela sincronização → um livro só',
      () async {
        await t.modoPro(usuarioTeste);
        // este aparelho: o livro 1, lido depois (versão mais nova), com grifo, marcador, sessão e posição
        final meu = livroTeste(
          1,
        ).copyWith(status: ShelfStatus.finished, meta: metaTeste(contador: 5));
        await UserBooksDao(t.db).upsert(meu);
        await AnnotationsDao(t.db).upsert(grifoTeste(10, livro: meu.id));
        await BookmarksDao(t.db).upsert(marcadorTeste(11, livro: meu.id));
        await ReadingSessionsDao(t.db)
            .upsert(sessaoTeste(12, livro: meu.id, inicio: t0Teste));
        await ReadingPositionsDao(t.db).upsert(posicaoTeste(meu.id));
        await arquivo(meu.id, '/livros/meu.epub');
        // o do outro aparelho chega pela sincronização: mesmo arquivo, outro id, versão mais velha
        await UserBooksDao(t.db)
            .upsert(livroTeste(2, title: 'Do outro aparelho'));
        await t.ps.execute(
          'UPDATE user_books SET content_sha256 = ? WHERE id = ?',
          [shaDoLivroTeste(1), idTeste(2)],
        );
        await ReadingPositionsDao(t.db).upsert(posicaoTeste(idTeste(2)));
        await arquivo(idTeste(2), '/livros/dele.epub');
        await t.ps.disconnectAndClear(clearLocal: false);
        await recusa('user_books', meu.id, 'duplicate key value', '23505');
        for (final (tab, id) in [
          ('annotations', idTeste(10)),
          ('bookmarks', idTeste(11)),
          ('reading_sessions', idTeste(12)),
          ('reading_positions', meu.id),
        ]) {
          await recusa(tab, id, 'violates foreign key constraint', '23503');
        }

        expect(await store.resolveUniqueConflicts(owner: usuarioTeste), 4);
        expect(await UserBooksDao(t.db).byId(meu.id), isNull);
        final fica = (await UserBooksDao(t.db).byId(idTeste(2)))!;
        expect(fica.status, ShelfStatus.finished, reason: 'vale o mais novo');
        expect(fica.meta.version, meu.meta.version);
        expect(await AnnotationsDao(t.db).forBook(idTeste(2)), hasLength(1));
        expect(await BookmarksDao(t.db).forBook(idTeste(2)), hasLength(1));
        expect(
          await ReadingSessionsDao(t.db).forBook(idTeste(2)),
          hasLength(1),
        );
        expect(await t.conta('SELECT count(*) FROM reading_positions'), 1);
        expect(await store.rejectionCount(), 0);
        expect(await idsNaFila(), {
          idTeste(2),
          idTeste(10),
          idTeste(11),
          idTeste(12),
        }, reason: 'o que ficou e o que passou para ele sobem de novo');
        expect(await t.conta('SELECT count(*) FROM local_files'), 1);
        expect(apagados, ['/livros/meu.epub']);
      },
    );

    test('o outro não chegou: espera; depois de uma sincronização completa sem ele, volta à fila', () async {
      await t.modoPro(usuarioTeste);
      await UserBooksDao(t.db).upsert(livroTeste(1));
      await t.ps.disconnectAndClear(clearLocal: false);
      await recusa('user_books', idTeste(1), 'duplicate key value', '23505');
      expect(await store.resolveUniqueConflicts(owner: usuarioTeste), 0);
      expect(
        await store.resolveUniqueConflicts(
          owner: usuarioTeste,
          syncedAt: recusadoEm.subtract(const Duration(minutes: 1)),
        ),
        0,
      );
      expect(await store.rejectionCount(), 1);
      expect(
        await store.resolveUniqueConflicts(
          owner: usuarioTeste,
          syncedAt: recusadoEm.add(const Duration(minutes: 1)),
        ),
        1,
      );
      expect(await idsNaFila(), {idTeste(1)});
      expect(await store.rejectionCount(), 0);
    });

    test(
      'rótulo da mesma cor: fica o que o servidor tem, com o nome mais novo',
      () async {
        await t.modoPro(usuarioTeste);
        Future<void> rotulo(int n, String nome, int contador) =>
            HighlightLabelsDao(t.db).upsert(
              HighlightLabel(
                id: idTeste(n),
                meta: metaTeste(contador: contador),
                color: '#FED170',
                label: nome,
              ),
            );
        await rotulo(1, 'do servidor', 0);
        await t.ps.execute(
          "UPDATE highlight_labels SET color = '#C7B8FF' WHERE id = ?",
          [idTeste(1)],
        ); // libera a cor para o DAO aceitar o 2º
        await rotulo(2, 'meu, mais novo', 3);
        await t.ps.execute(
          "UPDATE highlight_labels SET color = '#FED170' WHERE id = ?",
          [idTeste(1)],
        );
        await t.ps.disconnectAndClear(clearLocal: false);
        await recusa(
          'highlight_labels',
          idTeste(2),
          'duplicate key value',
          '23505',
        );
        expect(await store.resolveUniqueConflicts(owner: usuarioTeste), 1);
        final r = await HighlightLabelsDao(t.db).forUser(usuarioTeste);
        expect(r.map((l) => (l.id, l.label)), [(idTeste(1), 'meu, mais novo')]);
        expect(await idsNaFila(), {idTeste(1)});
      },
    );

    test('recusa de uma linha que já saiu do aparelho cai sozinha', () async {
      await recusa('user_books', idTeste(7), 'duplicate key value', '23505');
      expect(await store.resolveUniqueConflicts(owner: usuarioTeste), 0);
      expect(await store.rejectionCount(), 0);
    });
  });
}

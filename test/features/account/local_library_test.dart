// D-68: cada conta (e o convidado) tem as suas linhas no aparelho. Entrar traz o que foi feito como
// convidado; sair esconde ou apaga; exportar leva tudo do dono (D-65).
import 'dart:convert';
import 'dart:io';

import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/daos/annotation_daos.dart';
import 'package:app_leitura/core/data/database/daos/kv_dao.dart';
import 'package:app_leitura/core/data/database/daos/library_daos.dart';
import 'package:app_leitura/core/data/database/daos/reader_daos.dart';
import 'package:app_leitura/core/data/database/local_sql.dart';
import 'package:app_leitura/core/data/model/nullable.dart';
import 'package:app_leitura/core/sync/ebook_cloud.dart' show EbookCloud;
import 'package:app_leitura/features/account/data/local_library.dart';
import 'package:app_leitura/features/library/domain/user_book.dart';
import 'package:app_leitura/features/reader/annotations/domain/highlight_label.dart';
import 'package:app_leitura/features/reader/annotations/ink/ink_changes.dart'
    show draftKey;
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:app_leitura/features/reading_session/data/paper_timer_store.dart';
import 'package:app_leitura/features/reading_session/domain/open_paper_session.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/personal_builders.dart';

const String conta = '0199a7c4-2f00-7a10-8b20-0000000000aa';

void main() {
  late AppDatabase db;
  late LocalLibrary lib;
  late List<String> arquivosApagados;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false);
    arquivosApagados = [];
    lib = LocalLibrary(db, removeFile: (p) async => arquivosApagados.add(p));
  });
  tearDown(() => db.close());

  /// Um livro com grifo, nota, marcador, sessão, posição e os caches locais.
  Future<void> semearLivro(
    int n,
    String dono, {
    String titulo = 'Dom Casmurro',
  }) async {
    final livro = livroTeste(n, dono: dono, title: titulo);
    await UserBooksDao(db).upsert(livro);
    final grifo = grifoTeste(n * 10, livro: livro.id, dono: dono);
    await AnnotationsDao(db).upsert(grifo);
    await BookmarksDao(db)
        .upsert(marcadorTeste(n * 10 + 1, livro: livro.id, dono: dono));
    await ReadingSessionsDao(db).upsert(
      sessaoTeste(n * 10 + 2, livro: livro.id, inicio: t0Teste, dono: dono),
    );
    await ReadingPositionsDao(db).upsert(posicaoTeste(livro.id, dono: dono));
    await db
        .into(db.localFiles)
        .insert(
          LocalFilesCompanion.insert(
            userBookId: livro.id,
            path: '/livros/${livro.id}.epub',
            bytes: 10,
            sha256: livro.contentSha256!,
            updatedAt: t0Teste,
          ),
        );
    await db
        .into(db.bookContentIndex)
        .insert(
          BookContentIndexCompanion.insert(
            userBookId: livro.id,
            contentSha256: livro.contentSha256!,
            refPageVersion: 1,
            spineJson: '[]',
            charCountsJson: '[]',
            tocJson: '[]',
            refPagesJson: '[]',
            builtAt: t0Teste,
          ),
        );
    await db
        .into(db.pageLayoutCache)
        .insert(
          PageLayoutCacheCompanion.insert(
            userBookId: livro.id,
            settingsHash: 'h',
            viewport: '390x844@3',
            fontsVersion: 1,
            breaks: Uint8List(0),
            createdAt: t0Teste,
          ),
        );
  }

  Future<void> ajustes(
    String dono, {
    required int contador,
    ReaderPaper? papel,
  }) => ReaderSettingsDao(db).upsert(
    ReaderSettings(
      id: dono,
      meta: metaTeste(userId: dono, contador: contador),
    ).copyWith(paper: papel ?? ReaderPaper.noite),
  );

  Future<void> rotulo(int n, String dono, String cor, String nome) =>
      HighlightLabelsDao(db).upsert(
        HighlightLabel(
          id: idTeste(n),
          meta: metaTeste(userId: dono),
          color: cor,
          label: nome,
        ),
      );

  Future<int> linhas(String sql, [List<Object> args = const []]) async =>
      (await db
              .customSelect(sql, variables: [for (final a in args) Variable(a)])
              .getSingle())
          .read<int>('n');

  Future<int> fts(String dono) => linhas(
    'SELECT count(*) AS n FROM annotations_fts WHERE annotation_id IN '
    '(SELECT id FROM annotations WHERE user_id = ?)',
    [dono],
  );

  group('donos', () {
    test('o convidado ganha um id (UUIDv7) na 1ª vez e o mantém; sem dono ativo = convidado', () async {
      final g = await lib.guestOwnerId();
      expect(
        g,
        matches(
          RegExp(
            r'^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
          ),
        ),
      );
      expect(await lib.guestOwnerId(), g);
      expect(await lib.activeOwnerId(), g);
      final vistos = <String?>[];
      final sub = lib.watchActiveOwnerId().listen(vistos.add);
      await lib.setActiveOwner(conta);
      expect(await lib.activeOwnerId(), conta);
      await pumpEventQueue();
      expect(vistos.last, conta);
      await sub.cancel();
    });
  });

  test('donos guardados (contas que saíram) e o bloqueio de menor de 13 ficam no aparelho', () async {
    final g = await lib.guestOwnerId();
    await semearLivro(1, conta);
    await semearLivro(2, g);
    expect(await lib.ownersExcept({g}), {conta});
    expect(await lib.countRowsExcept({g}), 5);
    expect(await lib.countRowsExcept({g, conta}), 0);
    expect(await lib.isUnderageBlocked(), isFalse);
    await lib.setUnderageBlocked(true);
    expect(await lib.isUnderageBlocked(), isTrue);
    await lib.setUnderageBlocked(false);
    expect(await lib.isUnderageBlocked(), isFalse);
  });

  group('adopt (entrar numa conta)', () {
    test('tudo do convidado passa para a conta, com o índice de busca dos grifos junto', () async {
      final g = await lib.guestOwnerId();
      await semearLivro(1, g);
      await ajustes(g, contador: 1);
      await rotulo(90, g, '#FED170', 'lindo');
      final antes = await lib.countRows(g);
      expect(
        antes,
        7,
      ); // livro, grifo, marcador, sessão, posição, ajustes, rótulo

      final r = await lib.adopt(from: g, to: conta);
      expect(r.moved, antes);
      expect(r.discarded, 0);
      expect(await lib.countRows(g), 0);
      expect(await lib.countRows(conta), antes);
      expect(await ReaderSettingsDao(db).forUser(conta), isNotNull);
      expect(await ReaderSettingsDao(db).forUser(g), isNull);
      expect(await fts(conta), 1);
      expect(
        await AnnotationsDao(db).search(idTeste(1), 'Capitu'),
        hasLength(1),
      );
    });

    test(
      'preferência única: vence a versão mais nova (LWW pelo version_hlc)',
      () async {
        final g = await lib.guestOwnerId();
        await ajustes(conta, contador: 1, papel: ReaderPaper.sepia);
        await ajustes(g, contador: 2, papel: ReaderPaper.noite); // mais nova
        var r = await lib.adopt(from: g, to: conta);
        expect(r.moved, 1);
        expect(
          (await ReaderSettingsDao(db).forUser(conta))!.paper,
          ReaderPaper.noite,
        );
        expect(await linhas('SELECT count(*) AS n FROM reader_settings'), 1);

        await ajustes(
          g,
          contador: 0,
          papel: ReaderPaper.sepia,
        ); // mais velha que a da conta
        r = await lib.adopt(from: g, to: conta);
        expect(r.moved, 0);
        expect(r.discarded, 1);
        expect(
          (await ReaderSettingsDao(db).forUser(conta))!.paper,
          ReaderPaper.noite,
        );
        expect(await ReaderSettingsDao(db).forUser(g), isNull);
      },
    );

    test('G16 — os rascunhos da tinta do convidado passam para a conta; o do livro juntado, para o que ficou (D-166)', () async {
      final g = await lib.guestOwnerId();
      await semearLivro(1, conta);
      final dup = livroTeste(2, dono: g).copyWith(
        contentSha256: Nullable(shaDoLivroTeste(1)),
        meta: metaTeste(userId: g, contador: 5),
      );
      await UserBooksDao(db).upsert(dup);
      await semearLivro(3, g);
      for (final (k, v) in [
        (draftKey(g, dup.id, 's1'), '{"um":1}'),
        (draftKey(g, idTeste(3), 's2'), '{"dois":2}'),
        (draftKey(conta, idTeste(1), 's0'), '{"zero":0}'),
        ('outra:${draftKey(g, idTeste(3), 's9')}', '{"fora":9}'),
      ]) {
        await KvDao(db).set(k, v);
      }
      await lib.adopt(from: g, to: conta);
      expect(
        await KvDao(db).get(draftKey(conta, idTeste(1), 's1')),
        '{"um":1}',
      );
      expect(
        await KvDao(db).get(draftKey(conta, idTeste(3), 's2')),
        '{"dois":2}',
      );
      expect(
        await KvDao(db).get(draftKey(conta, idTeste(1), 's0')),
        '{"zero":0}',
      );
      expect(
        await linhas(
          "SELECT count(*) AS n FROM kv WHERE key LIKE 'ink_draft:%' AND key LIKE ?",
          ['%$g%'],
        ),
        0,
      );
      expect(
        await KvDao(db).get('outra:${draftKey(g, idTeste(3), 's9')}'),
        '{"fora":9}',
        reason: 'só as chaves que começam com o rascunho',
      );
    });

    test('T04 — a sessão aberta do cronômetro do convidado passa para a conta (R8)', () async {
      final g = await lib.guestOwnerId();
      final s = OpenPaperSession.start(
        id: idTeste(90),
        userBookId: idTeste(3),
        now: t0Teste,
      );
      await KvPaperTimerStore(db).save(g, s);
      await lib.adopt(from: g, to: conta);
      expect(await KvPaperTimerStore(db).load(conta), s);
      expect(await KvDao(db).get(paperTimerKey(g)), isNull);
    });

    test('rótulo da mesma cor: fica o da conta; de outra cor: passa', () async {
      final g = await lib.guestOwnerId();
      await rotulo(91, conta, '#FED170', 'da conta');
      await rotulo(92, g, '#FED170', 'do convidado');
      await rotulo(93, g, '#C7B8FF', 'roxo');
      final r = await lib.adopt(from: g, to: conta);
      expect(r.discarded, 1);
      final daConta = await HighlightLabelsDao(db).forUser(conta);
      expect(daConta.map((l) => l.label), containsAll(['da conta', 'roxo']));
      expect(daConta.map((l) => l.label), isNot(contains('do convidado')));
    });

    test('G06 — o mesmo arquivo na estante do convidado e da conta vira um livro só (o da conta)', () async {
      final g = await lib.guestOwnerId();
      await semearLivro(1, conta);
      // o convidado tem o MESMO arquivo (outro id), lido depois (versão mais nova)
      final dup = livroTeste(2, dono: g, title: 'Dom Casmurro (convidado)')
          .copyWith(
            contentSha256: Nullable(shaDoLivroTeste(1)),
            status: ShelfStatus.finished,
            meta: metaTeste(userId: g, contador: 5),
          );
      await UserBooksDao(db).upsert(dup);
      await AnnotationsDao(db).upsert(grifoTeste(30, livro: dup.id, dono: g));
      await BookmarksDao(db).upsert(marcadorTeste(31, livro: dup.id, dono: g));
      await ReadingPositionsDao(db).upsert(posicaoTeste(dup.id, dono: g));
      await db
          .into(db.localFiles)
          .insert(
            LocalFilesCompanion.insert(
              userBookId: dup.id,
              path: '/livros/copia.epub',
              bytes: 10,
              sha256: shaDoLivroTeste(1),
              updatedAt: t0Teste,
            ),
          );

      final r = await lib.adopt(from: g, to: conta);
      expect(r.mergedBooks, 1);
      expect(await UserBooksDao(db).byId(dup.id), isNull);
      final fica = (await UserBooksDao(db).byId(idTeste(1)))!;
      expect(fica.meta.userId, conta);
      expect(fica.status, ShelfStatus.finished); // o estado mais novo
      expect(fica.title, 'Dom Casmurro (convidado)');
      expect(
        await linhas(
          'SELECT count(*) AS n FROM user_books WHERE content_sha256 = ? '
          'AND deleted_at IS NULL',
          [shaDoLivroTeste(1)],
        ),
        1,
        reason: 'o servidor só aceita um livro ativo por arquivo',
      );
      for (final t in ['annotations', 'bookmarks']) {
        expect(
          await linhas(
            'SELECT count(*) AS n FROM $t WHERE user_book_id = ? AND user_id = ?',
            [idTeste(1), conta],
          ),
          2,
          reason: t,
        );
      }
      expect(await linhas('SELECT count(*) AS n FROM reading_positions'), 1);
      expect(
        await AnnotationsDao(db).search(idTeste(1), 'Capitu'),
        hasLength(2),
      );
      expect(await linhas('SELECT count(*) AS n FROM local_files'), 1);
      expect(arquivosApagados, ['/livros/copia.epub']);
    });

    test('de um dono para ele mesmo: nada muda', () async {
      final g = await lib.guestOwnerId();
      await semearLivro(1, g);
      final r = await lib.adopt(from: g, to: g);
      expect((r.moved, r.discarded), (0, 0));
      expect(await lib.countRows(g), 5);
    });
  });

  group('erase (sair e apagar / excluir e apagar)', () {
    test('G09 (D-90): a capa que veio no arquivo some com o último livro que usa o arquivo', () async {
      final capas = Directory.systemTemp.createTempSync(
        'booknest_capas_arquivo_',
      );
      addTearDown(() => capas.deleteSync(recursive: true));
      final apagados = <String>[];
      final l = LocalLibrary(
        db,
        removeFile: (p) async => apagados.add(p),
        fileCovers: () async => capas,
      );
      final g = await l.guestOwnerId();
      await semearLivro(1, conta);
      await semearLivro(2, g, titulo: 'Memórias Póstumas');
      final shaConta = (await UserBooksDao(db).byId(idTeste(1)))!
          .contentSha256!;
      final shaConvidado = (await UserBooksDao(db).byId(idTeste(2)))!
          .contentSha256!;
      await l.erase(conta);
      String capa(String sha) =>
          '${capas.path}${Platform.pathSeparator}$sha.img';
      expect(apagados, contains(capa(shaConta)));
      expect(apagados, isNot(contains(capa(shaConvidado))));
    });

    test(
      'G09: o mesmo arquivo em outra conta do aparelho — a capa fica',
      () async {
        final capas = Directory.systemTemp.createTempSync(
          'booknest_capas_arquivo_',
        );
        addTearDown(() => capas.deleteSync(recursive: true));
        final apagados = <String>[];
        final l = LocalLibrary(
          db,
          removeFile: (p) async => apagados.add(p),
          fileCovers: () async => capas,
        );
        final g = await l.guestOwnerId();
        await semearLivro(1, conta);
        final mesmo = (await UserBooksDao(db).byId(idTeste(1)))!;
        await UserBooksDao(db).upsert(
          livroTeste(
            3,
            dono: g,
          ).copyWith(contentSha256: Nullable(mesmo.contentSha256)),
        );
        await l.erase(conta);
        expect(apagados.where((p) => p.endsWith('.img')), isEmpty);
      },
    );

    test('T04 — a sessão aberta do cronômetro sai com o dono; a do outro fica (R8)', () async {
      final g = await lib.guestOwnerId();
      final s = OpenPaperSession.start(
        id: idTeste(90),
        userBookId: idTeste(1),
        now: t0Teste,
      );
      await KvPaperTimerStore(db).save(conta, s);
      await KvPaperTimerStore(db).save(g, s);
      await lib.erase(conta);
      expect(await KvDao(db).get(paperTimerKey(conta)), isNull);
      expect(await KvPaperTimerStore(db).load(g), s);
    });

    test('apaga só o dono: linhas, índice de busca, caches dos livros e os arquivos', () async {
      final g = await lib.guestOwnerId();
      await semearLivro(1, conta);
      await semearLivro(2, g, titulo: 'Memórias Póstumas');
      await ajustes(conta, contador: 1);

      final n = await lib.erase(conta);
      expect(
        n,
        6 + 3,
      ); // 6 pessoais + arquivo, índice e cache de páginas do livro
      expect(await lib.countRows(conta), 0);
      // o índice de busca é tabela virtual sem gatilho de DELETE: conferir pelo id do grifo apagado
      expect(
        await linhas(
          'SELECT count(*) AS n FROM annotations_fts WHERE annotation_id = ?',
          [idTeste(10)],
        ),
        0,
      );
      expect(await linhas('SELECT count(*) AS n FROM annotations_fts'), 1);
      for (final t in [
        'local_files',
        'book_content_index',
        'page_layout_cache',
      ]) {
        expect(
          await linhas('SELECT count(*) AS n FROM $t WHERE user_book_id = ?', [
            idTeste(1),
          ]),
          0,
          reason: t,
        );
        expect(
          await linhas('SELECT count(*) AS n FROM $t WHERE user_book_id = ?', [
            idTeste(2),
          ]),
          1,
          reason: '$t do outro dono fica',
        );
      }
      expect(arquivosApagados, ['/livros/${idTeste(1)}.epub']);
      expect(await lib.countRows(g), 5);
      expect(await fts(g), 1);
    });

    test('G06 — o que a sincronização guardou das linhas do dono sai junto (recusas, remoções ignoradas, envio de e-book pela metade)', () async {
      final g = await lib.guestOwnerId();
      await semearLivro(1, conta);
      await semearLivro(2, g, titulo: 'Memórias Póstumas');
      Future<void> recusa(String id, String linha, String dono) =>
          db.customStatement(
            'INSERT INTO sync_rejections (id, entity, row_id, reason, code, operation, rejected_at) '
            'VALUES (?, ?, ?, ?, ?, ?, ?)',
            [
              id,
              'user_books',
              linha,
              'duplicate key value',
              '23505',
              jsonEncode({
                'table': 'user_books',
                'id': linha,
                'data': {'user_id': dono, 'title': 'título guardado'},
              }),
              '2026-10-04T12:00:00.000Z',
            ],
          );
      await recusa('r1', idTeste(1), conta);
      await recusa('r2', idTeste(2), g);
      await recusa('r3', idTeste(99), conta); // linha que já saiu do aparelho
      for (final id in [idTeste(1), idTeste(2)]) {
        await db.customStatement(
          'INSERT INTO sync_ignored_deletes (entity, row_id, received_at) VALUES (?, ?, ?)',
          ['user_books', id, '2026-10-04T12:00:00.000Z'],
        );
        await db.customStatement('INSERT INTO kv (key, value) VALUES (?, ?)', [
          EbookCloud.resumeKey(id),
          '{"url":"https://exemplo.invalid/envio"}',
        ]);
      }

      await lib.erase(conta);
      expect(
        await linhas(
          'SELECT count(*) AS n FROM sync_rejections WHERE id <> ?',
          ['r2'],
        ),
        0,
      );
      expect(await linhas('SELECT count(*) AS n FROM sync_rejections'), 1);
      expect(
        await linhas(
          'SELECT count(*) AS n FROM sync_ignored_deletes WHERE row_id = ?',
          [idTeste(1)],
        ),
        0,
      );
      expect(await linhas('SELECT count(*) AS n FROM sync_ignored_deletes'), 1);
      expect(
        await linhas('SELECT count(*) AS n FROM kv WHERE key = ?', [
          EbookCloud.resumeKey(idTeste(1)),
        ]),
        0,
      );
      expect(
        await linhas('SELECT count(*) AS n FROM kv WHERE key = ?', [
          EbookCloud.resumeKey(idTeste(2)),
        ]),
        1,
      );
    });

    test(
      'G16 — o rascunho da tinta do dono sai junto; o de outro dono fica',
      () async {
        final g = await lib.guestOwnerId();
        for (final k in [
          draftKey(conta, idTeste(1), 's1'),
          draftKey(conta, idTeste(2), 's2'),
          draftKey(g, idTeste(1), 's3'),
        ]) {
          await db.customStatement(
            'INSERT INTO kv (key, value) VALUES (?, ?)',
            [k, '{"v":1}'],
          );
        }
        await lib.erase(conta);
        expect(
          await linhas(
            "SELECT count(*) AS n FROM kv WHERE key LIKE 'ink_draft:%'",
          ),
          1,
        );
        expect(
          await linhas('SELECT count(*) AS n FROM kv WHERE key = ?', [
            draftKey(g, idTeste(1), 's3'),
          ]),
          1,
        );
      },
    );
  });

  test('clearSocialCache: o cache social da conta anterior sai', () async {
    await db
        .into(db.socialCache)
        .insert(
          SocialCacheCompanion.insert(
            key: 'perfil',
            payload: '{}',
            updatedAt: t0Teste,
          ),
        );
    await lib.clearSocialCache();
    expect(await linhas('SELECT count(*) AS n FROM social_cache'), 0);
  });

  test(
    'export: as 10 tabelas pessoais, só as linhas do dono, como o banco guarda',
    () async {
      final g = await lib.guestOwnerId();
      await semearLivro(1, conta, titulo: 'Dom Casmurro');
      await semearLivro(2, g, titulo: 'Memórias Póstumas');
      final e = await lib.export(conta);
      expect(e.keys.toSet(), personalSyncColumns.keys.toSet());
      expect(e['user_books']!.single['title'], 'Dom Casmurro');
      expect(e['annotations'], hasLength(1));
      expect(e['reader_settings'], isEmpty);
      expect(
        e.values.expand((rows) => rows).every((r) => r['user_id'] == conta),
        isTrue,
      );
    },
  );
}

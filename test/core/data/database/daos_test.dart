// G03.3 — DAOs em memória: ida e volta das entidades, filtros, ordem, busca FTS5 e formato
// canônico gravado; versões das escritas locais (regra receive-antes-de-send + kv).
import 'package:app_leitura/core/data/clock/hlc.dart';
import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/daos/annotation_daos.dart';
import 'package:app_leitura/core/data/database/daos/kv_dao.dart';
import 'package:app_leitura/core/data/database/daos/library_daos.dart';
import 'package:app_leitura/core/data/database/daos/reader_daos.dart';
import 'package:app_leitura/core/data/database/failures.dart';
import 'package:app_leitura/core/data/database/versioning.dart';
import 'package:app_leitura/core/data/model/nullable.dart';
import 'package:app_leitura/features/library/domain/reading_goals.dart';
import 'package:app_leitura/features/reader/annotations/domain/highlight_label.dart';
import 'package:app_leitura/features/reader/annotations/domain/pen_presets.dart';
import 'package:app_leitura/features/reader/domain/locator.dart';
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/personal_builders.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false));
  tearDown(() => db.close());

  Future<Map<String, Object?>> linha(String tabela, String id) async =>
      (await db
              .customSelect(
                'SELECT * FROM $tabela WHERE id = ?',
                variables: [Variable.withString(id)],
              )
              .getSingle())
          .data;

  group('UserBooksDao', () {
    test(
      'ida e volta da entidade; datas e versão no formato canônico',
      () async {
        final dao = UserBooksDao(db);
        final livro = livroTeste(1).copyWith(
          lastOpenedAt: Nullable(DateTime.utc(2026, 9, 20, 22, 59, 1, 5, 7)),
        );
        await dao.upsert(livro);
        expect(await dao.byId(livro.id), livro);
        final raw = await linha('user_books', livro.id);
        expect(raw['created_at'], '2026-09-20T23:00:00.000000Z');
        expect(raw['last_opened_at'], '2026-09-20T22:59:01.005007Z');
        expect(raw['version_hlc'], '0001789945200000-0000-aparelhoA');
        expect(raw['format'], 'epub');
        expect(raw['_extras'], isNull);
      },
    );

    test(
      'estante sem apagados, na ordem de chegada; upsert atualiza',
      () async {
        final dao = UserBooksDao(db);
        await dao.upsert(livroTeste(3, title: 'Senhora'));
        await dao.upsert(livroTeste(1));
        await dao.upsert(livroTeste(2, title: 'O Alienista', apagado: true));
        expect((await dao.shelf(usuarioTeste)).map((b) => b.title), [
          'Dom Casmurro',
          'Senhora',
        ]);
        await dao.upsert(livroTeste(3, title: 'Senhora (2ª ed.)'));
        expect((await dao.shelf(usuarioTeste)).map((b) => b.title), [
          'Dom Casmurro',
          'Senhora (2ª ed.)',
        ]);
        expect(
          await dao.shelf('00000000-0000-4000-8000-000000000000'),
          isEmpty,
        );
      },
    );

    test('escrita local não apaga `_extras` vindo do servidor', () async {
      final dao = UserBooksDao(db);
      await dao.upsert(livroTeste(1));
      await db.customStatement(
        "UPDATE user_books SET _extras = '{\"lang\":\"pt\"}' WHERE id = '${idTeste(1)}'",
      );
      await dao.upsert(livroTeste(1, title: 'Dom Casmurro (ed. crítica)'));
      expect(
        (await linha('user_books', idTeste(1)))['_extras'],
        '{"lang":"pt"}',
      );
    });
  });

  group('leitor', () {
    test('posição: localizador JSON e progressão "0.62113"', () async {
      final dao = ReadingPositionsDao(db);
      final p = posicaoTeste(idTeste(1));
      await dao.upsert(p);
      expect(await dao.forBook(idTeste(1)), p);
      expect(await dao.forBook(idTeste(2)), isNull);
      final raw = await linha('reading_positions', idTeste(1));
      expect(raw['progression'], '0.62113');
      expect(raw['locator'], startsWith('{"v":1,"sha":'));
    });

    test(
      'sessões: por livro e por intervalo de início, sem apagadas',
      () async {
        final dao = ReadingSessionsDao(db);
        final livro = idTeste(1);
        final a = sessaoTeste(
          10,
          livro: livro,
          inicio: DateTime.utc(2026, 9, 20, 12),
        );
        final b = sessaoTeste(
          11,
          livro: livro,
          inicio: DateTime.utc(2026, 9, 21, 1, 30),
        );
        final c = sessaoTeste(
          12,
          livro: livro,
          inicio: DateTime.utc(2026, 9, 19, 12),
        );
        final apagada = sessaoTeste(
          13,
          livro: livro,
          inicio: DateTime.utc(2026, 9, 20, 13),
        ).copyWith(meta: metaTeste(apagado: true));
        for (final s in [b, a, c, apagada]) {
          await dao.upsert(s);
        }
        expect(await dao.forBook(livro), [c, a, b]);
        // dia 20 em São Paulo = [20 03:00Z, 21 03:00Z)
        expect(
          await dao.startedBetween(
            usuarioTeste,
            DateTime.utc(2026, 9, 20, 3),
            DateTime.utc(2026, 9, 21, 3),
          ),
          [a, b],
        );
      },
    );

    test('marcadores na ordem do livro, sem apagados', () async {
      final dao = BookmarksDao(db);
      final livro = idTeste(1);
      final m159 = marcadorTeste(20, livro: livro, pagina: 159);
      final m3 = marcadorTeste(21, livro: livro, pagina: 3);
      final m6 = marcadorTeste(22, livro: livro, pagina: 6);
      await dao.upsert(m159);
      await dao.upsert(m3);
      await dao.upsert(m6);
      await dao.upsert(
        marcadorTeste(23, livro: livro, pagina: 40, apagado: true),
      );
      expect((await dao.forBook(livro)).map((b) => b.refPage), [3, 6, 159]);
      expect(await dao.watchForBook(livro).first, [m3, m6, m159]);
      // G15 (D-152): pelo id, também a apagada (a fita da aba Marcadas devolve a mesma linha)
      expect(await dao.byId(m3.id), m3);
      final apagada = await dao.byId(idTeste(23));
      expect(apagada!.meta.isDeleted, isTrue);
      expect(apagada.refPage, 40);
      expect(await dao.byId(idTeste(99)), isNull);
    });

    test('ajustes de leitura e metas: 1 linha por usuário', () async {
      final ajustes = ReaderSettings(
        id: usuarioTeste,
        meta: metaTeste(),
      ).copyWith(paper: ReaderPaper.noite, fontStep: 5);
      await ReaderSettingsDao(db).upsert(ajustes);
      expect(await ReaderSettingsDao(db).forUser(usuarioTeste), ajustes);
      final metas = ReadingGoals(
        id: usuarioTeste,
        meta: metaTeste(),
        badgeTargetDays: 14,
      );
      await ReadingGoalsDao(db).upsert(metas);
      expect(await ReadingGoalsDao(db).forUser(usuarioTeste), metas);
      expect(await ReadingGoalsDao(db).forUser(idTeste(9)), isNull);
    });
  });

  group('anotações', () {
    test(
      'ida e volta; ordem do livro (página → início → criação); sem apagadas',
      () async {
        final dao = AnnotationsDao(db);
        final livro = idTeste(1);
        final g1 = grifoTeste(30, livro: livro, pagina: 159, inicio: 300);
        final g2 = grifoTeste(
          31,
          livro: livro,
          pagina: 159,
          inicio: 10,
          exato: 'Olhos de ressaca',
        );
        final g3 = grifoTeste(
          32,
          livro: livro,
          pagina: 6,
          cor: '#FFC1C6',
          exato: 'atar as duas pontas da vida',
        );
        final nota = notaTeste(
          33,
          livro: livro,
          pai: g3,
          texto: 'É o livro todo nessa frase.',
        );
        final apagado = grifoTeste(34, livro: livro, apagado: true);
        for (final a in [g1, g2, g3, nota, apagado]) {
          await dao.upsert(a);
        }
        expect(await dao.forBook(livro), [g3, nota, g2, g1]);
        expect(await dao.watchForBook(livro).first, hasLength(4));
      },
    );

    test(
      'byId: a linha viva ou apagada; id que não existe → null (G13)',
      () async {
        final dao = AnnotationsDao(db);
        final vivo = grifoTeste(45, livro: idTeste(1));
        final apagado = grifoTeste(46, livro: idTeste(1), apagado: true);
        await dao.upsert(vivo);
        await dao.upsert(apagado);
        expect(await dao.byId(vivo.id), vivo);
        expect(await dao.byId(apagado.id), apagado);
        expect(await dao.byId(idTeste(47)), isNull);
      },
    );

    test('grifos do usuário em todos os livros (D-40)', () async {
      final dao = AnnotationsDao(db);
      await dao.upsert(grifoTeste(40, livro: idTeste(1)));
      await dao.upsert(grifoTeste(41, livro: idTeste(2), cor: '#ABCF82'));
      final g = grifoTeste(42, livro: idTeste(2));
      await dao.upsert(g);
      await dao.upsert(notaTeste(43, livro: idTeste(2), pai: g, texto: 'n'));
      await dao.upsert(grifoTeste(44, livro: idTeste(2), apagado: true));
      expect(await dao.highlightsOfUser(usuarioTeste), hasLength(3));
    });

    test(
      'busca FTS5: sem acento, sem caixa, por prefixo, no grifo e na nota',
      () async {
        final dao = AnnotationsDao(db);
        final livro = idTeste(1);
        final capitu = grifoTeste(
          50,
          livro: livro,
          exato: 'aqueles olhos de Capitu',
        );
        final opera = grifoTeste(
          51,
          livro: livro,
          pagina: 41,
          exato: '— A vida é uma ópera e uma grande ópera.',
        );
        final nota = notaTeste(
          52,
          livro: livro,
          pai: opera,
          texto: 'Levar para o encontro de quinta.',
        );
        for (final a in [capitu, opera, nota]) {
          await dao.upsert(a);
        }
        expect(await dao.search(livro, 'CAPÍTU'), [capitu]);
        expect(await dao.search(livro, 'opera'), [opera, nota]);
        expect(await dao.search(livro, 'encon quin'), [nota]);
        expect(await dao.search(livro, 'vida "ópera'), [opera, nota]);
        expect(await dao.search(livro, '   '), hasLength(3));
        expect(await dao.search(idTeste(2), 'capitu'), isEmpty);
        // apagar (tombstone) tira do índice
        await dao.upsert(
          capitu.copyWith(meta: metaTeste(apagado: true, contador: 1)),
        );
        expect(await dao.search(livro, 'capitu'), isEmpty);
      },
    );

    test('camada de tinta: booleano e espaço; rótulos; caneta', () async {
      final camada = camadaTeste(60, livro: idTeste(1));
      await InkLayersDao(db).upsert(camada);
      expect(await InkLayersDao(db).forBook(idTeste(1)), [camada]);
      expect((await linha('ink_layers', camada.id))['collapsed'], 1);

      final rotulos = [
        for (final (i, (cor, nome)) in const [
          ('#FED170', 'lindo'),
          ('#FFC1C6', 'personagem'),
          ('#ABCF82', 'ideia'),
          ('#B6ACE4', 'pro clube'),
        ].indexed)
          HighlightLabel(
            id: idTeste(70 + i),
            meta: metaTeste(),
            color: cor,
            label: nome,
            sort: i,
          ),
      ];
      for (final r in rotulos.reversed) {
        await HighlightLabelsDao(db).upsert(r);
      }
      expect(await HighlightLabelsDao(db).forUser(usuarioTeste), rotulos);

      final caneta = PenPresets(
        id: usuarioTeste,
        meta: metaTeste(),
        penWidthMm: 0.3,
      );
      await PenPresetsDao(db).upsert(caneta);
      expect(await PenPresetsDao(db).forUser(usuarioTeste), caneta);
      final raw = await linha('pen_presets', usuarioTeste);
      expect(raw['pen_width_mm'], '0.3');
      expect(
        raw['favorite_colors'],
        '["#FF552E","#552CB7","#058CD7","#00995E","#F2A815","#1A1714"]',
      );
    });

    test('âncora em formato desconhecido (PDF) sobrevive à gravação', () async {
      final pdf = RawAnchor(const {
        'page': 12,
        'quads': [
          [0.1, 0.2, 0.3, 0.4],
        ],
      });
      final g = grifoTeste(80, livro: idTeste(1)).copyWith(anchor: pdf);
      await AnnotationsDao(db).upsert(g);
      expect((await AnnotationsDao(db).forBook(idTeste(1))).single.anchor, pdf);
    });
  });

  group('G16: leituras da tinta', () {
    test(
      'camadas por id (vivas ou não) e as sobre o texto vivas do livro',
      () async {
        final dao = InkLayersDao(db);
        final viva = camadaSobreTextoTeste(90, livro: idTeste(1));
        final apagada = camadaSobreTextoTeste(
          91,
          livro: idTeste(1),
          apagada: true,
        );
        final espaco = camadaTeste(92, livro: idTeste(1));
        final outroLivro = camadaSobreTextoTeste(93, livro: idTeste(2));
        for (final l in [viva, apagada, espaco, outroLivro]) {
          await dao.upsert(l);
        }
        expect(
          await dao.byIds([viva.id, apagada.id, idTeste(99)]),
          unorderedEquals([viva, apagada]),
        );
        expect(await dao.byIds(const []), isEmpty);
        expect(await dao.liveOverTextForBook(idTeste(1)), [viva]);
      },
    );

    test(
      'anotações por id (vivas ou não) e os desenhos vivos das camadas',
      () async {
        final dao = AnnotationsDao(db);
        final c1 = camadaSobreTextoTeste(90, livro: idTeste(1));
        final c2 = camadaSobreTextoTeste(91, livro: idTeste(1));
        final d1 = desenhoTeste(94, livro: idTeste(1), camada: c1);
        final d2 = desenhoTeste(
          95,
          livro: idTeste(1),
          camada: c2,
          apagado: true,
        );
        final grifo = grifoTeste(96, livro: idTeste(1));
        for (final a in [d1, d2, grifo]) {
          await dao.upsert(a);
        }
        expect(
          await dao.byIds([d1.id, d2.id, grifo.id, idTeste(99)]),
          unorderedEquals([d1, d2, grifo]),
        );
        expect(await dao.byIds(const []), isEmpty);
        expect(await dao.drawingsOfLayers([c1.id, c2.id]), [d1]);
        expect(await dao.drawingsOfLayers(const []), isEmpty);
      },
    );

    test('kv: apagar uma chave (e a que não existe não faz nada)', () async {
      final kv = KvDao(db);
      await kv.set('ink_draft:dona:livro', '{"v":1}');
      await kv.delete('ink_draft:dona:livro');
      expect(await kv.get('ink_draft:dona:livro'), isNull);
      await kv.delete('ink_draft:dona:livro');
      expect(await kv.get('sync'), 'gratis');
    });
  });

  group('kv e versões', () {
    test('kv: get/set/watch', () async {
      final kv = KvDao(db);
      expect(await kv.get('sync'), 'gratis');
      expect(await kv.get('brand'), isNull);
      await kv.set('brand', '#B6ACE4');
      await kv.set('brand', '#FFC1C6');
      expect(await kv.get('brand'), '#FFC1C6');
      expect(await kv.watch('brand').first, '#FFC1C6');
    });

    test('nova versão > versão atual da linha, mesmo com o relógio 10 min atrasado', () async {
      await UserBooksDao(db)
          .upsert(livroTeste(1)); // versão de outro aparelho, mais adiantado
      final remota = Hlc(
        t0Teste.millisecondsSinceEpoch + 600000,
        4,
        'aparelhoB',
      );
      await db.customStatement(
        "UPDATE user_books SET version_hlc = '$remota' WHERE id = '${idTeste(1)}'",
      );
      final versoes = await LocalVersioning.open(
        db,
        deviceId: 'aparelhoA',
        nowMs: () => t0Teste.millisecondsSinceEpoch,
      );
      final v = await versoes.next('user_books', idTeste(1));
      expect(v > remota, isTrue);
      // G06 (revisão): versão lida mais de 5 min à frente não puxa o relógio do aparelho — só a
      // versão DAQUELA linha fica acima dela (senão um período com o relógio errado levaria todas as
      // escritas seguintes para o futuro e a RPC recusaria tudo)
      final relogio = Hlc.parse(
        (await KvDao(db).get(LocalVersioning.lastHlcKey))!,
      );
      expect(relogio.ms, t0Teste.millisecondsSinceEpoch);
      // linha nova: só o relógio
      final n = await versoes.next('user_books', idTeste(2));
      expect(n > relogio, isTrue);
      expect(n.ms, t0Teste.millisecondsSinceEpoch);
      // reabrir retoma do último HLC salvo, mesmo com o relógio 2 min atrás dele
      final reaberto = await LocalVersioning.open(
        db,
        deviceId: 'aparelhoA',
        nowMs: () => n.ms - 120000,
      );
      expect(await reaberto.next('annotations', idTeste(3)) > n, isTrue);
      expect(() => versoes.next('kv', 'sync'), throwsArgumentError);
    });

    test('HLC salvo > 5 min à frente do relógio (relógio adiantado, depois acertado) é ignorado; '
        'a ordem por linha continua pelo receive da versão gravada', () async {
      final agora = t0Teste.millisecondsSinceEpoch;
      final futuro = Hlc(agora + 86400000, 0, 'aparelhoA'); // 1 dia à frente
      await KvDao(db).set(LocalVersioning.lastHlcKey, futuro.toString());
      final versoes = await LocalVersioning.open(
        db,
        deviceId: 'aparelhoA',
        nowMs: () => agora,
      );
      final nova = await versoes.next('user_books', idTeste(7)); // linha nova
      expect(nova.ms, agora); // a RPC aceita (≤ agora + 5 min)
      // linha gravada no período adiantado: continua monotônica
      await UserBooksDao(db).upsert(livroTeste(8).copyWith(meta: metaTeste()));
      await db.customStatement(
        "UPDATE user_books SET version_hlc = '$futuro' WHERE id = '${idTeste(8)}'",
      );
      expect(await versoes.next('user_books', idTeste(8)) > futuro, isTrue);
      // dentro de 5 min, o salvo é respeitado
      final perto = Hlc(agora + 240000, 0, 'aparelhoA');
      await KvDao(db).set(LocalVersioning.lastHlcKey, perto.toString());
      final reaberto = await LocalVersioning.open(
        db,
        deviceId: 'aparelhoA',
        nowMs: () => agora,
      );
      expect(await reaberto.next('user_books', idTeste(9)) > perto, isTrue);
    });

    test('write: ler, versionar e gravar numa transação; a versão gravada só sobe', () async {
      final versoes = await LocalVersioning.open(
        db,
        deviceId: 'aparelhoA',
        nowMs: () => t0Teste.millisecondsSinceEpoch,
      );
      final livro = livroTeste(1);
      await versoes.write('user_books', livro.id, (v) async {
        await UserBooksDao(db)
            .upsert(livro.copyWith(meta: livro.meta.copyWith(version: v)));
      });
      final gravada = (await UserBooksDao(db).byId(livro.id))!.meta.version;
      final outra = await versoes.write('user_books', livro.id, (v) async {
        await UserBooksDao(db).upsert(
          livro.copyWith(
            title: 'Dom Casmurro (2)',
            meta: livro.meta.edited(t0Teste, v),
          ),
        );
        return v;
      });
      expect(outra > gravada, isTrue);
      // o gatilho recusa qualquer escrita local com versão menor que a gravada
      await expectLater(
        UserBooksDao(db).upsert(livro.copyWith(title: 'velho')),
        throwsA(
          isA<SqliteException>().having(
            (e) => e.message,
            'mensagem',
            contains('version_hlc_regressed'),
          ),
        ),
      );
      expect(
        (await UserBooksDao(db).byId(livro.id))!.title,
        'Dom Casmurro (2)',
      );
    });
  });

  group('únicos do servidor (índices parciais) checados no aparelho', () {
    test('2º livro ativo com o mesmo arquivo é recusado; depois de apagar o 1º, pode', () async {
      final dao = UserBooksDao(db);
      final livroComOMesmoArquivo = livroTeste(2)
          .copyWith(contentSha256: Nullable(livroTeste(1).contentSha256));
      await dao.upsert(livroTeste(1));
      await expectLater(
        dao.upsert(livroComOMesmoArquivo), // mesmo sha256 do livro 1
        throwsA(
          isA<DuplicateActiveRow>()
              .having((e) => e.column, 'coluna', 'content_sha256')
              .having((e) => e.existingId, 'id', idTeste(1)),
        ),
      );
      await dao.upsert(
        livroTeste(1).copyWith(meta: metaTeste(apagado: true, contador: 1)),
      );
      await dao.upsert(livroComOMesmoArquivo);
      expect((await dao.shelf(usuarioTeste)).map((b) => b.id), [idTeste(2)]);
      expect(
        const DuplicateActiveRow(
          table: 't',
          column: 'c',
          existingId: 'x',
        ).toString(),
        contains('t.c'),
      );
    });

    test('2º rótulo ativo com a mesma cor é recusado', () async {
      final dao = HighlightLabelsDao(db);
      HighlightLabel rotulo(int n, String nome) => HighlightLabel(
        id: idTeste(n),
        meta: metaTeste(),
        color: '#FED170',
        label: nome,
      );
      await dao.upsert(rotulo(1, 'lindo'));
      await dao.upsert(rotulo(1, 'lindíssimo')); // a mesma linha pode mudar
      await expectLater(
        dao.upsert(rotulo(2, 'outro')),
        throwsA(isA<DuplicateActiveRow>()),
      );
    });
  });
}

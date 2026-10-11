// G03.5 — a fixture do mundo de referência (D-34) é coerente consigo mesma, com o banco local e com
// cada prancha; asserções de consistência entre telas do Anexo 01 §14.
import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/daos/annotation_daos.dart';
import 'package:app_leitura/core/data/database/daos/library_daos.dart';
import 'package:app_leitura/core/data/database/daos/reader_daos.dart';
import 'package:app_leitura/core/data/ids/uuid_v7.dart';
import 'package:app_leitura/features/reader/annotations/domain/annotation.dart';
import 'package:app_leitura/features/reader/annotations/domain/annotation_stats.dart';
import 'package:app_leitura/features/reader/annotations/domain/ink_layer.dart';
import 'package:app_leitura/features/reader/annotations/ink/bnk1_codec.dart';
import 'package:app_leitura/features/reader/annotations/ink/drawing_anchor.dart';
import 'package:app_leitura/features/reader/annotations/ink/ink_stroke.dart';
import 'package:app_leitura/features/reader/annotations/ink/ink_units.dart';
import 'package:app_leitura/features/reader/annotations/space/note_ink.dart';
import 'package:app_leitura/features/reader/annotations/space/space_metrics.dart';
import 'package:app_leitura/features/reader/domain/locator.dart';
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'home_mock_repository.dart';
import 'mundo_2026_09_20.dart';
import 'sumario_dom_casmurro.dart';
import 'telas/inicio01.dart';
import 'telas/instantaneo.dart';
import 'telas/t19.dart';
import 'telas/t20.dart';
import 'telas/t21.dart';
import 'telas/t22.dart';
import 'telas/t23.dart';
import 'telas/t23b.dart';
import 'telas/t24.dart';
import 'telas/t24b.dart';
import 'telas/t25.dart';
import 'telas/t26.dart';
import 'telas/t26b.dart';
import 'telas/t27.dart';
import 'telas/t27b.dart';
import 'tinta_do_mundo.dart';

void main() {
  final m = mundoReferencia;
  final dc = m.domCasmurro;
  final todas = [
    t19,
    t20,
    t21,
    t22,
    t23,
    t23b,
    t24,
    t24b,
    t25,
    t26,
    t26b,
    t27,
    t27b,
  ];

  group('mundo base', () {
    test('agora = domingo 20/09/2026 20:00 em São Paulo (D-09)', () {
      expect(m.agora, DateTime.utc(2026, 9, 20, 23));
      expect(m.agoraLocal.hour, 20);
      expect(m.agoraLocal.weekday, DateTime.sunday);
    });

    test('ids são UUIDv7 únicos (gerados como no aparelho)', () {
      final ids = [
        ...m.livros.map((e) => e.id),
        ...m.sessoes.map((e) => e.id),
        ...m.marcadores.map((e) => e.id),
        ...m.anotacoes.map((e) => e.id),
        ...m.camadas.map((e) => e.id),
        ...m.rotulos.map((e) => e.id),
        m.clube.id,
        m.clube.postCompartilhadoId,
      ];
      expect(ids.toSet(), hasLength(ids.length));
      for (final id in ids) {
        expect(UuidV7.isValid(id), isTrue, reason: id);
      }
    });

    test(
      'grava num banco local (todos os CHECKs do SQL) e volta igual',
      () async {
        final db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false);
        addTearDown(db.close);
        await m.gravarEm(db);
        expect(await UserBooksDao(db).shelf(m.usuarioId), hasLength(6));
        expect(await AnnotationsDao(db).forBook(dc.id), hasLength(12));
        expect(
          (await AnnotationsDao(db).forBook(dc.id)).toSet(),
          m.anotacoesDo(Slugs.domCasmurro).toSet(),
        );
        expect(
          await BookmarksDao(db).forBook(dc.id),
          m.marcadoresDo(Slugs.domCasmurro),
        );
        expect(
          await ReadingPositionsDao(db).forBook(dc.id),
          m.posicao(Slugs.domCasmurro),
        );
        expect(await AnnotationsDao(db).search(dc.id, 'ressaca'), hasLength(1));
        // "Capitu era Capitu…" (grifo + a nota dele) e "olhos de Capitu"
        expect(await AnnotationsDao(db).search(dc.id, 'capitu'), hasLength(3));
      },
    );

    test(
      'Dom Casmurro: 148 capítulos, 256 páginas, pág. 159 = 62 %, cap. XXXII',
      () {
        expect(sumarioDomCasmurro, hasLength(148));
        expect(dc.chaptersTotal, 148);
        expect(dc.refPagesTotal, 256);
        final p = m.posicao(Slugs.domCasmurro);
        expect(p.refPage, 159);
        expect((p.progression * 100).round(), 62);
        expect((159 / 256 * 100).round(), 62);
        expect(sumarioDomCasmurro[p.chapterIndex].numeral, 'XXXII');
        expect(sumarioDomCasmurro[p.chapterIndex].titulo, 'Olhos de ressaca');
      },
    );

    test('sumário: páginas crescentes; XXV–XXXVII como na tela 27; XXXII = págs. 157–162', () {
      for (var i = 1; i < 148; i++) {
        expect(
          sumarioDomCasmurro[i].pagina,
          greaterThanOrEqualTo(sumarioDomCasmurro[i - 1].pagina),
        );
      }
      expect(
        [
          for (final c in sumarioDomCasmurro.sublist(24, 37))
            '${c.numeral} ${c.titulo} ${c.pagina}',
        ],
        [
          'XXV No Passeio Público 121',
          'XXVI As leis são belas 126',
          'XXVII Ao portão 131',
          'XXVIII Na rua 136',
          'XXIX O imperador 141',
          'XXX O Santíssimo 146',
          'XXXI As curiosidades de Capitu 152',
          'XXXII Olhos de ressaca 157',
          'XXXIII O penteado 163',
          'XXXIV Sou homem! 166',
          'XXXV O protonotário apostólico 170',
          'XXXVI Ideia sem pernas 175',
          'XXXVII A alma é cheia de mistérios 179',
        ],
      );
      for (final p in [157, 159, 162]) {
        expect(Mundo.capituloDaPagina(p), 31, reason: 'pág. $p');
      }
      expect(Mundo.capituloDaPagina(163), 32);
    });

    test('âncoras: o trecho citado está no texto de fixture, na posição, no capítulo da página', () {
      for (final a in m.anotacoes) {
        final ancora = a.anchor as EpubAnchor;
        final slug = m.slugs.entries
            .firstWhere((e) => e.value == a.userBookId)
            .key;
        final texto = m.textosDosCapitulos[slug]![ancora.spine - 1]!;
        expect(
          texto.substring(ancora.start, ancora.end),
          ancora.quote.exact,
          reason: a.id,
        );
        expect(ancora.refPage, a.refPage);
        if (slug == Slugs.domCasmurro) {
          expect(
            Mundo.capituloDaPagina(a.refPage),
            a.chapterIndex,
            reason: '${a.refPage}',
          );
          expect(ancora.spine, a.chapterIndex + 1);
        }
      }
      for (final c in m.camadas) {
        // G16: os desenhos com a âncora de 8 chaves (o intervalo e a largura em em)
        final ancora = inkAnchorOf(c.anchor)!.range;
        final texto =
            m.textosDosCapitulos[Slugs.domCasmurro]![ancora.spine - 1]!;
        expect(texto.substring(ancora.start, ancora.end), ancora.quote.exact);
      }
    });
  });

  group('Anexo 01 §14 — consistência entre telas', () {
    test('tela 25: Tudo 12 = Grifos 6 + Notas 2 + À mão 1 + Desenhos 3 = contador da tela 20', () {
      final c = t25.contagens;
      expect(
        [c.all, c.highlights, c.notes, c.handwriting, c.drawings],
        [12, 6, 2, 1, 3],
      );
      expect(t20.contagens.all, 12);
    });

    test('tela 25: páginas 3/6/41/121/152/159 na ordem do livro e coerentes com o sumário', () {
      final paginas = {
        for (final a in m.anotacoesDo(Slugs.domCasmurro)) a.refPage,
      }.toList()..sort();
      expect(paginas, [3, 6, 41, 121, 152, 159]);
      expect(
        [
          for (final p in paginas)
            sumarioDomCasmurro[Mundo.capituloDaPagina(p)].numeral,
        ],
        ['I', 'II', 'IX', 'XXV', 'XXXI', 'XXXII'],
      );
    });

    test(
      'tela 25: 8 cartões; trechos literais batem com as anotações (D-49)',
      () {
        expect(m.cartoesDaTela25, hasLength(8));
        final porGrupo = <String, List<Annotation>>{};
        for (final a in m.anotacoesDo(Slugs.domCasmurro)) {
          (porGrupo[a.groupId] ??= []).add(a);
        }
        expect(porGrupo.keys.toSet(), {
          for (final c in m.cartoesDaTela25) c.grupoId,
        });
        for (final cartao in m.cartoesDaTela25) {
          for (final t in cartao.trechos) {
            if (t.anotacaoId == null) continue;
            final a = m.anotacao(t.anotacaoId!);
            expect(a.groupId, cartao.grupoId);
            expect((a.anchor as EpubAnchor).quote.exact, t.texto);
          }
        }
        // cabeçalhos: GRIFO · GRIFO+NOTA · GRIFO · GRIFO · GRIFO+NOTA(+clube) · GRIFO · DESENHO+À MÃO · 2 DESENHOS
        expect(
          [
            for (final c in m.cartoesDaTela25)
              [for (final a in porGrupo[c.grupoId]!) a.kind.code].join('+'),
          ],
          [
            'highlight',
            'highlight+note',
            'highlight',
            'highlight',
            'highlight+note',
            'highlight',
            'drawing+handwriting',
            'drawing+drawing',
          ],
        );
        final compartilhados = m.anotacoes.where(
          (a) => a.sharedClubPostId != null,
        );
        expect(
          compartilhados.single.refPage,
          152,
        ); // "Só do clube" / "Leitoras de Capitu · 3 respostas"
        expect(m.clube.respostasDoPost, 3);
      },
    );

    test('tela 27: marcas XXV = 1, XXXI = 2, XXXII = 5, com os símbolos do arquivo', () {
      expect(t27.marcasDoCapitulo(24).count, 1);
      expect(t27.marcasDoCapitulo(24).symbols, [
        const MarkSymbol(AnnotationKind.highlight, CoresDoMundo.amarelo),
      ]);
      expect(t27.marcasDoCapitulo(30).count, 2);
      expect(t27.marcasDoCapitulo(30).symbols, [
        const MarkSymbol(AnnotationKind.highlight, CoresDoMundo.lavanda),
        const MarkSymbol(AnnotationKind.note, null),
      ]);
      expect(t27.marcasDoCapitulo(31).count, 5);
      expect(t27.marcasDoCapitulo(31).symbols, [
        const MarkSymbol(AnnotationKind.highlight, CoresDoMundo.amarelo),
        const MarkSymbol(AnnotationKind.drawing, CoresDoMundo.coral),
        const MarkSymbol(AnnotationKind.handwriting, null),
      ]);
      for (final i in [25, 26, 27, 28, 29, 32, 33, 34, 35, 36]) {
        expect(
          t27.marcasDoCapitulo(i).count,
          0,
          reason: sumarioDomCasmurro[i].numeral,
        );
      }
    });

    test(
      'clube: "Até o cap. L · faltam 18" (27), encontro quinta 24/09 20:00',
      () {
        expect(t27.faltamParaOClube, 18);
        expect(m.clube.metaCapitulo - t27.capituloAtual, 18);
        final encontro = m.clube.proximoEncontro.add(m.fuso);
        expect(
          [encontro.weekday, encontro.day, encontro.month, encontro.hour],
          [DateTime.thursday, 24, 9, 20],
        );
      },
    );

    test('marcadas: 3 (págs. 3, 6, 159); a fita da tela 20 está pressionada (pág. 159)', () {
      expect(t27b.marcadas.map((b) => b.refPage), [3, 6, 159]);
      expect(
        t27b.marcadas.map((b) => sumarioDomCasmurro[b.chapterIndex].numeral),
        ['I', 'II', 'XXXII'],
      );
      expect(t27b.marcadas.map((b) => b.excerpt), [
        'Uma noite destas, vindo da cidade para o Engenho Novo, encontrei no trem da Central…',
        'Agora que expliquei o título, passo a escrever o livro…',
        'Retórica dos namorados, dá-me uma comparação exata e poética…',
      ]);
      expect(t20.paginaMarcada, isTrue);
    });

    test('rótulos do marca-texto (23b): lindo 5 · personagem 3 · ideia 2 · pro clube 2 (D-40)', () {
      final porCor = t23b.grifosPorCor;
      expect(
        [for (final r in m.rotulos) '${r.label} ${porCor[r.color]}'],
        ['lindo 5', 'personagem 3', 'ideia 2', 'pro clube 2'],
      );
      // em Dom Casmurro, 6 grifos: 3 amarelos, 1 rosa, 1 verde, 1 lavanda (tela 25)
      expect(
        AnnotationStats.highlightsByColor(m.anotacoesDo(Slugs.domCasmurro)),
        {
          CoresDoMundo.amarelo: 3,
          CoresDoMundo.rosa: 1,
          CoresDoMundo.verde: 1,
          CoresDoMundo.lavanda: 1,
        },
      );
    });

    test('Início ↔ Leitor: o que bate', () {
      final s = const HomeMockRepository().snapshot(
        HomeMockRepository.referenceNow,
      );
      expect(s.continueReading!.book.title, dc.title);
      expect(s.continueReading!.book.author, dc.authorDisplay);
      // a 01 mostra a página (D-254): "pág. 159 de 256" = a da tela 20
      expect(
        (s.continueReading!.refPage, s.continueReading!.refPagesTotal),
        (t20.pagina, t20.totalDePaginas),
      ); // (159, 256)
      expect(s.continueReading!.highlightsCount, t20.contagens.all); // 12
      expect(
        (s.continueReading!.progress * 100).round(),
        t20.porcentagem,
      ); // 62 %
      expect(
        s.continueReading!.timeLeft,
        t20.tempoRestante,
      ); // "~2h 10min" ↔ "≈ 2 h 10 min"
      expect(s.readingDay.readMinutes, t20.minutosHoje); // "18 min hoje"
      expect(t20.minutosHoje, 18);
      expect(s.club!.nameHighlight, 'Capitu');
      expect(s.club!.nextMeeting, DateTime(2026, 9, 24, 20));
      expect(s.club!.book.title, dc.title);
      expect(s.club!.untilChapter, m.clube.metaCapitulo); // até o cap. 50
    });

    test('Início ↔ Leitor: das 4 divergências da Q25 sobra "grifos hoje" (T03: a 01 trocou o capítulo pela página e '
        'usa a meta do clube e as anotações do leitor) — nenhuma outra', () {
      final s = const HomeMockRepository().snapshot(
        HomeMockRepository.referenceNow,
      );
      final hoje = [
        for (final a in m.anotacoesDo(Slugs.domCasmurro))
          if (a.meta.createdAt.add(m.fuso).day == 20 &&
              a.kind == AnnotationKind.highlight)
            a,
      ];
      final divergencias = {
        if (s.continueReading!.refPage != t20.pagina)
          'página': (s.continueReading!.refPage, t20.pagina),
        if (s.club!.untilChapter != m.clube.metaCapitulo)
          'meta do clube': (s.club!.untilChapter, m.clube.metaCapitulo),
        if (s.continueReading!.highlightsCount != t20.contagens.all)
          'destaques do livro': (
            s.continueReading!.highlightsCount,
            t20.contagens.all,
          ),
        if (s.readingDay.highlightsToday != hoje.length)
          'grifos hoje': (s.readingDay.highlightsToday, hoje.length),
      };
      expect(divergencias, {'grifos hoje': (2, 1)});
    });
  });

  group('instantâneos por prancha (D-34)', () {
    test('um por prancha medida, todos no mesmo livro e na pág. 159', () {
      expect(todas.map((t) => t.prancha), [
        '19_leitor_limpo',
        '20_leitor_controles',
        '21_selecao_texto',
        '22_modo_anotacao',
        '23_ajustes_caneta',
        '23b_ajustes_marcatexto',
        '24_abrindo_espaco',
        '24b_nota_mao',
        '25_grifos_notas',
        '26_ajustes_leitura',
        '26b_tema_noite',
        '27_sumario',
        '27b_sumario_marcadas',
      ]);
      for (final t in todas) {
        expect(t.pagina, 159, reason: t.prancha);
        expect(t.totalDePaginas, 256, reason: t.prancha);
        expect(t.porcentagem, 62, reason: t.prancha);
        expect(t.capitulo.numeral, 'XXXII', reason: t.prancha);
        expect(t.brand, '#B6ACE4', reason: t.prancha);
      }
    });

    test('19/20/26/26b/27/27b: a pág. 159 sem nenhuma anotação desenhada', () {
      for (final t in [t19, t20, t26, t26b, t27, t27b]) {
        expect(t.anotacoesNaPagina, isEmpty, reason: t.prancha);
        expect(t.tintaNaPagina, isEmpty, reason: t.prancha);
      }
    });

    test('D-169: 19/20/26/26b/27/27b — a tinta de hoje fica no banco sem lugar (conta 12, não pinta, não abre espaço)', () {
      for (final t in [t19, t20, t26, t26b, t27, t27b]) {
        expect(t.contagens.all, 12, reason: t.prancha);
        // os 3 desenhos, o grifo à mão e (G18) a nota à mão
        final deHoje = [
          for (final a in t.mundo.anotacoesDo(Slugs.domCasmurro))
            if (a.refPage == 159 && a.source == AnnotationSource.ink) a,
        ];
        expect(deHoje, hasLength(5), reason: t.prancha);
        expect(
          deHoje.where((a) => a.kind == AnnotationKind.handwriting),
          hasLength(1),
        );
        for (final a in deHoje) {
          final ancora = a.anchor as EpubAnchor;
          expect(ancora.sha, shaDeAntesDeHoje, reason: t.prancha);
          expect(ancora.quote.exact, citacaoDeAntesDeHoje);
          expect(t.textoDoCapitulo.contains(citacaoDeAntesDeHoje), isFalse);
          final id = a.inkLayerId;
          if (id == null) continue;
          final camada = t.mundo.camadas.singleWhere((c) => c.id == id);
          expect(
            inkAnchorOf(camada.anchor)!.range.quote.exact,
            citacaoDeAntesDeHoje,
            reason: t.prancha,
          );
        }
      }
      // o mundo base continua com a tinta no lugar
      expect(
        (m.anotacao(t22.anotacoesNaPagina.first.id).anchor as EpubAnchor)
            .quote
            .exact,
        'olhos de Capitu',
      );
    });

    test('21: grifo de seleção em "aqueles olhos de Capitu", nenhuma tinta, trecho selecionado', () {
      expect(t21.anotacoesNaPagina, hasLength(1));
      final g = t21.anotacoesNaPagina.single;
      expect(g.source, AnnotationSource.selection);
      expect(g.style, HighlightStyle.fill);
      expect(g.color, CoresDoMundo.amarelo);
      expect((g.anchor as EpubAnchor).quote.exact, 'aqueles olhos de Capitu');
      expect(t21.mundo.camadas, isEmpty);
      final sel = t21.selecao!;
      expect(
        sel.texto,
        'como a vaga que se retira da praia, nos dias de ressaca.',
      );
      expect(t21.textoDoCapitulo.substring(sel.inicio, sel.fim), sel.texto);
    });

    test('22: o começo da sessão da prancha — o grifo à mão e a elipse (1 camada); o duplo e a onda vêm do fluxo', () {
      expect(
        [
          for (final a in t22.anotacoesNaPagina)
            (a.anchor as EpubAnchor).quote.exact,
        ],
        ['olhos de Capitu', 'Olhos de ressaca?'],
      );
      expect(t22.tintaNaPagina, hasLength(1));
      expect(t22.modo, ModoDoLeitor.anotacao);
    });

    test('23/23b/24: grifo à mão livre + elipse + ondulado + duplo; sem a nota à mão ainda', () {
      for (final t in [t23, t23b, t24]) {
        expect(
          [
            for (final a in t.anotacoesNaPagina)
              (a.anchor as EpubAnchor).quote.exact,
          ],
          [
            'olhos de Capitu',
            'Olhos de ressaca?',
            'fluido misterioso',
            'a vaga que se retira',
          ],
          reason: t.prancha,
        );
        expect(t.tintaNaPagina, hasLength(3), reason: t.prancha);
        expect(t.modo, ModoDoLeitor.anotacao);
      }
      expect(
        [t22.ferramenta, t23.ferramenta, t23b.ferramenta, t24.ferramenta],
        [
          FerramentaDeAnotacao.caneta,
          FerramentaDeAnotacao.caneta,
          FerramentaDeAnotacao.marcaTexto,
          FerramentaDeAnotacao.espaco,
        ],
      );
      expect(
        [t23.painel, t23b.painel],
        [PainelDaFerramenta.caneta, PainelDaFerramenta.marcaTexto],
      );
      expect(t24.abrindoEspacoLinhas, 3);
    });

    test(
      '24b: + nota à mão num espaço de 3 linhas depois de "Vá, de ressaca."',
      () {
        final nota = t24b.anotacoesNaPagina.singleWhere(
          (a) => a.kind == AnnotationKind.handwriting,
        );
        final espaco = t24b.tintaNaPagina.singleWhere(
          (c) => c.id == nota.inkLayerId,
        );
        expect(espaco.spaceLines, 3);
        expect(espaco.collapsed, isFalse);
        expect(
          (espaco.anchor as EpubAnchor).quote.prefix,
          endsWith('Vá, de ressaca.'),
        );
        // D-187: a prancha já está na Caneta
        expect(t24b.ferramenta, FerramentaDeAnotacao.caneta);
      },
    );

    test('24b (R15): a tinta da nota é a do arquivo, coral 2,2, na unidade da caixa (±0,5 px)', () {
      final espaco = t24b.tintaNaPagina.singleWhere(
        (c) => c.kind == InkLayerKind.space,
      );
      final tracos = decodeStrokesB64(espaco.strokesB64, Bnk1Unit.box);
      expect(espaco.strokeCount, tracos.length);
      final (:caminhos, :centro, :raio) = caminhosDaNotaAMao();
      final subcaminhos = [for (final d in caminhos) ...tracosDoCaminho(d)];
      // um traço por subcaminho e um para a íris (T01, R5)
      expect(tracos, hasLength(subcaminhos.length + 1));
      for (final s in tracos) {
        expect(
          (s.tool, s.argb, s.widthCentiMm),
          (InkTool.pen.code, tintaCoral, centiMmOfDp(2.2)),
        );
      }
      // cada ponto do 1º traço ("r" de "ressaca") perto do caminho do arquivo levado à caixa
      final numeros = RegExp(r'-?\d+\.?\d*')
          .allMatches(subcaminhos.first)
          .map((m) => double.parse(m.group(0)!))
          .toList();
      final linha = [
        for (var i = 0; i + 1 < numeros.length; i += 2)
          naCaixaDaNota(Offset(numeros[i], numeros[i + 1])),
      ];
      for (final p in tracos.first.points) {
        final px = Offset(p.x * larguraDaTintaDaNota, p.y * noteLinePx);
        expect(distanciaALinha(px, linha), lessThan(0.5));
      }
      // a íris cheia (T01, R5): a espiral do centro e a volta no raio de dentro; com a meia largura de 1,1, cobre o
      // círculo de 7,5 sem falha e não passa dele
      final c = naCaixaDaNota(centro);
      final iris = [
        for (final p in tracos.last.points)
          Offset(p.x * larguraDaTintaDaNota, p.y * noteLinePx),
      ];
      final r = raio * escalaDaNotaAMao;
      expect((iris.first - c).distance, lessThan(0.05), reason: 'do centro');
      expect((iris.last - c).distance, closeTo(r - 1.1, 0.05));
      for (final p in iris) {
        expect((p - c).distance, lessThanOrEqualTo(r - 1.1 + 0.05));
      }
      for (var dx = -r + 1; dx <= r - 1; dx += 0.5) {
        for (var dy = -r + 1; dy <= r - 1; dy += 0.5) {
          final p = c + Offset(dx, dy);
          if ((p - c).distance > r - 1) continue;
          expect(
            distanciaALinha(p, iris),
            lessThanOrEqualTo(1.1),
            reason: '$p',
          );
        }
      }
      // a menor caixa que contém a tinta tem 3 linhas: a 2ª onda desce até 106,3 px, passando da 2ª pauta (106) — a
      // alça não sobe dali (D-186)
      expect(inkBottomPx(tracos), closeTo(106.3, 0.1));
      expect(minLinesFor(tracos), 3);
    });

    test('23: caneta esferográfica · 1,2 mm · coral (padrões); 26/26b: Creme e Noite', () {
      expect(t23.mundo.caneta.penWidthMm, 1.2);
      expect(t23.mundo.caneta.penColor, CoresDoMundo.coral);
      expect(t26.mundo.ajustes.paper, ReaderPaper.creme);
      expect(t26.mundo.ajustes.fontStep, 4);
      expect(t26b.mundo.ajustes.paper, ReaderPaper.noite);
    });
  });

  test('a Início é montada da fixture sem mudar nenhum valor (as mesmas instâncias a cada chamada)', () {
    final a = const HomeMockRepository().snapshot(
      HomeMockRepository.referenceNow,
    );
    final b = const HomeMockRepository().snapshot(
      HomeMockRepository.referenceNow,
    );
    expect(identical(a.continueReading, b.continueReading), isTrue);
    expect(a.continueReading!.book, same(HomeMockRepository.domCasmurro));
    expect(a.readingDay.week.map((d) => d.minutes), [
      32,
      45,
      30,
      22,
      38,
      55,
      18,
    ]);
    expect(a.readingDay.streakDays, 12);
    expect(a.readingDay.sessionsToday, 2);
    expect(a.readingDay.goalMinutes, 30);
    expect(a.readingDay.badgeTargetDays, 14);
    expect(a.dailyReview, same(TelaInicio01.revisao));
    expect(a.alsoReading.map((e) => e.book.title), [
      'Memórias Póstumas de Brás Cubas',
      'Orgulho e Preconceito',
      'Mrs. Dalloway',
    ]);
    expect(TelaInicio01.agora, DateTime(2026, 9, 20, 20));
  });
}

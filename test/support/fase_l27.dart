// G15.5 — as fases L27 e L27b (telas 27 e 27b, a folha do sumário): a tela pela rota real, no mundo de referência (D-34)
// com o índice injetado da tela 27 (as páginas de início do arquivo, 159 de 256, o cap. XXXII a 18/44), o clube do
// mundo pela fonte de teste (D-149: no app a fonte é vazia até a G21) e o fuso do mundo; com os controles abertos e
// "Sumário" tocado (e a aba Marcadas, na 27b). Contra as medidas do arquivo:
// - geometria de todos os ids das seções da página, do véu e da folha (sem os inline), com as tolerâncias da v1
//   (±0,5; ±1,0 em x/w nos que dependem do texto);
// - texto: as linhas da página (o 1º parágrafo; a 7ª, recortada na prancha) e os textos da folha, com as baselines; as
//   linhas recortadas da lista (XXXIV–XXXVII) ficam atrás do esmaecido de baixo, dentro da caixa da lista;
// - estilo: folha, abas, faixa, linhas, cartão atual com o anel, cartões das Marcadas e a dica;
// - semântica: o diálogo, as abas, a lista, as linhas, o atual e as fitas;
// - dados: os textos saem do instantâneo e das contas (nunca escritos aqui como literal da prancha).
// Desvios:
// - a prancha recorta a página num `article` de 200 de altura; no app a página inteira fica sob o véu — confere-se o
//   lugar da caixa do texto (canto e largura) com a altura da prancha;
// - a lista da prancha só tem as 13 linhas de XXV a XXXVII; no app ela tem os 148 capítulos e abre rolada no atual
//   (D-154) — a caixa `toc.sheet.chapters.list` é conferida no trecho da prancha.
import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/widgets/neo_box.dart';
import 'package:app_leitura/features/reader/application/reader_club_source.dart';
import 'package:app_leitura/features/reader/application/reader_session_controller.dart';
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:app_leitura/features/reader/layout/laid_block.dart';
import 'package:app_leitura/features/reader/layout/page_snapshot.dart';
import 'package:app_leitura/features/reader/layout/paginator.dart';
import 'package:app_leitura/features/reader/presentation/reader_chrome_palette.dart';
import 'package:app_leitura/features/reader/presentation/reader_page_view.dart';
import 'package:app_leitura/features/reader/presentation/toc_chapters.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/mundo_2026_09_20.dart';
import '../fixtures/sumario_dom_casmurro.dart';
import '../fixtures/telas/indice_t27.dart';
import '../fixtures/telas/instantaneo.dart';
import '../reference/leitor/ref_tipos.dart';
import 'canvas.dart';
import 'dados_t20.dart';
import 'fase_l20.dart' show instantaneoBrand;
import 'load_fonts.dart';
import 'pump_reader.dart';
import 'reader_harness.dart';

/// As linhas da lista sob o esmaecido de baixo (a prancha tem do XXXIII ao XXXVII) ficam montadas mas fora do que se
/// vê (a lista sob demanda — R12, G20): o finder as vê também.
Finder _key(String k) => find.byKey(ValueKey<String>(k), skipOffstage: false);

/// O clube do mundo de referência ("Leitoras de Capitu", quinta 24/09, meta cap. L) — no app a fonte é vazia (D-149).
final class ClubeDoMundo implements ReaderClubSource {
  const ClubeDoMundo();

  @override
  Future<ReaderClubGoal?> goalFor(String owner, String userBookId) async {
    final c = mundoReferencia.clube;
    return (
      name: '${c.nomePrefixo} ${c.nomeDestaque}',
      nextMeeting: c.proximoEncontro,
      goalChapter: c.metaCapitulo,
      goalLabel: null,
    );
  }
}

/// O Dom Casmurro da tela 20 com o índice injetado da tela 27.
Future<LivroNaEstante> livroDaTela27() async {
  final livro = await livroDaTela20();
  await livro.usarIndice(indiceDaTela27(livro.index));
  return livro;
}

Future<ReaderDeps> depsDaTela27(
  LeitorNaTela t,
  LivroNaEstante livro, {
  ReaderClubSource clube = const ClubeDoMundo(),
}) async {
  final d = await depsDaTela20(t, livro);
  return livro.readerDeps(
    awake: t.awake,
    onError: (e, _) => t.erros.add(e),
    now: d.now,
    elapsed: d.elapsed,
    speedOf: d.speedOf,
    club: clube,
    utcOffsetAt: (_) => mundoReferencia.fuso,
  );
}

/// Espera o banco (as leituras da folha) e os quadros.
Future<void> _banco(WidgetTester tester) async {
  for (var i = 0; i < 15; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 16));
  }
}

/// Abre a tela 20 (controles), toca em "Sumário" e espera a folha (150 ms) e os dados; [marcadas] = a aba da 27b.
Future<LeitorNaTela> abrirTela27(
  WidgetTester tester,
  LivroNaEstante livro, {
  bool golden = false,
  bool marcadas = false,
  ReaderClubSource clube = const ClubeDoMundo(),
}) async {
  setCanvasView(tester, logical: const Size(390, 844));
  final t = await abrirLeitor(
    tester,
    livro,
    golden: golden,
    deps: (t) => depsDaTela27(t, livro, clube: clube),
  );
  await tester.tapAt(const Offset(195, 420));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 150));
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
  await tester.tap(_key('r20.bottomIsland.tools.toc'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 150));
  await _banco(tester);
  if (marcadas) {
    await tester.tap(_key('toc.sheet.tabs.bookmarks'));
    await tester.pump();
    await _banco(tester);
  }
  return t;
}

PageSnapshot _pagina(WidgetTester tester) =>
    tester.widget<ReaderPageView>(find.byType(ReaderPageView)).document.current
        as PageSnapshot;

/// O AppText de [id] cujo texto começa pela 1ª linha esperada (a aba Marcadas tem o nome e o número em dois textos).
RenderAppText _texto(WidgetTester tester, String id, String primeira) {
  final todos = find
      .descendant(
        of: _key(id),
        matching: find.byType(AppText, skipOffstage: false),
        matchRoot: true,
        skipOffstage: false,
      )
      .evaluate()
      .toList();
  for (final e in todos) {
    final w = e.widget as AppText;
    if (w.span.toPlainText().startsWith(primeira)) {
      return e.renderObject! as RenderAppText;
    }
  }
  throw StateError('sem AppText "$primeira" em $id');
}

void faseL27({
  required String nome,
  required LeitorRefPrancha ref,
  required InstantaneoDoLeitor instantaneo,
  required bool marcadas,
}) {
  setUpAll(loadAppFonts);

  late LivroNaEstante livro;
  setUp(() async => livro = await livroDaTela27());
  tearDown(() async => livro.close());

  final pre = marcadas ? 'bm' : 'toc';
  final secoes = ['$pre.page', '$pre.fade', '$pre.sheet'];
  final cores = ReaderChromePalette.of(ReaderPaper.creme);

  /// O retângulo medido na tela para o id da prancha (a página e o texto dela pela página do leitor).
  Rect medido(WidgetTester tester, String id) {
    if (id == '$pre.page' || id == '$pre.page.text') {
      final p = _pagina(tester);
      final s = p.page.slices.first as TextSlice;
      final b = p.block(s.block) as LaidText;
      final t = p.typography;
      final esperado = ref.elements[id]!.rect;
      return Rect.fromLTWH(
        t.sideMargin + (id == '$pre.page' ? 0 : b.left),
        t.topInset + (id == '$pre.page' ? 0 : s.y),
        id == '$pre.page' ? t.contentWidth : b.width,
        id == '$pre.page'
            // desvio: o `article` da prancha tem 200 de altura; a página do app continua sob o véu
            ? esperado.height
            : b.lines[s.firstLine + 6].bottom - b.lines[s.firstLine].top,
      );
    }
    if (id == 'toc.sheet.chapters.list') {
      // desvio: a prancha só tem as 13 linhas de XXV a XXXVII; no app a lista tem os 148 capítulos e abre rolada
      // (D-154) — confere-se o trecho da prancha, da 1ª à última linha dela
      final de = tester.getRect(_key('toc.sheet.chapters.ch25'));
      final ate = tester.getRect(_key('toc.sheet.chapters.ch37'));
      return Rect.fromLTRB(de.left, de.top, ate.right, ate.bottom);
    }
    return tester.getRect(_key(id));
  }

  testWidgets('$nome — geometria: os ids das seções', (tester) async {
    await abrirTela27(tester, livro, marcadas: marcadas);
    final ids = [for (final s in secoes) ...ref.idsOfSection(s)];
    expect(ids, hasLength(marcadas ? 53 : 131));
    final falhas = <String>[];
    for (final id in ids) {
      if (_key(id).evaluate().isEmpty && !id.startsWith('$pre.page')) {
        falhas.add('$id: não está na tela');
        continue;
      }
      final m = medido(tester, id);
      final e = ref.elements[id]!;
      final r = e.rect;
      final tolX = ref.textDependentX.contains(id) ? 1.0 : 0.5;
      void confere(String o, double g, double x, double tol) {
        if ((g - x).abs() > tol + 1e-6) {
          falhas.add(
            '$id.$o: ${g.toStringAsFixed(2)} ≠ ${x.toStringAsFixed(2)}',
          );
        }
      }

      confere('x', m.left, r.left, tolX);
      confere('y', m.top, r.top, 0.5);
      confere('w', m.width, r.width, tolX);
      confere('h', m.height, r.height, 0.5);
    }
    expect(falhas, isEmpty, reason: falhas.join('\n'));
  });

  testWidgets('$nome — texto: a página e os textos da folha, com as baselines', (
    tester,
  ) async {
    await abrirTela27(tester, livro, marcadas: marcadas);
    final p = _pagina(tester);
    final s = p.page.slices.first as TextSlice;
    final b = p.block(s.block) as LaidText;
    final base = p.typography.topInset + s.y - b.lines[s.firstLine].top;
    final linhas = ref.elements['$pre.page.text']!.lines;
    expect(linhas, hasLength(7));
    for (var i = 0; i < 7; i++) {
      final line = b.lines[s.firstLine + i];
      final texto = p.item.text.substring(line.start, line.end).trimRight();
      expect(texto, linhas[i].text);
      expect(
        base + line.baseline,
        moreOrLessEquals(linhas[i].baseline, epsilon: 0.5),
        reason: linhas[i].text,
      );
    }
    // a caixa da lista: o que fica abaixo dela está recortado (as linhas "ocultas" da prancha)
    final caixa = marcadas ? null : tester.getRect(_key('toc.sheet.chapters'));
    final falhas = <String>[];
    for (final e in ref.elements.entries) {
      final id = e.key;
      if (!id.startsWith('$pre.sheet') ||
          e.value.kind == LeitorRefKind.inline) {
        continue;
      }
      final esperadas = e.value.linesAll.isNotEmpty
          ? e.value.linesAll
          : e.value.lines;
      if (esperadas.isEmpty) continue;
      final r = _texto(tester, id, esperadas.first.text);
      final got = r.debugLines();
      if (got.map((l) => l.text).join('|') !=
          esperadas.map((l) => l.text).join('|')) {
        falhas.add(
          '$id: ${got.map((l) => l.text).toList()} ≠ ${esperadas.map((l) => l.text).toList()}',
        );
        continue;
      }
      for (var i = 0; i < got.length; i++) {
        final x = esperadas[i];
        if ((got[i].baseline - x.baseline).abs() > 0.5 ||
            (got[i].left - x.left).abs() > 1 ||
            (got[i].right - x.right).abs() > 1) {
          falhas.add(
            '$id[$i] "${x.text}": baseline ${got[i].baseline.toStringAsFixed(2)}/${x.baseline}, '
            '${got[i].left.toStringAsFixed(2)}–${got[i].right.toStringAsFixed(2)} ≠ ${x.left}–${x.right}',
          );
        }
        if (x.hidden && caixa != null) {
          // recortada: abaixo da caixa da lista (atrás do fim da folha)
          if (got[i].baseline < caixa.bottom - tocFadeBottom) {
            falhas.add('$id[$i] "${x.text}": deveria estar recortada');
          }
        }
      }
    }
    expect(falhas, isEmpty, reason: falhas.join('\n'));
  });

  testWidgets(
    '$nome — estilo: folha, abas, ${marcadas ? 'cartões e dica' : 'faixa, linhas e o atual'}',
    (tester) async {
      await abrirTela27(tester, livro, marcadas: marcadas);
      final brand = instantaneoBrand(instantaneo);
      final linha = BorderSide(width: 1.5, color: cores.border);
      final folha = tester.widget<NeoBox>(_key('$pre.sheet'));
      expect(
        (folha.color, folha.border, folha.shadow, folha.shadowColor),
        (cores.island, linha, const Offset(0, 4), cores.shadow),
      );
      expect(
        folha.radius,
        const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
          bottomLeft: Radius.circular(44),
          bottomRight: Radius.circular(44),
        ),
      );
      final veu = tester.widget<ColoredBox>(
        find.descendant(
          of: _key('$pre.fade'),
          matching: find.byType(ColoredBox),
        ),
      );
      expect(veu.color, AppColors.ink.withValues(alpha: 0.28));
      final ativa = tester.widget<NeoBox>(
        _key(marcadas ? 'bm.sheet.tabs.bookmarks' : 'toc.sheet.tabs.chapters'),
      );
      expect((ativa.color, ativa.border), (brand, linha));
      final barra = tester.widget<NeoBox>(_key('$pre.sheet.tabs'));
      expect((barra.color, barra.border), (AppColors.paper, linha));
      final titulo = tester
          .widget<AppText>(_key('$pre.sheet.title'))
          .span
          .style!;
      expect(
        (titulo.fontFamily, titulo.fontSize, titulo.letterSpacing),
        ('Bricolage26', 26.0, -0.6),
      );
      if (!marcadas) {
        final faixa = tester.widget<NeoBox>(_key('toc.sheet.club'));
        expect(
          (faixa.color, faixa.border, faixa.shadow, faixa.radius),
          (
            AppColors.blush,
            linha,
            const Offset(2, 2),
            BorderRadius.circular(18),
          ),
        );
        final atual = tester.widget<NeoBox>(
          _key('toc.sheet.chapters.ch32.link'),
        );
        expect(
          (atual.color, atual.border, atual.shadow, atual.radius),
          (
            AppColors.surface,
            linha,
            const Offset(2, 2),
            BorderRadius.circular(16),
          ),
        );
        final anel = tester.widget<CustomPaint>(
          _key('toc.sheet.chapters.ch32.progressRing'),
        );
        expect(
          (anel.painter! as TocProgressRingPainter).progress,
          closeTo(18 / 44, 0.001),
        );
        final pilula = tester.widget<NeoBox>(
          _key('toc.sheet.chapters.ch32.youAreHere'),
        );
        expect((pilula.color, pilula.border!.width), (AppColors.flame, 1.3));
        final lido = tester.widget<NeoBox>(
          _key('toc.sheet.chapters.ch25.read'),
        );
        expect((lido.color, lido.border!.width), (AppColors.leaf, 1.3));
        final grifo = tester.widget<NeoBox>(
          _key('toc.sheet.chapters.ch25.marks.highlight'),
        );
        expect(grifo.color, const Color(0xFFFED170));
        final tituloLinha = tester
            .widget<AppText>(
              find.descendant(
                of: _key('toc.sheet.chapters.ch25.title'),
                matching: find.byType(AppText),
              ),
            )
            .span
            .style!;
        expect(
          (tituloLinha.fontFamily, tituloLinha.fontSize, tituloLinha.color),
          ('Literata16', 16.0, AppColors.bookText),
        );
        final naoLido = tester
            .widget<AppText>(
              find.descendant(
                of: _key('toc.sheet.chapters.ch33.title'),
                matching: find.byType(AppText),
              ),
            )
            .span
            .style!;
        expect(naoLido.color, AppColors.ink);
      } else {
        final aqui = tester.widget<NeoBox>(
          _key('bm.sheet.bookmarks.item3.row'),
        );
        expect(
          (aqui.color, aqui.border, aqui.shadow, aqui.radius),
          (
            AppColors.surface,
            linha,
            const Offset(2, 2),
            BorderRadius.circular(18),
          ),
        );
        expect(
          tester.widget<NeoBox>(_key('bm.sheet.bookmarks.item1.row')).shadow,
          isNull,
        );
        final pag = tester.widget<NeoBox>(
          _key('bm.sheet.bookmarks.item1.head.page'),
        );
        expect((pag.color, pag.border), (AppColors.paper, linha));
        final excerto = tester
            .widget<AppText>(_key('bm.sheet.bookmarks.item1.excerpt'))
            .span
            .style!;
        expect(
          (excerto.fontFamily, excerto.fontSize, excerto.height, excerto.color),
          ('Literata15_5', 15.5, 1.5, AppColors.inkWarm),
        );
      }
    },
  );

  testWidgets('$nome — semântica', (tester) async {
    final h = tester.ensureSemantics();
    await abrirTela27(tester, livro, marcadas: marcadas);
    expect(
      tester.getSemantics(_key('$pre.sheet')),
      isSemantics(label: 'Sumário', scopesRoute: true, namesRoute: true),
    );
    expect(
      tester.getSemantics(_key('$pre.sheet.tabs')).role,
      SemanticsRole.tabBar,
    );
    final capitulos = tester.getSemantics(_key('$pre.sheet.tabs.chapters'));
    expect(capitulos.role, SemanticsRole.tab);
    expect(capitulos, isSemantics(isSelected: !marcadas));
    expect(
      tester.getSemantics(_key('$pre.sheet.tabs.bookmarks')),
      isSemantics(isSelected: marcadas),
    );
    expect(find.bySemanticsLabel('Fechar'), findsOneWidget);
    if (!marcadas) {
      expect(find.bySemanticsLabel('Capítulos'), findsOneWidget);
      expect(
        tester.getSemantics(_key('toc.sheet.chapters.ch25.link')),
        isSemantics(
          label:
              '${sumarioDomCasmurro[24].numeral}, ${sumarioDomCasmurro[24].titulo}, página ${sumarioDomCasmurro[24].pagina}, '
              '${instantaneo.marcasDoCapitulo(24).count == 1 ? '1 marca' : '${instantaneo.marcasDoCapitulo(24).count} marcas'}, lido',
          isButton: true,
        ),
      );
      expect(
        tester.getSemantics(_key('toc.sheet.chapters.ch32.link')),
        isSemantics(
          label:
              '${instantaneo.capitulo.numeral}, ${instantaneo.capitulo.titulo}, página ${instantaneo.capitulo.pagina}, '
              '${instantaneo.marcasDoCapitulo(31).count} marcas, lendo, você está na pág. ${instantaneo.pagina}',
          isButton: true,
        ),
      );
    } else {
      expect(find.bySemanticsLabel('Páginas marcadas'), findsOneWidget);
      String visto(String id) => tester
          .widget<AppText>(
            find
                .descendant(
                  of: _key(id),
                  matching: find.byType(AppText),
                  matchRoot: true,
                )
                .first,
          )
          .span
          .toPlainText();
      for (final (i, m) in instantaneo.marcadas.indexed) {
        final it = 'bm.sheet.bookmarks.item${i + 1}';
        // D-158: o cartão inteiro para o leitor de tela, e a ação é abrir
        expect(
          tester.getSemantics(_key('$it.link')),
          isSemantics(
            label: [
              'Página ${m.refPage}',
              visto('$it.head.chapter').replaceAll(' · ', ', '),
              if (m.refPage == instantaneo.pagina) 'você está aqui',
              if (m.excerpt != null) m.excerpt!,
              visto('$it.date'),
            ].join(', '),
            hint: 'Abrir na página ${m.refPage}',
            isButton: true,
          ),
        );
        expect(
          tester.getSemantics(_key('bm.sheet.bookmarks.item${i + 1}.ribbon')),
          isSemantics(
            label: 'Tirar a marca da página ${m.refPage}',
            isToggled: true,
            hasToggledState: true,
          ),
        );
      }
    }
    h.dispose();
  });

  testWidgets('$nome — dados: os textos saem do instantâneo e das contas', (
    tester,
  ) async {
    await abrirTela27(tester, livro, marcadas: marcadas);
    String txt(String id) => tester
        .widget<AppText>(
          find
              .descendant(
                of: _key(id),
                matching: find.byType(AppText),
                matchRoot: true,
              )
              .first,
        )
        .span
        .toPlainText();
    final livroDoMundo = instantaneo.livro;
    expect(
      txt('$pre.sheet.subtitle'),
      '${livroDoMundo.title} · ${livroDoMundo.chaptersTotal} capítulos',
    );
    expect(
      txt('$pre.sheet.tabs.bookmarks.count'),
      '${instantaneo.marcadas.length}',
    );
    if (!marcadas) {
      final meta = sumarioDomCasmurro[instantaneo.mundo.clube.metaCapitulo - 1];
      expect(
        txt('toc.sheet.club.goal'),
        'Até o cap. ${meta.numeral} · faltam ${instantaneo.faltamParaOClube}',
      );
      expect(txt('toc.sheet.chapters.ch32.title'), instantaneo.capitulo.titulo);
      expect(
        txt('toc.sheet.chapters.ch32.youAreHere.text'),
        'você está na pág. ${instantaneo.pagina}',
      );
      for (final c in [24, 30, 31]) {
        expect(
          txt('toc.sheet.chapters.ch${c + 1}.marks.count'),
          '${instantaneo.marcasDoCapitulo(c).count}',
        );
      }
    } else {
      for (final (i, m) in instantaneo.marcadas.indexed) {
        expect(
          txt('bm.sheet.bookmarks.item${i + 1}.head.page'),
          'pág. ${m.refPage}',
        );
        expect(txt('bm.sheet.bookmarks.item${i + 1}.excerpt'), m.excerpt);
      }
    }
  });
}

// G16 (Tarefa 24) — o mundo da tela 22 no banco do leitor (D-34): o Dom Casmurro do mundo com o EPUB da 22 (NBSP dentro
// dos 4 trechos anotados — D-160), o índice da 19, a pág. 159, o que estava gravado quando a sessão da prancha começou
// (o grifo à mão e a elipse com o risco — `mundoDaTela22`), com as âncoras refeitas no sha e na citação deste arquivo
// (os deslocamentos não mudam), e o `pen_presets` do mundo. A tela 22 é aberta pelo fluxo de verdade: controles →
// Anotar → Reta (as 2 barras do sublinhado duplo, dos centros das pontas medidas) → Caneta → a onda até 66 % e o último
// movimento até o centro do anel, com o dedo parado (o traço ao vivo e o indicador de toque da prancha).
import 'package:app_leitura/core/data/database/daos/annotation_daos.dart';
import 'package:app_leitura/core/data/database/daos/reader_daos.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/features/reader/annotations/domain/annotation.dart';
import 'package:app_leitura/features/reader/annotations/ink/drawing_anchor.dart';
import 'package:app_leitura/features/reader/content/chapter_content.dart'
    show chapterOf;
import 'package:app_leitura/features/reader/domain/anchoring.dart' show quoteAt;
import 'package:app_leitura/features/reader/domain/locator.dart';
import 'package:app_leitura/features/reader/application/annotation_session.dart'
    show AnnotationTool;
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:app_leitura/features/reader/presentation/tool_shelf.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/mundo_2026_09_20.dart';
import '../fixtures/telas/indice_t19.dart';
import '../fixtures/telas/instantaneo.dart' show mundoDaTela22;
import '../fixtures/tinta_do_mundo.dart';
import 'canvas.dart';
import 'dados_t20.dart' show depsDaTela20;
import 'mundo_epub.dart';
import 'precache_svgs.dart';
import 'pump_reader.dart';
import 'reader_harness.dart';

/// Os trechos anotados da página 159 que a prancha 22 não quebra (`white-space: nowrap` — D-160).
const Set<String> trechosDaTela22 = {
  'olhos de Capitu',
  'Olhos de ressaca?',
  'fluido misterioso',
  'a vaga que se retira',
};

/// O Dom Casmurro da tela 22 na estante da conta do mundo, no papel [papel]. [nbsp] = `false`: o EPUB da 19 (as
/// quebras do leitor limpo). [mundo] troca o que estava gravado (G17: o mundo das telas 23 e 23b, com a tinta toda);
/// os rótulos do marca-texto do mundo vão junto (D-40).
Future<LivroNaEstante> livroDaTela22({
  ReaderPaper papel = ReaderPaper.creme,
  bool nbsp = true,
  Mundo? mundo,
}) async {
  final m = mundo ?? mundoDaTela22;
  final livro = await LivroNaEstante.epubDe(
    mundoEpub(
      Slugs.domCasmurro,
      completo: true,
      nbsp: nbsp ? trechosDaTela22 : const {},
    ),
    livro: m.domCasmurro,
    leitor: m.usuarioId,
  );
  await livro.usarIndice(indiceDaTela19(livro.index));
  await livro.guardarPosicao(itemDaPagina159, 0);
  final sha = livro.index.contentSha256;
  final texto = chapterOf(livro.epub, itemDaPagina159).item.text;
  EpubAnchor deste(EpubAnchor a) => a.spine != itemDaPagina159
      ? a
      : EpubAnchor(
          sha: sha,
          spine: a.spine,
          start: a.start,
          end: a.end,
          quote: quoteAt(texto, a.start, a.end),
          refPage: a.refPage,
        );
  final db = livro.db;
  for (final c in m.camadas) {
    final ink = inkAnchorOf(c.anchor);
    final w = ink?.w;
    await InkLayersDao(db).upsert(
      ink == null
          ? c
          : c.copyWith(
              anchor: w == null
                  ? deste(ink.range)
                  : inkLayerAnchor(deste(ink.range), w),
            ),
    );
  }
  for (final a in m.anotacoes) {
    final anchor = a.anchor;
    await AnnotationsDao(db).upsert(
      a.userBookId == m.domCasmurro.id && anchor is EpubAnchor
          ? a.copyWith(anchor: deste(anchor))
          : a,
    );
  }
  await PenPresetsDao(db).upsert(m.caneta);
  for (final r in m.rotulos) {
    await HighlightLabelsDao(db).upsert(r);
  }
  await ReaderSettingsDao(db).upsert(m.ajustes.copyWith(paper: papel));
  return livro;
}

Finder _key(String k) => find.byKey(ValueKey<String>(k));

Future<void> _quadros(WidgetTester tester, [int n = 20]) async {
  for (var i = 0; i < n; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

/// O banco (as anotações e a tinta relidas, o `pen_presets`) e a tela.
Future<void> esperarBancoL22(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 16));
  }
}

/// Entra no modo anotação pelo "Anotar" dos controles e espera a camada (220 ms).
Future<void> entrarNoModoAnotacao(WidgetTester tester) async {
  await tester.tapAt(const Offset(195, 420));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 150));
  await _quadros(tester, 6);
  await tester.tap(_key('r20.bottomIsland.tools.annotate'));
  await esperarBancoL22(tester);
  await _quadros(tester);
}

/// Um traço de dedo pelos [pontos], 8 ms entre eles; [soltar] = `false` deixa o dedo parado no último.
Future<TestGesture> tracarL22(
  WidgetTester tester,
  List<Offset> pontos, {
  bool soltar = true,
}) async {
  final g = await tester.startGesture(pontos.first);
  for (var i = 1; i < pontos.length; i++) {
    await g.moveTo(pontos[i], timeStamp: Duration(milliseconds: 8 * i));
  }
  if (soltar) await g.up();
  await tester.pump();
  return g;
}

/// O dedo da onda, ainda na tela (a prancha mostra o traço sendo desenhado).
TestGesture? dedoDaTela22;

/// Abre a tela 22: o leitor na pág. 159, o modo anotação, as 2 barras com a Reta e a onda com a Caneta até 66 %, o
/// último movimento até o centro do anel (o dedo fica).
Future<LeitorNaTela> abrirTela22(
  WidgetTester tester,
  LivroNaEstante livro, {
  bool golden = false,
}) async {
  setCanvasView(tester, logical: const Size(390, 844));
  await precacheTela22(tester);
  final t = await abrirLeitor(
    tester,
    livro,
    golden: golden,
    deps: (t) => depsDaTela20(t, livro),
  );
  await esperarBancoL22(tester);
  await entrarNoModoAnotacao(tester);
  await tester.tap(_key('ann.toolShelf.line'));
  await tester.pump();
  for (final (a, b) in barrasDoDuplo22()) {
    await tracarL22(tester, [a, Offset.lerp(a, b, 0.5)!, b]);
  }
  await tester.tap(_key('ann.toolShelf.pen'));
  await tester.pump();
  final anel = kRefAnelDaTela22.center;
  dedoDaTela22 = await tracarL22(tester, [
    ...pontosDaOnda22(ate: 0.66),
    anel,
  ], soltar: false);
  addTearDown(() async {
    await dedoDaTela22?.up();
    dedoDaTela22 = null;
  });
  await _quadros(tester, 6);
  return t;
}

/// As ilustrações da prateleira, ativas e não, com as cores do mundo (a `brand` padrão e a tinta coral): o
/// flutter_svg carrega de forma assíncrona e, sem isto, o golden sai sem os objetos.
Future<void> precacheTela22(
  WidgetTester tester, {
  Color brand = AppColors.lavender,
  Color ink = const Color(tintaCoral),
}) async {
  for (final tool in AnnotationTool.values) {
    for (final on in const [false, true]) {
      final (asset, colors) = ToolShelf.art(
        tool,
        on: on,
        brand: brand,
        ink: ink,
      );
      await precacheSvgs(tester, [asset], colors: colors);
    }
  }
}

/// O anel do indicador de toque medido na prancha (L22a nº 10).
final Rect kRefAnelDaTela22 = caixaNaPrancha('ann.page.text.wavy.touchRing');

/// A anotação `drawing` de [m] presa a [exato] (para conferir o que a tela mostra).
Annotation desenhoDoMundoEm(String exato) =>
    mundoReferencia.anotacoes.singleWhere(
      (a) =>
          a.kind == AnnotationKind.drawing &&
          (a.anchor as EpubAnchor).quote.exact == exato,
    );

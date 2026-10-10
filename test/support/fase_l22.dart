// G16.7 — as fases L22a (a página anotada e a borda de mesa), L22b (a pílula e o Concluir), L22c (a prateleira) e
// L22d (a ilha): a tela 22 pela rota real, no mundo da tela 22 (D-34 e D-160), aberta pelo fluxo (`abrirTela22`:
// "Anotar", as 2 barras do duplo com a Reta, a onda com a Caneta até 66 % e o dedo parado no centro do anel), contra
// as medidas do arquivo:
// - geometria: os ids de cada seção (±0,5; ±1,0 em x/w nos que dependem do texto). Na página: `ann.page.text` pelo
//   bloco do parágrafo; a tinta pelos pontos dos traços contra o caminho do arquivo na caixa medida (desvio ≤ 0,5 px,
//   além da metade do passo de 1/100 em nos traços gravados); as barras da Reta pela cápsula; a mancha pela caixa
//   calculada (D-161); o anel e o ponto pelo retângulo; os trechos inline linha a linha;
// - texto: as 22 linhas do parágrafo (a 22ª escondida) com o fio de navalha das linhas 7 e 19; vindo da 19 (sem
//   NBSP), as quebras do leitor limpo ficam e o texto só desce 30 (D-160); os rótulos, "Modo anotação", o subtítulo
//   e "Concluir";
// - estilo, semântica e dados (os textos e as cores saem do instantâneo e do banco).
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:app_leitura/core/design_system/painters/chromium_dash.dart';
import 'package:app_leitura/core/design_system/painters/conic_ring_painter.dart';
import 'package:app_leitura/core/design_system/painters/dashed_stadium_painter.dart';
import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/tokens/app_illustrations_leitor.dart';
import 'package:app_leitura/core/design_system/tokens/app_shadows.dart';
import 'package:app_leitura/core/design_system/tokens/app_typography.dart';
import 'package:app_leitura/core/design_system/widgets/app_svg.dart';
import 'package:app_leitura/core/design_system/widgets/neo_box.dart';
import 'package:app_leitura/features/reader/annotations/domain/annotation.dart';
import 'package:app_leitura/features/reader/annotations/domain/pen_presets.dart';
import 'package:app_leitura/features/reader/annotations/ink/ink_stroke.dart';
import 'package:app_leitura/features/reader/annotations/ink/ink_units.dart';
import 'package:app_leitura/features/reader/application/annotation_session.dart';
import 'package:app_leitura/features/reader/domain/locator.dart';
import 'package:app_leitura/features/reader/layout/display_page.dart';
import 'package:app_leitura/features/reader/layout/laid_block.dart';
import 'package:app_leitura/features/reader/layout/page_snapshot.dart';
import 'package:app_leitura/features/reader/layout/paginator.dart';
import 'package:app_leitura/features/reader/presentation/annotation_canvas.dart';
import 'package:app_leitura/features/reader/presentation/annotation_island.dart';
import 'package:app_leitura/features/reader/presentation/annotation_mode.dart';
import 'package:app_leitura/features/reader/presentation/ink_painter.dart';
import 'package:app_leitura/features/reader/presentation/reader_chrome_palette.dart';
import 'package:app_leitura/features/reader/presentation/reader_palette.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/telas/t22.dart';
import '../fixtures/tinta_do_mundo.dart';
import '../reference/leitor/reference_layout_19_leitor_limpo.dart';
import '../reference/leitor/reference_layout_22_modo_anotacao.dart';
import 'canvas.dart';
import 'dados_t20.dart' show depsDaTela20;
import 'dados_t22.dart';
import 'fase_l20.dart' show instantaneoBrand;
import 'load_fonts.dart';
import 'pecas_l22.dart';
import 'pump_reader.dart';
import 'reader_harness.dart';

const double _desce = annotationTextShift;

/// Metade do passo de 1/100 em na letra da prancha: o que a gravação em em arredonda.
const double _quantizacao = emDaPrancha / 100 / 2;

AnnotationMode _modo(WidgetTester tester) =>
    tester.widget<AnnotationMode>(find.byType(AnnotationMode));

AnnotationSession sessaoL22(WidgetTester tester) => _modo(tester).session;

/// A página aberta (a do leitor limpo, travada no modo).
PageSnapshot paginaDoModo(WidgetTester tester) =>
    _modo(tester).page as PageSnapshot;

/// O trecho [texto] da página, por linha, já na tela da 22 (30 abaixo do leitor limpo).
List<TextLineBox> trechoNaTela(WidgetTester tester, String texto) {
  final p = paginaDoModo(tester);
  final t = p.item.text.replaceAll(' ', ' ');
  final a = t.indexOf(texto);
  expect(a, isNot(-1), reason: texto);
  return porLinhaNaTela(p, p.spine, a, a + texto.length);
}

/// As caixas de [unit] [from]–[to] por linha (a união das caixas de cada linha), 30 abaixo.
List<TextLineBox> porLinhaNaTela(DisplayPage p, int unit, int from, int to) {
  final linhas = <double, TextLineBox>{};
  for (final c in p.boxesOf(unit, from, to)) {
    final antes = linhas[c.baseline];
    linhas[c.baseline] = antes == null
        ? c
        : (
            rect: antes.rect.expandToInclude(c.rect),
            baseline: c.baseline,
            textTop: c.textTop,
            textBottom: c.textBottom,
            em: c.em,
          );
  }
  return [
    for (final l
        in linhas.values.toList()
          ..sort((a, b) => a.baseline.compareTo(b.baseline)))
      (
        rect: l.rect.shift(const Offset(0, _desce)),
        baseline: l.baseline + _desce,
        textTop: l.textTop + _desce,
        textBottom: l.textBottom + _desce,
        em: l.em,
      ),
  ];
}

/// Os pontos de [s] na tela da 22.
List<Offset> pontosNaTela(InkStroke s) => [
  for (final p in s.points) Offset(p.x, p.y + _desce),
];

/// O maior desvio dos [pontos] até a polilinha [caminho].
double desvioMaximo(List<Offset> pontos, List<Offset> caminho) =>
    pontos.map((p) => distanciaALinha(p, caminho)).reduce(math.max);

/// A cápsula da Reta [s] na tela: do primeiro ao último ponto, com metade da largura para cada lado.
Rect capsulaNaTela(InkStroke s) {
  final r = dpOfCentiMm(s.widthCentiMm) / 2;
  final a = pontosNaTela(s).first;
  final b = pontosNaTela(s).last;
  return Rect.fromPoints(a, b).inflate(r);
}

/// Os traços da página: a elipse e o risco (o desenho do banco), as 2 barras da Reta e a onda ao vivo.
({InkStroke elipse, InkStroke risco, List<InkStroke> barras, InkStroke onda})
tracosL22(WidgetTester tester) {
  final s = sessaoL22(tester);
  final todos = s.visibleStrokes;
  final barras = [
    for (final t in todos)
      if (InkTool.fromCode(t.tool) == InkTool.line) t,
  ]..sort((a, b) => a.points.first.y.compareTo(b.points.first.y));
  final caneta = [
    for (final t in todos)
      if (InkTool.fromCode(t.tool) == InkTool.pen) t,
  ];
  expect(caneta, hasLength(2), reason: 'a elipse e o risco');
  expect(barras, hasLength(2), reason: 'as 2 barras do duplo');
  final ao = s.live.value;
  expect(ao, isA<LiveStroke>(), reason: 'a onda ainda sendo desenhada');
  return (
    elipse: caneta[0],
    risco: caneta[1],
    barras: barras,
    onda: (ao! as LiveStroke).stroke,
  );
}

NeoBox _caixa(WidgetTester tester, String id) => tester.widget<NeoBox>(
  find
      .descendant(
        of: chaveL22(id),
        matching: find.byType(NeoBox),
        matchRoot: true,
      )
      .first,
);

/// Grava os retângulos e os caminhos que o pintor da página desenha (com a tinta e o modo de mistura).
final class _Gravador implements ui.Canvas {
  final retangulos = <(Rect, Color)>[];
  final caminhos = <(Rect, Color, BlendMode)>[];

  @override
  void drawRect(Rect rect, Paint paint) => retangulos.add((rect, paint.color));

  @override
  void drawPath(Path path, Paint paint) =>
      caminhos.add((path.getBounds(), paint.color, paint.blendMode));

  @override
  Float64List getTransform() => Float64List(16);

  @override
  Object? noSuchMethod(Invocation invocation) => null;
}

void _comOLivro(void Function(LivroNaEstante Function() livro) testes) {
  setUpAll(loadAppFonts);
  late LivroNaEstante livro;
  setUp(() async => livro = await livroDaTela22());
  tearDown(() async => livro.close());
  testes(() => livro);
}

// ---- L22a ----------------------------------------------------------------------------------------------------

/// Os trechos inline da página e o texto de cada um.
const Map<String, String> inlineL22 = {
  'ann.page.text.handHighlight': 'olhos de Capitu',
  'ann.page.text.circled': 'Olhos de ressaca?',
  'ann.page.text.wavy': 'fluido misterioso',
  'ann.page.text.doubleUnderline': 'a vaga que se retira',
};

void faseL22a() => _comOLivro((livro) {
  testWidgets(
    'L22a — geometria: os ids da página e da borda de mesa; a tinta pelos pontos; os trechos inline',
    (tester) async {
      await abrirTela22(tester, livro());
      final ids = [
        ...kRef22.idsOfSection('ann.page'),
        ...kRef22.idsOfSection('ann.deskEdge'),
      ];
      expect(ids, hasLength(10 + 1));
      final falhas = <String>[];
      void confere(String id, String o, double g, double e, double tol) {
        if ((g - e).abs() > tol + 1e-6) {
          falhas.add(
            '$id.$o: ${g.toStringAsFixed(2)} ≠ ${e.toStringAsFixed(2)}',
          );
        }
      }

      void retangulo(String id, Rect m) {
        final r = kRef22.elements[id]!.rect;
        final tx = kRef22.textDependentX.contains(id) ? 1.0 : 0.5;
        confere(id, 'x', m.left, r.left, tx);
        confere(id, 'y', m.top, r.top, 0.5);
        confere(id, 'w', m.width, r.width, tx);
        confere(id, 'h', m.height, r.height, 0.5);
      }

      final p = paginaDoModo(tester);
      final tinta = tracosL22(tester);
      final modo = _modo(tester);
      final desvios = <String, double>{};
      for (final id in ids) {
        switch (id) {
          case 'ann.page.text':
            // o parágrafo: do topo da caixa da página até o pé da última linha (30 abaixo do leitor limpo)
            final s = p.page.slices.first as TextSlice;
            final b = p.block(s.block) as LaidText;
            final t = p.typography;
            retangulo(
              id,
              Rect.fromLTRB(
                t.sideMargin + b.left,
                tester.getRect(chaveL22('ann.page')).top,
                t.sideMargin + b.left + b.width,
                t.topInset + s.y + _desce + b.lines.last.bottom,
              ),
            );
          case 'ann.page.text.handHighlight.stroke':
            final m = handHighlightBoxes(p, modo.inkHighlights);
            expect(m, hasLength(1), reason: 'a mancha numa linha');
            retangulo(id, m.single.box.shift(const Offset(0, _desce)));
          case 'ann.page.text.circled.ellipse':
            final d = desvioMaximo(
              pontosNaTela(tinta.elipse),
              pontosDaElipse22(),
            );
            desvios[id] = d;
            if (d > 0.5 + _quantizacao) falhas.add('$id: desvio $d');
          case 'ann.page.text.circled.flourish':
            final d = desvioMaximo(
              pontosNaTela(tinta.risco),
              pontosDoRisco22(),
            );
            desvios[id] = d;
            if (d > 0.5 + _quantizacao) falhas.add('$id: desvio $d');
          case 'ann.page.text.wavy.wave':
            // a onda ao vivo, sem o último movimento (até o centro do anel)
            final pts = pontosNaTela(tinta.onda);
            final d = desvioMaximo(
              pts.sublist(0, pts.length - 1),
              pontosDaOnda22(ate: 0.66),
            );
            desvios[id] = d;
            if (d > 0.5) falhas.add('$id: desvio $d');
          case 'ann.page.text.doubleUnderline.line1':
            retangulo(id, capsulaNaTela(tinta.barras[0]));
          case 'ann.page.text.doubleUnderline.line2':
            retangulo(id, capsulaNaTela(tinta.barras[1]));
          default:
            retangulo(id, tester.getRect(chaveL22(id)));
        }
      }
      // os trechos inline: o retângulo de cada linha (a área do texto) e as bordas
      for (final MapEntry(key: id, value: texto) in inlineL22.entries) {
        final e = kRef22.elements[id]!;
        final got = trechoNaTela(tester, texto);
        expect(got, hasLength(e.lines.length), reason: id);
        for (var i = 0; i < got.length; i++) {
          confere(
            id,
            'linha $i baseline',
            got[i].baseline,
            e.lines[i].baseline,
            0.5,
          );
          confere(id, 'linha $i início', got[i].rect.left, e.lines[i].left, 1);
          confere(id, 'linha $i fim', got[i].rect.right, e.lines[i].right, 1);
        }
        final uniao = Rect.fromLTRB(
          got.map((l) => l.rect.left).reduce(math.min),
          got.first.textTop,
          got.map((l) => l.rect.right).reduce(math.max),
          got.last.textBottom,
        );
        retangulo(id, uniao);
      }
      // ignore: avoid_print
      print(
        'G16.7 tela 22: desvio da tinta (px) — ${[for (final MapEntry(:key, :value) in desvios.entries) '${key.split('.').last} ${value.toStringAsFixed(3)}'].join(' · ')}',
      );
      expect(falhas, isEmpty, reason: falhas.join('\n'));
    },
  );

  testWidgets(
    'L22a — a onda acaba no centro do anel; o anel e o ponto ficam no dedo; as barras são Reta de 2 pontos',
    (tester) async {
      await abrirTela22(tester, livro());
      final tinta = tracosL22(tester);
      final anel = kRefAnelDaTela22.center;
      expect(pontosNaTela(tinta.onda).last, offsetMoreOrLessEquals(anel));
      expect(
        tester.getCenter(chaveL22('ann.page.text.wavy.touchRing')),
        offsetMoreOrLessEquals(anel),
      );
      expect(
        tester.getCenter(chaveL22('ann.page.text.wavy.touchDot')),
        offsetMoreOrLessEquals(anel),
      );
      final barras = barrasDoDuplo22();
      for (var i = 0; i < 2; i++) {
        final pts = pontosNaTela(tinta.barras[i]);
        expect(pts, hasLength(2));
        expect(pts.first, offsetMoreOrLessEquals(barras[i].$1, epsilon: 0.5));
        expect(pts.last, offsetMoreOrLessEquals(barras[i].$2, epsilon: 0.5));
      }
    },
  );

  testWidgets(
    'L22a — texto: as 22 linhas (a 22ª escondida) e o fio de navalha das linhas 7 e 19 (D-160)',
    (tester) async {
      await abrirTela22(tester, livro());
      final p = paginaDoModo(tester);
      final s = p.page.slices.first as TextSlice;
      final b = p.block(s.block) as LaidText;
      final t = p.typography;
      final todas = kRef22.elements['ann.page.text']!.linesAll;
      expect(b.lines, hasLength(todas.length));
      expect(todas, hasLength(22));
      final base = t.topInset + s.y + _desce - b.lines[s.firstLine].top;
      final direita = t.sideMargin + t.contentWidth;
      final fundo = tester.getRect(chaveL22('ann.page')).bottom;
      for (var l = 0; l < b.lines.length; l++) {
        final line = b.lines[l];
        final e = todas[l];
        final texto = p.item.text
            .substring(line.start, line.end)
            .replaceAll(' ', ' ')
            .trimRight();
        expect(texto, e.text, reason: 'linha ${l + 1}');
        expect(
          base + line.baseline,
          moreOrLessEquals(e.baseline, epsilon: 0.5),
          reason: e.text,
        );
        // a escondida passa do pé da tela; as que não são da página ficam embaixo da borda de mesa opaca
        expect(base + line.top >= fundo, e.hidden, reason: 'linha ${l + 1}');
        if (l > s.lastLine) {
          expect(
            base + line.top,
            greaterThanOrEqualTo(fundo - deskEdgeSolid),
            reason: 'linha ${l + 1} fora da página, sob a borda de mesa',
          );
        }
      }
      for (final k in kRef22.knifeEdges) {
        final line = b.lines[k.line - 1];
        final texto = p.item.text
            .substring(line.start, line.end)
            .replaceAll(' ', ' ')
            .trimRight();
        expect(texto, k.text);
        final fim = p
            .boxesOf(p.spine, line.start, line.end)
            .map((c) => c.rect.right)
            .reduce(math.max);
        expect(direita - fim, moreOrLessEquals(k.slack, epsilon: 1));
      }
    },
  );

  testWidgets(
    'L22a — vindo da 19 (sem NBSP), as quebras do leitor limpo ficam e o texto só desce 30 (D-160)',
    (tester) async {
      final da19 = await livroDaTela22(nbsp: false);
      addTearDown(da19.close);
      setCanvasView(tester, logical: const Size(390, 844));
      await precacheTela22(tester);
      await abrirLeitor(tester, da19, deps: (t) => depsDaTela20(t, da19));
      await esperarBancoL22(tester);
      await entrarNoModoAnotacao(tester);
      final p = paginaDoModo(tester);
      final s = p.page.slices.first as TextSlice;
      final b = p.block(s.block) as LaidText;
      final t = p.typography;
      // a 19 não tem trechos inline: as linhas do próprio texto são as do parágrafo
      final limpo = kRef19.elements['r19.page.text']!.lines;
      final base = t.topInset + s.y + _desce - b.lines[s.firstLine].top;
      expect(b.lines, hasLength(limpo.length));
      for (var l = 0; l < b.lines.length; l++) {
        final line = b.lines[l];
        expect(
          p.item.text.substring(line.start, line.end).trimRight(),
          limpo[l].text,
        );
        expect(
          base + line.baseline,
          moreOrLessEquals(limpo[l].baseline + _desce, epsilon: 0.5),
        );
      }
    },
  );

  testWidgets(
    'L22a — estilo: o papel, a mancha a 90 % multiplicada, a tinta coral na Média, o anel, o ponto e o degradê',
    (tester) async {
      await abrirTela22(tester, livro());
      final papel = ReaderPalette.of(t22.mundo.ajustes.paper).paper;
      final g = _Gravador();
      (tester.widget<CustomPaint>(chaveL22('ann.canvas.page')).painter!
              as AnnotationPagePainter)
          .paint(g, const Size(390, 844));
      final (fundo, corDoFundo) = g.retangulos.first;
      expect(
        (fundo, corDoFundo.toARGB32()),
        (Offset.zero & const Size(390, 844), papel.toARGB32()),
      );
      final grifo = t22.anotacoesNaPagina.singleWhere(
        (a) => a.kind == AnnotationKind.highlight,
      );
      expect(grifo.source, AnnotationSource.ink);
      final cor = Color(argbOfHex(grifo.color!));
      final mancha = [
        for (final (_, c, m) in g.caminhos)
          if (m == BlendMode.multiply) c,
      ];
      expect(mancha, hasLength(1));
      // o `Paint` guarda a cor em float32: o alfa 0,9 fica perto, as letras do RGB iguais
      expect(mancha.single.a, closeTo(.9, 1e-6));
      expect(mancha.single.withValues(alpha: 1).toARGB32(), cor.toARGB32());
      final tinta = tracosL22(tester);
      final caneta = t22.mundo.caneta;
      for (final s in [tinta.elipse, tinta.onda, ...tinta.barras]) {
        expect(s.argb, argbOfHex(caneta.penColor));
      }
      expect(
        tinta.onda.widthCentiMm,
        widthCentiMm(caneta.penWidthMm, caneta.strokeSize),
        reason: 'a Média do pen_presets (2,2 px)',
      );
      expect(dpOfCentiMm(tinta.onda.widthCentiMm), closeTo(2.2, 0.01));
      expect(
        [tinta.elipse.widthCentiMm, tinta.risco.widthCentiMm],
        [centiMmOfDp(2.3), centiMmOfDp(1.8)],
      );
      final anel = tester.widget<CustomPaint>(
        chaveL22('ann.page.text.wavy.touchRing'),
      );
      // a borda por cima do miolo, como no CSS (T01, R7)
      expect(anel.painter, isNull);
      expect(
        (anel.foregroundPainter! as DashedStadiumPainter).color,
        AppColors.ink,
      );
      expect(
        tester
            .widget<DecoratedBox>(
              find.descendant(
                of: chaveL22('ann.page.text.wavy.touchRing'),
                matching: find.byType(DecoratedBox),
              ),
            )
            .decoration,
        const BoxDecoration(color: touchRingFill, shape: BoxShape.circle),
      );
      final ponto =
          tester
                  .widget<DecoratedBox>(chaveL22('ann.page.text.wavy.touchDot'))
                  .decoration
              as BoxDecoration;
      expect(
        (ponto.color, ponto.border),
        (
          Color(argbOfHex(caneta.penColor)),
          Border.all(width: 1.5, color: AppColors.ink),
        ),
      );
      final degrade =
          (tester.widget<DecoratedBox>(chaveL22('ann.deskEdge')).decoration
                      as BoxDecoration)
                  .gradient!
              as LinearGradient;
      expect(degrade.colors, [papel, papel, papel.withValues(alpha: 0)]);
      expect(degrade.stops, [0, 135 / 250, 1]);
      expect(
        (degrade.begin, degrade.end),
        (Alignment.bottomCenter, Alignment.topCenter),
      );
    },
  );

  testWidgets(
    'L22a — semântica: "‹Título›, página X de Y — modo anotação"; a tinta e os enfeites fora',
    (tester) async {
      final h = tester.ensureSemantics();
      await abrirTela22(tester, livro());
      final i = t22;
      expect(
        find.bySemanticsLabel(
          '${i.livro.title}, página ${i.pagina} de ${i.totalDePaginas} '
          '— modo anotação',
        ),
        findsOneWidget,
      );
      // a página de baixo (o rodapé do leitor limpo) não chega ao leitor de tela
      expect(find.bySemanticsLabel(RegExp('^pág\\. ')), findsNothing);
      h.dispose();
    },
  );

  testWidgets(
    'L22a — dados: o grifo à mão e a elipse do banco, presos aos trechos do mundo; a tinta do pen_presets',
    (tester) async {
      await abrirTela22(tester, livro());
      final p = paginaDoModo(tester);
      final modo = _modo(tester);
      final mancha = modo.inkHighlights.single;
      expect(
        p
            .textOf(mancha.range.unit, mancha.range.from, mancha.range.to)
            .replaceAll('\u00A0', ' '),
        'olhos de Capitu',
      );
      expect(
        [
          for (final a in t22.anotacoesNaPagina)
            ((a.anchor as EpubAnchor).quote.exact, a.kind),
        ],
        unorderedEquals([
          ('olhos de Capitu', AnnotationKind.highlight),
          ('Olhos de ressaca?', AnnotationKind.drawing),
        ]),
      );
      final s = sessaoL22(tester);
      final salvos = [
        for (final d in s.drawings)
          if (d.saved != null) d,
      ];
      expect(salvos, hasLength(1), reason: 'a elipse com o risco');
      expect(salvos.single.strokes, hasLength(2));
      expect(t22.tintaNaPagina.single.strokeCount, 2);
      expect(s.color, argbOfHex(t22.mundo.caneta.penColor));
      expect(s.strokeSize, t22.mundo.caneta.strokeSize);
      expect(s.tool, AnnotationTool.pen, reason: 't22: ${t22.ferramenta}');
    },
  );
});

// ---- L22b ----------------------------------------------------------------------------------------------------

void faseL22b() => _comOLivro((livro) {
  testWidgets('L22b — geometria: os 8 ids da pílula e do Concluir', (
    tester,
  ) async {
    await abrirTela22(tester, livro());
    final ids = [
      ...kRef22.idsOfSection('ann.modePill'),
      ...kRef22.idsOfSection('ann.done'),
    ];
    expect(ids, hasLength(8));
    conferirGeometriaL22(tester, ids);
  });

  testWidgets(
    'L22b — texto: "Modo anotação", o subtítulo e "Concluir" nas baselines',
    (tester) async {
      await abrirTela22(tester, livro());
      for (final id in const [
        'ann.modePill.title',
        'ann.modePill.subtitle',
        'ann.done',
      ]) {
        conferirLinhasL22(tester, id);
      }
    },
  );

  testWidgets(
    'L22b — estilo: bordas 1,5, sombras duras, o círculo amarelo, Bricolage 15,5/800, Figtree 11,5/600 e 15/800',
    (tester) async {
      await abrirTela22(tester, livro());
      final cores = ReaderChromePalette.of(t22.mundo.ajustes.paper);
      final pilula = _caixa(tester, 'ann.modePill');
      expect(
        (pilula.color, pilula.border, pilula.shadow, pilula.shadowColor),
        (
          cores.island,
          BorderSide(width: 1.5, color: cores.border),
          AppShadows.hard3,
          cores.shadow,
        ),
      );
      expect(_caixa(tester, 'ann.modePill.iconCircle').color, AppColors.sun);
      final pronto = _caixa(tester, 'ann.done');
      expect(
        (pronto.color, pronto.border?.width, pronto.shadow),
        (AppColors.leaf, 1.5, AppShadows.hard3),
      );
      TextStyle estilo(String id) => tester
          .widget<AppText>(
            find
                .descendant(
                  of: chaveL22(id),
                  matching: find.byType(AppText),
                  matchRoot: true,
                )
                .last,
          )
          .span
          .style!;
      final titulo = estilo('ann.modePill.title');
      expect(
        (titulo.fontFamily, titulo.fontSize, titulo.fontWeight),
        (AppTextStyles.annModeTitle.fontFamily, 15.5, FontWeight.w800),
      );
      final sub = estilo('ann.modePill.subtitle');
      expect(
        (sub.fontFamily, sub.fontSize, sub.fontWeight, sub.color),
        (
          AppTextStyles.annModeSubtitle.fontFamily,
          11.5,
          FontWeight.w600,
          cores.muted,
        ),
      );
      final concluir = estilo('ann.done');
      expect(
        (concluir.fontFamily, concluir.fontSize, concluir.fontWeight),
        (AppTextStyles.annDone.fontFamily, 15.0, FontWeight.w800),
      );
    },
  );

  testWidgets(
    'L22b — semântica: os textos da pílula e "Concluir" como botão; os ícones fora',
    (tester) async {
      final h = tester.ensureSemantics();
      await abrirTela22(tester, livro());
      expect(find.bySemanticsLabel('Modo anotação'), findsOneWidget);
      expect(find.bySemanticsLabel(annotationHint), findsOneWidget);
      expect(
        tester.getSemantics(chaveL22('ann.done')),
        isSemantics(label: 'Concluir', isButton: true, hasTapAction: true),
      );
      h.dispose();
    },
  );

  testWidgets(
    'L22b — dados: o subtítulo é o da Caneta (a ferramenta do instantâneo)',
    (tester) async {
      await abrirTela22(tester, livro());
      expect(t22.ferramenta?.name, 'caneta');
      expect(sessaoL22(tester).tool, AnnotationTool.pen);
      expect(
        tester
            .widget<AppText>(chaveL22('ann.modePill.subtitle'))
            .span
            .toPlainText(),
        annotationHint,
      );
    },
  );
});

// ---- L22c ----------------------------------------------------------------------------------------------------

void faseL22c() => _comOLivro((livro) {
  testWidgets(
    'L22c — geometria: os 13 ids (a Caneta ativa na caixa visual, 12 acima)',
    (tester) async {
      await abrirTela22(tester, livro());
      final ids = kRef22.idsOfSection('ann.toolShelf').toList();
      expect(ids, hasLength(13));
      conferirGeometriaL22(tester, ids);
    },
  );

  testWidgets(
    'L22c — estilo: a Caneta ativa com a brand e a tinta do pen_presets; as outras sem troca',
    (tester) async {
      await abrirTela22(tester, livro());
      final caneta = tester.widget<AppSvg>(chaveL22('ann.toolShelf.pen.art'));
      expect(caneta.asset, AppIllustrationsLeitor.toolPenActive);
      expect(caneta.colors, {
        AppColors.lavender: instantaneoBrand(t22),
        AppColors.flame: Color(argbOfHex(t22.mundo.caneta.penColor)),
      });
      for (final id in const ['marker', 'eraser', 'lasso', 'line', 'space']) {
        expect(
          tester.widget<AppSvg>(chaveL22('ann.toolShelf.$id.art')).colors,
          isNull,
          reason: id,
        );
      }
    },
  );

  testWidgets(
    'L22c — semântica: "Ferramentas de anotação" com a Caneta marcada',
    (tester) async {
      final h = tester.ensureSemantics();
      await abrirTela22(tester, livro());
      expect(
        tester.getSemantics(chaveL22('ann.toolShelf')),
        isSemantics(label: 'Ferramentas de anotação'),
      );
      for (final (id, marcada) in const [
        ('pen', true),
        ('marker', false),
        ('eraser', false),
        ('lasso', false),
        ('line', false),
        ('space', false),
      ]) {
        expect(
          tester.getSemantics(chaveL22('ann.toolShelf.$id')),
          isSemantics(
            hasCheckedState: true,
            isChecked: marcada,
            isInMutuallyExclusiveGroup: true,
            hasTapAction: true,
          ),
          reason: id,
        );
      }
      h.dispose();
    },
  );
});

// ---- L22d ----------------------------------------------------------------------------------------------------

void faseL22d() => _comOLivro((livro) {
  testWidgets('L22d — geometria: os 24 ids da ilha', (tester) async {
    await abrirTela22(tester, livro());
    final ids = kRef22.idsOfSection('ann.island').toList();
    expect(ids, hasLength(24));
    conferirGeometriaL22(tester, ids);
  });

  testWidgets('L22d — texto: os 6 rótulos nas baselines', (tester) async {
    await abrirTela22(tester, livro());
    for (final id in const [
      'ann.island.labels.pen.pill',
      'ann.island.labels.marker',
      'ann.island.labels.eraser',
      'ann.island.labels.lasso',
      'ann.island.labels.line',
      'ann.island.labels.space',
    ]) {
      conferirLinhasL22(tester, id);
    }
  });

  testWidgets(
    'L22d — estilo: a ilha, o rótulo ativo, o tracejado, o poço, a espessura Média e Desfazer ligado',
    (tester) async {
      await abrirTela22(tester, livro());
      final cores = ReaderChromePalette.of(t22.mundo.ajustes.paper);
      final brand = instantaneoBrand(t22);
      final ilha = _caixa(tester, 'ann.island');
      expect(
        (ilha.color, ilha.border, ilha.shadow, ilha.shadowColor),
        (
          cores.island,
          BorderSide(width: 1.5, color: cores.border),
          AppShadows.hard3,
          cores.shadow,
        ),
      );
      expect(_caixa(tester, 'ann.island.labels.pen.pill').color, brand);
      TextStyle rotulo(String id) => tester
          .widget<AppText>(
            find.descendant(of: chaveL22(id), matching: find.byType(AppText)),
          )
          .span
          .style!;
      final ativo = rotulo('ann.island.labels.pen.pill');
      expect(
        (ativo.fontFamily, ativo.fontSize, ativo.fontWeight),
        (AppTextStyles.annLabelActive.fontFamily, 10.0, FontWeight.w800),
      );
      final outro = rotulo('ann.island.labels.marker');
      expect(
        (outro.fontFamily, outro.fontSize, outro.fontWeight, outro.color),
        (
          AppTextStyles.annLabel.fontFamily,
          10.0,
          FontWeight.w700,
          AppColors.labelReader,
        ),
      );
      expect(
        (tester.widget<CustomPaint>(chaveL22('ann.island.row')).painter!
                as ChromiumDashPainter)
            .color,
        AppColors.dashReader,
      );
      final anel =
          tester
                  .widget<CustomPaint>(
                    find.descendant(
                      of: chaveL22('ann.island.colorWell'),
                      matching: find.byType(CustomPaint),
                    ),
                  )
                  .painter!
              as ConicRingPainter;
      expect(anel.center, Color(argbOfHex(t22.mundo.caneta.penColor)));
      expect(_caixa(tester, 'ann.island.width.medium').color, brand);
      expect(_caixa(tester, 'ann.island.width.thin').color, isNull);
      expect(
        tester.widget<AppSvg>(chaveL22('ann.island.undo.icon')).opacity,
        isNull,
        reason: 'as 2 barras deixam o Desfazer ligado',
      );
      expect(
        tester.widget<AppSvg>(chaveL22('ann.island.redo.icon')).opacity,
        0.38,
      );
    },
  );

  testWidgets(
    'L22d — semântica: "Barra de anotação", o poço com o nome da cor, a espessura e Desfazer/Refazer',
    (tester) async {
      final h = tester.ensureSemantics();
      await abrirTela22(tester, livro());
      expect(
        tester.getSemantics(chaveL22('ann.island')),
        isSemantics(label: 'Barra de anotação'),
      );
      final nome = AnnotationIsland.colorName(
        Color(argbOfHex(t22.mundo.caneta.penColor)),
      );
      expect(nome, 'coral');
      expect(
        tester.getSemantics(chaveL22('ann.island.colorWell')),
        isSemantics(
          label: 'Cor da caneta: $nome. Toque para escolher qualquer cor',
          isButton: true,
          hasTapAction: true,
        ),
      );
      for (final (id, marcada) in const [
        ('thin', false),
        ('medium', true),
        ('thick', false),
      ]) {
        expect(
          tester.getSemantics(chaveL22('ann.island.width.$id')),
          isSemantics(
            hasCheckedState: true,
            isChecked: marcada,
            isInMutuallyExclusiveGroup: true,
            hasTapAction: true,
          ),
          reason: id,
        );
      }
      expect(
        tester.getSemantics(chaveL22('ann.island.undo')),
        // ligado: só o botão (o "indisponível" é só do desligado, como o `aria-disabled` do arquivo)
        isSemantics(label: 'Desfazer', isButton: true, hasTapAction: true),
      );
      expect(
        tester.getSemantics(chaveL22('ann.island.redo')),
        isSemantics(
          label: 'Refazer',
          isButton: true,
          hasEnabledState: true,
          isEnabled: false,
        ),
      );
      h.dispose();
    },
  );

  testWidgets(
    'L22d — dados: a espessura e a cor do pen_presets do mundo; o Desfazer pelas barras da sessão',
    (tester) async {
      await abrirTela22(tester, livro());
      final s = sessaoL22(tester);
      final caneta = t22.mundo.caneta;
      expect(caneta.strokeSize, StrokeSize.medium);
      expect(s.strokeSize, caneta.strokeSize);
      expect((s.canUndo, s.canRedo), (true, false));
    },
  );
});

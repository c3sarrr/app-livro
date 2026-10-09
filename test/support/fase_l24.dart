// G18.6 — as fases L24 (abrindo espaço, tela 24) e L24b (a nota à mão, tela 24b) pela rota real, no mundo das telas
// (D-34, D-160, R15), abertas pelo fluxo (`abrirTela24`: Anotar, o Espaço e o dedo parado 3 linhas abaixo da fresta de
// "Vá, de ressaca."; `abrirTela24b`: Anotar, com a nota salva e a Caneta), contra as medidas do arquivo:
// - geometria: os ids da página (±0,5; ±1,0 em x/w nos que dependem do texto) — o texto de cima e o de baixo pelos
//   blocos do parágrafo partido na âncora, a mancha pela caixa calculada (D-161), a tinta pelos pontos contra o
//   caminho do arquivo na caixa medida desta prancha, o abridor ou a caixa da nota pelas chaves; os trechos inline
//   linha a linha; o que muda na pílula, na prateleira e na ilha (o Espaço ativo na 24);
// - texto: as linhas de cima e as de baixo (as escondidas fora da tela), o fio de navalha, o chip, a etiqueta, a dica;
// - estilo: o abridor e a caixa (cores, bordas 1,5, raios, a sombra 2/2 da alça, as fontes), a tinta coral;
// - semântica: o "Abrindo espaço: 3 linhas", o grupo da nota, os botões, a alça e a tinta (D-31);
// - dados: o espaço do mundo no banco (a camada `space` com a tinta e a anotação `handwriting`).
import 'dart:math' as math;

import 'package:app_leitura/core/data/database/daos/annotation_daos.dart';
import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/features/reader/annotations/domain/annotation.dart';
import 'package:app_leitura/features/reader/annotations/ink/ink_stroke.dart';
import 'package:app_leitura/features/reader/annotations/ink/ink_units.dart';
import 'package:app_leitura/features/reader/annotations/space/note_ink.dart';
import 'package:app_leitura/features/reader/application/annotation_session.dart';
import 'package:app_leitura/features/reader/layout/display_page.dart';
import 'package:app_leitura/features/reader/layout/laid_block.dart';
import 'package:app_leitura/features/reader/layout/page_snapshot.dart';
import 'package:app_leitura/features/reader/layout/paginator.dart';
import 'package:app_leitura/features/reader/presentation/annotation_canvas.dart';
import 'package:app_leitura/features/reader/presentation/ink_painter.dart';
import 'package:app_leitura/features/reader/presentation/space_opener.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/telas/t24.dart';
import '../fixtures/telas/t24b.dart';
import '../fixtures/tinta_do_mundo.dart';
import '../reference/leitor/ref_tipos.dart';
import '../reference/leitor/reference_layout_24_abrindo_espaco.dart';
import '../reference/leitor/reference_layout_24b_nota_mao.dart';
import 'dados_t24.dart';
import 'load_fonts.dart';
import 'pecas_l23.dart';
import 'reader_harness.dart';

const double _desce = annotationTextShift;

/// Metade do passo de 1/100 em na letra da prancha: o que a gravação em em arredonda.
const double _quantizacao = emDaPrancha / 100 / 2;

/// A página da sessão (refeita com o espaço).
PageSnapshot paginaDaSessao(WidgetTester tester) =>
    sessaoNaTela(tester).page! as PageSnapshot;

/// O parágrafo da pág. 159 partido na âncora: o bloco, a fatia de antes e a de depois do espaço e onde a linha 0 de
/// cada uma ficaria na tela (para as linhas fora da página também).
({LaidText b, TextSlice antes, TextSlice depois, double base1, double base2})
paragrafoPartido(WidgetTester tester) {
  final p = paginaDaSessao(tester);
  final t = p.typography;
  final textos = p.page.slices.whereType<TextSlice>().toList();
  expect(p.page.slices.whereType<SpaceSlice>(), hasLength(1));
  final antes = textos[0];
  final depois = textos[1];
  expect(depois.block, antes.block, reason: 'o mesmo parágrafo, partido');
  final b = p.block(antes.block) as LaidText;
  double base(TextSlice s) =>
      t.topInset + s.y + _desce - b.lines[s.firstLine].top;
  return (
    b: b,
    antes: antes,
    depois: depois,
    base1: base(antes),
    base2: base(depois),
  );
}

/// As caixas de [unit] [from]–[to] por linha (a união das caixas de cada linha), 30 abaixo.
List<TextLineBox> _porLinha(DisplayPage p, int unit, int from, int to) {
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

/// O trecho [texto] da página da sessão, por linha, na tela.
List<TextLineBox> trechoDaSessao(WidgetTester tester, String texto) {
  final p = paginaDaSessao(tester);
  final t = p.item.text.replaceAll(' ', ' ');
  final a = t.indexOf(texto);
  expect(a, isNot(-1), reason: texto);
  return _porLinha(p, p.spine, a, a + texto.length);
}

/// Os desenhos da página na sessão: a elipse e o risco, a onda e as 2 barras do duplo (coordenadas do leitor limpo).
({InkStroke elipse, InkStroke risco, InkStroke onda, List<InkStroke> barras})
desenhosDaSessao(WidgetTester tester) {
  final s = sessaoNaTela(tester);
  final canetas = <List<InkStroke>>[];
  final barras = <InkStroke>[];
  for (final d in s.drawings) {
    final pen = [
      for (final x in d.strokes)
        if (InkTool.fromCode(x.stroke.tool) == InkTool.pen) x.stroke,
    ];
    if (pen.isNotEmpty) canetas.add(pen);
    barras.addAll([
      for (final x in d.strokes)
        if (InkTool.fromCode(x.stroke.tool) == InkTool.line) x.stroke,
    ]);
  }
  final elipse = canetas.singleWhere((c) => c.length == 2);
  final onda = canetas.singleWhere((c) => c.length == 1);
  expect(barras, hasLength(2));
  barras.sort((a, b) => a.points.first.y.compareTo(b.points.first.y));
  return (
    elipse: elipse[0],
    risco: elipse[1],
    onda: onda.single,
    barras: barras,
  );
}

List<Offset> _naTela(InkStroke s) => [
  for (final p in s.points) Offset(p.x, p.y + _desce),
];

double _desvio(List<Offset> pontos, List<Offset> caminho) =>
    pontos.map((p) => distanciaALinha(p, caminho)).reduce(math.max);

Rect _capsula(InkStroke s) {
  final r = dpOfCentiMm(s.widthCentiMm) / 2;
  final pts = _naTela(s);
  return Rect.fromPoints(pts.first, pts.last).inflate(r);
}

/// Os trechos inline da página e o texto de cada um (sem o prefixo da prancha).
const Map<String, String> _inline = {
  'page.text.handHighlight': 'olhos de Capitu',
  'page.text.circled': 'Olhos de ressaca?',
  'page.textBelow.wavy': 'fluido misterioso',
  'page.textBelow.doubleUnderline': 'a vaga que se retira',
};

/// A geometria da página da prancha [ref]: os ids que só existem nela vão por [proprios] (as chaves do app); o
/// resto (o texto, a mancha, a tinta e os trechos) é medido aqui.
void conferirPaginaL24(
  WidgetTester tester,
  LeitorRefPrancha ref, {
  required Set<String> proprios,
}) {
  final pre = ref.prefix;
  final falhas = <String>[];
  void confere(String id, String o, double g, double e, double tol) {
    if ((g - e).abs() > tol + 1e-6) {
      falhas.add('$id.$o: ${g.toStringAsFixed(2)} ≠ ${e.toStringAsFixed(2)}');
    }
  }

  void retangulo(String id, Rect m) {
    final e = ref.elements[id]!;
    final r = e.visual ?? e.rect;
    final tx = ref.textDependentX.contains(id) ? 1.0 : 0.5;
    confere(id, 'x', m.left, r.left, tx);
    confere(id, 'y', m.top, r.top, 0.5);
    confere(id, 'w', m.width, r.width, tx);
    confere(id, 'h', m.height, r.height, 0.5);
  }

  final p = paginaDaSessao(tester);
  final t = p.typography;
  final (:b, :antes, :depois, :base1, :base2) = paragrafoPartido(tester);
  final s = sessaoNaTela(tester);
  final tinta = desenhosDaSessao(tester);
  Rect caixa(String id) => ref.elements['$pre.$id']!.rect;
  for (final id in ref.idsOfSection('$pre.page')) {
    final semPre = id.substring(pre.length + 1);
    switch (semPre) {
      case 'page.text':
        // de cima: do topo da caixa da página até o pé da linha da âncora
        retangulo(
          id,
          Rect.fromLTRB(
            t.sideMargin + b.left,
            tester.getRect(chaveL23('ann.page')).top,
            t.sideMargin + b.left + b.width,
            base1 + b.lines[antes.lastLine].bottom,
          ),
        );
      case 'page.textBelow':
        // de baixo: da 1ª linha depois do espaço até o pé do parágrafo (as escondidas também)
        retangulo(
          id,
          Rect.fromLTRB(
            t.sideMargin + b.left,
            base2 + b.lines[depois.firstLine].top,
            t.sideMargin + b.left + b.width,
            base2 + b.lines.last.bottom,
          ),
        );
      case 'page.text.handHighlight.stroke':
        final m = handHighlightBoxes(p, s.paintedInkHighlights!);
        expect(m, hasLength(1), reason: 'a mancha numa linha');
        retangulo(id, m.single.box.shift(const Offset(0, _desce)));
      case 'page.text.circled.ellipse':
        final c = caixa(semPre);
        final d = _desvio(
          _naTela(tinta.elipse),
          amostrarCaminho(
            caminhoDaElipse,
            origem: c.topLeft,
            sx: c.width / 100,
            sy: c.height / 40,
          ),
        );
        if (d > 0.5 + _quantizacao) falhas.add('$id: desvio $d');
      case 'page.text.circled.flourish':
        final d = _desvio(
          _naTela(tinta.risco),
          amostrarCaminho(caminhoDoRisco, origem: caixa(semPre).topLeft),
        );
        if (d > 0.5 + _quantizacao) falhas.add('$id: desvio $d');
      case 'page.textBelow.wavy.wave':
        final d = _desvio(
          _naTela(tinta.onda),
          amostrarCaminho(
            caminhoDaOnda,
            origem: caixa(semPre).topLeft,
            ateX: caixa('page.textBelow.wavy').width,
          ),
        );
        if (d > 0.5 + _quantizacao) falhas.add('$id: desvio $d');
      case 'page.textBelow.doubleUnderline.line1':
        retangulo(id, _capsula(tinta.barras[0]));
      case 'page.textBelow.doubleUnderline.line2':
        retangulo(id, _capsula(tinta.barras[1]));
      default:
        if (!proprios.contains(semPre)) {
          falhas.add('$id: sem medida');
          continue;
        }
        final f = chaveL23(chaveDoApp(ref, id));
        if (f.evaluate().isEmpty) {
          falhas.add('$id: sem widget');
          continue;
        }
        retangulo(id, tester.getRect(f.first));
    }
  }
  // os trechos inline: cada linha (a área do texto) e as bordas
  for (final MapEntry(key: semPre, value: texto) in _inline.entries) {
    final id = '$pre.$semPre';
    final e = ref.elements[id]!;
    final got = trechoDaSessao(tester, texto);
    expect(got, hasLength(e.lines.length), reason: id);
    for (var i = 0; i < got.length; i++) {
      confere(
        id,
        'linha $i baseline',
        got[i].baseline,
        e.lines[i].baseline,
        .5,
      );
      confere(id, 'linha $i início', got[i].rect.left, e.lines[i].left, 1);
      confere(id, 'linha $i fim', got[i].rect.right, e.lines[i].right, 1);
    }
    retangulo(
      id,
      Rect.fromLTRB(
        got.map((l) => l.rect.left).reduce(math.min),
        got.first.textTop,
        got.map((l) => l.rect.right).reduce(math.max),
        got.last.textBottom,
      ),
    );
  }
  expect(falhas, isEmpty, reason: falhas.join('\n'));
}

/// O texto da prancha [ref]: as linhas de cima (8) e as de baixo (14, as que passam do pé escondidas), nas
/// baselines, e o fio de navalha das duas.
void conferirTextoL24(WidgetTester tester, LeitorRefPrancha ref) {
  final pre = ref.prefix;
  final p = paginaDaSessao(tester);
  final t = p.typography;
  final (:b, antes: _, :depois, :base1, :base2) = paragrafoPartido(tester);
  final cima = ref.elements['$pre.page.text']!.linesAll;
  final baixo = ref.elements['$pre.page.textBelow']!.linesAll;
  expect(b.lines, hasLength(cima.length + baixo.length));
  expect(depois.firstLine, cima.length);
  final fundo = tester.getRect(chaveL23('ann.page')).bottom;
  String texto(LaidLine l) =>
      p.item.text.substring(l.start, l.end).replaceAll(' ', ' ').trimRight();
  for (var l = 0; l < b.lines.length; l++) {
    final line = b.lines[l];
    final (e, base) = l < cima.length
        ? (cima[l], base1)
        : (baixo[l - cima.length], base2);
    expect(texto(line), e.text, reason: 'linha ${l + 1}');
    expect(
      base + line.baseline,
      moreOrLessEquals(e.baseline, epsilon: 0.5),
      reason: e.text,
    );
    // as que passam do pé da tela ficam escondidas
    expect(base + line.top >= fundo, e.hidden, reason: 'linha ${l + 1}');
  }
  final direita = t.sideMargin + t.contentWidth;
  for (final k in ref.knifeEdges) {
    final l = k.id.endsWith('textBelow')
        ? cima.length + k.line - 1
        : k.line - 1;
    final line = b.lines[l];
    expect(texto(line), k.text);
    final caixas = p.boxesOf(p.spine, line.start, line.end);
    // a linha escondida (fora da página) não tem caixas: a quebra dela já foi conferida pelo texto de cada linha
    if (caixas.isEmpty) continue;
    final fim = caixas.map((c) => c.rect.right).reduce(math.max);
    expect(direita - fim, moreOrLessEquals(k.slack, epsilon: 1));
  }
}

void _comOLivro(
  Future<LivroNaEstante> Function() abrir,
  void Function(LivroNaEstante Function() livro) testes,
) {
  setUpAll(loadAppFonts);
  late LivroNaEstante livro;
  setUp(() async => livro = await abrir());
  tearDown(() async => livro.close());
  testes(() => livro);
}

/// Os ids do abridor (a chave do app de cada um).
const Set<String> _doAbridor = {
  'page',
  'page.spaceOpener',
  'page.spaceOpener.area',
  'page.spaceOpener.seam',
  'page.spaceOpener.seamDotLeft',
  'page.spaceOpener.seamDotRight',
  'page.spaceOpener.trail',
  'page.spaceOpener.finger',
  'page.spaceOpener.sizeChip',
  'page.spaceOpener.sizeChip.icon',
};

/// Os ids da caixa da nota (a chave do app de cada um).
const Set<String> _daNota = {
  'page',
  'page.handNote',
  'page.handNote.tag',
  'page.handNote.tag.icon',
  'page.handNote.rule1',
  'page.handNote.rule2',
  'page.handNote.actions',
  'page.handNote.actions.collapse',
  'page.handNote.actions.collapse.icon',
  'page.handNote.actions.delete',
  'page.handNote.actions.delete.icon',
  'page.handNote.ink',
  'page.handNote.hint',
  'page.handNote.handle',
  'page.handNote.handle.bar1',
  'page.handNote.handle.bar2',
};

// ---- L24 -------------------------------------------------------------------------------------------------------

void faseL24() => _comOLivro(livroDaTela24, (livro) {
  testWidgets(
    'L24 — geometria: os 18 ids da página (o abridor, o texto de cima e o de baixo, a tinta) e os trechos',
    (tester) async {
      await abrirTela24(tester, livro());
      expect(kRef24.idsOfSection('sp.page'), hasLength(18));
      conferirPaginaL24(tester, kRef24, proprios: _doAbridor);
    },
  );

  testWidgets(
    'L24 — o que muda da 22: a pílula (subtítulo), o Espaço 12 acima, a Caneta embaixo e o rótulo',
    (tester) async {
      await abrirTela24(tester, livro());
      conferirGeometriaL23(tester, kRef24, const [
        'sp.modePill',
        'sp.modePill.texts',
        'sp.modePill.title',
        'sp.modePill.subtitle',
        'sp.toolShelf.pen',
        'sp.toolShelf.space',
        'sp.island.labels.space.pill',
      ]);
    },
  );

  testWidgets(
    'L24 — texto: as 8 linhas de cima, as 14 de baixo (7 escondidas), o chip e o subtítulo',
    (tester) async {
      await abrirTela24(tester, livro());
      conferirTextoL24(tester, kRef24);
      conferirLinhasL23(tester, kRef24, 'sp.page.spaceOpener.sizeChip');
      conferirLinhasL23(tester, kRef24, 'sp.modePill.subtitle');
    },
  );

  testWidgets(
    'L24 — estilo: o abridor no papel (violeta, hachura, dedo lavanda), o chip na tinta, a tinta coral',
    (tester) async {
      await abrirTela24(tester, livro());
      final abridor = tester.widget<SpaceOpener>(find.byType(SpaceOpener));
      expect(abridor.colors, OpenerColors.paper);
      expect(abridor.colors.line, AppColors.violet);
      final chip =
          tester
                  .widget<Container>(chaveL23('ann.page.spaceOpener.sizeChip'))
                  .decoration!
              as BoxDecoration;
      expect(
        (chip.color, chip.borderRadius),
        (AppColors.ink, BorderRadius.circular(9)),
      );
      final letras = tester
          .widget<AppText>(chaveL23('ann.page.spaceOpener.sizeChip.text'))
          .span
          .style!;
      expect(
        (letras.fontSize, letras.fontWeight, letras.color),
        (12.5, FontWeight.w800, AppColors.paper),
      );
      final tinta = desenhosDaSessao(tester);
      for (final s in [tinta.elipse, tinta.onda, ...tinta.barras]) {
        expect(s.argb, tintaCoral);
      }
    },
  );

  testWidgets(
    'L24 — semântica: a página e o "Abrindo espaço: 3 linhas" (status)',
    (tester) async {
      final h = tester.ensureSemantics();
      await abrirTela24(tester, livro());
      expect(
        find.bySemanticsLabel(
          'Dom Casmurro, página 159 de 256 — modo anotação',
        ),
        findsOneWidget,
      );
      expect(
        tester.getSemantics(chaveL23('ann.page.spaceOpener')),
        matchesSemantics(label: 'Abrindo espaço: 3 linhas', isLiveRegion: true),
      );
      h.dispose();
    },
  );

  testWidgets(
    'L24 — dados: o Espaço do instantâneo, 3 linhas, na âncora de "Vá, de ressaca."; nada gravado ainda',
    (tester) async {
      await abrirTela24(tester, livro());
      final s = sessaoNaTela(tester);
      expect(t24.abrindoEspacoLinhas, s.opening.value!.lines);
      final texto = s.anchors.textOf(s.opening.value!.seam.unit)!;
      expect(
        texto.substring(0, s.opening.value!.seam.at),
        endsWith('Vá, de ressaca.'),
      );
      final gravados = await tester.runAsync(
        () => InkLayersDao(livro().db).liveSpacesForBook(livro().book.id),
      );
      expect(gravados, isEmpty);
    },
  );
});

// ---- L24b ------------------------------------------------------------------------------------------------------

void faseL24b() => _comOLivro(livroDaTela24b, (livro) {
  testWidgets(
    'L24b — geometria: os 24 ids da página (a caixa da nota e as peças dela, o texto, a tinta) e os trechos',
    (tester) async {
      await abrirTela24b(tester, livro());
      expect(kRef24b.idsOfSection('hn.page'), hasLength(24));
      conferirPaginaL24(tester, kRef24b, proprios: _daNota);
    },
  );

  testWidgets(
    'L24b — a tinta da nota é a do arquivo na caixa (desvio ≤ 0,5 px), por dentro da borda',
    (tester) async {
      await abrirTela24b(tester, livro());
      final s = sessaoNaTela(tester);
      final nota = s.notes.single;
      final quadro = s.noteInkFrame(nota.id)!.shift(const Offset(0, _desce));
      expect(
        quadro.topLeft,
        offsetMoreOrLessEquals(const Offset(29.5, 435.58), epsilon: 0.5),
      );
      final tracos = s.noteStrokes(nota.id);
      final (:caminhos, centro: _, raio: _) = caminhosDaNotaAMao();
      final subcaminhos = [for (final d in caminhos) ...tracosDoCaminho(d)];
      var pior = 0.0;
      for (var i = 0; i < subcaminhos.length; i++) {
        final caminho = [
          for (final q in amostrarCaminho(
            subcaminhos[i],
            origem: const Offset(0, sobraDaNotaAMao),
            sx: escalaDaNotaAMao,
            sy: escalaDaNotaAMao,
          ))
            q + quadro.topLeft,
        ];
        final pts = [
          for (final p in fromNote(tracos[i], quadro).points) Offset(p.x, p.y),
        ];
        pior = math.max(pior, _desvio(pts, caminho));
      }
      expect(pior, lessThanOrEqualTo(0.5));
      expect(minLinesFor(tracos), 3, reason: 'a 2ª onda passa da 2ª pauta');
    },
  );

  testWidgets(
    'L24b — texto: as linhas de cima e de baixo, a etiqueta e a dica',
    (tester) async {
      await abrirTela24b(tester, livro());
      conferirTextoL24(tester, kRef24b);
      conferirLinhasL23(tester, kRef24b, 'hn.page.handNote.tag');
      conferirLinhasL23(tester, kRef24b, 'hn.page.handNote.hint');
    },
  );

  testWidgets(
    'L24b — estilo: o fundo, o tracejado e as pautas da caixa; a etiqueta, os botões e a alça; a tinta coral',
    (tester) async {
      await abrirTela24b(tester, livro());
      final s = sessaoNaTela(tester);
      final nota = s.notes.single;
      final g = TestRecordingCanvas();
      (tester.widget<CustomPaint>(chaveL23('ann.canvas.page')).painter!
              as AnnotationPagePainter)
          .paint(g, const Size(390, 844));
      Iterable<(Object, int)> chamadas(Symbol nome) => [
        for (final c in g.invocations)
          if (c.invocation.memberName == nome)
            (
              c.invocation.positionalArguments[0],
              (c.invocation.positionalArguments[1] as Paint).color.toARGB32(),
            ),
      ];
      // o fundo #FFFDF8 com o raio 18 na caixa da sessão; as 2 pautas #EFE5D3
      final fundo = chamadas(#drawRRect)
          .where((c) => c.$2 == AppColors.paperWhite.toARGB32());
      expect(fundo, hasLength(1));
      final rr = fundo.single.$1 as RRect;
      expect(rr.outerRect, s.noteBox(nota.id));
      expect(rr.tlRadiusX, 18, reason: 'o raio 18 da prancha');
      expect(
        chamadas(#drawRect).where((c) => c.$2 == AppColors.noteRule.toARGB32()),
        hasLength(2),
      );
      // a etiqueta, os botões e a alça
      final tag =
          tester
                  .widget<Container>(chaveL23('ann.page.handNote.tag'))
                  .decoration!
              as BoxDecoration;
      expect(
        (tag.color, tag.border),
        (AppColors.sun, Border.all(width: 1.5, color: AppColors.ink)),
      );
      for (final id in const ['collapse', 'delete']) {
        final b =
            tester
                    .widget<Container>(
                      chaveL23('ann.page.handNote.actions.$id.box'),
                    )
                    .decoration!
                as BoxDecoration;
        expect(
          (b.color, b.shape, b.border),
          (
            AppColors.surface,
            BoxShape.circle,
            Border.all(width: 1.5, color: AppColors.ink),
          ),
        );
      }
      final alca =
          tester
                  .widget<Container>(chaveL23('ann.page.handNote.handle.box'))
                  .decoration!
              as BoxDecoration;
      expect(alca.boxShadow!.single.offset, const Offset(2, 2));
      expect(alca.boxShadow!.single.blurRadius, 0);
      final dica = tester
          .widget<AppText>(chaveL23('ann.page.handNote.hint'))
          .span
          .style!;
      expect(
        (dica.fontSize, dica.fontWeight, dica.color),
        (11.0, FontWeight.w700, AppColors.readerFooter),
      );
      for (final x in s.noteStrokes(nota.id)) {
        expect((x.argb, x.widthCentiMm), (tintaCoral, centiMmOfDp(2.2)));
      }
    },
  );

  testWidgets('L24b — semântica: o grupo, os botões, a alça e a tinta (D-31)', (
    tester,
  ) async {
    final h = tester.ensureSemantics();
    await abrirTela24b(tester, livro());
    // pela árvore do leitor de tela (a página do leitor limpo, embaixo do modo, fica bloqueada)
    for (final rotulo in const [
      'Nota à mão, depois de “Vá, de ressaca.”',
      'Recolher a nota',
      'Apagar a nota',
      'Arrastar para mudar a altura do espaço',
      'Nota à mão, 20 de setembro',
    ]) {
      expect(find.semantics.byLabel(rotulo), findsOne, reason: rotulo);
    }
    expect(
      tester.getSemantics(chaveL23('ann.page.handNote.ink')),
      matchesSemantics(label: 'Nota à mão, 20 de setembro', isImage: true),
    );
    h.dispose();
  });

  testWidgets(
    'L24b — dados: a camada `space` do mundo (3 linhas, aberta, a tinta) e a anotação `handwriting`',
    (tester) async {
      await abrirTela24b(tester, livro());
      final db = livro().db;
      final camadas = await tester.runAsync(
        () => InkLayersDao(db).liveSpacesForBook(livro().book.id),
      );
      final c = camadas!.single;
      expect(
        (c.spaceLines, c.collapsed, c.strokeCount),
        (3, false, notaAMaoDoMundo.strokeCount),
      );
      final notas = await tester.runAsync(
        () => AnnotationsDao(db).handwritingOfLayers([c.id]),
      );
      final a = notas!.single;
      expect(a.kind, AnnotationKind.handwriting);
      final doMundo = t24b.anotacoesNaPagina.singleWhere(
        (x) => x.kind == AnnotationKind.handwriting,
      );
      expect((a.id, a.groupId), (doMundo.id, doMundo.groupId));
      expect(sessaoNaTela(tester).notes.single.id, c.id);
    },
  );
});

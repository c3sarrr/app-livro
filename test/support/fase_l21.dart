// G13.5 — as fases L21a (página: grifo, seleção, alças, âncora da barra; e o rodapé) e L21b (a barra de ações): a
// tela pela rota real, no mundo da tela 21 (D-34), com a seleção feita pelos gestos, contra as medidas do arquivo:
// - geometria de todos os ids das seções (±0,5; ±1,0 em x/w nos que dependem do texto) e os trechos inline (grifo e
//   seleção) linha a linha;
// - texto: as 19 linhas da página (D-55) e os 5 textos da barra, com as baselines;
// - estilo: alças, fundo do grifo (faixa de 12–92 % na cor a 85 %), seleção (brand a 62 %), a barra;
// - semântica: um só "Trecho selecionado" com o texto (D-57), os rótulos da barra, as alças fora da árvore;
// - dados: a seleção é a do instantâneo e o grifo pintado é o do mundo, achado pela citação.
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/widgets/neo_box.dart';
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:app_leitura/features/reader/layout/display_page.dart';
import 'package:app_leitura/features/reader/layout/laid_block.dart';
import 'package:app_leitura/features/reader/layout/paginator.dart';
import 'package:app_leitura/features/reader/presentation/page_marks.dart';
import 'package:app_leitura/features/reader/presentation/reader_chrome_palette.dart';
import 'package:app_leitura/features/reader/presentation/reader_page_view.dart';
import 'package:flutter/services.dart' show SystemChannels;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/telas/instantaneo.dart';
import '../reference/leitor/ref_tipos.dart';
import 'dados_t21.dart';
import 'fase_l20.dart' show instantaneoBrand;
import 'load_fonts.dart';
import 'reader_harness.dart';

Finder _key(String k) => find.byKey(ValueKey<String>(k));

/// A prancha usa `r21.page`/`r21.footer*`; a tela, os da 19 (é a mesma página). O resto tem as próprias chaves.
String _chave(String id) =>
    id == 'r21.page' ? 'r19.page' : id.replaceFirst('r21.footer', 'r19.footer');

/// As seções conferidas: a página e o rodapé (L21a) e a barra (L21b). O `orphanLabel` (inline) não existe no app
/// (D-57): a frase que o arquivo marca como "sem lugar" é texto comum na página.
const List<String> secoesL21 = ['r21.page', 'r21.footer', 'r21.toolbar'];

ReaderPagesPainter _pintor(WidgetTester tester) => tester
    .widgetList<CustomPaint>(
      find.descendant(
        of: find.byType(ReaderPageView),
        matching: find.byType(CustomPaint),
      ),
    )
    .map((c) => c.painter)
    .whereType<ReaderPagesPainter>()
    .single;

/// Grava os fundos que o pintor desenha.
final class _Tela implements ui.Canvas {
  final fundos = <(RRect, Color)>[];
  final cortes = <Rect>[];

  @override
  void drawRRect(RRect rrect, Paint paint) => fundos.add((rrect, paint.color));

  @override
  void clipRect(
    Rect rect, {
    ui.ClipOp clipOp = ui.ClipOp.intersect,
    bool doAntiAlias = true,
  }) => cortes.add(rect);

  @override
  Float64List getTransform() => Float64List(16);

  @override
  Object? noSuchMethod(Invocation invocation) => null;
}

void faseL21({
  required String nome,
  required LeitorRefPrancha ref,
  required InstantaneoDoLeitor instantaneo,
  ReaderPaper papel = ReaderPaper.creme,
}) {
  setUpAll(loadAppFonts);

  late LivroNaEstante livro;
  setUp(() async => livro = await livroDaTela21(papel: papel));
  tearDown(() async => livro.close());

  final cores = ReaderChromePalette.of(papel);

  /// O retângulo medido na tela para o id da prancha (o texto da página: o parágrafo inteiro, como na L19).
  Rect medido(WidgetTester tester, String id) {
    if (id == 'r21.page.text') {
      final p = paginaNaTela(tester);
      final s = p.page.slices.first as TextSlice;
      final b = p.block(s.block) as LaidText;
      final t = p.typography;
      return Rect.fromLTWH(
        t.sideMargin + b.left,
        t.topInset + s.y,
        b.width,
        b.lines.last.bottom,
      );
    }
    return tester.getRect(_key(_chave(id)));
  }

  /// O trecho [r] por linha: a área do texto (onde o fundo é pintado), a baseline e as bordas.
  List<TextLineBox> porLinha(WidgetTester tester, ReaderRange r) {
    final caixas = paginaNaTela(tester).boxesOf(r.unit, r.from, r.to);
    final linhas = <double, TextLineBox>{};
    for (final c in caixas) {
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
    return linhas.values.toList()
      ..sort((a, b) => a.baseline.compareTo(b.baseline));
  }

  PaintedHighlight grifo(WidgetTester tester) =>
      _pintor(tester).highlights!
          .highlightsIn(paginaNaTela(tester).shown!)
          .single;

  testWidgets(
    '$nome — geometria: todos os ids das seções e os trechos inline',
    (tester) async {
      await abrirTela21(tester, livro);
      final ids = [for (final s in secoesL21) ...ref.idsOfSection(s)];
      expect(ids, hasLength(12 + 22));
      final falhas = <String>[];
      void confere(String id, String o, double g, double e, double tol) {
        if ((g - e).abs() > tol + 1e-6) {
          falhas.add(
            '$id.$o: ${g.toStringAsFixed(2)} ≠ ${e.toStringAsFixed(2)}',
          );
        }
      }

      for (final id in ids) {
        final m = medido(tester, id);
        final r = ref.elements[id]!.rect;
        final tolX = ref.textDependentX.contains(id) ? 1.0 : 0.5;
        confere(id, 'x', m.left, r.left, tolX);
        confere(id, 'y', m.top, r.top, 0.5);
        confere(id, 'w', m.width, r.width, tolX);
        confere(id, 'h', m.height, r.height, 0.5);
      }
      // os trechos inline: o retângulo de cada linha (a área do texto) e as bordas
      final sel = _pintor(tester).selection!.value!;
      for (final (id, r) in [
        ('r21.page.text.highlight', grifo(tester).range),
        ('r21.page.text.selection', sel),
      ]) {
        final e = ref.elements[id]!;
        final got = porLinha(tester, r);
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
          got.map((l) => l.rect.left).reduce((a, b) => a < b ? a : b),
          got.first.textTop,
          got.map((l) => l.rect.right).reduce((a, b) => a > b ? a : b),
          got.last.textBottom,
        );
        confere(id, 'x', uniao.left, e.rect.left, 1);
        confere(id, 'y', uniao.top, e.rect.top, 0.5);
        confere(id, 'w', uniao.width, e.rect.width, 1);
        confere(id, 'h', uniao.height, e.rect.height, 0.5);
      }
      expect(falhas, isEmpty, reason: falhas.join('\n'));
    },
  );

  testWidgets(
    '$nome — texto: as 19 linhas da página e os 5 da barra, com as baselines',
    (tester) async {
      await abrirTela21(tester, livro);
      final p = paginaNaTela(tester);
      final s = p.page.slices.first as TextSlice;
      final b = p.block(s.block) as LaidText;
      final todas = ref.elements['r21.page.text']!.linesAll;
      final base = p.typography.topInset + s.y - b.lines[s.firstLine].top;
      expect(s.lastLine - s.firstLine + 1, 19, reason: 'D-55: 19 linhas');
      for (var l = s.firstLine; l <= s.lastLine; l++) {
        final line = b.lines[l];
        final e = todas[l - s.firstLine];
        expect(p.item.text.substring(line.start, line.end).trimRight(), e.text);
        expect(
          base + line.baseline,
          moreOrLessEquals(e.baseline, epsilon: 0.5),
          reason: e.text,
        );
      }
      for (final id in const [
        'r21.toolbar.colors.label',
        'r21.toolbar.actions.note',
        'r21.toolbar.actions.copy',
        'r21.toolbar.actions.share',
        'r21.toolbar.actions.search',
      ]) {
        final e = ref.elements[id]!.lines.single;
        final r = tester.renderObject<RenderAppText>(
          find
              .descendant(
                of: _key(id),
                matching: find.byType(AppText),
                matchRoot: true,
              )
              .last,
        );
        final got = r.debugLines().single;
        expect(got.text, e.text, reason: id);
        expect(
          got.baseline,
          moreOrLessEquals(e.baseline, epsilon: 0.5),
          reason: id,
        );
        expect(got.left, moreOrLessEquals(e.left, epsilon: 1), reason: id);
        expect(got.right, moreOrLessEquals(e.right, epsilon: 1), reason: id);
      }
    },
  );

  testWidgets('$nome — estilo: alças, fundo do grifo, seleção e a barra', (
    tester,
  ) async {
    await abrirTela21(tester, livro);
    for (final k in const [
      'r21.page.text.handleStart.stem',
      'r21.page.text.handleEnd.stem',
    ]) {
      expect(
        tester
            .widget<ColoredBox>(
              find.descendant(of: _key(k), matching: find.byType(ColoredBox)),
            )
            .color,
        AppColors.violet,
      );
    }
    final bola = tester.widget<DecoratedBox>(
      find.descendant(
        of: _key('r21.page.text.handleStart.knob'),
        matching: find.byType(DecoratedBox),
      ),
    );
    expect(
      bola.decoration,
      const BoxDecoration(color: AppColors.violet, shape: BoxShape.circle),
    );
    // o pintor da tela: o grifo e a seleção por trás das letras, cada um na sua faixa e na sua cor
    final tela = _Tela();
    _pintor(tester).paint(tela, const Size(390, 844));
    final g = grifo(tester);
    final linhasDoGrifo = porLinha(tester, g.range);
    final amarelo = AppColors.sun.withValues(alpha: .85).toARGB32();
    final doGrifo = [
      for (final (rr, c) in tela.fundos)
        if (c.toARGB32() == amarelo) rr,
    ];
    expect(doGrifo, hasLength(linhasDoGrifo.length));
    for (var i = 0; i < doGrifo.length; i++) {
      final l = linhasDoGrifo[i];
      expect(doGrifo[i].top, moreOrLessEquals(l.textTop, epsilon: 1e-6));
      expect(doGrifo[i].bottom, moreOrLessEquals(l.textBottom, epsilon: 1e-6));
      expect(doGrifo[i].tlRadius, const Radius.circular(3));
      final area = l.textBottom - l.textTop;
      expect(
        tela.cortes.any(
          (c) =>
              (c.top - (l.textTop + .12 * area)).abs() < 1e-6 &&
              (c.bottom - (l.textTop + .92 * area)).abs() < 1e-6,
        ),
        isTrue,
        reason: 'a faixa de 12–92 % da linha $i',
      );
    }
    final lavanda = instantaneoBrand(instantaneo)
        .withValues(alpha: .62)
        .toARGB32();
    final daSelecao = [
      for (final (rr, c) in tela.fundos)
        if (c.toARGB32() == lavanda) rr,
    ];
    expect(daSelecao, hasLength(3));
    expect(daSelecao.first.tlRadius, const Radius.circular(2));
    expect(daSelecao.first.top, moreOrLessEquals(92 + 390.27, epsilon: 0.5));
    // a barra
    final barra = tester.widget<NeoBox>(_key('r21.toolbar'));
    expect(
      (
        barra.color,
        barra.border,
        barra.radius,
        barra.shadow,
        barra.shadowColor,
      ),
      (
        cores.island,
        BorderSide(width: 1.5, color: cores.border),
        BorderRadius.circular(22),
        const Offset(3, 3),
        cores.shadow,
      ),
    );
    final grifar = tester
        .widget<AppText>(_key('r21.toolbar.colors.label'))
        .span
        .style!;
    expect(
      (
        grifar.fontFamily,
        grifar.fontSize,
        grifar.fontWeight,
        grifar.letterSpacing,
        grifar.color,
      ),
      ('Figtree', 11.0, FontWeight.w800, 1.2, cores.label),
    );
  });

  testWidgets(
    '$nome — semântica: um só "Trecho selecionado" com o texto, a barra e as alças de fora',
    (tester) async {
      final h = tester.ensureSemantics();
      await abrirTela21(tester, livro);
      expect(find.bySemanticsLabel('Trecho selecionado'), findsOneWidget);
      expect(
        tester.getSemantics(_key('r21.page.text.selection')),
        isSemantics(
          label: 'Trecho selecionado',
          value: instantaneo.selecao!.texto,
        ),
      );
      expect(
        find.bySemanticsLabel('Ações para o trecho selecionado'),
        findsOneWidget,
      );
      for (final r in const [
        'Grifar em amarelo',
        'Grifar em rosa',
        'Grifar em verde',
        'Grifar em lavanda',
        'Escolher outra cor',
        'Sublinhar',
        'Nota',
        'Copiar',
        'Compartilhar',
        'Buscar',
      ]) {
        expect(find.bySemanticsLabel(r), findsOneWidget, reason: r);
      }
      h.dispose();
    },
  );

  testWidgets(
    '$nome — dados: a seleção do instantâneo e o grifo do mundo, achado pela citação',
    (tester) async {
      await abrirTela21(tester, livro);
      final p = paginaNaTela(tester);
      final sel = _pintor(tester).selection!.value!;
      expect(p.textOf(sel.unit, sel.from, sel.to), instantaneo.selecao!.texto);
      final g = grifo(tester);
      expect(
        p.textOf(g.range.unit, g.range.from, g.range.to),
        'aqueles olhos de Capitu',
      );
      expect(
        (g.color, g.style),
        (AppColors.sun, instantaneo.anotacoesNaPagina.single.style),
      );
      final rodape = tester
          .widget<AppText>(_key('r19.footer.pageLabel'))
          .span
          .toPlainText();
      expect(
        rodape,
        'pág. ${instantaneo.pagina} de ${instantaneo.totalDePaginas}',
      );
      // Copiar: a citação da D-39, letra por letra
      String? copiado;
      final mensageiro =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            ..setMockMethodCallHandler(SystemChannels.platform, (call) async {
              if (call.method == 'Clipboard.setData') {
                copiado = (call.arguments as Map)['text'] as String;
              }
              return null;
            });
      addTearDown(
        () =>
            mensageiro.setMockMethodCallHandler(SystemChannels.platform, null),
      );
      await tester.tap(_key('r21.toolbar.actions.copy'));
      await tester.pump();
      expect(
        copiado,
        '“como a vaga que se retira da praia, nos dias de ressaca.”\n'
        '— Machado de Assis, Dom Casmurro (pág. 159)',
      );
    },
  );
}

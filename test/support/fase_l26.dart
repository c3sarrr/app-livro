// G14.5 — a fase L26 (tela 26, a folha de ajustes): a tela pela rota real, no mundo de referência (D-34) com o ajuste
// da conta do mundo (passo 4, Literata, Creme, Médio, Média), com os controles abertos e "Aa Fonte" tocado, contra as
// medidas do arquivo:
// - geometria de todos os ids de `rs.page`, `rs.livePill` e `rs.sheet` (83, sem o inline do título), com as
//   tolerâncias da v1 (±0,5; ±1,0 em x/w nos que dependem do texto); a pílula pela caixa visual (`translateX`);
// - texto: as 14 linhas do parágrafo da prévia (as 6 de cima à vista, as outras atrás do papel do corte) e os textos
//   da folha, com as baselines;
// - estilo: folha, alça, pontos, cartões, segmentados, rótulos, título e a pílula;
// - semântica: o diálogo, a prévia, os botões, o controle deslizante e os grupos com as opções marcadas;
// - dados: os ajustes mostrados são os da linha do mundo, lidos do banco, e a página é a do instantâneo.
// Desvio (D-147): a legenda da Atkinson é "baixa visão" (a prancha diz "dislexia"): o mesmo centro e a mesma linha
// de base da prancha, com a largura do texto novo.
import 'package:app_leitura/core/data/database/daos/reader_daos.dart';
import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/tokens/app_typography.dart';
import 'package:app_leitura/core/design_system/widgets/neo_box.dart';
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:app_leitura/features/reader/layout/laid_block.dart';
import 'package:app_leitura/features/reader/layout/page_snapshot.dart';
import 'package:app_leitura/features/reader/layout/paginator.dart';
import 'package:app_leitura/features/reader/presentation/reader_chrome_palette.dart';
import 'package:app_leitura/features/reader/presentation/reader_page_view.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/mundo_2026_09_20.dart';
import '../fixtures/telas/instantaneo.dart';
import '../reference/leitor/ref_tipos.dart';
import 'dados_t20.dart';
import 'fase_l20.dart' show abrirTela20, instantaneoBrand;
import 'load_fonts.dart';
import 'pump_reader.dart';
import 'reader_harness.dart';

Finder _key(String k) => find.byKey(ValueKey<String>(k));

/// As seções da prancha conferidas.
const List<String> secoesL26 = ['rs.page', 'rs.livePill', 'rs.sheet'];

/// O Dom Casmurro da tela 26 com o ajuste da conta do mundo trocado por [look] (padrão: o do mundo).
Future<LivroNaEstante> livroDaTela26({
  ReaderLook look = const ReaderLook(),
}) async {
  final livro = await livroDaTela20(papel: look.paper);
  await ReaderSettingsDao(livro.db)
      .upsert(mundoReferencia.ajustes.withLook(look));
  return livro;
}

/// Abre a tela 20 (controles), toca em "Aa Fonte" e espera a folha (150 ms).
Future<LeitorNaTela> abrirTela26(
  WidgetTester tester,
  LivroNaEstante livro, {
  bool golden = false,
}) async {
  final t = await abrirTela20(tester, livro, golden: golden);
  await tester.tap(_key('r20.bottomIsland.tools.font'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 150));
  for (var i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
  return t;
}

/// D-147: a legenda da Atkinson ("baixa visão" no lugar do "dislexia" da prancha).
const String legendaAtkinsonL26 = 'rs.sheet.fonts.atkinson.caption';
const String textoLegendaAtkinson = 'baixa visão';

/// O elemento esperado: o da prancha, menos a legenda da Atkinson (D-147), que fica no mesmo centro e na mesma
/// linha de base, com a largura de "baixa visão" no estilo da legenda.
LeitorRefElement esperadoL26(LeitorRefPrancha ref, String id) {
  final e = ref.elements[id]!;
  if (id != legendaAtkinsonL26) return e;
  final tp = TextPainter(
    text: TextSpan(
      text: textoLegendaAtkinson,
      style: AppTextStyles.readerSheetCaption,
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  final w = tp.width;
  tp.dispose();
  final cx = e.rect.center.dx;
  final l = e.lines.single;
  return LeitorRefElement(
    e.section,
    Rect.fromLTWH(cx - w / 2, e.rect.top, w, e.rect.height),
    e.kind,
    lines: [
      LeitorRefLine(textoLegendaAtkinson, cx - w / 2, cx + w / 2, l.baseline),
    ],
  );
}

PageSnapshot _pagina(WidgetTester tester) =>
    tester.widget<ReaderPageView>(find.byType(ReaderPageView)).document.current
        as PageSnapshot;

void faseL26({
  required String nome,
  required LeitorRefPrancha ref,
  required InstantaneoDoLeitor instantaneo,
}) {
  setUpAll(loadAppFonts);

  late LivroNaEstante livro;
  setUp(() async => livro = await livroDaTela26());
  tearDown(() async => livro.close());

  final cores = ReaderChromePalette.of(ReaderPaper.creme);

  /// O retângulo medido na tela para o id da prancha (o texto da página: o parágrafo inteiro, como na L19).
  Rect medido(WidgetTester tester, String id) {
    if (id == 'rs.page.text') {
      final p = _pagina(tester);
      final s = p.page.slices.first as TextSlice;
      final b = p.block(s.block) as LaidText;
      final t = p.typography;
      return Rect.fromLTWH(
        t.sideMargin + b.left,
        t.topInset + s.y,
        b.width,
        // a prancha corta o parágrafo em "dias de ressaca." (14 linhas); no livro ele continua ("Para não ser…"):
        // mede-se a caixa das 14 linhas do arquivo (da 7ª em diante, atrás do papel do corte)
        b.lines[s.firstLine + 13].bottom - b.lines[s.firstLine].top,
      );
    }
    return tester.getRect(_key(id));
  }

  testWidgets('$nome — geometria: os 83 ids das seções', (tester) async {
    await abrirTela26(tester, livro);
    final ids = [for (final s in secoesL26) ...ref.idsOfSection(s)];
    expect(ids, hasLength(83));
    final falhas = <String>[];
    for (final id in ids) {
      final m = medido(tester, id);
      final e = esperadoL26(ref, id);
      final r = e.visual ?? e.rect;
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

  testWidgets(
    '$nome — texto: as 14 linhas da prévia (6 à vista) e os textos da folha',
    (tester) async {
      await abrirTela26(tester, livro);
      final p = _pagina(tester);
      final s = p.page.slices.first as TextSlice;
      final b = p.block(s.block) as LaidText;
      final linhas = ref.elements['rs.page.text']!.lines;
      final base = p.typography.topInset + s.y - b.lines[s.firstLine].top;
      final corte = tester.getRect(_key('rs.paper')).top;
      expect(linhas, hasLength(14));
      for (var i = 0; i < 14; i++) {
        final line = b.lines[s.firstLine + i];
        final e = linhas[i];
        final texto = p.item.text.substring(line.start, line.end).trimRight();
        if (i < 13) {
          expect(texto, e.text);
        } else {
          // a última linha da prancha é o fim do parágrafo cortado; no livro, a linha segue com a frase seguinte
          expect(texto, startsWith(e.text));
        }
        expect(
          base + line.baseline,
          moreOrLessEquals(e.baseline, epsilon: 0.5),
          reason: e.text,
        );
        if (e.hidden) {
          expect(
            base + line.top,
            greaterThanOrEqualTo(corte - 1e-6),
            reason: 'atrás do papel: ${e.text}',
          );
        } else {
          expect(
            base + line.baseline,
            lessThan(corte),
            reason: 'à vista: ${e.text}',
          );
        }
      }
      void textos(String id, {bool composto = false}) {
        final e = esperadoL26(ref, id);
        final esperadas = composto ? e.linesAll : e.lines;
        final dx = (e.visual?.left ?? e.rect.left) - e.rect.left;
        final r = tester.renderObject<RenderAppText>(
          find
              .descendant(
                of: _key(id),
                matching: find.byType(AppText),
                matchRoot: true,
              )
              .last,
        );
        final got = r.debugLines();
        expect(
          got.map((l) => l.text),
          esperadas.map((l) => l.text),
          reason: id,
        );
        for (var i = 0; i < got.length; i++) {
          expect(
            got[i].baseline,
            moreOrLessEquals(esperadas[i].baseline, epsilon: 0.5),
            reason: '$id baseline',
          );
          expect(
            got[i].left,
            moreOrLessEquals(esperadas[i].left + dx, epsilon: 1),
            reason: '$id início',
          );
          expect(
            got[i].right,
            moreOrLessEquals(esperadas[i].right + dx, epsilon: 1),
            reason: '$id fim',
          );
        }
      }

      textos('rs.sheet.title', composto: true);
      textos('rs.livePill');
      for (final id in ref.elements.keys.where(
        (k) =>
            k.startsWith('rs.sheet.') &&
            k != 'rs.sheet.title' &&
            k != 'rs.sheet.title.serif' &&
            ref.elements[k]!.lines.isNotEmpty,
      )) {
        textos(id);
      }
    },
  );

  testWidgets(
    '$nome — estilo: folha, alça, pontos, cartões, segmentados, rótulos, título e pílula',
    (tester) async {
      await abrirTela26(tester, livro);
      final brand = instantaneoBrand(instantaneo);
      final linha = BorderSide(width: 1.5, color: cores.border);
      final folha = tester.widget<NeoBox>(_key('rs.sheet'));
      expect(
        (folha.color, folha.border, folha.shadow, folha.shadowColor),
        (cores.island, linha, const Offset(0, 4), cores.shadow),
      );
      expect(tester.getSize(_key('rs.sheet.grabber')), const Size(40, 5));
      final ativo = tester.widget<NeoBox>(_key('rs.sheet.size.step4'));
      expect((ativo.color, ativo.border), (brand, linha));
      NeoBox de(String id) => tester.widget<NeoBox>(
        find.descendant(of: _key(id), matching: find.byType(NeoBox)).first,
      );
      final literata = de('rs.sheet.fonts.literata');
      expect(
        (literata.color, literata.shadow, literata.radius),
        (brand, const Offset(2, 2), BorderRadius.circular(16)),
      );
      final creme = tester.widget<NeoBox>(_key('rs.sheet.papers.cream.card'));
      expect(
        (creme.color, creme.shadow, creme.radius),
        (AppColors.paperCream, const Offset(2, 2), BorderRadius.circular(14)),
      );
      final check = tester.widget<NeoBox>(_key('rs.sheet.papers.cream.check'));
      expect((check.color, check.border), (brand, linha));
      final medio = de('rs.sheet.spacing.medium');
      expect((medio.color, medio.border), (brand, linha));
      final rotulo = tester
          .widget<AppText>(_key('rs.sheet.fontLabel'))
          .span
          .style!;
      expect(
        (
          rotulo.fontFamily,
          rotulo.fontSize,
          rotulo.fontWeight,
          rotulo.letterSpacing,
          rotulo.color,
        ),
        ('Figtree', 11.0, FontWeight.w800, 1.2, cores.label),
      );
      final titulo =
          tester.widget<AppText>(_key('rs.sheet.title')).span as TextSpan;
      final a = titulo.children![0] as TextSpan;
      final b = titulo.children![1] as TextSpan;
      expect(
        (a.style!.fontFamily, a.style!.fontSize, a.style!.letterSpacing),
        ('Bricolage23', 23.0, -0.5),
      );
      expect(
        (
          b.style!.fontFamily,
          b.style!.fontSize,
          b.style!.fontStyle,
          b.style!.letterSpacing,
        ),
        ('InstrumentSerif', 28.0, FontStyle.italic, -0.2),
      );
      final ponto = tester.widget<DecoratedBox>(
        find.descendant(
          of: _key('rs.livePill.dot'),
          matching: find.byType(DecoratedBox),
        ),
      );
      expect((ponto.decoration as BoxDecoration).color, AppColors.flame);
    },
  );

  testWidgets(
    '$nome — semântica: diálogo, prévia, botões, deslizante e grupos',
    (tester) async {
      final h = tester.ensureSemantics();
      await abrirTela26(tester, livro);
      expect(
        tester.getSemantics(_key('rs.sheet')),
        isSemantics(label: 'Ajustes de leitura', scopesRoute: true),
      );
      for (final r in [
        'Prévia da página',
        'Fechar',
        'Diminuir a letra',
        'Aumentar a letra',
        'Tamanho da letra',
        'Fonte',
        'Tema do papel',
        'Entrelinha',
        'Margens',
      ]) {
        expect(find.bySemanticsLabel(r), findsOneWidget, reason: r);
      }
      expect(
        tester.getSemantics(find.bySemanticsLabel('Tamanho da letra')),
        isSemantics(label: 'Tamanho da letra', value: '4 de 7', isSlider: true),
      );
      for (final (id, rotulo, marcado) in const [
        ('rs.sheet.fonts.literata', 'Literata, tela', true),
        ('rs.sheet.fonts.lora', 'Lora, clássica', false),
        ('rs.sheet.fonts.figtree', 'Figtree, sem serifa', false),
        ('rs.sheet.fonts.atkinson', 'Atkinson, baixa visão', false),
        ('rs.sheet.papers.cream', 'Tema Creme', true),
        ('rs.sheet.papers.white', 'Tema Branco', false),
        ('rs.sheet.papers.sepia', 'Tema Sépia', false),
        ('rs.sheet.papers.night', 'Tema Noite', false),
        ('rs.sheet.spacing.tight', 'Justo', false),
        ('rs.sheet.spacing.medium', 'Médio', true),
        ('rs.sheet.spacing.loose', 'Solto', false),
        ('rs.sheet.margins.narrow', 'Estreita', false),
        ('rs.sheet.margins.medium', 'Média', true),
        ('rs.sheet.margins.wide', 'Larga', false),
      ]) {
        expect(
          tester.getSemantics(_key(id)),
          isSemantics(
            label: rotulo,
            hasCheckedState: true,
            isChecked: marcado,
            isInMutuallyExclusiveGroup: true,
          ),
          reason: id,
        );
      }
      expect(
        find.bySemanticsLabel(RegExp('prévia ao vivo')),
        findsNothing,
        reason: 'aria-hidden',
      );
      h.dispose();
    },
  );

  testWidgets('$nome — dados: os ajustes mostrados são os da linha do mundo', (
    tester,
  ) async {
    await abrirTela26(tester, livro);
    final ajuste = mundoReferencia.ajustes;
    expect(ajuste.look, const ReaderLook());
    expect(
      tester.getSize(_key('rs.sheet.size.step${ajuste.fontStep}')),
      const Size(14, 14),
    );
    expect(_key('rs.sheet.papers.cream.check'), findsOneWidget);
    // a prévia é a página do instantâneo (o rodapé fica atrás do papel do corte, mas continua montado)
    final rodape = tester
        .widget<AppText>(_key('r19.footer.pageLabel'))
        .span
        .toPlainText();
    expect(
      rodape,
      'pág. ${instantaneo.pagina} de ${instantaneo.totalDePaginas}',
    );
  });
}

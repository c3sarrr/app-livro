// G17.7 — as fases L23 (o painel da caneta, tela 23) e L23b (o painel do marca-texto, tela 23b) pela rota real, no
// mundo das telas 23 e 23b (D-34, D-160), abertas pelo fluxo (`abrirTela23`/`abrirTela23b`), contra as medidas do
// arquivo:
// - geometria: os ids das seções do véu e do painel, sem os inline (±0,5; ±1,0 em x/w nos que dependem do texto; a
//   caixa visual da seta girada); na 23b, também o grifo da prévia e a palavra das amostras;
// - texto: as linhas e as baselines (a prévia e a dica da 23b com os trechos de dentro);
// - estilo: a moldura (o fundo da ilha, a borda de 1,5, o raio 26 e a sombra 4/4), o véu (o papel a 66 %), os
//   ativos na `brand` com a sombra 2/2, as fontes;
// - semântica: o diálogo, os grupos e os marcados;
// - dados: o `pen_presets` do mundo (o subtítulo) e, na 23b, os rótulos e as contagens de todos os livros (D-40).
import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/widgets/neo_box.dart';
import 'package:app_leitura/features/reader/presentation/reader_palette.dart';
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/telas/t23.dart';
import '../fixtures/telas/t23b.dart';
import '../reference/leitor/ref_tipos.dart';
import '../reference/leitor/reference_layout_23_ajustes_caneta.dart';
import '../reference/leitor/reference_layout_23b_ajustes_marcatexto.dart';
import 'app_text_finder.dart';
import 'dados_t23.dart';
import 'fase_l20.dart' show instantaneoBrand;
import 'load_fonts.dart';
import 'pecas_l23.dart';
import 'reader_harness.dart';

/// Os ids de [secoes] sem os inline (o texto deles é conferido pelas linhas do pai).
List<String> idsL23(LeitorRefPrancha ref, Set<String> secoes) => [
  for (final MapEntry(key: id, value: e) in ref.elements.entries)
    if (secoes.contains(e.section) && e.kind != LeitorRefKind.inline) id,
];

void _comOLivro(void Function(LivroNaEstante Function() livro) testes) {
  setUpAll(loadAppFonts);
  late LivroNaEstante livro;
  // T01: no estado da prancha — a sessão da 22 desenhada, o Desfazer aceso
  setUp(() async => livro = await livroDaTela23(sessao: true));
  tearDown(() async => livro.close());
  testes(() => livro);
}

/// O fundo de um `Container` com chave.
BoxDecoration _deco(WidgetTester tester, String chave) =>
    tester.widget<Container>(chaveL23(chave)).decoration! as BoxDecoration;

/// A moldura das telas 23 e 23b (L23.1, L23b.1): o fundo da ilha, a borda de 1,5, o raio 26, a sombra 4/4 e o véu
/// no papel a 66 %.
void _conferirMoldura(WidgetTester tester, String id) {
  final d = _deco(tester, id);
  expect(d.color, AppColors.surface, reason: id);
  expect((d.border! as Border).top.width, 1.5);
  expect((d.border! as Border).top.color, AppColors.ink);
  expect(d.borderRadius, BorderRadius.circular(26));
  expect(d.boxShadow!.single.offset, const Offset(4, 4));
  expect(d.boxShadow!.single.color, AppColors.ink);
  expect(
    tester.widget<ColoredBox>(chaveL23('ann.fade')).color,
    ReaderPalette.of(ReaderPaper.creme).paper.withValues(alpha: 0.66),
  );
}

/// As linhas de todo o texto (com os trechos de dentro) do `AppText` em [chave], contra [linhas].
void _conferirLinhasTodas(
  WidgetTester tester,
  String chave,
  List<LeitorRefLine> linhas,
) {
  final got = tester
      .renderObject<RenderAppText>(
        find
            .descendant(
              of: chaveL23(chave),
              matching: find.byType(AppText),
              matchRoot: true,
            )
            .last,
      )
      .debugLines();
  expect(got.map((l) => l.text), linhas.map((l) => l.text), reason: chave);
  for (var i = 0; i < got.length; i++) {
    expect(
      got[i].baseline,
      moreOrLessEquals(linhas[i].baseline, epsilon: 0.5),
      reason: '$chave baseline',
    );
    expect(got[i].left, moreOrLessEquals(linhas[i].left, epsilon: 1));
    expect(got[i].right, moreOrLessEquals(linhas[i].right, epsilon: 1));
  }
}

// ---- L23 -------------------------------------------------------------------------------------------------------

void faseL23() => _comOLivro((livro) {
  testWidgets('L23 — o Desfazer aceso como na prancha (T01)', (tester) async {
    await abrirTela23(tester, livro());
    conferirHistoricoDaPrancha(tester);
  });

  testWidgets('L23 — geometria: os 48 ids do véu e do painel da caneta', (
    tester,
  ) async {
    await abrirTela23(tester, livro());
    final ids = idsL23(kRef23, const {'pen.fade', 'pen.penPanel'});
    expect(ids, hasLength(48));
    conferirGeometriaL23(tester, kRef23, ids);
  });

  testWidgets('L23 — texto: as linhas nas baselines', (tester) async {
    await abrirTela23(tester, livro());
    for (final id in const [
      'pen.penPanel.title',
      'pen.penPanel.subtitle',
      'pen.penPanel.tipLabel',
      'pen.penPanel.tips.ballpoint',
      'pen.penPanel.tips.fountain',
      'pen.penPanel.tips.brush',
      'pen.penPanel.sizeHeader.label',
      'pen.penPanel.sizeHeader.value',
      'pen.penPanel.colorLabel',
      'pen.penPanel.picker.brightnessLabel',
      'pen.penPanel.picker.hex.value',
    ]) {
      conferirLinhasL23(tester, kRef23, id);
    }
  });

  testWidgets(
    'L23 — estilo: a moldura, o véu, a ponta ativa na brand com a sombra 2/2 e as fontes',
    (tester) async {
      await abrirTela23(tester, livro());
      _conferirMoldura(tester, 'ann.penPanel');
      final ativa = tester.widget<NeoBox>(
        chaveL23('ann.penPanel.tips.ballpoint.box'),
      );
      expect(ativa.color, instantaneoBrand(t23));
      expect(ativa.shadow, const Offset(2, 2));
      expect(
        tester.widget<NeoBox>(chaveL23('ann.penPanel.tips.brush.box')).color,
        AppColors.paper,
      );
      final titulo =
          (tester.widget<AppText>(chaveL23('ann.penPanel.title')).span
                  as TextSpan)
              .style!;
      expect((titulo.fontSize, titulo.letterSpacing), (22.0, -0.4));
      expect(titulo.fontFamily, startsWith('Bricolage'));
      final sub =
          (tester.widget<AppText>(chaveL23('ann.penPanel.subtitle')).span
                  as TextSpan)
              .style!;
      expect(
        (sub.fontSize, sub.fontWeight, sub.color),
        (12.5, FontWeight.w600, const Color(0xFF5B544B)),
      );
    },
  );

  testWidgets('L23 — semântica: o diálogo, as pontas e a espessura', (
    tester,
  ) async {
    final h = tester.ensureSemantics();
    await abrirTela23(tester, livro());
    expect(find.bySemanticsLabel('Ajustes da caneta'), findsOneWidget);
    expect(find.bySemanticsLabel('Tipo de ponta'), findsOneWidget);
    expect(
      tester.getSemantics(chaveL23('ann.penPanel.tips.ballpoint')),
      isSemantics(
        label: 'Esferográfica',
        hasCheckedState: true,
        isChecked: true,
        isInMutuallyExclusiveGroup: true,
        hasTapAction: true,
      ),
    );
    expect(find.bySemanticsLabel('Cores favoritas'), findsOneWidget);
    expect(find.bySemanticsLabel('Espessura'), findsOneWidget);
    h.dispose();
  });

  testWidgets('L23 — dados: o subtítulo e os ajustes do pen_presets do mundo', (
    tester,
  ) async {
    await abrirTela23(tester, livro());
    final c = t23.mundo.caneta;
    expect(c.penColor, '#FF552E');
    expect(findAppText('Esferográfica · 1,2 mm · coral'), findsOneWidget);
    expect(findAppText('1,2 mm'), findsOneWidget);
    expect(findAppText(c.penColor), findsOneWidget);
  });
});

// ---- L23b ------------------------------------------------------------------------------------------------------

void faseL23b() => _comOLivro((livro) {
  testWidgets('L23b — o Desfazer aceso como na prancha (T01)', (tester) async {
    await abrirTela23b(tester, livro());
    conferirHistoricoDaPrancha(tester);
  });

  testWidgets('L23b — geometria: os 53 ids do véu e do painel do marca-texto', (
    tester,
  ) async {
    await abrirTela23b(tester, livro());
    final ids = idsL23(kRef23b, const {'mk.fade', 'mk.markerPanel'});
    expect(ids, hasLength(53));
    conferirGeometriaL23(tester, kRef23b, [
      ...ids,
      'mk.markerPanel.preview.highlight',
      'mk.markerPanel.styles.fill.sample.word',
      'mk.markerPanel.styles.underline.sample.word',
      'mk.markerPanel.styles.wavy.sample.word',
    ]);
  });

  testWidgets('L23b — texto: as linhas nas baselines', (tester) async {
    await abrirTela23b(tester, livro());
    for (final id in const [
      'mk.markerPanel.title',
      'mk.markerPanel.subtitle',
      'mk.markerPanel.styleLabel',
      'mk.markerPanel.styles.fill',
      'mk.markerPanel.styles.underline',
      'mk.markerPanel.styles.wavy',
      'mk.markerPanel.colorsHeader.label',
      'mk.markerPanel.colorsHeader.editLabels',
      'mk.markerPanel.colors.yellow.label',
      'mk.markerPanel.colors.yellow.count',
      'mk.markerPanel.colors.pink.label',
      'mk.markerPanel.colors.pink.count',
      'mk.markerPanel.colors.green.label',
      'mk.markerPanel.colors.green.count',
      'mk.markerPanel.colors.lavender.label',
      'mk.markerPanel.colors.lavender.count',
      'mk.markerPanel.heightLabel',
      'mk.markerPanel.heights.low',
      'mk.markerPanel.heights.medium',
      'mk.markerPanel.heights.high',
    ]) {
      conferirLinhasL23(tester, kRef23b, id);
    }
    for (final id in const [
      'preview',
      'tip.text',
      'styles.fill.sample',
      'styles.underline.sample',
      'styles.wavy.sample',
    ]) {
      _conferirLinhasTodas(
        tester,
        'ann.markerPanel.$id',
        kRef23b.elements['mk.markerPanel.$id']!.linesAll,
      );
    }
  });

  testWidgets(
    'L23b — estilo: a moldura, o véu, os ativos na brand e a linha marcada com a borda de tinta',
    (tester) async {
      await abrirTela23b(tester, livro());
      _conferirMoldura(tester, 'ann.markerPanel');
      BoxDecoration primeiro(String chave) =>
          tester
                  .widget<Container>(
                    find
                        .descendant(
                          of: chaveL23(chave),
                          matching: find.byType(Container),
                        )
                        .first,
                  )
                  .decoration!
              as BoxDecoration;
      final fundo = primeiro('ann.markerPanel.styles.fill');
      expect(fundo.color, instantaneoBrand(t23b));
      expect(fundo.boxShadow!.single.offset, const Offset(2, 2));
      expect(primeiro('ann.markerPanel.styles.wavy').color, AppColors.paper);
      expect(
        (primeiro('ann.markerPanel.colors.yellow').border! as Border).top.color,
        AppColors.ink,
      );
      expect(
        (primeiro('ann.markerPanel.colors.pink').border! as Border).top.color,
        AppColors.markerRowBorder,
      );
      expect(
        primeiro('ann.markerPanel.heights.medium').color,
        instantaneoBrand(t23b),
      );
    },
  );

  testWidgets('L23b — semântica: o diálogo, a prévia e os 3 grupos', (
    tester,
  ) async {
    final h = tester.ensureSemantics();
    await abrirTela23b(tester, livro());
    expect(find.bySemanticsLabel('Ajustes do marca-texto'), findsOneWidget);
    expect(
      tester.getSemantics(chaveL23('ann.markerPanel.preview')).label,
      'Prévia: Olhos de ressaca, com fundo amarelo na palavra ressaca',
    );
    for (final g in const [
      'Estilo do marca-texto',
      'Cor do marca-texto',
      'Altura do fundo',
    ]) {
      // a ilha também diz "Altura do fundo" com o Marca-texto (R18): o do painel
      expect(
        find.descendant(
          of: chaveL23('ann.markerPanel'),
          matching: find.bySemanticsLabel(g),
        ),
        findsOneWidget,
        reason: g,
      );
    }
    expect(
      tester.getSemantics(chaveL23('ann.markerPanel.colors.yellow')).label,
      'amarelo, rótulo lindo, 5 grifos',
    );
    h.dispose();
  });

  testWidgets(
    'L23b — dados: os rótulos e as contagens de todos os livros do mundo (D-40)',
    (tester) async {
      await abrirTela23b(tester, livro());
      final porCor = t23b.grifosPorCor;
      for (final r in t23b.mundo.rotulos) {
        expect(findAppText(r.label), findsOneWidget, reason: r.label);
        expect(porCor[r.color], isNotNull);
      }
      expect(findAppText('5 grifos'), findsOneWidget);
      expect(findAppText('3 grifos'), findsOneWidget);
      expect(findAppText('2 grifos'), findsNWidgets(2));
      expect(findAppText('Fundo · amarelo “lindo” · média'), findsOneWidget);
    },
  );
});

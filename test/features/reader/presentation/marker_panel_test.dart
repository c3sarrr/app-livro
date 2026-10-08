// G17.5 — o painel do marca-texto (tela 23b, L23b.1–L23b.5): os 53 ids das seções `mk.fade` e `mk.markerPanel` nos
// lugares da prancha, com os textos; o subtítulo (R15); a prévia com a frase da página e o grifo nítido na palavra
// (R16, D-171); os estilos; as cores com os rótulos e as contagens (R17, D-40); a altura, apagada fora do Fundo (R18);
// a dica; o leitor de tela.
import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/widgets/app_svg.dart';
import 'package:app_leitura/features/reader/annotations/domain/annotation.dart'
    show FillHeight, HighlightStyle;
import 'package:app_leitura/features/reader/annotations/domain/pen_presets.dart';
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:app_leitura/features/reader/presentation/marker_panel.dart';
import 'package:app_leitura/features/reader/presentation/reader_palette.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../reference/leitor/ref_tipos.dart';
import '../../../reference/leitor/reference_layout_23b_ajustes_marcatexto.dart';
import '../../../support/app_text_finder.dart';
import '../../../support/load_fonts.dart';
import '../../../support/pecas_l23.dart';
import '../../../support/personal_builders.dart';
import '../../../support/sessao_g17.dart';

/// A base do painel nas pranchas: 22 acima do topo da prateleira (676).
const double _base = 844 - 676 + 22;

/// Os rótulos e as contagens do mundo (D-40): 5/3/2/2.
const _rotulos = {
  '#FED170': 'lindo',
  '#FFC1C6': 'personagem',
  '#ABCF82': 'ideia',
  '#B6ACE4': 'pro clube',
};
const _contagens = {'#FED170': 5, '#FFC1C6': 3, '#ABCF82': 2, '#B6ACE4': 2};

Future<SessaoG17> _montar(
  WidgetTester tester, {
  PenPresets? presets,
  ReaderPaper papel = ReaderPaper.creme,
  Map<String, String> rotulos = _rotulos,
  Map<String, int> contagens = _contagens,
  MarkerPreviewSource? previa,
  VoidCallback? editar,
}) async {
  final s = sessaoG17(presets: presets);
  s.sessao.setLabelData(labels: rotulos, counts: contagens);
  await montarPecasL23(tester, [
    Positioned.fill(
      child: MarkerPanelLayer(
        session: s.sessao,
        bottom: _base,
        paper: ReaderPalette.of(papel).paper,
        preview: previa,
        onEditLabels: editar ?? () {},
      ),
    ),
  ], papel: papel);
  return s;
}

List<String> _ids(LeitorRefPrancha ref, Set<String> secoes) => [
  for (final MapEntry(key: id, value: e) in ref.elements.entries)
    if (secoes.contains(e.section) && e.kind != LeitorRefKind.inline) id,
];

Finder _k(String k) => find.byKey(ValueKey<String>(k));

/// As linhas de todo o texto (com os trechos de dentro) do `AppText` em [chave].
List<AppTextLine> _linhas(WidgetTester tester, String chave) => tester
    .renderObject<RenderAppText>(
      find
          .descendant(
            of: _k(chave),
            matching: find.byType(AppText),
            matchRoot: true,
          )
          .last,
    )
    .debugLines();

void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'L23b — os 53 ids do véu e do painel nos lugares da prancha; os textos nas baselines',
    (tester) async {
      await _montar(tester);
      final ids = _ids(kRef23b, const {'mk.fade', 'mk.markerPanel'});
      expect(ids, hasLength(53));
      conferirGeometriaL23(tester, kRef23b, [
        ...ids,
        // o grifo da prévia e a palavra das amostras (inline no arquivo)
        'mk.markerPanel.preview.highlight',
        'mk.markerPanel.styles.fill.sample.word',
        'mk.markerPanel.styles.underline.sample.word',
        'mk.markerPanel.styles.wavy.sample.word',
      ]);
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
      // a prévia e a dica têm trechos de dentro: as linhas inteiras
      for (final (chave, id) in const [
        ('ann.markerPanel.preview', 'mk.markerPanel.preview'),
        ('ann.markerPanel.tip.text', 'mk.markerPanel.tip.text'),
        (
          'ann.markerPanel.styles.fill.sample',
          'mk.markerPanel.styles.fill.sample',
        ),
        (
          'ann.markerPanel.styles.underline.sample',
          'mk.markerPanel.styles.underline.sample',
        ),
        (
          'ann.markerPanel.styles.wavy.sample',
          'mk.markerPanel.styles.wavy.sample',
        ),
      ]) {
        final esperadas = kRef23b.elements[id]!.linesAll;
        final got = _linhas(tester, chave);
        expect(
          got.map((l) => l.text),
          esperadas.map((l) => l.text),
          reason: id,
        );
        for (var i = 0; i < got.length; i++) {
          expect(
            got[i].baseline,
            moreOrLessEquals(esperadas[i].baseline, epsilon: 0.5),
          );
          expect(got[i].left, moreOrLessEquals(esperadas[i].left, epsilon: 1));
          expect(
            got[i].right,
            moreOrLessEquals(esperadas[i].right, epsilon: 1),
          );
        }
      }
    },
  );

  group('subtítulo (R15)', () {
    test('estilo · cor e rótulo entre aspas curvas · altura (só no Fundo)', () {
      final p = presetsTeste();
      expect(
        markerPanelSubtitle(p, _rotulos),
        'Fundo · amarelo “lindo” · média',
      );
      expect(markerPanelSubtitle(p, const {}), 'Fundo · amarelo · média');
      expect(
        markerPanelSubtitle(
          p.copyWith(
            highlighterStyle: HighlightStyle.underline,
            highlighterColor: '#FFC1C6',
          ),
          _rotulos,
        ),
        'Sublinhado · rosa “personagem”',
      );
      expect(
        markerPanelSubtitle(
          p.copyWith(highlighterHeight: FillHeight.high),
          const {'#FED170': '   '},
        ),
        'Fundo · amarelo · alta',
      );
    });
  });

  group('estilos e altura (R18)', () {
    testWidgets(
      'Ondulado: grava, o subtítulo perde a altura e a ALTURA fica apagada, sem responder',
      (tester) async {
        final s = await _montar(tester);
        await tester.tap(_k('ann.markerPanel.styles.wavy'));
        await tester.pump();
        expect(s.sessao.presets.highlighterStyle, HighlightStyle.wavy);
        expect(findAppText('Ondulado · amarelo “lindo”'), findsOneWidget);
        await tester.tap(
          _k('ann.markerPanel.heights.high'),
          warnIfMissed: false,
        );
        await tester.pump();
        expect(s.sessao.presets.highlighterHeight, FillHeight.medium);
        final semantica = tester.ensureSemantics();
        expect(
          tester.getSemantics(_k('ann.markerPanel.heights.high')),
          isSemantics(
            label: 'Alta',
            hasCheckedState: true,
            isInMutuallyExclusiveGroup: true,
            hasEnabledState: true,
            isEnabled: false,
          ),
        );
        semantica.dispose();
        // o rótulo ALTURA apagado (0,38)
        final cor =
            (tester.widget<AppText>(findAppText('ALTURA')).span as TextSpan)
                .style!
                .color!;
        expect(cor.a, closeTo(0.38, 0.01));
        // de volta ao Fundo, a altura responde
        await tester.tap(_k('ann.markerPanel.styles.fill'));
        await tester.pump();
        await tester.tap(_k('ann.markerPanel.heights.high'));
        await tester.pump();
        expect(s.sessao.presets.highlighterHeight, FillHeight.high);
        expect(findAppText('Fundo · amarelo “lindo” · alta'), findsOneWidget);
      },
    );

    testWidgets('o cartão ativo: brand com sombra 2/2; os outros no poço', (
      tester,
    ) async {
      await _montar(tester);
      final d = tester
          .widget<Container>(
            find
                .descendant(
                  of: _k('ann.markerPanel.styles.fill'),
                  matching: find.byType(Container),
                )
                .first,
          )
          .decoration;
      expect(d, isA<BoxDecoration>());
      final ativo = d! as BoxDecoration;
      expect(ativo.color, AppColors.lavender);
      expect(ativo.boxShadow!.single.offset, const Offset(2, 2));
    });
  });

  group('cores, rótulos e contagens (R17)', () {
    testWidgets(
      'tocar rosa muda a cor; a borda de tinta e o aro passam à linha dela',
      (tester) async {
        final s = await _montar(tester);
        Color borda(String id) =>
            ((tester
                                .widget<Container>(
                                  find
                                      .descendant(
                                        of: _k('ann.markerPanel.colors.$id'),
                                        matching: find.byType(Container),
                                      )
                                      .first,
                                )
                                .decoration!
                            as BoxDecoration)
                        .border!
                    as Border)
                .top
                .color;
        expect(borda('yellow'), AppColors.ink);
        expect(borda('pink'), const Color(0xFFE2D7C4));
        await tester.tap(_k('ann.markerPanel.colors.pink'));
        await tester.pump();
        expect(s.sessao.presets.highlighterColor, '#FFC1C6');
        expect(borda('pink'), AppColors.ink);
        expect(borda('yellow'), const Color(0xFFE2D7C4));
        expect(
          findAppText('Fundo · rosa “personagem” · média'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'sem rótulo, o nome da cor; "1 grifo" no singular; a sessão conta; rótulo longo termina em "…"',
      (tester) async {
        final s = await _montar(
          tester,
          rotulos: const {'#ABCF82': 'um rótulo de vinte e qua'},
          contagens: const {'#FED170': 1, '#FFC1C6': 0},
        );
        expect(findAppText('amarelo'), findsOneWidget);
        expect(findAppText('1 grifo'), findsOneWidget);
        expect(findAppText('0 grifos'), findsNWidgets(3));
        final l = _linhas(tester, 'ann.markerPanel.colors.green.label');
        // cortado (o "…" é pintado no lugar do resto)
        expect(
          l.single.text.length,
          lessThan('um rótulo de vinte e qua'.length),
        );
        expect('um rótulo de vinte e qua', startsWith(l.single.text));
        expect(
          tester
              .widget<AppText>(_k('ann.markerPanel.colors.green.label'))
              .ellipsis,
          isTrue,
        );
        final semantica = tester.ensureSemantics();
        expect(
          tester.getSemantics(_k('ann.markerPanel.colors.yellow')),
          isSemantics(
            label: 'amarelo, 1 grifo',
            hasCheckedState: true,
            isChecked: true,
            isInMutuallyExclusiveGroup: true,
            hasTapAction: true,
          ),
        );
        expect(
          tester.getSemantics(_k('ann.markerPanel.colors.green')).label,
          'verde, rótulo um rótulo de vinte e qua, 0 grifos',
        );
        expect(s.sessao.presets.highlighterColor, '#FED170');
        semantica.dispose();
      },
    );

    testWidgets('"Editar rótulos" chama a folha', (tester) async {
      var vezes = 0;
      await _montar(tester, editar: () => vezes++);
      await tester.tap(_k('ann.markerPanel.colorsHeader.editLabels'));
      expect(vezes, 1);
    });
  });

  group('prévia (R16)', () {
    testWidgets(
      'a frase da página, com o grifo nítido na palavra mais longa da 1ª frase',
      (tester) async {
        final semantica = tester.ensureSemantics();
        await _montar(
          tester,
          previa: (
            text: 'aí. Fui ver o mar morto. Ela riu.',
            start: 4,
            end: 33,
          ),
        );
        expect(
          _linhas(tester, 'ann.markerPanel.preview').single.text,
          'Fui ver o mar morto. Ela riu.',
        );
        expect(
          tester.getSemantics(_k('ann.markerPanel.preview')).label,
          'Prévia: Fui ver o mar morto, com fundo amarelo na palavra morto',
        );
        semantica.dispose();
      },
    );

    testWidgets('o leitor de tela: o diálogo, a prévia e os 3 grupos', (
      tester,
    ) async {
      final semantica = tester.ensureSemantics();
      await _montar(tester);
      expect(find.bySemanticsLabel('Ajustes do marca-texto'), findsOneWidget);
      expect(
        tester.getSemantics(_k('ann.markerPanel.preview')).label,
        'Prévia: Olhos de ressaca, com fundo amarelo na palavra ressaca',
      );
      for (final g in const [
        'Estilo do marca-texto',
        'Cor do marca-texto',
        'Altura do fundo',
      ]) {
        expect(find.bySemanticsLabel(g), findsOneWidget, reason: g);
      }
      semantica.dispose();
    });
  });

  group('Noite (R26)', () {
    /// As cores dos trechos do `AppText` de [chave] (o trecho com o texto [t]).
    Color corDe(WidgetTester tester, String chave, String t) {
      final span =
          tester
                  .widget<AppText>(
                    find
                        .descendant(
                          of: _k(chave),
                          matching: find.byType(AppText),
                        )
                        .last,
                  )
                  .span
              as TextSpan;
      Color? achar(InlineSpan s, Color? herdada) {
        if (s is! TextSpan) return null;
        final c = s.style?.color ?? herdada;
        if (s.text == t) return c;
        for (final f in s.children ?? const <InlineSpan>[]) {
          final r = achar(f, c);
          if (r != null) return r;
        }
        return null;
      }

      return achar(span, null)!;
    }

    testWidgets(
      'as cores da ilha do Noite; os cartões e a pílula no poço; o ativo brand com letras escuras',
      (tester) async {
        await _montar(tester, papel: ReaderPaper.noite);
        final caixa = tester.widget<Container>(_k('ann.markerPanel'));
        expect(
          (caixa.decoration! as BoxDecoration).color,
          AppColors.islandNight,
        );
        BoxDecoration deco(String chave) =>
            tester
                    .widget<Container>(
                      find
                          .descendant(
                            of: _k(chave),
                            matching: find.byType(Container),
                          )
                          .first,
                    )
                    .decoration!
                as BoxDecoration;
        expect(
          deco('ann.markerPanel.styles.underline').color,
          AppColors.paperNight,
        );
        expect(deco('ann.markerPanel.styles.fill').color, AppColors.lavender);
        expect(
          (tester.widget<Container>(_k('ann.markerPanel.heights')).decoration!
                  as BoxDecoration)
              .color,
          AppColors.paperNight,
        );
        expect(
          (tester.widget<Container>(_k('ann.markerPanel.preview')).decoration!
                  as BoxDecoration)
              .color,
          AppColors.paperNight,
        );
        // o desenho da dica: o contorno escuro do arquivo vira o claro do Noite
        expect(tester.widget<AppSvg>(_k('ann.markerPanel.tip.icon')).colors, {
          AppColors.ink: AppColors.inkNight,
        });
      },
    );

    testWidgets(
      'as letras: claras no poço; a palavra do fundo e o cartão ativo escuros (D-133)',
      (tester) async {
        await _montar(tester, papel: ReaderPaper.noite);
        // a prévia: a frase clara e "ressaca" (no fundo amarelo) escura
        expect(
          corDe(tester, 'ann.markerPanel.preview', 'Olhos de '),
          AppColors.bookTextNight,
        );
        expect(
          corDe(tester, 'ann.markerPanel.preview', 'ressaca'),
          AppColors.ink,
        );
        // as amostras: o Fundo (ativo, na brand) e o Sublinhado (no poço)
        expect(
          corDe(tester, 'ann.markerPanel.styles.fill.sample', 'ressaca'),
          AppColors.ink,
        );
        expect(
          corDe(tester, 'ann.markerPanel.styles.underline.sample', 'ressaca'),
          AppColors.bookTextNight,
        );
      },
    );

    testWidgets('no Creme, as letras da frase e das amostras são as do livro', (
      tester,
    ) async {
      await _montar(tester);
      expect(
        corDe(tester, 'ann.markerPanel.preview', 'ressaca'),
        AppColors.bookText,
      );
      expect(
        corDe(tester, 'ann.markerPanel.styles.wavy.sample', 'ressaca'),
        AppColors.bookText,
      );
      expect(
        tester.widget<AppSvg>(_k('ann.markerPanel.tip.icon')).colors,
        isNull,
      );
    });
  });
}

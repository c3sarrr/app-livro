// G17.3 — o painel da caneta (tela 23, L23.1–L23.6): os 48 ids das seções `pen.fade` e `pen.penPanel` nos lugares
// da prancha, com os textos; o subtítulo derivado (R8); a prévia pelo motor da tinta na ponta, na cor e na espessura
// do painel, ampliada 17/11 (R9, D-159); as pontas (R10); a espessura na escala da D-50 (R11); as favoritas com o
// "+", tirar e Desfazer (R12, D-175); o seletor (R13, R14); o leitor de tela.
import 'dart:math' as math;

import 'package:app_leitura/core/design_system/painters/dashed_stadium_painter.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/widgets/app_svg.dart';
import 'package:app_leitura/core/design_system/widgets/neo_box.dart';
import 'package:app_leitura/features/reader/annotations/domain/pen_presets.dart';
import 'package:app_leitura/features/reader/annotations/ink/ink_stroke.dart';
import 'package:app_leitura/features/reader/annotations/ink/ink_units.dart';
import 'package:app_leitura/features/reader/application/annotation_session.dart';
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:app_leitura/features/reader/presentation/pen_panel.dart';
import 'package:app_leitura/features/reader/presentation/reader_palette.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../reference/leitor/ref_tipos.dart';
import '../../../reference/leitor/reference_layout_23_ajustes_caneta.dart';
import '../../../support/app_text_finder.dart';
import '../../../support/capture.dart';
import '../../../support/load_fonts.dart';
import '../../../support/pecas_l23.dart';
import '../../../support/personal_builders.dart';
import '../../../support/sessao_g17.dart';

/// A base do painel nas pranchas: 22 acima do topo da prateleira (676).
const double _base = 844 - 676 + 22;

Future<SessaoG17> _montar(
  WidgetTester tester, {
  PenPresets? presets,
  ReaderPaper papel = ReaderPaper.creme,
  EdgeInsets teclado = EdgeInsets.zero,
}) async {
  final s = sessaoG17(presets: presets);
  await montarPecasL23(
    tester,
    [
      Positioned.fill(
        child: PenPanelLayer(
          session: s.sessao,
          from: AnnotationTool.pen,
          bottom: _base,
          paper: ReaderPalette.of(papel).paper,
        ),
      ),
    ],
    papel: papel,
    teclado: teclado,
  );
  return s;
}

/// Os ids de [secoes] sem os inline (o texto deles é conferido pelas linhas do pai).
List<String> _ids(LeitorRefPrancha ref, Set<String> secoes) => [
  for (final MapEntry(key: id, value: e) in ref.elements.entries)
    if (secoes.contains(e.section) && e.kind != LeitorRefKind.inline) id,
];

Finder _k(String k) => find.byKey(ValueKey<String>(k));

void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'L23 — os 48 ids do véu e do painel nos lugares da prancha; os textos nas baselines',
    (tester) async {
      await _montar(tester);
      final ids = _ids(kRef23, const {'pen.fade', 'pen.penPanel'});
      expect(ids, hasLength(48));
      conferirGeometriaL23(tester, kRef23, ids);
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
    },
  );

  group('subtítulo (R8)', () {
    test(
      'ponta · espessura com 1 casa · nome da cor em minúsculas, ou o hex',
      () {
        final p = presetsTeste();
        expect(penPanelSubtitle(p), 'Esferográfica · 1,2 mm · coral');
        expect(
          penPanelSubtitle(
            p.copyWith(
              penTip: PenTip.fountain,
              penWidthMm: 2.0,
              penColor: '#1A1714',
            ),
          ),
          'Tinteiro · 2,0 mm · tinta preta',
        );
        expect(
          penPanelSubtitle(
            p.copyWith(penTip: PenTip.brush, penColor: '#12AB34'),
          ),
          'Pincel · 1,2 mm · #12AB34',
        );
        // só os 6 nomes da caneta: o amarelo do marca-texto sai pelo código
        expect(
          penPanelSubtitle(p.copyWith(penColor: '#FED170')),
          'Esferográfica · 1,2 mm · #FED170',
        );
      },
    );

    testWidgets('acompanha a sessão', (tester) async {
      final s = await _montar(tester);
      s.sessao.setPenColor('#058CD7');
      await tester.pump();
      expect(findAppText('Esferográfica · 1,2 mm · azul'), findsOneWidget);
    });
  });

  group('prévia (R9)', () {
    test('o traço da prévia: o caminho do arquivo, a ponta, a cor e a espessura × Fina/Média/Grossa × 17/11', () {
      final p = presetsTeste();
      final t = penPreviewStroke(p);
      expect(
        (t.tool, t.tip, t.argb),
        (InkTool.pen.code, tipCode(PenTip.ballpoint), 0xFFFF552E),
      );
      // 3,4 px a 1,2 mm na Média, como o arquivo
      expect(dpOfCentiMm(t.widthCentiMm), closeTo(3.4, 0.02));
      // o caminho do arquivo: do (14, 38) ao (290, 26) na caixa de 300×56, centrada nos 324 de dentro
      expect((t.points.first.x, t.points.first.y), (26.0, 38.0));
      expect(t.points.last.x, closeTo(302, 0.01));
      expect(t.points.last.y, closeTo(26, 0.01));
      expect(t.points.every((q) => q.pressure == 0.5), isTrue);
      final grossa = penPreviewStroke(
        p.copyWith(strokeSize: StrokeSize.thick, penWidthMm: 4.0),
      );
      expect(
        dpOfCentiMm(grossa.widthCentiMm),
        closeTo(4.0 * 1.8 * 17 / 6, 0.05),
      );
      final tinteiro = penPreviewStroke(
        p.copyWith(penTip: PenTip.fountain, penColor: '#552CB7'),
      );
      expect(
        (tinteiro.tip, tinteiro.argb),
        (tipCode(PenTip.fountain), 0xFF552CB7),
      );
      // os pontos são amostrados uma vez (o painel reconstrói com a sessão)
      expect(identical(tinteiro.points, t.points), isTrue);
    });

    testWidgets(
      'a faixa pautada e o traço nos pixels; leitor de tela "Prévia do traço"',
      (tester) async {
        final h = tester.ensureSemantics();
        await _montar(tester);
        expect(
          tester.getSemantics(_k('ann.penPanel.preview')),
          matchesSemantics(label: 'Prévia do traço', isImage: true),
        );
        final px = await _pixels(tester, _k('ann.penPanel.preview'));
        // o fio da pauta a 7,5–9 do topo de dentro (1,5 de borda): #E6DBC6; o fundo #F7F0E3
        expect(px(30, 1.5 + 8.2), const Color(0xFFE6DBC6));
        expect(px(30, 1.5 + 18), const Color(0xFFF7F0E3));
        // o traço coral passa pelo (14, 38) do caminho: (1,5 + 12 + 14, 1,5 + 38)
        expect(px(1.5 + 12 + 14.5, 1.5 + 38), const Color(0xFFFF552E));
        h.dispose();
      },
    );
  });

  group('pontas (R10)', () {
    testWidgets(
      'a ativa com a brand e a sombra 2/2; tocar troca; as amostras na cor da caneta',
      (tester) async {
        final s = await _montar(
          tester,
          presets: presetsTeste().copyWith(penColor: '#058CD7'),
        );
        NeoBox card(String n) =>
            tester.widget<NeoBox>(_k('ann.penPanel.tips.$n.box'));
        expect(card('ballpoint').color, AppColors.lavender);
        expect(card('ballpoint').shadow, const Offset(2, 2));
        expect(card('fountain').color, AppColors.paper);
        expect(card('fountain').shadow, isNull);
        final amostra = tester.widget<AppSvg>(
          _k('ann.penPanel.tips.fountain.sample'),
        );
        expect(amostra.colors, {AppColors.flame: const Color(0xFF058CD7)});
        await tester.tap(_k('ann.penPanel.tips.fountain'));
        await tester.pump();
        expect(s.sessao.presets.penTip, PenTip.fountain);
        expect(card('fountain').color, AppColors.lavender);
        expect(s.gravados, hasLength(1));
      },
    );

    testWidgets('leitor de tela: o grupo "Tipo de ponta" com a marcada', (
      tester,
    ) async {
      final h = tester.ensureSemantics();
      await _montar(tester);
      expect(
        tester.getSemantics(_k('ann.penPanel.tips')),
        isSemantics(label: 'Tipo de ponta'),
      );
      expect(
        tester.getSemantics(_k('ann.penPanel.tips.ballpoint')),
        isSemantics(
          label: 'Esferográfica',
          hasCheckedState: true,
          isChecked: true,
          isInMutuallyExclusiveGroup: true,
          hasTapAction: true,
        ),
      );
      h.dispose();
    });
  });

  group('espessura (R11, D-50)', () {
    testWidgets(
      'arrastar o botão até o fim: "4,0 mm" e grava uma vez, ao soltar',
      (tester) async {
        final s = await _montar(tester);
        final trilho = tester.getRect(_k('ann.penPanel.size.slider'));
        final g = await tester.startGesture(
          tester.getCenter(_k('ann.penPanel.size.slider.knob')),
        );
        await tester.pump();
        await g.moveTo(Offset(trilho.right + 40, trilho.center.dy));
        await tester.pump();
        expect(s.sessao.presets.penWidthMm, 4.0);
        expect(s.gravados, isEmpty);
        expect(findAppText('4,0 mm'), findsOneWidget);
        await g.up();
        await tester.pump();
        expect(s.gravados, hasLength(1));
        // o preenchimento vai até o meio do botão
        expect(
          tester.getRect(_k('ann.penPanel.size.slider.fill')).right,
          closeTo(331, 0.5),
        );
      },
    );

    testWidgets(
      'T01 — as pontas do trilho: a borda de tinta acompanha a curva (a hachura e o preenchimento ficam por dentro dela)',
      (tester) async {
        await _montar(tester);
        final trilho = tester.getRect(_k('ann.penPanel.size.slider'));
        final px = await _pixelsNaTela(tester, _k('ann.penPanel.size.slider'));
        // o meio da borda de 1,5 (raio 8 − 0,75) nas curvas das duas pontas, longe do topo e do pé retos
        final r = trilho.height / 2;
        for (final (centro, graus) in [
          (
            Offset(trilho.left + r, trilho.center.dy),
            [120, 135, 150, 210, 225, 240],
          ),
          (
            Offset(trilho.right - r, trilho.center.dy),
            [30, 45, 60, 300, 315, 330],
          ),
        ]) {
          for (final g in graus) {
            final p =
                centro + Offset.fromDirection(g * math.pi / 180, r - 0.75);
            final c = px(p.dx, p.dy);
            final distancia =
                (c.r - AppColors.ink.r).abs() +
                (c.g - AppColors.ink.g).abs() +
                (c.b - AppColors.ink.b).abs();
            expect(distancia, lessThan(0.15), reason: '$g° em $p: $c');
          }
        }
      },
    );

    testWidgets(
      'leitor de tela: "Espessura", "1,2 milímetro"; aumentar dá 1,3 e grava',
      (tester) async {
        final h = tester.ensureSemantics();
        final s = await _montar(tester);
        expect(
          tester.getSemantics(_k('ann.penPanel.size.slider')),
          matchesSemantics(
            label: 'Espessura',
            value: '1,2 milímetro',
            increasedValue: '1,3 milímetro',
            decreasedValue: '1,1 milímetro',
            isSlider: true,
            hasIncreaseAction: true,
            hasDecreaseAction: true,
          ),
        );
        tester.semantics.performAction(
          find.semantics.byLabel('Espessura'),
          SemanticsAction.increase,
        );
        await tester.pump();
        expect(s.sessao.presets.penWidthMm, 1.3);
        expect(s.gravados, hasLength(1));
        h.dispose();
      },
    );
  });

  group('favoritas (R12, D-175)', () {
    testWidgets('a marcada tem o aro duplo; tocar outra troca a cor e grava', (
      tester,
    ) async {
      final s = await _montar(tester);
      BoxDecoration d(String n) =>
          tester
                  .widget<DecoratedBox>(_k('ann.penPanel.favorites.$n.dot'))
                  .decoration
              as BoxDecoration;
      expect(d('coral').boxShadow, hasLength(2));
      expect(d('blue').boxShadow, isNull);
      await tester.tap(_k('ann.penPanel.favorites.blue'));
      await tester.pump();
      expect(s.sessao.presets.penColor, '#058CD7');
      expect(d('blue').boxShadow, hasLength(2));
      expect(s.gravados, hasLength(1));
    });

    testWidgets(
      'o "+" fica aceso como na prancha (D-248): com a cor atual já favorita, o toque não junta e mostra '
      '"Essa cor já está nas favoritas." por 4 s; com uma cor nova, junta e passa à 2ª fileira',
      (tester) async {
        final s = await _montar(tester);
        expect(_alpha(tester, 'ann.penPanel.favorites.add'), 1);
        final antes = s.sessao.presets.favoriteColors;
        await tester.tap(_k('ann.penPanel.favorites.add'));
        await tester.pump();
        expect(s.sessao.presets.favoriteColors, antes);
        expect(s.gravados, isEmpty);
        expect(findAppText('Essa cor já está nas favoritas.'), findsOneWidget);
        s.disparar(const Duration(seconds: 4));
        await tester.pump();
        expect(findAppText('Essa cor já está nas favoritas.'), findsNothing);
        final topoAntes = tester.getRect(_k('ann.penPanel')).top;
        s.sessao.setPenColor('#12AB34');
        await tester.pump();
        expect(_alpha(tester, 'ann.penPanel.favorites.add'), 1);
        await tester.tap(_k('ann.penPanel.favorites.add'));
        await tester.pump();
        expect(s.sessao.presets.favoriteColors.last, '#12AB34');
        // a 7ª favorita fecha a 1ª fileira; o "+" vai para a 2ª e o painel cresce para cima
        final setima = tester.getRect(_k('ann.penPanel.favorites.7'));
        expect(setima.left, closeTo(320.5, 0.5));
        final mais = tester.getRect(_k('ann.penPanel.favorites.add'));
        expect(mais.left, closeTo(35.5, 0.5));
        expect(mais.top - setima.top, closeTo(34 + 13.5, 0.5));
        expect(
          tester.getRect(_k('ann.penPanel')).top,
          closeTo(topoAntes - 47.5, 0.5),
        );
        expect(tester.getRect(_k('ann.penPanel')).bottom, closeTo(654, 0.5));
      },
    );

    testWidgets('com 12 favoritas, o "+" some', (tester) async {
      await _montar(
        tester,
        presets: presetsTeste().copyWith(
          favoriteColors: [
            for (var i = 0; i < 12; i++)
              '#0000${(i + 16).toRadixString(16).toUpperCase()}',
          ],
        ),
      );
      expect(_k('ann.penPanel.favorites.add'), findsNothing);
      expect(_k('ann.penPanel.favorites.12'), findsOneWidget);
    });

    testWidgets(
      'favoritas repetidas (de outro aparelho): a 1ª fica com o id do arquivo, a outra com o lugar',
      (tester) async {
        await _montar(
          tester,
          presets: presetsTeste().copyWith(
            favoriteColors: ['#FF552E', '#058CD7', '#ff552e'],
          ),
        );
        expect(tester.takeException(), isNull);
        expect(_k('ann.penPanel.favorites.coral'), findsOneWidget);
        expect(_k('ann.penPanel.favorites.blue'), findsOneWidget);
        expect(_k('ann.penPanel.favorites.3'), findsOneWidget);
      },
    );

    testWidgets(
      'pressão longa tira, com "Cor tirada das favoritas" e Desfazer, que põe de volta no lugar',
      (tester) async {
        final s = await _montar(tester);
        await tester.longPress(_k('ann.penPanel.favorites.blue'));
        await tester.pump();
        expect(s.sessao.presets.favoriteColors, isNot(contains('#058CD7')));
        expect(findAppText('Cor tirada das favoritas'), findsOneWidget);
        await tester.tap(_k('leitor.desfazer.botao'));
        await tester.pump();
        expect(s.sessao.presets.favoriteColors[2], '#058CD7');
        expect(findAppText('Cor tirada das favoritas'), findsNothing);
        // de novo; depois de 4 s a pílula some e a cor fica fora
        await tester.longPress(_k('ann.penPanel.favorites.blue'));
        await tester.pump();
        s.disparar(const Duration(seconds: 4));
        await tester.pump();
        expect(findAppText('Cor tirada das favoritas'), findsNothing);
        expect(s.sessao.presets.favoriteColors, isNot(contains('#058CD7')));
      },
    );

    testWidgets(
      'leitor de tela: "Cores favoritas", os nomes, "Tirar das favoritas" e o "+"',
      (tester) async {
        final h = tester.ensureSemantics();
        final s = await _montar(
          tester,
          presets: presetsTeste().copyWith(
            favoriteColors: ['#FF552E', '#12AB34'],
          ),
        );
        expect(
          tester.getSemantics(_k('ann.penPanel.favorites')),
          isSemantics(label: 'Cores favoritas'),
        );
        expect(
          tester.getSemantics(_k('ann.penPanel.favorites.coral')),
          isSemantics(
            label: 'Coral',
            hasCheckedState: true,
            isChecked: true,
            isInMutuallyExclusiveGroup: true,
            hasTapAction: true,
            hasLongPressAction: true,
            customActions: [
              const CustomSemanticsAction(label: 'Tirar das favoritas'),
            ],
          ),
        );
        expect(
          tester.getSemantics(_k('ann.penPanel.favorites.2')),
          isSemantics(label: 'Cor #12AB34'),
        );
        // D-248: aceso também com a cor já favorita (o toque avisa)
        expect(
          tester.getSemantics(_k('ann.penPanel.favorites.add')),
          isSemantics(
            label: 'Salvar a cor atual nas favoritas',
            isButton: true,
            hasTapAction: true,
          ),
        );
        s.sessao.setPenColor('#ABCDEF');
        await tester.pump();
        expect(
          tester.getSemantics(_k('ann.penPanel.favorites.add')),
          isSemantics(
            label: 'Salvar a cor atual nas favoritas',
            isButton: true,
            hasTapAction: true,
          ),
        );
        h.dispose();
      },
    );
  });

  group('seletor (R13, R14)', () {
    testWidgets(
      'arrastar na roda muda a cor, a prévia e o subtítulo; grava ao soltar',
      (tester) async {
        final s = await _montar(tester);
        final roda = tester.getRect(_k('ann.penPanel.picker.wheel'));
        final g = await tester.startGesture(roda.center + const Offset(0, 55));
        await tester.pump();
        await g.moveTo(roda.center + const Offset(0, 300));
        await tester.pump();
        // tom 180 (ciano) na borda
        expect(s.sessao.presets.penColor, '#00FFFF');
        expect(s.gravados, isEmpty);
        expect(findAppText('Esferográfica · 1,2 mm · #00FFFF'), findsOneWidget);
        await g.up();
        await tester.pump();
        expect(s.gravados, hasLength(1));
        // nenhuma favorita marcada
        expect(
          (tester
                      .widget<DecoratedBox>(
                        _k('ann.penPanel.favorites.coral.dot'),
                      )
                      .decoration
                  as BoxDecoration)
              .boxShadow,
          isNull,
        );
      },
    );

    testWidgets(
      'o hex: com o teclado aberto, o painel sobe até o campo ficar 8 acima dele (R14)',
      (tester) async {
        final s = await _montar(tester);
        await tester.tap(_k('ann.penPanel.picker.hex'));
        await tester.pump();
        // o teclado de 330 chega
        await montarPecasL23(tester, [
          Positioned.fill(
            child: PenPanelLayer(
              session: s.sessao,
              from: AnnotationTool.pen,
              bottom: _base,
              paper: ReaderPalette.of(ReaderPaper.creme).paper,
            ),
          ),
        ], teclado: const EdgeInsets.only(bottom: 330));
        await tester.pump();
        final campo = tester.getRect(_k('ann.penPanel.picker.hex'));
        expect(campo.bottom, closeTo(844 - 330 - 8, 0.5));
      },
    );
  });

  testWidgets(
    'Noite: o painel nas cores da ilha do Noite; as amostras e a roda como são (R26)',
    (tester) async {
      await _montar(tester, papel: ReaderPaper.noite);
      final caixa = tester.widget<Container>(_k('ann.penPanel'));
      expect((caixa.decoration! as BoxDecoration).color, AppColors.islandNight);
      expect(
        tester.widget<NeoBox>(_k('ann.penPanel.tips.fountain.box')).color,
        AppColors.paperNight,
      );
    },
  );
}

/// Os pixels (3×) da caixa [f], que fica numa `RepaintBoundary` própria; [px] lê o ponto em dp da caixa.
Future<Color Function(double, double)> _pixels(
  WidgetTester tester,
  Finder f,
) async {
  final img = await captureAt(tester, f);
  final rgba = await rgbaOf(tester, img);
  final w = img.width;
  return (x, y) {
    final i = ((y * 3).floor() * w + (x * 3).floor()) * 4;
    return Color.fromARGB(rgba[i + 3], rgba[i], rgba[i + 1], rgba[i + 2]);
  };
}

/// Os pixels (3×) da `RepaintBoundary` acima de [f]; [px] lê o ponto em dp da tela.
Future<Color Function(double, double)> _pixelsNaTela(
  WidgetTester tester,
  Finder f,
) async {
  RenderObject node = tester.renderObject(f);
  while (node is! RenderRepaintBoundary) {
    node = node.parent!;
  }
  final origem = node.localToGlobal(Offset.zero);
  final px = await _pixels(tester, f);
  return (x, y) => px(x - origem.dx, y - origem.dy);
}

/// O alfa do tracejado do "+" (apagado = 0,38).
double _alpha(WidgetTester tester, String id) {
  final paint = tester.widget<CustomPaint>(
    find.descendant(of: _k(id), matching: find.byType(CustomPaint)).first,
  );
  return (paint.painter! as DashedStadiumPainter).color.a;
}

import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/tokens/app_icons.dart';
import 'package:app_leitura/core/design_system/widgets/app_svg.dart';
import 'package:app_leitura/core/design_system/widgets/neo_box.dart';
import 'package:app_leitura/core/design_system/widgets/pill.dart';
import 'package:app_leitura/core/design_system/widgets/pressable.dart';
import 'package:app_leitura/features/home/presentation/covers/memorias_postumas_cover.dart';
import 'package:app_leitura/features/home/presentation/covers/o_cortico_cover.dart';
import 'package:app_leitura/features/home/presentation/covers/quincas_borba_cover.dart';
import 'package:app_leitura/features/home/presentation/sections/for_you_section.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../reference/reference_layout.dart';
import '../support/canvas.dart';
import '../support/geometry.dart';
import '../support/geometry_report.dart';
import '../support/load_fonts.dart';
import '../support/pump_app.dart';

Rect _rect(WidgetTester tester, String id) =>
    tester.getRect(find.byKey(ValueKey<String>(id)));

/// Retângulo relativo ao canto superior esquerdo da seção (a tabela da F08 usa essa origem).
Rect _rel(WidgetTester tester, String id) =>
    _rect(tester, id).shift(-_rect(tester, 'forYou').topLeft);

/// Alturas e posições que somam alturas de texto carregam o ruído float32 do SkParagraph (±1e-3).
const _eps = 1e-3;

/// Larguras medidas de texto: as fontes estáticas foram validadas contra o navegador com desvio
/// ≤ 0,05 px (§6.1 do prompt mestre).
const _textW = 0.05;

void _expectRect(Rect got, Rect exp, {String? reason, double eps = _eps}) {
  for (final (what, g, e) in [
    ('x', got.left, exp.left),
    ('y', got.top, exp.top),
    ('w', got.width, exp.width),
    ('h', got.height, exp.height),
  ]) {
    expect(g, moreOrLessEquals(e, epsilon: eps), reason: '$reason $what');
  }
}

T _parentOf<T extends Widget>(WidgetTester tester, String id) =>
    tester.widget<T>(
      find
          .ancestor(
            of: find.byKey(ValueKey<String>(id)),
            matching: find.byType(T),
          )
          .first,
    );

/// Retângulo do `AppText` sem Key dentro do widget com a Key [id].
Rect _textIn(WidgetTester tester, String id) => tester.getRect(
  find.descendant(
    of: find.byKey(ValueKey<String>(id)),
    matching: find.byType(AppText),
  ),
);

/// Retângulo da `Stack` filha direta da capa = padding box (116×174 menos a borda 1,5).
Rect _coverStack(WidgetTester tester, NeoBox cover) =>
    tester.getRect(find.byWidget(cover.child!));

/// Chaves dos filhos da `Stack` de uma capa, na ordem de pintura (o filho de cada `Positioned`).
List<Key?> _stackOrder(Stack stack) => [
  for (final child in stack.children) (child as Positioned).child.key,
];

/// `border-radius: 4px 10px 10px 4px` (ordem CSS: TL, TR, BR, BL), literal da especificação.
const _coverRadius = BorderRadius.only(
  topLeft: Radius.circular(4),
  topRight: Radius.circular(10),
  bottomRight: Radius.circular(10),
  bottomLeft: Radius.circular(4),
);

/// Caixa da capa (116×174, borda 1,5 tinta, raio 4/10/10/4, recorte, sem sombra, sem padding) e a
/// `Stack` filha direta.
Stack _expectCoverBox(WidgetTester tester, String id, Color color) {
  final neo = tester.widget<NeoBox>(find.byKey(ValueKey<String>(id)));
  expect((neo.width, neo.height), (116.0, 174.0), reason: id);
  expect(
    neo.border,
    const BorderSide(width: 1.5, color: AppColors.ink),
    reason: id,
  );
  expect(neo.radius, _coverRadius, reason: id);
  expect(neo.clip, isTrue, reason: id);
  expect(neo.shadow, isNull, reason: id);
  expect(neo.padding, EdgeInsets.zero, reason: id);
  expect(neo.color, color, reason: id);
  return neo.child! as Stack;
}

/// Lombada: `Positioned(left 0, top 0, bottom 0, width 7)` > NeoBox sem borda e sem raio (o recorte da
/// capa arredonda os cantos) com a Key `<capa>.spine`.
void _expectSpine(Stack stack, String id, Color color) {
  final spine = stack.children[0] as Positioned;
  expect(
    (spine.left, spine.top, spine.right, spine.bottom),
    (0.0, 0.0, null, 0.0),
    reason: id,
  );
  expect((spine.width, spine.height), (7.0, null), reason: id);
  final box = spine.child as NeoBox;
  expect(box.key, ValueKey('$id.spine'));
  expect(box.color, color, reason: id);
  expect(box.border, isNull, reason: id);
  expect(box.radius, BorderRadius.zero, reason: id);
  expect(box.shadow, isNull, reason: id);
}

/// Texto de cada linha visível de um `AppText` com a Key [id].
List<String> _lineTexts(WidgetTester tester, String id) => [
  for (final line
      in tester
          .renderObject<RenderAppText>(find.byKey(ValueKey<String>(id)))
          .debugLines())
    line.text,
];

/// Os três itens: prefixo das Keys, arte, cor do fundo e reticências no título.
const _items = [
  ('forYou.item1', MemoriasPostumasCover, AppColors.flame, true),
  ('forYou.item2', QuincasBorbaCover, AppColors.azure, false),
  ('forYou.item3', OCorticoCover, AppColors.emerald, false),
];

/// Tabela "Especificação pixel a pixel" da F08 (x, y, w, h relativos à seção), na ordem do arquivo.
const _table = [
  ('forYou', 0.0, 0.0, 350.0, 327.0),
  ('forYou.header', 0.0, 0.0, 350.0, 44.0),
  ('forYou.title', 0.0, 7.6, 109.35, 28.8),
  ('forYou.seeAll', 272.01, 0.0, 77.99, 44.0),
  ('forYou.seeAll.icon', 332.0, 13.0, 18.0, 18.0),
  ('forYou.reasonChip', 0.0, 58.0, 241.28, 32.6),
  ('forYou.reasonChip.icon', 11.5, 67.3, 14.0, 14.0),
  ('forYou.carousel', -20.0, 108.6, 390.0, 218.4),
  ('forYou.item1', 0.0, 108.6, 116.0, 218.4),
  ('forYou.item1.cover', 0.0, 108.6, 116.0, 174.0),
  ('forYou.item1.cover.spine', 1.5, 110.1, 7.0, 171.0),
  ('forYou.item1.cover.blob', 21.5, 223.1, 123.0, 116.0),
  ('forYou.item1.cover.title', 17.5, 126.1, 87.0, 54.15),
  ('forYou.item1.cover.author', 17.5, 261.29, 78.33, 7.81),
  ('forYou.item1.textBlock', 0.0, 292.6, 116.0, 34.4),
  ('forYou.item1.title', 0.0, 292.6, 116.0, 16.8),
  ('forYou.item1.author', 0.0, 311.4, 116.0, 15.6),
  ('forYou.item2', 130.0, 108.6, 116.0, 218.4),
  ('forYou.item2.cover', 130.0, 108.6, 116.0, 174.0),
  ('forYou.item2.cover.spine', 131.5, 110.1, 7.0, 171.0),
  ('forYou.item2.cover.lines', 147.5, 128.1, 81.0, 30.0),
  ('forYou.item2.cover.line1', 147.5, 128.1, 81.0, 6.0),
  ('forYou.item2.cover.line2', 147.5, 140.1, 56.7, 6.0),
  ('forYou.item2.cover.line3', 147.5, 152.1, 32.4, 6.0),
  ('forYou.item2.cover.textBlock', 147.5, 208.49, 87.0, 60.61),
  ('forYou.item2.cover.title', 147.5, 208.49, 87.0, 46.8),
  ('forYou.item2.cover.author', 147.5, 261.29, 87.0, 7.81),
  ('forYou.item2.textBlock', 130.0, 292.6, 116.0, 34.4),
  ('forYou.item2.title', 130.0, 292.6, 116.0, 16.8),
  ('forYou.item2.author', 130.0, 311.4, 116.0, 15.6),
  ('forYou.item3', 260.0, 108.6, 116.0, 218.4),
  ('forYou.item3.cover', 260.0, 108.6, 116.0, 174.0),
  ('forYou.item3.cover.spine', 261.5, 110.1, 7.0, 171.0),
  ('forYou.item3.cover.archOuter', 285.5, 132.1, 68.0, 80.0),
  ('forYou.item3.cover.archInner', 305.5, 166.1, 28.0, 46.0),
  ('forYou.item3.cover.textBlock', 277.5, 231.89, 87.0, 37.21),
  ('forYou.item3.cover.title', 277.5, 231.89, 87.0, 23.4),
  ('forYou.item3.cover.author', 277.5, 261.29, 87.0, 7.81),
  ('forYou.item3.textBlock', 260.0, 292.6, 116.0, 34.4),
  ('forYou.item3.title', 260.0, 292.6, 116.0, 16.8),
  ('forYou.item3.author', 260.0, 311.4, 116.0, 15.6),
];

/// F08 — camada 1 (geometria) e construção da seção `forYou`.
void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'F08 geometria: os 41 ids da seção forYou dentro da tolerância (canvas 390×2390)',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final ids = idsOfSection('forYou').toList();
      expect(ids, [
        'forYou',
        'forYou.header',
        'forYou.title',
        'forYou.seeAll',
        'forYou.seeAll.icon',
        'forYou.reasonChip',
        'forYou.reasonChip.icon',
        'forYou.carousel',
        'forYou.item1',
        'forYou.item1.cover',
        'forYou.item1.cover.spine',
        'forYou.item1.cover.blob',
        'forYou.item1.cover.title',
        'forYou.item1.cover.author',
        'forYou.item1.textBlock',
        'forYou.item1.title',
        'forYou.item1.author',
        'forYou.item2',
        'forYou.item2.cover',
        'forYou.item2.cover.spine',
        'forYou.item2.cover.lines',
        'forYou.item2.cover.line1',
        'forYou.item2.cover.line2',
        'forYou.item2.cover.line3',
        'forYou.item2.cover.textBlock',
        'forYou.item2.cover.title',
        'forYou.item2.cover.author',
        'forYou.item2.textBlock',
        'forYou.item2.title',
        'forYou.item2.author',
        'forYou.item3',
        'forYou.item3.cover',
        'forYou.item3.cover.spine',
        'forYou.item3.cover.archOuter',
        'forYou.item3.cover.archInner',
        'forYou.item3.cover.textBlock',
        'forYou.item3.cover.title',
        'forYou.item3.cover.author',
        'forYou.item3.textBlock',
        'forYou.item3.title',
        'forYou.item3.author',
      ]);
      expectGeometry(tester, ids);
      reportGeometry(tester, ids);
    },
  );

  testWidgets(
    '8.1 construção: Semantics(seção) > Column(stretch, min) [Padding(h 20) > cabeçalho, 14, Padding(h 20) > Align(centerLeft) > chip, 14 + 4, carrossel]; _fullBleed: Stack 0→390 com a Key forYou 20→370 como irmã',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final sectionFinder = find.byType(ForYouSection);
      final section = tester.widget<Semantics>(
        find
            .descendant(of: sectionFinder, matching: find.byType(Semantics))
            .first,
      );
      // O Semantics da seção é a raiz do build de ForYouSection (nada por fora dele).
      Widget? root;
      tester.element(sectionFinder).visitChildElements((e) => root = e.widget);
      expect(root, same(section));
      expect(section.container, isTrue);
      expect(section.explicitChildNodes, isTrue);
      expect(section.properties.label, 'Para você');

      final column = section.child! as Column;
      expect(column.crossAxisAlignment, CrossAxisAlignment.stretch);
      expect(column.mainAxisSize, MainAxisSize.min);
      expect(column.spacing, 0);
      expect(column.children.map((w) => w.runtimeType), const [
        Padding,
        SizedBox,
        Padding,
        SizedBox,
        RepaintBoundary, // F12 12.4: camada própria do carrossel
      ]);
      final headerPad = column.children[0] as Padding;
      expect(headerPad.padding, const EdgeInsets.symmetric(horizontal: 20));
      // O cabeçalho (SizedBox 44) é o filho de layout direto desse Padding.
      expect(_parentOf<Padding>(tester, 'forYou.header'), same(headerPad));
      final gap1 = column.children[1] as SizedBox;
      expect((gap1.width, gap1.height), (null, 14.0));
      final chipPad = column.children[2] as Padding;
      expect(chipPad.padding, const EdgeInsets.symmetric(horizontal: 20));
      final align = chipPad.child! as Align;
      expect(align.alignment, Alignment.centerLeft);
      expect((align.widthFactor, align.heightFactor), (null, null));
      expect(_parentOf<Align>(tester, 'forYou.reasonChip'), same(align));
      final gap2 = column.children[3] as SizedBox;
      expect((gap2.width, gap2.height), (null, 14.0 + 4));
      final carousel =
          (column.children[4] as RepaintBoundary).child!
              as SingleChildScrollView;
      expect(carousel.key, const ValueKey('forYou.carousel'));
      expect(carousel.scrollDirection, Axis.horizontal);
      expect(carousel.padding, const EdgeInsets.symmetric(horizontal: 20));
      expect(carousel.clipBehavior, Clip.hardEdge);
      // D-03: física da plataforma (sem physics próprio), da esquerda para a direita, repouso em 0.
      expect(carousel.physics, isNull);
      expect(carousel.reverse, isFalse);
      expect(carousel.controller, isNull);
      final row = carousel.child! as Row;
      expect(row.crossAxisAlignment, CrossAxisAlignment.start);
      expect(row.mainAxisAlignment, MainAxisAlignment.start);
      expect(row.spacing, 14);
      expect(row.children, hasLength(3));
      // Os 3 itens são os únicos links do carrossel; o chip (um <span>) não é interativo.
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('forYou.carousel')),
          matching: find.byType(Pressable),
        ),
        findsNWidgets(3),
      );
      expect(
        find.ancestor(
          of: find.byKey(const ValueKey('forYou.reasonChip')),
          matching: find.byType(Pressable),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('forYou.reasonChip')),
          matching: find.byType(Pressable),
        ),
        findsNothing,
      );

      // _fullBleed da tela: Stack de largura total [Positioned(20, 0, 20, 0) > IgnorePointer >
      // SizedBox.expand(Key forYou), ForYouSection]. A Key não é ancestral da seção.
      final stackFinder = find
          .ancestor(of: sectionFinder, matching: find.byType(Stack))
          .first;
      final stack = tester.widget<Stack>(stackFinder);
      expect(stack.children, hasLength(2));
      final marker = stack.children[0] as Positioned;
      expect(
        (marker.left, marker.top, marker.right, marker.bottom),
        (20.0, 0.0, 20.0, 0.0),
      );
      expect((marker.width, marker.height), (null, null));
      final ignore = marker.child as IgnorePointer;
      expect(ignore.ignoring, isTrue);
      final keyBox = ignore.child! as SizedBox;
      expect(keyBox.key, const ValueKey('forYou'));
      expect((keyBox.width, keyBox.height), (double.infinity, double.infinity));
      expect(keyBox.child, isNull);
      expect(stack.children[1], isA<ForYouSection>());
      expect(
        find.ancestor(
          of: sectionFinder,
          matching: find.byKey(const ValueKey('forYou')),
        ),
        findsNothing,
      );

      final stackRect = tester.getRect(stackFinder);
      final sectionRect = tester.getRect(sectionFinder);
      final keyRect = _rect(tester, 'forYou');
      _expectRect(
        stackRect,
        const Rect.fromLTWH(0, 1207.56, 390, 327),
        reason: 'Stack',
      );
      expect(sectionRect, stackRect);
      expect(keyRect.left, 20);
      expect(keyRect.right, 370);
      expect(keyRect.top, stackRect.top);
      expect(keyRect.bottom, stackRect.bottom);
      debugPrint(
        '[forYou] Stack $stackRect | seção $sectionRect | Key forYou $keyRect',
      );
    },
  );

  testWidgets(
    '8.1 cabeçalho 350 × 44 (space-between): título 109,35 × 28,8 a y + 7,6; "Ver tudo" com 44 de altura na direita: texto 55,99 + 4 + seta 18 em (332; 13), texto centrado; seção 327 = 44 + 14 + 32,6 + 18 + 218,4',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final headerBox = tester.widget<SizedBox>(
        find.byKey(const ValueKey('forYou.header')),
      );
      expect((headerBox.width, headerBox.height), (null, 44.0));
      final row = headerBox.child! as Row;
      expect(row.mainAxisAlignment, MainAxisAlignment.spaceBetween);
      expect(row.crossAxisAlignment, CrossAxisAlignment.center);
      expect(row.children, hasLength(2));
      final h3 = row.children[0] as Semantics;
      expect(h3.container, isTrue);
      expect(h3.properties.header, isTrue);
      expect(h3.child!.key, const ValueKey('forYou.title'));
      final link = row.children[1] as Pressable;
      expect(link.isLink, isTrue);
      expect(link.semanticsLabel, isNull);
      final seeAll = link.child as SizedBox;
      expect(seeAll.key, const ValueKey('forYou.seeAll'));
      expect((seeAll.width, seeAll.height), (null, 44.0));
      final seeAllRow = seeAll.child! as Row;
      expect(seeAllRow.mainAxisSize, MainAxisSize.min);
      expect(seeAllRow.spacing, 4);
      expect(seeAllRow.crossAxisAlignment, CrossAxisAlignment.center);
      expect(seeAllRow.children, hasLength(2));
      expect(seeAllRow.children[0], isA<AppText>());
      final icon = seeAllRow.children[1] as AppSvg;
      expect(icon.key, const ValueKey('forYou.seeAll.icon'));
      expect(icon.asset, AppIcons.arrowRight);
      expect(icon.size, 18);

      final header = _rel(tester, 'forYou.header');
      expect(header, const Rect.fromLTWH(0, 0, 350, 44));
      final title = _rel(tester, 'forYou.title');
      expect(title.left, 0);
      expect(title.width, moreOrLessEquals(109.35, epsilon: _textW));
      expect(title.height, moreOrLessEquals(28.8, epsilon: _eps));
      // 28,8 centrado nos 44 → y + 7,6.
      expect(title.top, moreOrLessEquals(7.6, epsilon: _eps));

      final link0 = _rel(tester, 'forYou.seeAll');
      final arrow = _rel(tester, 'forYou.seeAll.icon');
      final text = _textIn(
        tester,
        'forYou.seeAll',
      ).shift(-_rect(tester, 'forYou').topLeft);
      expect(link0.right, moreOrLessEquals(350, epsilon: 1e-9));
      expect(link0.top, 0);
      expect(link0.height, 44);
      expect(text.left, moreOrLessEquals(link0.left, epsilon: 1e-9));
      expect(text.width, moreOrLessEquals(55.99, epsilon: _textW));
      expect(arrow.left - text.right, moreOrLessEquals(4, epsilon: 1e-9));
      expect(arrow.right, moreOrLessEquals(350, epsilon: 1e-9));
      expect(arrow, const Rect.fromLTWH(332, 13, 18, 18));
      expect(link0.width, moreOrLessEquals(text.width + 4 + 18, epsilon: 1e-9));
      // Área de toque = a caixa inteira do link (78 × 44), não só o texto.
      expect(
        tester
            .getRect(find.byWidget(link))
            .shift(-_rect(tester, 'forYou').topLeft),
        link0,
      );
      // Texto 14 / normal (16,8) centrado verticalmente nos 44.
      expect(text.height, moreOrLessEquals(16.8, epsilon: _eps));
      expect(
        text.top - link0.top,
        moreOrLessEquals(link0.bottom - text.bottom, epsilon: _eps),
      );
      expect(text.top, moreOrLessEquals(13.6, epsilon: _eps));

      // Coluna da seção: 44 + 14 + 32,6 + 18 + 218,4 = 327.
      final chip = _rel(tester, 'forYou.reasonChip');
      final carousel = _rel(tester, 'forYou.carousel');
      expect(chip.top - header.bottom, moreOrLessEquals(14, epsilon: 1e-9));
      expect(carousel.top - chip.bottom, moreOrLessEquals(18, epsilon: _eps));
      expect(
        _rel(tester, 'forYou').height,
        moreOrLessEquals(44 + 14 + 32.6 + 18 + 218.4, epsilon: _eps),
      );
      expect(
        carousel.bottom,
        moreOrLessEquals(_rel(tester, 'forYou').bottom, epsilon: _eps),
      );
      debugPrint(
        '[forYou] título ${title.size} em y +${title.top.toStringAsFixed(3)} | "Ver tudo" $link0 '
        '(texto ${text.width.toStringAsFixed(3)} × ${text.height.toStringAsFixed(3)} em y +${text.top.toStringAsFixed(3)}) | '
        'seta $arrow | seção ${_rel(tester, 'forYou').height.toStringAsFixed(4)}',
      );
    },
  );

  testWidgets(
    '8.2 chip: Pill(padding 10/7/12/7, borda 1,5) > Row(min, gap 6) [brilho 14, texto] → 241,28 × 32,6; brilho em (11,5; 9,3); texto 6 depois do ícone e 12 + 1,5 antes da borda direita',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final pill = tester.widget<Pill>(
        find.byKey(const ValueKey('forYou.reasonChip')),
      );
      expect(pill.padding, const EdgeInsets.fromLTRB(10, 7, 12, 7));
      expect(pill.border, const BorderSide(width: 1.5, color: AppColors.ink));
      expect(pill.color, AppColors.surface);
      final row = pill.child as Row;
      expect(row.mainAxisSize, MainAxisSize.min);
      expect(row.spacing, 6);
      expect(row.crossAxisAlignment, CrossAxisAlignment.center);
      expect(row.children, hasLength(2));
      final icon = row.children[0] as AppSvg;
      expect(icon.key, const ValueKey('forYou.reasonChip.icon'));
      expect(icon.asset, AppIcons.sparkleSolid);
      expect(icon.size, 14);
      expect(row.children[1], isA<AppText>());

      final chip = _rect(tester, 'forYou.reasonChip');
      final sparkle = _rect(tester, 'forYou.reasonChip.icon');
      final text = _textIn(tester, 'forYou.reasonChip');
      expect(_rel(tester, 'forYou.reasonChip').topLeft, const Offset(0, 58));
      // 1,5 + 7 + 15,6 + 7 + 1,5.
      expect(text.height, moreOrLessEquals(15.6, epsilon: _eps));
      expect(chip.height, moreOrLessEquals(32.6, epsilon: _eps));
      // Brilho 14 centrado na linha de 15,6 (+0,8) → (1,5 + 10; 1,5 + 7 + 0,8).
      expect(sparkle.size, const Size(14, 14));
      expect(sparkle.left - chip.left, moreOrLessEquals(11.5, epsilon: 1e-9));
      expect(sparkle.top - chip.top, moreOrLessEquals(9.3, epsilon: _eps));
      expect(text.left - sparkle.right, moreOrLessEquals(6, epsilon: 1e-9));
      expect(text.top - chip.top, moreOrLessEquals(8.5, epsilon: _eps));
      expect(
        chip.right - text.right,
        moreOrLessEquals(12 + 1.5, epsilon: 1e-9),
      );
      expect(
        chip.width,
        moreOrLessEquals(
          1.5 + 10 + 14 + 6 + text.width + 12 + 1.5,
          epsilon: 1e-9,
        ),
      );
      expect(text.width, moreOrLessEquals(196.28, epsilon: _textW));
      expect(chip.width, moreOrLessEquals(241.28, epsilon: _textW));
      debugPrint(
        '[forYou] chip ${chip.width.toStringAsFixed(3)} × ${chip.height.toStringAsFixed(3)} | '
        'brilho em (${(sparkle.left - chip.left).toStringAsFixed(3)}; ${(sparkle.top - chip.top).toStringAsFixed(3)}) | '
        'texto ${text.width.toStringAsFixed(3)}',
      );
    },
  );

  testWidgets(
    '8.3 carrossel 0→390 × 218,4, 18 abaixo do chip; itens em 20, 150, 280 (gap 14, largura 116); 3º item de 280 a 396 (6 além do viewport); conteúdo 416',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final carouselFinder = find.byKey(const ValueKey('forYou.carousel'));
      final carousel = _rect(tester, 'forYou.carousel');
      expect(carousel.left, 0);
      expect(carousel.width, 390);
      expect(carousel.height, moreOrLessEquals(218.4, epsilon: _eps));
      expect(
        carousel.top - _rect(tester, 'forYou.reasonChip').bottom,
        moreOrLessEquals(14 + 4, epsilon: _eps),
      );
      // A Row filha direta do SingleChildScrollView (não uma Row qualquer de dentro dos itens).
      final rowRect = tester.getRect(
        find.byWidget(
          tester.widget<SingleChildScrollView>(carouselFinder).child!,
        ),
      );
      // 3 × 116 + 2 × 14 = 376, a partir do padding 20.
      expect(rowRect.left, 20);
      expect(rowRect.width, 376);
      expect(rowRect.top, carousel.top);
      expect(rowRect.height, moreOrLessEquals(218.4, epsilon: _eps));
      for (final (i, (id, _, _, _)) in _items.indexed) {
        final item = _rect(tester, id);
        expect(item.left, 20 + i * (116 + 14), reason: id);
        expect(item.width, 116, reason: id);
        expect(item.top, carousel.top, reason: id);
        expect(item.height, moreOrLessEquals(218.4, epsilon: _eps));
      }
      final item1 = _rect(tester, 'forYou.item1');
      final item2 = _rect(tester, 'forYou.item2');
      final item3 = _rect(tester, 'forYou.item3');
      expect(item2.left - item1.right, 14);
      expect(item3.left - item2.right, 14);
      expect(item1.left - carousel.left, 20); // padding do carrossel
      expect((item3.left, item3.right), (280.0, 396.0));
      expect(item3.right - carousel.right, 6);

      final position = tester
          .state<ScrollableState>(
            find.descendant(
              of: carouselFinder,
              matching: find.byType(Scrollable),
            ),
          )
          .position;
      // Conteúdo 20 + 376 + 20 = 416 − viewport 390 = 26 de rolagem (D-03); repouso em 0.
      expect(position.axis, Axis.horizontal);
      expect(position.pixels, 0);
      expect(position.minScrollExtent, 0);
      expect(position.viewportDimension, 390);
      expect(position.maxScrollExtent, 26);
      expect(position.viewportDimension + position.maxScrollExtent, 416);
      debugPrint(
        '[forYou] carrossel $carousel | linha $rowRect | 3º item $item3 | '
        'extensão ${position.maxScrollExtent} (viewport ${position.viewportDimension})',
      );
    },
  );

  testWidgets(
    '8.3 itens: Pressable(link, sem rótulo) > SizedBox(116) > Column(stretch, min, gap 10) [capa 116×174, bloco Column(stretch, min, gap 2): título 16,8 + autor 15,6 = 34,4]',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      for (final (id, art, color, ellipsis) in _items) {
        final pressable = _parentOf<Pressable>(tester, id);
        expect(pressable.isLink, isTrue, reason: id);
        expect(pressable.semanticsLabel, isNull, reason: id);
        final box = pressable.child as SizedBox;
        expect(box.key, ValueKey(id));
        expect((box.width, box.height), (116.0, null), reason: id);
        final column = box.child! as Column;
        expect(column.crossAxisAlignment, CrossAxisAlignment.stretch);
        expect(column.mainAxisSize, MainAxisSize.min);
        expect(column.spacing, 10);
        expect(column.children, hasLength(2));
        expect(column.children[0].runtimeType, art, reason: id);
        expect(
          tester.widget<NeoBox>(find.byKey(ValueKey('$id.cover'))).color,
          color,
          reason: id,
        );
        expect(column.children[1].key, ValueKey('$id.textBlock'));
        final block = column.children[1] as Column;
        expect(block.crossAxisAlignment, CrossAxisAlignment.stretch);
        expect(block.mainAxisSize, MainAxisSize.min);
        expect(block.spacing, 2);
        expect(block.children.map((w) => w.key), [
          ValueKey('$id.title'),
          ValueKey('$id.author'),
        ]);
        final title = block.children[0] as AppText;
        final author = block.children[1] as AppText;
        // Só o 1º título tem nowrap + ellipsis.
        expect(title.maxLines, ellipsis ? 1 : null, reason: id);
        expect(title.ellipsis, ellipsis, reason: id);
        expect((author.maxLines, author.ellipsis), (null, false));
        // Renderizado: uma linha cada; só o 1º título estoura e sai com "…" ("Memórias Póstu…").
        final titleRender = tester.renderObject<RenderAppText>(
          find.byKey(ValueKey('$id.title')),
        );
        expect(titleRender.debugLines(), hasLength(1), reason: id);
        expect(titleRender.debugDidExceedMaxLines, ellipsis, reason: id);
        expect(_lineTexts(tester, '$id.author'), hasLength(1), reason: id);

        final item = _rect(tester, id);
        // O item inteiro é o <a>: a área de toque é a caixa 116 × 218,4 toda.
        expect(tester.getRect(find.byWidget(pressable)), item, reason: id);
        final cover = _rect(tester, '$id.cover');
        final blockRect = _rect(tester, '$id.textBlock');
        final titleRect = _rect(tester, '$id.title');
        final authorRect = _rect(tester, '$id.author');
        expect(cover, item.topLeft & const Size(116, 174), reason: id);
        expect(blockRect.top - cover.bottom, 10, reason: id);
        expect(blockRect.left, item.left, reason: id);
        expect(blockRect.width, 116, reason: id);
        expect(blockRect.height, moreOrLessEquals(34.4, epsilon: _eps));
        expect(
          blockRect.bottom,
          moreOrLessEquals(item.bottom, epsilon: _eps),
          reason: id,
        );
        expect(titleRect.topLeft, blockRect.topLeft, reason: id);
        expect(titleRect.width, 116, reason: id);
        expect(titleRect.height, moreOrLessEquals(16.8, epsilon: _eps));
        expect(
          authorRect.top - titleRect.bottom,
          moreOrLessEquals(2, epsilon: 1e-9),
          reason: id,
        );
        expect(authorRect.width, 116, reason: id);
        expect(authorRect.height, moreOrLessEquals(15.6, epsilon: _eps));
        expect(
          item.height,
          moreOrLessEquals(174 + 10 + 34.4, epsilon: _eps),
          reason: id,
        );
      }
    },
  );

  testWidgets(
    '8.4 capa Memórias: NeoBox 116×174 (borda 1,5, raio 4/10/10/4, recorte) > Stack [lombada, elipse OvalBorder 123×116, título 87 em 3 linhas, autor só com left/bottom]',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      const id = 'forYou.item1.cover';
      final stack = _expectCoverBox(tester, id, AppColors.flame);
      final neo = tester.widget<NeoBox>(find.byKey(const ValueKey(id)));
      expect(_stackOrder(stack), const [
        ValueKey('$id.spine'),
        ValueKey('$id.blob'),
        ValueKey('$id.title'),
        ValueKey('$id.author'),
      ]);
      _expectSpine(stack, id, AppColors.spine15);
      final blob = stack.children[1] as Positioned;
      expect(
        (blob.left, blob.top, blob.right, blob.bottom),
        (20.0, null, -30.0, -58.0),
      );
      expect((blob.width, blob.height), (null, 116.0));
      final oval = blob.child as DecoratedBox;
      final shape = oval.decoration as ShapeDecoration;
      // border-radius 50% numa caixa 123 × 116 = elipse; nunca BoxShape.circle nem borda/sombra.
      expect(
        shape,
        const ShapeDecoration(shape: OvalBorder(), color: AppColors.ink),
      );
      expect(shape.shape, const OvalBorder());
      expect(oval.position, DecorationPosition.background);
      final title = stack.children[2] as Positioned;
      expect(
        (title.left, title.top, title.right, title.bottom),
        (16.0, 16.0, 10.0, null),
      );
      expect((title.width, title.height), (null, null));
      final author = stack.children[3] as Positioned;
      expect(
        (author.left, author.top, author.right, author.bottom),
        (16.0, null, null, 12.0),
      );
      expect((author.width, author.height), (null, null));

      final cover = _rect(tester, id);
      final pad = _coverStack(tester, neo);
      expect(pad, cover.deflate(1.5));
      expect(_rect(tester, '$id.spine'), pad.topLeft & const Size(7, 171));
      final blobRect = _rect(tester, '$id.blob');
      // left 20 / right −30 / bottom −58, altura 116 → 123 × 116 (elipse, não círculo).
      expect(blobRect.size, const Size(123, 116));
      expect(blobRect.topLeft - pad.topLeft, const Offset(20, 113));
      expect(blobRect.right - pad.right, 30);
      expect(blobRect.bottom - pad.bottom, 58);
      final titleRect = _rect(tester, '$id.title');
      expect(titleRect.topLeft - pad.topLeft, const Offset(16, 16));
      expect(titleRect.width, 87);
      expect(pad.right - titleRect.right, 10);
      // 3 linhas × 19 × 0,95.
      expect(titleRect.height, moreOrLessEquals(3 * 18.05, epsilon: _eps));
      // Quebras obrigatórias em 87 de largura.
      expect(_lineTexts(tester, '$id.title'), const [
        'Memórias',
        'Póstumas de',
        'Brás Cubas',
      ]);
      final authorRect = _rect(tester, '$id.author');
      expect(authorRect.left - pad.left, 16);
      expect(
        pad.bottom - authorRect.bottom,
        moreOrLessEquals(12, epsilon: _eps),
      );
      // Sem right: a largura é a do texto (78,33) numa linha só, não 87.
      expect(_lineTexts(tester, '$id.author'), const ['MACHADO DE ASSIS']);
      expect(authorRect.width, moreOrLessEquals(78.33, epsilon: _textW));
      expect(authorRect.height, moreOrLessEquals(7.8, epsilon: _eps));
      debugPrint(
        '[forYou] $id: padding box $pad | elipse $blobRect | título ${titleRect.size} | '
        'autor ${authorRect.width.toStringAsFixed(3)} × ${authorRect.height.toStringAsFixed(3)} em y ${authorRect.top.toStringAsFixed(3)}',
      );
    },
  );

  testWidgets(
    '8.5 capa Quincas: Stack [lombada, Positioned(16, 18, 16) > Column(stretch, min, gap 6) de FractionallySizedBox(1 | ,7 | ,4, centerLeft) > SizedBox(6), Positioned(16, 10, bottom 12) > Column(stretch, min, gap 6)]',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      const id = 'forYou.item2.cover';
      final stack = _expectCoverBox(tester, id, AppColors.azure);
      final neo = tester.widget<NeoBox>(find.byKey(const ValueKey(id)));
      expect(_stackOrder(stack), const [
        ValueKey('$id.spine'),
        ValueKey('$id.lines'),
        ValueKey('$id.textBlock'),
      ]);
      _expectSpine(stack, id, AppColors.spine18);
      final linesPos = stack.children[1] as Positioned;
      expect(
        (linesPos.left, linesPos.top, linesPos.right, linesPos.bottom),
        (16.0, 18.0, 16.0, null),
      );
      expect((linesPos.width, linesPos.height), (null, null));
      final lines = linesPos.child as Column;
      expect(lines.crossAxisAlignment, CrossAxisAlignment.stretch);
      expect(lines.mainAxisSize, MainAxisSize.min);
      expect(lines.spacing, 6);
      expect(lines.children, hasLength(3));
      final blockPos = stack.children[2] as Positioned;
      expect(
        (blockPos.left, blockPos.top, blockPos.right, blockPos.bottom),
        (16.0, null, 10.0, 12.0),
      );
      expect((blockPos.width, blockPos.height), (null, null));
      final block = blockPos.child as Column;
      expect(block.crossAxisAlignment, CrossAxisAlignment.stretch);
      expect(block.mainAxisSize, MainAxisSize.min);
      expect(block.spacing, 6);
      expect(block.children.map((w) => w.key), const [
        ValueKey('$id.title'),
        ValueKey('$id.author'),
      ]);

      final pad = _coverStack(tester, neo);
      expect(pad, _rect(tester, id).deflate(1.5));
      expect(_rect(tester, '$id.spine'), pad.topLeft & const Size(7, 171));
      final linesRect = _rect(tester, '$id.lines');
      expect(linesRect, Rect.fromLTWH(pad.left + 16, pad.top + 18, 81, 30));
      for (final (i, factor) in [1.0, .7, .4].indexed) {
        final barId = '$id.line${i + 1}';
        final fractionFinder = find
            .ancestor(
              of: find.byKey(ValueKey(barId)),
              matching: find.byType(FractionallySizedBox),
            )
            .first;
        final fraction = tester.widget<FractionallySizedBox>(fractionFinder);
        expect(fraction.widthFactor, factor, reason: barId);
        expect(fraction.heightFactor, isNull, reason: barId);
        expect(fraction.alignment, Alignment.centerLeft, reason: barId);
        final bar = fraction.child! as SizedBox;
        expect(bar.key, ValueKey(barId));
        expect((bar.width, bar.height), (null, 6.0), reason: barId);
        final paint = bar.child! as DecoratedBox;
        expect(
          paint.decoration,
          const BoxDecoration(
            color: AppColors.paper,
            borderRadius: BorderRadius.all(Radius.circular(6)),
          ),
        );
        // Com o stretch, o FractionallySizedBox mede a coluna toda (81) e a barra fica à esquerda.
        final slot = tester.getRect(fractionFinder);
        expect(
          slot,
          Rect.fromLTWH(linesRect.left, linesRect.top + i * 12, 81, 6),
          reason: barId,
        );
        final barRect = _rect(tester, barId);
        expect(barRect.left, linesRect.left, reason: barId);
        expect(barRect.top, linesRect.top + i * 12, reason: barId);
        expect(barRect.width, moreOrLessEquals(81 * factor, epsilon: 1e-9));
        expect(barRect.height, 6, reason: barId);
        debugPrint('[forYou] $barId: $barRect (fração $factor)');
      }

      final blockRect = _rect(tester, '$id.textBlock');
      final titleRect = _rect(tester, '$id.title');
      final authorRect = _rect(tester, '$id.author');
      expect(blockRect.left - pad.left, 16);
      expect(blockRect.width, 87);
      expect(
        pad.bottom - blockRect.bottom,
        moreOrLessEquals(12, epsilon: _eps),
      );
      // "Quincas⏎Borba": 2 × 26 × 0,9; autor 6,5 × 1,2.
      expect(_lineTexts(tester, '$id.title'), const ['Quincas', 'Borba']);
      expect(_lineTexts(tester, '$id.author'), const ['MACHADO DE ASSIS']);
      expect(titleRect.height, moreOrLessEquals(2 * 23.4, epsilon: _eps));
      expect(authorRect.height, moreOrLessEquals(7.8, epsilon: _eps));
      expect(titleRect.topLeft, blockRect.topLeft);
      expect(titleRect.width, 87);
      expect(authorRect.width, 87);
      expect(
        authorRect.top - titleRect.bottom,
        moreOrLessEquals(6, epsilon: 1e-9),
      );
      expect(blockRect.height, moreOrLessEquals(46.8 + 6 + 7.8, epsilon: _eps));
      debugPrint(
        '[forYou] $id: bloco ${blockRect.width} × ${blockRect.height.toStringAsFixed(4)} em y '
        '${(blockRect.top - pad.top).toStringAsFixed(4)} da padding box',
      );
    },
  );

  testWidgets(
    '8.6 capa O Cortiço: Stack [lombada, arco Positioned(24, 22) 68×80, arco Positioned(44, 56) 28×46, Positioned(16, 10, bottom 12) > Column(stretch, min, gap 6)]',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      const id = 'forYou.item3.cover';
      final stack = _expectCoverBox(tester, id, AppColors.emerald);
      final neo = tester.widget<NeoBox>(find.byKey(const ValueKey(id)));
      expect(_stackOrder(stack), const [
        ValueKey('$id.spine'),
        ValueKey('$id.archOuter'),
        ValueKey('$id.archInner'),
        ValueKey('$id.textBlock'),
      ]);
      _expectSpine(stack, id, AppColors.spine18);
      for (final (i, (arch, left, top, w, h, r, color)) in const [
        ('archOuter', 24.0, 22.0, 68.0, 80.0, 34.0, AppColors.sun),
        ('archInner', 44.0, 56.0, 28.0, 46.0, 14.0, AppColors.emerald),
      ].indexed) {
        final pos = stack.children[1 + i] as Positioned;
        expect(
          (pos.left, pos.top, pos.right, pos.bottom),
          (left, top, null, null),
          reason: arch,
        );
        expect((pos.width, pos.height), (w, h), reason: arch);
        final box = pos.child as NeoBox;
        expect(box.color, color, reason: arch);
        expect(
          box.radius,
          BorderRadius.only(
            topLeft: Radius.circular(r),
            topRight: Radius.circular(r),
          ),
          reason: arch,
        );
        expect(box.border, isNull, reason: arch);
        expect(box.shadow, isNull, reason: arch);
        expect((box.width, box.height), (null, null), reason: arch);
      }
      final blockPos = stack.children[3] as Positioned;
      expect(
        (blockPos.left, blockPos.top, blockPos.right, blockPos.bottom),
        (16.0, null, 10.0, 12.0),
      );
      expect((blockPos.width, blockPos.height), (null, null));
      final block = blockPos.child as Column;
      expect(block.crossAxisAlignment, CrossAxisAlignment.stretch);
      expect(block.mainAxisSize, MainAxisSize.min);
      expect(block.spacing, 6);
      expect(block.children.map((w) => w.key), const [
        ValueKey('$id.title'),
        ValueKey('$id.author'),
      ]);

      final pad = _coverStack(tester, neo);
      expect(pad, _rect(tester, id).deflate(1.5));
      expect(_rect(tester, '$id.spine'), pad.topLeft & const Size(7, 171));
      expect(
        _rect(tester, '$id.archOuter'),
        Rect.fromLTWH(pad.left + 24, pad.top + 22, 68, 80),
      );
      expect(
        _rect(tester, '$id.archInner'),
        Rect.fromLTWH(pad.left + 44, pad.top + 56, 28, 46),
      );
      // Os dois arcos terminam na mesma linha (22 + 80 = 56 + 46 = 102): a "porta" fica no chão.
      expect(
        _rect(tester, '$id.archOuter').bottom,
        _rect(tester, '$id.archInner').bottom,
      );
      final blockRect = _rect(tester, '$id.textBlock');
      final titleRect = _rect(tester, '$id.title');
      final authorRect = _rect(tester, '$id.author');
      expect(blockRect.left - pad.left, 16);
      expect(blockRect.width, 87);
      expect(
        pad.bottom - blockRect.bottom,
        moreOrLessEquals(12, epsilon: _eps),
      );
      // "O Cortiço" numa linha: 26 × 0,9; autor 6,5 × 1,2.
      expect(_lineTexts(tester, '$id.title'), const ['O Cortiço']);
      expect(_lineTexts(tester, '$id.author'), const ['ALUÍSIO AZEVEDO']);
      expect(titleRect.height, moreOrLessEquals(23.4, epsilon: _eps));
      expect(authorRect.height, moreOrLessEquals(7.8, epsilon: _eps));
      expect(titleRect.topLeft, blockRect.topLeft);
      // stretch: título e autor com os 87 do bloco (left 16 / right 10).
      expect(titleRect.width, 87);
      expect(authorRect.width, 87);
      expect(authorRect.left, blockRect.left);
      expect(
        authorRect.top - titleRect.bottom,
        moreOrLessEquals(6, epsilon: 1e-9),
      );
      expect(blockRect.height, moreOrLessEquals(23.4 + 6 + 7.8, epsilon: _eps));
      expect(
        authorRect.bottom,
        moreOrLessEquals(blockRect.bottom, epsilon: _eps),
      );
      debugPrint(
        '[forYou] $id: bloco ${blockRect.width} × ${blockRect.height.toStringAsFixed(4)} em y '
        '${(blockRect.top - pad.top).toStringAsFixed(4)} da padding box',
      );
    },
  );

  testWidgets(
    'posições da tabela da F08 relativas à seção: origem (20; 1207,56) e as 41 linhas (x, y, w, h)',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final origin = _rect(tester, 'forYou').topLeft;
      expect(origin.dx, 20);
      expect(origin.dy, moreOrLessEquals(1207.56, epsilon: _eps));
      expect(
        _table.map((e) => e.$1),
        idsOfSection('forYou'),
        reason: 'a tabela cobre os 41 ids, na ordem',
      );
      var worst = ('', '', 0.0);
      for (final (id, x, y, w, h) in _table) {
        // A tabela é a referência absoluta menos a origem da seção.
        final ref = kRefLayout[id]!.rect;
        _expectRect(
          Rect.fromLTWH(x, y, w, h).shift(const Offset(20, 1207.56)),
          ref,
          reason: '$id (tabela + origem × referência)',
          eps: 1e-6,
        );
        final got = _rel(tester, id);
        final tolX = kTextDependentX.contains(id) ? 1.0 : 0.5;
        for (final (what, g, e, tol) in [
          ('x', got.left, x, tolX),
          ('y', got.top, y, 0.5),
          ('w', got.width, w, tolX),
          ('h', got.height, h, 0.5),
        ]) {
          expect(g, moreOrLessEquals(e, epsilon: tol), reason: '$id $what');
          if ((g - e).abs() > worst.$3.abs()) worst = (id, what, g - e);
        }
        debugPrint(
          '[tabela] $id: obtido (${got.left.toStringAsFixed(3)}, ${got.top.toStringAsFixed(3)}, '
          '${got.width.toStringAsFixed(3)}, ${got.height.toStringAsFixed(3)}) | tabela ($x, $y, $w, $h)',
        );
      }
      debugPrint(
        '[tabela] maior desvio ${worst.$1}.${worst.$2} = ${worst.$3.toStringAsFixed(4)}',
      );
      // Além do gate do §7: fora da largura medida dos textos (≤ 0,05, §6.1) só sobram o arredondamento
      // da tabela (0,005) e a altura "normal" da Figtree 6,5 (7,8 aqui, 7,81 no navegador).
      expect(worst.$3.abs(), lessThanOrEqualTo(_textW));
    },
  );

  testWidgets(
    'a referência da seção confere com a soma do CSS (sanidade dos dados)',
    (tester) async {
      // 766,76 + 400,8 + 40 = 1207,56; 1207,56 + 327 = 1534,56; a seção seguinte começa 40 abaixo.
      expect(
        kRefSections['forYou'],
        const Rect.fromLTWH(20, 1207.56, 350, 327),
      );
      expect(
        kRefSections['forYou']!.top,
        moreOrLessEquals(kRefSections['today']!.bottom + 40, epsilon: 1e-9),
      );
      expect(
        kRefSections['club']!.top,
        moreOrLessEquals(1207.56 + 327 + 40, epsilon: 1e-9),
      );
      expect(kRefLayout['forYou']!.rect, kRefSections['forYou']);
    },
  );
}

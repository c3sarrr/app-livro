import 'dart:math' as math;

import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/widgets/app_svg.dart';
import 'package:app_leitura/core/design_system/widgets/circle_icon_button.dart';
import 'package:app_leitura/core/design_system/widgets/count_badge.dart';
import 'package:app_leitura/core/design_system/widgets/neo_box.dart';
import 'package:app_leitura/core/design_system/widgets/pill.dart';
import 'package:app_leitura/core/design_system/widgets/pressable.dart';
import 'package:app_leitura/core/design_system/widgets/stadium_progress_bar.dart';
import 'package:app_leitura/features/home/presentation/covers/dom_casmurro_cover.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../reference/reference_layout.dart';
import '../reference/reference_layout_w360.dart';
import '../support/canvas.dart';
import '../support/geometry.dart';
import '../support/geometry_report.dart';
import '../support/load_fonts.dart';
import '../support/pump_app.dart';

Rect _rect(WidgetTester tester, String id) =>
    tester.getRect(find.byKey(ValueKey<String>(id)));

/// Relativo ao canto superior esquerdo da seção (as tabelas da F05 usam essa origem).
Offset _rel(WidgetTester tester, String id) =>
    layoutRect(tester, id).topLeft - _rect(tester, 'hero').topLeft;

T _parentOf<T extends Widget>(WidgetTester tester, String id) =>
    tester.widget<T>(
      find
          .ancestor(
            of: find.byKey(ValueKey<String>(id)),
            matching: find.byType(T),
          )
          .first,
    );

/// F05 — camada 1 (geometria) e construção da seção `hero`.
void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'F05 geometria: os 30 ids da seção hero dentro da tolerância (canvas 390×2390)',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final ids = idsOfSection('hero').toList();
      expect(ids, [
        'hero',
        'hero.sparkleLarge',
        'hero.sparkleSmall',
        'hero.topRow',
        'hero.cover',
        'hero.cover.spine',
        'hero.cover.sun',
        'hero.cover.ring',
        'hero.cover.textBlock',
        'hero.cover.title',
        'hero.cover.author',
        'hero.meta',
        'hero.meta.top',
        'hero.chapterPill',
        'hero.titleBlock',
        'hero.title',
        'hero.author',
        'hero.meta.bottom',
        'hero.progressRow',
        'hero.percent',
        'hero.timeLeft',
        'hero.progressBar',
        'hero.progressFill',
        'hero.actions',
        'hero.cta',
        'hero.cta.icon',
        'hero.cta.label',
        'hero.notesButton',
        'hero.notesButton.icon',
        'hero.notesButton.badge',
      ]);
      expectGeometry(tester, ids);
      reportGeometry(tester, ids);
    },
  );

  testWidgets(
    '5.1 construção: Semantics(seção) > NeoBox(hero, recorte) > Stack [Padding 20 > Column(stretch, gap 20), brilho 30, brilho 14]',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final section = _parentOf<Semantics>(tester, 'hero');
      expect(section.child!.key, const ValueKey('hero'));
      expect(section.container, isTrue);
      expect(section.explicitChildNodes, isTrue);
      expect(section.properties.label, 'Continuar lendo');

      final card = tester.widget<NeoBox>(find.byKey(const ValueKey('hero')));
      expect(card.clip, isTrue);
      expect(card.padding, EdgeInsets.zero);
      // Altura auto: os 275 vêm do conteúdo.
      expect((card.width, card.height), (null, null));
      final stack = card.child! as Stack;
      expect(stack.children, hasLength(3));
      // Conteúdo de fluxo primeiro, brilhos absolutos depois (pintam por cima, como no CSS).
      final padding = stack.children[0] as Padding;
      expect(padding.padding, const EdgeInsets.all(20));
      final column = padding.child! as Column;
      expect(column.crossAxisAlignment, CrossAxisAlignment.stretch);
      expect(column.spacing, 20);
      expect(column.children, hasLength(2));
      for (final (i, top, right, size, id) in [
        (1, 18.0, 18.0, 30.0, 'hero.sparkleLarge'),
        (2, 54.0, 50.0, 14.0, 'hero.sparkleSmall'),
      ]) {
        final p = stack.children[i] as Positioned;
        expect((p.top, p.right, p.left, p.bottom), (top, right, null, null));
        expect(p.child.key, ValueKey(id));
        expect((p.child as AppSvg).size, size);
      }
      // Posição a partir da padding box (dentro da borda 1,5): (347 − 18 − 30; 18) e (347 − 50 − 14; 54).
      expect(
        _rel(tester, 'hero.sparkleLarge'),
        const Offset(1.5 + 299, 1.5 + 18),
      );
      expect(
        _rel(tester, 'hero.sparkleSmall'),
        const Offset(1.5 + 283, 1.5 + 54),
      );
      // 1,5 + 20 + 158 + 20 + 54 + 20 + 1,5 = 275.
      expect(
        tester.getSize(find.byKey(const ValueKey('hero'))),
        const Size(350, 275),
      );
      expect(_rect(tester, 'hero.topRow').height, 158);
      expect(_rect(tester, 'hero.actions').height, 54);
      expect(
        _rect(tester, 'hero.actions').top - _rect(tester, 'hero.topRow').bottom,
        20,
      );
    },
  );

  testWidgets(
    '5.2 capa: Align(topLeft) > Padding(2, 2) > SizedBox(hero.cover 104×156) > Transform.rotate(−3°) > KeyedSubtree(#rot) > DomCasmurroCover',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final slot = tester.widget<SizedBox>(
        find.byKey(const ValueKey('hero.cover')),
      );
      expect((slot.width, slot.height), (104.0, 156.0));
      final pad = _parentOf<Padding>(tester, 'hero.cover');
      expect(pad.padding, const EdgeInsets.only(left: 2, top: 2));
      final align = _parentOf<Align>(tester, 'hero.cover');
      expect(align.alignment, Alignment.topLeft);
      expect((align.widthFactor, align.heightFactor), (null, null));
      final transform = slot.child! as Transform;
      expect(transform.alignment, Alignment.center);
      expect(transform.origin, isNull);
      final expected = Matrix4.rotationZ(-3 * math.pi / 180);
      for (var i = 0; i < 16; i++) {
        expect(
          transform.transform.storage[i],
          moreOrLessEquals(expected.storage[i], epsilon: 1e-12),
          reason: 'matriz[$i]',
        );
      }
      final rot = transform.child! as KeyedSubtree;
      expect(rot.key, const ValueKey('hero.cover#rot'));
      expect(rot.child, isA<DomCasmurroCover>());
      // Giro em torno do CENTRO do slot (transform-origin 50% 50%): o layout não muda, o canto superior
      // esquerdo da arte vai para centro + R(−3°)·(−52, −78).
      final r = _rect(tester, 'hero.cover');
      final rotBox = tester.renderObject<RenderBox>(
        find.byKey(const ValueKey('hero.cover#rot')),
      );
      const a = -3 * math.pi / 180;
      final c = r.center;
      final corner = rotBox.localToGlobal(Offset.zero);
      final want =
          c +
          Offset(
            -52 * math.cos(a) + 78 * math.sin(a),
            -52 * math.sin(a) - 78 * math.cos(a),
          );
      expect(corner.dx, moreOrLessEquals(want.dx, epsilon: 1e-6));
      expect(corner.dy, moreOrLessEquals(want.dy, epsilon: 1e-6));
      expect(rotBox.size, const Size(104, 156));
      debugPrint(
        '[hero] capa: slot $r | canto girado $corner (esperado $want)',
      );
    },
  );

  testWidgets(
    '5.2 linha superior: IntrinsicHeight > Row(stretch, gap 20) — metadados esticados a 158, capa 104×156 no topo (margem 2/0/0/2)',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final row = tester.widget<Row>(find.byKey(const ValueKey('hero.topRow')));
      expect(row.crossAxisAlignment, CrossAxisAlignment.stretch);
      expect(row.spacing, 20);
      expect(row.children, hasLength(2));
      expect(row.children.last, isA<Expanded>());
      expect(
        find.ancestor(
          of: find.byKey(const ValueKey('hero.topRow')),
          matching: find.byType(IntrinsicHeight),
        ),
        findsOneWidget,
      );
      final top = _rect(tester, 'hero.topRow');
      final cover = _rect(tester, 'hero.cover');
      final meta = _rect(tester, 'hero.meta');
      expect(top.height, 158);
      expect(meta.height, 158); // stretch
      expect(meta.width, 181);
      expect(cover.topLeft - top.topLeft, const Offset(2, 2));
      expect(cover.size, const Size(104, 156));
      expect(meta.left - cover.right, 20);
      expect(meta.right, top.right);
    },
  );

  testWidgets(
    '5.2 largura 360: o título quebra e a linha mede 158,8, mas a capa continua 104×156 no topo (Align)',
    (tester) async {
      setCanvasView(tester, logical: const Size(360, 2390));
      await pumpApp(tester);
      // Só a afirmação da F05 sobre a capa (a validação completa em 360/430 é da F13, ±1,0).
      expectGeometryAgainst(tester, {
        for (final id in [
          'hero',
          'hero.topRow',
          'hero.cover',
          'hero.cover.spine',
          'hero.cover.sun',
          'hero.cover.ring',
          'hero.cover.textBlock',
          'hero.meta',
          'hero.title',
        ])
          id: kRefLayoutW360[id]!,
      });
      final top = _rect(tester, 'hero.topRow');
      final cover = _rect(tester, 'hero.cover');
      expect(top.height, moreOrLessEquals(158.8, epsilon: 1e-3));
      expect(cover.size, const Size(104, 156));
      expect(cover.top - top.top, 2);
      debugPrint('[hero] w360: linha ${top.height} | capa $cover');
    },
  );

  testWidgets(
    '5.3 metadados: Padding(top 2) > Column(spaceBetween, stretch) [topo (gap 10): pílula à esquerda + bloco do título (gap 3); base]',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final meta = tester.widget<Padding>(
        find.byKey(const ValueKey('hero.meta')),
      );
      expect(meta.padding, const EdgeInsets.only(top: 2));
      final column = meta.child! as Column;
      expect(column.mainAxisAlignment, MainAxisAlignment.spaceBetween);
      expect(column.crossAxisAlignment, CrossAxisAlignment.stretch);
      expect(column.children.map((w) => w.key), [
        const ValueKey('hero.meta.top'),
        const ValueKey('hero.meta.bottom'),
      ]);
      final metaTop = tester.widget<Column>(
        find.byKey(const ValueKey('hero.meta.top')),
      );
      expect(metaTop.spacing, 10);
      expect(metaTop.crossAxisAlignment, CrossAxisAlignment.stretch);
      final pillAlign = metaTop.children.first as Align;
      expect(pillAlign.alignment, Alignment.centerLeft);
      expect(pillAlign.child, isA<Pill>());
      expect(pillAlign.child!.key, const ValueKey('hero.chapterPill'));
      final pill = pillAlign.child! as Pill;
      expect(
        pill.padding,
        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      );
      final titleBlock = tester.widget<Column>(
        find.byKey(const ValueKey('hero.titleBlock')),
      );
      expect(titleBlock.spacing, 3);
      expect(titleBlock.crossAxisAlignment, CrossAxisAlignment.stretch);

      final pillRect = _rect(tester, 'hero.chapterPill');
      final metaRect = _rect(tester, 'hero.meta');
      final title = _rect(tester, 'hero.title');
      final author = _rect(tester, 'hero.author');
      final bottom = _rect(tester, 'hero.meta.bottom');
      expect(pillRect.topLeft - metaRect.topLeft, const Offset(0, 2));
      // 14,4 + 2 × 5 + 2 × 1,5.
      expect(pillRect.height, moreOrLessEquals(27.4, epsilon: 1e-3));
      expect(pillRect.width, moreOrLessEquals(104.55, epsilon: 0.05));
      expect(title.top - pillRect.bottom, moreOrLessEquals(10, epsilon: 1e-3));
      expect(title.height, moreOrLessEquals(25.2, epsilon: 1e-3)); // 24 × 1,05
      expect(author.top - title.bottom, moreOrLessEquals(3, epsilon: 1e-3));
      expect(author.height, moreOrLessEquals(16.8, epsilon: 1e-3)); // 14 × 1,2
      // space-between: a base encosta no fundo da linha de 158.
      expect(bottom.bottom, metaRect.bottom);
      debugPrint(
        '[hero] pílula ${pillRect.size} | título ${title.height} | autor ${author.height} | base em ${bottom.top}',
      );
    },
  );

  testWidgets(
    '5.4 base: "62%" × "~2h 10min" pela baseline (space-between), gap 8, barra 181×10 com preenchimento 110,36×7',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final bottom = tester.widget<Column>(
        find.byKey(const ValueKey('hero.meta.bottom')),
      );
      expect(bottom.spacing, 8);
      final row = tester.widget<Row>(
        find.byKey(const ValueKey('hero.progressRow')),
      );
      expect(row.mainAxisAlignment, MainAxisAlignment.spaceBetween);
      expect(row.crossAxisAlignment, CrossAxisAlignment.baseline);
      expect(row.textBaseline, TextBaseline.alphabetic);
      final percent = tester.renderObject<RenderAppText>(
        find.byKey(const ValueKey('hero.percent')),
      );
      final time = tester.renderObject<RenderAppText>(
        find.byKey(const ValueKey('hero.timeLeft')),
      );
      final b1 = percent.debugLines().single.baseline;
      final b2 = time.debugLines().single.baseline;
      expect(b1, moreOrLessEquals(b2, epsilon: 1e-6));
      final rowRect = _rect(tester, 'hero.progressRow');
      expect(rowRect.height, moreOrLessEquals(31.2, epsilon: 1e-3));
      expect(_rect(tester, 'hero.timeLeft').right, rowRect.right);

      final bar = tester.widget<StadiumProgressBar>(
        find.byKey(const ValueKey('hero.progressBar')),
      );
      expect(bar.progress, 0.62);
      expect(bar.height, 10);
      expect(bar.fillKey, const ValueKey('hero.progressFill'));
      final barRect = _rect(tester, 'hero.progressBar');
      final fill = _rect(tester, 'hero.progressFill');
      expect(barRect.top - rowRect.bottom, moreOrLessEquals(8, epsilon: 1e-3));
      expect(barRect.size, const Size(181, 10));
      expect(fill.topLeft - barRect.topLeft, const Offset(1.5, 1.5));
      expect(fill.width, moreOrLessEquals(0.62 * 178, epsilon: 1e-9)); // 110,36
      expect(fill.height, 7);
      debugPrint(
        '[hero] baselines 62% $b1 | tempo $b2 | preenchimento ${fill.size}',
      );
    },
  );

  testWidgets(
    '5.5 ações: CTA Expanded 243×54 (ícone 20 + gap 10 + rótulo centralizados) e botão 54 com badge 24,61×22 em top −4 / right −4',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final actions = tester.widget<SizedBox>(
        find.byKey(const ValueKey('hero.actions')),
      );
      expect(actions.height, 54);
      final row = actions.child! as Row;
      expect(row.spacing, 10);
      expect(row.children, hasLength(2));
      expect(row.children.first, isA<Expanded>());
      final pressable = (row.children.first as Expanded).child as Pressable;
      expect(pressable.isLink, isTrue);
      expect(pressable.child.key, const ValueKey('hero.cta'));
      final cta = pressable.child as NeoBox;
      expect(cta.height, 54);
      final content = cta.child! as Row;
      expect(content.mainAxisAlignment, MainAxisAlignment.center);
      expect(content.spacing, 10);
      expect(content.children.map((w) => w.key), [
        const ValueKey('hero.cta.icon'),
        const ValueKey('hero.cta.label'),
      ]);
      expect(row.children.last, isA<CircleIconButton>());
      expect(row.children.last.key, const ValueKey('hero.notesButton'));

      final ctaRect = _rect(tester, 'hero.cta');
      final icon = _rect(tester, 'hero.cta.icon');
      final label = _rect(tester, 'hero.cta.label');
      expect(ctaRect.size, const Size(243, 54));
      expect(label.left - icon.right, 10);
      // Conteúdo (20 + 10 + rótulo) centralizado nos 243.
      expect(
        (icon.left - ctaRect.left) - (ctaRect.right - label.right),
        moreOrLessEquals(0, epsilon: 1e-9),
      );
      expect(icon.center.dy, ctaRect.center.dy);
      expect(
        label.center.dy,
        moreOrLessEquals(ctaRect.center.dy, epsilon: 1e-6),
      );

      final button = tester.widget<CircleIconButton>(
        find.byKey(const ValueKey('hero.notesButton')),
      );
      expect(button.size, 54);
      expect(button.overlays, hasLength(1));
      final p = button.overlays.single as Positioned;
      expect((p.top, p.right, p.left, p.bottom), (-4.0, -4.0, null, null));
      final badge = p.child as CountBadge;
      expect(badge.key, const ValueKey('hero.notesButton.badge'));
      expect(
        (badge.minWidth, badge.height, badge.horizontalPadding),
        (22.0, 22.0, 5.0),
      );
      final buttonRect = _rect(tester, 'hero.notesButton');
      final badgeRect = _rect(tester, 'hero.notesButton.badge');
      final iconRect = _rect(tester, 'hero.notesButton.icon');
      expect(buttonRect.left - ctaRect.right, 10);
      expect(buttonRect.size, const Size(54, 54));
      expect(iconRect.topLeft - buttonRect.topLeft, const Offset(16, 16));
      expect(badgeRect.width, moreOrLessEquals(24.61, epsilon: 0.05));
      expect(badgeRect.height, 22);
      // A partir da borda interna: right −4 → sai 2,5 px da borda externa; top −4 → idem.
      expect(
        badgeRect.right - buttonRect.right,
        moreOrLessEquals(2.5, epsilon: 1e-9),
      );
      expect(
        badgeRect.top - buttonRect.top,
        moreOrLessEquals(-2.5, epsilon: 1e-9),
      );
      debugPrint(
        '[hero] CTA ícone x ${icon.left} rótulo x ${label.left} | badge $badgeRect',
      );
    },
  );

  testWidgets(
    'a referência do hero confere com a soma do CSS (sanidade dos dados)',
    (tester) async {
      // 62 + 48 + 24 + 90,16 + 24 = 248,16 e 275 de altura: a seção seguinte começa em 555,16 (+ 32).
      expect(kRefSections['hero'], const Rect.fromLTWH(20, 248.16, 350, 275));
      expect(
        kRefSections['alsoReading']!.top,
        moreOrLessEquals(555.16, epsilon: 1e-9),
      );
    },
  );
}

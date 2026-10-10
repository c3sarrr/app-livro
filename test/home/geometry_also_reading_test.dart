import 'dart:math' as math;

import 'package:app_leitura/core/design_system/painters/ring_progress_painter.dart';
import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/widgets/count_badge.dart';
import 'package:app_leitura/core/design_system/widgets/neo_box.dart';
import 'package:app_leitura/core/design_system/widgets/pressable.dart';
import 'package:app_leitura/features/home/presentation/covers/mrs_dalloway_cover.dart';
import 'package:app_leitura/features/home/presentation/covers/pride_prejudice_cover.dart';
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

/// Relativo ao canto superior esquerdo da seção (as tabelas da F06 usam essa origem).
Offset _rel(WidgetTester tester, String id) =>
    layoutRect(tester, id).topLeft - _rect(tester, 'alsoReading').topLeft;

T _parentOf<T extends Widget>(WidgetTester tester, String id) =>
    tester.widget<T>(
      find
          .ancestor(
            of: find.byKey(ValueKey<String>(id)),
            matching: find.byType(T),
          )
          .first,
    );

/// Os dois cards: prefixo das Keys, giro da capa (graus), tipo da arte e progresso.
const _cards = [
  ('alsoReading.card1', -4.0, MrsDallowayCover, 0.34),
  ('alsoReading.card2', 3.0, PridePrejudiceCover, 0.81),
];

/// F06 — camada 1 (geometria) e construção da seção `alsoReading`.
void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'F06 geometria: os 29 ids da seção alsoReading dentro da tolerância (canvas 390×2390)',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final ids = idsOfSection('alsoReading').toList();
      expect(ids, [
        'alsoReading',
        'alsoReading.header',
        'alsoReading.title',
        'alsoReading.count',
        'alsoReading.grid',
        'alsoReading.card1',
        'alsoReading.card1.top',
        'alsoReading.card1.cover',
        'alsoReading.card1.cover.spine',
        'alsoReading.card1.cover.arch',
        'alsoReading.card1.cover.title',
        'alsoReading.card1.ring',
        'alsoReading.card1.ring.svg',
        'alsoReading.card1.ring.label',
        'alsoReading.card1.textBlock',
        'alsoReading.card1.title',
        'alsoReading.card1.author',
        'alsoReading.card2',
        'alsoReading.card2.top',
        'alsoReading.card2.cover',
        'alsoReading.card2.cover.spine',
        'alsoReading.card2.cover.circle',
        'alsoReading.card2.cover.title',
        'alsoReading.card2.ring',
        'alsoReading.card2.ring.svg',
        'alsoReading.card2.ring.label',
        'alsoReading.card2.textBlock',
        'alsoReading.card2.title',
        'alsoReading.card2.author',
      ]);
      expectGeometry(tester, ids);
      reportGeometry(tester, ids);
    },
  );

  testWidgets(
    '6.1 construção: Semantics(seção) > Column(alsoReading, stretch, gap 30) [cabeçalho Row(gap 8, centro): h3 + contador; grade]',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final section = _parentOf<Semantics>(tester, 'alsoReading');
      expect(section.child!.key, const ValueKey('alsoReading'));
      expect(section.container, isTrue);
      expect(section.explicitChildNodes, isTrue);
      expect(section.properties.label, 'Também lendo');

      final column = tester.widget<Column>(
        find.byKey(const ValueKey('alsoReading')),
      );
      expect(column.crossAxisAlignment, CrossAxisAlignment.stretch);
      expect(column.mainAxisSize, MainAxisSize.min);
      expect(column.spacing, 30);
      expect(column.children, hasLength(2));
      expect(column.children.first.key, const ValueKey('alsoReading.header'));
      // T03: a grade dentro de um IntrinsicHeight (o stretch do `display: grid` — cartões da mesma altura)
      expect(
        (column.children.last as IntrinsicHeight).child!.key,
        const ValueKey('alsoReading.grid'),
      );

      final header = tester.widget<Row>(
        find.byKey(const ValueKey('alsoReading.header')),
      );
      expect(header.spacing, 8);
      expect(header.crossAxisAlignment, CrossAxisAlignment.center);
      expect(header.mainAxisAlignment, MainAxisAlignment.start);
      expect(header.children, hasLength(2));
      final h3 = header.children.first as Semantics;
      expect(h3.child!.key, const ValueKey('alsoReading.title'));
      expect(header.children.last.key, const ValueKey('alsoReading.count'));
      final count = tester.widget<CountBadge>(
        find.byKey(const ValueKey('alsoReading.count')),
      );
      expect(count.label, '2');
      expect(
        (count.minWidth, count.height, count.horizontalPadding),
        (22.0, 22.0, 7.0),
      );
      expect(count.background, AppColors.ink);
      expect(count.border, isNull);

      final headerRect = _rect(tester, 'alsoReading.header');
      final title = _rect(tester, 'alsoReading.title');
      final badge = _rect(tester, 'alsoReading.count');
      expect(headerRect.size, const Size(350, 22));
      // 21,6 centrado na linha de 22 → +0,2.
      expect(title.height, moreOrLessEquals(21.6, epsilon: 1e-3));
      expect(title.top - headerRect.top, moreOrLessEquals(0.2, epsilon: 1e-3));
      expect(title.left, headerRect.left);
      // min-width 22: "2" (6,95) + 2 × 7 = 20,95 < 22.
      expect(badge.size, const Size(22, 22));
      expect(badge.left - title.right, moreOrLessEquals(8, epsilon: 1e-9));
      expect(badge.top, headerRect.top);
      // Texto do contador centralizado nos 22.
      final label = tester.renderObject<RenderAppText>(
        find.descendant(
          of: find.byKey(const ValueKey('alsoReading.count')),
          matching: find.byType(AppText),
        ),
      );
      final line = label.debugLines().single;
      expect(
        (line.left - badge.left) - (badge.right - line.right),
        moreOrLessEquals(0, epsilon: 0.01),
      );
      // Grade 30 abaixo do cabeçalho; seção 22 + 30 + 123,6.
      expect(
        _rect(tester, 'alsoReading.grid').top - headerRect.bottom,
        moreOrLessEquals(30, epsilon: 1e-9),
      );
      expect(
        tester.getSize(find.byKey(const ValueKey('alsoReading'))).height,
        moreOrLessEquals(175.6, epsilon: 1e-3),
      );
      debugPrint(
        '[alsoReading] título ${title.size} em y +${(title.top - headerRect.top).toStringAsFixed(3)} | contador $badge | '
        'texto "2" ${line.left.toStringAsFixed(3)}–${line.right.toStringAsFixed(3)}',
      );
    },
  );

  testWidgets(
    '6.2 grade e cards: IntrinsicHeight > Row(stretch, gap 12) [Expanded > Pressable(link) > NeoBox 169×123,6 (padding 0/14/14)] ×2; coluna do card (stretch, gap 12): linha 59 + bloco 35,6',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final grid = tester.widget<Row>(
        find.byKey(const ValueKey('alsoReading.grid')),
      );
      expect(grid.crossAxisAlignment, CrossAxisAlignment.stretch);
      expect(grid.spacing, 12);
      expect(grid.children, hasLength(2));
      expect(grid.clipBehavior, Clip.none); // a capa vaza para cima
      for (final (i, (id, _, _, _)) in _cards.indexed) {
        final expanded = grid.children[i] as Expanded;
        expect(expanded.flex, 1); // minmax(0, 1fr)
        final pressable = tester.widget<Pressable>(
          find.ancestor(
            of: find.byKey(ValueKey(id)),
            matching: find.byType(Pressable),
          ),
        );
        expect(pressable.isLink, isTrue, reason: id);
        expect(pressable.semanticsLabel, isNull, reason: id);
        expect(pressable.child.key, ValueKey(id), reason: id);
        final card = pressable.child as NeoBox;
        expect(card.padding, const EdgeInsets.fromLTRB(14, 0, 14, 14));
        expect(card.clip, isFalse, reason: id);
        expect(card.shadow, isNull, reason: id);
        expect((card.width, card.height), (null, null)); // altura auto
        final column = card.child! as Column;
        expect(column.crossAxisAlignment, CrossAxisAlignment.stretch);
        expect(column.mainAxisSize, MainAxisSize.min);
        expect(column.spacing, 12);
        expect(column.children.map((w) => w.key), [
          ValueKey('$id.top'),
          ValueKey('$id.textBlock'),
        ]);

        final cardRect = _rect(tester, id);
        final top = _rect(tester, '$id.top');
        final block = _rect(tester, '$id.textBlock');
        // 1,5 + 59 + 12 + 35,6 + 14 + 1,5.
        expect(cardRect.width, 169, reason: id);
        expect(
          cardRect.height,
          moreOrLessEquals(123.6, epsilon: 1e-3),
          reason: id,
        );
        // Sem padding no topo: a linha começa na borda interna.
        expect(top.topLeft - cardRect.topLeft, const Offset(15.5, 1.5));
        expect(top.size, const Size(138, 59));
        expect(block.top - top.bottom, 12, reason: id);
        expect(block.left, top.left, reason: id);
        expect(block.width, 138, reason: id);
        expect(
          cardRect.bottom - block.bottom,
          moreOrLessEquals(14 + 1.5, epsilon: 1e-9),
          reason: id,
        );
      }
      final c1 = _rect(tester, 'alsoReading.card1');
      final c2 = _rect(tester, 'alsoReading.card2');
      final gridRect = _rect(tester, 'alsoReading.grid');
      expect(c2.left - c1.right, 12);
      expect(c1.left, gridRect.left);
      expect(c2.right, gridRect.right);
      expect(c1.top, gridRect.top);
      expect(c2.top, gridRect.top);
      expect(gridRect.height, moreOrLessEquals(123.6, epsilon: 1e-3));
    },
  );

  testWidgets(
    '6.3/6.4 capas: SizedBox(54×59) > OverflowBox(81, embaixo) > SizedBox(cover 54×81) > Transform.rotate(−4° / +3°) > KeyedSubtree(#rot) > arte',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      for (final (id, degrees, art, _) in _cards) {
        final coverId = '$id.cover';
        final slot = tester.widget<SizedBox>(
          find.byKey(ValueKey<String>(coverId)),
        );
        expect((slot.width, slot.height), (54.0, 81.0), reason: id);
        final overflow = _parentOf<OverflowBox>(tester, coverId);
        expect(
          (overflow.minHeight, overflow.maxHeight),
          (81.0, 81.0),
          reason: id,
        );
        expect((overflow.minWidth, overflow.maxWidth), (null, null));
        expect(overflow.alignment, Alignment.bottomCenter, reason: id);
        final line = _parentOf<SizedBox>(tester, coverId);
        expect(line.child, same(overflow));
        expect((line.width, line.height), (54.0, 59.0), reason: id);

        final transform = slot.child! as Transform;
        expect(transform.alignment, Alignment.center);
        expect(transform.origin, isNull);
        final angle = degrees * math.pi / 180;
        final expected = Matrix4.rotationZ(angle);
        for (var i = 0; i < 16; i++) {
          expect(
            transform.transform.storage[i],
            moreOrLessEquals(expected.storage[i], epsilon: 1e-12),
            reason: '$id matriz[$i]',
          );
        }
        final rot = transform.child! as KeyedSubtree;
        expect(rot.key, ValueKey('$coverId#rot'));
        expect(rot.child.runtimeType, art);

        // margin-top −22 + flex-end: a capa termina no fundo da linha de 59 e vaza 22 px acima dela
        // (20,5 acima da borda externa do card, por cima da borda).
        final top = _rect(tester, '$id.top');
        final cover = _rect(tester, coverId);
        final card = _rect(tester, id);
        expect(cover.size, const Size(54, 81), reason: id);
        expect(cover.left, top.left, reason: id);
        expect(cover.bottom, moreOrLessEquals(top.bottom, epsilon: 1e-9));
        expect(cover.top - top.top, moreOrLessEquals(-22, epsilon: 1e-9));
        expect(cover.top - card.top, moreOrLessEquals(-20.5, epsilon: 1e-9));

        // Giro em torno do CENTRO do slot: o canto superior esquerdo da arte vai para
        // centro + R(θ)·(−27, −40,5).
        final rotBox = tester.renderObject<RenderBox>(
          find.byKey(ValueKey('$coverId#rot')),
        );
        final c = cover.center;
        final corner = rotBox.localToGlobal(Offset.zero);
        final want =
            c +
            Offset(
              -27 * math.cos(angle) + 40.5 * math.sin(angle),
              -27 * math.sin(angle) - 40.5 * math.cos(angle),
            );
        expect(corner.dx, moreOrLessEquals(want.dx, epsilon: 1e-6));
        expect(corner.dy, moreOrLessEquals(want.dy, epsilon: 1e-6));
        expect(rotBox.size, const Size(54, 81));
        debugPrint(
          '[alsoReading] $coverId: slot $cover | canto girado $corner (esperado $want)',
        );
      }
    },
  );

  testWidgets(
    '6.5 anéis: Padding(top 12) > SizedBox(ring 46×46) > Stack [Positioned.fill > ExcludeSemantics > CustomPaint(svg), Positioned.fill > Center(label)]',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      for (final (id, _, _, progress) in _cards) {
        final ringId = '$id.ring';
        final padding = _parentOf<Padding>(tester, ringId);
        expect(padding.padding, const EdgeInsets.only(top: 12), reason: id);
        final ring = tester.widget<SizedBox>(
          find.byKey(ValueKey<String>(ringId)),
        );
        expect((ring.width, ring.height), (46.0, 46.0));
        final stack = ring.child! as Stack;
        expect(stack.children, hasLength(2));
        final svg = stack.children[0] as Positioned;
        expect((svg.left, svg.top, svg.right, svg.bottom), (0, 0, 0, 0));
        final exclude = svg.child as ExcludeSemantics;
        expect(exclude.excluding, isTrue);
        final paint = exclude.child! as CustomPaint;
        expect(paint.key, ValueKey('$ringId.svg'));
        expect(paint.child, isNull);
        expect(paint.foregroundPainter, isNull);
        final painter = paint.painter! as RingProgressPainter;
        expect(painter.progress, progress, reason: id);
        final label = stack.children[1] as Positioned;
        expect(
          (label.left, label.top, label.right, label.bottom),
          (0, 0, 0, 0),
        );
        expect(label.child, isA<Center>());
        expect(label.child.key, ValueKey('$ringId.label'));

        final top = _rect(tester, '$id.top');
        final ringRect = _rect(tester, ringId);
        // space-between + flex-end: encostado à direita e embaixo, 13 abaixo do topo da linha.
        expect(ringRect.size, const Size(46, 46));
        expect(ringRect.right, top.right, reason: id);
        expect(ringRect.bottom, top.bottom, reason: id);
        expect(ringRect.top - top.top, moreOrLessEquals(13, epsilon: 1e-9));
        // O CustomPaint mede 46×46 (sem o Positioned.fill mediria 0×0 e o anel sairia em (0, 0)).
        expect(_rect(tester, '$ringId.svg'), ringRect);
        expect(_rect(tester, '$ringId.label'), ringRect);
        final text = _rect(
          tester,
          '$ringId.label',
        ); // Center: o AppText fica no meio
        final textBox = tester.getRect(
          find.descendant(
            of: find.byKey(ValueKey('$ringId.label')),
            matching: find.byType(AppText),
          ),
        );
        expect(
          textBox.center.dx,
          moreOrLessEquals(text.center.dx, epsilon: 1e-9),
        );
        expect(
          textBox.center.dy,
          moreOrLessEquals(text.center.dy, epsilon: 1e-9),
        );
        expect(textBox.height, moreOrLessEquals(13.2, epsilon: 1e-3));
        debugPrint('[alsoReading] $ringId: $ringRect | rótulo $textBox');
      }
    },
  );

  testWidgets(
    '6.6 bloco de texto: Column(stretch, gap 2) [título 138×18 e autor 138×15,6, maxLines 1 + "…"]',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      for (final (id, _, _, _) in _cards) {
        final block = tester.widget<Column>(
          find.byKey(ValueKey('$id.textBlock')),
        );
        expect(block.crossAxisAlignment, CrossAxisAlignment.stretch);
        expect(block.mainAxisSize, MainAxisSize.min);
        expect(block.spacing, 2);
        expect(block.children.map((w) => w.key), [
          ValueKey('$id.title'),
          ValueKey('$id.author'),
        ]);
        for (final text in block.children.cast<AppText>()) {
          expect(text.maxLines, 1, reason: '${text.key}');
          expect(text.ellipsis, isTrue, reason: '${text.key}');
        }
        final blockRect = _rect(tester, '$id.textBlock');
        final title = _rect(tester, '$id.title');
        final author = _rect(tester, '$id.author');
        expect(title.topLeft, blockRect.topLeft);
        expect(title.width, 138, reason: id);
        expect(title.height, moreOrLessEquals(18, epsilon: 1e-3)); // 15 × 1,2
        expect(author.top - title.bottom, moreOrLessEquals(2, epsilon: 1e-9));
        expect(author.width, 138, reason: id);
        expect(
          author.height,
          moreOrLessEquals(15.6, epsilon: 1e-3),
        ); // 13 × 1,2
        expect(blockRect.height, moreOrLessEquals(35.6, epsilon: 1e-3));
      }
    },
  );

  testWidgets(
    'posições da tabela da F06 relativas à seção (capas pelo retângulo de layout, sem giro)',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      // Nº 8, 12, 20 e 24 da tabela: capas vazando 22 px (y 31,5) e anéis em y 66,5.
      expect(_rel(tester, 'alsoReading.card1.cover'), const Offset(15.5, 31.5));
      expect(
        _rel(tester, 'alsoReading.card2.cover'),
        const Offset(196.5, 31.5),
      );
      final ring1 = _rel(tester, 'alsoReading.card1.ring');
      final ring2 = _rel(tester, 'alsoReading.card2.ring');
      expect(ring1.dx, 107.5);
      expect(ring2.dx, 288.5);
      expect(ring1.dy, moreOrLessEquals(66.5, epsilon: 1e-9));
      expect(ring2.dy, moreOrLessEquals(66.5, epsilon: 1e-9));
    },
  );

  testWidgets(
    'a referência da seção confere com a soma do CSS (sanidade dos dados)',
    (tester) async {
      // 555,16 + 175,6 = 730,76; a seção seguinte começa 36 abaixo (766,76).
      expect(
        kRefSections['alsoReading'],
        const Rect.fromLTWH(20, 555.16, 350, 175.6),
      );
      expect(
        kRefSections['today']!.top,
        moreOrLessEquals(555.16 + 175.6 + 36, epsilon: 1e-9),
      );
    },
  );
}

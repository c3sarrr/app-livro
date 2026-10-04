import 'dart:math' as math;
import 'dart:typed_data';

import 'package:app_leitura/app/app.dart';
import 'package:app_leitura/core/design_system/painters/ring_progress_painter.dart';
import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/tokens/app_radii.dart';
import 'package:app_leitura/core/design_system/tokens/app_shadows.dart';
import 'package:app_leitura/core/design_system/tokens/app_typography.dart';
import 'package:app_leitura/core/design_system/widgets/neo_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/overrides_do_mundo.dart';
import '../support/canvas.dart';
import '../support/capture.dart';
import '../support/load_fonts.dart';
import '../support/precache_svgs.dart';
import '../support/pump_app.dart';

BoxDecoration _decorationOf(WidgetTester tester, String id) =>
    tester
            .widget<DecoratedBox>(
              find
                  .descendant(
                    of: find.byKey(ValueKey<String>(id)),
                    matching: find.byType(DecoratedBox),
                  )
                  .first,
            )
            .decoration
        as BoxDecoration;

ClipRRect _clipOf(WidgetTester tester, String id) => tester.widget<ClipRRect>(
  find
      .descendant(
        of: find.byKey(ValueKey<String>(id)),
        matching: find.byType(ClipRRect),
      )
      .first,
);

TextStyle _styleOf(WidgetTester tester, String id) =>
    (tester
                .widget<AppText>(
                  find.descendant(
                    of: find.byKey(ValueKey<String>(id)),
                    matching: find.byType(AppText),
                    matchRoot: true,
                  ),
                )
                .span
            as TextSpan)
        .style!;

void _expectHardShadow(BoxDecoration d, Offset offset) {
  expect(d.boxShadow, hasLength(1));
  final s = d.boxShadow!.single;
  expect(s.offset, offset);
  expect(s.blurRadius, 0);
  expect(s.spreadRadius, 0);
  expect(s.color.toARGB32(), 0xFF1A1714);
  expect(s.blurStyle, BlurStyle.normal);
}

void _expectInkBorder(BoxDecoration d, {double width = 1.5}) {
  expect(d.border, Border.all(width: width, color: AppColors.ink));
  expect((d.border! as Border).top.color.toARGB32(), 0xFF1A1714);
}

/// Monta o app sob um RepaintBoundary (mesma captura do golden).
Future<void> _pumpCanvas(WidgetTester tester) async {
  await precacheAppIcons(tester);
  await tester.pumpWidget(
    ProviderScope(
      overrides: overridesDoMundo,
      child: const RepaintBoundary(key: goldenRootKey, child: App.forTests()),
    ),
  );
  await tester.pumpAndSettle();
}

Future<(Uint8List, int)> _capture(WidgetTester tester) async {
  final image = await captureAt(tester, find.byKey(goldenRootKey));
  return (await rgbaOf(tester, image), image.width);
}

/// Cor ARGB do pixel @3x que contém o ponto LÓGICO (x, y).
int _argbAt(Uint8List rgba, int width, Offset p) {
  final i = ((p.dy * 3).floor() * width + (p.dx * 3).floor()) * 4;
  return (rgba[i + 3] << 24) |
      (rgba[i] << 16) |
      (rgba[i + 1] << 8) |
      rgba[i + 2];
}

/// Ponto da arte de uma capa (coordenadas locais da borda EXTERNA, sem giro) levado ao canvas (com o giro).
Offset _coverPoint(WidgetTester tester, String card, Offset local) => tester
    .renderObject<RenderBox>(find.byKey(ValueKey('$card.cover#rot')))
    .localToGlobal(local);

/// Ponto do anel no raio médio do traço (18), a [degrees] graus do topo no sentido horário.
Offset _ringPoint(WidgetTester tester, String card, double degrees) {
  final c = tester.getCenter(find.byKey(ValueKey('$card.ring')));
  final a = degrees * math.pi / 180;
  return c + Offset(18 * math.sin(a), -18 * math.cos(a));
}

/// Composição src-over de preto com [alpha] (0–255) sobre [rgb]: canal × (1 − alpha/255).
List<double> _darken(int rgb, int alpha) => [
  (rgb >> 16) & 0xFF,
  (rgb >> 8) & 0xFF,
  rgb & 0xFF,
].map((c) => c * (1 - alpha / 255)).toList();

/// F06 — camada 2 (estilo, sem tolerância) da seção `alsoReading`.
void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    '6.1 título Bricolage18 18/1,2 ls −0,3 tinta; contador tinta raio 999 (→ 11) sem borda/sombra, "2" Figtree 12/700 #F7F0E3',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final title = _styleOf(tester, 'alsoReading.title');
      expect(title, same(AppTextStyles.sectionTitleS));
      expect(
        (
          title.fontFamily,
          title.fontSize,
          title.fontWeight,
          title.height,
          title.letterSpacing,
        ),
        ('Bricolage18', 18.0, FontWeight.w800, 1.2, -0.3),
      );
      expect(title.fontFamilyFallback, ['Bricolage18Ext', 'Bricolage18Vi']);
      expect(title.color!.toARGB32(), 0xFF1A1714);

      final badge = _decorationOf(tester, 'alsoReading.count');
      expect(badge.color!.toARGB32(), 0xFF1A1714);
      expect(badge.borderRadius, BorderRadius.circular(999));
      expect(
        (badge.border, badge.boxShadow, badge.gradient),
        (null, null, null),
      );
      final rect = tester.getRect(
        find.byKey(const ValueKey('alsoReading.count')),
      );
      final rrect = BorderRadius.circular(999).toRRect(rect).scaleRadii();
      expect(rrect.tlRadiusX, moreOrLessEquals(11, epsilon: 1e-9)); // círculo
      final count = _styleOf(tester, 'alsoReading.count');
      expect(count, same(AppTextStyles.count12OnInk));
      expect(
        (count.fontFamily, count.fontSize, count.fontWeight, count.height),
        // CSS 800 → renderizado 700 (D-14).
        ('Figtree', 12.0, FontWeight.w700, 1.2),
      );
      expect(count.fontFamilyFallback, ['FigtreeExt']);
      expect(count.color!.toARGB32(), 0xFFF7F0E3);
      for (final s in [title, count]) {
        expect(s.leadingDistribution, TextLeadingDistribution.even);
      }
    },
  );

  testWidgets(
    '6.2 cards: #FFFAF1, borda 1,5 #1A1714, raio 22, SEM sombra e SEM recorte (os únicos recortes da seção são os das capas)',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      for (final id in ['alsoReading.card1', 'alsoReading.card2']) {
        final d = _decorationOf(tester, id);
        expect(d.color!.toARGB32(), 0xFFFFFAF1, reason: id);
        expect(d.color, AppColors.surface);
        _expectInkBorder(d);
        expect(d.borderRadius, BorderRadius.circular(22), reason: id);
        expect(AppRadii.cardM, 22);
        expect(d.boxShadow, isNull, reason: id);
        expect(d.gradient, isNull, reason: id);
      }
      // Nenhum recorte na seção, na grade nem nos cards: a capa passa por cima da borda do card.
      final clips = find.descendant(
        of: find.byKey(const ValueKey('alsoReading')),
        matching: find.byWidgetPredicate(
          (w) =>
              w is ClipRect || w is ClipRRect || w is ClipPath || w is ClipOval,
        ),
      );
      expect(clips, findsNWidgets(2));
      for (final card in ['alsoReading.card1', 'alsoReading.card2']) {
        expect(
          find.descendant(
            of: find.byKey(ValueKey('$card.cover#rot')),
            matching: find.byType(ClipRRect),
          ),
          findsOneWidget,
          reason: card,
        );
      }
    },
  );

  testWidgets(
    '6.3 Mrs. Dalloway: #ABCF82, borda 1,5, raio 3/7/7/3, sombra dura (2,2) blur 0; recorte 1,5/5,5/5,5/1,5; filhos lombada, arco, título',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      const card = 'alsoReading.card1';
      final d = _decorationOf(tester, '$card.cover#rot');
      expect(d.color!.toARGB32(), 0xFFABCF82);
      expect(d.color, AppColors.leaf);
      _expectInkBorder(d);
      expect(
        d.borderRadius,
        const BorderRadius.only(
          topLeft: Radius.circular(3),
          topRight: Radius.circular(7),
          bottomRight: Radius.circular(7),
          bottomLeft: Radius.circular(3),
        ),
      );
      expect(d.borderRadius, AppRadii.coverS);
      _expectHardShadow(d, const Offset(2, 2));
      expect(AppShadows.hard2, const Offset(2, 2));
      expect(
        _clipOf(tester, '$card.cover#rot').borderRadius,
        const BorderRadius.only(
          topLeft: Radius.circular(1.5),
          topRight: Radius.circular(5.5),
          bottomRight: Radius.circular(5.5),
          bottomLeft: Radius.circular(1.5),
        ),
      );
      expect(_clipOf(tester, '$card.cover#rot').clipBehavior, Clip.antiAlias);
      final stack = tester.widget<Stack>(
        find
            .descendant(
              of: find.byKey(const ValueKey('$card.cover#rot')),
              matching: find.byType(Stack),
            )
            .first,
      );
      // Ordem de pintura do arquivo: lombada, arco, título.
      expect(stack.children.map((w) => (w as Positioned).child.key), const [
        ValueKey('$card.cover.spine'),
        ValueKey('$card.cover.arch'),
        ValueKey('$card.cover.title'),
      ]);
      expect(
        [
          for (final w in stack.children.cast<Positioned>())
            (w.left, w.top, w.right, w.bottom, w.width, w.height),
        ],
        [
          (0.0, 0.0, null, 0.0, 5.0, null), // lombada: altura toda
          (12.0, 12.0, 7.0, null, null, 20.0), // arco
          (10.0, null, 5.0, 8.0, null, null), // título
        ],
      );
      final spine = _decorationOf(tester, '$card.cover.spine');
      expect(spine.color!.toARGB32(), 0x26000000); // round(0,15 × 255) = 38
      expect(spine.color, AppColors.spine15);
      expect((spine.border, spine.boxShadow), (null, null));
      expect(spine.borderRadius, BorderRadius.zero);
      final arch = _decorationOf(tester, '$card.cover.arch');
      expect(arch.color!.toARGB32(), 0xFF1A1714);
      expect(
        arch.borderRadius,
        const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      );
      expect((arch.border, arch.boxShadow), (null, null));
      // 20 + 20 > 32: CSS e Skia reduzem todos os raios pelo fator 0,8 → 16 (em cima), 0 (embaixo).
      // Tamanho do render box (espaço local da arte): `getRect` daria a caixa global, que cresce com o giro.
      final archSize = tester.getSize(
        find.byKey(const ValueKey('$card.cover.arch')),
      );
      expect(archSize, const Size(32, 20));
      final archRRect = (arch.borderRadius! as BorderRadius)
          .toRRect(Offset.zero & archSize)
          .scaleRadii();
      expect(
        (
          archRRect.tlRadiusX,
          archRRect.tlRadiusY,
          archRRect.trRadiusX,
          archRRect.trRadiusY,
          archRRect.blRadiusX,
          archRRect.brRadiusX,
        ),
        (16.0, 16.0, 16.0, 16.0, 0.0, 0.0),
      );
      final t = _styleOf(tester, '$card.cover.title');
      expect(t, same(AppTextStyles.coverTitle11));
      expect(
        (t.fontFamily, t.fontSize, t.fontWeight, t.height, t.letterSpacing),
        ('InstrumentSerif', 11.0, FontWeight.w400, 0.95, 0.0),
      );
      expect(t.fontStyle, FontStyle.normal);
      expect(t.fontFamilyFallback, ['InstrumentSerifExt']);
      expect(t.color!.toARGB32(), 0xFF1A1714);
      expect(t.leadingDistribution, TextLeadingDistribution.even);
    },
  );

  testWidgets(
    '6.4 Orgulho e Preconceito: #FFC1C6, borda 1,5, raio 3/7/7/3, sombra dura (2,2); filhos lombada .12, círculo 20×20 borda 1,5 vazado, título 9/0,95',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      const card = 'alsoReading.card2';
      final d = _decorationOf(tester, '$card.cover#rot');
      expect(d.color!.toARGB32(), 0xFFFFC1C6);
      expect(d.color, AppColors.blush);
      _expectInkBorder(d);
      expect(d.borderRadius, AppRadii.coverS);
      _expectHardShadow(d, const Offset(2, 2));
      expect(
        _clipOf(tester, '$card.cover#rot').borderRadius,
        const BorderRadius.only(
          topLeft: Radius.circular(1.5),
          topRight: Radius.circular(5.5),
          bottomRight: Radius.circular(5.5),
          bottomLeft: Radius.circular(1.5),
        ),
      );
      final stack = tester.widget<Stack>(
        find
            .descendant(
              of: find.byKey(const ValueKey('$card.cover#rot')),
              matching: find.byType(Stack),
            )
            .first,
      );
      // Ordem de pintura do arquivo: lombada, círculo, título.
      expect(stack.children.map((w) => (w as Positioned).child.key), const [
        ValueKey('$card.cover.spine'),
        ValueKey('$card.cover.circle'),
        ValueKey('$card.cover.title'),
      ]);
      expect(
        [
          for (final w in stack.children.cast<Positioned>())
            (w.left, w.top, w.right, w.bottom, w.width, w.height),
        ],
        [
          (0.0, 0.0, null, 0.0, 5.0, null), // lombada: altura toda
          (17.0, 13.0, null, null, null, null), // círculo
          (9.0, null, 2.0, 8.0, null, null), // título
        ],
      );
      final spine = _decorationOf(tester, '$card.cover.spine');
      expect(spine.color!.toARGB32(), 0x1F000000); // round(0,12 × 255) = 31
      expect(spine.color, AppColors.spine12);
      expect((spine.border, spine.boxShadow), (null, null));
      final circle = _decorationOf(tester, '$card.cover.circle');
      expect(circle.color, isNull); // vazado
      _expectInkBorder(circle);
      expect(circle.borderRadius, BorderRadius.circular(10)); // 50 % de 20
      expect(circle.boxShadow, isNull);
      final box = tester.widget<NeoBox>(
        find.byKey(const ValueKey('$card.cover.circle')),
      );
      expect((box.width, box.height), (20.0, 20.0)); // border-box
      final t = _styleOf(tester, '$card.cover.title');
      expect(t, same(AppTextStyles.coverTitle9));
      expect(
        (t.fontFamily, t.fontSize, t.fontWeight, t.height, t.letterSpacing),
        ('InstrumentSerif', 9.0, FontWeight.w400, 0.95, 0.0),
      );
      expect(t.fontStyle, FontStyle.normal);
      expect(t.color!.toARGB32(), 0xFF1A1714);
      expect(t.leadingDistribution, TextLeadingDistribution.even);
    },
  );

  testWidgets(
    '6.5 anéis: RingProgressPainter (r 18, traço 5) com 0,34 e 0,81; rótulos Figtree 11/700 tinta',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      expect(
        (RingProgressPainter.radius, RingProgressPainter.stroke),
        (18.0, 5.0),
      );
      for (final (card, progress) in [
        ('alsoReading.card1', 0.34),
        ('alsoReading.card2', 0.81),
      ]) {
        final paint = tester.widget<CustomPaint>(
          find.byKey(ValueKey('$card.ring.svg')),
        );
        final painter = paint.painter! as RingProgressPainter;
        expect(painter.progress, progress, reason: card);
        final label = _styleOf(tester, '$card.ring.label');
        expect(label, same(AppTextStyles.micro11Bold));
        expect(
          (label.fontFamily, label.fontSize, label.fontWeight, label.height),
          // CSS 800 → renderizado 700 (D-14).
          ('Figtree', 11.0, FontWeight.w700, 1.2),
        );
        expect(label.color!.toARGB32(), 0xFF1A1714);
      }
    },
  );

  testWidgets(
    '6.6 título Figtree 15/700 line-height 1,2 tinta; autor Figtree 13/500 #5B544B',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      for (final card in ['alsoReading.card1', 'alsoReading.card2']) {
        final title = _styleOf(tester, '$card.title');
        expect(title, same(AppTextStyles.title15));
        expect(
          (title.fontFamily, title.fontSize, title.fontWeight, title.height),
          ('Figtree', 15.0, FontWeight.w700, 1.2),
        );
        expect(title.color!.toARGB32(), 0xFF1A1714);
        final author = _styleOf(tester, '$card.author');
        expect(author, same(AppTextStyles.body13Muted));
        expect(
          (
            author.fontFamily,
            author.fontSize,
            author.fontWeight,
            author.height,
          ),
          ('Figtree', 13.0, FontWeight.w500, 1.2),
        );
        expect(author.color!.toARGB32(), 0xFF5B544B);
        for (final s in [title, author]) {
          expect(s.fontFamilyFallback, ['FigtreeExt']);
          expect(s.leadingDistribution, TextLeadingDistribution.even);
        }
      }
    },
  );

  testWidgets(
    'pixels @3x: cards sem sombra, capas giradas com sombra 2/2 passando por cima da borda do card, lombadas, arco, círculo vazado, anéis e contador',
    (tester) async {
      setCanvasView(tester);
      await _pumpCanvas(tester);
      final (rgba, width) = await _capture(tester);
      int at(Offset p) => _argbAt(rgba, width, p);
      const c1 = 'alsoReading.card1', c2 = 'alsoReading.card2';
      final checks = <String, (Offset, int)>{
        'contador: fundo tinta (à esquerda do "2")': (
          const Offset(157.5, 566.16),
          0xFF1A1714,
        ),
        'card 1: fundo #FFFAF1 abaixo do autor': (
          const Offset(100, 722),
          0xFFFFFAF1,
        ),
        'card 1: borda esquerda': (const Offset(20.5, 690), 0xFF1A1714),
        'card 1: borda inferior': (const Offset(100, 730), 0xFF1A1714),
        'card 1 sem sombra: papel à direita da borda': (
          const Offset(190.5, 690),
          0xFFF7F0E3,
        ),
        'card 1 sem sombra: papel abaixo da borda': (
          const Offset(100, 732),
          0xFFF7F0E3,
        ),
        'card 2: fundo #FFFAF1': (const Offset(300, 722), 0xFFFFFAF1),
        'card 2 sem sombra: papel à direita da borda': (
          const Offset(371.5, 690),
          0xFFF7F0E3,
        ),
        // Mrs. Dalloway (−4°).
        'capa 1: verde no meio (entre o arco e o título)': (
          _coverPoint(tester, c1, const Offset(27, 40.5)),
          0xFFABCF82,
        ),
        'capa 1: arco tinta (parte reta de baixo)': (
          _coverPoint(tester, c1, const Offset(29.5, 30)),
          0xFF1A1714,
        ),
        'capa 1: canto do arco arredondado (raio 16)': (
          _coverPoint(tester, c1, const Offset(14.5, 14.5)),
          0xFFABCF82,
        ),
        'capa 1: sombra girada à direita': (
          _coverPoint(tester, c1, const Offset(55, 40.5)),
          0xFF1A1714,
        ),
        'capa 1: sombra girada embaixo': (
          _coverPoint(tester, c1, const Offset(27, 82)),
          0xFF1A1714,
        ),
        'capa 1: card além da sombra': (
          _coverPoint(tester, c1, const Offset(57.5, 40.5)),
          0xFFFFFAF1,
        ),
        'capa 1 por cima da borda superior do card (y 607,16–608,66)': (
          const Offset(45, 607.91),
          0xFFABCF82,
        ),
        'capa 1 acima do card (vazamento)': (
          const Offset(62.5, 595),
          0xFFABCF82,
        ),
        // Orgulho e Preconceito (+3°).
        'capa 2: rosa no meio': (
          _coverPoint(tester, c2, const Offset(27, 45)),
          0xFFFFC1C6,
        ),
        'capa 2: círculo vazado (centro rosa)': (
          _coverPoint(tester, c2, const Offset(28.5, 24.5)),
          0xFFFFC1C6,
        ),
        'capa 2: traço do círculo': (
          _coverPoint(tester, c2, const Offset(28.5 + 9.25, 24.5)),
          0xFF1A1714,
        ),
        'capa 2: sombra girada à direita': (
          _coverPoint(tester, c2, const Offset(55, 40.5)),
          0xFF1A1714,
        ),
        'capa 2: card além da sombra': (
          _coverPoint(tester, c2, const Offset(57.5, 40.5)),
          0xFFFFFAF1,
        ),
        'capa 2 por cima da borda superior do card': (
          const Offset(230, 607.91),
          0xFFFFC1C6,
        ),
        'capa 2 acima do card (vazamento)': (
          const Offset(243.5, 595),
          0xFFFFC1C6,
        ),
        // Anel 34 % (arco de 0° a 122,4°, pontas redondas de raio 2,5 ≈ 7,96°).
        'anel 1: arco a 60°': (_ringPoint(tester, c1, 60), 0xFF1A1714),
        'anel 1: ponta inicial a −5° (antes do topo)': (
          _ringPoint(tester, c1, -5),
          0xFF1A1714,
        ),
        'anel 1: trilho a 140° (depois da ponta)': (
          _ringPoint(tester, c1, 140),
          0xFFEAE1CF,
        ),
        'anel 1: trilho a 180°': (_ringPoint(tester, c1, 180), 0xFFEAE1CF),
        'anel 1: trilho a 270°': (_ringPoint(tester, c1, 270), 0xFFEAE1CF),
        'anel 1: trilho a −15°': (_ringPoint(tester, c1, -15), 0xFFEAE1CF),
        'anel 1: miolo claro (acima do rótulo)': (
          tester.getCenter(find.byKey(const ValueKey('$c1.ring'))) +
              const Offset(0, -12),
          0xFFFFFAF1,
        ),
        // Anel 81 % (arco de 0° a 291,6°).
        'anel 2: arco a 90°': (_ringPoint(tester, c2, 90), 0xFF1A1714),
        'anel 2: arco a 180°': (_ringPoint(tester, c2, 180), 0xFF1A1714),
        'anel 2: arco a 270°': (_ringPoint(tester, c2, 270), 0xFF1A1714),
        'anel 2: trilho a 320° (depois da ponta)': (
          _ringPoint(tester, c2, 320),
          0xFFEAE1CF,
        ),
      };
      final failures = <String>[];
      checks.forEach((what, check) {
        final got = at(check.$1);
        debugPrint(
          '[pixels] $what em (${check.$1.dx.toStringAsFixed(2)}; ${check.$1.dy.toStringAsFixed(2)}): '
          '0x${got.toRadixString(16).toUpperCase()}',
        );
        if (got != check.$2) {
          failures.add(
            '$what: 0x${got.toRadixString(16).toUpperCase()} ≠ 0x${check.$2.toRadixString(16).toUpperCase()}',
          );
        }
      });
      // Lombadas: rgba(0,0,0,.15) sobre o verde e rgba(0,0,0,.12) sobre o rosa (src-over).
      for (final (what, card, base, alpha) in [
        ('lombada 1', c1, 0xABCF82, 38),
        ('lombada 2', c2, 0xFFC1C6, 31),
      ]) {
        final got = at(
          _coverPoint(tester, card, const Offset(1.5 + 2.5, 40.5)),
        );
        final want = _darken(base, alpha);
        final channels = [(got >> 16) & 0xFF, (got >> 8) & 0xFF, got & 0xFF];
        debugPrint(
          '[pixels] $what: 0x${got.toRadixString(16).toUpperCase()} '
          '(src-over exato ${want.map((v) => v.toStringAsFixed(2)).join(', ')})',
        );
        expect(got >>> 24, 0xFF);
        for (var c = 0; c < 3; c++) {
          // Só o arredondamento de 8 bits da composição.
          expect(channels[c], closeTo(want[c], 1), reason: '$what canal $c');
        }
      }
      expect(failures, isEmpty, reason: failures.join('\n'));
    },
  );

  testWidgets(
    'sem ripple: nenhum InkWell/InkResponse/Material/Ink na seção; cada card só escala 0,97 no toque (D-04)',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('alsoReading')),
          matching: find.byWidgetPredicate(
            (w) =>
                w is InkWell || w is InkResponse || w is Material || w is Ink,
          ),
        ),
        findsNothing,
      );
      for (final id in ['alsoReading.card1', 'alsoReading.card2']) {
        final scale = find.ancestor(
          of: find.byKey(ValueKey(id)),
          matching: find.byType(AnimatedScale),
        );
        expect(scale, findsOneWidget, reason: id);
        expect(tester.widget<AnimatedScale>(scale).scale, 1.0, reason: id);
        final gesture = await tester.startGesture(
          tester.getCenter(find.byKey(ValueKey('$id.textBlock'))),
        );
        await tester.pump();
        expect(tester.widget<AnimatedScale>(scale).scale, 0.97, reason: id);
        await gesture.up();
        await tester.pumpAndSettle();
        // F12: soltar dentro do alvo agora navega (o callback está ligado): voltar devolve a Início.
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(tester.widget<AnimatedScale>(scale).scale, 1.0, reason: id);
      }
    },
  );
}

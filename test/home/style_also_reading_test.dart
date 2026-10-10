import 'dart:math' as math;
import 'dart:typed_data';

import 'package:app_leitura/app/app.dart';
import 'package:app_leitura/core/design_system/painters/ring_progress_painter.dart';
import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/tokens/app_radii.dart';
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

/// F06 — camada 2 (estilo, sem tolerância) da seção `alsoReading`; desde a T03 a da prancha 01 (L01a3): o cartão 1 é o
/// Brás Cubas de papel (a capa da cartola — exata em `test/home/inicio01/tambem_lendo_test.dart` —, o "play" e a
/// pílula "Papel · 3h 40min") e só o Orgulho tem anel.
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

  testWidgets('6.5 anel (só o Orgulho, D-253): RingProgressPainter (r 18, traço 5) com 0,81; rótulo Figtree 11/700 tinta; o '
      'cartão de papel sem página não tem anel', (tester) async {
    setCanvasView(tester);
    await pumpApp(tester);
    expect(
      (RingProgressPainter.radius, RingProgressPainter.stroke),
      (18.0, 5.0),
    );
    expect(find.byKey(const ValueKey('alsoReading.card1.ring')), findsNothing);
    for (final (card, progress) in [('alsoReading.card2', 0.81)]) {
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
  });

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

  testWidgets('pixels @3x: cartões sem sombra, capas giradas com sombra 2/2 passando por cima da borda do cartão, lombadas, '
      'cartola, círculo vazado, "play", pílulas, anel e contador', (tester) async {
    setCanvasView(tester);
    await _pumpCanvas(tester);
    final (rgba, width) = await _capture(tester);
    int at(Offset p) => _argbAt(rgba, width, p);
    Rect r(String id) => tester.getRect(find.byKey(ValueKey(id)));
    const c1 = 'alsoReading.card1', c2 = 'alsoReading.card2';
    final card1 = r(c1), card2 = r(c2), count = r('alsoReading.count');
    final play = r('$c1.play'), meta1 = r('$c1.meta');
    final checks = <String, (Offset, int)>{
      'contador: fundo tinta (à esquerda do "3")': (
        Offset(count.left + 3.5, count.center.dy),
        0xFF1A1714,
      ),
      'cartão 1: fundo #FFFAF1 no padding de baixo': (
        Offset(card1.center.dx, card1.bottom - 6),
        0xFFFFFAF1,
      ),
      'cartão 1: borda esquerda': (
        Offset(card1.left + 0.5, card1.center.dy),
        0xFF1A1714,
      ),
      'cartão 1: borda inferior': (
        Offset(card1.center.dx, card1.bottom - 0.5),
        0xFF1A1714,
      ),
      'cartão 1 sem sombra: papel à direita da borda': (
        Offset(card1.right + 0.5, card1.center.dy),
        0xFFF7F0E3,
      ),
      'cartão 1 sem sombra: papel abaixo da borda': (
        Offset(card1.center.dx, card1.bottom + 2),
        0xFFF7F0E3,
      ),
      'cartão 2: fundo #FFFAF1 no padding de baixo': (
        Offset(card2.center.dx, card2.bottom - 6),
        0xFFFFFAF1,
      ),
      'cartão 2 sem sombra: papel à direita da borda': (
        Offset(card2.right + 0.5, card2.center.dy),
        0xFFF7F0E3,
      ),
      // Brás Cubas (−4°): pontos na borda EXTERNA da arte (padding box + 1,5).
      'capa 1: azul entre a aba e o título': (
        _coverPoint(tester, c1, const Offset(31.5, 42.5)),
        0xFF058CD7,
      ),
      'capa 1: copa da cartola tinta': (
        _coverPoint(tester, c1, const Offset(28.5, 23.5)),
        0xFF1A1714,
      ),
      'capa 1: aba tinta (centro da elipse)': (
        _coverPoint(tester, c1, const Offset(28.5, 33)),
        0xFF1A1714,
      ),
      'capa 1: canto da caixa da aba é azul (elipse)': (
        _coverPoint(tester, c1, const Offset(15, 30.7)),
        0xFF058CD7,
      ),
      'capa 1: sombra girada à direita': (
        _coverPoint(tester, c1, const Offset(55, 40.5)),
        0xFF1A1714,
      ),
      'capa 1: sombra girada embaixo': (
        _coverPoint(tester, c1, const Offset(27, 82)),
        0xFF1A1714,
      ),
      'capa 1: cartão além da sombra': (
        _coverPoint(tester, c1, const Offset(57.5, 40.5)),
        0xFFFFFAF1,
      ),
      'capa 1 por cima da borda superior do cartão': (
        Offset(
          r('$c1.cover').left + 46,
          card1.top + 0.75,
        ), // à direita da cartola
        0xFF058CD7,
      ),
      'capa 1 acima do cartão (vazamento)': (
        Offset(r('$c1.cover').left + 46, card1.top - 8),
        0xFF058CD7,
      ),
      // "play": círculo tinta (borda 1,5 tinta) com o triângulo amarelo.
      'play: círculo tinta (perto da borda)': (
        Offset(play.left + 4, play.center.dy),
        0xFF1A1714,
      ),
      'play: triângulo amarelo no centro': (
        play.center + const Offset(1, 0),
        0xFFFED170,
      ),
      'play: papel/cartão fora do círculo (canto da caixa)': (
        play.topLeft + const Offset(1, 1),
        0xFFFFFAF1,
      ),
      // Pílula "Papel · 3h 40min": fundo #F7F0E3 e borda 1,2 #E2D7C4.
      'pílula 1: fundo #F7F0E3 (entre o ícone e o texto)': (
        Offset(meta1.left + 4, meta1.center.dy),
        0xFFF7F0E3,
      ),
      'pílula 1: borda superior #E2D7C4': (
        Offset(meta1.center.dx, meta1.top + 0.5),
        0xFFE2D7C4,
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
      'capa 2: cartão além da sombra': (
        _coverPoint(tester, c2, const Offset(57.5, 40.5)),
        0xFFFFFAF1,
      ),
      'capa 2 por cima da borda superior do cartão': (
        Offset(r('$c2.cover').center.dx, card2.top + 0.75),
        0xFFFFC1C6,
      ),
      'capa 2 acima do cartão (vazamento)': (
        Offset(r('$c2.cover').center.dx, card2.top - 8),
        0xFFFFC1C6,
      ),
      // Anel 81 % (arco de 0° a 291,6°).
      'anel 2: arco a 90°': (_ringPoint(tester, c2, 90), 0xFF1A1714),
      'anel 2: arco a 180°': (_ringPoint(tester, c2, 180), 0xFF1A1714),
      'anel 2: arco a 270°': (_ringPoint(tester, c2, 270), 0xFF1A1714),
      'anel 2: trilho a 320° (depois da ponta)': (
        _ringPoint(tester, c2, 320),
        0xFFEAE1CF,
      ),
      'anel 2: miolo claro (acima do rótulo)': (
        tester.getCenter(find.byKey(const ValueKey('$c2.ring'))) +
            const Offset(0, -12),
        0xFFFFFAF1,
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
    // Lombadas: rgba(0,0,0,.18) sobre o azul e rgba(0,0,0,.12) sobre o rosa (src-over).
    for (final (what, card, base, alpha) in [
      ('lombada 1', c1, 0x058CD7, 46),
      ('lombada 2', c2, 0xFFC1C6, 31),
    ]) {
      final got = at(_coverPoint(tester, card, const Offset(1.5 + 2.5, 50.5)));
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
  });

  testWidgets('sem ripple: nenhum InkWell/InkResponse/Material/Ink na seção; a capa do Brás Cubas, o "play" e o cartão do '
      'Orgulho só escalam 0,97 no toque (D-04)', (tester) async {
    setCanvasView(tester);
    await pumpApp(tester);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('alsoReading')),
        matching: find.byWidgetPredicate(
          (w) => w is InkWell || w is InkResponse || w is Material || w is Ink,
        ),
      ),
      findsNothing,
    );
    for (final (id, escala, navega) in [
      (
        'alsoReading.card1.cover',
        find.ancestor(
          of: find.byKey(const ValueKey('alsoReading.card1.cover')),
          matching: find.byType(AnimatedScale),
        ),
        true,
      ),
      (
        'alsoReading.card1.play',
        find.descendant(
          of: find.byKey(const ValueKey('alsoReading.card1.play')),
          matching: find.byType(AnimatedScale),
        ),
        false, // sem ação até a T04 (D-243 b)
      ),
      (
        'alsoReading.card2',
        find.ancestor(
          of: find.byKey(const ValueKey('alsoReading.card2')),
          matching: find.byType(AnimatedScale),
        ),
        true,
      ),
    ]) {
      expect(escala, findsOneWidget, reason: id);
      expect(tester.widget<AnimatedScale>(escala).scale, 1.0, reason: id);
      final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(ValueKey(id))),
      );
      await tester.pump();
      expect(tester.widget<AnimatedScale>(escala).scale, 0.97, reason: id);
      await gesture.up();
      await tester.pumpAndSettle();
      // Soltar dentro do alvo navega (a página do livro): voltar devolve a Início.
      if (navega) {
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
      }
      expect(tester.widget<AnimatedScale>(escala).scale, 1.0, reason: id);
    }
  });
}

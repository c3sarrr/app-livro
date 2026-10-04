import 'dart:math' as math;
import 'dart:typed_data';

import 'package:app_leitura/app/app.dart';
import 'package:app_leitura/core/design_system/painters/chromium_dash.dart';
import 'package:app_leitura/core/design_system/painters/goal_dial_painter.dart';
import 'package:app_leitura/core/design_system/painters/hatch_painter.dart';
import 'package:app_leitura/core/design_system/painters/top_border_crescent_painter.dart';
import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/tokens/app_icons.dart';
import 'package:app_leitura/core/design_system/tokens/app_radii.dart';
import 'package:app_leitura/core/design_system/tokens/app_shadows.dart';
import 'package:app_leitura/core/design_system/tokens/app_typography.dart';
import 'package:app_leitura/core/design_system/widgets/app_svg.dart';
import 'package:app_leitura/core/design_system/widgets/neo_box.dart';
import 'package:app_leitura/core/design_system/widgets/pill.dart';
import 'package:app_leitura/features/home/presentation/home_screen.dart';
import 'package:app_leitura/features/home/application/home_providers.dart';
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

NeoBox _neoBox(WidgetTester tester, String id) =>
    tester.widget<NeoBox>(find.byKey(ValueKey<String>(id)));

T _painterOf<T extends CustomPainter>(WidgetTester tester, Finder finder) =>
    tester.widget<CustomPaint>(finder).painter! as T;

/// O CustomPaint dentro de [id] cujo pintor é do tipo [T].
Finder _paintIn<T extends CustomPainter>(String id) => find.descendant(
  of: find.byKey(ValueKey<String>(id)),
  matching: find.byWidgetPredicate((w) => w is CustomPaint && w.painter is T),
);

AppText _textOf(WidgetTester tester, Finder of) => tester.widget<AppText>(
  find.descendant(of: of, matching: find.byType(AppText), matchRoot: true),
);

TextStyle _styleOf(WidgetTester tester, String id) =>
    (_textOf(tester, find.byKey(ValueKey<String>(id))).span as TextSpan).style!;

void _expectInkBorder(BoxDecoration d, double width) {
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

/// src-over de [src] (com o seu alpha) sobre [dst] opaco, arredondado ao inteiro mais próximo.
int _over(Color src, Color dst) {
  final a = src.a;
  int ch(double s, double d) => ((s * a + d * (1 - a)) * 255).round();
  return 0xFF000000 |
      (ch(src.r, dst.r) << 16) |
      (ch(src.g, dst.g) << 8) |
      ch(src.b, dst.b);
}

String _hex(int argb) => '0x${argb.toRadixString(16).toUpperCase()}';

/// Confere pixels @3x: `exato` = mesmo ARGB; com [tolerance] = ±n por canal (composição translúcida,
/// arredondamento de 8 bits do motor).
void _expectPixels(
  Uint8List rgba,
  int width,
  Map<String, (Offset, int, int)> checks,
) {
  final failures = <String>[];
  checks.forEach((what, check) {
    final (p, expected, tolerance) = check;
    final got = _argbAt(rgba, width, p);
    debugPrint(
      '[pixels] $what em (${p.dx.toStringAsFixed(2)}; ${p.dy.toStringAsFixed(2)}): ${_hex(got)} '
      '(esperado ${_hex(expected)}${tolerance == 0 ? ', exato' : ', ±$tolerance'})',
    );
    var ok = true;
    for (final shift in [24, 16, 8, 0]) {
      if ((((got >> shift) & 0xFF) - ((expected >> shift) & 0xFF)).abs() >
          tolerance) {
        ok = false;
      }
    }
    if (!ok) failures.add('$what: ${_hex(got)} ≠ ${_hex(expected)}');
  });
  expect(failures, isEmpty, reason: failures.join('\n'));
}

/// Canto superior esquerdo LÓGICO de [id] no canvas.
Offset _topLeft(WidgetTester tester, String id) =>
    tester.getTopLeft(find.byKey(ValueKey<String>(id)));

const _barHeights = [43.0, 60.0, 40.0, 30.0, 51.0, 73.0, 24.0];

/// F07 — camada 2 (estilo, sem tolerância nas decorações) da seção `today`.
void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    '7.1 cartão: #FED170, borda 1,5 tinta, raio 28, sombra dura 4/4, padding 18, recorte na padding box (raio 26,5)',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final d = _decorationOf(tester, 'today');
      expect(d.color!.toARGB32(), 0xFFFED170);
      expect(d.color, AppColors.sun);
      _expectInkBorder(d, 1.5);
      expect(d.borderRadius, BorderRadius.circular(28));
      expect(AppRadii.card, 28);
      expect(d.gradient, isNull);
      expect(d.boxShadow, hasLength(1));
      final s = d.boxShadow!.single;
      expect(
        (s.offset, s.blurRadius, s.spreadRadius, s.color.toARGB32()),
        (AppShadows.hard4, 0.0, 0.0, 0xFF1A1714),
      );
      expect(AppShadows.hard4, const Offset(4, 4));
      expect(s.blurStyle, BlurStyle.normal);

      // overflow: hidden → recorte dos filhos na padding box, raio interno 28 − 1,5 = 26,5, com suavização.
      final box = _neoBox(tester, 'today');
      expect(box.clip, isTrue);
      final clip = _clipOf(tester, 'today');
      expect(clip.borderRadius, BorderRadius.circular(28 - 1.5));
      expect(clip.clipBehavior, Clip.antiAlias);
      final clipRect = tester.getRect(
        find
            .descendant(
              of: find.byKey(const ValueKey('today')),
              matching: find.byType(ClipRRect),
            )
            .first,
      );
      final card = tester.getRect(find.byKey(const ValueKey('today')));
      expect(clipRect.left - card.left, 1.5);
      expect(clipRect.top - card.top, moreOrLessEquals(1.5, epsilon: 1e-9));
      expect(card.right - clipRect.right, 1.5);
      expect(
        card.bottom - clipRect.bottom,
        moreOrLessEquals(1.5, epsilon: 1e-9),
      );
      // O único recorte do cartão (fora das barras) é esse: a Stack não recorta de novo.
      final stack = tester.widget<Stack>(
        find
            .descendant(
              of: find.byKey(const ValueKey('today')),
              matching: find.byType(Stack),
            )
            .first,
      );
      expect(stack.clipBehavior, Clip.none);
      final clips = find.descendant(
        of: find.byKey(const ValueKey('today')),
        matching: find.byWidgetPredicate(
          (w) =>
              w is ClipRect || w is ClipRRect || w is ClipPath || w is ClipOval,
        ),
      );
      // cartão + 7 trilhos.
      expect(clips, findsNWidgets(8));
      // padding 18 e coluna gap 16, esticada.
      final padding = stack.children.last as Padding;
      expect(padding.padding, const EdgeInsets.all(18));
      final column = padding.child! as Column;
      expect(column.spacing, 16);
      expect(column.crossAxisAlignment, CrossAxisAlignment.stretch);
      expect(column.mainAxisSize, MainAxisSize.min);
    },
  );

  testWidgets(
    '7.1 círculos: 153 e 101 (content-box), só borda 1,5 rgba(26,23,20,.14) → 0x241A1714, raio 50 %, antes do conteúdo',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      expect(AppColors.decoRing.toARGB32(), 0x241A1714);
      expect((0.14 * 255).round(), 0x24);
      for (final (id, size) in [
        ('today.decoCircleLarge', 153.0),
        ('today.decoCircleSmall', 101.0),
      ]) {
        final d = _decorationOf(tester, id);
        expect(d.color, isNull, reason: id);
        expect(d.border, Border.all(width: 1.5, color: AppColors.decoRing));
        expect(d.borderRadius, BorderRadius.circular(size / 2), reason: id);
        expect(d.boxShadow, isNull, reason: id);
        expect(tester.getSize(find.byKey(ValueKey(id))), Size(size, size));
        // aria-hidden.
        expect(
          find.ancestor(
            of: find.byKey(ValueKey(id)),
            matching: find.byType(ExcludeSemantics),
          ),
          findsWidgets,
          reason: id,
        );
      }
      // Ordem na Stack: os dois Positioned primeiro (atrás), o conteúdo por último.
      final stack = tester.widget<Stack>(
        find
            .descendant(
              of: find.byKey(const ValueKey('today')),
              matching: find.byType(Stack),
            )
            .first,
      );
      expect(stack.children, hasLength(3));
      final large = stack.children[0] as Positioned;
      final small = stack.children[1] as Positioned;
      expect((large.right, large.top), (-46.0, -46.0));
      expect((small.right, small.top), (-20.0, -20.0));
      expect(stack.children[2], isA<Padding>());
    },
  );

  testWidgets(
    '7.1 pixels: anel dos círculos sobre o amarelo; círculo pequeno ATRÁS da pílula; nada fora do cartão',
    (tester) async {
      setCanvasView(tester);
      await _pumpCanvas(tester);
      final (rgba, width) = await _capture(tester);
      final section = _topLeft(tester, 'today');
      // Centro comum dos círculos: (318; 32) da seção. Raio médio do traço: 76,5 − 0,75 e 50,5 − 0,75.
      final center = section + const Offset(318, 32);
      final ring = _over(AppColors.decoRing, AppColors.sun);
      _expectPixels(rgba, width, {
        'cartão (fundo)': (section + const Offset(200, 60), 0xFFFED170, 0),
        'círculo grande, no amarelo (lado esquerdo)': (
          center + const Offset(-75.75, 0),
          ring,
          1,
        ),
        'círculo grande, no amarelo (embaixo)': (
          center + const Offset(0, 75.75),
          ring,
          1,
        ),
        'círculo pequeno, no amarelo (embaixo)': (
          center + const Offset(0, 49.75),
          ring,
          1,
        ),
        // Onde o círculo pequeno passa sob a pílula, vale a pílula: o círculo pinta ATRÁS do conteúdo.
        'círculo pequeno sob a pílula → fundo da pílula': (
          center + const Offset(-49.75, 0),
          0xFFFFFAF1,
          0,
        ),
        // Recortado pelo cartão: o trecho acima dele não aparece (papel entre as seções).
        'círculo grande acima do cartão → papel': (
          center + Offset(-math.sqrt(75.75 * 75.75 - 48.76 * 48.76), -48.76),
          0xFFF7F0E3,
          0,
        ),
      });
    },
  );

  testWidgets(
    '7.2 título misto (Bricolage20 20/800/1,2 ls −0,4 + InstrumentSerif itálico 23/1,3 ls −0,2) e pílula #FFFAF1 borda 1,5 raio 999 (→ 16)',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final title = _textOf(tester, find.byKey(const ValueKey('today.title')));
      final root = title.span as TextSpan;
      final serif = (root.children!.single as TextSpan).style!;
      expect(root.style, same(AppTextStyles.cardTitleM));
      expect(serif, same(AppTextStyles.cardSerifM));
      expect(
        (
          root.style!.fontFamily,
          root.style!.fontSize,
          root.style!.fontWeight,
          root.style!.fontStyle,
          root.style!.height,
          root.style!.letterSpacing,
        ),
        ('Bricolage20', 20.0, FontWeight.w800, null, 1.2, -0.4),
      );
      expect(root.style!.fontFamilyFallback, [
        'Bricolage20Ext',
        'Bricolage20Vi',
      ]);
      expect(
        (
          serif.fontFamily,
          serif.fontSize,
          serif.fontWeight,
          serif.fontStyle,
          serif.height,
          serif.letterSpacing,
        ),
        ('InstrumentSerif', 23.0, FontWeight.w400, FontStyle.italic, 1.3, -0.2),
      );
      expect(serif.fontFamilyFallback, ['InstrumentSerifExt']);
      for (final s in [root.style!, serif]) {
        expect(s.color!.toARGB32(), 0xFF1A1714);
        expect(s.leadingDistribution, TextLeadingDistribution.even);
      }

      final header = tester.widget<Row>(
        find.byKey(const ValueKey('today.header')),
      );
      expect(header.mainAxisAlignment, MainAxisAlignment.spaceBetween);
      expect(header.crossAxisAlignment, CrossAxisAlignment.center);

      final pill = _decorationOf(tester, 'today.streakPill');
      expect(pill.color!.toARGB32(), 0xFFFFFAF1);
      _expectInkBorder(pill, 1.5);
      expect(pill.borderRadius, BorderRadius.circular(999));
      expect(pill.boxShadow, isNull);
      final rect = tester.getRect(
        find.byKey(const ValueKey('today.streakPill')),
      );
      expect(
        BorderRadius.circular(999).toRRect(rect).scaleRadii().tlRadiusX,
        moreOrLessEquals(16, epsilon: 1e-9),
      );
      final box = _neoBox(tester, 'today.streakPill');
      expect(box.height, 32);
      expect(box.padding, const EdgeInsets.fromLTRB(8, 0, 11, 0));
      final row = tester.widget<Row>(
        find
            .descendant(
              of: find.byKey(const ValueKey('today.streakPill')),
              matching: find.byType(Row),
            )
            .first,
      );
      expect(row.spacing, 5);
      expect(row.mainAxisSize, MainAxisSize.min);
      final icon = tester.widget<AppSvg>(
        find.byKey(const ValueKey('today.streakPill.icon')),
      );
      expect((icon.asset, icon.size), (AppIcons.flame, 17.0));
      final label = _textOf(
        tester,
        find.byKey(const ValueKey('today.streakPill')),
      );
      final style = (label.span as TextSpan).style!;
      expect(style, same(AppTextStyles.body13Bold));
      // CSS 800 → renderizado 700 (D-14).
      expect(
        (style.fontFamily, style.fontSize, style.fontWeight, style.height),
        ('Figtree', 13.0, FontWeight.w700, 1.2),
      );
      expect(style.color!.toARGB32(), 0xFF1A1714);
    },
  );

  testWidgets(
    '7.3 dial: GoalDialPainter(18/30) em 112×112 fora da semântica; "18" Bricolage34 34/1 ls −1; "de 30 min" 11/700 #4A4238',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final svg = find.byKey(const ValueKey('today.dial.svg'));
      final painter = _painterOf<GoalDialPainter>(tester, svg);
      expect(painter.progress, 18 / 30);
      expect(painter.progress, 0.6);
      expect(tester.getSize(svg), const Size(112, 112));
      expect(
        find.ancestor(of: svg, matching: find.byType(ExcludeSemantics)),
        findsWidgets,
      );
      final center = tester.widget<Column>(
        find.byKey(const ValueKey('today.dial.center')),
      );
      expect(center.mainAxisAlignment, MainAxisAlignment.center);
      expect(center.crossAxisAlignment, CrossAxisAlignment.center);

      final value = _styleOf(tester, 'today.dial.value');
      expect(value, same(AppTextStyles.dialValue));
      expect(
        (
          value.fontFamily,
          value.fontSize,
          value.fontWeight,
          value.height,
          value.letterSpacing,
        ),
        ('Bricolage34', 34.0, FontWeight.w800, 1.0, -1.0),
      );
      expect(value.color!.toARGB32(), 0xFF1A1714);
      final caption = _styleOf(tester, 'today.dial.caption');
      expect(caption, same(AppTextStyles.dialCaption));
      expect(
        (
          caption.fontFamily,
          caption.fontSize,
          caption.fontWeight,
          caption.height,
        ),
        ('Figtree', 11.0, FontWeight.w700, 1.2),
      );
      expect(caption.color!.toARGB32(), 0xFF4A4238);
    },
  );

  testWidgets(
    '7.3 pixels: face #FFFAF1 com traço, marcação .35, arco tinta com ponta redonda no topo, pino #FF552E por cima do arco',
    (tester) async {
      setCanvasView(tester);
      await _pumpCanvas(tester);
      final (rgba, width) = await _capture(tester);
      final dial = _topLeft(tester, 'today.dial');
      const c = Offset(56, 56);
      Offset polar(double r, double degrees) =>
          dial +
          c +
          Offset(
            r * math.cos(degrees * math.pi / 180),
            r * math.sin(degrees * math.pi / 180),
          );
      // Marcação 15: começa em 15 × 9,21 = 138,15 de arco (às 3 h, sentido horário) — centro em 138,9/44 rad.
      final tick = polar(44, 138.9 / 44 * 180 / math.pi);
      final knob = dial + const Offset(30.137, 91.597);
      _expectPixels(rgba, width, {
        'face (miolo, à esquerda do texto)': (
          dial + const Offset(25, 56),
          0xFFFFFAF1,
          0,
        ),
        'traço da face (r 54, à direita)': (polar(54, 0), 0xFF1A1714, 0),
        'fora da face (canto do quadrado) → cartão': (
          dial + const Offset(4, 4),
          0xFFFED170,
          0,
        ),
        'marcação às 9 h (r 44, .35)': (
          tick,
          _over(AppColors.dialTick, AppColors.surface),
          1,
        ),
        'entre marcações (vão, 9 h + 5 px de arco)': (
          polar(44, 180 + 5 / 44 * 180 / math.pi),
          0xFFFFFAF1,
          0,
        ),
        'arco às 3 h (r 44)': (polar(44, 0), 0xFF1A1714, 0),
        'arco às 6 h (r 44)': (polar(44, 90), 0xFF1A1714, 0),
        'ponta redonda antes do topo (−93°)': (polar(44, -93), 0xFF1A1714, 0),
        'depois do pino (145°) → marcações/face, sem arco': (
          polar(40.5, 145),
          0xFFFFFAF1,
          0,
        ),
        'pino (centro) por cima do arco': (knob, 0xFFFF552E, 0),
        'traço do pino (r 6, para fora do arco)': (
          knob + Offset(-6 * math.cos(math.pi / 4), 6 * math.sin(math.pi / 4)),
          0xFF1A1714,
          0,
        ),
      });
    },
  );

  testWidgets(
    '7.4 frase 15/600/1,3 + "12 min" 15/700/1,3; chips rgba(255,250,241,.7) → 0xB3FFFAF1, borda 1,2, raio 999, padding 5/9, 12/700; Wrap gap 6',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final sentence =
          _textOf(
                tester,
                find.byKey(const ValueKey('today.goalText.sentence')),
              ).span
              as TextSpan;
      final base = sentence.style!;
      final strong = (sentence.children!.first as TextSpan).style!;
      expect(base, same(AppTextStyles.goalSentence));
      expect(strong, same(AppTextStyles.goalSentenceStrong));
      expect(
        (base.fontFamily, base.fontSize, base.fontWeight, base.height),
        ('Figtree', 15.0, FontWeight.w600, 1.3),
      );
      // CSS 800 → renderizado 700 (D-14).
      expect(
        (strong.fontFamily, strong.fontSize, strong.fontWeight, strong.height),
        ('Figtree', 15.0, FontWeight.w700, 1.3),
      );
      for (final s in [base, strong]) {
        expect(s.color!.toARGB32(), 0xFF1A1714);
        expect(s.letterSpacing, 0);
        expect(s.leadingDistribution, TextLeadingDistribution.even);
      }

      final goalText = tester.widget<Column>(
        find.byKey(const ValueKey('today.goalText')),
      );
      expect(goalText.spacing, 10);
      expect(goalText.crossAxisAlignment, CrossAxisAlignment.stretch);
      final wrap = tester.widget<Wrap>(
        find.byKey(const ValueKey('today.chips')),
      );
      expect((wrap.spacing, wrap.runSpacing), (6.0, 6.0));
      expect(wrap.direction, Axis.horizontal);

      expect(AppColors.chipGlass.toARGB32(), 0xB3FFFAF1);
      expect((0.7 * 255).round(), 0xB3);
      for (final id in ['today.chip.pages', 'today.chip.highlights']) {
        final d = _decorationOf(tester, id);
        expect(d.color, AppColors.chipGlass, reason: id);
        _expectInkBorder(d, 1.2);
        expect(d.borderRadius, BorderRadius.circular(999), reason: id);
        expect(d.boxShadow, isNull, reason: id);
        final pill = tester.widget<Pill>(find.byKey(ValueKey(id)));
        expect(
          pill.padding,
          const EdgeInsets.symmetric(vertical: 5, horizontal: 9),
          reason: id,
        );
        expect(pill.border, const BorderSide(width: 1.2, color: AppColors.ink));
        final rect = tester.getRect(find.byKey(ValueKey(id)));
        // 26,8 / 2; a altura vem do texto (float32 do SkParagraph) → ±1e-3.
        expect(
          BorderRadius.circular(999).toRRect(rect).scaleRadii().tlRadiusX,
          moreOrLessEquals(13.4, epsilon: 1e-3),
          reason: id,
        );
        final s =
            (_textOf(tester, find.byKey(ValueKey(id))).span as TextSpan).style!;
        expect(s, same(AppTextStyles.label12Bold), reason: id);
        expect(
          (s.fontFamily, s.fontSize, s.fontWeight, s.height),
          ('Figtree', 12.0, FontWeight.w700, 1.2),
        );
        expect(s.color!.toARGB32(), 0xFF1A1714);
      }
    },
  );

  testWidgets(
    '7.4 pixels: fundo dos chips = .7 de #FFFAF1 sobre o amarelo; borda 1,2 em tinta',
    (tester) async {
      setCanvasView(tester);
      await _pumpCanvas(tester);
      final (rgba, width) = await _capture(tester);
      final glass = _over(AppColors.chipGlass, AppColors.sun);
      final checks = <String, (Offset, int, int)>{};
      for (final id in ['today.chip.pages', 'today.chip.highlights']) {
        final r = tester.getRect(find.byKey(ValueKey(id)));
        checks['$id: fundo (entre a borda e o texto)'] = (
          Offset(r.left + 5.2, r.center.dy),
          glass,
          1,
        );
        checks['$id: borda esquerda (1,2)'] = (
          Offset(r.left + 0.6, r.center.dy),
          0xFF1A1714,
          0,
        );
        checks['$id: amarelo logo fora'] = (
          Offset(r.left - 1, r.center.dy),
          0xFFFED170,
          0,
        );
      }
      _expectPixels(rgba, width, checks);
    },
  );

  testWidgets(
    '7.5 cartão da semana: #FFFAF1, borda 1,5, raio 22, sem sombra nem recorte; padding 14/14/12, gap 8; cabeçalho por baseline',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final d = _decorationOf(tester, 'today.week');
      expect(d.color!.toARGB32(), 0xFFFFFAF1);
      _expectInkBorder(d, 1.5);
      expect(d.borderRadius, BorderRadius.circular(22));
      expect(AppRadii.cardM, 22);
      expect(d.boxShadow, isNull);
      final box = _neoBox(tester, 'today.week');
      expect(box.clip, isFalse);
      expect(box.padding, const EdgeInsets.fromLTRB(14, 14, 14, 12));
      final column = box.child! as Column;
      expect(column.spacing, 8);
      expect(column.crossAxisAlignment, CrossAxisAlignment.stretch);

      final header = tester.widget<Row>(
        find.byKey(const ValueKey('today.week.header')),
      );
      expect(header.mainAxisAlignment, MainAxisAlignment.spaceBetween);
      expect(header.crossAxisAlignment, CrossAxisAlignment.baseline);
      expect(header.textBaseline, TextBaseline.alphabetic);
      final title = _styleOf(tester, 'today.week.title');
      expect(title, same(AppTextStyles.body13Bold));
      final total = _styleOf(tester, 'today.week.total');
      expect(total, same(AppTextStyles.caption12Muted));
      expect(
        (total.fontFamily, total.fontSize, total.fontWeight, total.height),
        ('Figtree', 12.0, FontWeight.w600, 1.2),
      );
      expect(total.color!.toARGB32(), 0xFF5B544B);
      // A baseline comum: o total começa 0,95 abaixo do título (ascendente menor).
      final titleTop = tester.getTopLeft(
        find.byKey(const ValueKey('today.week.title')),
      );
      final totalTop = tester.getTopLeft(
        find.byKey(const ValueKey('today.week.total')),
      );
      expect(totalTop.dy - titleTop.dy, moreOrLessEquals(0.95, epsilon: 0.01));
    },
  );

  testWidgets(
    '7.6 trilhos: borda 1,2 (0–5) × 1,5 (6), raio 999 (→ 16,571), recorte interno 15,371 / 15,071; hachuras #EFE6D4 / #FDE2B2 sobre #FFFAF1',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      for (var i = 0; i < 7; i++) {
        final id = 'today.week.bar$i';
        final today = i == 6;
        final bw = today ? 1.5 : 1.2;
        final d = _decorationOf(tester, id);
        expect(d.color, isNull, reason: id);
        _expectInkBorder(d, bw);
        expect(d.borderRadius, BorderRadius.circular(999), reason: id);
        expect(d.boxShadow, isNull, reason: id);
        final rect = tester.getRect(find.byKey(ValueKey(id)));
        expect(rect.height, 80, reason: id);
        final outer = BorderRadius.circular(999).toRRect(rect).scaleRadii();
        expect(outer.tlRadiusX, moreOrLessEquals(33.142857 / 2, epsilon: 1e-3));
        final clip = _clipOf(tester, id);
        expect(clip.borderRadius, BorderRadius.circular(999 - bw), reason: id);
        expect(clip.clipBehavior, Clip.antiAlias, reason: id);
        final inner = BorderRadius.circular(999 - bw)
            .toRRect(rect.deflate(bw))
            .scaleRadii();
        expect(
          inner.tlRadiusX,
          moreOrLessEquals(33.142857 / 2 - bw, epsilon: 1e-3),
          reason: '$id: raio interno = externo − borda',
        );
        final hatch = _painterOf<HatchPainter>(
          tester,
          _paintIn<HatchPainter>(id),
        );
        expect(
          hatch.stripe.toARGB32(),
          today ? 0xFFFDE2B2 : 0xFFEFE6D4,
          reason: id,
        );
        expect(hatch.base.toARGB32(), 0xFFFFFAF1, reason: id);
        // A hachura cobre a padding box inteira (origem no canto interno superior esquerdo).
        final hatchRect = tester.getRect(_paintIn<HatchPainter>(id));
        final padding = rect.deflate(bw);
        for (final (what, got, exp) in [
          ('left', hatchRect.left, padding.left),
          ('top', hatchRect.top, padding.top),
          ('right', hatchRect.right, padding.right),
          ('bottom', hatchRect.bottom, padding.bottom),
        ]) {
          expect(
            got,
            moreOrLessEquals(exp, epsilon: 1e-9),
            reason: '$id $what',
          );
        }
      }
    },
  );

  testWidgets(
    '7.6 preenchimentos: alturas [43, 60, 40, 30, 51, 73, 24] dos dados, largura 100 % da área interna, meia-lua 1,5 tinta; weekColor #B6ACE4 em 0–5 e #FF552E em 6',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      for (var i = 0; i < 7; i++) {
        final id = 'today.week.bar$i';
        final today = i == 6;
        final bw = today ? 1.5 : 1.2;
        final fill = tester.getRect(find.byKey(ValueKey('$id.fill')));
        final bar = tester.getRect(find.byKey(ValueKey(id)));
        final size = tester.getSize(find.byKey(ValueKey('$id.fill')));
        expect(size.height, _barHeights[i], reason: id);
        expect(
          size.width,
          moreOrLessEquals((280 - 6 * 8) / 7 - 2 * bw, epsilon: 1e-9),
          reason: id,
        );
        // Encostado embaixo (align-items: flex-end), dentro da borda.
        expect(
          fill.bottom,
          moreOrLessEquals(bar.bottom - bw, epsilon: 1e-9),
          reason: id,
        );
        final crescent = _painterOf<TopBorderCrescentPainter>(
          tester,
          _paintIn<TopBorderCrescentPainter>('$id.fill'),
        );
        expect(
          crescent.fill.toARGB32(),
          today ? 0xFFFF552E : 0xFFB6ACE4,
          reason: id,
        );
        expect(crescent.border, 1.5, reason: id);
        expect(crescent.borderColor.toARGB32(), 0xFF1A1714, reason: id);
        expect(
          tester.getSize(_paintIn<TopBorderCrescentPainter>('$id.fill')),
          size,
          reason: id,
        );
      }
      // Na ordem de pintura do trilho: hachura primeiro, preenchimento por cima.
      final stack = tester.widget<Stack>(
        find
            .descendant(
              of: find.byKey(const ValueKey('today.week.bar0')),
              matching: find.byType(Stack),
            )
            .first,
      );
      expect(
        ((stack.children[0] as Positioned).child as CustomPaint).painter,
        isA<HatchPainter>(),
      );
      expect(stack.children[1], isA<Align>());
      expect((stack.children[1] as Align).alignment, Alignment.bottomCenter);
    },
  );

  testWidgets(
    '7.6 pixels: hachura "/" (listra 3 a cada 7, origem na padding box), meia-lua no topo, base recortada pela curva do trilho',
    (tester) async {
      setCanvasView(tester);
      await _pumpCanvas(tester);
      final (rgba, width) = await _capture(tester);
      // Padding box da barra 0: (55 + 1,2; 1001,36 + 1,2). t = (u + v)/√2; listra se t mod 7 < 3.
      final pad0 = _topLeft(tester, 'today.week.bar0') + const Offset(1.2, 1.2);
      Offset at(double t, double v) => pad0 + Offset(t * math.sqrt2 - v, v);
      final pad6 = _topLeft(tester, 'today.week.bar6') + const Offset(1.5, 1.5);
      Offset at6(double t, double v) => pad6 + Offset(t * math.sqrt2 - v, v);
      final fill0 = tester.getRect(
        find.byKey(const ValueKey('today.week.bar0.fill')),
      );
      final fill6 = tester.getRect(
        find.byKey(const ValueKey('today.week.bar6.fill')),
      );
      // Canto inferior esquerdo da barra 6: centro comum dos raios externo (16,571) e interno (15,071).
      final bar6 = tester.getRect(
        find.byKey(const ValueKey('today.week.bar6')),
      );
      const r6 = 33.142857142857146 / 2;
      final corner6 = Offset(bar6.left + r6, bar6.bottom - r6);
      final ringMid =
          corner6 +
          const Offset(-(r6 - 0.75) / math.sqrt2, (r6 - 0.75) / math.sqrt2);
      // O mesmo ponto está DENTRO do preenchimento de hoje (raio 12): sem o recorte do trilho ele seria laranja.
      final fillCorner6 = Offset(fill6.left + 12, fill6.bottom - 12);
      expect((ringMid - fillCorner6).distance, lessThan(12 - 0.5));
      _expectPixels(rgba, width, {
        'barra 0: listra (t = 22,5)': (at(22.5, 20), 0xFFEFE6D4, 0),
        'barra 0: mesma listra seguindo "/" (t = 22,5)': (
          at(22.5, 14),
          0xFFEFE6D4,
          0,
        ),
        'barra 0: base (t = 26)': (at(26, 20), 0xFFFFFAF1, 0),
        'barra 0: base seguindo "/" (t = 26)': (at(26, 26), 0xFFFFFAF1, 0),
        'barra 0: listra seguinte (t = 29,5)': (at(29.5, 25), 0xFFEFE6D4, 0),
        'barra 6: listra de hoje (t = 22,5)': (at6(22.5, 20), 0xFFFDE2B2, 0),
        'barra 6: base (t = 26)': (at6(26, 20), 0xFFFFFAF1, 0),
        'barra 0: meia-lua no topo do preenchimento': (
          Offset(fill0.center.dx, fill0.top + 0.75),
          0xFF1A1714,
          0,
        ),
        'barra 0: preenchimento weekColor': (
          Offset(fill0.center.dx, fill0.top + 10),
          0xFFB6ACE4,
          0,
        ),
        'barra 6: meia-lua no topo do preenchimento': (
          Offset(fill6.center.dx, fill6.top + 0.75),
          0xFF1A1714,
          0,
        ),
        'barra 6: preenchimento #FF552E': (
          Offset(fill6.center.dx, fill6.top + 10),
          0xFFFF552E,
          0,
        ),
        'barra 6: borda do trilho no canto (a base do preenchimento é recortada)':
            (ringMid, 0xFF1A1714, 0),
      });
    },
  );

  testWidgets(
    '7.7 linha da meta: ChromiumDashPainter horizontal 1,5, cor 0x731A1714 (.45), 288 × 1,5 → 64 traços; por cima das barras',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final line = find.byKey(const ValueKey('today.week.goalLine'));
      final painter = _painterOf<ChromiumDashPainter>(tester, line);
      expect(painter.axis, Axis.horizontal);
      expect(painter.thickness, 1.5);
      expect(painter.color.toARGB32(), 0x731A1714);
      expect(painter.color, AppColors.goalLine);
      expect((0.45 * 255).round(), 0x73);
      expect(tester.getSize(line), const Size(288, 1.5));
      final starts = chromiumDashStarts(length: 288, thickness: 1.5);
      expect(starts, hasLength(64));
      expect(starts.last + 3, moreOrLessEquals(288, epsilon: 1e-9));
      debugPrint(
        '[tracejado] 64 traços de 3 com vão ${(starts[1] - starts[0] - 3).toStringAsFixed(4)} (ideal 1,5)',
      );
      // Pintada DEPOIS das barras (position: absolute): último filho da Stack do gráfico.
      final stack = tester.widget<Stack>(
        find
            .descendant(
              of: find.byKey(const ValueKey('today.week.chart')),
              matching: find.byType(Stack),
            )
            .first,
      );
      expect(stack.clipBehavior, Clip.none);
      expect(stack.children, hasLength(2));
      expect(stack.children.first, isA<Row>());
      final positioned = stack.children.last as Positioned;
      expect(
        (
          positioned.left,
          positioned.right,
          positioned.bottom,
          positioned.height,
        ),
        (-4.0, -4.0, 38.0, 1.5),
      );
      expect(positioned.child.key, const ValueKey('today.week.goalLine'));
    },
  );

  testWidgets(
    '7.7 pixels: traço .45 sobre o preenchimento, vão sem traço; rótulos 11/700 #5B544B e "Hoje" 11/700 tinta, centralizados',
    (tester) async {
      setCanvasView(tester);
      await _pumpCanvas(tester);
      final (rgba, width) = await _capture(tester);
      final line = _topLeft(tester, 'today.week.goalLine');
      final starts = chromiumDashStarts(length: 288, thickness: 1.5);
      // Traço 11 sobre o preenchimento da barra 1 e o vão logo depois dele.
      final dash = line + Offset(starts[11] + 1.5, 0.75);
      final gap =
          line +
          Offset(starts[11] + 3 + (starts[12] - starts[11] - 3) / 2, 0.75);
      final fill1 = tester.getRect(
        find.byKey(const ValueKey('today.week.bar1.fill')),
      );
      expect(fill1.contains(dash) && fill1.contains(gap), isTrue);
      _expectPixels(rgba, width, {
        'traço sobre o preenchimento (weekColor)': (
          dash,
          _over(AppColors.goalLine, AppColors.lavender),
          1,
        ),
        'vão do tracejado (só o preenchimento)': (gap, 0xFFB6ACE4, 0),
      });

      for (var i = 0; i < 7; i++) {
        final id = 'today.week.label$i';
        final text = _textOf(tester, find.byKey(ValueKey(id)));
        expect(text.textAlign, TextAlign.center, reason: id);
        final s = (text.span as TextSpan).style!;
        expect(
          s,
          same(i == 6 ? AppTextStyles.micro11Bold : AppTextStyles.weekDay),
          reason: id,
        );
        expect(
          (s.fontFamily, s.fontSize, s.fontWeight, s.height),
          ('Figtree', 11.0, FontWeight.w700, 1.2),
          reason: id,
        );
        expect(
          s.color!.toARGB32(),
          i == 6 ? 0xFF1A1714 : 0xFF5B544B,
          reason: id,
        );
      }
    },
  );

  testWidgets(
    '7.8 rodapé: brilho sólido 16 + frase 13/600 com "2 dias" 13/700 (CSS 800), gap 8, centralizados',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final row = tester.widget<Row>(
        find.byKey(const ValueKey('today.footer')),
      );
      expect(row.spacing, 8);
      expect(row.crossAxisAlignment, CrossAxisAlignment.center);
      final icon = tester.widget<AppSvg>(
        find.byKey(const ValueKey('today.footer.icon')),
      );
      expect((icon.asset, icon.size), (AppIcons.sparkleSolid, 16.0));
      final span =
          _textOf(tester, find.byKey(const ValueKey('today.footer.text'))).span
              as TextSpan;
      final base = span.style!;
      final strong = (span.children!.first as TextSpan).style!;
      expect(base, same(AppTextStyles.body13Semi));
      expect(strong, same(AppTextStyles.body13Bold));
      expect(
        (base.fontFamily, base.fontSize, base.fontWeight, base.height),
        ('Figtree', 13.0, FontWeight.w600, 1.2),
      );
      expect(
        (strong.fontFamily, strong.fontSize, strong.fontWeight, strong.height),
        ('Figtree', 13.0, FontWeight.w700, 1.2),
      );
      for (final s in [base, strong]) {
        expect(s.color!.toARGB32(), 0xFF1A1714);
      }
    },
  );

  testWidgets(
    'Tema: cada opção de weekColor (AppColors.weekColorOptions) muda só os preenchimentos das barras 0–5',
    (tester) async {
      setCanvasView(tester);
      await _pumpCanvas(tester);
      final (base, width) = await _capture(tester);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(HomeScreen)),
      );
      final fills = [
        for (var i = 0; i < 6; i++)
          tester.getRect(find.byKey(ValueKey('today.week.bar$i.fill'))),
      ];
      expect(AppColors.weekColorOptions, hasLength(4));
      for (final color in AppColors.weekColorOptions) {
        container.read(homeThemeProvider.notifier).setWeekColor(color);
        await tester.pumpAndSettle();
        for (var i = 0; i < 7; i++) {
          final crescent = _painterOf<TopBorderCrescentPainter>(
            tester,
            _paintIn<TopBorderCrescentPainter>('today.week.bar$i.fill'),
          );
          expect(
            crescent.fill,
            i == 6 ? AppColors.flame : color,
            reason: 'bar$i',
          );
        }
        final (rgba, _) = await _capture(tester);
        var changed = 0, outside = 0;
        for (var i = 0; i < rgba.length; i += 4) {
          if (rgba[i] == base[i] &&
              rgba[i + 1] == base[i + 1] &&
              rgba[i + 2] == base[i + 2] &&
              rgba[i + 3] == base[i + 3]) {
            continue;
          }
          changed++;
          final px = (i ~/ 4) % width, py = (i ~/ 4) ~/ width;
          // O pixel @3x cobre [px/3, (px+1)/3) × [py/3, (py+1)/3): precisa tocar um dos 6 preenchimentos.
          final touches = fills.any(
            (f) =>
                (px + 1) / 3 > f.left &&
                px / 3 < f.right &&
                (py + 1) / 3 > f.top &&
                py / 3 < f.bottom,
          );
          if (!touches) outside++;
        }
        final sample = _argbAt(
          rgba,
          width,
          Offset(fills[0].center.dx, fills[0].top + 10),
        );
        debugPrint(
          '[tema] weekColor ${_hex(color.toARGB32())}: $changed pixels mudaram, $outside fora dos preenchimentos 0–5; '
          'preenchimento 0 = ${_hex(sample)}',
        );
        expect(outside, 0);
        expect(sample, color.toARGB32());
        if (color == AppColors.lavender) {
          expect(changed, 0); // é o padrão
        } else {
          expect(changed, greaterThan(50000));
        }
      }
    },
  );
}

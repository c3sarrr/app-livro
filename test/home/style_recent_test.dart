import 'package:app_leitura/app/app.dart';
import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/tokens/app_icons.dart';
import 'package:app_leitura/core/design_system/tokens/app_radii.dart';
import 'package:app_leitura/core/design_system/tokens/app_typography.dart';
import 'package:app_leitura/core/design_system/widgets/app_svg.dart';
import 'package:app_leitura/core/design_system/widgets/circle_icon_button.dart';
import 'package:app_leitura/core/design_system/widgets/neo_box.dart';
import 'package:app_leitura/core/design_system/widgets/pill.dart';
import 'package:app_leitura/features/home/presentation/covers/senhora_mini_cover.dart';
import 'package:app_leitura/features/home/presentation/sections/recently_added_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/overrides_do_mundo.dart';
import '../support/canvas.dart';
import '../support/capture.dart';
import '../support/load_fonts.dart';
import '../support/precache_svgs.dart';
import '../support/pump_app.dart';

/// Decoração do primeiro `DecoratedBox` sob [id] (ou do próprio, se a Key estiver nele).
BoxDecoration _decorationOf(WidgetTester tester, String id) =>
    tester
            .widget<DecoratedBox>(
              find
                  .descendant(
                    of: find.byKey(ValueKey<String>(id)),
                    matching: find.byType(DecoratedBox),
                    matchRoot: true,
                  )
                  .first,
            )
            .decoration
        as BoxDecoration;

NeoBox _neoBox(WidgetTester tester, String id) =>
    tester.widget<NeoBox>(find.byKey(ValueKey<String>(id)));

ClipRRect _clipOf(WidgetTester tester, String id) => tester.widget<ClipRRect>(
  find
      .descendant(
        of: find.byKey(ValueKey<String>(id)),
        matching: find.byType(ClipRRect),
      )
      .first,
);

/// Estilo do único `AppText` sob [id].
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

/// Tipografia completa de um estilo: família, tamanho, peso, altura de linha, espaçamento, fallbacks,
/// cor e distribuição "even".
void _expectTypography(
  TextStyle s, {
  required String family,
  required List<String> fallback,
  required double size,
  required FontWeight weight,
  required double height,
  required double letterSpacing,
  required int color,
  String? reason,
}) {
  expect(
    (s.fontFamily, s.fontSize, s.fontWeight, s.height, s.letterSpacing),
    (family, size, weight, height, letterSpacing),
    reason: reason,
  );
  expect(s.fontFamilyFallback, fallback, reason: reason);
  expect(s.fontStyle, isNull, reason: reason);
  expect(s.color!.toARGB32(), color, reason: reason);
  expect(s.leadingDistribution, TextLeadingDistribution.even, reason: reason);
}

void _expectFigtree(
  TextStyle s, {
  required double size,
  required FontWeight weight,
  required int color,
  String? reason,
}) => _expectTypography(
  s,
  family: 'Figtree',
  fallback: ['FigtreeExt'],
  size: size,
  weight: weight,
  height: 1.2, // line-height normal
  letterSpacing: 0,
  color: color,
  reason: reason,
);

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
  expect(
    (image.width, image.height),
    (390 * 3, 2650 * 3),
    reason: 'canvas inteiro @3x',
  );
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

/// Chamadas ao canvas de [r] pintando a sua subárvore INTEIRA, em coordenadas do próprio [r]. Como no
/// `PaintingContext` real, `Clip.none` não gera chamada de recorte e um `Transform` identidade/translação não
/// gera `transform`.
List<RecordedInvocation> _paintCalls(RenderObject r) {
  final canvas = TestRecordingCanvas();
  final context = TestRecordingPaintingContext(canvas);
  r.paint(context, Offset.zero);
  context.dispose();
  return canvas.invocations;
}

const _clipMethods = {#clipRect, #clipRRect, #clipPath, #clipRSuperellipse};

/// Chamadas que só mudam o estado do canvas (o resto desenha).
const _stateMethods = {
  #save,
  #restore,
  #restoreToCount,
  #translate,
  #transform,
  ..._clipMethods,
};

/// Os números de um [RRect] (l, t, r, b e os raios x/y de TL, TR, BR, BL) ou de um [Rect] (l, t, r, b).
List<double> _shapeNumbers(Object shape) => switch (shape) {
  RRect(
    :final left,
    :final top,
    :final right,
    :final bottom,
    :final tlRadiusX,
    :final tlRadiusY,
    :final trRadiusX,
    :final trRadiusY,
    :final brRadiusX,
    :final brRadiusY,
    :final blRadiusX,
    :final blRadiusY,
  ) =>
    [
      left,
      top,
      right,
      bottom,
      tlRadiusX,
      tlRadiusY,
      trRadiusX,
      trRadiusY,
      brRadiusX,
      brRadiusY,
      blRadiusX,
      blRadiusY,
    ],
  Rect(:final left, :final top, :final right, :final bottom) => [
    left,
    top,
    right,
    bottom,
  ],
  _ => throw ArgumentError.value(shape, 'shape', 'nem Rect nem RRect'),
};

/// Confere uma forma registrada no canvas contra a esperada, número a número (±[epsilon]).
void _expectShape(
  Object got,
  Object want, {
  double epsilon = 1e-9,
  String? reason,
}) {
  expect(got.runtimeType, want.runtimeType, reason: reason);
  final g = _shapeNumbers(got), w = _shapeNumbers(want);
  for (var i = 0; i < w.length; i++) {
    expect(
      g[i],
      moreOrLessEquals(w[i], epsilon: epsilon),
      reason: '${reason ?? ''} [número $i de $got]',
    );
  }
}

/// Nome de um método registrado (`#drawRRect` → `drawRRect`).
String _methodName(Symbol s) {
  final text = '$s'; // Symbol("drawRRect")
  return text.substring(8, text.length - 2);
}

/// Descrição curta de um desenho: método + cor do `Paint`.
String _drawLabel(Invocation draw) {
  final name = _methodName(draw.memberName);
  final paint = draw.positionalArguments.whereType<Paint>().firstOrNull;
  if (paint == null) return name;
  return '$name ${_hex(paint.color.toARGB32())}';
}

const _ink = 0xFF1A1714;
const _paper = 0xFFF7F0E3;
const _surface = 0xFFFFFAF1;
const _muted = 0xFF5B544B;
const _lavender = 0xFFB6ACE4;
const _amber = 0xFFF2A815;
const _divider = 0xFFE9E1D2;
const _tagLavenderBg = 0xFFECE7FA;
const _tagLavenderFg = 0xFF3B2D86;
const _tagSandBg = 0xFFEFE7D7;
const _tagSandFg = 0xFF4A4238;

/// "Lido" (prancha 01, D-255).
const _tagReadBg = 0xFFE1EDD0;
const _tagReadFg = 0xFF2E5314;

/// F10 — camada 2 (estilo, sem tolerância) da seção `recent`; desde a T03 com os dados da prancha 01 (o selo "Lido"
/// verde no O Alienista — D-255).
void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    '10.1 título Bricolage24 24/800/1,2 ls −0,6 tinta; "Biblioteca" Figtree 14/700 tinta + seta ic_arrow_right 18 (traço 2 no SVG), gap 4, sem colorFilter',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final title = _styleOf(tester, 'recent.title');
      expect(title, same(AppTextStyles.sectionTitleL));
      _expectTypography(
        title,
        family: 'Bricolage24', // opsz = tamanho (24)
        fallback: ['Bricolage24Ext', 'Bricolage24Vi'],
        size: 24,
        weight: FontWeight.w800,
        height: 1.2,
        letterSpacing: -0.6,
        color: _ink,
      );
      final link = _styleOf(tester, 'recent.libraryLink');
      expect(link, same(AppTextStyles.label14Bold));
      _expectFigtree(link, size: 14, weight: FontWeight.w700, color: _ink);
      final row = tester.widget<Row>(
        find.descendant(
          of: find.byKey(const ValueKey('recent.libraryLink')),
          matching: find.byType(Row),
        ),
      );
      expect(row.spacing, 4);
      expect(row.mainAxisSize, MainAxisSize.min);

      final arrowFinder = find.byKey(const ValueKey('recent.libraryLink.icon'));
      final arrow = tester.widget<AppSvg>(arrowFinder);
      expect((arrow.asset, arrow.size), (AppIcons.arrowRight, 18.0));
      final picture = tester.widget<SvgPicture>(
        find.descendant(of: arrowFinder, matching: find.byType(SvgPicture)),
      );
      expect(picture.colorFilter, isNull); // a cor está no próprio SVG
      final source = (await tester.runAsync(
        () => rootBundle.loadString(AppIcons.arrowRight),
      ))!;
      // Traço 2 no viewBox 24 → 1,5 px lógicos a 18 px (escala com o tamanho, como no navegador).
      expect(
        RegExp(r'stroke-width="([^"]*)"')
            .allMatches(source)
            .map((m) => m.group(1))
            .toList(),
        ['2'],
      );
      expect(source, contains('viewBox="0 0 24 24"'));
      expect(source, contains('stroke="#1A1714"'));
      expect(source, contains('fill="none"'));
    },
  );

  testWidgets(
    '10.2 lista: fundo #FFFAF1, raio 24, SEM borda, sombra, gradiente nem recorte; divisor 1 px #E9E1D2 só em `border-bottom` das linhas 0 e 1',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final d = _decorationOf(tester, 'recent.list');
      expect(d.color!.toARGB32(), _surface);
      expect(d.color, AppColors.surface);
      expect(d.borderRadius, BorderRadius.circular(24));
      expect(AppRadii.list, 24);
      expect(d.border, isNull);
      expect(d.boxShadow, isNull);
      expect(d.gradient, isNull);
      expect(d.image, isNull);
      expect(d.shape, BoxShape.rectangle);
      // Sem recorte entre a lista e as linhas.
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('recent.list')),
          matching: find.byType(ClipRRect),
        ),
        // as 3 mini-capas recortam os próprios filhos (overflow: hidden), nada mais
        findsNWidgets(3),
      );
      for (final id in ['recent.row0', 'recent.row1']) {
        final decoration =
            tester.widget<Container>(find.byKey(ValueKey(id))).decoration!
                as BoxDecoration;
        final border = decoration.border! as Border;
        expect(border.bottom.width, 1, reason: id);
        expect(border.bottom.color.toARGB32(), _divider, reason: id);
        expect(border.bottom.style, BorderStyle.solid, reason: id);
        expect(border.top, BorderSide.none, reason: id);
        expect(border.left, BorderSide.none, reason: id);
        expect(border.right, BorderSide.none, reason: id);
        expect((decoration.color, decoration.borderRadius), (null, null));
        expect((decoration.boxShadow, decoration.gradient), (null, null));
      }
      expect(
        tester
            .widget<Container>(find.byKey(const ValueKey('recent.row2')))
            .decoration,
        isNull,
      );
      expect(AppColors.divider.toARGB32(), _divider);
    },
  );

  testWidgets(
    '10.3 mini-capas: 44 × 66, borda 1,2 tinta, raio 3/7/7/3, sem sombra, recorte na padding box (raio 1,8/5,8/5,8/1,8); fundos tinta / #B6ACE4 / #F2A815',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      const inner = BorderRadius.only(
        topLeft: Radius.circular(3 - 1.2),
        topRight: Radius.circular(7 - 1.2),
        bottomRight: Radius.circular(7 - 1.2),
        bottomLeft: Radius.circular(3 - 1.2),
      );
      for (final (id, color) in [
        ('recent.row0.cover', _ink),
        ('recent.row1.cover', _lavender),
        ('recent.row2.cover', _amber),
      ]) {
        final neo = _neoBox(tester, id);
        expect((neo.width, neo.height), (44.0, 66.0), reason: id);
        expect(neo.color!.toARGB32(), color, reason: id);
        expect(neo.border, const BorderSide(width: 1.2, color: AppColors.ink));
        expect(neo.radius, AppRadii.coverS, reason: id);
        expect(
          neo.radius,
          const BorderRadius.only(
            topLeft: Radius.circular(3),
            topRight: Radius.circular(7),
            bottomRight: Radius.circular(7),
            bottomLeft: Radius.circular(3),
          ),
        );
        expect(neo.shadow, isNull, reason: id);
        expect(neo.clip, isTrue, reason: id);
        final d = _decorationOf(tester, id);
        expect(d.boxShadow, isNull, reason: id);
        expect(d.border, Border.all(width: 1.2, color: AppColors.ink));
        // overflow: hidden recorta na padding box, com o raio da borda − 1,2 — suavizado.
        final clip = _clipOf(tester, id);
        expect(clip.borderRadius, inner, reason: id);
        expect(clip.clipBehavior, Clip.antiAlias, reason: id);
        // Nenhuma rotação / transformação: a capa não gira.
        expect(
          find.descendant(
            of: find.byKey(ValueKey(id)),
            matching: find.byType(Transform),
          ),
          findsNothing,
          reason: id,
        );
      }
    },
  );

  testWidgets(
    '10.3 filhos das capas: Frankenstein (lua #B6ACE4 raio 11, barra #B6ACE4 raio 3, sem lombada); O Alienista (lombada .12, anel borda 1,5 sem fundo, ponto tinta); Senhora (lombada .12 e arco vazado sem a borda de baixo)',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      // Frankenstein.
      final moon = _neoBox(tester, 'recent.row0.cover.moon');
      expect(moon.color!.toARGB32(), _lavender);
      expect(moon.radius, BorderRadius.circular(11));
      expect((moon.border, moon.shadow), (null, null));
      final bar = _neoBox(tester, 'recent.row0.cover.bar');
      expect(bar.color!.toARGB32(), _lavender);
      expect(bar.radius, BorderRadius.circular(3));
      expect((bar.border, bar.shadow), (null, null));
      // Sem lombada.
      expect(
        find.byKey(const ValueKey('recent.row0.cover.spine')),
        findsNothing,
      );
      // O Alienista.
      final spine1 = _neoBox(tester, 'recent.row1.cover.spine');
      expect(spine1.color!.toARGB32(), 0x1F000000);
      expect(spine1.color, AppColors.spine12);
      expect((spine1.border, spine1.radius), (null, BorderRadius.zero));
      final ring = _neoBox(tester, 'recent.row1.cover.ring');
      expect(ring.color, isNull);
      expect(ring.border, const BorderSide(width: 1.5, color: AppColors.ink));
      expect(ring.radius, BorderRadius.circular(10));
      final dot = _neoBox(tester, 'recent.row1.cover.dot');
      expect(dot.color!.toARGB32(), _ink);
      expect(dot.radius, BorderRadius.circular(4));
      expect((dot.border, dot.shadow), (null, null));
      // Senhora.
      final spine2 = _neoBox(tester, 'recent.row2.cover.spine');
      expect(spine2.color!.toARGB32(), 0x1F000000);
      expect((spine2.border, spine2.radius), (null, BorderRadius.zero));
      final arch = tester.widget<CustomPaint>(
        find.byKey(const ValueKey('recent.row2.cover.arch')),
      );
      final painter = arch.painter! as ArchBorderPainter;
      expect(painter.topRadius, 13);
      expect(painter.border, 1.5);
      expect(painter.color.toARGB32(), _ink);
      expect(arch.foregroundPainter, isNull);
      expect(arch.child, isNull);
    },
  );

  testWidgets(
    '10.3 arco da Senhora: faixa em "U" (sem a borda de baixo) — raios 13 → 11,8 (o CSS reduz 26 → 23,6 pelo mesmo fator) por fora e 10,3 por dentro; só o contorno é pintado, sem fundo',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final render = tester.renderObject<RenderCustomPaint>(
        find.byKey(const ValueKey('recent.row2.cover.arch')),
      );
      expect(render.size.width, moreOrLessEquals(23.6, epsilon: 1e-9));
      expect(render.size.height, 26);
      final calls = _paintCalls(render);
      final draws = [
        for (final c in calls)
          if (!_stateMethods.contains(c.invocation.memberName)) c.invocation,
      ];
      expect(draws.map(_drawLabel), ['drawPath 0xFF1A1714']);
      final path = draws.single.positionalArguments.first as Path;
      final bounds = path.getBounds();
      // `Path` guarda os pontos em float32 (os arcos acumulam ~1e-6).
      expect(bounds.left, moreOrLessEquals(0, epsilon: 1e-5));
      expect(bounds.top, moreOrLessEquals(0, epsilon: 1e-5));
      expect(bounds.right, moreOrLessEquals(23.6, epsilon: 1e-5));
      expect(bounds.bottom, moreOrLessEquals(26, epsilon: 1e-5));
      // Contém: as pernas (1,5) e o topo (1,5); não contém o miolo nem a base.
      bool has(double x, double y) => path.contains(Offset(x, y));
      expect(has(0.75, 20), isTrue, reason: 'perna esquerda');
      expect(has(22.85, 20), isTrue, reason: 'perna direita');
      expect(has(11.8, 0.75), isTrue, reason: 'topo');
      expect(has(11.8, 13), isFalse, reason: 'miolo');
      expect(has(11.8, 25.5), isFalse, reason: 'sem borda embaixo');
      expect(has(2.5, 20), isFalse, reason: 'dentro da perna');
      expect(has(0.75, 25.9), isTrue, reason: 'a perna vai até a base');
      // Fora do contorno externo arredondado (canto de cima, raio 11,8): sem tinta.
      expect(has(0.3, 0.3), isFalse, reason: 'fora do arco');
      // Meio do anel a 45° no canto: distância 11,8 − 0,75 = 11,05 do centro (11,8; 11,8).
      expect(has(11.8 - 11.05 * 0.70710678, 11.8 - 11.05 * 0.70710678), isTrue);
    },
  );

  testWidgets(
    '10.5 selos: sem borda, raio 999 (normalizado), fundos #ECE7FA / #E1EDD0 / #EFE7D7; texto Figtree 12/700 #3B2D86 / #2E5314 / #4A4238; padding 5 10',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      for (final (i, bg, fg, style) in [
        (0, _tagLavenderBg, _tagLavenderFg, AppTextStyles.tagLavender),
        (1, _tagReadBg, _tagReadFg, AppTextStyles.tagRead), // "Lido" (D-255)
        (2, _tagSandBg, _tagSandFg, AppTextStyles.tagSand),
      ]) {
        final id = 'recent.row$i.tag';
        final pill = tester.widget<Pill>(find.byKey(ValueKey(id)));
        expect(pill.color.toARGB32(), bg, reason: id);
        expect(pill.border, isNull, reason: id);
        expect(
          pill.padding,
          const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          reason: id,
        );
        final d = _decorationOf(tester, id);
        expect(d.color!.toARGB32(), bg, reason: id);
        expect(d.border, isNull, reason: id);
        expect(d.borderRadius, BorderRadius.circular(999), reason: id);
        expect((d.boxShadow, d.gradient), (null, null), reason: id);
        final s = _styleOf(tester, id);
        expect(s, same(style), reason: id);
        _expectFigtree(
          s,
          size: 12,
          weight: FontWeight.w700,
          color: fg,
          reason: id,
        );
        // O raio 999 normaliza para metade do menor lado (como no CSS): 12,2 (1 linha) ou 19,4 (2 linhas).
        final rect = tester.getRect(find.byKey(ValueKey(id)));
        final r = BorderRadius.circular(999)
            .toRRect(rect)
            .scaleRadii()
            .tlRadiusX;
        expect(r, moreOrLessEquals(rect.height / 2, epsilon: 1e-9), reason: id);
      }
      expect(AppColors.tagLavenderBg.toARGB32(), _tagLavenderBg);
      expect(AppColors.tagLavenderFg.toARGB32(), _tagLavenderFg);
      expect(AppColors.tagSandBg.toARGB32(), _tagSandBg);
      expect(AppColors.inkWarm.toARGB32(), _tagSandFg);
      expect(AppColors.tagReadBg.toARGB32(), _tagReadBg);
      expect(AppColors.tagReadFg.toARGB32(), _tagReadFg);
    },
  );

  testWidgets(
    'textos: título 15/700 tinta; subtítulo 13/500 #5B544B; line-height normal (1,2) → 18 e 15,6 por linha; gap 3 entre os dois',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      for (var i = 0; i < 3; i++) {
        final title = _styleOf(tester, 'recent.row$i.title');
        expect(title, same(AppTextStyles.title15), reason: '$i');
        _expectFigtree(title, size: 15, weight: FontWeight.w700, color: _ink);
        final sub = _styleOf(tester, 'recent.row$i.subtitle');
        expect(sub, same(AppTextStyles.body13Muted), reason: '$i');
        _expectFigtree(sub, size: 13, weight: FontWeight.w500, color: _muted);
        final block = tester.widget<Column>(
          find.byKey(ValueKey('recent.row$i.textBlock')),
        );
        expect(block.spacing, 3);
        expect(block.crossAxisAlignment, CrossAxisAlignment.stretch);
        expect(block.mainAxisSize, MainAxisSize.min);
      }
    },
  );

  testWidgets(
    '10.6 botão "mais opções": CircleIconButton 44 sem fundo e sem borda (transparente); ícone ic_more_horizontal 20 com 3 círculos r 1,8 preenchidos #1A1714, sem colorFilter',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final source = (await tester.runAsync(
        () => rootBundle.loadString(AppIcons.moreHorizontal),
      ))!;
      expect(AppIcons.moreHorizontal, 'assets/icons/ic_more_horizontal.svg');
      expect(source, contains('viewBox="0 0 24 24"'));
      expect(source, contains('fill="#1A1714"'));
      expect(
        RegExp(r'<circle cx="(\d+)" cy="(\d+)" r="([\d.]+)"')
            .allMatches(source)
            .map((m) => (m.group(1), m.group(2), m.group(3)))
            .toList(),
        [('5', '12', '1.8'), ('12', '12', '1.8'), ('19', '12', '1.8')],
      );
      for (var i = 0; i < 3; i++) {
        final id = 'recent.row$i.more';
        final button = tester.widget<CircleIconButton>(
          find.byKey(ValueKey(id)),
        );
        expect((button.size, button.color, button.border), (44.0, null, null));
        final neo = tester.widget<NeoBox>(
          find.descendant(
            of: find.byKey(ValueKey(id)),
            matching: find.byType(NeoBox),
          ),
        );
        expect((neo.color, neo.border, neo.shadow), (null, null, null));
        expect(neo.radius, BorderRadius.circular(22));
        final d = _decorationOf(tester, id);
        expect(
          (d.color, d.border, d.boxShadow, d.gradient),
          (null, null, null, null),
        );
        final picture = tester.widget<SvgPicture>(
          find.descendant(
            of: find.byKey(ValueKey('$id.icon')),
            matching: find.byType(SvgPicture),
          ),
        );
        expect(picture.colorFilter, isNull);
        expect(picture.width, 20);
        expect(picture.height, 20);
      }
    },
  );

  testWidgets(
    'canvas (TestRecordingPaintingContext): só 3 recortes (os das mini-capas, suavizados e na padding box com raio 1,8/5,8); sem saveLayer; ordem de pintura do arquivo (lista → linha: divisor, capa, selo)',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final calls = _paintCalls(
        tester.renderObject(find.byType(RecentlyAddedSection)),
      );
      final origin = tester.getTopLeft(find.byType(RecentlyAddedSection));
      Rect rel(String id) =>
          tester.getRect(find.byKey(ValueKey<String>(id))).shift(-origin);

      final clips = [
        for (final c in calls)
          if (_clipMethods.contains(c.invocation.memberName)) c.invocation,
      ];
      debugPrint(
        '[canvas] recortes (coordenadas da seção): ${clips.map((c) => '${_methodName(c.memberName)} ${c.positionalArguments.single} aa=${c.namedArguments[#doAntiAlias]}').join(' · ')}',
      );
      expect(clips.map((c) => c.memberName), [
        #clipRRect,
        #clipRRect,
        #clipRRect,
      ]);
      expect(
        clips.every((c) => c.namedArguments[#doAntiAlias] == true),
        isTrue,
      );
      for (final (i, clip) in clips.indexed) {
        final cover = rel('recent.row$i.cover');
        _expectShape(
          clip.positionalArguments.single as Object,
          RRect.fromRectAndCorners(
            cover.deflate(1.2),
            topLeft: const Radius.circular(1.8),
            topRight: const Radius.circular(5.8),
            bottomRight: const Radius.circular(5.8),
            bottomLeft: const Radius.circular(1.8),
          ),
          reason: 'recorte da capa $i',
        );
      }
      final names = calls.map((c) => c.invocation.memberName).toSet();
      for (final forbidden in [#saveLayer, #rotate, #skew, #scale, #clipPath]) {
        expect(names.contains(forbidden), isFalse, reason: '$forbidden');
      }

      final draws = [
        for (final c in calls)
          if (!_stateMethods.contains(c.invocation.memberName) &&
              c.invocation.memberName != #drawParagraph &&
              c.invocation.memberName != #drawPicture)
            _drawLabel(c.invocation),
      ];
      debugPrint('[canvas] desenhos (sem texto/SVG): ${draws.join(' | ')}');
      const ink = 'drawDRRect 0xFF1A1714';
      final expected = [
        'drawRRect 0xFFFFFAF1', // lista
        // linha 0: divisor, capa (fundo, borda), lua, barra, selo
        'drawPath 0xFFE9E1D2',
        'drawRRect 0xFF1A1714',
        ink,
        'drawRRect 0xFFB6ACE4',
        'drawRRect 0xFFB6ACE4',
        'drawRRect 0xFFECE7FA',
        // linha 1: divisor, capa (fundo, borda), lombada, anel (só borda), ponto, selo "Lido"
        'drawPath 0xFFE9E1D2',
        'drawRRect 0xFFB6ACE4',
        ink,
        'drawRect 0x1F000000',
        ink,
        'drawRRect 0xFF1A1714',
        'drawRRect 0xFFE1EDD0',
        // linha 2 (sem divisor): capa (fundo, borda), lombada, arco, selo
        'drawRRect 0xFFF2A815',
        ink,
        'drawRect 0x1F000000',
        'drawPath 0xFF1A1714',
        'drawRRect 0xFFEFE7D7',
      ];
      expect(draws, expected);
      // 11 textos pintados, um parágrafo cada, e 4 SVG (a v1 pintava 13 parágrafos: o subtítulo e o selo da linha 2
      // eram 2 parágrafos cada; com os dados da prancha 01 nenhum texto da seção pede mais de um).
      expect(
        calls.where((c) => c.invocation.memberName == #drawParagraph),
        hasLength(11),
      );
      expect(
        calls.where((c) => c.invocation.memberName == #drawPicture),
        hasLength(4),
      );
    },
  );

  testWidgets(
    'pixels @3x (cor EXATA): lista e cantos; divisores (só nas linhas 0 e 1, 1 px, de x = 14 a 342); capas (borda, lua, barra, lombadas, anel, ponto, arco aberto embaixo); selos sem borda; pontos do botão; sem sombra',
    (tester) async {
      setCanvasView(tester);
      await _pumpCanvas(tester);
      final (rgba, width) = await _capture(tester);
      final o = tester.getTopLeft(find.byKey(const ValueKey('recent')));
      Offset at(double x, double y) => o + Offset(x, y);
      final spineOnLavender = _over(AppColors.spine12, AppColors.lavender);
      final spineOnAmber = _over(AppColors.spine12, AppColors.amber);
      final checks = <String, (Offset, int)>{
        // Lista.
        'lista: fundo': (at(200, 80), _surface),
        'lista: canto de cima fora do raio 24 (papel)': (at(1, 55), _paper),
        'lista: sem borda (topo)': (at(175, 54.7), _surface),
        'lista: sem sombra (embaixo)': (at(175, 335), _paper),
        'lista: sem sombra (à direita)': (at(351, 190), _paper),
        // Divisores.
        'divisor da linha 0': (at(200, 148.5), _divider),
        'divisor da linha 0: começo (x = 14)': (at(14.5, 148.5), _divider),
        'divisor da linha 0: antes do começo': (at(13.5, 148.5), _surface),
        'divisor da linha 0: fim (x = 342)': (at(341.5, 148.5), _divider),
        'divisor da linha 0: depois do fim': (at(342.5, 148.5), _surface),
        'divisor da linha 1': (at(200, 239.5), _divider),
        'linha 2 sem divisor': (at(200, 329.5), _surface),
        // Capa Frankenstein (14; 70).
        'Frankenstein: borda de cima': (at(36, 70.6), _ink),
        'Frankenstein: fundo tinta': (at(36, 110), _ink),
        'Frankenstein: lua': (at(36.2, 92.2), _lavender),
        'Frankenstein: barra': (at(37, 126.3), _lavender),
        'Frankenstein: fora do canto (papel da lista)': (
          at(14.2, 70.2),
          _surface,
        ),
        // Capa O Alienista (14; 161).
        'Alienista: fundo': (at(50, 215), _lavender),
        'Alienista: lombada .12 sobre o fundo': (
          at(17.2, 200),
          spineOnLavender,
        ),
        'Alienista: anel (borda esquerda)': (at(27.95, 184.2), _ink),
        'Alienista: entre o anel e o ponto (sem fundo no anel)': (
          at(30.2, 184.2),
          _lavender,
        ),
        'Alienista: ponto': (at(37.2, 184.2), _ink),
        // Capa Senhora (14; 252).
        'Senhora: fundo âmbar': (at(50, 305), _amber),
        'Senhora: lombada .12 sobre o âmbar': (at(17.2, 285), spineOnAmber),
        'Senhora: arco, perna esquerda': (at(25.95, 285), _ink),
        'Senhora: arco, perna direita': (at(48.05, 285), _ink),
        'Senhora: arco, topo': (at(37, 265.95), _ink),
        'Senhora: dentro do arco (âmbar)': (at(37, 280), _amber),
        'Senhora: sem borda embaixo (âmbar entre as pernas)': (
          at(37, 290.9),
          _amber,
        ),
        'Senhora: abaixo do arco': (at(37, 293), _amber),
        // Selos (sem borda).
        'selo "Quero ler" (linha 0)': (at(240, 93), _tagLavenderBg),
        'selo "Quero ler" (linha 0): topo sem borda': (
          at(240, 91.5),
          _tagLavenderBg,
        ),
        'selo "Lido" (linha 1, no padding esquerdo)': (
          at(245, 194),
          _tagReadBg,
        ),
        'selo "Novo" (linha 2)': (at(244, 275), _tagSandBg),
        'selo: fora do pílula (canto)': (at(212.8, 91), _surface),
        // Botão "mais opções": transparente (a lista aparece) e os três pontos.
        'botão: sem fundo (dentro do círculo, longe do ícone)': (
          at(302, 103),
          _surface,
        ),
        'botão: ponto do meio': (at(320, 103), _ink),
        'botão: ponto da esquerda': (at(314.17, 103), _ink),
        'botão: ponto da direita': (at(325.83, 103), _ink),
        'botão: entre os pontos': (at(317, 103), _surface),
      };
      final failures = <String>[];
      checks.forEach((what, check) {
        final (p, expected) = check;
        final got = _argbAt(rgba, width, p);
        debugPrint(
          '[pixels] $what em (${p.dx.toStringAsFixed(2)}; ${p.dy.toStringAsFixed(2)}): ${_hex(got)} '
          '(esperado ${_hex(expected)}, exato)',
        );
        if (got != expected) {
          failures.add('$what: ${_hex(got)} ≠ ${_hex(expected)}');
        }
      });
      expect(failures, isEmpty, reason: failures.join('\n'));
    },
  );
}

import 'package:app_leitura/app/app.dart';
import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/tokens/app_icons.dart';
import 'package:app_leitura/core/design_system/tokens/app_radii.dart';
import 'package:app_leitura/core/design_system/tokens/app_typography.dart';
import 'package:app_leitura/core/design_system/widgets/app_svg.dart';
import 'package:app_leitura/core/design_system/widgets/neo_box.dart';
import 'package:app_leitura/core/design_system/widgets/pill.dart';
import 'package:app_leitura/features/home/presentation/sections/for_you_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

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

Stack _stackOf(WidgetTester tester, String id) => tester.widget<Stack>(
  find
      .descendant(
        of: find.byKey(ValueKey<String>(id)),
        matching: find.byType(Stack),
      )
      .first,
);

AppText _textOf(WidgetTester tester, String id) => tester.widget<AppText>(
  find.descendant(
    of: find.byKey(ValueKey<String>(id)),
    matching: find.byType(AppText),
    matchRoot: true,
  ),
);

TextStyle _styleOf(WidgetTester tester, String id) =>
    (_textOf(tester, id).span as TextSpan).style!;

void _expectInkBorder(BoxDecoration d, double width) {
  expect(d.border, Border.all(width: width, color: AppColors.ink));
  expect((d.border! as Border).top.color.toARGB32(), 0xFF1A1714);
}

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
  FontStyle? fontStyle,
  String? reason,
}) {
  expect(
    (s.fontFamily, s.fontSize, s.fontWeight, s.height, s.letterSpacing),
    (family, size, weight, height, letterSpacing),
    reason: reason,
  );
  expect(s.fontFamilyFallback, fallback, reason: reason);
  expect(s.fontStyle, fontStyle, reason: reason);
  expect(s.color!.toARGB32(), color, reason: reason);
  expect(s.leadingDistribution, TextLeadingDistribution.even, reason: reason);
}

/// Os filhos de uma [Stack] como (left, top, right, bottom, width, height) do `Positioned`.
List<(double?, double?, double?, double?, double?, double?)> _positions(
  Stack stack,
) => [
  for (final w in stack.children.cast<Positioned>())
    (w.left, w.top, w.right, w.bottom, w.width, w.height),
];

/// Comportamento de recorte de um widget de recorte (null se não for um).
Clip? _clipBehaviorOf(Widget w) => switch (w) {
  ClipRect(:final clipBehavior) => clipBehavior,
  ClipRRect(:final clipBehavior) => clipBehavior,
  ClipPath(:final clipBehavior) => clipBehavior,
  ClipOval(:final clipBehavior) => clipBehavior,
  _ => null,
};

/// Filhos de uma [RenderStack] que saem dos limites dela — mesma conta do `RenderStack.performLayout`:
/// com algum, o `clipBehavior` (padrão `Clip.hardEdge`) empurra um recorte retangular na pintura.
List<Rect> _overflowingChildren(RenderStack stack) {
  final out = <Rect>[];
  var child = stack.firstChild;
  while (child != null) {
    final data = child.parentData! as StackParentData;
    final r = data.offset & child.size;
    if (r.left < 0 ||
        r.top < 0 ||
        r.right > stack.size.width ||
        r.bottom > stack.size.height) {
      out.add(r);
    }
    child = data.nextSibling;
  }
  return out;
}

/// Monta o app sob um RepaintBoundary (mesma captura do golden).
Future<void> _pumpCanvas(WidgetTester tester) async {
  await precacheAppIcons(tester);
  await tester.pumpWidget(
    const ProviderScope(
      child: RepaintBoundary(key: goldenRootKey, child: App.forTests()),
    ),
  );
  await tester.pumpAndSettle();
}

Future<(Uint8List, int)> _capture(WidgetTester tester) async {
  final image = await captureAt(tester, find.byKey(goldenRootKey));
  expect(
    (image.width, image.height),
    (390 * 3, 2390 * 3),
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

/// Cor ARGB do pixel FÍSICO (px, py) da captura @3x.
int _argbAtPixel(Uint8List rgba, int width, int px, int py) {
  final i = (py * width + px) * 4;
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

/// Confere pixels @3x com o ARGB EXATO (sem tolerância).
void _expectPixels(
  Uint8List rgba,
  int width,
  Map<String, (Offset, int)> checks,
) {
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
}

/// Canto superior esquerdo LÓGICO de [id] no canvas.
Offset _topLeft(WidgetTester tester, String id) =>
    tester.getTopLeft(find.byKey(ValueKey<String>(id)));

/// Chamadas ao canvas de [r] pintando a sua subárvore INTEIRA, em coordenadas do próprio [r]. O
/// [TestRecordingPaintingContext] também atravessa as fronteiras de repintura; como no `PaintingContext` real,
/// `Clip.none` não gera chamada de recorte e um `Transform` identidade/translação não gera `transform`.
List<RecordedInvocation> _paintCalls(RenderObject r) {
  final canvas = TestRecordingCanvas();
  final context = TestRecordingPaintingContext(canvas);
  r.paint(context, Offset.zero);
  context.dispose();
  return canvas.invocations;
}

const _clipMethods = {#clipRect, #clipRRect, #clipPath, #clipRSuperellipse};

/// Chamadas que só mudam o estado do canvas (o resto desenha).
const _stateMethods = {#save, #restore, #restoreToCount, ..._clipMethods};

List<Invocation> _clipsIn(List<RecordedInvocation> calls) => [
  for (final c in calls)
    if (_clipMethods.contains(c.invocation.memberName)) c.invocation,
];

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

Object _shift(Object shape, Offset o) =>
    shape is RRect ? shape.shift(o) : (shape as Rect).shift(o);

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

/// Recorte de `overflow: hidden` de uma capa: a padding box (1,5 para dentro) com raio − borda.
RRect _innerRRect(Rect cover) => RRect.fromRectAndCorners(
  cover.deflate(1.5),
  topLeft: const Radius.circular(2.5),
  topRight: const Radius.circular(8.5),
  bottomRight: const Radius.circular(8.5),
  bottomLeft: const Radius.circular(2.5),
);

/// Nome de um método registrado (`#drawRRect` → `drawRRect`).
String _methodName(Symbol s) {
  final text = '$s'; // Symbol("drawRRect")
  return text.substring(8, text.length - 2);
}

/// Cor ARGB do `Paint` (último argumento) de uma chamada de desenho registrada.
int _paintColor(Invocation draw) =>
    (draw.positionalArguments.last as Paint).color.toARGB32();

const _covers = [
  'forYou.item1.cover',
  'forYou.item2.cover',
  'forYou.item3.cover',
];

const _ink = 0xFF1A1714;
const _paper = 0xFFF7F0E3;
const _surface = 0xFFFFFAF1;
const _flame = 0xFFFF552E;
const _azure = 0xFF058CD7;
const _emerald = 0xFF00995E;
const _sun = 0xFFFED170;

/// F08 — camada 2 (estilo, sem tolerância) da seção `forYou`.
void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    '8.1 título Bricolage24 24/800/1,2 ls −0,6 tinta; "Ver tudo" Figtree 14/700 tinta + seta ic_arrow_right 18 (traço 2 no SVG), gap 4, sem colorFilter',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final title = _styleOf(tester, 'forYou.title');
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
      final header = tester.widget<Row>(
        find
            .descendant(
              of: find.byKey(const ValueKey('forYou.header')),
              matching: find.byType(Row),
            )
            .first,
      );
      expect(header.mainAxisAlignment, MainAxisAlignment.spaceBetween);
      expect(header.crossAxisAlignment, CrossAxisAlignment.center);

      final seeAll = _styleOf(tester, 'forYou.seeAll');
      expect(seeAll, same(AppTextStyles.label14Bold));
      _expectTypography(
        seeAll,
        family: 'Figtree',
        fallback: ['FigtreeExt'],
        size: 14,
        weight: FontWeight.w700,
        height: 1.2, // line-height normal
        letterSpacing: 0,
        color: _ink,
      );
      final link = tester.widget<Row>(
        find.descendant(
          of: find.byKey(const ValueKey('forYou.seeAll')),
          matching: find.byType(Row),
        ),
      );
      expect(link.spacing, 4);
      expect(link.mainAxisSize, MainAxisSize.min);

      final arrowFinder = find.byKey(const ValueKey('forYou.seeAll.icon'));
      final arrow = tester.widget<AppSvg>(arrowFinder);
      expect((arrow.asset, arrow.size), (AppIcons.arrowRight, 18.0));
      expect(arrow.asset, 'assets/icons/ic_arrow_right.svg');
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
      debugPrint('[ícone] ${AppIcons.arrowRight}: $source');
    },
  );

  testWidgets(
    '8.2 chip: #FFFAF1, borda 1,5 tinta, raio 999 (→ 16,3), sem sombra; padding 7/12/7/10, gap 6; brilho ic_sparkle_solid 14; motivo Figtree 13/600 tinta',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      const id = 'forYou.reasonChip';
      final d = _decorationOf(tester, id);
      expect(d.color!.toARGB32(), _surface);
      expect(d.color, AppColors.surface);
      _expectInkBorder(d, 1.5);
      expect(d.borderRadius, BorderRadius.circular(999));
      expect(AppRadii.pill, 999);
      expect((d.boxShadow, d.gradient), (null, null));
      final rect = tester.getRect(find.byKey(const ValueKey(id)));
      final radius = BorderRadius.circular(999)
          .toRRect(rect)
          .scaleRadii()
          .tlRadiusX;
      debugPrint(
        '[chip] ${rect.width.toStringAsFixed(4)} × ${rect.height.toStringAsFixed(4)}, raio normalizado ${radius.toStringAsFixed(6)}',
      );
      // 32,6 / 2; a altura vem do texto (float32 do SkParagraph) → ±1e-3.
      expect(radius, moreOrLessEquals(16.3, epsilon: 1e-3));

      final pill = tester.widget<Pill>(find.byKey(const ValueKey(id)));
      expect(pill.padding, const EdgeInsets.fromLTRB(10, 7, 12, 7));
      expect(pill.border, const BorderSide(width: 1.5, color: AppColors.ink));
      expect(pill.color, AppColors.surface);
      final row = tester.widget<Row>(
        find.descendant(
          of: find.byKey(const ValueKey(id)),
          matching: find.byType(Row),
        ),
      );
      expect(row.spacing, 6);
      expect(row.mainAxisSize, MainAxisSize.min);
      expect(row.crossAxisAlignment, CrossAxisAlignment.center);
      // align-self: flex-start → alinhado à esquerda, abraçando o conteúdo.
      final align = tester.widget<Align>(
        find
            .ancestor(
              of: find.byKey(const ValueKey(id)),
              matching: find.byType(Align),
            )
            .first,
      );
      expect(align.alignment, Alignment.centerLeft);

      final iconFinder = find.byKey(const ValueKey('forYou.reasonChip.icon'));
      final icon = tester.widget<AppSvg>(iconFinder);
      expect((icon.asset, icon.size), (AppIcons.sparkleSolid, 14.0));
      expect(icon.asset, 'assets/icons/ic_sparkle_solid.svg');
      expect(
        tester
            .widget<SvgPicture>(
              find.descendant(
                of: iconFinder,
                matching: find.byType(SvgPicture),
              ),
            )
            .colorFilter,
        isNull,
      );
      final source = (await tester.runAsync(
        () => rootBundle.loadString(AppIcons.sparkleSolid),
      ))!;
      expect(source, contains('fill="#1A1714"')); // sólido, sem traço
      expect(source, isNot(contains('stroke')));

      final s = _styleOf(tester, id);
      expect(s, same(AppTextStyles.body13Semi));
      _expectTypography(
        s,
        family: 'Figtree',
        fallback: ['FigtreeExt'],
        size: 13,
        weight: FontWeight.w600,
        height: 1.2,
        letterSpacing: 0,
        color: _ink,
      );
    },
  );

  testWidgets(
    '8.3 recortes: só os 3 ClipRRect das capas (antiAlias) + o carrossel (Clip.hardEdge, 0→390, excesso 26); nada mais recorta em repouso',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final section = find.byType(ForYouSection);
      final clipWidgets = tester
          .widgetList(
            find.descendant(
              of: section,
              matching: find.byWidgetPredicate(
                (w) => _clipBehaviorOf(w) != null,
              ),
            ),
          )
          .toList();
      final effective = clipWidgets
          .where((w) => _clipBehaviorOf(w) != Clip.none)
          .toList();
      debugPrint(
        '[recortes] widgets de recorte na seção: '
        '${clipWidgets.map((w) => '${w.runtimeType}(${_clipBehaviorOf(w)!.name})').join(', ')}',
      );
      expect(effective, hasLength(3));
      for (final id in _covers) {
        final clip = _clipOf(tester, id);
        expect(effective, contains(same(clip)), reason: id);
        expect(clip.clipBehavior, Clip.antiAlias, reason: id);
        expect(
          find.descendant(
            of: find.byKey(ValueKey(id)),
            matching: find.byWidgetPredicate((w) => _clipBehaviorOf(w) != null),
          ),
          findsOneWidget,
          reason: '$id: um único recorte por capa',
        );
      }
      // O único outro widget de recorte é o do efeito de overscroll do próprio carrossel (D-03): Clip.none
      // em repouso (só recorta durante o stretch).
      final carouselFinder = find.byKey(const ValueKey('forYou.carousel'));
      final stretch = find.descendant(
        of: carouselFinder,
        matching: find.byType(StretchingOverscrollIndicator),
      );
      expect(
        tester.widget<StretchingOverscrollIndicator>(stretch).axisDirection,
        AxisDirection.right,
      );
      for (final w in clipWidgets.where(
        (w) => _clipBehaviorOf(w) == Clip.none,
      )) {
        expect(w, isA<ClipRect>());
        expect(
          find.descendant(of: stretch, matching: find.byWidget(w)),
          findsOneWidget,
        );
      }

      // Carrossel: overflow hidden → Clip.hardEdge na janela 0→390; o conteúdo (20 + 3 × 116 + 2 × 14 + 20 =
      // 416) passa 26 dela, então o recorte é efetivo (o 3º item é cortado em 390).
      final carousel = tester.widget<SingleChildScrollView>(carouselFinder);
      expect(carousel.clipBehavior, Clip.hardEdge);
      expect(carousel.scrollDirection, Axis.horizontal);
      expect(carousel.padding, const EdgeInsets.symmetric(horizontal: 20));
      final viewport = tester.getRect(carouselFinder);
      expect((viewport.left, viewport.right), (0.0, 390.0));
      final position = tester
          .state<ScrollableState>(
            find.descendant(
              of: carouselFinder,
              matching: find.byType(Scrollable),
            ),
          )
          .position;
      expect((position.pixels, position.maxScrollExtent), (0.0, 26.0));

      // Nenhuma Row/Column da seção recorta.
      final sectionRender = tester.renderObject(section);
      final stacks = <RenderStack>[];
      void walk(RenderObject r) {
        if (r is RenderFlex) expect(r.clipBehavior, Clip.none);
        if (r is RenderStack) stacks.add(r);
        r.visitChildren(walk);
      }

      walk(sectionRender);
      expect(stacks, hasLength(3)); // uma Stack por capa
      // As 3 Stacks das capas têm `Clip.none`: o único recorte de cada capa é o ClipRRect suavizado do NeoBox.
      // Na Memórias isso importa, porque a elipse transborda a padding box — com o `Clip.hardEdge` padrão a
      // Stack recortaria de novo num retângulo SEM suavização (e apagaria a lombada na coluna física 64).
      for (final id in _covers) {
        final stack = tester.renderObject<RenderStack>(
          find
              .descendant(
                of: find.byKey(ValueKey(id)),
                matching: find.byType(Stack),
              )
              .first,
        );
        expect(stack.clipBehavior, Clip.none, reason: id);
        expect(stack.size, const Size(113, 171), reason: id);
        if (id == 'forYou.item1.cover') {
          // Elipse: (20; 113) → (143; 229) na padding box 113×171.
          expect(_overflowingChildren(stack), [
            const Rect.fromLTRB(20, 113, 143, 229),
          ]);
        } else {
          expect(_overflowingChildren(stack), isEmpty, reason: id);
        }
      }
    },
  );

  testWidgets(
    '8.3 sem rotação: nenhum Transform/RotatedBox nas capas; até a seção só os Transform identidade do Pressable (D-04) e do StretchEffect (D-03); capa → seção = translação pura',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final section = find.byType(ForYouSection);
      expect(
        find.descendant(of: section, matching: find.byType(RotatedBox)),
        findsNothing,
      );
      final sectionBox = tester.renderObject<RenderBox>(section);
      for (final (id, x) in [
        ('forYou.item1.cover', 20.0),
        ('forYou.item2.cover', 150.0),
        ('forYou.item3.cover', 280.0),
      ]) {
        final cover = find.byKey(ValueKey(id));
        expect(
          find.descendant(
            of: cover,
            matching: find.byWidgetPredicate(
              (w) => w is Transform || w is RotatedBox || w is FittedBox,
            ),
          ),
          findsNothing,
          reason: id,
        );
        final ancestors = <Widget>[];
        tester.element(cover).visitAncestorElements((e) {
          ancestors.add(e.widget);
          return e.widget is! ForYouSection;
        });
        expect(ancestors.last, isA<ForYouSection>(), reason: id);
        expect(
          ancestors.where((w) => w is RotatedBox || w is FittedBox),
          isEmpty,
          reason: id,
        );
        final owners = <Type>[];
        for (var i = 0; i < ancestors.length; i++) {
          final w = ancestors[i];
          if (w is! Transform) continue;
          expect(w.transform, Matrix4.identity(), reason: '$id: repouso');
          owners.add(ancestors[i + 1].runtimeType);
        }
        expect(owners, [ScaleTransition, StretchEffect], reason: id);
        final m = tester
            .renderObject<RenderBox>(cover)
            .getTransformTo(sectionBox);
        final t = m.getTranslation();
        expect(m, Matrix4.translationValues(t.x, t.y, 0), reason: id);
        expect(t.x, x, reason: id);
        expect(t.y, moreOrLessEquals(108.6, epsilon: 1e-3), reason: id);
        debugPrint(
          '[transform] $id → seção: translação (${t.x}; ${t.y}); Transform ancestrais de $owners, todos identidade',
        );
      }
    },
  );

  testWidgets(
    '8.4–8.6 capas: #FF552E / #058CD7 / #00995E, borda 1,5 tinta, raio 4/10/10/4, sem sombra; recorte antiAlias 2,5/8,5/8,5/2,5 exatamente 1,5 dentro da borda; lombadas 7 px .15 / .18 / .18',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      expect(AppColors.spine15.toARGB32(), 0x26000000);
      expect((0.15 * 255).round(), 0x26); // 38
      expect(AppColors.spine18.toARGB32(), 0x2E000000);
      expect((0.18 * 255).round(), 0x2E); // 46
      for (final (id, color, token, spine, spineToken) in [
        (
          'forYou.item1.cover',
          _flame,
          AppColors.flame,
          0x26000000,
          AppColors.spine15,
        ),
        (
          'forYou.item2.cover',
          _azure,
          AppColors.azure,
          0x2E000000,
          AppColors.spine18,
        ),
        (
          'forYou.item3.cover',
          _emerald,
          AppColors.emerald,
          0x2E000000,
          AppColors.spine18,
        ),
      ]) {
        final box = _neoBox(tester, id);
        expect(
          (box.width, box.height, box.clip, box.shadow, box.padding),
          (116.0, 174.0, true, null, EdgeInsets.zero),
          reason: id,
        );
        expect(
          box.border,
          const BorderSide(width: 1.5, color: AppColors.ink),
          reason: id,
        );
        final d = _decorationOf(tester, id);
        expect(d.color!.toARGB32(), color, reason: id);
        expect(d.color, token, reason: id);
        _expectInkBorder(d, 1.5);
        expect(
          d.borderRadius,
          const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(10),
            bottomRight: Radius.circular(10),
            bottomLeft: Radius.circular(4),
          ),
          reason: id,
        );
        expect(d.borderRadius, AppRadii.coverL, reason: id);
        expect((d.boxShadow, d.gradient, d.image), (null, null, null));
        final rect = tester.getRect(find.byKey(ValueKey(id)));
        expect(rect.size, const Size(116, 174), reason: id);
        // Raios que cabem (4 + 10 ≤ 116 e ≤ 174): nenhuma redução.
        final outer = (d.borderRadius! as BorderRadius)
            .toRRect(rect)
            .scaleRadii();
        expect(
          (outer.tlRadiusX, outer.trRadiusX, outer.brRadiusX, outer.blRadiusX),
          (4.0, 10.0, 10.0, 4.0),
          reason: id,
        );

        // overflow: hidden → recorte dos filhos na padding box, raio interno = raio − borda, com suavização.
        final clip = _clipOf(tester, id);
        expect(
          clip.borderRadius,
          const BorderRadius.only(
            topLeft: Radius.circular(2.5),
            topRight: Radius.circular(8.5),
            bottomRight: Radius.circular(8.5),
            bottomLeft: Radius.circular(2.5),
          ),
          reason: id,
        );
        expect(clip.clipBehavior, Clip.antiAlias, reason: id);
        final clipRect = tester.getRect(
          find
              .descendant(
                of: find.byKey(ValueKey(id)),
                matching: find.byType(ClipRRect),
              )
              .first,
        );
        for (final (side, got) in [
          ('left', clipRect.left - rect.left),
          ('top', clipRect.top - rect.top),
          ('right', rect.right - clipRect.right),
          ('bottom', rect.bottom - clipRect.bottom),
        ]) {
          expect(
            got,
            moreOrLessEquals(1.5, epsilon: 1e-9),
            reason: '$id $side',
          );
        }

        final spineId = '$id.spine';
        final s = _decorationOf(tester, spineId);
        expect(s.color!.toARGB32(), spine, reason: spineId);
        expect(s.color, spineToken, reason: spineId);
        expect((s.border, s.boxShadow, s.gradient), (null, null, null));
        expect(s.borderRadius, BorderRadius.zero, reason: spineId);
        expect(
          tester.getSize(find.byKey(ValueKey(spineId))),
          const Size(7, 171),
          reason: spineId,
        );
      }
    },
  );

  testWidgets(
    '8.4 Memórias: lombada → elipse → título → autor; elipse ShapeDecoration(OvalBorder) tinta 123×116 (não BoxShape.circle); título InstrumentSerif 19/0,95 tinta; autor Figtree 6,5/700 ls 0,91 #FF552E',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      const id = 'forYou.item1.cover';
      final stack = _stackOf(tester, id);
      // Ordem de pintura do arquivo.
      expect(stack.children.map((w) => (w as Positioned).child.key), const [
        ValueKey('$id.spine'),
        ValueKey('$id.blob'),
        ValueKey('$id.title'),
        ValueKey('$id.author'),
      ]);
      expect(_positions(stack), [
        (0.0, 0.0, null, 0.0, 7.0, null), // lombada: altura toda
        (20.0, null, -30.0, -58.0, null, 116.0), // elipse
        (16.0, 16.0, 10.0, null, null, null), // título: 87 de largura
        (16.0, null, null, 12.0, null, null), // autor: largura do texto
      ]);

      final blobFinder = find.byKey(const ValueKey('$id.blob'));
      final blob = tester.widget<DecoratedBox>(blobFinder);
      expect(blob.decoration, isA<ShapeDecoration>());
      expect(blob.decoration, isNot(isA<BoxDecoration>()));
      expect(blob.position, DecorationPosition.background);
      final shape = blob.decoration as ShapeDecoration;
      expect(shape.shape, const OvalBorder());
      expect(shape.shape.runtimeType, OvalBorder);
      expect((shape.shape as OvalBorder).side, BorderSide.none);
      expect(shape.color!.toARGB32(), _ink);
      expect(shape.color, AppColors.ink);
      expect((shape.gradient, shape.image, shape.shadows), (null, null, null));
      // border-radius 50 % numa caixa 123×116 = elipse de semieixos 61,5 × 58.
      expect(tester.getSize(blobFinder), const Size(123, 116));
      expect(
        find.descendant(
          of: find.byKey(const ValueKey(id)),
          matching: find.byWidgetPredicate(
            (w) =>
                w is DecoratedBox &&
                w.decoration is BoxDecoration &&
                (w.decoration as BoxDecoration).shape == BoxShape.circle,
          ),
        ),
        findsNothing,
      );

      final title = _styleOf(tester, '$id.title');
      expect(title, same(AppTextStyles.coverTitle19));
      _expectTypography(
        title,
        family: 'InstrumentSerif',
        fallback: ['InstrumentSerifExt'],
        size: 19,
        weight: FontWeight.w400,
        height: 0.95,
        letterSpacing: 0,
        color: _ink,
        fontStyle: FontStyle.normal,
      );
      final author = _styleOf(tester, '$id.author');
      expect(author, same(AppTextStyles.coverAuthorFlame));
      expect(0.14 * 6.5, moreOrLessEquals(0.91, epsilon: 1e-12)); // 0,14em
      _expectTypography(
        author,
        family: 'Figtree',
        fallback: ['FigtreeExt'],
        size: 6.5,
        weight: FontWeight.w700,
        height: 1.2,
        letterSpacing: 0.91,
        color: _flame, // = cor do fundo da capa
      );
      expect(author.color, AppColors.flame);
    },
  );

  testWidgets(
    '8.5 Quincas: lombada → barras → bloco; barras #F7F0E3 raio 6 (→ 3), 81 / 56,7 / 32,4 × 6, coluna stretch gap 6; título InstrumentSerif 26/0,9 #FFFAF1; autor 6,5/700 ls 0,91 #FFFAF1',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      const id = 'forYou.item2.cover';
      final stack = _stackOf(tester, id);
      expect(stack.children.map((w) => (w as Positioned).child.key), const [
        ValueKey('$id.spine'),
        ValueKey('$id.lines'),
        ValueKey('$id.textBlock'),
      ]);
      expect(_positions(stack), [
        (0.0, 0.0, null, 0.0, 7.0, null), // lombada
        (16.0, 18.0, 16.0, null, null, null), // barras: 81 de largura
        (16.0, null, 10.0, 12.0, null, null), // bloco inferior
      ]);

      final lines = tester.widget<Column>(
        find.byKey(const ValueKey('$id.lines')),
      );
      expect(lines.crossAxisAlignment, CrossAxisAlignment.stretch);
      expect(lines.spacing, 6);
      expect(lines.mainAxisSize, MainAxisSize.min);
      final fractions = tester
          .widgetList<FractionallySizedBox>(
            find.descendant(
              of: find.byKey(const ValueKey('$id.lines')),
              matching: find.byType(FractionallySizedBox),
            ),
          )
          .toList();
      expect(fractions.map((f) => f.widthFactor), [1.0, 0.7, 0.4]);
      for (final f in fractions) {
        expect(f.alignment, Alignment.centerLeft);
        expect(f.heightFactor, isNull); // a altura (6) vem da caixa filha
      }
      for (final (i, width) in [(1, 81.0), (2, 56.7), (3, 32.4)]) {
        final lineId = '$id.line$i';
        final d = _decorationOf(tester, lineId);
        expect(d.color!.toARGB32(), _paper, reason: lineId);
        expect(d.color, AppColors.paper, reason: lineId);
        expect(d.borderRadius, BorderRadius.circular(6), reason: lineId);
        expect((d.border, d.boxShadow, d.gradient), (null, null, null));
        final rect = tester.getRect(find.byKey(ValueKey(lineId)));
        expect(rect.width, moreOrLessEquals(width, epsilon: 1e-9));
        expect(rect.height, 6, reason: lineId);
        // 6 + 6 > 6 de altura: CSS e Skia reduzem os raios pela metade → 3 (pontas redondas).
        final rrect = BorderRadius.circular(6).toRRect(rect).scaleRadii();
        expect(
          (rrect.tlRadiusX, rrect.tlRadiusY, rrect.brRadiusX, rrect.brRadiusY),
          (3.0, 3.0, 3.0, 3.0),
          reason: lineId,
        );
        debugPrint(
          '[barras] $lineId: ${rect.width.toStringAsFixed(4)} × ${rect.height}, raio efetivo ${rrect.tlRadiusX}',
        );
      }

      final block = tester.widget<Column>(
        find.byKey(const ValueKey('$id.textBlock')),
      );
      expect(block.spacing, 6);
      expect(block.crossAxisAlignment, CrossAxisAlignment.stretch);
      final title = _styleOf(tester, '$id.title');
      expect(title, same(AppTextStyles.coverTitle26));
      _expectTypography(
        title,
        family: 'InstrumentSerif',
        fallback: ['InstrumentSerifExt'],
        size: 26,
        weight: FontWeight.w400,
        height: 0.9,
        letterSpacing: 0,
        color: _surface,
        fontStyle: FontStyle.normal,
      );
      final author = _styleOf(tester, '$id.author');
      expect(author, same(AppTextStyles.coverAuthorSurface));
      _expectTypography(
        author,
        family: 'Figtree',
        fallback: ['FigtreeExt'],
        size: 6.5,
        weight: FontWeight.w700,
        height: 1.2,
        letterSpacing: 0.91,
        color: _surface,
      );
    },
  );

  testWidgets(
    '8.6 O Cortiço: lombada → arco externo → arco interno → bloco; arcos #FED170 34/34/0/0 68×80 e #00995E (cor do fundo) 14/14/0/0 28×46; título e autor #FFFAF1',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      const id = 'forYou.item3.cover';
      final stack = _stackOf(tester, id);
      expect(stack.children.map((w) => (w as Positioned).child.key), const [
        ValueKey('$id.spine'),
        ValueKey('$id.archOuter'),
        ValueKey('$id.archInner'),
        ValueKey('$id.textBlock'),
      ]);
      expect(_positions(stack), [
        (0.0, 0.0, null, 0.0, 7.0, null), // lombada
        (24.0, 22.0, null, null, 68.0, 80.0), // arco externo
        (44.0, 56.0, null, null, 28.0, 46.0), // arco interno ("porta")
        (16.0, null, 10.0, 12.0, null, null), // bloco inferior
      ]);
      final background = _decorationOf(tester, id).color;
      for (final (archId, color, token, r, size) in [
        ('$id.archOuter', _sun, AppColors.sun, 34.0, const Size(68, 80)),
        (
          '$id.archInner',
          _emerald,
          AppColors.emerald,
          14.0,
          const Size(28, 46),
        ),
      ]) {
        final d = _decorationOf(tester, archId);
        expect(d.color!.toARGB32(), color, reason: archId);
        expect(d.color, token, reason: archId);
        expect(
          d.borderRadius,
          BorderRadius.only(
            topLeft: Radius.circular(r),
            topRight: Radius.circular(r),
          ),
          reason: archId,
        );
        expect((d.border, d.boxShadow, d.gradient), (null, null, null));
        final box = _neoBox(tester, archId);
        expect((box.border, box.shadow, box.clip), (null, null, false));
        final rect = tester.getRect(find.byKey(ValueKey(archId)));
        expect(rect.size, size, reason: archId);
        // r + r = largura: os raios cabem exatamente, sem redução.
        final rrect = (d.borderRadius! as BorderRadius)
            .toRRect(rect)
            .scaleRadii();
        expect(
          (
            rrect.tlRadiusX,
            rrect.tlRadiusY,
            rrect.trRadiusX,
            rrect.trRadiusY,
            rrect.brRadiusX,
            rrect.blRadiusX,
          ),
          (r, r, r, r, 0.0, 0.0),
          reason: archId,
        );
      }
      // A "porta" é pintada na cor do fundo da capa.
      expect(_decorationOf(tester, '$id.archInner').color, background);

      final block = tester.widget<Column>(
        find.byKey(const ValueKey('$id.textBlock')),
      );
      expect(block.spacing, 6);
      expect(block.crossAxisAlignment, CrossAxisAlignment.stretch);
      final title = _styleOf(tester, '$id.title');
      expect(title, same(AppTextStyles.coverTitle26));
      _expectTypography(
        title,
        family: 'InstrumentSerif',
        fallback: ['InstrumentSerifExt'],
        size: 26,
        weight: FontWeight.w400,
        height: 0.9,
        letterSpacing: 0,
        color: _surface,
        fontStyle: FontStyle.normal,
      );
      final author = _styleOf(tester, '$id.author');
      expect(author, same(AppTextStyles.coverAuthorSurface));
      _expectTypography(
        author,
        family: 'Figtree',
        fallback: ['FigtreeExt'],
        size: 6.5,
        weight: FontWeight.w700,
        height: 1.2,
        letterSpacing: 0.91,
        color: _surface,
      );
    },
  );

  testWidgets(
    '8.7 legendas: títulos Figtree 14/700/1,2 tinta (maxLines 1 + reticências só no 1º); autores Figtree 13/500 #5B544B; item 116, gap 10 e 2',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      for (var i = 1; i <= 3; i++) {
        final item = 'forYou.item$i';
        expect(
          tester.getSize(find.byKey(ValueKey(item))).width,
          116,
          reason: item,
        );
        final column = tester.widget<Column>(
          find
              .descendant(
                of: find.byKey(ValueKey(item)),
                matching: find.byType(Column),
              )
              .first,
        );
        expect(column.spacing, 10, reason: item);
        final block = tester.widget<Column>(
          find.byKey(ValueKey('$item.textBlock')),
        );
        expect(block.spacing, 2, reason: item);
        expect(block.crossAxisAlignment, CrossAxisAlignment.stretch);

        final titleText = _textOf(tester, '$item.title');
        expect(
          (titleText.maxLines, titleText.ellipsis),
          i == 1 ? (1, true) : (null, false),
          reason: '$item.title: nowrap + ellipsis só no 1º',
        );
        final title = _styleOf(tester, '$item.title');
        expect(title, same(AppTextStyles.label14Bold), reason: item);
        _expectTypography(
          title,
          family: 'Figtree',
          fallback: ['FigtreeExt'],
          size: 14,
          weight: FontWeight.w700,
          height: 1.2,
          letterSpacing: 0,
          color: _ink,
          reason: '$item.title',
        );
        final author = _styleOf(tester, '$item.author');
        expect(author, same(AppTextStyles.body13Muted), reason: item);
        _expectTypography(
          author,
          family: 'Figtree',
          fallback: ['FigtreeExt'],
          size: 13,
          weight: FontWeight.w500,
          height: 1.2, // line-height normal
          letterSpacing: 0,
          color: 0xFF5B544B,
          reason: '$item.author',
        );
        expect(author.color, AppColors.inkMuted);
      }
    },
  );

  testWidgets(
    '8.3 canvas (TestRecordingPaintingContext): recortes PINTADOS = carrossel (hardEdge, 0→390) + 3 clipRRect antiAlias 2,5/8,5/8,5/2,5; nada mais recorta; sem saveLayer; nenhuma transformação além da escala viewBox → tamanho dos 2 SVGs',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      // O teste de widgets acima só enxerga widgets de recorte; aqui vale o que chega ao canvas (qualquer
      // RenderObject que recorte — Stack/Flex com transbordo, FittedBox, viewport — aparece como chamada).
      final sectionFinder = find.byType(ForYouSection);
      final origin = tester.getTopLeft(sectionFinder);
      final calls = _paintCalls(tester.renderObject(sectionFinder));
      final clips = _clipsIn(calls);
      debugPrint(
        '[canvas] recortes pintados pela seção (coordenadas da seção): ${[for (final c in calls)
          if (_clipMethods.contains(c.invocation.memberName)) '$c'].join(' · ')}',
      );
      expect(
        clips.where(
          (c) => c.memberName != #clipRect && c.memberName != #clipRRect,
        ),
        isEmpty,
        reason: 'nenhum clipPath/clipRSuperellipse',
      );

      // Carrossel: o 1º recorte (o cabeçalho e o chip não recortam), sem suavização (Clip.hardEdge), na janela
      // 0→390 × 108,6→327 da seção.
      final carousel = clips.first;
      expect(carousel.memberName, #clipRect);
      expect(carousel.namedArguments[#doAntiAlias], isFalse);
      final viewport = tester
          .getRect(find.byKey(const ValueKey('forYou.carousel')))
          .shift(-origin);
      _expectShape(
        carousel.positionalArguments.single as Object,
        viewport,
        epsilon: 1e-6,
        reason: 'carrossel',
      );
      // Tabela: carrossel em x −20 (= 0 do canvas), y 108,6, 390 × 218,4 (y com o ruído float32 do texto).
      _expectShape(
        carousel.positionalArguments.single as Object,
        const Rect.fromLTRB(0, 108.6, 390, 327),
        epsilon: 1e-3,
        reason: 'carrossel (tabela)',
      );

      // Exatamente 3 clipRRect, com suavização, na padding box de cada capa.
      final rrects = [
        for (final c in clips)
          if (c.memberName == #clipRRect) c,
      ];
      expect(rrects, hasLength(3));
      for (final (i, id) in _covers.indexed) {
        final got = rrects[i].positionalArguments.single as Object;
        expect(rrects[i].namedArguments[#doAntiAlias], isTrue, reason: id);
        _expectShape(
          got,
          _innerRRect(tester.getRect(find.byKey(ValueKey(id))).shift(-origin)),
          epsilon: 1e-6,
          reason: id,
        );
        // Tabela: capas em x 0 / 130 / 260 da seção (+ 20 do carrossel sangrado), y 108,6, 116 × 174.
        _expectShape(
          got,
          _innerRRect(Rect.fromLTWH(20 + 130.0 * i, 108.6, 116, 174)),
          epsilon: 1e-3,
          reason: '$id (tabela)',
        );
      }

      // Cada capa isolada: sem nenhuma transformação pintada; nas capas 2 e 3 o ÚNICO recorte é o clipRRect.
      final coverClips = <List<Invocation>>[];
      for (final id in _covers) {
        final coverCalls = _paintCalls(
          tester.renderObject(find.byKey(ValueKey(id))),
        );
        expect(
          coverCalls.where(
            (c) => const {
              #transform,
              #rotate,
              #skew,
              #scale,
              #translate,
            }.contains(c.invocation.memberName),
          ),
          isEmpty,
          reason: '$id: nada girado/escalado/deslocado dentro da capa',
        );
        coverClips.add(_clipsIn(coverCalls));
      }
      // Nas 3 capas o ÚNICO recorte é o clipRRect suavizado do NeoBox (a Stack tem `Clip.none`).
      for (final (i, id) in _covers.indexed) {
        expect(coverClips[i].map((c) => c.memberName), [
          #clipRRect,
        ], reason: id);
        expect(coverClips[i].single.namedArguments[#doAntiAlias], isTrue);
      }

      // Fora das capas, o único recorte da seção é o do carrossel: a sequência pintada pela seção é exatamente
      // o carrossel seguido dos recortes de cada capa (deslocados para as coordenadas da seção).
      final expected = <(Symbol, Object, bool)>[
        (#clipRect, viewport, false),
        for (final (i, id) in _covers.indexed)
          for (final c in coverClips[i])
            (
              c.memberName,
              _shift(
                c.positionalArguments.single as Object,
                tester.getTopLeft(find.byKey(ValueKey(id))) - origin,
              ),
              c.namedArguments[#doAntiAlias] as bool,
            ),
      ];
      expect(clips, hasLength(expected.length));
      for (final (i, (name, shape, antiAlias)) in expected.indexed) {
        expect(clips[i].memberName, name, reason: 'recorte $i');
        expect(clips[i].namedArguments[#doAntiAlias], antiAlias);
        _expectShape(
          clips[i].positionalArguments.single as Object,
          shape,
          epsilon: 1e-6,
          reason: 'recorte $i',
        );
      }

      // Nenhuma camada (Opacity, antiAliasWithSaveLayer) e nenhum giro/inclinação em toda a seção. As únicas
      // transformações são as dos dois SVGs (viewBox 24 → 18 e → 14: o traço 2 da seta vira 1,5), escalas
      // uniformes puras.
      expect(
        calls.where(
          (c) => const {
            #saveLayer,
            #rotate,
            #skew,
            #scale,
          }.contains(c.invocation.memberName),
        ),
        isEmpty,
      );
      // E todas pintadas ANTES do recorte do carrossel (no cabeçalho e no chip): nenhuma transformação envolve
      // o carrossel nem as capas.
      final carouselAt = calls.indexWhere(
        (c) => c.invocation.memberName == #clipRect,
      );
      final scales = <double>[];
      for (final (i, c) in calls.indexed) {
        if (c.invocation.memberName != #transform) continue;
        expect(i, lessThan(carouselAt), reason: 'transformação fora dos SVGs');
        final m = c.invocation.positionalArguments.single as List<double>;
        final s = m[0];
        expect(m, [s, 0, 0, 0, 0, s, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]);
        scales.add(s);
      }
      debugPrint(
        '[canvas] transformações pintadas pela seção: escalas $scales',
      );
      expect(scales, [18 / 24, 14 / 24]);
    },
  );

  testWidgets(
    '8.4–8.6 canvas: cada capa pinta fundo → borda 1,5 (DRRect 4/10/10/4 → 2,5/8,5/8,5/2,5) → lombada 7 × 171 → formas → textos, sem sombra; elipse = drawOval 123×116 tinta',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      const outer = Rect.fromLTWH(0, 0, 116, 174);
      final outerRRect = AppRadii.coverL.toRRect(outer);
      // Coordenadas da capa (borda externa); os filhos absolutos somam 1,5 (padding box).
      for (final (id, background, spine, shapes) in [
        (
          'forYou.item1.cover',
          _flame,
          0x26000000,
          [
            // left 20 / right −30 / bottom −58 / altura 116 → 21,5 → 144,5 × 114,5 → 230,5 (123 × 116).
            (#drawOval, const Rect.fromLTRB(21.5, 114.5, 144.5, 230.5), _ink),
          ],
        ),
        (
          'forYou.item2.cover',
          _azure,
          0x2E000000,
          [
            // left 16 / top 18 → 17,5; 19,5; larguras 81 / 56,7 / 32,4; gap 6; raio 6.
            for (final (i, w) in [(0, 81.0), (1, 81 * 0.7), (2, 81 * 0.4)])
              (
                #drawRRect,
                RRect.fromLTRBR(
                  17.5,
                  19.5 + 12.0 * i,
                  17.5 + w,
                  25.5 + 12.0 * i,
                  const Radius.circular(6),
                ),
                _paper,
              ),
          ],
        ),
        (
          'forYou.item3.cover',
          _emerald,
          0x2E000000,
          [
            // Arco externo left 24 / top 22, 68 × 80, raio 34 34 0 0.
            (
              #drawRRect,
              RRect.fromLTRBAndCorners(
                25.5,
                23.5,
                93.5,
                103.5,
                topLeft: const Radius.circular(34),
                topRight: const Radius.circular(34),
              ),
              _sun,
            ),
            // Arco interno left 44 / top 56, 28 × 46, raio 14 14 0 0, na cor do fundo.
            (
              #drawRRect,
              RRect.fromLTRBAndCorners(
                45.5,
                57.5,
                73.5,
                103.5,
                topLeft: const Radius.circular(14),
                topRight: const Radius.circular(14),
              ),
              _emerald,
            ),
          ],
        ),
      ]) {
        final calls = _paintCalls(
          tester.renderObject(find.byKey(ValueKey(id))),
        );
        final draws = [
          for (final c in calls)
            if (!_stateMethods.contains(c.invocation.memberName)) c.invocation,
        ];
        debugPrint(
          '[canvas] $id desenha: ${draws.map((d) => d.memberName == #drawParagraph ? 'texto' : '${_methodName(d.memberName)} ${_hex(_paintColor(d))}').join(' → ')}',
        );
        final shapesDrawn = [
          for (final d in draws)
            if (d.memberName != #drawParagraph) d,
        ];
        // Ordem: fundo, borda, lombada, formas — e nada antes do fundo (sem sombra).
        expect(shapesDrawn.map((d) => d.memberName), [
          #drawRRect,
          #drawDRRect,
          #drawRect,
          for (final s in shapes) s.$1,
        ], reason: id);
        expect(_paintColor(shapesDrawn[0]), background, reason: '$id fundo');
        final border = shapesDrawn[1];
        expect(_paintColor(border), _ink, reason: '$id borda');
        _expectShape(
          border.positionalArguments[0] as Object,
          outerRRect,
          reason: '$id borda (externa 4/10/10/4)',
        );
        _expectShape(
          border.positionalArguments[1] as Object,
          _innerRRect(outer),
          reason: '$id borda (interna: 1,5 para dentro, 2,5/8,5/8,5/2,5)',
        );
        final spineDraw = shapesDrawn[2];
        expect(_paintColor(spineDraw), spine, reason: '$id lombada');
        _expectShape(
          spineDraw.positionalArguments[0] as Object,
          const Rect.fromLTRB(1.5, 1.5, 8.5, 172.5),
          reason: '$id lombada 7 × 171 na padding box',
        );
        for (final (i, (_, shape, color)) in shapes.indexed) {
          final d = shapesDrawn[3 + i];
          expect(_paintColor(d), color, reason: '$id forma $i');
          _expectShape(
            d.positionalArguments[0] as Object,
            shape,
            reason: '$id forma $i',
          );
        }
        // Os textos vêm depois de todas as formas (pintam por cima).
        final firstText = draws.indexWhere(
          (d) => d.memberName == #drawParagraph,
        );
        expect(firstText, greaterThanOrEqualTo(0), reason: id);
        expect(
          draws.skip(firstText).every((d) => d.memberName == #drawParagraph),
          isTrue,
          reason: '$id: textos por último',
        );
      }
    },
  );

  testWidgets(
    'sem ripple: nenhum InkWell/InkResponse/Material/Ink na seção (D-04: o toque só escala)',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      expect(
        find.descendant(
          of: find.byType(ForYouSection),
          matching: find.byWidgetPredicate(
            (w) =>
                w is InkWell || w is InkResponse || w is Material || w is Ink,
          ),
        ),
        findsNothing,
      );
    },
  );

  testWidgets(
    '8.1–8.2 pixels @3x: seta de "Ver tudo", chip (fundo, borda, brilho) e papel em volta',
    (tester) async {
      setCanvasView(tester);
      await _pumpCanvas(tester);
      final (rgba, width) = await _capture(tester);
      // Chip em (20; 1265,56), 241,28 × 32,6: centro vertical em 16,3 e raio 16,3 (14,8 por dentro da borda).
      final chip = _topLeft(tester, 'forYou.reasonChip');
      // Seta em (352; 1220,56), 18 × 18: haste "M5 12h14" → y = 9, x 3,75–14,25, traço 1,5 (8,25–9,75).
      final arrow = _topLeft(tester, 'forYou.seeAll.icon');
      _expectPixels(rgba, width, {
        // x 5: 11,3 do centro do semicírculo esquerdo (< 14,8) e 7,4 antes da ponta do brilho (11,5 + 0,875).
        'chip: fundo à esquerda do brilho': (
          chip + const Offset(5, 16.3),
          _surface,
        ),
        // Texto termina em 227,78 e o lado interno em 239,78: x 233,5 fica 5,7 / 6,3 de cada.
        'chip: fundo entre o texto e a borda direita': (
          chip + const Offset(233.5, 16.3),
          _surface,
        ),
        // Meio do traço de 1,5 no ponto mais à esquerda do semicírculo.
        'chip: borda esquerda': (chip + const Offset(0.75, 16.3), _ink),
        // Meio do traço de 1,5 no trecho reto de cima.
        'chip: borda superior': (chip + const Offset(110, 0.75), _ink),
        // Raio 16,3 (999 normalizado): (21,5; 1267,06) → pixel 21,33–21,67 × 1267,00–1267,33, a ≥ 20,6 do centro
        // do semicírculo (36,3; 1281,86) → fora do chip (papel). Com um raio "parecido" de até ~6 seria borda.
        'chip: canto do retângulo fora do semicírculo → papel': (
          chip + const Offset(1.5, 1.5),
          _paper,
        ),
        // Centro do ícone 14 (11,5 + 7; 9,3 + 7): miolo da estrela de 4 pontas.
        'chip: brilho sólido (centro)': (chip + const Offset(18.5, 16.3), _ink),
        // 8,72 à direita do chip (termina em 241,28), na linha do centro.
        'papel à direita do chip': (chip + const Offset(250, 16.3), _paper),
        // Sem sombra: 1 depois da borda direita (261,30 → coluna física 786 = x 262,00–262,33, 2 colunas
        // físicas longe da suavização da borda) e 1 abaixo da inferior (1298,16 → linha 3897 = y 1299,00–1299,33).
        // Uma sombra dura 2/2 ou 4/4 pintaria tinta nos dois pontos.
        'chip sem sombra: papel 1 à direita da borda': (
          chip + const Offset(242.3, 16.3),
          _paper,
        ),
        'chip sem sombra: papel 1 abaixo da borda': (
          chip + const Offset(110, 33.6),
          _paper,
        ),
        // 2,56 acima do chip (o cabeçalho termina 14 acima dele).
        'papel acima do chip': (chip + const Offset(110, -2.56), _paper),
        // 8,84 abaixo do chip e 9,16 acima das capas (gap 14 + 4).
        'papel entre o chip e o carrossel': (
          chip + const Offset(110, 41.44),
          _paper,
        ),
        // Haste da seta: linha física cabe inteira na faixa 8,25–9,75.
        'seta: haste (tinta)': (arrow + const Offset(6, 9), _ink),
        // x 6 só tem a haste (a ponta começa em x ≈ 9); 5,44 fica 2,8 acima dela.
        'seta: papel acima da haste': (arrow + const Offset(6, 5.44), _paper),
      });
    },
  );

  testWidgets(
    '8.4 pixels @3x: Memórias — fundo, lombada (src-over exato), elipse (não círculo) recortada pela capa, "ACHADO DE ASSIS" visível só sobre a elipse, "M" invisível, cantos 4 e 10',
    (tester) async {
      setCanvasView(tester);
      await _pumpCanvas(tester);
      final (rgba, width) = await _capture(tester);
      // Capa em (20; 1316,16), 116 × 174; padding box 21,5–134,5 × 1317,66–1488,66.
      // Elipse: centro (103; 1488,66), semieixos 61,5 × 58 (recortada à direita e embaixo).
      final c = _topLeft(tester, 'forYou.item1.cover');
      _expectPixels(rgba, width, {
        // (80; 1416,16): 28,35 abaixo do título (termina em 1387,81) e 14,5 acima do topo da elipse.
        'fundo #FF552E': (c + const Offset(60, 100), _flame),
        // (25; 1400,16): meio da faixa 21,5–28,5, a meia altura. Preto .15 sobre o laranja.
        'lombada .15 (src-over exato)': (
          c + const Offset(5, 84),
          _over(AppColors.spine15, AppColors.flame),
        ),
        // (103; 1455,16): eixo da elipse, 33,5 acima do centro (meia-largura ali 50,2) e 13,7 acima do autor.
        'elipse tinta': (c + const Offset(83, 139), _ink),
        // (43; 1483,66): 60 à esquerda e 5 acima do centro → dentro da elipse 61,5 × 58 (0,959 < 1; borda em
        // 41,73) e FORA de um círculo de raio 58 (60,2): prova que não é BoxShape.circle.
        'elipse, não círculo': (c + const Offset(23, 167.5), _ink),
        // (103; 1495): entre a capa (termina em 1490,16) e o título do item (1500,16); sem o recorte a
        // elipse iria até 1546,66.
        'elipse recortada embaixo → papel': (
          c + const Offset(83, 178.84),
          _paper,
        ),
        // (140; 1470): entre as capas 1 e 2; sem o recorte a elipse iria até x 161,2 nessa altura.
        'elipse recortada à direita → papel': (
          c + const Offset(120, 153.84),
          _paper,
        ),
        // (134; 1318): com raio 4 estaria dentro da capa (2,94 do centro do arco); com raio 10 o pixel físico
        // inteiro fica fora do arco (≥ 11,19 do centro (126; 1326,16)).
        'canto sup. direito (raio 10) → papel': (
          c + const Offset(114, 1.84),
          _paper,
        ),
        // (20,3; 1316,4): pixel inteiro fora do arco de raio 4 (≥ 5,06 do centro (24; 1320,16)).
        'canto sup. esquerdo (raio 4) → papel': (
          c + const Offset(0.3, 0.24),
          _paper,
        ),
        // (21,5; 1317,66): pixel inteiro entre 2,5 e 4 do centro do arco → faixa da borda.
        'canto sup. esquerdo: borda tinta': (c + const Offset(1.5, 1.5), _ink),
        // Borda 1,5 no trecho reto da esquerda, a meia altura (y 1403,16 → linha 4209): a capa começa em x 20
        // (coluna física 60, sem suavização), então a coluna 59 (x 19,67–20,00) é papel, a 62 (20,67–21,00) é
        // tinta PURA (a lombada não pinta por cima da borda: fica na padding box) e a 65 (21,67–22,00), logo
        // depois do fim da borda (21,5), já é a lombada inteira (com borda de 2 px seria tinta).
        'papel logo antes da borda esquerda': (
          c + const Offset(-0.2, 87),
          _paper,
        ),
        'borda esquerda: tinta pura': (c + const Offset(0.75, 87), _ink),
        'logo depois da borda esquerda: lombada': (
          c + const Offset(1.8, 87),
          _over(AppColors.spine15, AppColors.flame),
        ),
        // Borda inferior sob a elipse (x 78; y 1489,41 → linha 4468 = 1489,33–1489,67, dentro de 1488,66–1490,16):
        // tinta pura — a elipse é recortada na padding box (e é da mesma cor; o que prova o recorte é o papel
        // fora da capa, acima).
        'borda inferior (sob a elipse)': (c + const Offset(58, 173.25), _ink),
        // Sem sombra: 1 depois da borda direita (x 137 → coluna 411; a borda termina em 136 = coluna 408 exata)
        // e 1 abaixo da inferior (1491,16 → linha 4473; a borda termina em 1490,16 = linha 4470,48).
        'sem sombra: papel 1 à direita da borda': (
          c + const Offset(117, 87),
          _paper,
        ),
        'sem sombra: papel 1 abaixo da borda': (
          c + const Offset(58, 175),
          _paper,
        ),
      });

      // "MACHADO DE ASSIS" (#FF552E = fundo) só aparece sobre a elipse tinta.
      final author = tester.getRect(
        find.byKey(const ValueKey('forYou.item1.cover.author')),
      );
      final blob = tester.getRect(
        find.byKey(const ValueKey('forYou.item1.cover.blob')),
      );
      final center = blob.center;
      // Pixel físico cujo quadrado inteiro está ≥ 1 px lógico dentro da elipse (semieixos − 1).
      bool deepInside(int px, int py) {
        for (final (x, y) in [
          (px / 3, py / 3),
          ((px + 1) / 3, py / 3),
          (px / 3, (py + 1) / 3),
          ((px + 1) / 3, (py + 1) / 3),
        ]) {
          final ex = (x - center.dx) / (blob.width / 2 - 1);
          final ey = (y - center.dy) / (blob.height / 2 - 1);
          if (ex * ex + ey * ey > 1) return false;
        }
        return true;
      }

      var textOnBlob = 0, blobInk = 0, mixed = 0;
      for (
        var py = (author.top * 3).floor();
        py < (author.bottom * 3).ceil();
        py++
      ) {
        for (
          var px = (author.left * 3).floor();
          px < (author.right * 3).ceil();
          px++
        ) {
          if (!deepInside(px, py)) continue;
          final v = _argbAtPixel(rgba, width, px, py);
          if (v == _flame) {
            textOnBlob++;
          } else if (v == _ink) {
            blobInk++;
          } else {
            mixed++;
          }
        }
      }
      debugPrint(
        '[autor] pixels ≥ 1 dentro da elipse na caixa do autor: $textOnBlob #FF552E (texto), $blobInk tinta, $mixed suavizados',
      );
      expect(
        textOnBlob,
        greaterThan(0),
        reason: 'texto visível sobre a elipse',
      );
      expect(blobInk, greaterThan(0));
      _expectPixels(rgba, width, {
        // (45,1; 1472,8) = coluna física 135, linha 4418: 1,15 dentro da borda da elipse nessa altura (43,85);
        // pela posição, a perna esquerda do "A" de MACHADO (1º glifo depois do "M").
        'autor: traço de glifo #FF552E sobre a elipse': (
          Offset(author.left + 7.6, author.top + 3.95),
          _flame,
        ),
      });
      // O "M" inicial (começa em x 37,5) fica sobre o laranja: na base da caixa do autor (1476,66) a elipse
      // começa em x 42,83, então as colunas físicas 112–127 (x 37,33–42,67) nunca a tocam — só podem ter
      // #FF552E, mesmo com o "M" pintado ali.
      expect((author.left * 3).floor(), 112);
      var mFlame = 0;
      final mOther = <String>[];
      for (
        var py = (author.top * 3).floor();
        py < (author.bottom * 3).ceil();
        py++
      ) {
        for (var px = (author.left * 3).floor(); px <= 127; px++) {
          final v = _argbAtPixel(rgba, width, px, py);
          if (v == _flame) {
            mFlame++;
          } else {
            mOther.add('($px; $py) ${_hex(v)}');
          }
        }
      }
      debugPrint(
        '[autor] área do "M" (colunas 112–127, x 37,33–42,67): $mFlame pixels #FF552E, ${mOther.length} diferentes',
      );
      expect(mFlame, greaterThan(300));
      expect(mOther, isEmpty, reason: '"M" invisível sobre o laranja');

      // Coluna física 64 (x 21,33–21,67), a da borda interna esquerda: metade borda, metade padding box. A
      // lombada entra nela pela aresta suavizada do ClipRRect, como nas capas 2 e 3 (colunas 454 e 844). Um
      // recorte retangular sem suavização (Stack com `Clip.hardEdge` e a elipse transbordando) arredondaria a
      // aresta para 65 e deixaria só a mistura borda/laranja 0xFF8C3621, sem lombada.
      for (final (what, px, want) in [
        ('capa 1, coluna 64', 64, 0xFF873420),
        ('capa 2, coluna 454', 454, 0xFF0F4D70),
        ('capa 3, coluna 844', 844, 0xFF0C5436),
      ]) {
        final got = _argbAtPixel(rgba, width, px, 4200);
        debugPrint('[lombada] $what, linha 4200: ${_hex(got)}');
        expect(_hex(got), _hex(want), reason: what);
      }
      expect(_argbAtPixel(rgba, width, 64, 4200), isNot(0xFF8C3621));
    },
  );

  testWidgets(
    '8.5 pixels @3x: Quincas — fundo, lombada (src-over exato), barras #F7F0E3 com larguras 100 / 70 / 40 %, canto 10',
    (tester) async {
      setCanvasView(tester);
      await _pumpCanvas(tester);
      final (rgba, width) = await _capture(tester);
      // Capa em (150; 1316,16). Barras x 167,5 → 248,5 / 224,2 / 199,9; y 1335,66, 1347,66, 1359,66 (6 cada).
      final c = _topLeft(tester, 'forYou.item2.cover');
      Rect line(int i) =>
          tester.getRect(find.byKey(ValueKey('forYou.item2.cover.line$i')));
      final l1 = line(1), l2 = line(2), l3 = line(3);
      _expectPixels(rgba, width, {
        // (200; 1390,16): 24,5 abaixo das barras e 25,9 acima do título.
        'fundo #058CD7': (c + const Offset(50, 74), _azure),
        // (155; 1400,16): meio da faixa da lombada, a meia altura. Preto .18 sobre o azul.
        'lombada .18 (src-over exato)': (
          c + const Offset(5, 84),
          _over(AppColors.spine18, AppColors.azure),
        ),
        // Centros das barras: 3 das bordas de cima e de baixo.
        'barra 1 (centro)': (l1.center, _paper),
        'barra 2 (centro)': (l2.center, _paper),
        'barra 3 (centro)': (l3.center, _paper),
        // Vão de 6 entre as barras 1 e 2: 3 de cada uma.
        'vão entre as barras 1 e 2': (
          Offset(l1.center.dx, l1.bottom + 3),
          _azure,
        ),
        // 4,2 antes do fim da barra 2 (ponta redonda de raio 3) e 11,8 depois dele.
        'barra 2 perto do fim': (Offset(l2.right - 4.2, l2.center.dy), _paper),
        'azul depois da barra 2 (70 %)': (
          Offset(l2.right + 11.8, l2.center.dy),
          _azure,
        ),
        // 4,9 antes do fim da barra 3 e 12,1 depois dele.
        'barra 3 perto do fim': (Offset(l3.right - 4.9, l3.center.dy), _paper),
        'azul depois da barra 3 (40 %)': (
          Offset(l3.right + 12.1, l3.center.dy),
          _azure,
        ),
        // (264; 1318): mesmo ponto da capa 1 — fora do arco de raio 10 (dentro, se fosse 4).
        'canto sup. direito (raio 10) → papel': (
          c + const Offset(114, 1.84),
          _paper,
        ),
        // (264; 1488,16) → pixel 264,00–264,33 × 1488,00–1488,33: o canto mais perto do centro do arco de raio
        // 10 (256; 1480,16) fica a 11,2 dele → fora (papel); com raio 4 (centro (262; 1486,16)) estaria a
        // ≤ 3,2 → dentro. Ordem CSS TL, TR, BR, BL: o 3º raio é 10.
        'canto inf. direito (raio 10) → papel': (
          c + const Offset(114, 172),
          _paper,
        ),
        // (150,3; 1489,92) → pixel 150,00–150,33 × 1489,67–1490,00: ≥ 5,08 do centro do arco de raio 4
        // (154; 1486,16) → fora (papel). O 4º raio é 4.
        'canto inf. esquerdo (raio 4) → papel': (
          c + const Offset(0.3, 173.76),
          _paper,
        ),
        // (151,5; 1488,66) → pixel 151,33–151,67 × 1488,33–1488,67: entre 3,18 e 3,66 do mesmo centro → dentro
        // da faixa da borda (2,5–4) → tinta.
        'canto inf. esquerdo: borda tinta': (
          c + const Offset(1.5, 172.5),
          _ink,
        ),
        // Borda esquerda a meia altura (mesmas colunas relativas da capa 1: 449 / 452 / 455).
        'papel logo antes da borda esquerda': (
          c + const Offset(-0.2, 87),
          _paper,
        ),
        'borda esquerda: tinta pura': (c + const Offset(0.75, 87), _ink),
        'logo depois da borda esquerda: lombada': (
          c + const Offset(1.8, 87),
          _over(AppColors.spine18, AppColors.azure),
        ),
        // Sem sombra (mesmos pontos relativos da capa 1).
        'sem sombra: papel 1 à direita da borda': (
          c + const Offset(117, 87),
          _paper,
        ),
        'sem sombra: papel 1 abaixo da borda': (
          c + const Offset(58, 175),
          _paper,
        ),
      });
    },
  );

  testWidgets(
    '8.6 pixels @3x: O Cortiço — fundo, lombada (src-over exato), arco #FED170 (cantos 34) e "porta" #00995E (cantos 14)',
    (tester) async {
      setCanvasView(tester);
      await _pumpCanvas(tester);
      final (rgba, width) = await _capture(tester);
      // Capa em (280; 1316,16). Arco externo 305,5–373,5 × 1339,66–1419,66 (centro do topo (339,5; 1373,66));
      // arco interno 325,5–353,5 × 1373,66–1419,66 (centro do topo (339,5; 1387,66)).
      final c = _topLeft(tester, 'forYou.item3.cover');
      final outer = tester.getRect(
        find.byKey(const ValueKey('forYou.item3.cover.archOuter')),
      );
      final inner = tester.getRect(
        find.byKey(const ValueKey('forYou.item3.cover.archInner')),
      );
      _expectPixels(rgba, width, {
        // (295; 1330,16): 6,5 à direita da lombada, 10,5 antes e 9,5 acima do arco.
        'fundo #00995E': (c + const Offset(15, 14), _emerald),
        // (285; 1400,16): meio da faixa da lombada. Preto .18 sobre o verde.
        'lombada .18 (src-over exato)': (
          c + const Offset(5, 84),
          _over(AppColors.spine18, AppColors.emerald),
        ),
        // (315; 1400): 9,5 da borda externa e 10,5 da porta, no trecho reto (abaixo do centro do topo).
        'arco externo: faixa esquerda': (
          Offset(outer.left + 9.5, outer.bottom - 19.66),
          _sun,
        ),
        // (339,5; 1345): no eixo, 5,34 abaixo do alto do arco e 28,66 acima da porta.
        'arco externo: topo': (Offset(outer.center.dx, outer.top + 5.34), _sun),
        // (308; 1342): dentro do quadrado 68 × 80, mas a 44,66 do centro do arco (> 34) → fundo.
        'arco externo: canto arredondado (raio 34) → fundo': (
          Offset(outer.left + 2.5, outer.top + 2.34),
          _emerald,
        ),
        // (315; 1415) e (315; 1425): 4,66 acima e 5,34 abaixo do fim do arco (altura 80).
        'arco externo: base (acima do fim)': (
          Offset(outer.left + 9.5, outer.bottom - 4.66),
          _sun,
        ),
        'abaixo do arco → fundo': (
          Offset(outer.left + 9.5, outer.bottom + 5.34),
          _emerald,
        ),
        // (339,5; 1400): centro da porta, 14 das laterais.
        'porta #00995E (centro)': (
          Offset(inner.center.dx, inner.bottom - 19.66),
          _emerald,
        ),
        // (339,5; 1380): 6,34 abaixo do alto da porta, no eixo.
        'porta: topo arredondado': (
          Offset(inner.center.dx, inner.top + 6.34),
          _emerald,
        ),
        // (327; 1375,16): dentro do quadrado 28 × 46, mas a ≥ 17,3 do centro do topo (> 14) → arco amarelo.
        'porta: canto arredondado (raio 14) → arco': (
          Offset(inner.left + 1.5, inner.top + 1.5),
          _sun,
        ),
        // Borda esquerda a meia altura (colunas 839 / 842 / 845, como nas capas 1 e 2).
        'papel logo antes da borda esquerda': (
          c + const Offset(-0.2, 87),
          _paper,
        ),
        'borda esquerda: tinta pura': (c + const Offset(0.75, 87), _ink),
        'logo depois da borda esquerda: lombada': (
          c + const Offset(1.8, 87),
          _over(AppColors.spine18, AppColors.emerald),
        ),
        // Sem sombra embaixo (a lateral direita fica fora do canvas): 1 abaixo da borda inferior.
        'sem sombra: papel 1 abaixo da borda': (
          c + const Offset(58, 175),
          _paper,
        ),
      });
    },
  );

  testWidgets(
    '8.3 pixels @3x: corte do 3º item em x = 390 (a última coluna 389,67–390 ainda é capa, a borda direita 394,5–396 não aparece) e papel entre as capas',
    (tester) async {
      setCanvasView(tester);
      await _pumpCanvas(tester);
      final (rgba, width) = await _capture(tester);
      expect(width, 1170); // nada além de x = 390
      final cover3 = tester.getRect(
        find.byKey(const ValueKey('forYou.item3.cover')),
      );
      expect(cover3.right, 396); // o layout continua 6 além do canvas
      final c1 = _topLeft(tester, 'forYou.item1.cover');
      // Última coluna física (1169) = x 389,67–390.
      _expectPixels(rgba, width, {
        // (389,8; 1400,16): 4,7 antes da borda interna direita (394,5) → verde; sem a borda da direita.
        'última coluna: fundo da capa 3': (
          Offset(389.8, cover3.top + 84),
          _emerald,
        ),
        // (389,8; 1317,8): curva do raio 10 — nessa coluna a borda superior ocupa 1317,00–1318,49; a linha
        // física 1317,67–1318,00 cabe inteira nela.
        'última coluna: borda superior da capa 3': (
          Offset(389.8, cover3.top + 1.64),
          _ink,
        ),
        // (389,8; 1495): entre a capa (termina em 1490,16) e o título do item.
        'última coluna: papel abaixo da capa 3': (
          Offset(389.8, cover3.bottom + 4.84),
          _paper,
        ),
        // Gaps de 14 do carrossel: 7 das capas vizinhas.
        'papel entre as capas 1 e 2': (c1 + const Offset(123, 84), _paper),
        'papel entre as capas 2 e 3': (c1 + const Offset(253, 84), _paper),
      });
      final column = <int>{
        for (
          var py = (cover3.top * 3).ceil() + 30;
          py < (cover3.bottom * 3).floor() - 30;
          py++
        )
          _argbAtPixel(rgba, width, 1169, py),
      };
      debugPrint(
        '[corte] cores da coluna 1169 dentro da capa 3 (sem os cantos): ${column.map(_hex).join(', ')}',
      );
      // Só o verde da capa: a borda direita (394,5–396) não aparece e nada da arte chega a 389,67.
      expect(column, {_emerald});
    },
  );
}

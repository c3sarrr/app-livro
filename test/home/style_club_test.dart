import 'dart:math' as math;

import 'package:app_leitura/app/app.dart';
import 'package:app_leitura/core/design_system/painters/chromium_dash.dart';
import 'package:app_leitura/core/design_system/painters/hatch_painter.dart';
import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/tokens/app_icons.dart';
import 'package:app_leitura/core/design_system/tokens/app_typography.dart';
import 'package:app_leitura/core/design_system/widgets/app_svg.dart';
import 'package:app_leitura/core/design_system/widgets/count_badge.dart';
import 'package:app_leitura/core/design_system/widgets/neo_box.dart';
import 'package:app_leitura/core/design_system/widgets/pill.dart';
import 'package:app_leitura/features/home/application/home_providers.dart';
import 'package:app_leitura/features/home/data/home_repository.dart';
import 'package:app_leitura/features/home/domain/models.dart';
import 'package:app_leitura/features/home/presentation/sections/book_club_ticket.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

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

void _expectFigtree(
  TextStyle s, {
  required double size,
  required FontWeight weight,
  double letterSpacing = 0,
  int color = _ink,
  String? reason,
}) => _expectTypography(
  s,
  family: 'Figtree',
  fallback: ['FigtreeExt'],
  size: size,
  weight: weight,
  height: 1.2, // line-height normal
  letterSpacing: letterSpacing,
  color: color,
  reason: reason,
);

/// Borda uniforme de 1,5 tinta, raio [radius] e nenhuma sombra.
void _expectInkBox(
  BoxDecoration d, {
  required int? color,
  required BorderRadius radius,
  String? reason,
}) {
  expect(d.color?.toARGB32(), color, reason: reason);
  expect(
    d.border,
    Border.all(width: 1.5, color: AppColors.ink),
    reason: reason,
  );
  expect((d.border! as Border).top.color.toARGB32(), _ink, reason: reason);
  expect(d.borderRadius, radius, reason: reason);
  expect(d.boxShadow, isNull, reason: reason);
  expect(d.gradient, isNull, reason: reason);
  expect(d.image, isNull, reason: reason);
  expect(d.shape, BoxShape.rectangle, reason: reason);
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

/// Descrição curta de um desenho: método + cor do `Paint` ("shader" para a hachura).
String _drawLabel(Invocation draw) {
  final name = _methodName(draw.memberName);
  final paint = draw.positionalArguments.whereType<Paint>().firstOrNull;
  if (paint == null) return name;
  if (paint.shader != null) return '$name shader';
  return '$name ${_hex(paint.color.toARGB32())}';
}

const _ink = 0xFF1A1714;
const _paper = 0xFFF7F0E3;
const _surface = 0xFFFFFAF1;
const _blush = 0xFFFFC1C6;
const _sun = 0xFFFED170;
const _flame = 0xFFFF552E;
const _muted = 0xFF5B544B;

/// F09 — camada 2 (estilo, sem tolerância) da seção `club`.
void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    '9.1 seção só recorta (ClipRRect 28 suavizado, sem borda/fundo); ticket #FFFAF1, borda 1,5 tinta, raio 28, recorte na padding box (26,5), sem sombra',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final clip = tester.widget<ClipRRect>(find.byKey(const ValueKey('club')));
      expect(clip.borderRadius, BorderRadius.circular(28));
      expect(clip.clipBehavior, Clip.antiAlias);
      // Nada pinta entre a seção e o ticket: nenhuma decoração acima do ticket.
      expect(
        find.descendant(
          of: find.byType(BookClubTicket),
          matching: find.ancestor(
            of: find.byKey(const ValueKey('club.ticket')),
            matching: find.byWidgetPredicate(
              (w) => w is DecoratedBox || w is ColoredBox || w is CustomPaint,
            ),
          ),
        ),
        findsNothing,
      );
      final ticket = _neoBox(tester, 'club.ticket');
      expect(ticket.color, AppColors.surface);
      expect(ticket.color!.toARGB32(), _surface);
      expect(ticket.border, const BorderSide(width: 1.5, color: AppColors.ink));
      expect(ticket.radius, BorderRadius.circular(28));
      expect(ticket.clip, isTrue);
      expect(ticket.shadow, isNull);
      expect(ticket.padding, EdgeInsets.zero);
      _expectInkBox(
        _decorationOf(tester, 'club.ticket'),
        color: _surface,
        radius: BorderRadius.circular(28),
      );
      // overflow: hidden do ticket → recorte dos filhos na padding box com raio 28 − 1,5.
      final inner = tester.widget<ClipRRect>(
        find
            .descendant(
              of: find.byKey(const ValueKey('club.ticket')),
              matching: find.byType(ClipRRect),
            )
            .first,
      );
      expect(inner.borderRadius, BorderRadius.circular(26.5));
      expect(inner.clipBehavior, Clip.antiAlias);
    },
  );

  testWidgets(
    '9.2 perfuração = ChromiumDashPainter vertical, traço 1,5 tinta, sobre o fundo #FFC1C6 do canhoto; entalhes 26×26 #F7F0E3, borda 1,5 tinta, raio 13, sem sombra, fora da semântica',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final dash = tester.widget<CustomPaint>(
        find.byKey(const ValueKey('club.stub.perforation')),
      );
      final painter = dash.painter! as ChromiumDashPainter;
      expect(painter.axis, Axis.vertical);
      expect(painter.thickness, 1.5);
      expect(painter.color.toARGB32(), _ink);
      expect(dash.foregroundPainter, isNull);
      // Fundo do canhoto: ColoredBox blush de 92 × 263,6 (cobre a coluna da borda: os vãos mostram o blush).
      final colored = tester.widget<ColoredBox>(
        find.descendant(
          of: find.byKey(const ValueKey('club.stub')),
          matching: find.byType(ColoredBox),
        ),
      );
      expect(colored.color.toARGB32(), _blush);
      expect(
        tester.getSize(
          find.descendant(
            of: find.byKey(const ValueKey('club.stub')),
            matching: find.byType(ColoredBox),
          ),
        ),
        tester.getSize(find.byKey(const ValueKey('club.stub'))),
      );
      // aria-hidden: o ExcludeSemantics é o pai direto do CustomPaint da perfuração (e está ativo).
      final dashHidden = tester.widget<ExcludeSemantics>(
        find
            .ancestor(
              of: find.byKey(const ValueKey('club.stub.perforation')),
              matching: find.byType(ExcludeSemantics),
            )
            .first,
      );
      expect(dashHidden.excluding, isTrue);
      expect(dashHidden.child, same(dash));

      for (final id in ['club.notchTop', 'club.notchBottom']) {
        final neo = tester.widget<NeoBox>(
          find.descendant(
            of: find.byKey(ValueKey(id)),
            matching: find.byType(NeoBox),
          ),
        );
        expect((neo.width, neo.height), (26.0, 26.0), reason: id);
        expect(neo.color!.toARGB32(), _paper, reason: id);
        expect(neo.color, AppColors.paper, reason: id);
        expect(neo.shadow, isNull, reason: id);
        _expectInkBox(
          _decorationOf(tester, id),
          color: _paper,
          radius: const BorderRadius.all(Radius.circular(13)),
          reason: id,
        );
        // aria-hidden: o ExcludeSemantics é o pai direto do NeoBox do entalhe (e está ativo).
        final hidden = tester.widget<ExcludeSemantics>(
          find
              .ancestor(
                of: find.byWidget(neo),
                matching: find.byType(ExcludeSemantics),
              )
              .first,
        );
        expect(hidden.excluding, isTrue, reason: '$id: aria-hidden');
        expect(hidden.child, same(neo), reason: '$id: aria-hidden');
      }
    },
  );

  testWidgets(
    '9.3 pílula #FFC1C6, borda 1,5, raio 999, padding 5 10 + Figtree 12/700 tinta; avatares 26 com as cores dos dados (#B6ACE4 #ABCF82 #FFC1C6) e "+8" #FFFAF1, borda 1,5, raio 13 + Figtree 11/700 e 10/700 (800 → 700)',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final pill = tester.widget<Pill>(find.byKey(const ValueKey('club.pill')));
      expect(
        pill.padding,
        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      );
      expect(pill.color.toARGB32(), _blush);
      expect(pill.border, const BorderSide(width: 1.5, color: AppColors.ink));
      _expectInkBox(
        _decorationOf(tester, 'club.pill'),
        color: _blush,
        radius: BorderRadius.circular(999),
      );
      final pillStyle = _styleOf(tester, 'club.pill');
      expect(pillStyle, same(AppTextStyles.label12Bold));
      _expectFigtree(pillStyle, size: 12, weight: FontWeight.w700);

      const colors = [0xFFB6ACE4, 0xFFABCF82, _blush, _surface];
      for (var i = 0; i < 4; i++) {
        final id = 'club.avatar$i';
        final neo = _neoBox(tester, id);
        expect((neo.width, neo.height), (26.0, 26.0), reason: id);
        expect(neo.shadow, isNull, reason: id);
        _expectInkBox(
          _decorationOf(tester, id),
          color: colors[i],
          radius: BorderRadius.circular(13),
          reason: id,
        );
        final style = _styleOf(tester, id);
        if (i < 3) {
          expect(style, same(AppTextStyles.micro11Bold), reason: id);
          _expectFigtree(style, size: 11, weight: FontWeight.w700, reason: id);
        } else {
          expect(style, same(AppTextStyles.avatarCount), reason: id);
          _expectFigtree(style, size: 10, weight: FontWeight.w700, reason: id);
        }
        // Inicial centralizada (display: flex; center; center).
        expect(neo.child, isA<Center>(), reason: id);
      }
      expect(AppColors.lavender.toARGB32(), colors[0]);
      expect(AppColors.leaf.toARGB32(), colors[1]);
    },
  );

  testWidgets(
    '9.4 título: Bricolage22 22/800/1 ls −0,5 tinta + InstrumentSerif itálico 36/400/0,95 ls −0,4 tinta; subtítulo Figtree 13/500 #5B544B',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final lines = tester
          .widgetList<AppText>(
            find.descendant(
              of: find.byKey(const ValueKey('club.title')),
              matching: find.byType(AppText),
            ),
          )
          .map((w) => (w.span as TextSpan).style!)
          .toList();
      expect(lines, hasLength(2));
      expect(lines[0], same(AppTextStyles.clubTitle));
      _expectTypography(
        lines[0],
        family: 'Bricolage22', // opsz = tamanho (22)
        fallback: ['Bricolage22Ext', 'Bricolage22Vi'],
        size: 22,
        weight: FontWeight.w800,
        height: 1,
        letterSpacing: -0.5,
        color: _ink,
      );
      expect(lines[1], same(AppTextStyles.clubSerif));
      _expectTypography(
        lines[1],
        family: 'InstrumentSerif',
        fallback: ['InstrumentSerifExt'],
        size: 36,
        weight: FontWeight.w400,
        height: 0.95,
        letterSpacing: -0.4,
        color: _ink,
        fontStyle: FontStyle.italic,
      );
      final sub = _styleOf(tester, 'club.subtitle');
      expect(sub, same(AppTextStyles.body13Muted));
      _expectFigtree(sub, size: 13, weight: FontWeight.w500, color: _muted);
    },
  );

  testWidgets(
    '9.5 trilho: borda 1,5 tinta, raio 999, recorte, sem fundo próprio; hachura #EFE6D4 / #FFFAF1 na padding box; preenchimento #FFC1C6 com borda SÓ à direita (1,5 tinta), sem raio; marcador #FED170 borda 1,5 raio 12 + Bricolage12 11/800 tinta; legendas Figtree 12/600 #5B544B × 12/700 tinta',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final bar = _neoBox(tester, 'club.progressBar');
      expect(bar.color, isNull); // o fundo é a hachura
      expect(bar.clip, isTrue);
      expect(bar.shadow, isNull);
      _expectInkBox(
        _decorationOf(tester, 'club.progressBar'),
        color: null,
        radius: BorderRadius.circular(999),
      );
      final clip = tester.widget<ClipRRect>(
        find.descendant(
          of: find.byKey(const ValueKey('club.progressBar')),
          matching: find.byType(ClipRRect),
        ),
      );
      expect(clip.borderRadius, BorderRadius.circular(999 - 1.5));
      final hatchFinder = find.descendant(
        of: find.byKey(const ValueKey('club.progressBar')),
        matching: find.byWidgetPredicate(
          (w) => w is CustomPaint && w.painter is HatchPainter,
        ),
      );
      final hatch =
          tester.widget<CustomPaint>(hatchFinder).painter! as HatchPainter;
      expect(hatch.stripe.toARGB32(), 0xFFEFE6D4);
      expect(hatch.stripe, AppColors.hatch);
      expect(hatch.base.toARGB32(), _surface);
      // A hachura cobre a padding box inteira (origem no canto interno superior esquerdo).
      final barRect = tester.getRect(
        find.byKey(const ValueKey('club.progressBar')),
      );
      expect(tester.getRect(hatchFinder), barRect.deflate(1.5));

      final fill = _decorationOf(tester, 'club.progressFill');
      expect(fill.color!.toARGB32(), _blush);
      expect(fill.borderRadius, isNull);
      expect(fill.boxShadow, isNull);
      final border = fill.border! as Border;
      expect(border.right, const BorderSide(width: 1.5, color: AppColors.ink));
      expect(border.right.color.toARGB32(), _ink);
      expect(
        (border.top, border.bottom, border.left),
        (BorderSide.none, BorderSide.none, BorderSide.none),
      );

      final marker = _neoBox(tester, 'club.youMarker');
      expect((marker.width, marker.height), (24.0, 24.0));
      _expectInkBox(
        _decorationOf(tester, 'club.youMarker'),
        color: _sun,
        radius: BorderRadius.circular(12),
      );
      final m = _styleOf(tester, 'club.youMarker');
      expect(m, same(AppTextStyles.markerInitial));
      _expectTypography(
        m,
        family: 'Bricolage12', // 11 px usa a instância opsz 12 (o eixo começa em 12)
        fallback: ['Bricolage12Ext', 'Bricolage12Vi'],
        size: 11,
        weight: FontWeight.w800,
        height: 1.2,
        letterSpacing: 0,
        color: _ink,
      );

      final group = _styleOf(tester, 'club.groupLabel');
      expect(group, same(AppTextStyles.caption12Muted));
      _expectFigtree(group, size: 12, weight: FontWeight.w600, color: _muted);
      final you = _styleOf(tester, 'club.youLabel');
      expect(you, same(AppTextStyles.label12Bold));
      _expectFigtree(you, size: 12, weight: FontWeight.w700);
    },
  );

  testWidgets(
    '9.6 CTA tinta sem borda, raio 999; ic_message_circle 18 (traço #F7F0E3 1,8 no viewBox 24), sem colorFilter; rótulo Figtree 14/700 #F7F0E3; badge #FF552E sem borda, mín. 20 × 20, padding 0 6, texto Figtree 11/700 tinta',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final cta = _decorationOf(tester, 'club.cta');
      expect(cta.color!.toARGB32(), _ink);
      expect(cta.border, isNull);
      expect(cta.borderRadius, BorderRadius.circular(999));
      expect(cta.boxShadow, isNull);

      final iconFinder = find.byKey(const ValueKey('club.cta.icon'));
      final icon = tester.widget<AppSvg>(iconFinder);
      expect((icon.asset, icon.size), (AppIcons.messageCircle, 18.0));
      expect(icon.asset, 'assets/icons/ic_message_circle.svg');
      final picture = tester.widget<SvgPicture>(
        find.descendant(of: iconFinder, matching: find.byType(SvgPicture)),
      );
      expect(picture.colorFilter, isNull); // a cor está no próprio SVG
      final source = (await tester.runAsync(
        () => rootBundle.loadString(AppIcons.messageCircle),
      ))!;
      expect(source, contains('viewBox="0 0 24 24"'));
      expect(source, contains('stroke="#F7F0E3"'));
      expect(source, contains('stroke-width="1.8"'));
      expect(source, contains('fill="none"'));
      expect(
        source,
        contains('d="M21 12a8 8 0 0 1-11.6 7.1L4 20l1-4.6A8 8 0 1 1 21 12z"'),
      );
      debugPrint('[ícone] ${AppIcons.messageCircle}: $source');

      final label = _styleOf(tester, 'club.cta.label');
      expect(label, same(AppTextStyles.cta14OnInk));
      _expectFigtree(
        label,
        size: 14,
        weight: FontWeight.w700,
        color: AppColors.paper.toARGB32(),
      );

      final badge = tester.widget<CountBadge>(
        find.byKey(const ValueKey('club.cta.badge')),
      );
      expect(
        (badge.minWidth, badge.height, badge.horizontalPadding),
        (20.0, 20.0, 6.0),
      );
      expect(badge.background.toARGB32(), _flame);
      expect(badge.border, isNull);
      expect(badge.style, same(AppTextStyles.micro11Bold));
      _expectFigtree(badge.style, size: 11, weight: FontWeight.w700);
      final d = _decorationOf(tester, 'club.cta.badge');
      expect(d.color!.toARGB32(), _flame);
      expect(d.border, isNull);
      expect(d.borderRadius, BorderRadius.circular(999));
    },
  );

  testWidgets(
    '9.7 canhoto: ENCONTRO Figtree 10/700 ls 1 (0,1em) #4A2F33; QUI/SET Figtree 12/700 ls 0,96 (0,08em) tinta; "24" Bricolage42 42/800/0,95 ls −1,5 tinta; pílula 20h #FFFAF1 borda 1,5 raio 999 padding 4 10 + Figtree 13/700 tinta',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final label = _styleOf(tester, 'club.stub.label');
      expect(label, same(AppTextStyles.stubLabel));
      _expectFigtree(
        label,
        size: 10,
        weight: FontWeight.w700,
        letterSpacing: 0.1 * 10,
        color: 0xFF4A2F33,
      );
      expect(AppColors.stubLabel.toARGB32(), 0xFF4A2F33);
      for (final id in ['club.stub.weekday', 'club.stub.month']) {
        final s = _styleOf(tester, id);
        expect(s, same(AppTextStyles.stubMeta), reason: id);
        _expectFigtree(
          s,
          size: 12,
          weight: FontWeight.w700,
          letterSpacing: 0.96,
          reason: id,
        );
        expect(s.letterSpacing, moreOrLessEquals(0.08 * 12, epsilon: 1e-12));
      }
      final day = _styleOf(tester, 'club.stub.day');
      expect(day, same(AppTextStyles.stubDay));
      _expectTypography(
        day,
        family: 'Bricolage42',
        fallback: ['Bricolage42Ext', 'Bricolage42Vi'],
        size: 42,
        weight: FontWeight.w800,
        height: 0.95,
        letterSpacing: -1.5,
        color: _ink,
      );
      final time = tester.widget<Pill>(
        find.byKey(const ValueKey('club.stub.time')),
      );
      expect(
        time.padding,
        const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      );
      _expectInkBox(
        _decorationOf(tester, 'club.stub.time'),
        color: _surface,
        radius: BorderRadius.circular(999),
      );
      final hour = _styleOf(tester, 'club.stub.time');
      expect(hour, same(AppTextStyles.body13Bold));
      _expectFigtree(hour, size: 13, weight: FontWeight.w700);
    },
  );

  testWidgets(
    'canvas (TestRecordingPaintingContext): só 3 recortes, todos suavizados — seção (raio 28), ticket (padding box, 26,5) e trilho (997,5 → 4,5); sem saveLayer; ordem de pintura do arquivo, com os entalhes por último',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final calls = _paintCalls(
        tester.renderObject(find.byType(BookClubTicket)),
      );
      final origin = tester.getTopLeft(find.byType(BookClubTicket));
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
      final section = rel('club');
      _expectShape(
        clips[0].positionalArguments.single as Object,
        RRect.fromRectAndRadius(section, const Radius.circular(28)),
        reason: 'seção',
      );
      _expectShape(
        clips[0].positionalArguments.single as Object,
        RRect.fromLTRBR(0, 0, 350, 266.6, const Radius.circular(28)),
        epsilon: 1e-3,
        reason: 'seção (tabela)',
      );
      _expectShape(
        clips[1].positionalArguments.single as Object,
        RRect.fromRectAndRadius(
          section.deflate(1.5),
          const Radius.circular(26.5),
        ),
        reason: 'ticket',
      );
      final barInner = rel('club.progressBar').deflate(1.5);
      final barClip = clips[2].positionalArguments.single as RRect;
      _expectShape(
        barClip,
        RRect.fromRectAndRadius(barInner, const Radius.circular(997.5)),
        reason: 'trilho',
      );
      // O Skia normaliza o raio para metade do menor lado: 9 / 2 = 4,5 (= 6 − 1,5, a curva interna do CSS).
      final normalized = barClip.scaleRadii();
      expect(normalized.tlRadiusX, moreOrLessEquals(4.5, epsilon: 1e-9));
      expect(normalized.brRadiusY, moreOrLessEquals(4.5, epsilon: 1e-9));

      final names = calls.map((c) => c.invocation.memberName).toSet();
      for (final forbidden in [#saveLayer, #rotate, #skew, #scale, #clipPath]) {
        expect(names.contains(forbidden), isFalse, reason: '$forbidden');
      }
      // A única transformação é a escala viewBox 24 → 18 do balão (0,75).
      final transforms = [
        for (final c in calls)
          if (c.invocation.memberName == #transform)
            c.invocation.positionalArguments.single as List<double>,
      ];
      expect(transforms, hasLength(1));
      expect(transforms.single, [
        0.75, 0, 0, 0, //
        0, 0.75, 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1,
      ]);

      // Ordem de pintura das formas (textos e o SVG à parte): ticket → pílula → avatares A J L +8 → trilho
      // (borda, recorte, hachura, preenchimento, borda direita) → marcador → CTA → badge → canhoto (fundo + 59
      // traços) → pílula 20h → entalhes.
      final draws = [
        for (final c in calls)
          if (!_stateMethods.contains(c.invocation.memberName) &&
              c.invocation.memberName != #drawParagraph &&
              c.invocation.memberName != #drawPicture)
            _drawLabel(c.invocation),
      ];
      const ink = 'drawDRRect 0xFF1A1714';
      final expected = [
        'drawRRect 0xFFFFFAF1', ink, // ticket
        'drawRRect 0xFFFFC1C6', ink, // pílula
        'drawRRect 0xFFB6ACE4', ink, // A
        'drawRRect 0xFFABCF82', ink, // J
        'drawRRect 0xFFFFC1C6', ink, // L
        'drawRRect 0xFFFFFAF1', ink, // +8
        ink, // trilho: só a borda (sem fundo próprio)
        'drawRect shader', // hachura
        'drawRect 0xFFFFC1C6', // preenchimento
        'drawPath 0xFF1A1714', // borda direita do preenchimento
        'drawRRect 0xFFFED170', ink, // marcador
        'drawRRect 0xFF1A1714', // CTA
        'drawRRect 0xFFFF552E', // badge
        'drawRect 0xFFFFC1C6', // canhoto
        for (var i = 0; i < 59; i++) 'drawRect 0xFF1A1714', // perfuração
        'drawRRect 0xFFFFFAF1', ink, // pílula 20h
        'drawRRect 0xFFF7F0E3', ink, // entalhe de cima
        'drawRRect 0xFFF7F0E3', ink, // entalhe de baixo
      ];
      expect(draws, expected);
      // 17 textos pintados (o título são 2 parágrafos) e 1 SVG.
      expect(
        calls.where((c) => c.invocation.memberName == #drawParagraph),
        hasLength(18),
      );
      expect(
        calls.where((c) => c.invocation.memberName == #drawPicture),
        hasLength(1),
      );

      // Os entalhes são as últimas formas, DENTRO do recorte da seção e FORA do recorte do ticket.
      final restoreAfterTicket = calls.lastIndexWhere(
        (c) => c.invocation.memberName == #restore,
        calls.length - 2,
      );
      final notchDraws = [
        for (final (i, c) in calls.indexed)
          if (c.invocation.memberName == #drawRRect &&
              (c.invocation.positionalArguments[1] as Paint).color.toARGB32() ==
                  _paper)
            i,
      ];
      expect(notchDraws, hasLength(2));
      expect(notchDraws.first, greaterThan(restoreAfterTicket));
      expect(calls.last.invocation.memberName, #restore);

      // Perfuração: 59 retângulos 1,5 × 3 a partir do topo do canhoto, com o passo do Chromium.
      final starts = chromiumDashStarts(length: 263.6, thickness: 1.5);
      final dashRects = [
        for (final c in calls)
          if (c.invocation.memberName == #drawRect &&
              (c.invocation.positionalArguments[1] as Paint).color.toARGB32() ==
                  _ink)
            c.invocation.positionalArguments[0] as Rect,
      ];
      expect(dashRects, hasLength(59));
      for (final (i, r) in dashRects.indexed) {
        // Coordenadas locais do CustomPaint (o canvas foi transladado para o topo esquerdo do canhoto).
        _expectShape(
          r,
          Rect.fromLTWH(0, starts[i], 1.5, 3),
          epsilon: 1e-6,
          reason: 'traço $i',
        );
      }
      // Preenchimento: fundo até a metade da borda direita (o Flutter insere o fundo 0,75 sob a borda) e a
      // borda direita como caminho de 1,5 na ponta de 117,72.
      final fill = rel('club.progressFill');
      expect(fill.width, moreOrLessEquals(117.72, epsilon: 1e-9));
      final path =
          calls
                  .firstWhere((c) => c.invocation.memberName == #drawPath)
                  .invocation
                  .positionalArguments[0]
              as Path;
      // `Path` guarda os pontos em float32 (137,22 → 137,22000122).
      _expectShape(
        path.getBounds(),
        Rect.fromLTRB(fill.right - 1.5, fill.top, fill.right, fill.bottom),
        epsilon: 1e-5,
        reason: 'borda direita do preenchimento',
      );
    },
  );

  testWidgets(
    'pixels @3x (cor EXATA): fundo, bordas e canto do ticket; perfuração (traço e vão); entalhes (miolo, anel, metade recortada, borda interrompida); pílula; avatares e sobreposição; trilho, preenchimento, hachura e marcador; CTA, badge, 20h; sem sombra',
    (tester) async {
      setCanvasView(tester);
      await _pumpCanvas(tester);
      final (rgba, width) = await _capture(tester);
      final o = tester.getTopLeft(find.byKey(const ValueKey('club')));
      Offset at(double x, double y) => o + Offset(x, y);
      // Perfuração: traço i começa em 1,5 + i × (3 + vão) a partir do topo da seção.
      final starts = chromiumDashStarts(length: 263.6, thickness: 1.5);
      final gap = starts[1] - 3;
      // Hachura: padding box do trilho em (21; 154,2) da seção; t = (u + v)/√2, listra se t mod 7 < 3.
      Offset hatch(double t, double v) =>
          at(21 + t * math.sqrt2 - v, 154.2 + v);
      final checks = <String, (Offset, int)>{
        'ticket: fundo': (at(130, 45), _surface),
        'ticket: borda de cima': (at(100, 0.75), _ink),
        'ticket: borda esquerda': (at(0.75, 130), _ink),
        'ticket: borda direita (sobre o canhoto)': (at(349.25, 130), _ink),
        'fora do canto de raio 28 (papel da tela)': (at(2, 2), _paper),
        'canto: meio do anel da borda a 45°': (
          at(28 - 27.25 / math.sqrt2, 28 - 27.25 / math.sqrt2),
          _ink,
        ),
        'canhoto: fundo': (at(300, 30), _blush),
        'perfuração: traço 30': (at(257.25, 1.5 + starts[30] + 1.5), _ink),
        'perfuração: vão depois do traço 30 (mostra o fundo)': (
          at(257.25, 1.5 + starts[30] + 3 + gap / 2),
          _blush,
        ),
        'entalhe de cima: miolo (por cima da perfuração)': (
          at(257.25, 7),
          _paper,
        ),
        'entalhe de cima: anel': (at(257.25, 12.25), _ink),
        'entalhe de cima: metade de fora recortada pela seção': (
          at(257.25, -12.25),
          _paper,
        ),
        'borda de cima do ticket interrompida pelo entalhe': (
          at(250, 0.75),
          _paper,
        ),
        'entalhe de baixo: miolo': (at(257.25, 266.6 - 7), _paper),
        'entalhe de baixo: anel': (at(257.25, 266.6 - 12.25), _ink),
        'entalhe de baixo: metade de fora recortada pela seção': (
          at(257.25, 266.6 + 12.25),
          _paper,
        ),
        'pílula: fundo': (at(24, 33.2), _blush),
        'pílula: borda de cima': (at(60, 20.25), _ink),
        'avatar A': (at(164, 33.2), 0xFFB6ACE4),
        'avatar J (por cima do A)': (at(182, 33.2), 0xFFABCF82),
        'avatar L': (at(200, 33.2), _blush),
        'avatar +8': (at(218, 33.2), _surface),
        'borda esquerda do J pintada sobre o A': (at(179.25, 33.2), _ink),
        'A logo antes da borda do J': (at(177.9, 33.2), 0xFFB6ACE4),
        'trilho: borda de cima': (at(100, 153.45), _ink),
        'trilho: preenchimento': (at(80, 158.7), _blush),
        'trilho: borda direita do preenchimento': (at(137.97, 158.7), _ink),
        'hachura: listra (t = 134,5)': (hatch(134.5, 4.5), 0xFFEFE6D4),
        'hachura: base (t = 138)': (hatch(138, 4.5), _surface),
        'hachura: listra seguinte (t = 141,5)': (hatch(141.5, 2), 0xFFEFE6D4),
        'hachura: base seguinte (t = 145)': (hatch(145, 7), _surface),
        'marcador: fundo': (at(147.5, 158.7), _sun),
        'marcador: borda de cima, acima do trilho': (
          at(156.52, 158.7 - 11.25),
          _ink,
        ),
        'marcador cobre a borda do trilho': (at(156.52, 153.45), _sun),
        'CTA: ponta esquerda': (at(30, 224.1), _ink),
        'CTA: acima do rótulo': (at(130, 205), _ink),
        'badge': (at(189.5, 224.1), _flame),
        'pílula 20h: fundo': (at(285, 185.65), _surface),
        'sem sombra (abaixo, à direita)': (at(345, 268.5), _paper),
        'sem sombra (à direita)': (at(352, 130), _paper),
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

  testWidgets(
    'dados nos extremos: progresso do grupo 0 → preenchimento com o piso do border-box (1,5 = a própria borda direita: fio de tinta no começo do trilho); 1 → os 218 inteiros; sem avatares → grupo 0 × 0',
    (tester) async {
      setCanvasView(tester);
      final base = const HomeMockRepository().snapshot(
        HomeMockRepository.referenceNow,
      );
      final c = base.club;
      BookClub club(double group, {List<ClubParticipant>? shown, int? count}) =>
          BookClub(
            id: c.id,
            namePrefix: c.namePrefix,
            nameHighlight: c.nameHighlight,
            book: c.book,
            untilChapter: c.untilChapter,
            shownParticipants: shown ?? c.shownParticipants,
            participantsCount: count ?? c.participantsCount,
            groupProgress: group,
            userProgress: c.userProgress,
            userInitial: c.userInitial,
            unreadMessages: c.unreadMessages,
            nextMeeting: c.nextMeeting,
          );
      Future<void> pumpWith(BookClub data) async {
        await precacheAppIcons(tester);
        await tester.pumpWidget(
          ProviderScope(
            key: UniqueKey(),
            overrides: [
              homeSnapshotProvider.overrideWithValue(
                HomeSnapshot(
                  now: base.now,
                  user: base.user,
                  continueReading: base.continueReading,
                  alsoReading: base.alsoReading,
                  readingDay: base.readingDay,
                  forYou: base.forYou,
                  club: data,
                  recent: base.recent,
                ),
              ),
            ],
            child: const RepaintBoundary(
              key: goldenRootKey,
              child: App.forTests(),
            ),
          ),
        );
        await tester.pumpAndSettle();
      }

      Rect rect(String id) => tester.getRect(find.byKey(ValueKey<String>(id)));

      // 0 %: 54 % × 218 viraria 0, mas a caixa border-box não fica mais estreita que a borda (1,5).
      await pumpWith(club(0));
      final inner = rect('club.progressBar').deflate(1.5);
      final fill0 = rect('club.progressFill');
      expect(fill0.left, inner.left);
      expect(fill0.width, moreOrLessEquals(1.5, epsilon: 1e-9));
      expect(fill0.height, 9);
      final (rgba, width) = await _capture(tester);
      // No meio da altura, a 0,83 da borda interna esquerda (dentro do fio e do recorte de raio 4,5): tinta;
      // 2,5 à direita, já na hachura (t = (2,5 + 4,5)/√2 = 4,95 → base).
      final mid = inner.center.dy;
      final wire = _argbAt(rgba, width, Offset(inner.left + 0.83, mid));
      final after = _argbAt(rgba, width, Offset(inner.left + 2.5, mid));
      debugPrint(
        '[extremos] progresso 0: preenchimento ${fill0.size} · fio ${_hex(wire)} · hachura ${_hex(after)}',
      );
      expect(wire, _ink);
      expect(after, _surface);

      // 100 %: o preenchimento ocupa a padding box inteira.
      await pumpWith(club(1));
      final fill1 = rect('club.progressFill');
      final inner1 = rect('club.progressBar').deflate(1.5);
      expect(fill1.width, moreOrLessEquals(218, epsilon: 1e-9));
      expect(fill1.right, moreOrLessEquals(inner1.right, epsilon: 1e-9));
      // Acima do piso, a fração é a do arquivo: 0,54 × 218.
      await pumpWith(club(0.54));
      expect(
        rect('club.progressFill').width,
        moreOrLessEquals(117.72, epsilon: 1e-9),
      );

      // Sem avatares: o flex vazio mede 0 × 0 e a linha continua com a altura da pílula.
      await pumpWith(club(0.54, shown: const [], count: 0));
      expect(
        tester.getSize(find.byKey(const ValueKey('club.avatars'))),
        Size.zero,
      );
      expect(find.byKey(const ValueKey('club.avatar0')), findsNothing);
      expect(rect('club.topRow').height, moreOrLessEquals(27.4, epsilon: 1e-3));
    },
  );
}

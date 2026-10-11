import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:app_leitura/core/design_system/painters/chromium_dash.dart';
import 'package:app_leitura/core/design_system/painters/goal_dial_painter.dart';
import 'package:app_leitura/core/design_system/painters/hatch_painter.dart';
import 'package:app_leitura/core/design_system/painters/ring_progress_painter.dart';
import 'package:app_leitura/core/design_system/painters/top_border_crescent_painter.dart';
import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/tokens/app_typography.dart';
import 'package:app_leitura/core/design_system/widgets/neo_box.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/capture.dart';
import '../support/geometry.dart';
import '../support/load_fonts.dart';

List<RecordedInvocation> _record(CustomPainter painter, Size size) {
  final canvas = TestRecordingCanvas();
  painter.paint(canvas, size);
  return canvas.invocations;
}

String _name(RecordedInvocation call) => call.invocation.memberName
    .toString()
    .replaceAll(RegExp(r'Symbol\("|"\)'), '');

List<Object?> _args(RecordedInvocation call) =>
    call.invocation.positionalArguments;

/// Pixels RGBA de um pintor desenhado num PictureRecorder em [scale]×.
Future<(Uint8List, int, int)> _rasterize(
  CustomPainter painter,
  Size size,
  double scale,
) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder)..scale(scale);
  painter.paint(canvas, size);
  final width = (size.width * scale).ceil(),
      height = (size.height * scale).ceil();
  final image = recorder.endRecording().toImageSync(width, height);
  final data = await image.toByteData(
    format: ui.ImageByteFormat.rawStraightRgba,
  );
  image.dispose();
  return (data!.buffer.asUint8List(), width, height);
}

Color _pixel(Uint8List rgba, int width, int x, int y) {
  final i = (y * width + x) * 4;
  return Color.fromARGB(rgba[i + 3], rgba[i], rgba[i + 1], rgba[i + 2]);
}

Matcher _isColor(Color expected, {int tolerance = 2}) => predicate<Color>(
  (c) {
    int ch(double v) => (v * 255).round();
    return (ch(c.r) - ch(expected.r)).abs() <= tolerance &&
        (ch(c.g) - ch(expected.g)).abs() <= tolerance &&
        (ch(c.b) - ch(expected.b)).abs() <= tolerance &&
        (ch(c.a) - ch(expected.a)).abs() <= tolerance;
  },
  'cor ≈ 0x${expected.toARGB32().toRadixString(16).toUpperCase()} (±$tolerance por canal)',
);

// ── Cenas alinhadas à grade @3x da referência ────────────────────────────────────────────────
// A caixa da cena começa e termina em pixels físicos inteiros da referência @3x; os filhos são posicionados em
// coordenadas ABSOLUTAS do canvas da prancha 01 (390×2650; até a T03, o 390×2390 da v1). Assim o golden é comparável
// 1:1 com o recorte da referência na mesma caixa (tools: ver relatório da F01).

const _kScale = 3.0;
const _goldenKey = Key('golden');

/// Caixa em pixels físicos inteiros da referência @3x que contém [r].
({int x0, int y0, int x1, int y1}) _gridPx(Rect r) => (
  x0: (r.left * _kScale).floor(),
  y0: (r.top * _kScale).floor(),
  x1: (r.right * _kScale).ceil(),
  y1: (r.bottom * _kScale).ceil(),
);

/// A mesma caixa em px lógicos. Largura/altura saem da DIFERENÇA inteira (N/3 × 3 == N em double) e
/// ficam guardadas à parte — um `Rect` guarda LTRB e recalcula a altura como diferença de dois valores
/// fracionários, o que pode passar de N/3 por 1 ulp e gerar uma linha de pixels a mais na captura.
({double left, double top, double width, double height}) _gridBox(Rect r) {
  final p = _gridPx(r);
  return (
    left: p.x0 / _kScale,
    top: p.y0 / _kScale,
    width: (p.x1 - p.x0) / _kScale,
    height: (p.y1 - p.y0) / _kScale,
  );
}

Widget _scene(
  Rect region,
  Color background,
  List<Widget> Function(Widget Function(Rect, Widget) at) build,
) {
  final box = _gridBox(region);
  Widget at(Rect r, Widget child) => Positioned(
    left: r.left - box.left,
    top: r.top - box.top,
    width: r.width,
    height: r.height,
    child: child,
  );
  return Directionality(
    textDirection: TextDirection.ltr,
    child: Align(
      alignment: Alignment.topLeft,
      child: RepaintBoundary(
        key: _goldenKey,
        child: SizedBox(
          width: box.width,
          height: box.height,
          child: ClipRect(
            child: ColoredBox(
              color: background,
              child: Stack(children: build(at)),
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> _expectSceneGolden(
  WidgetTester tester,
  String name,
  Rect region,
) async {
  final p = _gridPx(region);
  debugPrint('[cena] $name: caixa @3x = (${p.x0}, ${p.y0}, ${p.x1}, ${p.y1})');
  await expectLater(
    await captureAt(tester, find.byKey(_goldenKey)),
    matchesGoldenFile('../golden/goldens/$name@3x.png'),
  );
}

/// Barras da semana (valores do arquivo: colunas de (280 − 6 × 8)/7, alturas D-10).
const _kBarHeights = [43.0, 60.0, 40.0, 30.0, 51.0, 73.0, 24.0];
const double _kColumn = (280 - 6 * 8) / 7;

Widget _weekBar(int i) {
  final today = i == 6;
  final border = today ? 1.5 : 1.2;
  return NeoBox(
    width: _kColumn,
    height: 80,
    color: AppColors.surface,
    border: BorderSide(width: border, color: AppColors.ink),
    radius: BorderRadius.circular(999),
    clip: true,
    child: Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(
          painter: HatchPainter(
            stripe: today ? AppColors.hatchToday : AppColors.hatch,
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: _kBarHeights[i],
          child: CustomPaint(
            painter: TopBorderCrescentPainter(
              fill: today ? AppColors.flame : AppColors.lavender,
            ),
          ),
        ),
      ],
    ),
  );
}

void main() {
  setUpAll(loadAppFonts);

  group('1.6.1 HatchPainter', () {
    test(
      'amostragem de pixels sobre a diagonal (30,742 × 77,6 em 3×)',
      () async {
        const painter = HatchPainter(stripe: AppColors.hatch);
        final (rgba, width, _) = await _rasterize(
          painter,
          const Size(30.742, 77.6),
          3,
        );
        Color at(double x, double y) =>
            _pixel(rgba, width, (x * 3).floor(), (y * 3).floor());
        // t = (x + y)/√2: t = 1 → listra; t = 5 → base; t = 7,5 → listra (novo período).
        expect(at(0.707, 0.707), _isColor(AppColors.hatch), reason: 't = 1');
        expect(at(3.536, 3.536), _isColor(AppColors.surface), reason: 't = 5');
        expect(at(5.303, 5.303), _isColor(AppColors.hatch), reason: 't = 7,5');
        // Listras "/": t constante ao longo de (x + d, y − d).
        // x + y = 7 → t = 4,95 → base; x + y = 12 → t = 8,49 (1,49 no novo período) → listra.
        for (final (x, y) in [(1.0, 6.0), (3.5, 3.5), (6.0, 1.0)]) {
          expect(
            at(x, y),
            _isColor(AppColors.surface),
            reason: 't = 4,95 em ($x, $y)',
          );
        }
        for (final (x, y) in [(2.0, 10.0), (6.0, 6.0), (10.0, 2.0)]) {
          expect(
            at(x, y),
            _isColor(AppColors.hatch),
            reason: 't = 8,49 em ($x, $y)',
          );
        }
      },
    );

    test('base padrão = surface; shouldRepaint só quando as cores mudam', () {
      expect(
        const HatchPainter(stripe: AppColors.hatch).base,
        AppColors.surface,
      );
      const a = HatchPainter(stripe: AppColors.hatch);
      expect(
        a.shouldRepaint(const HatchPainter(stripe: AppColors.hatch)),
        isFalse,
      );
      expect(
        a.shouldRepaint(const HatchPainter(stripe: AppColors.hatchToday)),
        isTrue,
      );
    });
  });

  group('1.6.2 chromiumDashStarts / ChromiumDashPainter', () {
    void expectDashes(double length, int count, double gap) {
      final starts = chromiumDashStarts(length: length, thickness: 1.5);
      final gotGap = starts[1] - starts[0] - 3;
      debugPrint(
        '[dash] $length → ${starts.length} traços, vão ${gotGap.toStringAsFixed(4)}, último termina em ${starts.last + 3}',
      );
      expect(starts, hasLength(count));
      expect(starts.first, 0);
      expect(gotGap, moreOrLessEquals(gap, epsilon: 0.00005));
      expect(starts.last + 3, moreOrLessEquals(length, epsilon: 1e-9));
      for (var i = 1; i < starts.length; i++) {
        expect(
          starts[i] - starts[i - 1],
          moreOrLessEquals(3 + gotGap, epsilon: 1e-9),
        );
      }
    }

    test(
      'perfuração do ticket: 263,6 → 59 traços, vão 1,4931',
      () => expectDashes(263.6, 59, 1.4931),
    );
    test(
      'linha da meta: 288 → 64 traços, vão 1,5238',
      () => expectDashes(288, 64, 1.5238),
    );

    test('pintor desenha um retângulo de 3 × 1,5 (ou 1,5 × 3) por traço, na cor dada', () {
      final horizontal = _record(
        const ChromiumDashPainter(
          axis: Axis.horizontal,
          color: AppColors.goalLine,
        ),
        const Size(288, 1.5),
      );
      final starts = chromiumDashStarts(length: 288, thickness: 1.5);
      expect(horizontal, hasLength(64));
      for (var i = 0; i < 64; i++) {
        expect(_name(horizontal[i]), 'drawRect');
        expect(_args(horizontal[i])[0], Rect.fromLTWH(starts[i], 0, 3, 1.5));
        expect(
          (_args(horizontal[i])[1]! as Paint).color.toARGB32(),
          AppColors.goalLine.toARGB32(),
        );
      }
      final vertical = _record(
        const ChromiumDashPainter(axis: Axis.vertical),
        const Size(1.5, 263.6),
      );
      final vStarts = chromiumDashStarts(length: 263.6, thickness: 1.5);
      expect(vertical, hasLength(59));
      expect(_args(vertical.last)[0], Rect.fromLTWH(0, vStarts.last, 1.5, 3));
      expect(
        (_args(vertical.first)[1]! as Paint).color.toARGB32(),
        AppColors.ink.toARGB32(),
      );
    });
  });

  group('1.6.3 RingProgressPainter', () {
    test('trilho r 18 / traço 5 + arco do topo, horário, ponta redonda', () {
      final calls = _record(
        const RingProgressPainter(progress: 0.34),
        const Size(46, 46),
      );
      expect(calls.map(_name), ['drawCircle', 'drawArc']);
      expect(_args(calls[0])[0], const Offset(23, 23));
      expect(_args(calls[0])[1], 18);
      final track = _args(calls[0])[2]! as Paint;
      expect(
        (track.style, track.strokeWidth, track.color.toARGB32()),
        (PaintingStyle.stroke, 5.0, AppColors.ringTrack.toARGB32()),
      );
      final arc = _args(calls[1]);
      expect(arc[0], Rect.fromCircle(center: const Offset(23, 23), radius: 18));
      expect(arc[1], -math.pi / 2);
      expect(arc[2], moreOrLessEquals(2 * math.pi * 0.34, epsilon: 1e-12));
      expect(arc[3], isFalse);
      final ink = arc[4]! as Paint;
      expect(
        (ink.style, ink.strokeWidth, ink.strokeCap, ink.color.toARGB32()),
        (PaintingStyle.stroke, 5.0, StrokeCap.round, AppColors.ink.toARGB32()),
      );
      expect(
        _record(
          const RingProgressPainter(progress: 0),
          const Size(46, 46),
        ).map(_name),
        ['drawCircle'],
      );
    });

    test('equivalência com o SVG do arquivo (stroke-dasharray 38.5 / 91.6 de 113.1): Δ arco ≤ 0,05 px', () {
      for (final (progress, dash) in [(0.34, 38.5), (0.81, 91.6)]) {
        final arc = 2 * math.pi * RingProgressPainter.radius * progress;
        debugPrint(
          '[anel] ${(progress * 100).round()}%: arco ${arc.toStringAsFixed(3)} × SVG $dash (Δ ${(arc - dash).abs().toStringAsFixed(3)})',
        );
        expect((arc - dash).abs(), lessThanOrEqualTo(0.05));
      }
      expect(
        2 * math.pi * RingProgressPainter.radius,
        moreOrLessEquals(113.1, epsilon: 0.01),
      );
    });

    // Os dois anéis da v1 (34 % e 81 %); a prancha 01 tem só o do Orgulho (81 %, `alsoReading.card2.ring` — o 1º
    // cartão é o papel com o "play", D-253): as duas cenas ficam alinhadas a ele (o de 34 % segue como regressão do
    // pintor, sem recorte na prancha).
    for (final (id, progress, label) in [
      ('alsoReading.card2.ring', 0.34, '34%'),
      ('alsoReading.card2.ring', 0.81, '81%'),
    ]) {
      testWidgets(
        'golden isolado ${(progress * 100).round()}% (cena alinhada a $id, com o rótulo)',
        (tester) async {
          final rect = ref01(id).rect;
          await tester.pumpWidget(
            _scene(
              rect,
              AppColors.surface,
              (at) => [
                at(
                  rect,
                  CustomPaint(painter: RingProgressPainter(progress: progress)),
                ),
                at(
                  rect,
                  Center(
                    child: AppText(label, style: AppTextStyles.micro11Bold),
                  ),
                ),
              ],
            ),
          );
          await _expectSceneGolden(
            tester,
            'ds_anel_${(progress * 100).round()}',
            rect,
          );
        },
      );
    }
  });

  group('1.6.4 GoalDialPainter', () {
    final calls = _record(
      const GoalDialPainter(progress: 0.6),
      const Size(112, 112),
    );

    test('ordem de pintura: face → marcações → arco → pino', () {
      expect(calls.map(_name).toList(), [
        'drawCircle', 'drawCircle', // face (preenchimento + traço)
        for (var i = 0; i < 31; i++) 'drawArc', // marcações
        'drawArc', // progresso
        'drawCircle', 'drawCircle', // pino (preenchimento + traço)
      ]);
      final face = _args(calls[0])[2]! as Paint,
          faceStroke = _args(calls[1])[2]! as Paint;
      expect(
        (
          _args(calls[0])[0],
          _args(calls[0])[1],
          face.color.toARGB32(),
          face.style,
        ),
        (
          const Offset(56, 56),
          54.0,
          AppColors.surface.toARGB32(),
          PaintingStyle.fill,
        ),
      );
      expect(
        (faceStroke.strokeWidth, faceStroke.color.toARGB32(), faceStroke.style),
        (1.5, AppColors.ink.toARGB32(), PaintingStyle.stroke),
      );
    });

    test('31 marcações: r 44, traço 2, dash 1,5 a cada 9,21, início às 3 h; a última com 0,16', () {
      final ticks = calls.sublist(2, 33);
      final circumference = 2 * math.pi * 44;
      for (var i = 0; i < 31; i++) {
        final a = _args(ticks[i]);
        expect(a[0], Rect.fromCircle(center: const Offset(56, 56), radius: 44));
        expect(a[1] as double, moreOrLessEquals(i * 9.21 / 44, epsilon: 1e-12));
        final paint = a[4]! as Paint;
        expect(
          (paint.strokeWidth, paint.strokeCap, paint.color.toARGB32()),
          (2.0, StrokeCap.butt, AppColors.dialTick.toARGB32()),
        );
        final length = (a[2] as double) * 44;
        if (i < 30) {
          expect(length, moreOrLessEquals(1.5, epsilon: 1e-9));
        } else {
          debugPrint(
            '[dial] última marcação: ${length.toStringAsFixed(3)} px (circunferência ${circumference.toStringAsFixed(3)})',
          );
          expect(length, moreOrLessEquals(0.16, epsilon: 0.005));
        }
      }
    });

    test('arco de progresso 0,6 e pino em (30,137; 91,597) — SVG do arquivo: 165.9 de 276.5 e (30.1; 91.6)', () {
      final arc = _args(calls[33]);
      expect(arc[1], -math.pi / 2);
      expect(
        arc[2] as double,
        moreOrLessEquals(2 * math.pi * 0.6, epsilon: 1e-12),
      );
      final paint = arc[4]! as Paint;
      expect(
        (paint.strokeWidth, paint.strokeCap, paint.color.toARGB32()),
        (10.0, StrokeCap.round, AppColors.ink.toARGB32()),
      );
      expect(((arc[2] as double) * 44 - 165.9).abs(), lessThanOrEqualTo(0.05));
      final knob = _args(calls[34])[0]! as Offset;
      debugPrint(
        '[dial] pino em (${knob.dx.toStringAsFixed(3)}; ${knob.dy.toStringAsFixed(3)})',
      );
      expect(knob.dx, moreOrLessEquals(30.137, epsilon: 0.05));
      expect(knob.dy, moreOrLessEquals(91.597, epsilon: 0.05));
      expect(_args(calls[34])[1], 6);
      expect(
        (_args(calls[34])[2]! as Paint).color.toARGB32(),
        AppColors.flame.toARGB32(),
      );
      expect(_args(calls[35])[0], knob);
      final knobStroke = _args(calls[35])[2]! as Paint;
      expect(
        (knobStroke.strokeWidth, knobStroke.color.toARGB32(), knobStroke.style),
        (1.5, AppColors.ink.toARGB32(), PaintingStyle.stroke),
      );
    });

    testWidgets(
      'golden isolado (cena alinhada a today.dial, com "18" e "de 30 min")',
      (tester) async {
        final dial = ref01('today.dial').rect;
        final value = ref01('today.dial.value').rect;
        final caption = ref01('today.dial.caption').rect;
        await tester.pumpWidget(
          _scene(
            dial,
            AppColors.sun,
            (at) => [
              at(
                dial,
                const CustomPaint(painter: GoalDialPainter(progress: 18 / 30)),
              ),
              at(value, AppText('18', style: AppTextStyles.dialValue)),
              at(
                caption,
                AppText('de 30 min', style: AppTextStyles.dialCaption),
              ),
            ],
          ),
        );
        await _expectSceneGolden(tester, 'ds_dial', dial);
      },
    );
  });

  group('1.6.5 TopBorderCrescentPainter', () {
    test('meia-lua: 1,5 no topo, afinando até 0 nas laterais; preenchimento por baixo', () {
      const size = Size(_kColumn - 2.4, 43);
      final calls = _record(
        const TopBorderCrescentPainter(fill: AppColors.lavender),
        size,
      );
      expect(calls.map(_name), ['drawRRect', 'drawPath']);
      final r = size.width / 2;
      expect(
        _args(calls[0])[0],
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(r)),
      );
      expect(
        (_args(calls[0])[1]! as Paint).color.toARGB32(),
        AppColors.lavender.toARGB32(),
      );
      final border = _args(calls[1])[0]! as Path;
      expect(
        (_args(calls[1])[1]! as Paint).color.toARGB32(),
        AppColors.ink.toARGB32(),
      );
      final cx = size.width / 2;
      expect(
        border.contains(Offset(cx, 0.1)),
        isTrue,
        reason: 'topo, dentro da borda',
      );
      expect(
        border.contains(Offset(cx, 1.4)),
        isTrue,
        reason: 'topo, dentro da borda (1,5)',
      );
      expect(
        border.contains(Offset(cx, 1.6)),
        isFalse,
        reason: 'abaixo da borda no topo',
      );
      expect(
        border.contains(Offset(0.2, r)),
        isFalse,
        reason: 'lateral: espessura 0 na altura do raio',
      );
      expect(
        border.contains(Offset(size.width - 0.2, r)),
        isFalse,
        reason: 'lateral direita',
      );
      expect(border.contains(Offset(cx, 20)), isFalse, reason: 'interior');
    });

    testWidgets(
      'golden isolado: barras 30,742 × 43 (lavanda) e 30,142 × 24 (flame)',
      (tester) async {
        await tester.pumpWidget(
          const Directionality(
            textDirection: TextDirection.ltr,
            child: Align(
              alignment: Alignment.topLeft,
              child: RepaintBoundary(
                key: _goldenKey,
                child: ColoredBox(
                  color: AppColors.surface,
                  child: Padding(
                    padding: EdgeInsets.all(4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      spacing: 8,
                      children: [
                        // Barras 0–5: coluna − 2 × 1,2; barra "Hoje": coluna − 2 × 1,5.
                        SizedBox(
                          width: _kColumn - 2.4,
                          height: 43,
                          child: CustomPaint(
                            painter: TopBorderCrescentPainter(
                              fill: AppColors.lavender,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: _kColumn - 3,
                          height: 24,
                          child: CustomPaint(
                            painter: TopBorderCrescentPainter(
                              fill: AppColors.flame,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await expectLater(
          await captureAt(tester, find.byKey(_goldenKey)),
          matchesGoldenFile('../golden/goldens/ds_meia_lua@3x.png'),
        );
      },
    );
  });

  testWidgets(
    'cena de verificação: gráfico da semana (hachuras + meias-luas + linha da meta, alinhada a today.week.goalLine/chart)',
    (tester) async {
      final chart = ref01('today.week.chart').rect;
      final goal = ref01('today.week.goalLine').rect;
      final region = Rect.fromLTRB(
        goal.left,
        chart.top,
        goal.right,
        chart.bottom,
      );
      await tester.pumpWidget(
        _scene(
          region,
          AppColors.surface,
          (at) => [
            for (var i = 0; i < 7; i++)
              at(ref01('today.week.bar$i').rect, _weekBar(i)),
            at(
              goal,
              const CustomPaint(
                painter: ChromiumDashPainter(
                  axis: Axis.horizontal,
                  color: AppColors.goalLine,
                ),
              ),
            ),
          ],
        ),
      );
      // Os preenchimentos caem nos retângulos medidos no arquivo (referência arredondada a 0,01).
      final box = _gridBox(region);
      for (var i = 0; i < 7; i++) {
        final fill = find
            .descendant(
              of: find.byType(NeoBox).at(i),
              matching: find.byType(CustomPaint),
            )
            .last;
        final ref = ref01('today.week.bar$i.fill').rect;
        final got = tester.getRect(fill);
        expect(
          got.left,
          moreOrLessEquals(ref.left - box.left, epsilon: 0.01),
          reason: 'bar$i.fill x',
        );
        expect(
          got.top,
          moreOrLessEquals(ref.top - box.top, epsilon: 0.01),
          reason: 'bar$i.fill y',
        );
        expect(
          got.width,
          moreOrLessEquals(ref.width, epsilon: 0.01),
          reason: 'bar$i.fill largura',
        );
        expect(
          got.height,
          moreOrLessEquals(ref.height, epsilon: 0.01),
          reason: 'bar$i.fill altura',
        );
      }
      await _expectSceneGolden(tester, 'ds_semana', region);
    },
  );
}

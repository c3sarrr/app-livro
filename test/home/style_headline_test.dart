import 'dart:math' as math;
import 'dart:typed_data';

import 'package:app_leitura/app/app.dart';
import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/canvas.dart';
import '../support/capture.dart';
import '../support/load_fonts.dart';
import '../support/precache_svgs.dart';
import '../support/pump_app.dart';

const _headline = ValueKey<String>('headline');

TextStyle _styleOfLine(WidgetTester tester, int index) => tester
    .widget<AppText>(
      find
          .descendant(of: find.byKey(_headline), matching: find.byType(AppText))
          .at(index),
    )
    .span
    .style!;

/// Pixels @3x do canvas inteiro (mesma captura do golden).
Future<(Uint8List, int)> _canvasPixels(WidgetTester tester) async {
  await precacheAppIcons(tester);
  await tester.pumpWidget(
    const ProviderScope(
      child: RepaintBoundary(key: goldenRootKey, child: App.forTests()),
    ),
  );
  await tester.pumpAndSettle();
  final image = await captureAt(tester, find.byKey(goldenRootKey));
  return (await rgbaOf(tester, image), image.width);
}

/// F04 — camada 2 (estilo, sem tolerância) da seção `headline`.
void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    '4.1 "Continue": Bricolage42 (opsz 42) 800, 42 px, height 0,98 (41,16), ls −1,4, #1A1714, "even"',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final s = _styleOfLine(tester, 0);
      expect(s.fontFamily, 'Bricolage42');
      expect(s.fontFamilyFallback, ['Bricolage42Ext', 'Bricolage42Vi']);
      expect(s.fontSize, 42);
      expect(s.fontWeight, FontWeight.w800);
      expect(s.fontStyle, anyOf(isNull, FontStyle.normal));
      expect(s.height, 0.98);
      expect(s.letterSpacing, -1.4);
      expect(s.color!.toARGB32(), 0xFF1A1714);
      expect(s.leadingDistribution, TextLeadingDistribution.even);
      expect(s.fontSize! * s.height!, moreOrLessEquals(41.16, epsilon: 1e-9));
    },
  );

  testWidgets(
    '4.1 "sua história.": InstrumentSerif itálico 400, 50 px, height 0,98 herdado (49), ls −0,6, #1A1714, "even"',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final s = _styleOfLine(tester, 1);
      expect(s.fontFamily, 'InstrumentSerif');
      expect(s.fontFamilyFallback, ['InstrumentSerifExt']);
      expect(s.fontSize, 50);
      expect(s.fontWeight, FontWeight.w400);
      expect(s.fontStyle, FontStyle.italic);
      expect(s.height, 0.98);
      expect(s.letterSpacing, -0.6);
      expect(s.color!.toARGB32(), 0xFF1A1714);
      expect(s.leadingDistribution, TextLeadingDistribution.even);
      expect(s.fontSize! * s.height!, moreOrLessEquals(49, epsilon: 1e-9));
    },
  );

  testWidgets(
    'pixels @3x da faixa (0, 126, 390, 106): só tinta #1A1714 sobre papel #F7F0E3; a tinta cheia é exatamente #1A1714',
    (tester) async {
      setCanvasView(tester);
      final (rgba, width) = await _canvasPixels(tester);
      final ink = [
        (AppColors.ink.r * 255).round(),
        (AppColors.ink.g * 255).round(),
        (AppColors.ink.b * 255).round(),
      ];
      final paper = [
        (AppColors.paper.r * 255).round(),
        (AppColors.paper.g * 255).round(),
        (AppColors.paper.b * 255).round(),
      ];
      var opaque = true, worstSpread = 0.0, outOfRange = 0;
      var fullInk = 0, darkestSum = 1 << 30, darkest = 0;
      for (var y = 126 * 3; y < 232 * 3; y++) {
        for (var x = 0; x < width; x++) {
          final i = (y * width + x) * 4;
          if (rgba[i + 3] != 255) opaque = false;
          // Cobertura implícita em cada canal: um pixel de "tinta sobre papel" tem a mesma nos três.
          final a = [
            for (var c = 0; c < 3; c++)
              (paper[c] - rgba[i + c]) / (paper[c] - ink[c]),
          ];
          worstSpread = math.max(
            worstSpread,
            a.reduce(math.max) - a.reduce(math.min),
          );
          if (a.any((v) => v < -0.01 || v > 1.01)) outOfRange++;
          final sum = rgba[i] + rgba[i + 1] + rgba[i + 2];
          if (sum < darkestSum) {
            darkestSum = sum;
            darkest =
                0xFF000000 | (rgba[i] << 16) | (rgba[i + 1] << 8) | rgba[i + 2];
          }
          if (a.every((v) => v >= 0.999)) fullInk++;
        }
      }
      debugPrint(
        '[headline] pixels: maior divergência entre canais ${worstSpread.toStringAsFixed(4)} | '
        'fora de papel↔tinta $outOfRange | mais escuro 0x${darkest.toRadixString(16).toUpperCase()} | '
        'pixels de tinta cheia $fullInk',
      );
      expect(opaque, isTrue);
      expect(outOfRange, 0);
      expect(worstSpread, lessThan(0.02));
      expect(darkest, 0xFF1A1714);
      expect(fullInk, greaterThan(1000));
    },
  );
}

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:app_leitura/app/app.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/features/home/application/home_providers.dart';
import 'package:app_leitura/features/home/presentation/home_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/overrides_do_mundo.dart';
import '../support/canvas.dart';
import '../support/capture.dart';
import '../support/load_fonts.dart';
import '../support/precache_svgs.dart';

const _baseGolden = 'test/golden/goldens/inicio_canvas@3x.png';

/// Pixels RGBA do golden padrão (`inicio_canvas@3x.png`; desde a T03 o da prancha 01) e a largura.
Future<(Uint8List, int)> _loadBase(WidgetTester tester) async {
  // E/S real e decodificação: fora do FakeAsync do testWidgets (senão o teste trava).
  return (await tester.runAsync(() async {
    final bytes = await File(_baseGolden).readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final data = await frame.image.toByteData(
      format: ui.ImageByteFormat.rawStraightRgba,
    );
    return (data!.buffer.asUint8List(), frame.image.width);
  }))!;
}

/// O pixel @3x (px, py) cobre [px/3, (px+1)/3) × [py/3, (py+1)/3): conta se toca [r] (coordenadas lógicas).
bool _touches(int px, int py, Rect r) =>
    (px + 1) / 3 > r.left &&
    px / 3 < r.right &&
    (py + 1) / 3 > r.top &&
    py / 3 < r.bottom;

/// Recorte de [src] (@3x) no retângulo lógico [r], pixel a pixel, para o golden da região afetada.
Future<ui.Image> _crop(WidgetTester tester, ui.Image src, Rect r) async {
  final from = Rect.fromLTRB(
    (r.left * 3).floorToDouble(),
    (r.top * 3).floorToDouble(),
    (r.right * 3).ceilToDouble(),
    (r.bottom * 3).ceilToDouble(),
  );
  return (await tester.runAsync(() async {
    final recorder = ui.PictureRecorder();
    ui.Canvas(recorder).drawImageRect(
      src,
      from,
      Offset.zero & from.size,
      ui.Paint()..filterQuality = ui.FilterQuality.none,
    );
    return recorder.endRecording().toImage(
      from.width.toInt(),
      from.height.toInt(),
    );
  }))!;
}

String _hex(Color c) =>
    (c.toARGB32() & 0xFFFFFF).toRadixString(16).toLowerCase().padLeft(6, '0');

Rect _rect(WidgetTester tester, String id) =>
    tester.getRect(find.byKey(ValueKey<String>(id)));

Future<ProviderContainer> _pump(WidgetTester tester) async {
  setCanvasView(tester);
  await precacheAppIcons(tester);
  await tester.pumpWidget(
    ProviderScope(
      overrides: overridesDoMundo,
      child: const RepaintBoundary(key: goldenRootKey, child: App.forTests()),
    ),
  );
  await tester.pumpAndSettle();
  return ProviderScope.containerOf(tester.element(find.byType(HomeScreen)));
}

/// F12 12.3 — um golden por opção de `brand` (4) e de `weekColor` (4). Cada opção é comparada pixel a pixel com
/// o golden padrão do canvas: a diferença FORA das regiões esperadas precisa ser 0, e a opção padrão reproduz o
/// golden exatamente. Os PNGs `inicio_brand_*` / `inicio_weekcolor_*` guardam a região afetada. Desde a T03 na
/// prancha 01 (390 × 2650; o `{{brand}}` dela é o herói e a pílula da aba ativa, o `{{weekColor}}` as barras 0–5).
void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    '12.3 brand: as 4 opções mudam só o fundo do hero e a pílula ativa da navegação (0 pixels fora); a padrão = golden aprovado',
    (tester) async {
      final container = await _pump(tester);
      final (base, width) = await _loadBase(tester);
      final hero = _rect(tester, 'hero');
      final pill = _rect(tester, 'nav.home');
      expect(AppColors.brandOptions, hasLength(4));
      for (final (i, brand) in AppColors.brandOptions.indexed) {
        container.read(homeThemeProvider.notifier).setBrand(brand);
        await tester.pumpAndSettle();
        final image = await captureAt(tester, find.byKey(goldenRootKey));
        expect((image.width, image.height), (1170, 7950));
        final rgba = await rgbaOf(tester, image);
        expect(rgba.length, base.length);
        var changed = 0, inHero = 0, inPill = 0, outside = 0;
        for (var p = 0; p < rgba.length; p += 4) {
          if (rgba[p] == base[p] &&
              rgba[p + 1] == base[p + 1] &&
              rgba[p + 2] == base[p + 2] &&
              rgba[p + 3] == base[p + 3]) {
            continue;
          }
          changed++;
          final px = (p ~/ 4) % width, py = (p ~/ 4) ~/ width;
          final h = _touches(px, py, hero), n = _touches(px, py, pill);
          if (h) inHero++;
          if (n) inPill++;
          if (!h && !n) outside++;
        }
        debugPrint(
          '[tema] brand #${_hex(brand)}: $changed pixels diferentes do golden padrão → hero $inHero · pílula $inPill · FORA $outside',
        );
        expect(outside, 0, reason: 'brand #${_hex(brand)}: pixels fora');
        if (i == 0) {
          expect(changed, 0, reason: 'a opção padrão = o golden aprovado');
        } else {
          expect(inHero, greaterThan(300000));
          expect(inPill, greaterThan(5000));
        }
        // Região afetada: o cartão (com a sombra) e a faixa da navegação.
        await expectLater(
          await _crop(tester, image, hero.inflate(5)),
          matchesGoldenFile(
            '../golden/goldens/inicio_brand_${_hex(brand)}_hero@3x.png',
          ),
        );
        await expectLater(
          await _crop(tester, image, const Rect.fromLTWH(0, 2490, 390, 160)),
          matchesGoldenFile(
            '../golden/goldens/inicio_brand_${_hex(brand)}_nav@3x.png',
          ),
        );
      }
    },
  );

  testWidgets(
    '12.3 weekColor: as 4 opções mudam só os preenchimentos das barras 0–5 do gráfico (0 pixels fora; a barra de hoje e o resto não mudam); a padrão = golden aprovado',
    (tester) async {
      final container = await _pump(tester);
      final (base, width) = await _loadBase(tester);
      final bars = [
        for (var i = 0; i < 7; i++) _rect(tester, 'today.week.bar$i'),
      ];
      expect(AppColors.weekColorOptions, hasLength(4));
      for (final (i, color) in AppColors.weekColorOptions.indexed) {
        container.read(homeThemeProvider.notifier).setWeekColor(color);
        await tester.pumpAndSettle();
        final image = await captureAt(tester, find.byKey(goldenRootKey));
        final rgba = await rgbaOf(tester, image);
        final perBar = List.filled(7, 0);
        var changed = 0, outside = 0;
        for (var p = 0; p < rgba.length; p += 4) {
          if (rgba[p] == base[p] &&
              rgba[p + 1] == base[p + 1] &&
              rgba[p + 2] == base[p + 2] &&
              rgba[p + 3] == base[p + 3]) {
            continue;
          }
          changed++;
          final px = (p ~/ 4) % width, py = (p ~/ 4) ~/ width;
          var inside = false;
          for (var b = 0; b < 7; b++) {
            if (_touches(px, py, bars[b])) {
              perBar[b]++;
              inside = true;
            }
          }
          if (!inside) outside++;
        }
        debugPrint(
          '[tema] weekColor #${_hex(color)}: $changed pixels diferentes do golden padrão → por barra $perBar · FORA $outside',
        );
        expect(outside, 0, reason: 'weekColor #${_hex(color)}: pixels fora');
        expect(perBar[6], 0, reason: 'a barra de hoje é sempre #FF552E');
        if (i == 0) {
          expect(changed, 0, reason: 'a opção padrão = o golden aprovado');
        } else {
          for (var b = 0; b < 6; b++) {
            expect(perBar[b], greaterThan(300), reason: 'barra $b muda de cor');
          }
        }
        await expectLater(
          await _crop(tester, image, _rect(tester, 'today.week')),
          matchesGoldenFile(
            '../golden/goldens/inicio_weekcolor_${_hex(color)}@3x.png',
          ),
        );
      }
    },
  );
}

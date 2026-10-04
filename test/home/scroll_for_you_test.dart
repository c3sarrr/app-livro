import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:app_leitura/app/app.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/features/home/presentation/home_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/overrides_do_mundo.dart';
import '../reference/reference_layout.dart';
import '../support/canvas.dart';
import '../support/capture.dart';
import '../support/geometry.dart';
import '../support/load_fonts.dart';
import '../support/precache_svgs.dart';
import '../support/pump_app.dart';

const _carouselKey = ValueKey<String>('forYou.carousel');
final _carousel = find.byKey(_carouselKey);

/// Posição de rolagem do carrossel: a do `Scrollable` descendente da Key `forYou.carousel`.
ScrollPosition _position(WidgetTester tester) => tester
    .state<ScrollableState>(
      find.descendant(of: _carousel, matching: find.byType(Scrollable)),
    )
    .position;

/// Scrollables sob a HomeScreen (mesmo com a aba fora da tela): a Início e, desde a F08, o carrossel.
Finder _homeScrollables() => find.descendant(
  of: find.byType(HomeScreen, skipOffstage: false),
  matching: find.byType(Scrollable, skipOffstage: false),
);

Rect _rect(WidgetTester tester, String id) =>
    tester.getRect(find.byKey(ValueKey<String>(id)));

/// Alturas e posições que somam alturas de texto carregam o ruído float32 do SkParagraph (±1e-3).
const _eps = 1e-3;

/// Conteúdo do carrossel: padding 20 + 3 × 116 + 2 × 14 + padding 20 = 416; viewport 390 → extensão 26.
const _content = 20 + 3 * 116 + 2 * 14 + 20;
const _viewport = 390.0;
const _maxExtent = _content - _viewport; // 26

/// Faixa do carrossel no canvas (y 1316,16 → 1534,56) e em pixels @3x: linhas [3948, 4604).
final _band = kRefLayout['forYou.carousel']!.rect;
final _bandTop = (_band.top * 3).floor(); // 3948
final _bandBottom = (_band.bottom * 3).ceil(); // 4604 (exclusivo)

/// Ids que ficam DENTRO do conteúdo rolável (os 33 dos itens) e os de fora (seção, cabeçalho, chip e o
/// próprio viewport do carrossel).
final _itemIds = idsOfSection('forYou')
    .where((id) => id.startsWith('forYou.item'))
    .toList();
final _fixedIds = idsOfSection('forYou')
    .where((id) => !id.startsWith('forYou.item'))
    .toList();

/// Roda [body] com [platform] em `debugDefaultTargetPlatformOverride` e restaura o override num
/// `finally` DENTRO do corpo do teste: o flutter_test confere as variáveis de depuração da foundation
/// logo depois do corpo, antes dos `addTearDown` (um tearDown restauraria tarde demais).
Future<void> _onPlatform(
  TargetPlatform platform,
  Future<void> Function() body,
) async {
  debugDefaultTargetPlatformOverride = platform;
  try {
    await body();
  } finally {
    debugDefaultTargetPlatformOverride = null;
  }
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

/// Captura @3x do canvas inteiro (1170 × 7170) como palavras RGBA de 32 bits.
Future<Uint32List> _capture(WidgetTester tester) async {
  final image = await captureAt(tester, find.byKey(goldenRootKey));
  expect((image.width, image.height), (1170, 7170));
  final rgba = await rgbaOf(tester, image);
  return rgba.buffer.asUint32List(rgba.offsetInBytes, rgba.lengthInBytes ~/ 4);
}

/// Linhas @3x da seção "Para você" (y 1207,56 → 1534,56): [3622, 4604). A comparação com o golden em disco fica
/// restrita a elas — o golden é regenerado pelo `golden_canvas_test` a cada fase, e as outras seções não são
/// assunto deste teste.
final _sectionTop = (kRefSections['forYou']!.top * 3).floor(); // 3622
final _sectionBottom = (kRefSections['forYou']!.bottom * 3)
    .ceil(); // 4604 (exclusivo)

/// O golden do canvas (`test/golden/goldens/inicio_canvas@3x.png`, gerado pelo `golden_canvas_test`)
/// decodificado como palavras RGBA de 32 bits — só leitura, este teste nunca o grava.
Future<Uint32List> _goldenCanvas(WidgetTester tester) async {
  final bytes = File('test/golden/goldens/inicio_canvas@3x.png')
      .readAsBytesSync();
  final image = await tester.runAsync(() async {
    final codec = await ui.instantiateImageCodec(bytes);
    return (await codec.getNextFrame()).image;
  });
  expect((image!.width, image.height), (1170, 7170));
  final rgba = await rgbaOf(tester, image);
  return rgba.buffer.asUint32List(rgba.offsetInBytes, rgba.lengthInBytes ~/ 4);
}

/// Cor do arquivo (`Color` ARGB) como palavra RGBA de 32 bits little-endian (a leitura de `rgbaOf`).
int _rgbaWord(Color c) {
  final argb = c.toARGB32();
  final a = argb >>> 24, r = (argb >> 16) & 255, g = (argb >> 8) & 255;
  final b = argb & 255;
  return r | (g << 8) | (b << 16) | (a << 24);
}

/// A vizinhança 3 × 3 de ([x]; [y]) em [img] não é uniforme: o pixel está numa borda entre cores.
bool _isEdge(Uint32List img, int x, int y) {
  const width = 1170;
  final c = img[y * width + x];
  for (var dy = -1; dy <= 1; dy++) {
    for (var dx = -1; dx <= 1; dx++) {
      if (x + dx < 0 || x + dx >= width) continue; // sem dar a volta na linha
      if (img[(y + dy) * width + x + dx] != c) return true;
    }
  }
  return false;
}

/// Diferença de suavização (rasterização), não de forma nem de cor: o pixel [value] é uma mistura das
/// cores que [img] tem ali — cada canal fica entre o mínimo e o máximo da vizinhança 3 × 3 de
/// ([x]; [y]) em [img] — e essa vizinhança é uma borda (não uniforme). Num preenchimento chapado
/// (vizinhança uniforme) qualquer diferença é defeito.
bool _isEdgeBlend(Uint32List img, int x, int y, int value) {
  const width = 1170;
  var edge = false;
  for (var k = 0; k < 4; k++) {
    var lo = 255, hi = 0;
    for (var dy = -1; dy <= 1; dy++) {
      for (var dx = -1; dx <= 1; dx++) {
        if (x + dx < 0 || x + dx >= width) continue; // sem dar a volta na linha
        final c = (img[(y + dy) * width + x + dx] >> (8 * k)) & 255;
        if (c < lo) lo = c;
        if (c > hi) hi = c;
      }
    }
    final v = (value >> (8 * k)) & 255;
    if (v < lo || v > hi) return false;
    if (hi > lo) edge = true;
  }
  return edge;
}

/// Pixels diferentes entre [a] e [b] (largura 1170) e o retângulo @3x que os contém (vazio → null).
(int, Rect?) _diff(Uint32List a, Uint32List b, {int fromRow = 0, int? toRow}) {
  const width = 1170;
  var count = 0;
  var minX = width, minY = 1 << 30, maxX = -1, maxY = -1;
  for (var i = fromRow * width; i < (toRow ?? a.length ~/ width) * width; i++) {
    if (a[i] == b[i]) continue;
    count++;
    final x = i % width, y = i ~/ width;
    if (x < minX) minX = x;
    if (x > maxX) maxX = x;
    if (y < minY) minY = y;
    if (y > maxY) maxY = y;
  }
  if (count == 0) return (0, null);
  return (
    count,
    Rect.fromLTRB(minX.toDouble(), minY.toDouble(), maxX + 1.0, maxY + 1.0),
  );
}

/// Arraste de [dx] no centro do carrossel e espera assentar.
Future<void> _drag(WidgetTester tester, double dx) async {
  await tester.drag(_carousel, Offset(dx, 0));
  await tester.pumpAndSettle();
}

/// Intensidade do stretch do Android (`StretchEffect` do `StretchingOverscrollIndicator` do carrossel);
/// null quando a plataforma não tem o indicador (iOS).
double? _stretch(WidgetTester tester) {
  final effect = find.descendant(
    of: _carousel,
    matching: find.byType(StretchEffect),
  );
  if (effect.evaluate().isEmpty) return null;
  return tester.widget<StretchEffect>(effect).stretchStrength;
}

/// F08 — rolagem do carrossel "Para você" (D-03 do prompt mestre §10; "Testes da fase" da F08).
void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    '8.3 D-03 extensão: 20 + 3 × 116 + 2 × 14 + 20 = 416 no viewport 390 → maxScrollExtent 26; repouso em 0; física da plataforma (sem physics próprio)',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final scroll = tester.widget<SingleChildScrollView>(_carousel);
      expect(scroll.scrollDirection, Axis.horizontal);
      expect(scroll.padding, const EdgeInsets.symmetric(horizontal: 20));
      expect(scroll.clipBehavior, Clip.hardEdge);
      // D-03: física da plataforma — nenhum ScrollPhysics nem controller próprio no carrossel.
      expect(scroll.physics, isNull);
      expect(scroll.controller, isNull);

      final position = _position(tester);
      expect(position.axis, Axis.horizontal);
      expect(position.axisDirection, AxisDirection.right);
      expect(position.viewportDimension, _viewport);
      expect(position.minScrollExtent, 0);
      expect(position.maxScrollExtent, _maxExtent);
      expect(position.maxScrollExtent, 26);
      expect(position.pixels, 0);
      // Conteúdo medido: do início do item 1 ao fim do item 3 = 3 × 116 + 2 × 14, mais os paddings.
      final row =
          _rect(tester, 'forYou.item3').right -
          _rect(tester, 'forYou.item1').left;
      expect(row, 3 * 116 + 2 * 14);
      expect(20 + row + 20, _content);
      expect(position.maxScrollExtent + position.viewportDimension, 416);
      // O viewport é a faixa inteira 0 → 390 (sangria do CSS) e o 3º item passa 6 da borda (280 → 396).
      expect(_rect(tester, 'forYou.carousel').left, 0);
      expect(_rect(tester, 'forYou.carousel').width, _viewport);
      expect(_rect(tester, 'forYou.item3').right, 396);

      // A rolagem do carrossel é independente da rolagem vertical da Início: dois Scrollables sob a
      // HomeScreen, cada um com a sua posição.
      expect(_homeScrollables(), findsNWidgets(2));
      final home = homeScrollPosition(tester);
      expect(identical(home, position), isFalse);
      expect(home.axis, Axis.vertical);
      expect(home.pixels, 0);
      debugPrint(
        '[rolagem D-03] conteúdo ${20 + row + 20} | viewport ${position.viewportDimension} | '
        'maxScrollExtent ${position.maxScrollExtent} | pixels ${position.pixels} | '
        'physics resolvido ${position.physics.runtimeType}',
      );
    },
  );

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    final clamping = platform == TargetPlatform.android;
    final label = clamping ? 'android: clamping + stretch' : 'iOS: bouncing';

    testWidgets(
      '8.3 D-03 ($label): arrastar −100 → fica em 26 (itens deslocados 26; item3 termina em 370); arrastar +100 → volta a 0 e a geometria 41/41; a Início não rola',
      (tester) async {
        setCanvasView(tester);
        await _onPlatform(platform, () async {
          await pumpApp(tester);
          final position = _position(tester);
          // Física da plataforma resolvida pelo ScrollBehavior do MaterialApp.
          if (clamping) {
            expect(position.physics, isA<ClampingScrollPhysics>());
            expect(
              find.descendant(
                of: _carousel,
                matching: find.byType(StretchingOverscrollIndicator),
              ),
              findsOneWidget,
            );
          } else {
            expect(position.physics, isA<BouncingScrollPhysics>());
            expect(
              find.descendant(
                of: _carousel,
                matching: find.byType(StretchingOverscrollIndicator),
              ),
              findsNothing,
            );
          }
          expect(position.pixels, 0);
          expect(position.maxScrollExtent, 26);

          final rest = {
            for (final id in [..._itemIds, ..._fixedIds]) id: _rect(tester, id),
          };

          await _drag(tester, -100);
          // Posição relida depois do gesto (a do estado atual do Scrollable, não uma referência antiga).
          final scrolled = _position(tester);
          expect(scrolled.pixels, 26);
          expect(scrolled.maxScrollExtent, 26);
          expect(homeScrollPosition(tester).pixels, 0);
          // Os 33 ids dos itens andam exatamente 26 para a esquerda; o resto da seção não se move.
          final shifted = <String>[];
          for (final id in _itemIds) {
            final got = _rect(tester, id);
            final exp = rest[id]!.shift(const Offset(-_maxExtent, 0));
            if ((got.left - exp.left).abs() > 1e-9 ||
                (got.top - exp.top).abs() > 1e-9 ||
                (got.width - exp.width).abs() > 1e-9 ||
                (got.height - exp.height).abs() > 1e-9) {
              shifted.add('$id: $got ≠ $exp');
            }
          }
          expect(shifted, isEmpty, reason: shifted.join('\n'));
          for (final id in _fixedIds) {
            expect(_rect(tester, id), rest[id], reason: id);
          }
          for (final (i, x) in [(1, -6.0), (2, 124.0), (3, 254.0)]) {
            final item = _rect(tester, 'forYou.item$i');
            expect(item.left, x, reason: 'item$i');
            expect(
              item.top,
              moreOrLessEquals(_band.top, epsilon: _eps),
              reason: 'item$i',
            );
          }
          expect(_rect(tester, 'forYou.item3').right, 370);
          debugPrint(
            '[rolagem D-03 ${platform.name}] depois de −100: pixels ${scrolled.pixels} | '
            'item1.x ${_rect(tester, 'forYou.item1').left} | '
            'item3.right ${_rect(tester, 'forYou.item3').right} | '
            'Início ${homeScrollPosition(tester).pixels}',
          );

          await _drag(tester, 100);
          final back = _position(tester);
          expect(back.pixels, 0);
          expect(back.maxScrollExtent, 26);
          expect(homeScrollPosition(tester).pixels, 0);
          for (final id in rest.keys) {
            expect(_rect(tester, id), rest[id], reason: id);
          }
          // Em repouso de novo, a seção inteira volta ao arquivo.
          expectGeometry(tester, idsOfSection('forYou'));
          debugPrint(
            '[rolagem D-03 ${platform.name}] depois de +100: pixels ${back.pixels} | '
            'item3.right ${_rect(tester, 'forYou.item3').right} | '
            'Início ${homeScrollPosition(tester).pixels}',
          );
        });
      },
    );

    testWidgets(
      '8.3 D-03 ($label): durante o arraste de −100 ${clamping ? 'a posição trava em 26 (o excesso vai para o stretch)' : 'a posição passa de 26 (overscroll)'}; ao soltar volta a exatamente 26 — só o excesso volta',
      (tester) async {
        setCanvasView(tester);
        await _onPlatform(platform, () async {
          await pumpApp(tester);
          expect(_position(tester).pixels, 0);
          final gesture = await tester.startGesture(
            tester.getCenter(_carousel),
          );
          // Passa do slop de arraste antes do resto (como o `tester.drag`).
          await gesture.moveBy(const Offset(-20, 0));
          await tester.pump();
          await gesture.moveBy(const Offset(-80, 0));
          await tester.pump();
          final during = _position(tester).pixels;
          final stretchDuring = _stretch(tester);
          if (clamping) {
            // Clamping: a posição não passa de 26; o excesso vira stretch — no fim do conteúdo (borda
            // direita), intensidade negativa.
            expect(during, 26);
            expect(stretchDuring, lessThan(0));
          } else {
            // Bouncing: a posição passa de 26 (sem indicador de overscroll).
            expect(during, greaterThan(26));
            expect(stretchDuring, isNull);
          }
          expect(homeScrollPosition(tester).pixels, 0);

          await gesture.up();
          await tester.pumpAndSettle();
          expect(_position(tester).pixels, 26);
          expect(_position(tester).maxScrollExtent, 26);
          expect(_stretch(tester), clamping ? 0 : isNull);
          expect(homeScrollPosition(tester).pixels, 0);
          debugPrint(
            '[rolagem D-03 ${platform.name}] durante o arraste: pixels ${during.toStringAsFixed(3)}, '
            'stretch $stretchDuring | depois de soltar: pixels ${_position(tester).pixels}, stretch ${_stretch(tester)}',
          );

          // E o caminho inverso também para exatamente em 0.
          final back = await tester.startGesture(tester.getCenter(_carousel));
          await back.moveBy(const Offset(20, 0));
          await tester.pump();
          await back.moveBy(const Offset(80, 0));
          await tester.pump();
          final duringBack = _position(tester).pixels;
          final stretchBack = _stretch(tester);
          if (clamping) {
            // No início do conteúdo (borda esquerda), intensidade positiva.
            expect(duringBack, 0);
            expect(stretchBack, greaterThan(0));
          } else {
            expect(duringBack, lessThan(0));
            expect(stretchBack, isNull);
          }
          await back.up();
          await tester.pumpAndSettle();
          expect(_position(tester).pixels, 0);
          expect(_stretch(tester), clamping ? 0 : isNull);
          expect(homeScrollPosition(tester).pixels, 0);
          debugPrint(
            '[rolagem D-03 ${platform.name}] arraste de volta: pixels ${duringBack.toStringAsFixed(3)}, '
            'stretch $stretchBack → pixels ${_position(tester).pixels}',
          );
        });
      },
    );

    testWidgets(
      '8.3 D-03 ($label): o golden do repouso volta a ser idêntico depois de ir e voltar; em 26 a captura difere só dentro da faixa do carrossel (y 1316,16 → 1534,56), com o item 2 igual ao repouso deslocado 26 (78 px @3x)',
      (tester) async {
        setCanvasView(tester);
        await _onPlatform(platform, () async {
          await _pumpCanvas(tester);
          expect(_position(tester).pixels, 0);
          final rest = await _capture(tester);
          // Na faixa da seção, o repouso capturado aqui É o golden do canvas (mesma raiz, mesma captura @3x).
          expect((_sectionTop, _sectionBottom), (3622, 4604));
          final golden = await _goldenCanvas(tester);
          final (restVsGolden, restVsGoldenBox) = _diff(
            golden,
            rest,
            fromRow: _sectionTop,
            toRow: _sectionBottom,
          );
          expect(
            restVsGolden,
            0,
            reason:
                'repouso ≠ golden do canvas em $restVsGoldenBox (golden desatualizado?)',
          );

          await _drag(tester, -100);
          expect(_position(tester).pixels, 26);
          expect(homeScrollPosition(tester).pixels, 0);
          final scrolled = await _capture(tester);
          final (count, box) = _diff(rest, scrolled);
          expect(count, greaterThan(0));
          expect(box, isNotNull);
          // Só dentro da faixa do carrossel: linhas [3948, 4604) @3x.
          expect(_bandTop, 3948);
          expect(_bandBottom, 4604);
          expect(box!.top, greaterThanOrEqualTo(_bandTop));
          expect(box.bottom, lessThanOrEqualTo(_bandBottom));
          // Dentro da faixa, o que se vê em x é o que o repouso mostrava em x + 78 (26 × 3). O item 2
          // (124 → 240 em 26; 150 → 266 em repouso) não cruza a borda do viewport em nenhum dos dois
          // estados: bit a bit idêntico. Os itens 1 (−6 → 110 em 26) e 3 (280 → 396 em repouso) cruzam a
          // borda num dos estados; ali a suavização das bordas curvas (cantos das capas, arcos) sob o
          // recorte do viewport varia (rasterização) — essas divergências ficam restritas às colunas
          // deles E a pixels de borda nas duas capturas, e o valor em 26 é mistura das cores que o
          // repouso tem ali (entre o mínimo e o máximo da vizinhança 3 × 3), nunca num preenchimento
          // chapado nem uma cor nova.
          const width = 1170, shift = 78;
          const item1 = (0, 110 * 3), item2 = (124 * 3, 240 * 3);
          const item3 = (254 * 3, 370 * 3);
          bool inside((int, int) span, int x) => x >= span.$1 && x < span.$2;
          var mismatches = 0, inItem1 = 0, inItem3 = 0, inItem2 = 0;
          var maxDelta = 0;
          final elsewhere = <String>[];
          final notEdge = <String>[];
          for (var y = _bandTop; y < _bandBottom; y++) {
            for (var x = 0; x < width - shift; x++) {
              final got = scrolled[y * width + x];
              final exp = rest[y * width + x + shift];
              if (got == exp) continue;
              mismatches++;
              if (inside(item2, x)) inItem2++;
              if (inside(item1, x)) {
                inItem1++;
              } else if (inside(item3, x)) {
                inItem3++;
              } else if (elsewhere.length < 20) {
                elsewhere.add('($x; $y)');
              }
              if ((!_isEdgeBlend(rest, x + shift, y, got) ||
                      !_isEdge(scrolled, x, y)) &&
                  notEdge.length < 20) {
                notEdge.add('($x; $y)');
              }
              for (var k = 0; k < 4; k++) {
                final d = (((got >> (8 * k)) & 255) - ((exp >> (8 * k)) & 255))
                    .abs();
                if (d > maxDelta) maxDelta = d;
              }
            }
          }
          expect(elsewhere, isEmpty, reason: elsewhere.join(' '));
          expect(inItem1 + inItem3, mismatches);
          expect(notEdge, isEmpty, reason: notEdge.join(' '));
          // O item 2 inteiro (todas as linhas da faixa) é o repouso deslocado 78 px.
          final item2Pixels = (_bandBottom - _bandTop) * (item2.$2 - item2.$1);
          expect(inItem2, 0);
          // Na borda direita, os últimos 20 do viewport (370 → 390 = colunas [1110, 1170)) mostram o
          // padding direito: fundo `#F7F0E3`, igual ao padding esquerdo do repouso (0 → 20).
          final paper = _rgbaWord(AppColors.paper);
          var restPad = 0, scrolledPad = 0;
          for (var y = _bandTop; y < _bandBottom; y++) {
            for (var x = 0; x < 20 * 3; x++) {
              if (rest[y * width + x] != paper) restPad++;
              if (scrolled[y * width + (370 * 3) + x] != paper) scrolledPad++;
            }
          }
          expect(restPad, 0, reason: 'padding esquerdo do repouso');
          expect(scrolledPad, 0, reason: 'padding direito em 26');
          debugPrint(
            '[rolagem D-03 ${platform.name}] repouso = golden do canvas ($restVsGolden pixels '
            'diferentes) | em 26: $count pixels diferentes do repouso em '
            'x ${box.left.toInt()}–${box.right.toInt()}, y ${box.top.toInt()}–${box.bottom.toInt()} @3x '
            '(faixa $_bandTop–$_bandBottom) | repouso deslocado 78 px: item 2 idêntico '
            '($item2Pixels pixels); $mismatches divergências de suavização em pixels de borda '
            '(máx. $maxDelta/255 por canal), $inItem1 no item 1 e $inItem3 no item 3 | padding '
            'direito 370 → 390 = fundo',
          );

          await _drag(tester, 100);
          expect(_position(tester).pixels, 0);
          expect(homeScrollPosition(tester).pixels, 0);
          final back = await _capture(tester);
          final (backCount, backBox) = _diff(rest, back);
          expect(backCount, 0, reason: 'diferenças em $backBox');
          final (backVsGolden, backVsGoldenBox) = _diff(
            golden,
            back,
            fromRow: _sectionTop,
            toRow: _sectionBottom,
          );
          expect(backVsGolden, 0, reason: 'diferenças em $backVsGoldenBox');
          debugPrint(
            '[rolagem D-03 ${platform.name}] de volta a 0: $backCount pixels diferentes do repouso '
            '(${rest.length} pixels, bytes idênticos) e $backVsGolden do golden do canvas na faixa da seção '
            '(${(_sectionBottom - _sectionTop) * 1170} pixels)',
          );
        });
      },
    );
  }
}

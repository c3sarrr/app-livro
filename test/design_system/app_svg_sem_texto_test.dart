// T03.7 — as capas da Início nova são SVGs com `<text>` e `preserveAspectRatio="xMidYMid slice"`: o AppSvg as lê sem
// os textos (o flutter_svg usaria a fonte do sistema) e as encaixa em `BoxFit.cover` (= o slice). Os textos voltam em
// AppText no widget da capa (dom_casmurro_eye_cover.dart).
import 'dart:io';
import 'dart:ui' as ui;

import 'package:app_leitura/core/design_system/tokens/app_icons.dart';
import 'package:app_leitura/core/design_system/tokens/app_illustrations_inicio.dart';
import 'package:app_leitura/core/design_system/widgets/app_svg.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/canvas.dart';
import '../support/capture.dart';
import '../support/precache_svgs.dart';

const _capa = AppIllustrationsInicio.coverDomCasmurro;
const _violeta = ui.Color(0xFF552CB7);

/// A capa 101×153 (a área dentro da borda do herói) num quadro com DPR 3.
Future<ui.Image> _pintar(WidgetTester tester, Widget svg) async {
  tester.view.physicalSize = const Size(303, 459);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Align(
        alignment: Alignment.topLeft,
        child: RepaintBoundary(key: goldenRootKey, child: svg),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return captureAt(tester, find.byKey(goldenRootKey));
}

/// Os pixels da faixa do título "Dom" (viewBox x 12–45, y 8–26 → ×1,0625 − 0,5 em x; ×3 do DPR) fora do violeta.
Future<int> _foraDoVioleta(WidgetTester tester, ui.Image img) async {
  final bytes = (await tester.runAsync(
    () => img.toByteData(format: ui.ImageByteFormat.rawRgba),
  ))!;
  var n = 0;
  const s = 153 / 144;
  for (var y = (8 * s * 3).round(); y < (26 * s * 3).round(); y++) {
    for (
      var x = ((12 * s - 0.5) * 3).round();
      x < ((45 * s - 0.5) * 3).round();
      x++
    ) {
      final i = (y * img.width + x) * 4;
      final c = ui.Color.fromARGB(
        bytes.getUint8(i + 3),
        bytes.getUint8(i),
        bytes.getUint8(i + 1),
        bytes.getUint8(i + 2),
      );
      if (c != _violeta) n++;
    }
  }
  return n;
}

void main() {
  test('o cache do flutter_svg cabe todos os SVGs do pacote com folga (o pré-carregamento não se descarta)', () async {
    final n = Directory('assets')
        .listSync(recursive: true)
        .where((f) => f.path.endsWith('.svg'))
        .length;
    expect(n, 109);
    expect(kSvgCacheSize, greaterThanOrEqualTo(2 * n));
    svg.cache.maximumSize = 100; // o padrão do flutter_svg
    addTearDown(() => svg.cache.maximumSize = kSvgCacheSize);
    TestWidgetsFlutterBinding.ensureInitialized();
    await preloadAppSvg(AppIcons.bell);
    expect(svg.cache.maximumSize, kSvgCacheSize);
  });

  test('svgWithoutText tira os três <text> do arquivo e mais nada', () {
    final xml = File(_capa).readAsStringSync();
    expect(RegExp('<text').allMatches(xml), hasLength(3));
    final sem = svgWithoutText(xml);
    expect(sem, isNot(contains('<text')));
    expect(sem, isNot(contains('Casmurro')));
    expect(sem, isNot(contains('MACHADO')));
    expect(sem.length, lessThan(xml.length));
    // o resto do desenho fica (o céu, o olho e o mar)
    for (final t in ['<path', '<circle', '<rect', 'clip-path']) {
      expect(
        RegExp(t).allMatches(sem).length,
        RegExp(t).allMatches(xml).length,
        reason: t,
      );
    }
  });

  test(
    'a capa tem chave de cache própria; os ícones, a do SvgPicture.asset',
    () {
      final capa = appSvgLoader(_capa);
      expect(
        capa.cacheKey(null),
        isNot(const SvgAssetLoader(_capa).cacheKey(null)),
      );
      expect(capa.cacheKey(null), appSvgLoader(_capa).cacheKey(null));
      expect(capa, appSvgLoader(_capa));
      // o lado que o app controla (o `==` do SvgAssetLoader aceita qualquer subclasse): a chave é que separa
      expect(capa == const SvgAssetLoader(_capa), isFalse);
      expect(capa.hashCode, appSvgLoader(_capa).hashCode);
      expect(
        appSvgLoader(AppIcons.bell).cacheKey(null),
        const SvgAssetLoader(AppIcons.bell).cacheKey(null),
      );
      expect(
        AppIllustrationsInicio.withText,
        AppIllustrationsInicio.all.toSet(),
      );
    },
  );

  testWidgets(
    'a capa desenhada sem os textos: a faixa do título fica só violeta (com eles, não)',
    (tester) async {
      await precacheSvgs(tester, [_capa]);
      final sem = await _pintar(
        tester,
        const AppSvg(_capa, size: 101, height: 153, fit: BoxFit.cover),
      );
      expect(await _foraDoVioleta(tester, sem), 0);
      // o mesmo arquivo pelo carregador comum desenha "Dom" ali (com a fonte do sistema)
      await tester.runAsync(() => const SvgAssetLoader(_capa).loadBytes(null));
      final com = await _pintar(
        tester,
        SvgPicture.asset(_capa, width: 101, height: 153, fit: BoxFit.cover),
      );
      expect(await _foraDoVioleta(tester, com), greaterThan(0));
    },
  );

  testWidgets(
    'BoxFit.cover = o slice: o viewBox 96×144 cobre 101×153 (escala 1,0625) e 0,5 sai de cada lado',
    (tester) async {
      await precacheSvgs(tester, [_capa]);
      await _pintar(
        tester,
        const AppSvg(_capa, size: 101, height: 153, fit: BoxFit.cover),
      );
      final pic = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect((pic.width, pic.height, pic.fit), (101.0, 153.0, BoxFit.cover));
      expect(pic.clipBehavior, Clip.hardEdge);
      // o padrão continua `contain` (os ícones)
      expect(const AppSvg(AppIcons.bell, size: 22).fit, BoxFit.contain);
    },
  );
}

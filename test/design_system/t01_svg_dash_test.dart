// T01 — os traços tracejados dos desenhos SVG do arquivo (`stroke-dasharray`) como o Chromium: o padrão começa no
// início do elemento e segue pelos segmentos. O flutter_svg tracejava as curvas com outra fase (a elipse do Laço da
// prateleira começava no topo; a dica "Gruda nas palavras" da 23b perdia o último traço). O SVG é lido com o traço
// desse elemento escondido e a `AppSvg` o pinta por cima.
import 'dart:io';
import 'dart:typed_data';

import 'package:app_leitura/core/design_system/painters/svg_dash_painter.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/tokens/app_illustrations_leitor.dart';
import 'package:app_leitura/core/design_system/widgets/app_svg.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/capture.dart';
import '../support/precache_svgs.dart';

const _fundo = Color(0xFFF7F0E3);

void main() {
  test('a troca de cores esconde só o traço dos elementos indicados', () {
    final m = SvgColorSwap(const {}, strokeless: const {'ellipse'});
    expect(
      m.substitute(null, 'ellipse', 'stroke', AppColors.ink),
      const Color(0x00000000),
    );
    expect(m.substitute(null, 'ellipse', 'fill', AppColors.ink), AppColors.ink);
    expect(m.substitute(null, 'rect', 'stroke', AppColors.ink), AppColors.ink);
    expect(m, SvgColorSwap(const {}, strokeless: const {'ellipse'}));
    expect(m, isNot(SvgColorSwap(const {})));
    expect(
      m.hashCode,
      SvgColorSwap(const {}, strokeless: const {'ellipse'}).hashCode,
    );
  });

  test('os desenhos tracejados: o Laço (a elipse, 4/3, 1,7) e a dica (o caminho, 2,5/2,5, 1,6 redondo)', () {
    final laco = svgDashes[AppIllustrationsLeitor.toolLasso]!;
    expect(
      (laco.element, laco.on, laco.off, laco.width, laco.color, laco.cap),
      ('ellipse', 4.0, 3.0, 1.7, AppColors.ink, StrokeCap.butt),
    );
    final dica = svgDashes[AppIllustrationsLeitor.markerTip]!;
    expect(
      (dica.element, dica.on, dica.off, dica.width, dica.color, dica.cap),
      ('path', 2.5, 2.5, 1.6, AppColors.flame, StrokeCap.round),
    );
    expect(svgDashes.keys, hasLength(2));
    // a mesma chave de cache em toda pré-carga: o carregador já leva o elemento sem traço
    expect(
      appSvgLoader(AppIllustrationsLeitor.toolLasso).colorMapper,
      SvgColorSwap(const {}, strokeless: const {'ellipse'}),
    );
    expect(
      appSvgLoader(
        AppIllustrationsLeitor.markerTip,
        colors: {AppColors.ink: AppColors.inkNight},
      ).colorMapper,
      SvgColorSwap(
        {AppColors.ink: AppColors.inkNight},
        strokeless: const {'path'},
      ),
    );
    expect(appSvgLoader(AppIllustrationsLeitor.toolEraser).colorMapper, isNull);
  });

  test('o registro bate com os arquivos: todo SVG com stroke-dasharray está nele, com o elemento (o último), o '
      'viewBox, o padrão, a espessura, a cor, a ponta e a geometria', () {
    final comTraco = <String, String>{};
    for (final f in Directory('assets').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.svg')) continue;
      final txt = f.readAsStringSync();
      if (txt.contains('stroke-dasharray')) {
        comTraco[f.path.replaceAll(r'\', '/')] = txt;
      }
    }
    expect(comTraco.keys.toSet(), svgDashes.keys.toSet());
    for (final MapEntry(key: asset, value: svg) in comTraco.entries) {
      final d = svgDashes[asset]!;
      expect('stroke-dasharray'.allMatches(svg), hasLength(1), reason: asset);
      final caixa = RegExp(r'viewBox="0 0 ([\d.]+) ([\d.]+)"').firstMatch(svg)!;
      expect(
        d.viewBox,
        Size(double.parse(caixa.group(1)!), double.parse(caixa.group(2)!)),
      );
      final ultimo = RegExp(
        r'<(rect|path|ellipse|circle|line|polyline|polygon)\b([^>]*)>',
      ).allMatches(svg).last;
      expect(
        ultimo.group(1),
        d.element,
        reason: '$asset: o tracejado é o último',
      );
      final at = {
        for (final m in RegExp(
          r'([\w-]+)="([^"]*)"',
        ).allMatches(ultimo.group(2)!))
          m.group(1)!: m.group(2)!,
      };
      expect(at['stroke-dasharray']!.split(' ').map(double.parse), [
        d.on,
        d.off,
      ]);
      expect(double.parse(at['stroke-width']!), d.width);
      expect(
        Color(int.parse('FF${at['stroke']!.substring(1)}', radix: 16)),
        d.color,
      );
      expect(
        d.cap,
        at['stroke-linecap'] == 'round' ? StrokeCap.round : StrokeCap.butt,
      );
      final m = d.path.computeMetrics().toList();
      expect(m, hasLength(1));
      final inicio = m.single.getTangentForOffset(0)!.position;
      if (d.element == 'ellipse') {
        final cx = double.parse(at['cx']!), cy = double.parse(at['cy']!);
        final rx = double.parse(at['rx']!), ry = double.parse(at['ry']!);
        final b = d.path.getBounds();
        for (final (x, y) in [
          (b.left, cx - rx),
          (b.top, cy - ry),
          (b.right, cx + rx),
          (b.bottom, cy + ry),
        ]) {
          expect(x, moreOrLessEquals(y, epsilon: 1e-3));
        }
        // começa na ponta direita e desce (o sentido horário com y para baixo)
        expect(
          inicio,
          offsetMoreOrLessEquals(Offset(cx + rx, cy), epsilon: 1e-3),
        );
        expect(m.single.getTangentForOffset(1)!.position.dy, greaterThan(cy));
      } else {
        final arquivo = _caminhoDoD(at['d']!).computeMetrics().single;
        expect(
          m.single.length,
          moreOrLessEquals(arquivo.length, epsilon: 1e-3),
        );
        for (var i = 0; i <= 40; i++) {
          final t = arquivo.length * i / 40;
          expect(
            m.single.getTangentForOffset(t)!.position,
            offsetMoreOrLessEquals(
              arquivo.getTangentForOffset(t)!.position,
              epsilon: 1e-3,
            ),
          );
        }
      }
    }
  });

  Future<(Uint8List, int)> pintar(
    WidgetTester tester,
    String asset,
    Size tamanho, {
    double? opacity,
  }) async {
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await precacheSvgs(tester, [asset]);
    const chave = ValueKey('arte');
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: RepaintBoundary(
            key: chave,
            child: ColoredBox(
              color: _fundo,
              child: AppSvg(
                asset,
                size: tamanho.width,
                height: tamanho.height,
                opacity: opacity,
              ),
            ),
          ),
        ),
      ),
    );
    final imagem = await captureAt(tester, find.byKey(chave));
    return (await rgbaOf(tester, imagem), imagem.width);
  }

  /// O caminho de [d] amostrado no meio de cada traço e de cada vão (longe das pontas): `true` = tinta.
  List<(Offset, bool)> amostras(SvgDash d) {
    final out = <(Offset, bool)>[];
    final per = d.on + d.off;
    final cap = d.cap == StrokeCap.round ? d.width / 2 : 0.0;
    for (final m in d.path.computeMetrics()) {
      for (var s = 0.0; s + per <= m.length; s += per) {
        out
          ..add((m.getTangentForOffset(s + d.on / 2)!.position, true))
          ..add((
            m
                .getTangentForOffset(s + d.on + cap + (d.off - 2 * cap) / 2)!
                .position,
            false,
          ));
      }
    }
    return out;
  }

  /// [k] e [desvio]: o `viewBox` levado à caixa (`BoxFit.contain`, no centro).
  void conferir(
    Uint8List px,
    int largura,
    SvgDash d, {
    double k = 1,
    Offset desvio = Offset.zero,
  }) {
    final pontos = amostras(d);
    expect(pontos.length, greaterThan(10));
    for (final (ponto, tinta) in pontos) {
      final p = desvio + ponto * k;
      final i = ((p.dy * 3).floor() * largura + (p.dx * 3).floor()) * 4;
      final cor = Color.fromARGB(255, px[i], px[i + 1], px[i + 2]);
      final distancia =
          (cor.r - d.color.r).abs() +
          (cor.g - d.color.g).abs() +
          (cor.b - d.color.b).abs();
      if (tinta) {
        expect(distancia, lessThan(0.35), reason: 'traço em $p: $cor');
      } else {
        expect(distancia, greaterThan(0.35), reason: 'vão em $p: $cor');
      }
    }
  }

  testWidgets(
    'o Laço da prateleira: o tracejado começa na ponta direita e segue no sentido horário (o <ellipse> do SVG)',
    (tester) async {
      final (px, w) = await pintar(
        tester,
        AppIllustrationsLeitor.toolLasso,
        const Size(50, 70),
      );
      conferir(px, w, svgDashes[AppIllustrationsLeitor.toolLasso]!);
    },
  );

  testWidgets(
    'a dica "Gruda nas palavras": o tracejado do começo ao fim do caminho, com o último traço até (32, 9)',
    (tester) async {
      final (px, w) = await pintar(
        tester,
        AppIllustrationsLeitor.markerTip,
        const Size(34, 22),
      );
      conferir(px, w, svgDashes[AppIllustrationsLeitor.markerTip]!);
    },
  );

  testWidgets(
    'noutro tamanho, o traço acompanha o desenho (BoxFit.contain: escala 10/7 e centrado na horizontal)',
    (tester) async {
      final (px, w) = await pintar(
        tester,
        AppIllustrationsLeitor.toolLasso,
        const Size(100, 100),
      );
      const k = 100 / 70;
      conferir(
        px,
        w,
        svgDashes[AppIllustrationsLeitor.toolLasso]!,
        k: k,
        desvio: const Offset((100 - 50 * k) / 2, 0),
      );
    },
  );

  testWidgets('a troca de cores do desenho vale também para o traço pintado', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final troca = {AppColors.ink: AppColors.azure};
    await precacheSvgs(tester, [
      AppIllustrationsLeitor.toolLasso,
    ], colors: troca);
    const chave = ValueKey('arte');
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: RepaintBoundary(
            key: chave,
            child: ColoredBox(
              color: _fundo,
              child: AppSvg(
                AppIllustrationsLeitor.toolLasso,
                size: 50,
                height: 70,
                colors: troca,
              ),
            ),
          ),
        ),
      ),
    );
    final imagem = await captureAt(tester, find.byKey(chave));
    final px = await rgbaOf(tester, imagem);
    final d = svgDashes[AppIllustrationsLeitor.toolLasso]!;
    final (p, _) = amostras(d).first;
    final i = ((p.dy * 3).floor() * imagem.width + (p.dx * 3).floor()) * 4;
    expect(Color.fromARGB(255, px[i], px[i + 1], px[i + 2]), AppColors.azure);
  });

  testWidgets(
    'com uma cor só (color), o desenho não esmaece (o filtro é o srcIn) e o traço também não',
    (tester) async {
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await precacheSvgs(tester, [AppIllustrationsLeitor.toolLasso]);
      const chave = ValueKey('arte');
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: RepaintBoundary(
              key: chave,
              child: ColoredBox(
                color: _fundo,
                child: AppSvg(
                  AppIllustrationsLeitor.toolLasso,
                  size: 50,
                  height: 70,
                  color: AppColors.azure,
                  opacity: 0,
                ),
              ),
            ),
          ),
        ),
      );
      final imagem = await captureAt(tester, find.byKey(chave));
      final px = await rgbaOf(tester, imagem);
      final d = svgDashes[AppIllustrationsLeitor.toolLasso]!;
      final (p, _) = amostras(d).first;
      final i = ((p.dy * 3).floor() * imagem.width + (p.dx * 3).floor()) * 4;
      expect(Color.fromARGB(255, px[i], px[i + 1], px[i + 2]), AppColors.azure);
    },
  );

  testWidgets('o traço esmaece com o desenho (a moldura que aparece e some)', (
    tester,
  ) async {
    final (px, w) = await pintar(
      tester,
      AppIllustrationsLeitor.toolLasso,
      const Size(50, 70),
      opacity: 0,
    );
    final d = svgDashes[AppIllustrationsLeitor.toolLasso]!;
    for (final (p, _) in amostras(d)) {
      final i = ((p.dy * 3).floor() * w + (p.dx * 3).floor()) * 4;
      expect(
        Color.fromARGB(255, px[i], px[i + 1], px[i + 2]),
        _fundo,
        reason: '$p',
      );
    }
  });
}

/// O `d` de um `<path>` com M, C e S absolutos (os comandos dos desenhos tracejados); outro comando falha o teste.
Path _caminhoDoD(String d) {
  final partes = RegExp(r'([A-Za-z])([^A-Za-z]*)').allMatches(d);
  final p = Path();
  var ultimo = Offset.zero, controle = Offset.zero;
  for (final c in partes) {
    final n = RegExp(r'-?[\d.]+')
        .allMatches(c.group(2)!)
        .map((m) => double.parse(m.group(0)!))
        .toList();
    switch (c.group(1)) {
      case 'M':
        ultimo = Offset(n[0], n[1]);
        p.moveTo(ultimo.dx, ultimo.dy);
      case 'C':
        p.cubicTo(n[0], n[1], n[2], n[3], n[4], n[5]);
        controle = Offset(n[2], n[3]);
        ultimo = Offset(n[4], n[5]);
      case 'S':
        final r = ultimo * 2 - controle;
        p.cubicTo(r.dx, r.dy, n[0], n[1], n[2], n[3]);
        controle = Offset(n[0], n[1]);
        ultimo = Offset(n[2], n[3]);
      default:
        fail('comando ${c.group(1)} no d "$d"');
    }
  }
  return p;
}

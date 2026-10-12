// T01 — os traços tracejados dos desenhos SVG do arquivo (`stroke-dasharray`) como o Chromium: o padrão começa no
// início do elemento e segue pelos segmentos. O flutter_svg tracejava as curvas com outra fase (a elipse do Laço da
// prateleira começava no topo; a dica "Gruda nas palavras" da 23b perdia o último traço). O SVG é lido com o traço
// desse elemento escondido e a `AppSvg` o pinta por cima. T13.11 (D-285): os do scanner — os livros pelo `id` do
// elemento (outros `<rect>` do desenho têm traço) e a mira, com 4 subcaminhos; o tracejado não precisa ser o último,
// mas nada que vem depois dele o cruza. D-286: o traço é medido na escala da pintura, como o Chromium; os 5 contra o
// Chromium a 3× e a 8× (as referências de `tools/medicao/tracejados_chromium.js`).
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:app_leitura/core/design_system/painters/svg_dash_painter.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/tokens/app_illustrations_leitor.dart';
import 'package:app_leitura/core/design_system/tokens/app_illustrations_scanner.dart';
import 'package:app_leitura/core/design_system/widgets/app_svg.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/capture.dart';
import '../support/precache_svgs.dart';

const _fundo = Color(0xFFF7F0E3);
const _refs = 'docs/design/medicao/projeto/png/tracejados';

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

  test('T13.11 (D-285): com "#", a troca esconde só o traço do elemento com esse id (os outros do mesmo nome ficam)', () {
    final m = SvgColorSwap(const {}, strokeless: const {'#tracejado'});
    expect(
      m.substitute('tracejado', 'rect', 'stroke', AppColors.ink),
      const Color(0x00000000),
    );
    expect(
      m.substitute('tracejado', 'rect', 'fill', AppColors.ink),
      AppColors.ink,
    );
    expect(m.substitute(null, 'rect', 'stroke', AppColors.ink), AppColors.ink);
    expect(
      m.substitute('outro', 'rect', 'stroke', AppColors.ink),
      AppColors.ink,
    );
    // sem o "#", é um nome de elemento: não esconde pelo id
    expect(
      SvgColorSwap(
        const {},
        strokeless: const {'tracejado'},
      ).substitute('tracejado', 'rect', 'stroke', AppColors.ink),
      AppColors.ink,
    );
    expect(m, isNot(SvgColorSwap(const {}, strokeless: const {'rect'})));
  });

  test('os desenhos tracejados: o Laço (a elipse, 4/3, 1,7), a dica (o caminho, 2,5/2,5, 1,6 redondo) e os do '
      'scanner (T13.11: os livros pelo id, 5/4 coral e 4/3 tinta; a mira, 2/9, 5,5 creme redonda)', () {
    final laco = svgDashes[AppIllustrationsLeitor.toolLasso]!;
    expect(
      (
        laco.element,
        laco.id,
        laco.on,
        laco.off,
        laco.width,
        laco.color,
        laco.cap,
      ),
      ('ellipse', null, 4.0, 3.0, 1.7, AppColors.ink, StrokeCap.butt),
    );
    final dica = svgDashes[AppIllustrationsLeitor.markerTip]!;
    expect(
      (
        dica.element,
        dica.id,
        dica.on,
        dica.off,
        dica.width,
        dica.color,
        dica.cap,
      ),
      ('path', null, 2.5, 2.5, 1.6, AppColors.flame, StrokeCap.round),
    );
    final codigo = svgDashes[AppIllustrationsScanner.livroCodigoBarras]!;
    expect(
      (
        codigo.element,
        codigo.id,
        codigo.on,
        codigo.off,
        codigo.width,
        codigo.color,
        codigo.cap,
      ),
      ('rect', 'tracejado', 5.0, 4.0, 2.4, AppColors.flame, StrokeCap.butt),
    );
    final interrogacao = svgDashes[AppIllustrationsScanner.livroInterrogacao]!;
    expect(
      (
        interrogacao.element,
        interrogacao.id,
        interrogacao.on,
        interrogacao.off,
        interrogacao.width,
        interrogacao.color,
        interrogacao.cap,
      ),
      ('rect', 'tracejado', 4.0, 3.0, 1.3, AppColors.ink, StrokeCap.butt),
    );
    final mira = svgDashes[AppIllustrationsScanner.miraScannerTracejada]!;
    expect(
      (
        mira.element,
        mira.id,
        mira.on,
        mira.off,
        mira.width,
        mira.color,
        mira.cap,
      ),
      ('path', null, 2.0, 9.0, 5.5, AppColors.surface, StrokeCap.round),
    );
    expect(svgDashes.keys, hasLength(5));
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
    expect(
      appSvgLoader(AppIllustrationsScanner.livroCodigoBarras).colorMapper,
      SvgColorSwap(const {}, strokeless: const {'#tracejado'}),
    );
    expect(
      appSvgLoader(AppIllustrationsScanner.miraScannerTracejada).colorMapper,
      SvgColorSwap(const {}, strokeless: const {'path'}),
    );
    expect(appSvgLoader(AppIllustrationsLeitor.toolEraser).colorMapper, isNull);
  });

  test(
    'o registro bate com os arquivos: todo SVG com stroke-dasharray está nele, com o elemento (pelo nome ou pelo '
    'id), o viewBox, o padrão, a espessura, a cor, a ponta e a geometria',
    () {
      final comTraco = _tracejados();
      expect(comTraco.keys.toSet(), svgDashes.keys.toSet());
      for (final MapEntry(key: asset, value: svg) in comTraco.entries) {
        final d = svgDashes[asset]!;
        expect('stroke-dasharray'.allMatches(svg), hasLength(1), reason: asset);
        final raiz = _atributos(
          RegExp('<svg[^>]*>').firstMatch(svg)!.group(0)!,
        );
        final caixa = raiz['viewBox']!.split(' ').map(double.parse).toList();
        expect(caixa.take(2), [0, 0], reason: asset);
        expect(d.viewBox, Size(caixa[2], caixa[3]), reason: asset);
        final el = _tracejado(svg);
        expect(el.nome, d.element, reason: asset);
        final at = el.atributos;
        expect(
          at['id'],
          d.id,
          reason: '$asset: o id do registro é o do elemento',
        );
        if (d.id == null) {
          // pelo nome, a troca esconde o traço de todo elemento com esse nome: nenhum outro pode ter traço, nem herdado
          expect(
            _elementos(svg).where(
              (e) => e.nome == d.element && e.atributos.containsKey('stroke'),
            ),
            hasLength(1),
            reason: '$asset: outro <${d.element}> com traço perderia o dele',
          );
          expect(raiz.containsKey('stroke'), isFalse, reason: asset);
          expect(
            RegExp('<g [^>]*stroke=').hasMatch(svg),
            isFalse,
            reason: asset,
          );
        } else {
          expect(' id="${d.id}"'.allMatches(svg), hasLength(1), reason: asset);
        }
        expect(at['stroke-dasharray']!.split(' ').map(double.parse), [
          d.on,
          d.off,
        ]);
        expect(double.parse(at['stroke-width']!), d.width);
        expect(
          Color(int.parse('FF${at['stroke']!.substring(1)}', radix: 16)),
          d.color,
        );
        // a ponta pode vir da raiz (a mira)
        expect(
          d.cap,
          (at['stroke-linecap'] ?? raiz['stroke-linecap']) == 'round'
              ? StrokeCap.round
              : StrokeCap.butt,
          reason: asset,
        );
        _mesmaGeometria(d, at, asset);
      }
    },
  );

  testWidgets(
    'T13.11 (D-285): nada que vem depois do tracejado no arquivo cruza o traço — a AppSvg o pinta por cima de tudo; '
    'o Chromium, na ordem do arquivo (os <text> voltam em AppText, por cima do desenho inteiro)',
    (tester) async {
      for (final MapEntry(key: asset, value: svg) in _tracejados().entries) {
        final d = svgDashes[asset]!;
        final el = _tracejado(svg);
        // filho direto da raiz: o que vem depois dele no texto é o que é desenhado depois
        final antes = svg.substring(0, el.inicio);
        expect(
          '<g'.allMatches(antes).length,
          '</g>'.allMatches(antes).length,
          reason: '$asset: o tracejado dentro de um <g>',
        );
        final raiz = RegExp('<svg[^>]*>').firstMatch(svg)!.group(0)!;
        final depois = svgWithoutText(
          svg.substring(el.fim, svg.lastIndexOf('</svg>')),
        );
        const k = 8.0;
        final w = (d.viewBox.width * k).round();
        final h = (d.viewBox.height * k).round();
        final camadas = await tester.runAsync(() async {
          final info = await vg.loadPicture(
            SvgStringLoader('$raiz$depois</svg>'),
            null,
          );
          final resto = ui.PictureRecorder();
          Canvas(resto)
            ..scale(k)
            ..drawPicture(info.picture);
          info.picture.dispose();
          // o traço inteiro, sem os vãos: nada pode passar nem pelos vãos
          final traco = ui.PictureRecorder();
          Canvas(traco)
            ..scale(k)
            ..drawPath(
              d.path,
              Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = d.width
                ..strokeCap = d.cap,
            );
          return (await _rgba(resto, w, h), await _rgba(traco, w, h));
        });
        final (resto, traco) = camadas!;
        var cruzam = 0, desenho = 0;
        for (var i = 3; i < resto.length; i += 4) {
          if (resto[i] > 0) desenho++;
          if (resto[i] > 0 && traco[i] > 0) cruzam++;
        }
        expect(
          cruzam,
          0,
          reason: '$asset: $cruzam pixels do que vem depois sobre o traço',
        );
        if (d.id != null) {
          // os livros: há o que conferir (o risco do código; a estrela)
          expect(desenho, greaterThan(500), reason: asset);
        }
      }
    },
  );

  Future<(Uint8List, int)> pintar(
    WidgetTester tester,
    String asset,
    Size tamanho, {
    double? opacity,
    Color fundo = _fundo,
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
              color: fundo,
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

  /// O caminho de [d] amostrado no meio de cada traço e de cada vão (longe das pontas): `true` = tinta. Medido na
  /// [escala] da pintura, como o pintor (D-286): o encaixe × a densidade (3).
  List<(Offset, bool)> amostras(SvgDash d, {double escala = 3}) {
    final out = <(Offset, bool)>[];
    final per = (d.on + d.off) * escala;
    final cap = d.cap == StrokeCap.round ? d.width / 2 * escala : 0.0;
    final grande = d.path.transform(
      Matrix4.diagonal3Values(escala, escala, 1).storage,
    );
    for (final m in grande.computeMetrics()) {
      for (var s = 0.0; s + per <= m.length; s += per) {
        out
          ..add((
            m.getTangentForOffset(s + d.on * escala / 2)!.position / escala,
            true,
          ))
          ..add((
            m
                    .getTangentForOffset(
                      s + d.on * escala + cap + (d.off * escala - 2 * cap) / 2,
                    )!
                    .position /
                escala,
            false,
          ));
      }
    }
    return out;
  }

  Color cor(Uint8List px, int largura, Offset p) {
    final i = ((p.dy * 3).floor() * largura + (p.dx * 3).floor()) * 4;
    return Color.fromARGB(255, px[i], px[i + 1], px[i + 2]);
  }

  /// [k] e [desvio]: o `viewBox` levado à caixa (`BoxFit.contain`, no centro).
  void conferir(
    Uint8List px,
    int largura,
    SvgDash d, {
    double k = 1,
    Offset desvio = Offset.zero,
  }) {
    final pontos = amostras(d, escala: k * 3);
    expect(pontos.length, greaterThan(10));
    for (final (ponto, tinta) in pontos) {
      final p = desvio + ponto * k;
      final c = cor(px, largura, p);
      final distancia =
          (c.r - d.color.r).abs() +
          (c.g - d.color.g).abs() +
          (c.b - d.color.b).abs();
      if (tinta) {
        expect(distancia, lessThan(0.35), reason: 'traço em $p: $c');
      } else {
        expect(distancia, greaterThan(0.35), reason: 'vão em $p: $c');
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
    'T13.11: o livro do código de barras (39) — o tracejado coral começa em (17, 53), no sentido horário, e os outros '
    '<rect> continuam com o traço de tinta (só o do id sai escondido)',
    (tester) async {
      final (px, w) = await pintar(
        tester,
        AppIllustrationsScanner.livroCodigoBarras,
        const Size(86, 104),
      );
      conferir(px, w, svgDashes[AppIllustrationsScanner.livroCodigoBarras]!);
      // o contorno do livro (x 3, 1,5) e o da etiqueta (x 16, 1,3), no meio do traço
      for (final p in [const Offset(3, 50), const Offset(16, 72)]) {
        expect(cor(px, w, p), AppColors.ink, reason: '$p');
      }
    },
  );

  testWidgets('T13.11: o livro do "?" (40) — o tracejado de tinta sobre o fundo creme do próprio <rect>, e o contorno do livro '
      'com o traço', (tester) async {
    final (px, w) = await pintar(
      tester,
      AppIllustrationsScanner.livroInterrogacao,
      const Size(84, 110),
    );
    conferir(px, w, svgDashes[AppIllustrationsScanner.livroInterrogacao]!);
    for (final p in [const Offset(3, 50), const Offset(40, 3)]) {
      expect(cor(px, w, p), AppColors.ink, reason: '$p');
    }
    // dentro do tracejado, o creme do <rect> (o preenchimento continua no desenho)
    expect(cor(px, w, const Offset(30, 30)), AppColors.surface);
  });

  testWidgets(
    'T13.11: a mira tracejada (41) — cada um dos 4 cantos recomeça o padrão, com as pontas redondas, sobre o escuro',
    (tester) async {
      final (px, w) = await pintar(
        tester,
        AppIllustrationsScanner.miraScannerTracejada,
        const Size(290, 170),
        fundo: AppColors.ink,
      );
      final d = svgDashes[AppIllustrationsScanner.miraScannerTracejada]!;
      expect(d.path.computeMetrics(), hasLength(4));
      conferir(px, w, d);
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
    expect(cor(px, imagem.width, p), AppColors.azure);
  });

  testWidgets(
    'a meio esmaecimento, o traço fica a meio caminho entre a tinta e o que está embaixo',
    (tester) async {
      final (px, w) = await pintar(
        tester,
        AppIllustrationsLeitor.toolLasso,
        const Size(50, 70),
        opacity: 0.5,
      );
      final d = svgDashes[AppIllustrationsLeitor.toolLasso]!;
      double distancia(Color a, Color b) =>
          (a.r - b.r).abs() + (a.g - b.g).abs() + (a.b - b.b).abs();

      final pontos = amostras(d);
      for (var k = 0; k + 1 < pontos.length; k += 2) {
        final (traco, _) = pontos[k];
        final (vao, _) = pontos[k + 1];
        // longe da tinta cheia (seria ~0) e bem mais escuro que o vão ao lado
        expect(distancia(cor(px, w, traco), AppColors.ink), greaterThan(0.6));
        expect(
          distancia(cor(px, w, traco), AppColors.ink),
          lessThan(distancia(cor(px, w, vao), AppColors.ink) - 0.6),
        );
      }
    },
  );

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
      expect(cor(px, imagem.width, p), AppColors.azure);
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
      expect(cor(px, w, p), _fundo, reason: '$p');
    }
  });

  testWidgets(
    'D-286: a AppSvg passa ao pintor a densidade do aparelho, e o traço é medido na escala da pintura',
    (tester) async {
      tester.view.devicePixelRatio = 2.75;
      addTearDown(tester.view.reset);
      await precacheSvgs(tester, [AppIllustrationsLeitor.toolLasso]);
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: AppSvg(
              AppIllustrationsLeitor.toolLasso,
              size: 100,
              height: 100,
            ),
          ),
        ),
      );
      expect(_pintor(tester).devicePixelRatio, 2.75);
      // o MediaQuery, quando há, manda
      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(devicePixelRatio: 1.5),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Center(
              child: AppSvg(
                AppIllustrationsLeitor.toolLasso,
                size: 100,
                height: 100,
              ),
            ),
          ),
        ),
      );
      expect(_pintor(tester).devicePixelRatio, 1.5);
      // na escala 8, a elipse mede o que o Chromium mede: 80,67 (no viewBox, 80,22). São 12 traços de 4 a cada 7, e o
      // último começa onde a medida na escala 8 chega a 77 — cerca de 0,45 adiante do que a medida no viewBox dá
      final d = svgDashes[AppIllustrationsLeitor.toolLasso]!;
      Offset inicioDoUltimo(Path p) =>
          p.computeMetrics().last.getTangentForOffset(0)!.position;
      final na8 = d.path
          .transform(Matrix4.diagonal3Values(8, 8, 1).storage)
          .computeMetrics()
          .single;
      expect(na8.length / 8, moreOrLessEquals(80.67, epsilon: 5e-3));
      expect(d.dashedAt(8).computeMetrics(), hasLength(12));
      expect(
        inicioDoUltimo(d.dashedAt(8)),
        offsetMoreOrLessEquals(
          na8.getTangentForOffset(77 * 8)!.position / 8,
          epsilon: 1e-3,
        ),
      );
      expect(
        (inicioDoUltimo(d.dashedAt(8)) - inicioDoUltimo(d.dashedAt(1)))
            .distance,
        greaterThan(0.3),
      );
      expect(identical(d.dashedAt(8), d.dashedAt(8)), isTrue);
    },
  );

  // A prova da D-286: o traço que a AppSvg monta (o pintor dela, com a densidade que ela passou), sozinho e sem fundo,
  // contra o do Chromium no mesmo tamanho e escala.
  for (final MapEntry(key: asset, value: d) in svgDashes.entries) {
    final nome = asset.split('/').last.replaceAll('.svg', '');
    for (final k in [3, 8]) {
      testWidgets(
        'D-286: $nome a $k× — o traço da AppSvg é o do Chromium ($_refs/${nome}_x$k.png)',
        (tester) async {
          tester.view.devicePixelRatio = k.toDouble();
          addTearDown(tester.view.reset);
          await precacheSvgs(tester, [asset]);
          await tester.pumpWidget(
            Directionality(
              textDirection: TextDirection.ltr,
              child: Center(
                child: AppSvg(
                  asset,
                  size: d.viewBox.width,
                  height: d.viewBox.height,
                ),
              ),
            ),
          );
          final pintor = _pintor(tester);
          expect(pintor.devicePixelRatio, k);
          final w = (d.viewBox.width * k).round();
          final h = (d.viewBox.height * k).round();
          final imagens = await tester.runAsync(() async {
            final rec = ui.PictureRecorder();
            pintor.paint(Canvas(rec)..scale(k.toDouble()), d.viewBox);
            final codec = await ui.instantiateImageCodec(
              File('$_refs/${nome}_x$k.png').readAsBytesSync(),
            );
            final ref = (await codec.getNextFrame()).image;
            final bytes = await ref.toByteData(
              format: ui.ImageByteFormat.rawStraightRgba,
            );
            return (
              await _rgba(rec, w, h),
              bytes!.buffer.asUint8List(),
              (ref.width, ref.height),
            );
          });
          final (nosso, ref, tamanho) = imagens!;
          expect(tamanho, (w, h));
          var fortes = 0, leves = 0, tinta = 0, outraCor = 0;
          for (var i = 3; i < ref.length; i += 4) {
            final dif = (nosso[i] - ref[i]).abs();
            if (dif > 128) fortes++;
            if (dif > 24) leves++;
            if (ref[i] > 128) tinta++;
            if (ref[i] == 255 &&
                nosso[i] == 255 &&
                [for (var c = 1; c <= 3; c++) (nosso[i - c] - ref[i - c]).abs()]
                    .any((x) => x > 2)) {
              outraCor++;
            }
          }
          expect(tinta, greaterThan(200), reason: 'a referência tem o traço');
          expect(
            fortes,
            0,
            reason: '$fortes pixels com o traço num e o vão no outro',
          );
          expect(
            leves,
            lessThanOrEqualTo(64),
            reason: 'só o serrilhado: $leves',
          );
          expect(outraCor, 0, reason: 'a cor do traço');
        },
      );
    }
  }
}

SvgDashPainter _pintor(WidgetTester tester) =>
    tester
            .widget<CustomPaint>(
              find.byWidgetPredicate(
                (w) =>
                    w is CustomPaint && w.foregroundPainter is SvgDashPainter,
              ),
            )
            .foregroundPainter!
        as SvgDashPainter;

Future<Uint8List> _rgba(ui.PictureRecorder rec, int w, int h) async {
  final imagem = await rec.endRecording().toImage(w, h);
  final bytes = await imagem.toByteData(
    format: ui.ImageByteFormat.rawStraightRgba,
  );
  return bytes!.buffer.asUint8List();
}

/// Os SVGs de `assets/` com `stroke-dasharray` (caminho com "/" → texto).
Map<String, String> _tracejados() {
  final out = <String, String>{};
  for (final f in Directory('assets').listSync(recursive: true)) {
    if (f is! File || !f.path.endsWith('.svg')) continue;
    final txt = f.readAsStringSync();
    if (txt.contains('stroke-dasharray')) {
      out[f.path.replaceAll(Platform.pathSeparator, '/')] = txt;
    }
  }
  return out;
}

typedef _Elemento = ({
  String nome,
  Map<String, String> atributos,
  int inicio,
  int fim,
});

/// Os elementos desenháveis do SVG, em ordem, com os atributos e onde terminam (depois do fechamento, se houver).
List<_Elemento> _elementos(String svg) => [
  for (final m in RegExp(
    '<(rect|path|ellipse|circle|line|polyline|polygon)( [^>]*)?>',
  ).allMatches(svg))
    (
      nome: m.group(1)!,
      atributos: _atributos(m.group(0)!),
      inicio: m.start,
      fim: svg.startsWith('</${m.group(1)}>', m.end)
          ? m.end + m.group(1)!.length + 3
          : m.end,
    ),
];

_Elemento _tracejado(String svg) =>
    _elementos(svg)
        .singleWhere((e) => e.atributos.containsKey('stroke-dasharray'));

Map<String, String> _atributos(String tag) => {
  for (final m in RegExp('([A-Za-z_:-]+)="([^"]*)"').allMatches(tag))
    m.group(1)!: m.group(2)!,
};

/// O caminho do registro de [d] contra o do elemento no arquivo ([at]).
void _mesmaGeometria(SvgDash d, Map<String, String> at, String asset) {
  double n(String k) => double.parse(at[k]!);
  switch (d.element) {
    case 'ellipse':
      final m = d.path.computeMetrics().toList();
      expect(m, hasLength(1));
      final cx = n('cx'), cy = n('cy'), rx = n('rx'), ry = n('ry');
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
        m.single.getTangentForOffset(0)!.position,
        offsetMoreOrLessEquals(Offset(cx + rx, cy), epsilon: 1e-3),
      );
      expect(m.single.getTangentForOffset(1)!.position.dy, greaterThan(cy));
    case 'rect':
      final x = n('x'), y = n('y'), w = n('width'), h = n('height');
      final rx = double.parse(at['rx'] ?? at['ry'] ?? '0');
      expect(
        double.parse(at['ry'] ?? at['rx'] ?? '0'),
        rx,
        reason: '$asset: cantos circulares',
      );
      // o caminho do <rect> de cantos redondos no Chromium: começa em (x + rx, y) e segue no sentido horário
      final r = Radius.circular(rx);
      _mesmoCaminho(
        d.path,
        Path()
          ..moveTo(x + rx, y)
          ..lineTo(x + w - rx, y)
          ..arcToPoint(Offset(x + w, y + rx), radius: r)
          ..lineTo(x + w, y + h - rx)
          ..arcToPoint(Offset(x + w - rx, y + h), radius: r)
          ..lineTo(x + rx, y + h)
          ..arcToPoint(Offset(x, y + h - rx), radius: r)
          ..lineTo(x, y + rx)
          ..arcToPoint(Offset(x + rx, y), radius: r)
          ..close(),
        asset,
      );
    case 'path':
      _mesmoCaminho(d.path, _caminhoDoD(at['d']!), asset);
    default:
      fail('$asset: elemento <${d.element}> sem conferência de geometria');
  }
}

/// [path] e [esperado]: os mesmos contornos (fechados ou não), cada um com o mesmo comprimento e os mesmos 41 pontos.
void _mesmoCaminho(Path path, Path esperado, String asset) {
  final a = path.computeMetrics().toList();
  final b = esperado.computeMetrics().toList();
  expect(a, hasLength(b.length), reason: '$asset: os contornos');
  for (var c = 0; c < a.length; c++) {
    expect(a[c].isClosed, b[c].isClosed, reason: '$asset: contorno $c');
    expect(
      a[c].length,
      moreOrLessEquals(b[c].length, epsilon: 1e-3),
      reason: '$asset: contorno $c',
    );
    for (var i = 0; i <= 40; i++) {
      final t = b[c].length * i / 40;
      expect(
        a[c].getTangentForOffset(t)!.position,
        offsetMoreOrLessEquals(
          b[c].getTangentForOffset(t)!.position,
          epsilon: 1e-3,
        ),
        reason: '$asset: contorno $c em $t',
      );
    }
  }
}

/// O `d` de um `<path>` com M, L, H, V, C, S, A e Z absolutos, um conjunto de números por comando (os desenhos
/// tracejados); outro comando ou outra contagem falha o teste.
Path _caminhoDoD(String d) {
  const argumentos = {
    'M': 2,
    'L': 2,
    'H': 1,
    'V': 1,
    'C': 6,
    'S': 4,
    'A': 7,
    'Z': 0,
  };
  final p = Path();
  var ultimo = Offset.zero, controle = Offset.zero;
  for (final c in RegExp('([A-Za-z])([^A-Za-z]*)').allMatches(d)) {
    final cmd = c.group(1)!;
    final n = RegExp('-?[0-9.]+')
        .allMatches(c.group(2)!)
        .map((m) => double.parse(m.group(0)!))
        .toList();
    if (argumentos[cmd] != n.length) {
      fail('comando $cmd com ${n.length} números no d "$d"');
    }
    switch (cmd) {
      case 'M':
        ultimo = Offset(n[0], n[1]);
        p.moveTo(ultimo.dx, ultimo.dy);
      case 'L':
        ultimo = Offset(n[0], n[1]);
        p.lineTo(ultimo.dx, ultimo.dy);
      case 'H':
        ultimo = Offset(n[0], ultimo.dy);
        p.lineTo(ultimo.dx, ultimo.dy);
      case 'V':
        ultimo = Offset(ultimo.dx, n[0]);
        p.lineTo(ultimo.dx, ultimo.dy);
      case 'C':
        p.cubicTo(n[0], n[1], n[2], n[3], n[4], n[5]);
        controle = Offset(n[2], n[3]);
        ultimo = Offset(n[4], n[5]);
        continue;
      case 'S':
        final r = ultimo * 2 - controle;
        p.cubicTo(r.dx, r.dy, n[0], n[1], n[2], n[3]);
        controle = Offset(n[0], n[1]);
        ultimo = Offset(n[2], n[3]);
        continue;
      case 'A':
        ultimo = Offset(n[5], n[6]);
        p.arcToPoint(
          ultimo,
          radius: Radius.elliptical(n[0], n[1]),
          rotation: n[2],
          largeArc: n[3] != 0,
          clockwise: n[4] != 0,
        );
      case 'Z':
        p.close();
    }
    // depois de um comando que não é curva, o reflexo do S é o próprio ponto
    controle = ultimo;
  }
  return p;
}

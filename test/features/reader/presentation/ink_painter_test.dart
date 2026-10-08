// G16.5 — a pintura da tinta (§5): o contorno da Caneta com a largura da D-159 (Média de 1,2 mm = 2,2 px; Grossa
// 1,8×), a Reta como cápsula da largura do traço, o ponto como círculo, a cor e o alpha do traço (D-59); o cache de
// `Picture` (mesma página e revisão = a mesma; revisão nova = outra; até 4 páginas, as velhas descartadas); a mancha
// do grifo feito à mão (D-161) na caixa de cada linha (5 px para os lados, de 3 px abaixo do topo da letra até 1 px
// acima da base), a 90 % e multiplicada; no Noite, a técnica da D-133. G17 (R25): a mancha na altura do grifo (Baixa
// do meio da letra, Alta da letra toda) e só no fundo — o sublinhado e o ondulado à mão pintam como os da tela 21.
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:app_leitura/features/reader/annotations/domain/annotation.dart'
    show FillHeight, HighlightStyle;
import 'package:app_leitura/features/reader/annotations/ink/ink_stroke.dart';
import 'package:app_leitura/features/reader/layout/display_page.dart';
import 'package:app_leitura/features/reader/presentation/ink_painter.dart';
import 'package:app_leitura/features/reader/presentation/page_marks.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

InkStroke _traco(
  List<(double, double)> pts, {
  InkTool tool = InkTool.pen,
  int largura = 120,
  int argb = 0xFFFF552E,
  double pressao = 0.5,
}) => InkStroke(
  tool: tool.code,
  tip: 0,
  argb: argb,
  widthCentiMm: largura,
  points: [
    for (var i = 0; i < pts.length; i++)
      InkPoint(pts[i].$1, pts[i].$2, pressao, 8 * i),
  ],
);

/// Uma linha reta de (10, 50) a (110, 50), um ponto a cada 2 px.
List<(double, double)> get _reta => [
  for (var i = 0; i <= 50; i++) (10.0 + 2 * i, 50.0),
];

/// Grava os caminhos pintados (a cor e o modo de cada um) e as `Picture`.
final class _Tela implements ui.Canvas {
  final chamadas = <String>[];
  final caminhos = <(ui.Path, Color, BlendMode)>[];

  @override
  void drawPath(ui.Path path, Paint paint) {
    chamadas.add('caminho');
    caminhos.add((path, paint.color, paint.blendMode));
  }

  @override
  Float64List getTransform() {
    chamadas.add('texto');
    return Float64List(16);
  }

  @override
  Object? noSuchMethod(Invocation invocation) => null;
}

/// Uma linha de texto: o caractere i ocupa 2 px a partir de x = 30; letras de 120 a 140, área do texto de 122,41 a
/// 152,85 (em 20,5).
final class _Pagina implements DisplayPage {
  _Pagina({this.letra});

  final Color? letra;
  static const Rect caixaDaLetra = Rect.fromLTWH(45, 124, 8, 12);

  @override
  void paint(ui.Canvas canvas) {
    canvas.getTransform();
    final l = letra;
    if (l != null) canvas.drawRect(caixaDaLetra, Paint()..color = l);
  }

  @override
  List<TextLineBox> boxesOf(int unit, int from, int to) => unit == 2
      ? [
          (
            rect: Rect.fromLTRB(30.0 + 2 * from, 120, 30.0 + 2 * to, 140),
            baseline: 149.6,
            textTop: 122.41,
            textBottom: 152.85,
            em: 20.5,
          ),
        ]
      : const [];

  @override
  bool get alive => true;
  @override
  bool get opaque => false;
  @override
  String get spokenText => '';
  @override
  LinkHit? linkAt(ui.Offset p) => null;
  @override
  List<Rect> rectsOf(int unit, int from, int to) => const [];
  @override
  ReaderRange? get shown => (unit: 2, from: 0, to: 200);
  @override
  ReaderSpot? spotAt(ui.Offset p) => null;
  @override
  ReaderRange? wordAround(ReaderSpot s) => null;
  @override
  ReaderRange? wordAt(ui.Offset p) => null;
  @override
  String textOf(int unit, int from, int to) => '';
}

const _amarelo = Color(0xFFFED170);

PaintedHighlight _aMao(
  int from,
  int to, {
  Color color = _amarelo,
  HighlightStyle style = HighlightStyle.fill,
  FillHeight height = FillHeight.medium,
}) => PaintedHighlight(
  id: 'grifo-a-mao',
  range: (unit: 2, from: from, to: to),
  color: color,
  style: style,
  height: height,
);

void main() {
  group('inkPath', () {
    test('Caneta: o contorno do freehand com a largura da D-159 (Média 1,2 mm = 2,2 px)', () {
      final b = inkPath(_traco(_reta)).getBounds();
      expect(b.height, closeTo(2.2, 0.02));
      expect(b.top, closeTo(50 - 1.1, 0.02));
      expect(b.left, closeTo(10 - 1.1, 0.3));
      expect(b.right, closeTo(110 + 1.1, 0.3));
      // Grossa (1,8×): 2,16 mm = 3,96 px
      final grossa = inkPath(_traco(_reta, largura: 216)).getBounds();
      expect(grossa.height, closeTo(3.96, 0.02));
    });

    test(
      'Reta: a cápsula da largura do traço entre o primeiro e o último ponto',
      () {
        final r = inkPath(_traco([(28, 100), (128, 100)], tool: InkTool.line));
        final b = r.getBounds();
        expect(b.left, closeTo(28 - 1.1, 1e-4));
        expect(b.right, closeTo(128 + 1.1, 1e-4));
        expect(b.top, closeTo(100 - 1.1, 1e-4));
        expect(b.height, closeTo(2.2, 1e-4));
        // inclinada: o meio e as pontas dentro; fora da faixa, não
        final d = inkPath(
          _traco([(0, 0), (100, 100)], tool: InkTool.line, largura: 600),
        );
        expect(d.contains(const Offset(50, 50)), isTrue);
        expect(
          d.contains(const Offset(102, 102)),
          isTrue,
          reason: 'ponta redonda',
        );
        expect(d.contains(const Offset(60, 40)), isFalse);
        expect(d.contains(const Offset(106, 106)), isFalse);
      },
    );

    test('um ponto só (ou a Reta sem comprimento): o círculo da largura', () {
      for (final t in [
        _traco([(40, 60)]),
        _traco([(40, 60), (40, 60)], tool: InkTool.line),
      ]) {
        final b = inkPath(t).getBounds();
        expect(b.center.dx, closeTo(40, 1e-4));
        expect(b.center.dy, closeTo(60, 1e-4));
        expect(b.width, closeTo(2.2, 1e-4));
        expect(b.height, closeTo(2.2, 1e-4));
      }
      expect(inkPath(_traco(const [])).getBounds(), Rect.zero);
    });
  });

  test('paintInk: cada traço preenchido na cor e no alpha com que foi feito (D-59)', () {
    final tela = _Tela();
    paintInk(tela, [
      _traco(_reta),
      _traco([(0, 0), (9, 9)], tool: InkTool.line, argb: 0x80B6ACE4),
    ]);
    expect(
      [for (final c in tela.caminhos) c.$2.toARGB32()],
      [0xFFFF552E, 0x80B6ACE4],
    );
    expect(
      [for (final c in tela.caminhos) c.$3],
      [BlendMode.srcOver, BlendMode.srcOver],
    );
  });

  group('InkPictureCache', () {
    test('mesma página e revisão = a mesma Picture; revisão nova = outra, e a velha é descartada', () {
      final cache = InkPictureCache();
      addTearDown(cache.dispose);
      final pagina = _Pagina();
      var gravou = 0;
      List<InkStroke> tinta() {
        gravou++;
        return [_traco(_reta)];
      }

      final a = cache.pictureOf(pagina, 1, tinta)!;
      expect(cache.pictureOf(pagina, 1, tinta), same(a));
      expect(gravou, 1);
      final b = cache.pictureOf(pagina, 2, tinta)!;
      expect(b, isNot(same(a)));
      expect(gravou, 2);
      expect(a.debugDisposed, isTrue);
      expect(b.debugDisposed, isFalse);
    });

    test(
      'até 4 páginas: a quinta descarta a usada há mais tempo; sem tinta, nada',
      () {
        final cache = InkPictureCache();
        addTearDown(cache.dispose);
        final paginas = [for (var i = 0; i < 5; i++) _Pagina()];
        final pics = [
          for (final p in paginas.take(4))
            cache.pictureOf(p, 1, () => [_traco(_reta)])!,
        ];
        // a primeira foi usada de novo: a segunda é a mais velha
        expect(cache.pictureOf(paginas[0], 1, () => []), same(pics[0]));
        cache.pictureOf(paginas[4], 1, () => [_traco(_reta)]);
        expect(
          [for (final p in pics) p.debugDisposed],
          [false, true, false, false],
        );
        expect(cache.pictureOf(_Pagina(), 1, () => []), isNull);
        cache.dispose();
        expect(pics[0].debugDisposed, isTrue);
      },
    );
  });

  group('mancha do grifo feito à mão (D-161)', () {
    test('a caixa de cada linha: 5 px para os lados, de 3 px abaixo do topo da letra até 1 px acima da base', () {
      final boxes = handHighlightBoxes(_Pagina(), [_aMao(10, 30)]);
      expect(boxes.single.box, const Rect.fromLTRB(45, 125.41, 95, 151.85));
      expect(boxes.single.color, _amarelo);
    });

    test('G17 (R25): a altura — Baixa do meio da letra, Alta da letra toda (até a base); os lados ficam', () {
      const area = 152.85 - 122.41;
      expect(
        handHighlightBoxes(_Pagina(), [
          _aMao(10, 30, height: FillHeight.low),
        ]).single.box,
        const Rect.fromLTRB(45, 122.41 + area / 2, 95, 151.85),
      );
      expect(
        handHighlightBoxes(_Pagina(), [
          _aMao(10, 30, height: FillHeight.high),
        ]).single.box,
        const Rect.fromLTRB(45, 122.41, 95, 152.85),
      );
    });

    test('G17 (R25): o sublinhado e o ondulado à mão não são mancha', () {
      expect(
        handHighlightBoxes(_Pagina(), [
          _aMao(10, 30, style: HighlightStyle.underline),
          _aMao(10, 30, style: HighlightStyle.wavy),
        ]),
        isEmpty,
      );
    });

    test('o caminho do arquivo (100×20) esticado na caixa', () {
      const box = Rect.fromLTRB(45, 125.41, 95, 151.85);
      final p = handHighlightPath(box);
      expect(p.contains(box.center), isTrue);
      // o caminho começa em x = 2 e vai até 99 (de 100); em cima, y ≈ 2,5–4 (de 20)
      expect(p.contains(Offset(box.left + 0.5, box.center.dy)), isFalse);
      expect(p.contains(Offset(box.right - 0.2, box.center.dy)), isFalse);
      expect(p.contains(Offset(box.center.dx, box.top + 0.3)), isFalse);
      expect(
        p.contains(Offset(box.left + 0.05 * box.width, box.center.dy)),
        isTrue,
      );
      final b = p.getBounds();
      expect(b.left, closeTo(box.left + 0.015 * box.width, 1e-4));
      expect(b.right, closeTo(box.left + 0.99 * box.width, 1e-4));
    });

    test('Creme: por cima do texto, a 90 % e multiplicada', () {
      final tela = _Tela();
      paintHandHighlights(tela, _Pagina(), [_aMao(10, 30)]);
      final (path, cor, modo) = tela.caminhos.single;
      expect(modo, BlendMode.multiply);
      // o `Paint` guarda a cor em float32: 0,9 vira 229/255
      expect(cor.a, closeTo(0.9, 0.003));
      expect(cor.withValues(alpha: 1).toARGB32(), _amarelo.toARGB32());
      expect(
        path.getBounds().center.dx,
        closeTo(const Rect.fromLTRB(45, 125.41, 95, 151.85).center.dx, 1),
      );
      // e nada por trás das letras
      final atras = _Tela();
      paintHandHighlightsBehind(atras, _Pagina(), [_aMao(10, 30)]);
      expect(atras.caminhos, isEmpty);
    });

    test('Noite (D-133): por trás D − cor; por cima D em diferença (D = o maior canal de letra e cor)', () {
      const letra = Color(0xFFE3D9C6);
      final atras = _Tela();
      paintHandHighlightsBehind(atras, _Pagina(), [
        _aMao(10, 30),
      ], lightText: letra);
      final frente = _Tela();
      paintHandHighlights(frente, _Pagina(), [_aMao(10, 30)], lightText: letra);
      expect(atras.caminhos.single.$3, BlendMode.srcOver);
      expect(
        atras.caminhos.single.$2.toARGB32(),
        channelMinus(channelMax(letra, _amarelo), _amarelo).toARGB32(),
      );
      expect(frente.caminhos.single.$3, BlendMode.difference);
      expect(
        frente.caminhos.single.$2.toARGB32(),
        channelMax(letra, _amarelo).toARGB32(),
      );
    });

    test('Noite, nos pixels: o fundo da mancha é a cor do grifo, a letra fica escura, fora nada muda', () async {
      const papel = Color(0xFF1F1B17);
      const letra = Color(0xFFE3D9C6);
      final pagina = _Pagina(letra: letra);
      final gravador = ui.PictureRecorder();
      final canvas = Canvas(gravador)
        ..drawRect(const Rect.fromLTWH(0, 0, 120, 160), Paint()..color = papel);
      final hs = [_aMao(5, 30)];
      paintHandHighlightsBehind(canvas, pagina, hs, lightText: letra);
      pagina.paint(canvas);
      paintHandHighlights(canvas, pagina, hs, lightText: letra);
      final img = await gravador.endRecording().toImage(120, 160);
      final bytes = (await img.toByteData())!;
      img.dispose();
      Color px(int x, int y) {
        final i = (y * 120 + x) * 4;
        return Color.fromARGB(
          bytes.getUint8(i + 3),
          bytes.getUint8(i),
          bytes.getUint8(i + 1),
          bytes.getUint8(i + 2),
        );
      }

      void quase(Color a, Color b, String r) {
        for (final (x, y) in [(a.r, b.r), (a.g, b.g), (a.b, b.b)]) {
          expect((x - y).abs() * 255, lessThanOrEqualTo(1), reason: r);
        }
      }

      quase(px(70, 138), _amarelo, 'o fundo da mancha');
      quase(px(10, 10), papel, 'fora da mancha');
      final palavra = px(48, 134);
      final contraste =
          (_amarelo.computeLuminance() + 0.05) /
          (palavra.computeLuminance() + 0.05);
      expect(contraste, greaterThan(4.5), reason: 'a letra escura');
    });
  });

  group('G17 — o Noite da tinta (D-174, R26)', () {
    const letra = Color(0xFFE3D9C6);
    InkStroke marca() => _traco(
      [(30, 130), (110, 130)],
      tool: InkTool.marker,
      argb: 0xE6FED170,
      largura: 870,
    );

    test('D-174: a tinta quase preta sai na cor das letras do Noite (o alpha fica); o roxo fica; no Creme, nada muda', () {
      final noite = _Tela();
      paintInk(noite, [
        _traco(_reta, argb: 0xFF1A1714),
        _traco(_reta, argb: 0xFF552CB7),
        _traco(_reta, argb: 0x801A1714),
      ], lightText: letra);
      expect(
        [for (final c in noite.caminhos) c.$2.toARGB32()],
        [0xFFE3D9C6, 0xFF552CB7, 0x80E3D9C6],
      );
      final creme = _Tela();
      paintInk(creme, [_traco(_reta, argb: 0xFF1A1714)]);
      expect(creme.caminhos.single.$2.toARGB32(), 0xFF1A1714);
      expect(inkArgbOn(0xFF1A1714, letra), 0xFFE3D9C6);
      expect(inkArgbOn(0xFF1A1714, null), 0xFF1A1714);
      expect(inkArgbOn(0xFFFF552E, letra), 0xFFFF552E);
      // o limite de 1,5 : 1 contra #1F1B17: #383838 (1,46) troca; #3A3A3A (1,50) fica
      expect(inkArgbOn(0xFF383838, letra), 0xFFE3D9C6);
      expect(inkArgbOn(0xFF3A3A3A, letra), 0xFF3A3A3A);
    });

    test('Marca-texto: no Creme, multiplicado na cor a 90 %; no Noite (D-133), D em diferença por cima (paintInkFill) e D − cor por trás; a caneta só na passada de cima', () {
      final creme = _Tela();
      paintInk(creme, [marca()]);
      expect(creme.caminhos.single.$3, BlendMode.multiply);
      expect(creme.caminhos.single.$2.toARGB32(), 0xE6FED170);
      // no Noite, a passada de cima da tinta leva só a caneta e a Reta
      final caneta = _Tela();
      paintInk(caneta, [_traco(_reta), marca()], lightText: letra);
      expect(caneta.caminhos.single.$2.toARGB32(), 0xFFFF552E);
      final frente = _Tela();
      paintInkFill(frente, [_traco(_reta), marca()], lightText: letra);
      expect(frente.caminhos.single.$3, BlendMode.difference);
      // os da mesma cor e largura num caminho só (onde se cruzam, a diferença uma vez — achado 17); outra cor, outro
      final juntos = _Tela();
      paintInkFill(juntos, [
        marca(),
        _traco(
          [(70, 100), (70, 160)],
          tool: InkTool.marker,
          argb: 0xE6FED170,
          largura: 870,
        ),
        _traco(
          [(20, 150), (100, 150)],
          tool: InkTool.marker,
          argb: 0xE6FFC1C6,
          largura: 870,
        ),
      ], lightText: letra);
      expect(juntos.caminhos, hasLength(2));
      expect(
        juntos.caminhos.first.$1.computeMetrics().length,
        2,
        reason: 'os 2 amarelos no mesmo caminho',
      );
      expect(
        frente.caminhos.single.$2.toARGB32(),
        channelMax(letra, _amarelo).toARGB32(),
      );
      final atras = _Tela();
      paintInkBehind(atras, [_traco(_reta), marca()], lightText: letra);
      expect(atras.caminhos.single.$3, BlendMode.srcOver);
      expect(
        atras.caminhos.single.$2.toARGB32(),
        channelMinus(channelMax(letra, _amarelo), _amarelo).toARGB32(),
      );
    });

    test('Marca-texto no Noite, nos pixels: o fundo é a cor dele e a letra fica escura', () async {
      const papel = Color(0xFF1F1B17);
      final pagina = _Pagina(letra: letra);
      final gravador = ui.PictureRecorder();
      final canvas = Canvas(gravador)
        ..drawRect(const Rect.fromLTWH(0, 0, 120, 160), Paint()..color = papel);
      paintInkBehind(canvas, [marca()], lightText: letra);
      pagina.paint(canvas);
      paintInkFill(canvas, [marca()], lightText: letra);
      final img = await gravador.endRecording().toImage(120, 160);
      final bytes = (await img.toByteData())!;
      img.dispose();
      Color px(int x, int y) {
        final i = (y * 120 + x) * 4;
        return Color.fromARGB(
          bytes.getUint8(i + 3),
          bytes.getUint8(i),
          bytes.getUint8(i + 1),
          bytes.getUint8(i + 2),
        );
      }

      final fundo = px(70, 130);
      for (final (x, y) in [
        (fundo.r, _amarelo.r),
        (fundo.g, _amarelo.g),
        (fundo.b, _amarelo.b),
      ]) {
        expect((x - y).abs() * 255, lessThanOrEqualTo(1), reason: 'o fundo');
      }
      expect(px(10, 10), papel);
      final palavra = px(48, 130);
      final contraste =
          (_amarelo.computeLuminance() + 0.05) /
          (palavra.computeLuminance() + 0.05);
      expect(contraste, greaterThan(4.5), reason: 'a letra escura');
    });

    test('o cache separa o Creme e as 3 passadas do Noite; sem marca-texto, nada por trás nem na camada; no Creme, só a de cima', () {
      final cache = InkPictureCache(capacity: 8);
      addTearDown(cache.dispose);
      final p = _Pagina();
      List<InkStroke> tinta() => [_traco(_reta), marca()];
      final creme = cache.pictureOf(p, 1, tinta)!;
      final noite = cache.pictureOf(p, 1, tinta, lightText: letra)!;
      ui.Picture? passada(InkPass pass, [List<InkStroke> Function()? t]) =>
          cache.pictureOf(p, 1, t ?? tinta, lightText: letra, pass: pass);
      final atras = passada(InkPass.behind)!;
      final camada = passada(InkPass.fill)!;
      expect({creme, noite, atras, camada}, hasLength(4));
      expect(cache.pictureOf(p, 1, tinta), same(creme));
      expect(cache.pictureOf(p, 1, tinta, lightText: letra), same(noite));
      expect(passada(InkPass.behind), same(atras));
      expect(passada(InkPass.fill), same(camada));
      expect(creme.debugDisposed, isFalse);
      final soCaneta = _Pagina();
      List<InkStroke> caneta() => [_traco(_reta)];
      for (final pass in const [InkPass.behind, InkPass.fill]) {
        expect(
          cache.pictureOf(soCaneta, 1, caneta, lightText: letra, pass: pass),
          isNull,
        );
        expect(cache.pictureOf(p, 1, tinta, pass: pass), isNull);
      }
      // só o marca-texto: no Noite, nada na passada de cima
      expect(
        cache.pictureOf(_Pagina(), 1, () => [marca()], lightText: letra),
        isNull,
      );
    });
  });
}

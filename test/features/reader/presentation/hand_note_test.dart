// G18.4 — a pintura da caixa da nota à mão (tela 24b, L24b.1, L24b.3) e da faixa recolhida (D-184), pelos pixels:
// o fundo `#FFFDF8`, o tracejado 1,5 de tinta com raio 18, as pautas `#EFE5D3`, a tinta da nota (unidade dela, por
// dentro da borda) recortada na caixa, e a etiqueta "✎ Nota à mão" (`#FED170`, borda 1,5, o lápis e as letras) quando
// pedida (o leitor limpo — D-183); a faixa com o mesmo fundo e tracejado e a etiqueta no meio, sem pautas nem tinta.
// Noite (R14): fundo `#2A2520`, tracejado `#EDE3D1`, pautas `#4A433A`, a etiqueta amarela; a tinta preta clareia
// (D-174). Sem camada (regra 12.4).
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/features/reader/annotations/ink/ink_stroke.dart';
import 'package:app_leitura/features/reader/application/reader_ink.dart'
    show ReaderNote;
import 'package:app_leitura/features/reader/layout/display_page.dart';
import 'package:app_leitura/features/reader/presentation/hand_note.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../reference/leitor/reference_layout_24b_nota_mao.dart';
import '../../../support/load_fonts.dart';

Rect _ref(String id) => kRef24b.elements['hn.page.handNote$id']!.rect;

final Rect _caixa = _ref('');

/// Um traço da Caneta na unidade da nota (x = fração da largura, y = linhas de 42), de [a] a [b].
InkStroke _traco(
  (double, double) a,
  (double, double) b, {
  int argb = 0xFFFF552E,
}) => InkStroke(
  tool: InkTool.pen.code,
  tip: 0,
  argb: argb,
  widthCentiMm: 200,
  points: [
    InkPoint(a.$1, a.$2, 0.5, 0),
    InkPoint((a.$1 + b.$1) / 2, (a.$2 + b.$2) / 2, 0.5, 8),
    InkPoint(b.$1, b.$2, 0.5, 16),
  ],
);

/// Os pixels RGBA (sem pré-multiplicar) de [pintar] em 3×, a partir de (0, 380), 390 × 240.
Future<Uint8List> _pixels(void Function(Canvas c) pintar) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder)
    ..scale(3)
    ..translate(0, -380);
  pintar(canvas);
  final image = recorder.endRecording().toImageSync(390 * 3, 240 * 3);
  final data = await image.toByteData(
    format: ui.ImageByteFormat.rawStraightRgba,
  );
  image.dispose();
  return data!.buffer.asUint8List();
}

Color _em(Uint8List rgba, double x, double y) {
  final i = (((y - 380) * 3).floor() * 390 * 3 + (x * 3).floor()) * 4;
  return Color.fromARGB(rgba[i + 3], rgba[i], rgba[i + 1], rgba[i + 2]);
}

Matcher _cor(Color c, {int tol = 3}) => predicate<Color>(
  (g) => [
    (g.a - c.a).abs(),
    (g.r - c.r).abs(),
    (g.g - c.g).abs(),
    (g.b - c.b).abs(),
  ].every((d) => d * 255 <= tol),
  '≈ $c',
);

/// Uma página do leitor limpo com os espaços [spaces].
final class _Pagina implements DisplayPage, PageWithSpaces {
  _Pagina(this.spaces);

  @override
  final List<PageSpace> spaces;

  @override
  void paint(ui.Canvas canvas) {}
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
  ReaderRange? get shown => (unit: 4, from: 0, to: 10);
  @override
  ReaderSpot? spotAt(ui.Offset p) => null;
  @override
  ReaderRange? wordAround(ReaderSpot s) => null;
  @override
  ReaderRange? wordAt(ui.Offset p) => null;
  @override
  List<TextLineBox> boxesOf(int unit, int from, int to) => const [];
  @override
  String textOf(int unit, int from, int to) => '';
}

ReaderNote _nota(
  String id, {
  int lines = 3,
  bool collapsed = false,
  List<InkStroke> strokes = const [],
}) => (
  id: id,
  annotationId: '$id-a',
  unit: 4,
  at: 21,
  lines: lines,
  collapsed: collapsed,
  strokes: strokes,
  createdAt: DateTime(2026, 9, 20),
  groupId: '$id-a',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadAppFonts);

  group('a caixa (L24b.1, L24b.3)', () {
    test('o fundo, as pautas a 64 e 106 do topo de dentro e o tracejado de tinta com o canto redondo', () async {
      final px = await _pixels(
        (c) => paintHandNote(
          c,
          _caixa,
          lines: 3,
          strokes: const [],
          colors: HandNoteColors.onPaper,
        ),
      );
      expect(_em(px, 100, 470), _cor(AppColors.paperWhite));
      final pauta = _ref('.rule1');
      expect(
        _em(px, pauta.center.dx, pauta.center.dy),
        _cor(AppColors.noteRule),
      );
      expect(_em(px, 200, _ref('.rule2').center.dy), _cor(AppColors.noteRule));
      // as pautas a 12 dos lados (nem na borda, nem colada nela)
      expect(
        _em(px, pauta.left - 2, pauta.center.dy),
        _cor(AppColors.paperWhite),
      );
      // a borda da esquerda: traços de tinta e vãos com o fundo
      var tinta = 0, fundo = 0;
      for (var y = _caixa.top + 20; y < _caixa.bottom - 20; y += 1 / 3) {
        final c = _em(px, 28.5, y);
        if (c.r * 255 < 40 && c.a > 0.95) tinta++;
        if ((c.r * 255 - 0xFF).abs() < 4) fundo++;
      }
      expect(tinta, greaterThan(fundo));
      expect(fundo, greaterThan(0));
      // raio 18: o canto fica de fora; fora da caixa, nada
      expect(_em(px, 29, _caixa.top + 2).a, lessThan(0.05));
      expect(_em(px, 200, _caixa.bottom + 4).a, lessThan(0.05));
      // sem a etiqueta, nada amarelo
      expect(_em(px, 50, _ref('.tag').center.dy), isNot(_cor(AppColors.sun)));
    });

    test(
      'a tinta na unidade da nota, por dentro da borda, recortada na caixa',
      () async {
        final px = await _pixels(
          (c) => paintHandNote(
            c,
            _caixa,
            lines: 3,
            strokes: [
              _traco((0.2, 1), (0.4, 1)),
              // passa da caixa embaixo: o que sobra não aparece
              _traco((0.7, 3), (0.7, 5)),
            ],
            colors: HandNoteColors.onPaper,
          ),
        );
        final dentro = _ref('.ink');
        expect(
          _em(px, dentro.left + 0.3 * dentro.width, dentro.top + 42),
          _cor(const Color(0xFFFF552E)),
        );
        expect(
          _em(px, dentro.left + 0.7 * dentro.width, _caixa.bottom - 6),
          _cor(const Color(0xFFFF552E)),
        );
        expect(
          _em(px, dentro.left + 0.7 * dentro.width, _caixa.bottom + 6).a,
          lessThan(0.05),
        );
      },
    );

    test('a etiqueta (leitor limpo): a pílula amarela com a borda, o lápis e "Nota à mão"', () async {
      final px = await _pixels(
        (c) => paintHandNote(
          c,
          _caixa,
          lines: 3,
          strokes: const [],
          colors: HandNoteColors.onPaper,
          tag: true,
        ),
      );
      final tag = _ref('.tag');
      expect(noteTagSize().height, tag.height);
      expect(noteTagSize().width, closeTo(tag.width, 1.0));
      // o amarelo entre o lápis e o texto, a borda de tinta, o lápis e letras escuras
      expect(_em(px, 67.5, tag.center.dy), _cor(AppColors.sun));
      expect(
        _em(px, tag.left + 0.7, tag.center.dy),
        _cor(AppColors.ink, tol: 40),
      );
      var escuros = 0;
      for (var x = 70.0; x < 131; x += 1 / 3) {
        if (_em(px, x, 434.5).r * 255 < 90) escuros++;
      }
      expect(escuros, greaterThan(10), reason: 'as letras');
      var lapis = 0;
      for (var x = 52.0; x < 65; x += 1 / 3) {
        for (var y = 428.08; y < 441.08; y += 1) {
          if (_em(px, x, y).r * 255 < 90) lapis++;
        }
      }
      expect(lapis, greaterThan(10), reason: 'o lápis');
    });

    test('Noite (R14): fundo, tracejado e pautas do Noite; a tinta preta clareia (D-174)', () async {
      final px = await _pixels(
        (c) => paintHandNote(
          c,
          _caixa,
          lines: 3,
          strokes: [_traco((0.2, 1), (0.4, 1), argb: 0xFF1A1714)],
          colors: HandNoteColors.night,
          lightText: AppColors.bookTextNight,
          tag: true,
        ),
      );
      expect(_em(px, 100, 470), _cor(AppColors.islandNight));
      expect(_em(px, 200, _ref('.rule2').center.dy), _cor(AppColors.dashNight));
      final dentro = _ref('.ink');
      expect(
        _em(px, dentro.left + 0.3 * dentro.width, dentro.top + 42),
        _cor(AppColors.bookTextNight),
      );
      expect(_em(px, 67.5, _ref('.tag').center.dy), _cor(AppColors.sun));
      var claros = 0;
      for (var y = _caixa.top + 20; y < _caixa.bottom - 20; y += 1 / 3) {
        if ((_em(px, 28.5, y).r * 255 - 0xED).abs() < 6) claros++;
      }
      expect(claros, greaterThan(50), reason: 'o tracejado claro');
    });

    test('sem camada (regra 12.4)', () {
      final canvas = TestRecordingCanvas();
      paintHandNote(
        canvas,
        _caixa,
        lines: 3,
        strokes: [_traco((0.2, 1), (0.4, 1))],
        colors: HandNoteColors.onPaper,
        tag: true,
      );
      paintNoteStrip(
        canvas,
        const Rect.fromLTWH(28, 414.08, 334, 35.26),
        colors: HandNoteColors.onPaper,
        tag: true,
      );
      expect(
        canvas.invocations.where((c) => c.invocation.memberName == #saveLayer),
        isEmpty,
      );
    });
  });

  group('a faixa recolhida (D-184)', () {
    const faixa = Rect.fromLTWH(28, 414.08, 334, 35.26);

    test('o fundo e o tracejado da caixa; a etiqueta no meio da altura, a 14 da esquerda', () async {
      final px = await _pixels(
        (c) =>
            paintNoteStrip(c, faixa, colors: HandNoteColors.onPaper, tag: true),
      );
      expect(_em(px, 250, faixa.center.dy), _cor(AppColors.paperWhite));
      // a etiqueta: 24 de altura no meio
      expect(_em(px, 67.5, faixa.center.dy), _cor(AppColors.sun));
      expect(
        _em(px, 67.5, faixa.center.dy - 12 - 1),
        isNot(_cor(AppColors.sun)),
      );
      // o topo da faixa é tracejado de tinta em algum lugar
      var tinta = 0;
      for (var x = 60.0; x < 300; x += 1 / 3) {
        final c = _em(px, x, faixa.top + 0.5);
        if (c.r * 255 < 40 && c.a > 0.95) tinta++;
      }
      expect(tinta, greaterThan(100));
      // sem a etiqueta (o modo põe a dele por cima)
      final sem = await _pixels(
        (c) => paintNoteStrip(c, faixa, colors: HandNoteColors.onPaper),
      );
      expect(_em(sem, 67.5, faixa.center.dy), _cor(AppColors.paperWhite));
    });
  });

  test('as cores: papel e Noite (R14)', () {
    const p = HandNoteColors.onPaper;
    expect(
      (p.paper, p.line, p.rule, p.button, p.hint),
      (
        AppColors.paperWhite,
        AppColors.ink,
        AppColors.noteRule,
        AppColors.surface,
        AppColors.readerFooter,
      ),
    );
    const n = HandNoteColors.night;
    expect(
      (n.paper, n.line, n.rule, n.button, n.hint),
      (
        AppColors.islandNight,
        AppColors.inkNight,
        AppColors.dashNight,
        AppColors.islandNight,
        AppColors.mutedNight,
      ),
    );
  });

  group('o leitor limpo (R11, D-183, D-184)', () {
    // o bloco do espaço da 24b (com as margens 30/26) e o de uma faixa (10 + L + 10)
    const bloco = Rect.fromLTWH(28, 404.08, 334, 206);
    const blocoFaixa = Rect.fromLTWH(28, 650, 334, 55.26);

    test(
      'a caixa no bloco: 30 abaixo, 42·n + 24; a faixa: 10 de cada lado',
      () {
        expect(noteBoxIn(bloco, lines: 3, collapsed: false), _caixa);
        expect(
          noteBoxIn(blocoFaixa, lines: 3, collapsed: true),
          const Rect.fromLTWH(28, 660, 334, 35.26),
        );
      },
    );

    test('as notas da página pelos espaços dela (as sem espaço ou sem nota ficam de fora)', () {
      final p = _Pagina([
        (id: 'a', rect: bloco),
        (id: 'abridor', rect: const Rect.fromLTWH(28, 0, 334, 40)),
        (id: 'b', rect: blocoFaixa),
      ]);
      final postas = placedNotes(p, [
        _nota('b', collapsed: true),
        _nota('c'),
        _nota('a'),
      ]);
      expect(
        [for (final (n, r) in postas) (n.id, r)],
        [('a', _caixa), ('b', const Rect.fromLTWH(28, 660, 334, 35.26))],
      );
    });

    test('pinta a caixa com a etiqueta, as pautas e a tinta, e a faixa com a etiqueta; sem botões', () async {
      final p = _Pagina([(id: 'a', rect: bloco), (id: 'b', rect: blocoFaixa)]);
      final notas = [
        _nota('a', strokes: [_traco((0.2, 1), (0.4, 1))]),
        _nota('b', collapsed: true),
      ];
      final px = await _pixels((c) => paintPageNotes(c, p, notas));
      expect(_em(px, 100, 470), _cor(AppColors.paperWhite));
      expect(_em(px, 67.5, _ref('.tag').center.dy), _cor(AppColors.sun));
      final dentro = _ref('.ink');
      expect(
        _em(px, dentro.left + 0.3 * dentro.width, dentro.top + 42),
        _cor(const Color(0xFFFF552E)),
      );
      // a faixa fica abaixo do recorte de 240: pela gravação, o fundo e a etiqueta dela
      final canvas = TestRecordingCanvas();
      paintPageNotes(canvas, p, notas);
      final fundos = [
        for (final c in canvas.invocations)
          if (c.invocation.memberName == #drawRRect &&
              (c.invocation.positionalArguments[1] as Paint).color.toARGB32() ==
                  AppColors.paperWhite.toARGB32())
            (c.invocation.positionalArguments[0] as RRect).outerRect,
      ];
      expect(fundos, [_caixa, const Rect.fromLTWH(28, 660, 334, 35.26)]);
      final etiquetas = canvas.invocations.where(
        (c) =>
            c.invocation.memberName == #drawRRect &&
            (c.invocation.positionalArguments[1] as Paint).color.toARGB32() ==
                AppColors.sun.toARGB32(),
      );
      expect(etiquetas, hasLength(2));
      expect(
        canvas.invocations.where((c) => c.invocation.memberName == #saveLayer),
        isEmpty,
      );
    });

    test(
      'Noite (R14): o fundo do Noite e a tinta preta clara (D-174)',
      () async {
        final p = _Pagina([(id: 'a', rect: bloco)]);
        final px = await _pixels(
          (c) => paintPageNotes(c, p, [
            _nota('a', strokes: [_traco((0.2, 1), (0.4, 1), argb: 0xFF1A1714)]),
          ], lightText: AppColors.bookTextNight),
        );
        expect(_em(px, 100, 470), _cor(AppColors.islandNight));
        final dentro = _ref('.ink');
        expect(
          _em(px, dentro.left + 0.3 * dentro.width, dentro.top + 42),
          _cor(AppColors.bookTextNight),
        );
      },
    );

    test('sem notas, nada', () {
      final canvas = TestRecordingCanvas();
      paintPageNotes(canvas, _Pagina([(id: 'a', rect: bloco)]), const []);
      expect(canvas.invocations, isEmpty);
    });
  });
}

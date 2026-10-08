// G18 — a fonte da página do modo anotação (R3): pede ao documento a página congelada refeita com os espaços, do
// mesmo começo até o pé da tela (a altura do texto do modo: até a base da tela, menos os 30 px, mais a linha cortada
// pelo pé); guarda só as duas últimas montadas (a de agora e a de antes) e descarta as outras; sem a página do
// documento (o PDF), a congelada; as áreas dos grifos na página (as caixas das letras; a mancha nos à mão de fundo).
import 'dart:ui' as ui;

import 'package:app_leitura/features/reader/annotations/domain/annotation.dart';
import 'package:app_leitura/features/reader/annotations/ink/ink_geometry.dart';
import 'package:app_leitura/features/reader/application/reader_document.dart';
import 'package:app_leitura/features/reader/layout/reader_typography.dart';
import 'package:app_leitura/features/reader/layout/space_cut.dart';
import 'package:app_leitura/features/reader/presentation/ink_painter.dart'
    show handHighlightBoxes;
import 'package:app_leitura/features/reader/presentation/mode_page_source.dart';
import 'package:app_leitura/features/reader/presentation/page_marks.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

final class _Pagina implements DisplayPage {
  _Pagina(this.nome);

  final String nome;

  @override
  List<TextLineBox> boxesOf(int unit, int from, int to) => unit != 4
      ? const []
      : [
          (
            rect: Rect.fromLTRB(28.0 + from, 100, 28.0 + to, 135.26),
            baseline: 126.5,
            textTop: 106,
            textBottom: 132,
            em: 20.5,
          ),
        ];

  @override
  void paint(ui.Canvas canvas) {}
  @override
  bool get alive => true;
  @override
  bool get opaque => false;
  @override
  String get spokenText => nome;
  @override
  LinkHit? linkAt(ui.Offset p) => null;
  @override
  List<Rect> rectsOf(int unit, int from, int to) => const [];
  @override
  ReaderRange? get shown => (unit: 4, from: 0, to: 100);
  @override
  ReaderSpot? spotAt(ui.Offset p) => null;
  @override
  ReaderRange? wordAround(ReaderSpot s) => null;
  @override
  ReaderRange? wordAt(ui.Offset p) => null;
  @override
  String textOf(int unit, int from, int to) => '';
}

final class _Doc implements SpacedDocument {
  final pedidos = <(DisplayPage, List<SpaceCut>, double?)>[];
  final descartadas = <String>[];
  var semPagina = false;

  @override
  ({DisplayPage page, void Function() dispose})? pageWithSpaces(
    DisplayPage page,
    List<SpaceCut> cuts, {
    double? contentHeight,
  }) {
    pedidos.add((page, cuts, contentHeight));
    if (semPagina) return null;
    final p = _Pagina('p${pedidos.length}');
    return (page: p, dispose: () => descartadas.add(p.nome));
  }

  @override
  set spaces(SpaceCutsOf? spaces) {}
  @override
  Future<void> respace() async {}
  @override
  ReaderTypography get typography => const ReaderTypography();
}

PaintedHighlight _grifo(
  String id,
  int from,
  int to, {
  HighlightStyle estilo = HighlightStyle.fill,
}) => PaintedHighlight(
  id: id,
  range: (unit: 4, from: from, to: to),
  color: const Color(0xFFFED170),
  style: estilo,
);

void main() {
  final base = _Pagina('congelada');
  const corte = SpaceCut(at: 40, height: 141.78, id: 'abridor');

  test('a altura do texto do modo: até o pé da tela, menos os 30, mais a linha cortada', () {
    expect(
      modeContentHeight(screenHeight: 844, textTop: 92, lineHeight: 35.26),
      closeTo(844 - 92 - 30 + 35.26, 1e-9),
    );
  });

  test('pede a página congelada com os espaços e a altura do modo', () {
    final doc = _Doc();
    final f = ModePageSource(document: doc, base: base, contentHeight: 757.26);
    final p = f.pageWith(const [corte]);
    expect((p as _Pagina).nome, 'p1');
    expect(doc.pedidos.single.$1, same(base));
    expect(doc.pedidos.single.$2, const [corte]);
    expect(doc.pedidos.single.$3, 757.26);
  });

  test('guarda a de agora e a de antes; as outras são descartadas; o fim descarta tudo uma vez', () {
    final doc = _Doc();
    final f = ModePageSource(document: doc, base: base, contentHeight: 700);
    for (var i = 0; i < 4; i++) {
      f.pageWith(const [corte]);
    }
    expect(doc.descartadas, ['p1', 'p2']);
    f.dispose();
    expect(doc.descartadas, ['p1', 'p2', 'p3', 'p4']);
    f.dispose();
    expect(doc.descartadas, hasLength(4));
  });

  test('sem a página do documento, a congelada (nada a descartar)', () {
    final doc = _Doc()..semPagina = true;
    final f = ModePageSource(document: doc, base: base, contentHeight: 700);
    expect(f.pageWith(const [corte]), same(base));
    f.dispose();
    expect(doc.descartadas, isEmpty);
  });

  test(
    'as áreas dos grifos: as caixas das letras; a mancha nos à mão de fundo',
    () {
      final f = ModePageSource(
        document: _Doc(),
        base: base,
        contentHeight: 700,
        highlights: [_grifo('g1', 0, 10)],
        inkHighlights: [
          _grifo('m1', 20, 30),
          _grifo('m2', 40, 50, estilo: HighlightStyle.underline),
        ],
      );
      final p = _Pagina('outra');
      final areas = f.highlightsOn(p);
      expect(
        [for (final a in areas) (a.id, a.ink)],
        [('g1', false), ('m1', true), ('m2', true)],
      );
      expect(areas[0].areas.single, const InkRect(28, 106, 38, 132));
      final mancha = handHighlightBoxes(p, [_grifo('m1', 20, 30)]).single.box;
      expect(
        areas[1].areas.single,
        InkRect(mancha.left, mancha.top, mancha.right, mancha.bottom),
      );
      expect(areas[2].areas.single, const InkRect(68, 106, 78, 132));
    },
  );
}

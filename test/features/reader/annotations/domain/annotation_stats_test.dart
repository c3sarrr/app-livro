// G03.2 — contagens sempre derivadas (Anexo 02 §4.2): "Grifos 12" (tela 20), filtros da tela 25,
// marcas por capítulo do sumário (tela 27) e contagem por rótulo do marca-texto (23b, D-40).
import 'package:app_leitura/core/data/clock/hlc.dart';
import 'package:app_leitura/core/data/model/record_meta.dart';
import 'package:app_leitura/features/reader/annotations/domain/annotation.dart';
import 'package:app_leitura/features/reader/annotations/domain/annotation_stats.dart';
import 'package:app_leitura/features/reader/domain/locator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const usuario = '6f1c2a3b-4d5e-4f60-8a7b-9c0d1e2f3a4b';
  const domCasmurro = '0199a7c4-2f00-7a10-8b20-000000000001';
  const outroLivro = '0199a7c4-2f00-7a10-8b20-000000000002';
  const camada = '0199a7c4-2f00-7a10-8b20-0000000000c1';
  const amarelo = '#FED170';
  const rosa = '#FFC1C6';
  const verde = '#ABCF82';
  const lavanda = '#B6ACE4';
  const coral = '#FF552E';
  final t0 = DateTime.utc(2026, 9, 20, 23);
  final meta = RecordMeta(
    userId: usuario,
    createdAt: t0,
    updatedAt: t0,
    version: Hlc(t0.millisecondsSinceEpoch, 0, 'aparelhoA'),
  );
  var seq = 0;

  Annotation a(
    AnnotationKind kind, {
    String livro = domCasmurro,
    String? cor,
    int pagina = 159,
    int capitulo = 31,
    int inicio = 0,
    bool apagada = false,
  }) {
    seq++;
    final id = '0199a7c4-2f00-7a10-8b20-${seq.toString().padLeft(12, '0')}';
    return Annotation(
      id: id,
      meta: apagada
          ? meta.deleted(t0, Hlc(t0.millisecondsSinceEpoch, seq, 'aparelhoA'))
          : meta,
      userBookId: livro,
      kind: kind,
      groupId: id,
      anchor: EpubAnchor(
        sha: 'a3f1c2d4e5f60718293a4b5c6d7e8f90a1b2c3d4e5f60718293a4b5c6d7e8f90',
        spine: capitulo + 1,
        start: inicio,
        end: inicio + 5,
        quote: const TextQuote(exact: 'trech'),
        refPage: pagina,
      ),
      refPage: pagina,
      chapterIndex: capitulo,
      color: kind == AnnotationKind.highlight || kind == AnnotationKind.drawing
          ? cor
          : null,
      style: kind == AnnotationKind.highlight ? HighlightStyle.fill : null,
      noteText: kind == AnnotationKind.note ? 'nota' : null,
      inkLayerId:
          kind == AnnotationKind.drawing || kind == AnnotationKind.handwriting
          ? camada
          : null,
    );
  }

  // Dom Casmurro na tela 25: 6 grifos (3 amarelos, 1 rosa, 1 verde, 1 lavanda) + 2 notas + 1 à mão + 3 desenhos.
  List<Annotation> telaVinteECinco() => [
    a(AnnotationKind.highlight, cor: amarelo, pagina: 3, capitulo: 0),
    a(AnnotationKind.highlight, cor: rosa, pagina: 6, capitulo: 1),
    a(AnnotationKind.note, pagina: 6, capitulo: 1),
    a(AnnotationKind.highlight, cor: verde, pagina: 41, capitulo: 8),
    a(AnnotationKind.highlight, cor: amarelo, pagina: 121, capitulo: 24),
    a(AnnotationKind.highlight, cor: lavanda, pagina: 152, capitulo: 30),
    a(AnnotationKind.note, pagina: 152, capitulo: 30, inicio: 1),
    a(AnnotationKind.highlight, cor: amarelo, inicio: 10),
    a(AnnotationKind.drawing, cor: coral, inicio: 40),
    a(AnnotationKind.handwriting, inicio: 60),
    a(AnnotationKind.drawing, cor: coral, inicio: 80),
    a(AnnotationKind.drawing, cor: coral, inicio: 90),
  ];

  test('Tudo 12 = Grifos 6 + Notas 2 + À mão 1 + Desenhos 3, só do livro e sem apagadas', () {
    final lista = [
      ...telaVinteECinco(),
      a(AnnotationKind.highlight, cor: amarelo, livro: outroLivro),
      a(AnnotationKind.highlight, cor: amarelo, apagada: true),
    ];
    final c = AnnotationStats.countByKind(lista, userBookId: domCasmurro);
    expect(c.all, 12);
    expect(c.highlights, 6);
    expect(c.notes, 2);
    expect(c.handwriting, 1);
    expect(c.drawings, 3);
    expect(c.highlights + c.notes + c.handwriting + c.drawings, c.all);
  });

  test('rótulos do marca-texto: grifos por cor em TODOS os livros (D-40) → 5 + 3 + 2 + 2', () {
    final lista = [
      ...telaVinteECinco(),
      a(AnnotationKind.highlight, cor: amarelo, livro: outroLivro),
      a(AnnotationKind.highlight, cor: amarelo, livro: outroLivro),
      a(AnnotationKind.highlight, cor: rosa, livro: outroLivro),
      a(AnnotationKind.highlight, cor: rosa, livro: outroLivro),
      a(AnnotationKind.highlight, cor: verde, livro: outroLivro),
      a(AnnotationKind.highlight, cor: lavanda, livro: outroLivro),
      a(AnnotationKind.highlight, cor: lavanda, apagada: true),
      a(AnnotationKind.drawing, cor: amarelo), // desenho não é grifo
    ];
    expect(AnnotationStats.highlightsByColor(lista), {
      amarelo: 5,
      rosa: 3,
      verde: 2,
      lavanda: 2,
    });
  });

  group('marcas do sumário (tela 27)', () {
    test('XXV → 1 (círculo amarelo)', () {
      final m = AnnotationStats.chapterMarks(
        telaVinteECinco(),
        chapterIndex: 24,
      );
      expect(m.count, 1);
      expect(m.symbols, [const MarkSymbol(AnnotationKind.highlight, amarelo)]);
    });

    test('XXXI → 2 (círculo lavanda + quadradinho da nota)', () {
      final m = AnnotationStats.chapterMarks(
        telaVinteECinco(),
        chapterIndex: 30,
      );
      expect(m.count, 2);
      expect(m.symbols, [
        const MarkSymbol(AnnotationKind.highlight, lavanda),
        const MarkSymbol(AnnotationKind.note, null),
      ]);
    });

    test(
      'XXXII → 5 (círculo amarelo + círculo coral + caneta da nota à mão)',
      () {
        final m = AnnotationStats.chapterMarks(
          telaVinteECinco(),
          chapterIndex: 31,
        );
        expect(m.count, 5);
        expect(m.symbols, [
          const MarkSymbol(AnnotationKind.highlight, amarelo),
          const MarkSymbol(AnnotationKind.drawing, coral),
          const MarkSymbol(AnnotationKind.handwriting, null),
        ]);
      },
    );

    test(
      'no máximo 3 símbolos, na ordem grifo → nota → desenho → nota à mão',
      () {
        final lista = [
          a(AnnotationKind.handwriting, capitulo: 5, inicio: 1),
          a(AnnotationKind.drawing, cor: coral, capitulo: 5, inicio: 2),
          a(AnnotationKind.note, capitulo: 5, inicio: 3),
          a(AnnotationKind.highlight, cor: verde, capitulo: 5, inicio: 50),
          a(AnnotationKind.highlight, cor: rosa, capitulo: 5, inicio: 4),
          a(AnnotationKind.highlight, cor: rosa, capitulo: 5, apagada: true),
        ];
        final m = AnnotationStats.chapterMarks(lista, chapterIndex: 5);
        expect(m.count, 5);
        expect(m.symbols, [
          const MarkSymbol(AnnotationKind.highlight, rosa),
          const MarkSymbol(AnnotationKind.highlight, verde),
          const MarkSymbol(AnnotationKind.note, null),
        ]);
      },
    );

    test('capítulo sem anotações', () {
      final m = AnnotationStats.chapterMarks(
        telaVinteECinco(),
        chapterIndex: 25,
      );
      expect(m.count, 0);
      expect(m.symbols, isEmpty);
    });
  });
}

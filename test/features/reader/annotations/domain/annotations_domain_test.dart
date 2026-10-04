// G03.2 — anotações (tela 25), camadas de tinta, rótulos e predefinições da caneta (Anexo 02 §4.1).
import 'package:app_leitura/core/data/clock/hlc.dart';
import 'package:app_leitura/core/data/model/nullable.dart';
import 'package:app_leitura/core/data/model/record_meta.dart';
import 'package:app_leitura/features/reader/annotations/domain/annotation.dart';
import 'package:app_leitura/features/reader/annotations/domain/highlight_label.dart';
import 'package:app_leitura/features/reader/annotations/domain/ink_layer.dart';
import 'package:app_leitura/features/reader/annotations/domain/pen_presets.dart';
import 'package:app_leitura/features/reader/domain/locator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const usuario = '6f1c2a3b-4d5e-4f60-8a7b-9c0d1e2f3a4b';
  const livroId = '0199a7c4-2f00-7a10-8b20-000000000001';
  const grupo = '0199a7c4-2f00-7a10-8b20-0000000000e1';
  const camada = '0199a7c4-2f00-7a10-8b20-0000000000c1';
  const sha =
      'a3f1c2d4e5f60718293a4b5c6d7e8f90a1b2c3d4e5f60718293a4b5c6d7e8f90';
  final t0 = DateTime.utc(2026, 9, 20, 23);
  final meta = RecordMeta(
    userId: usuario,
    createdAt: t0,
    updatedAt: t0,
    version: Hlc(t0.millisecondsSinceEpoch, 0, 'aparelhoA'),
  );
  final ancora = EpubAnchor(
    sha: sha,
    spine: 33,
    start: 120,
    end: 143,
    quote: const TextQuote(exact: 'aqueles olhos de Capitu'),
    refPage: 159,
  );

  Annotation anotacao({
    AnnotationKind kind = AnnotationKind.highlight,
    String? color = '#FED170',
    HighlightStyle? style = HighlightStyle.fill,
    String? noteText,
    String? inkLayerId,
    String? parentId,
  }) => Annotation(
    id: '0199a7c4-2f00-7a10-8b20-0000000000a1',
    meta: meta,
    userBookId: livroId,
    kind: kind,
    parentId: parentId,
    groupId: grupo,
    anchor: ancora,
    refPage: 159,
    chapterIndex: 31,
    color: color,
    style: style,
    fillHeight: style == null ? null : FillHeight.medium,
    noteText: noteText,
    inkLayerId: inkLayerId,
  );

  group('Annotation', () {
    test('códigos do banco', () {
      expect(AnnotationKind.values.map((k) => k.code), [
        'highlight',
        'note',
        'handwriting',
        'drawing',
      ]);
      expect(AnnotationSource.values.map((k) => k.code), ['selection', 'ink']);
      expect(HighlightStyle.values.map((k) => k.code), [
        'fill',
        'underline',
        'wavy',
      ]);
      expect(FillHeight.values.map((k) => k.code), ['low', 'medium', 'high']);
      expect(anotacao().source, AnnotationSource.selection);
    });

    test('grifo exige cor e estilo', () {
      expect(anotacao().color, '#FED170');
      expect(() => anotacao(color: null), throwsArgumentError);
      expect(() => anotacao(style: null), throwsArgumentError);
      expect(() => anotacao(color: '#fed170'), throwsArgumentError);
    });

    test('nota exige texto e só nota tem texto (até 10.000 caracteres)', () {
      final nota = anotacao(
        kind: AnnotationKind.note,
        color: null,
        style: null,
        noteText: 'É o livro todo nessa frase.',
        parentId: '0199a7c4-2f00-7a10-8b20-0000000000a0',
      );
      expect(nota.noteText, 'É o livro todo nessa frase.');
      expect(
        () => anotacao(kind: AnnotationKind.note, color: null, style: null),
        throwsArgumentError,
      );
      expect(() => anotacao(noteText: 'texto em grifo'), throwsArgumentError);
      expect(
        () => anotacao(
          kind: AnnotationKind.note,
          style: null,
          noteText: 'x' * 10001,
        ),
        throwsArgumentError,
      );
    });

    test('nota à mão e desenho exigem a camada de tinta', () {
      expect(
        () => anotacao(
          kind: AnnotationKind.drawing,
          color: '#FF552E',
          style: null,
        ),
        throwsArgumentError,
      );
      final desenho = anotacao(
        kind: AnnotationKind.drawing,
        color: '#FF552E',
        style: null,
        inkLayerId: camada,
      );
      expect(desenho.inkLayerId, camada);
      expect(
        anotacao(
          kind: AnnotationKind.handwriting,
          color: null,
          style: null,
          inkLayerId: camada,
        ).kind,
        AnnotationKind.handwriting,
      );
    });

    test('igualdade e copyWith', () {
      expect(anotacao(), anotacao());
      expect(anotacao().hashCode, anotacao().hashCode);
      final b = anotacao().copyWith(color: const Nullable('#FFC1C6'));
      expect(b.color, '#FFC1C6');
      expect(b == anotacao(), isFalse);
      expect(
        anotacao()
            .copyWith(
              sharedClubPostId: const Nullable(
                '0199a7c4-2f00-7a10-8b20-0000000000f1',
              ),
            )
            .sharedClubPostId,
        isNotNull,
      );
    });
  });

  group('InkLayer', () {
    InkLayer tinta({
      InkLayerKind kind = InkLayerKind.space,
      int? spaceLines = 3,
      String b64 = '',
    }) => InkLayer(
      id: camada,
      meta: meta,
      userBookId: livroId,
      kind: kind,
      anchor: ancora,
      spaceLines: spaceLines,
      strokesB64: b64,
      strokeCount: 0,
    );

    test('espaço ⇔ número de linhas (1–12); traços até ≈ 256 KiB', () {
      expect(InkLayerKind.values.map((k) => k.code), ['over_text', 'space']);
      expect(tinta().spaceLines, 3);
      expect(tinta().collapsed, isFalse);
      expect(tinta().codecVersion, 1);
      expect(() => tinta(spaceLines: null), throwsArgumentError);
      expect(() => tinta(kind: InkLayerKind.overText), throwsArgumentError);
      expect(
        tinta(kind: InkLayerKind.overText, spaceLines: null).kind,
        InkLayerKind.overText,
      );
      expect(() => tinta(spaceLines: 13), throwsArgumentError);
      expect(() => tinta(b64: 'A' * 349529), throwsArgumentError);
      expect(tinta().copyWith(collapsed: true).collapsed, isTrue);
      expect(tinta(), tinta());
    });
  });

  group('HighlightLabel', () {
    test('rótulo 1–24 caracteres, cor #RRGGBB', () {
      HighlightLabel r(String label, {String color = '#FED170'}) =>
          HighlightLabel(
            id: '0199a7c4-2f00-7a10-8b20-0000000000d1',
            meta: meta,
            color: color,
            label: label,
          );
      expect(r('lindo').sort, 0);
      expect(() => r(''), throwsArgumentError);
      expect(() => r('x' * 25), throwsArgumentError);
      expect(() => r('lindo', color: 'amarelo'), throwsArgumentError);
      expect(r('lindo'), r('lindo'));
      expect(r('lindo').copyWith(label: 'ideia').label, 'ideia');
    });
  });

  group('PenPresets', () {
    test('padrões da tela 23/23b (SQL)', () {
      final p = PenPresets(id: usuario, meta: meta);
      expect(p.penTip, PenTip.ballpoint);
      expect(p.penWidthMm, 1.2);
      expect(p.penColor, '#FF552E');
      expect(p.favoriteColors, [
        '#FF552E',
        '#552CB7',
        '#058CD7',
        '#00995E',
        '#F2A815',
        '#1A1714',
      ]);
      expect(p.strokeSize, StrokeSize.medium);
      expect(p.highlighterStyle, HighlightStyle.fill);
      expect(p.highlighterHeight, FillHeight.medium);
      expect(p.highlighterColor, '#FED170');
      expect(PenTip.values.map((t) => t.code), [
        'ballpoint',
        'fountain',
        'brush',
      ]);
      expect(StrokeSize.values.map((t) => t.code), ['thin', 'medium', 'thick']);
    });

    test(
      'CHECKs: espessura 0,3–4,0 com 1 casa, até 12 favoritas, id = dono',
      () {
        expect(
          () => PenPresets(id: usuario, meta: meta, penWidthMm: 0.2),
          throwsArgumentError,
        );
        expect(
          () => PenPresets(id: usuario, meta: meta, penWidthMm: 4.1),
          throwsArgumentError,
        );
        expect(
          () => PenPresets(id: usuario, meta: meta, penWidthMm: 1.25),
          throwsArgumentError,
        );
        expect(
          PenPresets(id: usuario, meta: meta, penWidthMm: 0.3).penWidthMm,
          0.3,
        );
        expect(
          () => PenPresets(
            id: usuario,
            meta: meta,
            favoriteColors: List.filled(13, '#FF552E'),
          ),
          throwsArgumentError,
        );
        // o SQL só limita o tamanho do array: o formato da cor é regra da interface
        expect(
          PenPresets(
            id: usuario,
            meta: meta,
            favoriteColors: const ['#ff552e'],
          ).favoriteColors,
          ['#ff552e'],
        );
        expect(() => PenPresets(id: livroId, meta: meta), throwsArgumentError);
      },
    );

    test('igualdade compara a lista de favoritas; a lista é imutável', () {
      final a = PenPresets(
        id: usuario,
        meta: meta,
        favoriteColors: const ['#FF552E'],
      );
      expect(
        a,
        PenPresets(id: usuario, meta: meta, favoriteColors: const ['#FF552E']),
      );
      expect(
        a ==
            PenPresets(
              id: usuario,
              meta: meta,
              favoriteColors: const ['#552CB7'],
            ),
        isFalse,
      );
      expect(() => a.favoriteColors.add('#000000'), throwsUnsupportedError);
      expect(a.copyWith(penColor: '#552CB7').penColor, '#552CB7');
    });
  });
}

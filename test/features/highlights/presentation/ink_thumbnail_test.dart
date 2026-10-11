// G19.6 — a tinta nos cartões (R10): o desenho posto de volta sobre o trecho pela moldura da D-162 (o trecho numa
// linha estica pela largura; quebrado, não), a nota à mão reduzida à miniatura de 96, e o cache das imagens (até a
// capacidade, a mais antiga sai; a chave muda com a versão da camada e não com o lugar na tela).
import 'dart:ui' as ui;

import 'package:app_leitura/core/data/clock/hlc.dart';
import 'package:app_leitura/features/highlights/presentation/ink_thumbnail.dart';
import 'package:app_leitura/features/reader/annotations/domain/ink_layer.dart';
import 'package:app_leitura/features/reader/annotations/ink/ink_stroke.dart';
import 'package:app_leitura/features/reader/presentation/ink_painter.dart'
    show inkBounds;
import 'package:flutter_test/flutter_test.dart';

import '../../../fixtures/mundo_2026_09_20.dart';

/// As camadas `over_text` (os desenhos) e a da nota à mão, pelo tipo.
List<InkLayer> get _desenhos => [
  for (final l in mundoReferencia.camadas)
    if (l.kind == InkLayerKind.overText) l,
];

InkLayer get _notaAMao =>
    mundoReferencia.camadas.firstWhere((l) => l.kind == InkLayerKind.space);

ui.Rect _bounds(List<InkStroke> s) => inkBounds(s);

/// Pinta a miniatura de [l] em [at]; [x] = o começo do trecho na citação (o desenho).
void _pinta(InkThumbnailCache cache, InkLayer l, ui.Offset at, {double x = 0}) {
  final r = ui.PictureRecorder();
  final c = ui.Canvas(r);
  if (l.kind == InkLayerKind.space) {
    cache.paintHandNote(c, at, l, dpr: 3);
  } else {
    cache.paintDrawing(c, at, l, [
      (left: x, right: x + 120, baseline: 20, em: 16.5),
    ], dpr: 3);
  }
  r.endRecording().dispose();
}

void main() {
  test('o desenho num trecho de uma linha estica pela largura do trecho', () {
    final elipse = _desenhos.first;
    final estreito = _bounds(
      drawingInCard(elipse, [(left: 10, right: 110, baseline: 20, em: 16.5)])!,
    );
    final largo = _bounds(
      drawingInCard(elipse, [(left: 10, right: 210, baseline: 20, em: 16.5)])!,
    );
    expect(largo.width, greaterThan(estreito.width * 1.8));
    // a altura não estica (Y = base + ey·em)
    expect(largo.height, closeTo(estreito.height, 0.5));
  });

  test('o trecho quebrado em duas linhas não estica (k = 1)', () {
    final elipse = _desenhos.first;
    final quebrado = drawingInCard(elipse, [
      (left: 200, right: 320, baseline: 20, em: 16.5),
      (left: 0, right: 40, baseline: 46.4, em: 16.5),
    ])!;
    final outro = drawingInCard(elipse, [
      (left: 200, right: 320, baseline: 20, em: 16.5),
      (left: 0, right: 90, baseline: 46.4, em: 16.5),
    ])!;
    expect(_bounds(quebrado), _bounds(outro));
    expect(_bounds(quebrado).left, lessThan(200));
  });

  test('sem traços, sem desenho', () {
    final vazio = _desenhos.first.copyWith(strokesB64: '', strokeCount: 0);
    expect(
      drawingInCard(vazio, [(left: 0, right: 10, baseline: 10, em: 16.5)]),
      isNull,
    );
    expect(handNoteInThumb(_notaAMao.copyWith(strokesB64: '')), isNull);
  });

  test('a nota à mão cabe na miniatura de 96, alinhada à esquerda', () {
    final b = _bounds(handNoteInThumb(_notaAMao)!);
    expect(b.top, greaterThanOrEqualTo(-1.5));
    expect(b.bottom, lessThanOrEqualTo(thumbNoteInkHeight + 1.5));
    expect(b.left, lessThan(40));
    expect(b.right, lessThan(320));
  });

  testWidgets(
    'o cache: a mais antiga sai; a chave muda com a versão e não com o lugar',
    (tester) async {
      final cache = InkThumbnailCache(capacity: 2);
      final a = _desenhos[0];
      final b = _desenhos[1];
      final c = _notaAMao;
      _pinta(cache, a, ui.Offset.zero);
      _pinta(cache, a, const ui.Offset(0, 500));
      // o mesmo trecho em outro lugar da linha (outro cartão, outra rolagem): a mesma imagem
      _pinta(cache, a, ui.Offset.zero, x: 40);
      expect((cache.renders, cache.length), (1, 1));
      _pinta(cache, b, ui.Offset.zero);
      _pinta(cache, c, ui.Offset.zero);
      expect((cache.renders, cache.length), (3, 2));
      // a 1ª saiu (a mais antiga)
      _pinta(cache, a, ui.Offset.zero);
      expect((cache.renders, cache.length), (4, 2));
      // a c (usada antes da a) saiu; a b também já saiu — usar a de novo não redesenha
      _pinta(cache, a, ui.Offset.zero);
      expect(cache.renders, 4);
      final nova = a.copyWith(
        meta: a.meta.edited(
          a.meta.updatedAt.add(const Duration(minutes: 1)),
          Hlc(a.meta.version.ms + 60000, 0, a.meta.version.deviceId),
        ),
      );
      _pinta(cache, nova, ui.Offset.zero);
      expect(cache.renders, 5);
      cache.clear();
      expect(cache.length, 0);
    },
  );
}

// G18.3/G18.4 — a geometria das peças do Espaço contra as pranchas: o abridor da 24 (a área, a costura, as bolinhas,
// o rastro, o dedo e o lugar do chip), a caixa da nota à mão da 24b (medida por dentro da borda de 1,5: a etiqueta,
// as pautas, os botões, a dica, a alça e as barras) e a faixa recolhida (D-184).
import 'dart:ui';

import 'package:app_leitura/features/reader/annotations/space/hand_note_layout.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../reference/leitor/reference_layout_24_abrindo_espaco.dart';
import '../../../../reference/leitor/reference_layout_24b_nota_mao.dart';

void _igual(Rect r, Rect e, String id) {
  for (final (o, g, x) in [
    ('x', r.left, e.left),
    ('y', r.top, e.top),
    ('w', r.width, e.width),
    ('h', r.height, e.height),
  ]) {
    expect(g, closeTo(x, 0.01), reason: '$id.$o');
  }
}

void main() {
  group('o abridor da 24 (L24.1, L24.2)', () {
    Rect ref(String id) => kRef24.elements['sp.page.spaceOpener$id']!.rect;
    final area = ref('.area');
    // o dedo a 58 % da largura da área (o `left: 58%` do arquivo)
    final p = openerLayout(area, area.left + 0.58 * area.width);

    test('a área é a do arquivo; costura 4 para dentro e 1 acima, bolinhas de 10 nas pontas', () {
      expect(p.area, area);
      _igual(p.seam, ref('.seam'), 'seam');
      _igual(p.dotLeft, ref('.seamDotLeft'), 'seamDotLeft');
      _igual(p.dotRight, ref('.seamDotRight'), 'seamDotRight');
    });

    test('o rastro desce do topo até 18 acima da base; o dedo de 42 na borda de baixo', () {
      _igual(p.trail, ref('.trail'), 'trail');
      _igual(p.finger, ref('.finger'), 'finger');
      // o dedo acompanha o x de quem arrasta
      final outro = openerLayout(area, 100);
      expect(outro.finger.center, Offset(100, area.bottom));
      expect(outro.trail.center.dx, 100);
    });

    test('o chip a 14 da esquerda, 28 de altura, no meio da área', () {
      final chip = ref('.sizeChip');
      expect(p.chip.left, closeTo(chip.left, 0.01));
      expect(p.chip.top, closeTo(chip.top, 0.01));
      expect(p.chip.height, chip.height);
    });
  });

  group('a caixa da nota à mão da 24b (L24b.1–L24b.4)', () {
    Rect ref(String id) => kRef24b.elements['hn.page.handNote$id']!.rect;
    final box = ref('');
    final p = handNoteLayout(box, 3);

    test('a etiqueta a 14 da esquerda e 13 acima, por dentro da borda', () {
      expect(p.box, box);
      final tag = ref('.tag');
      expect(p.tag.dx, closeTo(tag.left, 0.01));
      expect(p.tag.dy, closeTo(tag.top, 0.01));
      expect(noteTagHeight, tag.height);
    });

    test('as pautas a cada 42 a partir de 22, a 12 dos lados', () {
      expect(p.rules, hasLength(2));
      _igual(p.rules[0], ref('.rule1'), 'rule1');
      _igual(p.rules[1], ref('.rule2'), 'rule2');
      expect(handNoteLayout(box, 1).rules, isEmpty);
      expect(handNoteLayout(box, 5).rules, hasLength(4));
    });

    test('os botões de 40 a 12 da direita, 20 acima, 6 entre eles', () {
      _igual(p.collapse, ref('.actions.collapse'), 'collapse');
      _igual(p.delete, ref('.actions.delete'), 'delete');
    });

    test(
      'a dica com o pé 8 acima da borda de baixo; a alça 52 × 22 e as barras',
      () {
        final hint = ref('.hint');
        expect(p.hintBottomLeft.dx, closeTo(hint.left, 0.01));
        expect(p.hintBottomLeft.dy, closeTo(hint.bottom, 0.01));
        _igual(p.handle, ref('.handle'), 'handle');
        _igual(p.bar1, ref('.handle.bar1'), 'bar1');
        _igual(p.bar2, ref('.handle.bar2'), 'bar2');
      },
    );

    test(
      'a tinta vive por dentro da borda (o desenho do arquivo começa ali)',
      () {
        final ink = ref('.ink');
        final f = inkFrame(box);
        expect(f.left, closeTo(ink.left, 0.01));
        expect(f.top, closeTo(ink.top, 0.01));
        expect(f.width, closeTo(ink.width, 0.01));
        expect(f.height, box.height - 2 * noteBorder);
      },
    );

    test('a caixa maior leva a alça, a dica e as pautas junto', () {
      final alta = handNoteLayout(const Rect.fromLTWH(28, 434.08, 334, 234), 5);
      expect(alta.handle.top, closeTo(p.handle.top + 84, 1e-9));
      expect(alta.hintBottomLeft.dy, closeTo(p.hintBottomLeft.dy + 84, 1e-9));
      expect(alta.delete, p.delete);
    });
  });

  test('a faixa recolhida (D-184): a etiqueta no meio da altura e o abrir de 32 a 6 da direita', () {
    const l = 35.26;
    const strip = Rect.fromLTWH(28, 414.08, 334, l);
    final s = stripLayout(strip);
    expect(s.strip, strip);
    expect(s.tag.dx, closeTo(43.5, 1e-9));
    expect(s.tag.dy, closeTo(414.08 + l / 2 - 12, 1e-9));
    _igual(
      s.open,
      const Rect.fromLTWH(362 - 1.5 - 6 - 32, 414.08 + l / 2 - 16, 32, 32),
      'open',
    );
  });
}

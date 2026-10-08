// G16 (Tarefa 24) — a tinta do mundo contra os SVGs da prancha 22: os traços de cada desenho, de volta à moldura da
// prancha (k = 1), ficam sobre o caminho do arquivo (≤ 0,5 px além da quantização de 1/100 em); o BNK1 devolve os
// mesmos traços; as larguras da D-159 (2,3 → 125; 1,8 → 98; 2,2 → 120; 2,4 → 131); a onda completa cobre o trecho; as
// barras são Reta de 2 pontos; o amostrador segue M/C/S/Q/T e o corte da onda.
import 'package:app_leitura/features/reader/annotations/ink/bnk1_codec.dart';
import 'package:app_leitura/features/reader/annotations/ink/drawing_anchor.dart';
import 'package:app_leitura/features/reader/annotations/ink/ink_stroke.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mundo_2026_09_20.dart';
import 'tinta_do_mundo.dart';

/// Os pontos (em em) de volta à tela 22, na moldura do trecho da prancha.
List<Offset> _naPrancha(DesenhoDoMundo d, int traco) {
  final m = molduraNaPrancha(d.trecho);
  return [
    for (final p in d.emEm[traco].points)
      Offset(m.x + p.x * emDaPrancha, m.baseline + p.y * emDaPrancha),
  ];
}

void main() {
  test('o amostrador: um passo de 0,5 px ao longo do traço; M/L, C/S, Q/T relativos; o corte em x', () {
    final reta = amostrarCaminho('M0 0L10 0', origem: Offset.zero);
    expect(reta, hasLength(21));
    expect(reta.last, const Offset(10, 0));
    final s = amostrarCaminho(
      'M0 0C0 10 10 10 10 0S20 -10 20 0',
      origem: const Offset(5, 5),
    );
    // a curva suave começa com o controle refletido: simétrica em torno de (15, 5)
    expect(s.first, const Offset(5, 5));
    expect((s.last - const Offset(25, 5)).distance, lessThan(1e-6));
    final t = amostrarCaminho('M0 5 q3 -4.5 6 0 t6 0', origem: Offset.zero);
    expect((t.last - const Offset(12, 5)).distance, lessThan(1e-6));
    expect(t.map((p) => p.dy).reduce((a, b) => a > b ? a : b), greaterThan(5));
    final cortada = amostrarCaminho(
      'M0 0L100 0',
      origem: const Offset(10, 0),
      ateX: 40,
    );
    expect(cortada.last.dx, closeTo(50, 1e-9));
  });

  test('a elipse e o risco ficam sobre os caminhos do arquivo (≤ 0,5 px além da quantização)', () {
    final elipse = pontosDaElipse22();
    final risco = pontosDoRisco22();
    final d = desenhoDaElipse;
    expect(d.emEm, hasLength(2));
    const tol = 0.5 + 0.5 * emDaPrancha / 100;
    for (final (i, caminho) in [(0, elipse), (1, risco)]) {
      for (final p in _naPrancha(d, i)) {
        expect(distanciaALinha(p, caminho), lessThan(tol), reason: '$i $p');
      }
    }
    // a caixa medida da elipse (a curva passa perto de x 2,3 de 100)
    final c = caixaNaPrancha('ann.page.text.circled.ellipse');
    final xs = elipse.map((p) => p.dx);
    expect(
      xs.reduce((a, b) => a < b ? a : b),
      inInclusiveRange(c.left + 0.02 * c.width, c.left + 0.026 * c.width),
    );
  });

  test('a onda completa cobre o trecho; as barras são Reta de 2 pontos; as larguras da D-159', () {
    final onda = _naPrancha(desenhoDoOndulado, 0);
    final trecho = caixaNaPrancha('ann.page.text.wavy');
    final o = caixaNaPrancha('ann.page.text.wavy.wave');
    expect(onda.first.dx, closeTo(o.left, 0.11));
    expect(onda.last.dx, closeTo(o.left + trecho.width, 0.11));
    expect(
      pontosDaOnda22(ate: 0.66).last.dx,
      closeTo(o.left + trecho.width * 0.66, 1e-6),
    );
    final barras = desenhoDoDuplo.emEm;
    expect(barras.map((b) => (b.tool, b.points.length)), [
      (InkTool.line.code, 2),
      (InkTool.line.code, 2),
    ]);
    expect(
      [
        for (final d in [desenhoDaElipse, desenhoDoOndulado, desenhoDoDuplo])
          for (final t in d.emEm) t.widthCentiMm,
      ],
      [125, 98, 120, 131, 131],
    );
    expect(
      {
        for (final d in [desenhoDaElipse, desenhoDoOndulado, desenhoDoDuplo])
          for (final t in d.emEm) t.argb,
      },
      {tintaCoral},
    );
  });

  test('o BNK1 devolve os traços (em 1/100 em) e as camadas do mundo os levam com a âncora de 8 chaves', () {
    for (final d in [desenhoDaElipse, desenhoDoOndulado, desenhoDoDuplo]) {
      final volta = decodeStrokesB64(d.strokesB64, Bnk1Unit.em);
      expect(volta, hasLength(d.emEm.length));
      for (var i = 0; i < volta.length; i++) {
        final a = volta[i].points;
        final b = d.emEm[i].points;
        expect(a, hasLength(b.length));
        for (var k = 0; k < a.length; k++) {
          expect(a[k].x, closeTo(b[k].x, 0.005 + 1e-9));
          expect(a[k].y, closeTo(b[k].y, 0.005 + 1e-9));
        }
      }
    }
    final m = mundoReferencia;
    final porTrecho = {
      for (final c in m.camadas)
        if (inkAnchorOf(c.anchor) case final a?) a.range.quote.exact: (c, a.w),
    };
    expect(porTrecho['Olhos de ressaca?']!.$1.strokeCount, 2);
    expect(porTrecho['fluido misterioso']!.$1.strokeCount, 1);
    expect(porTrecho['a vaga que se retira']!.$1.strokeCount, 2);
    expect(
      porTrecho['Olhos de ressaca?']!.$2,
      closeTo(168.54 / emDaPrancha, 1e-4),
    );
  });
}

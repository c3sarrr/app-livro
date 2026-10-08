// G18.1 — as alturas das pranchas 24 e 24b (D-182, D-184), o n do arrasto (D-41, R2), as pautas e as linhas que
// a tinta ocupa (D-186).
import 'package:app_leitura/features/reader/annotations/space/space_metrics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const l = 35.26; // a linha da tela 19 (20,5 × 1,72)

  test('abridor (24): área n·L − 2, margens 14/24 → 3 linhas = 103,78 e 141,78 no fluxo', () {
    expect(openerAreaHeight(3, l), closeTo(103.78, 1e-9));
    expect(openerFlowHeight(3, l), closeTo(141.78, 1e-9));
    expect(openerAreaHeight(1, l), closeTo(33.26, 1e-9));
  });

  test('caixa (24b): 42·n + 24, margens 30/26 → 3 linhas = 150 e 206', () {
    expect(noteBoxHeight(3), 150);
    expect(noteFlowHeight(3), 206);
    expect(noteBoxHeight(1), 66);
    expect(noteBoxHeight(12), 528);
    expect(noteFlowHeight(12), 584);
  });

  test('faixa recolhida (D-184): uma linha do texto, margens 10/10', () {
    expect(stripFlowHeight(l), closeTo(55.26, 1e-9));
  });

  test('n do arrasto: (do topo da área até o dedo + 2) ÷ L, arredondado, de 1 a 12 (D-41)', () {
    expect(linesOfDrag(103.78, l), 3); // o dedo na borda de baixo da 24
    expect(linesOfDrag(0, l), 1);
    expect(linesOfDrag(-40, l), 1);
    expect(linesOfDrag(52, l), 2); // 1,53 → 2
    expect(linesOfDrag(50, l), 1); // 1,47 → 1
    expect(linesOfDrag(2000, l), 12);
  });

  test('pautas a cada 42 a partir de 22: 64 e 106 com 3 linhas', () {
    expect(noteRulesY(3), [64, 106]);
    expect(noteRulesY(1), isEmpty);
    expect(noteRulesY(12), hasLength(11));
  });

  test('linhas escritas (D-186): a menor caixa que contém a tinta', () {
    expect(linesForInk(0), 1);
    expect(linesForInk(64), 1); // até a 1ª pauta
    expect(linesForInk(64.5), 2);
    expect(linesForInk(103.2), 2); // a tinta da 24b
    expect(linesForInk(106.01), 3);
    expect(linesForInk(600), 12);
  });
}

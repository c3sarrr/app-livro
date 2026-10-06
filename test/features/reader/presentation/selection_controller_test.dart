// G13.3 — a seleção da tela 21: a palavra da pressão longa; arrastar sem soltar estende o fim por palavra (o início
// fica — D-136); as alças movem as bordas por palavra ou, com a lupa, por letra (D-45); presa à página (D-47); a inicial
// nunca passa da final (pelo menos 1 letra); a barra de um grifo existente guarda o id dele (D-132) e não pinta fundo
// de seleção (D-137).
import 'package:app_leitura/features/reader/layout/display_page.dart';
import 'package:app_leitura/features/reader/presentation/selection_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/pagina_de_texto.dart';

void main() {
  final p = PaginaDeTexto(
    'aa bb, cc dd ee',
  ); // letra i em x = 10·i…10·i + 10, uma linha só
  ReaderRange r(int a, int z) => (unit: 0, from: a, to: z);
  // o dedo um pouco depois do começo da letra i (o ponto do texto mais perto é antes dela)
  Offset em(int i) => Offset(10.0 * i + 3, 20);

  test(
    'alça final por palavra: vai ao fim da palavra sob o dedo; pontuação conta',
    () {
      // texto: a0 a1 _2 b3 b4 ,5 _6 c7 c8 _9 d10 d11 _12 e13 e14 — "cc" (7–9) → fim 9; a "," (5) → fim 6
      expect(
        moveEdge(p, r(0, 2), SelectionHandle.end, em(7), byChar: false),
        r(0, 9),
      );
      expect(
        moveEdge(p, r(0, 2), SelectionHandle.end, em(5), byChar: false),
        r(0, 6),
      );
      // no espaço depois de "cc" (9): vale a palavra da letra antes dele
      expect(
        moveEdge(
          p,
          r(0, 2),
          SelectionHandle.end,
          const Offset(92, 20),
          byChar: false,
        ),
        r(0, 9),
      );
    },
  );

  test('alça inicial por palavra: vai ao começo; por letra: o ponto entre as letras', () {
    expect(
      moveEdge(p, r(7, 9), SelectionHandle.start, em(4), byChar: false),
      r(3, 9),
    );
    expect(
      moveEdge(
        p,
        r(7, 9),
        SelectionHandle.start,
        const Offset(44, 20),
        byChar: true,
      ),
      r(4, 9),
    );
  });

  test('a inicial nunca passa da final e vice-versa (pelo menos 1 letra)', () {
    expect(
      moveEdge(p, r(3, 5), SelectionHandle.start, em(13), byChar: false),
      r(4, 5),
    );
    expect(
      moveEdge(p, r(3, 5), SelectionHandle.end, em(0), byChar: false),
      r(3, 4),
    );
  });

  test('presa à página (D-47): o dedo fora vira a borda da página', () {
    expect(
      moveEdge(
        p,
        r(0, 2),
        SelectionHandle.end,
        const Offset(900, 900),
        byChar: false,
      ),
      r(0, 15),
    );
    expect(
      moveEdge(
        p,
        r(7, 9),
        SelectionHandle.start,
        const Offset(-50, 20),
        byChar: false,
      ),
      r(0, 9),
    );
  });

  test('arrastar sem soltar estende o fim por palavra; o início fica na palavra da pressão longa', () {
    expect(extendFrom(p, r(7, 9), em(13)), r(7, 15));
    expect(extendFrom(p, r(7, 9), em(11)), r(7, 12));
    expect(
      extendFrom(p, r(7, 9), em(0)),
      r(7, 9),
      reason: 'para trás, fica a palavra',
    );
    expect(extendFrom(p, r(7, 9), em(8)), r(7, 9), reason: 'dentro dela');
    expect(
      extendFrom(p, r(7, 9), const Offset(900, 20)),
      r(7, 15),
      reason: 'presa à página',
    );
  });

  test('controlador: escolher, crescer, alça com lupa, grifo existente e limpar avisam', () {
    final c = SelectionController();
    var avisos = 0;
    c.addListener(() => avisos++);
    expect((c.value, c.active, c.selection), (null, false, null));
    c.selectWord(r(3, 5));
    expect(
      (c.value, c.selection!.anchor, c.selection!.highlightId),
      (r(3, 5), r(3, 5), null),
    );
    c.setRange(r(3, 9));
    c.setRange(r(3, 9)); // igual: não avisa
    expect(
      c.selection!.anchor,
      r(3, 5),
      reason: 'a palavra da pressão longa fica',
    );
    c.beginDrag(SelectionHandle.end, em(8));
    expect(
      (c.selection!.dragging, c.selection!.byChar, c.selection!.anchor),
      (SelectionHandle.end, false, null),
    );
    c.enterCharMode();
    c.enterCharMode(); // já está: não avisa
    expect(c.selection!.byChar, isTrue);
    c.dragTo(p, const Offset(134, 20));
    expect(c.value, r(3, 13));
    expect(c.selection!.finger, const Offset(134, 20));
    c.endDrag();
    expect(
      (c.selection!.dragging, c.selection!.byChar, c.selection!.finger),
      (null, false, null),
    );
    c.showHighlight('g', r(0, 2));
    expect(
      (c.value, c.selection!.highlightId, c.selection!.anchor),
      (r(0, 2), 'g', null),
    );
    c.clear();
    c.clear(); // já limpa: não avisa
    expect((c.value, c.active), (null, false));
    expect(avisos, 8);
  });

  test('sem seleção, mexer nas alças não faz nada', () {
    final c = SelectionController();
    var avisos = 0;
    c.addListener(() => avisos++);
    c
      ..setRange(r(0, 2))
      ..beginDrag(SelectionHandle.start, em(1))
      ..enterCharMode()
      ..dragTo(p, em(3))
      ..endDrag();
    expect((c.value, avisos), (null, 0));
    c.selectWord(r(0, 2));
    c
      ..enterCharMode()
      ..dragTo(p, em(9))
      ..endDrag();
    expect(c.value, r(0, 2), reason: 'sem alça arrastada');
    expect(avisos, 1);
  });

  test('D-47 mesmo numa página que não prende o ponto: a borda fica no que ela mostra', () {
    final parte = PaginaDeTexto(
      'aa bb, cc dd ee',
      mostrado: (unit: 0, from: 3, to: 12),
    );
    expect(
      moveEdge(parte, r(3, 5), SelectionHandle.end, em(14), byChar: false),
      r(3, 12),
    );
    expect(
      moveEdge(parte, r(7, 9), SelectionHandle.start, em(0), byChar: false),
      r(3, 9),
    );
  });

  test('D-137: o fundo da seleção — na seleção nova, o trecho; no grifo existente, nenhum', () {
    final c = SelectionController();
    addTearDown(c.dispose);
    var avisos = 0;
    void ouvinte() => avisos++;
    c.fill.addListener(ouvinte);
    expect(c.fill.value, isNull);
    c.selectWord(r(1, 3));
    expect(c.fill.value, r(1, 3));
    c.showHighlight('g', r(0, 5));
    expect((c.value, c.fill.value), (r(0, 5), null));
    expect(avisos, 2);
    c.fill.removeListener(ouvinte);
    c.clear();
    expect(avisos, 2, reason: 'saiu');
  });
}

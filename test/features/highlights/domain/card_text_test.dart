// G19.1 — o texto do cartão da tela 25: o contexto da D-49 e o fim até a pontuação (R3); o recuo pela citação.
import 'package:app_leitura/features/highlights/domain/card_text.dart';
import 'package:flutter_test/flutter_test.dart';

String plano(List<CardSpan> s) =>
    s.map((x) => x.annotationId == null ? x.text : '[${x.text}]').join();

void main() {
  group('contexto (D-49)', () {
    test('a frase inteira cabe em 55: desde o começo dela, sem "…"', () {
      const t = 'Era noite. Traziam não sei que fluido misterioso e enérgico.';
      expect(contextBefore(t, t.indexOf('fluido')), 'Traziam não sei que ');
    });

    test('mais de 55: corta em palavra e começa com "…"', () {
      const t =
          'Retórica dos namorados, dá-me uma comparação exata e poética para dizer o que foram aqueles olhos de Capitu.';
      final c = contextBefore(t, t.indexOf('olhos de Capitu'));
      expect(c.startsWith('…'), isTrue);
      expect(c.length - 1, lessThanOrEqualTo(55));
      expect(c.substring(1).startsWith(' '), isFalse);
      expect(c.endsWith('aqueles '), isTrue);
      expect(c, '…exata e poética para dizer o que foram aqueles ');
    });

    test('exatamente 55 cabe; 56 corta', () {
      final cinquentaECinco = 'a' * 54;
      final t1 = '$cinquentaECinco X';
      expect(contextBefore(t1, t1.length - 1), '$cinquentaECinco ');
      final t2 = 'b $cinquentaECinco X';
      expect(contextBefore(t2, t2.length - 1), '…$cinquentaECinco ');
    });

    test(
      'começo do parágrafo e começo do texto contam como começo de frase',
      () {
        const t = 'Fim de um.\nComeço do outro com o grifo';
        expect(contextBefore(t, t.indexOf('grifo')), 'Começo do outro com o ');
        expect(contextBefore('grifo', 0), '');
      },
    );

    test('fim de frase com aspas que fecham; "?" e "!" e "…" também', () {
      const t = '— Vá, de ressaca.” E então o grifo';
      expect(contextBefore(t, t.indexOf('o grifo')), 'E então ');
      expect(contextBefore('Será? Sim o grifo', 10), 'Sim ');
      expect(contextBefore('Ah! Sim o grifo', 8), 'Sim ');
      expect(contextBefore('Ah… Sim o grifo', 8), 'Sim ');
      expect(contextBefore('Ah) Sim o grifo', 8), 'Ah) Sim ');
    });

    test('ponto sem branco depois (abreviação colada) não é fim de frase', () {
      const t = 'O Sr.José viu o grifo';
      expect(contextBefore(t, t.indexOf('o grifo')), 'O Sr.José viu ');
    });

    test('corte sem branco antes do trecho: só "…"', () {
      final t = 'x ${'a' * 70}grifo';
      expect(contextBefore(t, t.indexOf('grifo')), '…');
    });
  });

  group('depois do último trecho (R3)', () {
    test('o trecho já acaba a frase: nada', () {
      const t = 'que eu conheço de vista e de chapéu. Um dia, depois';
      expect(tailAfter(t, t.indexOf(' Um')), '');
      const t2 = 'disse: “Vá.” Depois, foi';
      expect(tailAfter(t2, t2.indexOf(' Depois')), '');
    });

    test('ponto final logo depois fica, com a aspa que fecha', () {
      const t = 'o que foram aqueles olhos de Capitu. Outra frase';
      expect(tailAfter(t, t.indexOf('.')), '.');
      const t2 = 'os olhos de Capitu.” Outra';
      expect(tailAfter(t2, t2.indexOf('.')), '.”');
      expect(tailAfter('fim?', 3), '?');
    });

    test('vírgula, ponto e vírgula e dois-pontos viram "…"', () {
      const t = 'como a vaga que se retira da praia, nos dias de ressaca.';
      expect(tailAfter(t, t.indexOf(' da praia')), ' da praia…');
      expect(tailAfter('a b; c', 1), ' b…');
      expect(tailAfter('a b: c', 1), ' b…');
    });

    test('sem pontuação em 40: corta em palavra e põe "…"', () {
      const t =
          'grifo e aqui vem um texto muito comprido sem pontuação nenhuma até o fim';
      final r = tailAfter(t, 5);
      expect(r, ' e aqui vem um texto muito comprido sem…');
      expect(r.length - 1, lessThanOrEqualTo(40));
    });

    test('o resto do texto cabe em 40 sem pontuação: vai inteiro', () {
      expect(tailAfter('grifo e mais nada', 5), ' e mais nada');
    });

    test('40 sem nenhum branco: corta seco', () {
      final t = 'g${'x' * 60}';
      expect(tailAfter(t, 1), '${'x' * 40}…');
    });

    test(
      'fim do parágrafo ou do texto: nada; parágrafo que acaba sem ponto',
      () {
        expect(tailAfter('fim\nnovo', 3), '');
        expect(tailAfter('fim', 3), '');
        expect(tailAfter('a b c\nd', 1), ' b c');
      },
    );
  });

  group('trechos do cartão', () {
    test('o cartão 8: dois desenhos e o fim na vírgula', () {
      const t =
          'Traziam não sei que fluido misterioso e enérgico, uma força que arrastava para dentro, como a vaga que se retira da praia, nos dias de ressaca.';
      final a = t.indexOf('fluido misterioso');
      final b = t.indexOf('a vaga que se retira');
      final s = cardSpans(t, [
        (id: 'd', start: b, end: b + 'a vaga que se retira'.length),
        (id: 'o', start: a, end: a + 'fluido misterioso'.length),
      ]);
      expect(
        plano(s),
        'Traziam não sei que [fluido misterioso] e enérgico, uma força que arrastava para dentro, como [a vaga que se retira] da praia…',
      );
      expect(s[1].annotationId, 'o');
      expect(s[3].annotationId, 'd');
    });

    test(
      'marca de ponto (nota à mão) estende o trecho até ela, sem marcar',
      () {
        const t = 'Olhos de ressaca? Vá, de ressaca. O que eles tinham';
        final e = t.indexOf(' Vá');
        final fim = t.indexOf(' O que');
        final s = cardSpans(t, [
          (id: 'e', start: 0, end: e),
          (id: 'h', start: fim, end: fim),
        ]);
        expect(plano(s), '[Olhos de ressaca?] Vá, de ressaca.');
      },
    );

    test('sobreposição: o 2º começa onde o 1º acabou; contido não repete', () {
      const t = 'abc def ghi.';
      expect(
        plano(
          cardSpans(t, [
            (id: '1', start: 0, end: 7),
            (id: '2', start: 4, end: 11),
          ]),
        ),
        '[abc def][ ghi].',
      );
      expect(
        plano(
          cardSpans(t, [
            (id: '1', start: 0, end: 11),
            (id: '2', start: 4, end: 7),
          ]),
        ),
        '[abc def ghi].',
      );
    });

    test('sem marcas: nada', () {
      expect(cardSpans('abc', const []), isEmpty);
    });
  });

  group('recuo pela citação guardada (sem o arquivo do livro)', () {
    test('prefixo cortado (32): "…" e o que vem depois do 1º branco; vírgula no sufixo', () {
      final s = spansFromQuotes([
        (
          id: 'g',
          prefix: 'rem da Central um rapaz aqui do ',
          exact: 'bairro',
          suffix: ', que eu conheço de vista',
        ),
      ]);
      expect(plano(s), '…da Central um rapaz aqui do [bairro]…');
    });

    test('prefixo com fim de frase: desde a frase; sufixo com ponto', () {
      final s = spansFromQuotes([
        (
          id: 'g',
          prefix: 'Ele saiu. Encontrei no trem um r',
          exact: 'apaz',
          suffix: '. Depois',
        ),
      ]);
      expect(plano(s), 'Encontrei no trem um r[apaz].');
    });

    test('prefixo curto (começo do capítulo): inteiro; dois trechos separados por " … "', () {
      final s = spansFromQuotes([
        (id: 'a', prefix: 'Eu ', exact: 'vi', suffix: ' tudo'),
        (id: 'b', prefix: 'mais ', exact: 'longe', suffix: ''),
      ]);
      expect(plano(s), 'Eu [vi] … [longe]');
    });

    test('prefixo cortado sem branco: só "…"; sem citações: nada', () {
      final s = spansFromQuotes([
        (id: 'a', prefix: 'x' * 32, exact: 'vi', suffix: ''),
      ]);
      expect(plano(s), '…[vi]');
      expect(spansFromQuotes(const []), isEmpty);
    });
  });
}

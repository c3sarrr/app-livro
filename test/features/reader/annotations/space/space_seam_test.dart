// G18.2 — a costura do Espaço (R1, D-181): a âncora fica no fim da última frase que termina na linha de cima da
// fresta; sem frase, no fim da linha (ou no último branco dela, se ela quebra no hífen); entre parágrafos, no fim
// do de cima. A frase da âncora vai ao leitor de tela (R13).
import 'package:app_leitura/features/reader/annotations/ink/ink_geometry.dart';
import 'package:app_leitura/features/reader/annotations/space/space_seam.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const t =
      'Olhos de ressaca? Vá, de ressaca. É o que me dá ideia daquela feição nova.\nOutro parágrafo, sem fim';

  group('âncora (R1, D-181)', () {
    test('o fim da última frase da linha', () {
      final fim = t.indexOf('ressaca. ') + 'ressaca.'.length;
      expect(anchorAfterLine(t, 0, t.indexOf(' que')), fim);
    });

    test('as aspas e o parêntese que fecham entram na frase', () {
      const s = 'Ele disse: “Vá.” E saiu de casa.';
      expect(anchorAfterLine(s, 0, s.indexOf(' saiu')), s.indexOf('” E') + 1);
      const p = 'Coisa feita (de ressaca!) e outra';
      expect(
        anchorAfterLine(p, 0, p.indexOf(' e outra')),
        p.indexOf(') e') + 1,
      );
    });

    test(
      'sem frase na linha: o fim da linha (o branco depois da última palavra)',
      () {
        final de = t.indexOf('É o que');
        expect(
          anchorAfterLine(t, de, t.indexOf(' daquela')),
          t.indexOf(' daquela'),
        );
      },
    );

    test('linha partida no hífen: o último branco dela; sem branco, nada', () {
      const s = 'às outras partes agarrei-me depois';
      expect(
        anchorAfterLine(s, 0, s.indexOf('-me') + 1),
        s.indexOf(' agarrei'),
      );
      const u = 'paralelepípedo-ônibus';
      expect(anchorAfterLine(u, 0, u.indexOf('-') + 1), isNull);
    });

    test('a linha que fecha o parágrafo: o fim dele, sem partir', () {
      final de = t.indexOf('É o que');
      expect(anchorAfterLine(t, de, t.indexOf('\n')), t.indexOf('\n'));
      // o último parágrafo do item, sem ponto: o fim do texto
      final outro = t.indexOf('Outro');
      expect(anchorAfterLine(t, outro, t.length), t.length);
    });

    test(
      'reticências e "!" fecham frase; ponto sem branco depois ("3.5") não',
      () {
        const s = 'Pensou… Depois saiu! Mediu 3.5 metros e';
        expect(anchorAfterLine(s, 0, s.indexOf(' saiu')), s.indexOf('…') + 1);
        expect(anchorAfterLine(s, 0, s.indexOf(' e')), s.indexOf('!') + 1);
      },
    );
  });

  group('a frase da âncora (R13)', () {
    test('desde o fim da frase anterior', () {
      final fim = t.indexOf('ressaca. ') + 'ressaca.'.length;
      expect(sentenceBefore(t, fim), 'Vá, de ressaca.');
      expect(sentenceBefore(t, t.indexOf('?') + 1), 'Olhos de ressaca?');
    });

    test(
      'sem frase: as últimas palavras (até 6), desde o começo do parágrafo',
      () {
        expect(sentenceBefore(t, t.indexOf(' daquela')), 'É o que me dá ideia');
        expect(sentenceBefore(t, t.length), 'Outro parágrafo, sem fim');
        const longo = 'uma duas três quatro cinco seis sete oito';
        expect(
          sentenceBefore(longo, longo.length),
          'três quatro cinco seis sete oito',
        );
      },
    );
  });

  group('a fresta (R1)', () {
    InkLine linha(int i, int from, int to) => InkLine(
      unit: 4,
      from: from,
      to: to,
      top: 92 + 35.26 * i,
      bottom: 92 + 35.26 * (i + 1),
      baseline: 92 + 35.26 * i + 26.5,
      em: 20.5,
      left: 28,
      right: 362,
      words: const [],
    );
    final g = InkPageGeometry([
      linha(0, 0, t.indexOf(' que')),
      linha(1, t.indexOf('que'), t.indexOf('\n')),
      linha(2, t.indexOf('Outro'), t.length),
    ]);

    test('a mais perto do dedo; a âncora e a base da linha de cima', () {
      final s = seamAt(g, 92 + 35.26 + 4, (_) => t)!;
      expect(s.line, 0);
      expect(s.unit, 4);
      expect(s.at, t.indexOf('ressaca. ') + 'ressaca.'.length);
      expect(s.y, closeTo(92 + 35.26, 1e-9));
      expect(seamAt(g, 92 + 2 * 35.26 - 6, (_) => t)!.line, 1);
      expect(seamAt(g, 2000, (_) => t)!.line, 2);
    });

    test('acima da 1ª linha, sem linhas ou sem o texto do item: nada abre', () {
      expect(seamAt(g, 80, (_) => t), isNull);
      expect(seamAt(InkPageGeometry.empty, 300, (_) => t), isNull);
      expect(seamAt(g, 200, (_) => null), isNull);
    });
  });
}

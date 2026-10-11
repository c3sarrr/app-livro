// G09.3 — âncoras e reancoragem (Anexo 03 §5.3, D-44): mesmo arquivo → posições guardadas; senão o trecho
// exato perto do lugar antigo (±2.000, desempate pelo texto em volta), depois aproximado no item inteiro
// (até 10 %, primeiro perto do lugar antigo); senão "sem lugar" — nunca apaga. Teste de propriedade: 1.000 edições sorteadas → ≥ 99 % quando o
// trecho exato sobrevive.
import 'dart:math';

import 'package:app_leitura/features/reader/content/epub_book.dart';
import 'package:app_leitura/features/reader/domain/anchoring.dart';
import 'package:app_leitura/features/reader/domain/locator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fixtures/mundo_2026_09_20.dart' show paragrafoDaPagina159;

// dois arquivos diferentes (sha256 em hexadecimal)
final String _a = 'a' * 64;
final String _b = 'b' * 64;

EpubAnchor _anchor(
  String text,
  int start,
  int end, {
  String? sha,
  int spine = 3,
}) => EpubAnchor(
  sha: sha ?? _a,
  spine: spine,
  start: start,
  end: end,
  quote: quoteAt(text, start, end),
  refPage: 1,
);

void main() {
  final texto = paragrafoDaPagina159;
  final olhos = texto.indexOf('aqueles olhos de Capitu');

  group('citação', () {
    test('exact + até 32 caracteres antes e depois', () {
      final q = quoteAt(texto, olhos, olhos + 23);
      expect(q.exact, 'aqueles olhos de Capitu');
      expect(q.prefix, texto.substring(olhos - 32, olhos));
      expect(q.suffix, texto.substring(olhos + 23, olhos + 55));
      final inicio = quoteAt(texto, 0, 8);
      expect(inicio.prefix, '');
      expect(inicio.exact, 'Retórica');
    });
  });

  group('reancoragem', () {
    test('mesmo arquivo: as posições guardadas', () {
      final a = _anchor(texto, olhos, olhos + 23);
      final r = reanchor(a, texto, currentSha: _a);
      expect(r, Anchored(olhos, olhos + 23, AnchorMethod.sameFile));
    });

    test('outro arquivo, trecho deslocado: acha perto do lugar antigo', () {
      final a = _anchor(texto, olhos, olhos + 23);
      final novo = 'PREFÁCIO NOVO. $texto';
      final r = reanchor(a, novo, currentSha: _b);
      expect(r, Anchored(olhos + 15, olhos + 38, AnchorMethod.exactNearby));
    });

    test('trecho repetido: o texto em volta decide, depois a distância', () {
      const t = 'xx ressaca yy ... aa ressaca bb ... xx ressaca yy';
      final segundo = t.indexOf('ressaca', 5); // o do meio (aa … bb)
      final a = _anchor(t, segundo, segundo + 7);
      final r = reanchor(a, 'ZZZ$t', currentSha: _b);
      expect(r, Anchored(segundo + 3, segundo + 10, AnchorMethod.exactNearby));
    });

    test('janela de ±2.000: a 1.500 é o passo 2 (exato perto); a 6.000, o passo 3 (item inteiro)', () {
      final a = _anchor(texto, olhos, olhos + 23);
      expect(
        reanchor(a, '${'y ' * 750}$texto', currentSha: _b),
        Anchored(olhos + 1500, olhos + 1523, AnchorMethod.exactNearby),
      );
      expect(
        reanchor(a, '${'x ' * 3000}$texto', currentSha: _b),
        Anchored(olhos + 6000, olhos + 6023, AnchorMethod.fuzzy),
      );
    });

    test(
      'trecho curto (< 10 caracteres) longe: só o exato, no item inteiro',
      () {
        final p = texto.indexOf('ressaca');
        final a = _anchor(texto, p, p + 7);
        expect(
          reanchor(a, '${'x ' * 3000}$texto', currentSha: _b),
          Anchored(p + 6000, p + 6007, AnchorMethod.fuzzy),
        );
      },
    );

    test('mudado no lugar e o exato longe: fica o do lugar (o perto vem antes)', () {
      final a = _anchor(texto, olhos, olhos + 23);
      final novo =
          '${texto.replaceFirst('aqueles olhos de Capitu', 'aquelles olhos de Capitu')} '
          '${'y ' * 2500}aqueles olhos de Capitu.';
      final r = reanchor(a, novo, currentSha: _b) as Anchored;
      expect(r.method, AnchorMethod.fuzzy);
      expect(r.start, olhos);
      expect(novo.substring(r.start, r.end), 'aquelles olhos de Capitu');
    });

    test('mais de 10 % diferente: sem lugar', () {
      final a = _anchor(texto, olhos, olhos + 23);
      // 4 trocas em 23 (17 %): com 10 %, no máximo 2
      final novo = texto.replaceFirst(
        'aqueles olhos de Capitu',
        'aqXelYs olZos de CapiWu',
      );
      expect(reanchor(a, novo, currentSha: _b), const Orphaned());
    });

    test('um erro de digitação dentro do trecho: aproximado (≤ 10 %)', () {
      final a = _anchor(texto, olhos, olhos + 23);
      final novo = texto.replaceFirst(
        'aqueles olhos de Capitu',
        'aquelles olhos de Capitú',
      );
      final r = reanchor(a, novo, currentSha: _b) as Anchored;
      expect(r.method, AnchorMethod.fuzzy);
      expect(r.start, olhos);
      expect(novo.substring(r.start, r.end), 'aquelles olhos de Capitú');
    });

    test(
      'trecho longo (> 64) mudado no meio: começo e fim acham o intervalo',
      () {
        final ini = texto.indexOf('Traziam');
        final fim =
            texto.indexOf('nos dias de ressaca.') +
            'nos dias de ressaca.'.length;
        final a = _anchor(texto, ini, fim);
        final novo = texto.replaceFirst(
          'fluido misterioso e enérgico',
          'fluido mysterioso e energico',
        );
        final r = reanchor(a, novo, currentSha: _b) as Anchored;
        expect(r.method, AnchorMethod.fuzzy);
        expect(novo.substring(r.start, r.end), startsWith('Traziam'));
        expect(
          novo.substring(r.start, r.end),
          endsWith('nos dias de ressaca.'),
        );
      },
    );

    test('trecho que sumiu: sem lugar (nunca apaga)', () {
      final a = _anchor(texto, olhos, olhos + 23);
      final r = reanchor(
        a,
        'Outro livro, outro texto, nada a ver com aquilo.',
        currentSha: _b,
      );
      expect(r, const Orphaned());
    });

    test(
      'âncora vazia (espaço aberto entre linhas): o texto em volta dá o ponto',
      () {
        final p = texto.indexOf('Olhos de ressaca?');
        final a = _anchor(texto, p, p);
        expect(a.quote.exact, '');
        final r = reanchor(a, 'Novo começo. $texto', currentSha: _b);
        expect(r, Anchored(p + 13, p + 13, AnchorMethod.exactNearby));
      },
    );

    test('posição de leitura: o mesmo caminho, com o deslocamento', () {
      final l = EpubLocator(
        sha: _a,
        spine: 3,
        offset: olhos,
        quote: TextQuote(exact: texto.substring(olhos, olhos + 32)),
        refPage: 159,
        progression: 0.62113,
      );
      expect(relocate(l, texto, currentSha: _a), (
        olhos,
        AnchorMethod.sameFile,
      ));
      expect(relocate(l, 'xyz $texto', currentSha: _b), (
        olhos + 4,
        AnchorMethod.exactNearby,
      ));
      final semCitacao = EpubLocator(
        sha: _a,
        spine: 3,
        offset: 99999,
        refPage: 1,
        progression: 0,
      );
      expect(relocate(semCitacao, texto, currentSha: _b), (
        texto.length,
        AnchorMethod.clamped,
      ));
    });
  });

  test('propriedade: 1.000 edições sorteadas de um capítulo real — ≥ 99 % quando o trecho exato sobrevive', () {
    // 8.000 caracteres do Dom Casmurro real (texto canônico do Gutenberg): sem repetições artificiais
    final livro = EpubBook.open('test/fixtures/livros/pg55752.epub');
    addTearDown(livro.close);
    final base = livro.parseItem(1).text.substring(20000, 28000);
    final rnd = Random(20260920);
    const letras = 'abcdefghijklmnopqrstuvwxyzáéíóúãõç ,.;';
    String aleatorio(int n) => String.fromCharCodes([
      for (var i = 0; i < n; i++) letras.codeUnitAt(rnd.nextInt(letras.length)),
    ]);
    final palavras = [
      for (var i = 1; i < base.length - 220; i++)
        if (base.codeUnitAt(i - 1) == 0x20) i,
    ];
    var fora = 0;
    var foraCertos = 0;
    var dentro = 0;
    var dentroAchados = 0;
    var dentroCertos = 0;
    for (var k = 0; k < 1000; k++) {
      // trecho de 10–200 caracteres começando numa palavra
      final s = palavras[rnd.nextInt(palavras.length)];
      final e = s + 10 + rnd.nextInt(191);
      final a = _anchor(base, s, e);
      if (rnd.nextInt(4) > 0) {
        // fora do trecho: antes ou depois, inserindo (até 300) ou removendo (até 3)
        fora++;
        final insere = rnd.nextBool();
        final n = 1 + rnd.nextInt(insere ? 300 : 3);
        final antes = rnd.nextBool() && s > n;
        final p = antes
            ? rnd.nextInt(s - n)
            : e + rnd.nextInt(max(1, base.length - e - n));
        final novo = insere
            ? base.substring(0, p) + aleatorio(n) + base.substring(p)
            : base.substring(0, p) + base.substring(min(base.length, p + n));
        final delta = antes ? (insere ? n : -n) : 0;
        final r = reanchor(a, novo, currentSha: _b);
        if (r is Anchored && r.start == s + delta && r.end == e + delta) {
          foraCertos++;
        }
      } else {
        // dentro do trecho: troca, insere ou remove 1–3 caracteres (longe das pontas)
        dentro++;
        final m = 1 + rnd.nextInt(3);
        final p = s + 1 + rnd.nextInt(max(1, e - s - 2 - m));
        final tipo = rnd.nextInt(3);
        final novo = switch (tipo) {
          0 => base.substring(0, p) + aleatorio(m) + base.substring(p + m),
          1 => base.substring(0, p) + aleatorio(m) + base.substring(p),
          _ => base.substring(0, p) + base.substring(p + m),
        };
        final delta = switch (tipo) {
          0 => 0,
          1 => m,
          _ => -m,
        };
        final r = reanchor(a, novo, currentSha: _b);
        if (r is Anchored) {
          dentroAchados++;
          if (r.start == s && (r.end - (e + delta)).abs() <= 1) {
            dentroCertos++;
          }
        }
      }
    }
    final taxa = foraCertos / fora;
    // ignore: avoid_print
    print(
      'G09.3 reancoragem: trecho intacto $foraCertos/$fora (${(taxa * 100).toStringAsFixed(1)} %); '
      'trecho mudado: achado $dentroAchados/$dentro, intervalo certo $dentroCertos/$dentro',
    );
    expect(taxa, greaterThanOrEqualTo(0.99));
  });
}

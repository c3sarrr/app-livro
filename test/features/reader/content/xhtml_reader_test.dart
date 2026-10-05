// G09.1 — XHTML → blocos + texto canônico (Anexo 03 §4, D-93): o texto canônico é a régua das âncoras —
// NFC, `\n` entre blocos, imagem e quebra de cena = U+FFFC, `<br>` = U+2028, espaços como no navegador,
// NBSP e hífen suave preservados, `display:none` fora; estilos de trecho e o subconjunto de CSS do livro.
import 'dart:convert';

import 'package:app_leitura/features/reader/content/content_blocks.dart';
import 'package:app_leitura/features/reader/content/xhtml_reader.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/epub_builder.dart';

ParsedItem _ler(
  String body, {
  String head = '',
  Map<String, String> css = const {},
  String path = 'OEBPS/texto/cap.xhtml',
}) =>
    XhtmlReader(css: (p) => css[p])
        .parse(utf8.encode(xhtml(body, head: head)), path: path);

List<String> _textos(ParsedItem p) => [for (final b in p.blocks) b.text];

void main() {
  group('texto canônico', () {
    test('blocos unidos por \\n; início de cada bloco guardado', () {
      final p = _ler(
        '<h1>Capítulo I</h1><p>Uma noite destas.</p><p>Vindo da cidade.</p>',
      );
      expect(p.text, 'Capítulo I\nUma noite destas.\nVindo da cidade.');
      expect(p.blockStarts, [0, 11, 29]);
      expect(p.blocks[0], isA<HeadingBlock>());
      expect((p.blocks[0] as HeadingBlock).level, 1);
      expect(p.blocks[1], isA<ParagraphBlock>());
    });

    test('espaços colapsam como no navegador (inclusive entre tags); NBSP e hífen suave ficam', () {
      final p = _ler(
        '<p>\n   Uma   noite\tdestas, <i> vindo </i> da\n cidade  </p>'
        '<p>pá\u00A0gina e sí\u00ADla\u00ADba</p>',
      );
      expect(_textos(p), [
        'Uma noite destas, vindo da cidade',
        'pá\u00A0gina e sí\u00ADla\u00ADba',
      ]);
    });

    test(
      '<br> vira U+2028 dentro do bloco; parágrafo vazio não vira bloco',
      () {
        final p = _ler(
          '<p>Primeiro verso<br/>segundo verso</p><p> </p><p></p>',
        );
        expect(p.text, 'Primeiro verso\u2028segundo verso');
      },
    );

    test('NFC: acento separado vira o composto; marca no começo de um trecho junta com a letra anterior', () {
      final p = _ler('<p>Cafe\u0301 e pe<i>\u0301</i>rola</p>');
      expect(p.text, 'Café e pérola');
      expect(p.text.length, 13);
    });

    test('display:none (CSS do livro e style), hidden, script, style e head ficam fora', () {
      final p = _ler(
        '<p>visível <span class="oculto">sumido</span>fim</p>'
        '<div style="display: none"><p>nada</p></div>'
        '<p hidden="hidden">escondido</p><script>var x = 1;</script>'
        '<p>depois</p>',
        head:
            '<link rel="stylesheet" type="text/css" href="../estilo/livro.css"/>'
            '<style>p.x { color: red }</style>',
        css: {'OEBPS/estilo/livro.css': '.oculto { display:none }'},
      );
      expect(_textos(p), ['visível fim', 'depois']);
    });

    test('imagem e quebra de cena ocupam 1 caractere (U+FFFC); a imagem guarda o caminho e o tamanho', () {
      final p = _ler(
        '<p>antes</p><hr/><p>meio <img src="../img/fig%201.png" alt="Figura" width="300" height="200"/> fim</p>'
        '<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">'
        '<image xlink:href="../img/capa.jpg"/></svg>',
      );
      expect(p.text, 'antes\n\uFFFC\nmeio\n\uFFFC\nfim\n\uFFFC');
      expect(p.blocks[1], isA<SceneBreakBlock>());
      final img = p.blocks[3] as ImageBlock;
      expect(img.path, 'OEBPS/img/fig 1.png');
      expect(img.alt, 'Figura');
      expect((img.width, img.height), (300, 200));
      expect((p.blocks.last as ImageBlock).path, 'OEBPS/img/capa.jpg');
    });

    test('citação, listas, tabela e texto pré-formatado', () {
      final p = _ler(
        '<blockquote><p>Citado.</p></blockquote>'
        '<ul><li>um</li><li>dois<ol><li>dois.a</li></ol></li></ul>'
        '<table><tr><th>Nome</th><th>Ano</th></tr><tr><td>Dom</td><td>1899</td></tr></table>'
        '<pre>linha  1\n    linha 2</pre>',
      );
      expect(_textos(p), [
        'Citado.',
        'um',
        'dois',
        'dois.a',
        'Nome · Ano',
        'Dom · 1899',
        'linha  1',
        '    linha 2',
      ]);
      expect(p.blocks[0].style.quoteDepth, 1);
      expect(p.blocks[1], isA<ListItemBlock>());
      expect(p.blocks[3].style.listDepth, 2);
      expect(p.blocks[6], isA<PreformattedBlock>());
    });

    test(
      'texto solto fora de <p> vira parágrafo; entidades HTML decodificadas',
      () {
        final p = _ler(
          '<div>Solto&nbsp;aqui &mdash; e <b>ali</b></div><div><p>dentro</p>resto</div>',
        );
        expect(_textos(p), ['Solto\u00A0aqui — e ali', 'dentro', 'resto']);
      },
    );

    test(
      'ids viram posições no texto canônico (sumário, notas, page-list)',
      () {
        final p = _ler(
          '<h2 id="cap2">II</h2><p>Começo <span id="meio"/>do meio.</p>'
          '<span epub:type="pagebreak" id="pg12" title="12"/><p id="fim">Fim.</p>',
        );
        expect(p.text, 'II\nComeço do meio.\nFim.');
        expect(p.idOffsets, {'cap2': 0, 'meio': 10, 'pg12': 19, 'fim': 19});
      },
    );

    test('XHTML mal formado (tag sem fechar) não derruba: o texto sai', () {
      final p = XhtmlReader(css: (_) => null).parse(
        utf8.encode('<html><body><p>um <i>dois<p>três</body></html>'),
        path: 'a.xhtml',
      );
      expect(p.text, contains('três'));
      expect(p.text, startsWith('um dois'));
    });

    test('UTF-16 com BOM e ISO-8859-1 declarado', () {
      final s = xhtml('<p>Ação</p>');
      final utf16 = <int>[0xFF, 0xFE];
      for (final c in s.codeUnits) {
        utf16
          ..add(c & 0xFF)
          ..add(c >> 8);
      }
      expect(
        XhtmlReader(css: (_) => null).parse(utf16, path: 'a').text,
        'Ação',
      );
      final latin = latin1.encode(
        xhtml('<p>Ação</p>')
            .replaceFirst('encoding="utf-8"', 'encoding="ISO-8859-1"'),
      );
      expect(
        XhtmlReader(css: (_) => null).parse(latin, path: 'a').text,
        'Ação',
      );
    });
  });

  group('estilos de trecho', () {
    test('itálico, negrito, sobrescrito, subscrito, link interno e versalete pelo CSS', () {
      final p = _ler(
        '<p><em>it</em> <strong>ne</strong> x<sup>2</sup> H<sub>2</sub>O '
        '<a href="notas.xhtml#n1">nota</a> <span class="vs">Versal</span></p>',
        css: {'OEBPS/texto/a.css': '.vs{font-variant:small-caps}'},
        head: '<link rel="stylesheet" href="a.css"/>',
      );
      final runs = (p.blocks.single as ParagraphBlock).runs;
      RunStyle de(String t) => runs.firstWhere((r) => r.text.contains(t)).style;
      expect(de('it').italic, isTrue);
      expect(de('ne').bold, isTrue);
      expect(de('2').superscript, isTrue);
      expect(runs.where((r) => r.style.subscript).single.text, '2');
      expect(
        runs.firstWhere((r) => r.text == 'nota').link,
        'OEBPS/texto/notas.xhtml#n1',
      );
      expect(de('Versal').smallCaps, isTrue);
      expect(runs.map((r) => r.text).join(), p.text);
    });
  });

  group('subconjunto do CSS do livro (Anexo 03 §4)', () {
    test('alinhamento, recuo, margens em em, quebra antes; px viram em (16 px = 1 em)', () {
      final p = _ler(
        '<h1 class="t">T</h1><p class="c">c</p><p style="text-indent:24px;margin:0.5em 0 1em">x</p>',
        css: {
          'OEBPS/texto/s.css':
              '/* comentário */ h1.t { text-align:center; page-break-before: always; margin-top: 3em }\n'
              '@media screen { p { text-align: right } }\n'
              'p { text-indent: 1.5em } .c { text-align: justify; text-indent: 0 }\n'
              'a:hover { display:none } p[lang] { display:none }',
        },
        head: '<link rel="stylesheet" href="s.css"/>',
      );
      final t = p.blocks[0].style;
      expect(t.align, BlockAlign.center);
      expect(t.pageBreakBefore, isTrue);
      expect(t.marginTopEm, 3);
      final c = p.blocks[1].style;
      expect(c.align, BlockAlign.justify);
      expect(c.indentEm, 0);
      final x = p.blocks[2].style;
      expect(x.indentEm, 1.5);
      expect(x.marginTopEm, 0.5);
      expect(x.marginBottomEm, 1);
      expect(x.align, isNull, reason: '@media fica de fora');
    });

    test('especificidade: classe > elemento; style > classe; empate → a regra de depois; herança de itálico', () {
      final p = _ler(
        '<div class="it"><p class="a" style="text-align:left">um</p><p class="a b">dois</p></div>',
        css: {
          'OEBPS/texto/s.css':
              '.a { text-align: center } p { text-align: right } '
              '.b { text-align: justify } .it { font-style: italic }',
        },
        head: '<link rel="stylesheet" href="s.css"/>',
      );
      expect(p.blocks[0].style.align, BlockAlign.left);
      expect(p.blocks[1].style.align, BlockAlign.justify);
      expect((p.blocks[0] as ParagraphBlock).runs.single.style.italic, isTrue);
    });
  });
}

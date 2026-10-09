// G19.1 — a exportação da tela 25 (D-194, R9): Markdown e CSV dos grifos e das notas de texto do livro todo.
import 'package:app_leitura/features/highlights/domain/highlights_export.dart';
import 'package:app_leitura/features/reader/annotations/domain/annotation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fixtures/mundo_2026_09_20.dart';
import '../../../support/personal_builders.dart';
import '../support/ordem_do_livro.dart';

void main() {
  final itens = itensDoMundo();
  const sp = Duration(hours: -3);
  Duration fuso(DateTime _) => sp;
  // 09/10/2026 12:00 em São Paulo
  final agora = DateTime.utc(2026, 10, 9, 15);
  final livro = (
    title: mundoReferencia.domCasmurro.title,
    author: mundoReferencia.domCasmurro.authorDisplay,
  );
  final rotulos = [for (var i = 0; i < 148; i++) 'cap$i'];

  test('nome do arquivo: o título sem acento, com hífens', () {
    expect(
      exportFileName('Dom Casmurro', 'md'),
      'dom-casmurro-grifos-e-notas.md',
    );
    expect(
      exportFileName('Memórias Póstumas de Brás Cubas', 'csv'),
      'memorias-postumas-de-bras-cubas-grifos-e-notas.csv',
    );
    expect(exportFileName('  ', 'md'), 'livro-grifos-e-notas.md');
    expect(exportFileName('Ação!', 'md'), 'acao-grifos-e-notas.md');
  });

  test('o que vai: 6 grifos + 2 notas', () {
    expect(exportableCount(itens), 8);
    expect(
      exportableCount(itens.where((a) => a.kind == AnnotationKind.drawing)),
      0,
    );
  });

  group('Markdown', () {
    late String md;
    setUp(() => md = markdownOf(livro, itens, now: agora, offsetAt: fuso));

    test('cabeçalho, a 1ª página e o fim com linha em branco', () {
      expect(
        md.startsWith(
          '# Dom Casmurro — grifos e notas\n'
          'Machado de Assis · exportado em 09/10/2026\n'
          '\n'
          '## pág. 3\n'
          '> que eu conheço de vista e de chapéu.\n'
          '\n'
          'Grifo amarelo · 2 set 2026\n',
        ),
        isTrue,
        reason: md,
      );
      expect(md.endsWith('\n\n'), isTrue);
    });

    test('a nota logo depois do grifo dela', () {
      expect(
        md.contains(
          '## pág. 6\n'
          '> O meu fim evidente era atar as duas pontas da vida, e restaurar na velhice a adolescência.\n'
          '\n'
          'Grifo rosa · 3 set 2026\n'
          '**Nota:** É o livro todo nessa frase.\n',
        ),
        isTrue,
        reason: md,
      );
    });

    test('a 159 só com o grifo à mão livre; nada de tinta', () {
      expect(
        md.contains(
          '## pág. 159\n> olhos de Capitu\n\nGrifo à mão livre · 20 set 2026\n',
        ),
        isTrue,
        reason: md,
      );
      expect(md.contains('ressaca'), isFalse);
      expect('## pág.'.allMatches(md).length, 6);
    });

    test(
      'dois grifos na mesma página: uma linha em branco entre eles; sem autor',
      () {
        final a = grifoTeste(
          1,
          livro: idTeste(50),
          pagina: 9,
          inicio: 0,
          exato: 'um',
        );
        final b = grifoTeste(
          2,
          livro: idTeste(50),
          pagina: 9,
          inicio: 10,
          exato: 'dois',
          cor: '#123456',
        );
        final m = markdownOf(
          (title: 'L', author: null),
          [a, b],
          now: agora,
          offsetAt: fuso,
        );
        expect(
          m,
          '# L — grifos e notas\n'
          'exportado em 09/10/2026\n'
          '\n'
          '## pág. 9\n'
          '> um\n'
          '\n'
          'Grifo amarelo · 20 set 2026\n'
          '\n'
          '> dois\n'
          '\n'
          'Grifo de outra cor · 20 set 2026\n'
          '\n',
        );
      },
    );
  });

  group('CSV', () {
    late String csv;
    setUp(() => csv = csvOf(itens, chapterLabels: rotulos, offsetAt: fuso));

    test('BOM, cabeçalho, uma linha por grifo, CRLF', () {
      expect(
        csv.startsWith('﻿pagina;capitulo;tipo;cor;trecho;nota;criado_em\r\n'),
        isTrue,
      );
      expect(csv.endsWith('\r\n'), isTrue);
      final linhas = csv.substring(1).split('\r\n')..removeLast();
      expect(linhas, hasLength(7));
    });

    test('a linha da pág. 6, com a nota; o grifo à mão livre', () {
      final p6 = itemDoMundo(6, AnnotationKind.highlight);
      expect(
        csv.contains(
          '6;cap${p6.chapterIndex};grifo;rosa;O meu fim evidente era atar as duas pontas da vida, e restaurar na velhice a adolescência.;É o livro todo nessa frase.;2026-09-03 20:00\r\n',
        ),
        isTrue,
        reason: csv,
      );
      expect(
        csv.contains(';grifo à mão livre;amarelo;olhos de Capitu;;'),
        isTrue,
      );
    });

    test('aspas e ponto e vírgula; duas notas juntas; capítulo sem rótulo', () {
      final g = grifoTeste(
        1,
        livro: idTeste(50),
        pagina: 9,
        exato: 'diz "oi"; tchau',
        cor: '#123456',
      );
      final n1 = notaTeste(2, livro: idTeste(50), pai: g, texto: 'a');
      final n2 = notaTeste(3, livro: idTeste(50), pai: g, texto: 'b\nc');
      final c = csvOf([g, n1, n2], chapterLabels: const [], offsetAt: fuso);
      expect(
        c,
        '﻿pagina;capitulo;tipo;cor;trecho;nota;criado_em\r\n'
        '9;;grifo;#123456;"diz ""oi""; tchau";"a | b\nc";2026-09-20 20:00\r\n',
      );
    });
  });
}

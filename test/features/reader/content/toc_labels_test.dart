// G15.1 (D-150) — o numeral do capítulo como no livro: do rótulo do sumário ("XXXII. Olhos de ressaca") ou, quando o
// rótulo não tem, do título do capítulo no texto quando ele é só um número (o Gutenberg põe "XXXII" num bloco logo
// antes de "Olhos de ressaca."); romano só válido e em maiúsculas; o título perde um ponto final.
import 'package:app_leitura/features/reader/content/toc_labels.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('rótulo do sumário', () {
    test('numeral + separador + título', () {
      expect(tocLabel('XXXII. Olhos de ressaca'), (
        numeral: 'XXXII',
        title: 'Olhos de ressaca',
      ));
      expect(tocLabel('XXXII — Olhos de ressaca'), (
        numeral: 'XXXII',
        title: 'Olhos de ressaca',
      ));
      expect(tocLabel('32) Olhos'), (numeral: '32', title: 'Olhos'));
      expect(tocLabel('IV: A ópera'), (numeral: 'IV', title: 'A ópera'));
      expect(tocLabel('1 - Um'), (numeral: '1', title: 'Um'));
      expect(tocLabel('XL – Quarenta'), (numeral: 'XL', title: 'Quarenta'));
      expect(tocLabel('Capítulo 32 — Olhos de ressaca'), (
        numeral: '32',
        title: 'Olhos de ressaca',
      ));
      expect(tocLabel('CAPÍTULO XXXII. Olhos'), (
        numeral: 'XXXII',
        title: 'Olhos',
      ));
      expect(tocLabel('Cap. 7: Sete'), (numeral: '7', title: 'Sete'));
      expect(tocLabel('Chapter 4: Title'), (numeral: '4', title: 'Title'));
    });

    test(
      'sem título depois do número: o rótulo fica como título, sem numeral',
      () {
        expect(tocLabel('XXXII'), (numeral: null, title: 'XXXII'));
        expect(tocLabel('Capítulo 1'), (numeral: null, title: 'Capítulo 1'));
        expect(tocLabel('XXXII.'), (numeral: null, title: 'XXXII'));
      },
    );

    test('romano só válido e em maiúsculas; palavra não é número', () {
      expect(tocLabel('CIVIL. Guerra').numeral, isNull);
      expect(tocLabel('IIII. Quatro').numeral, isNull);
      expect(tocLabel('VV. Dez').numeral, isNull);
      expect(tocLabel('xxxii. Olhos').numeral, isNull);
      expect(tocLabel('I, Robô').numeral, isNull);
      expect(tocLabel('I Am Legend').numeral, isNull);
      expect(tocLabel('12345. Grande demais').numeral, isNull);
      expect(tocLabel('Do titulo.'), (numeral: null, title: 'Do titulo'));
    });

    test('um ponto final sai; reticências, ! e ? ficam; espaços juntados', () {
      expect(tocLabel('Olhos de ressaca.').title, 'Olhos de ressaca');
      expect(tocLabel('E bem, e o resto?').title, 'E bem, e o resto?');
      expect(tocLabel('Um dever amarissimo!').title, 'Um dever amarissimo!');
      expect(tocLabel('Enfim...').title, 'Enfim...');
      expect(tocLabel('  Muitos \n  espaços. ').title, 'Muitos espaços');
      expect(tocTitle('.'), '.');
      expect(tocTitle(''), '');
    });

    test(
      'numeral do texto: vale quando o rótulo não tem; não se repete no título',
      () {
        expect(tocLabel('Olhos de ressaca.', textNumeral: 'XXXII'), (
          numeral: 'XXXII',
          title: 'Olhos de ressaca',
        ));
        expect(tocLabel('XXXII Olhos de ressaca', textNumeral: 'XXXII'), (
          numeral: 'XXXII',
          title: 'Olhos de ressaca',
        ));
        expect(tocLabel('V. O agregado', textNumeral: 'X'), (
          numeral: 'V',
          title: 'O agregado',
        ));
      },
    );
  });

  group('numeral no texto', () {
    test('o bloco logo antes da entrada (Gutenberg)', () {
      const t =
          'fim do anterior.\n￼\nXXXII\nOlhos de ressaca.\nTudo era materia';
      expect(headingNumeral(t, t.indexOf('Olhos')), 'XXXII');
      const u = 'antes.\nI\n￼\n\nDo titulo.\nUma noite';
      expect(headingNumeral(u, u.indexOf('Do titulo')), 'I');
    });

    test('o bloco na entrada, pulando a imagem e os vazios', () {
      const t = 'antes.\n￼\nCapítulo 7.\nTítulo\nTexto';
      expect(headingNumeral(t, t.indexOf('￼')), '7');
      const u = 'XXXII Olhos de ressaca\nTexto';
      expect(headingNumeral(u, 0), 'XXXII');
      const v = 'texto.\n\n32.\nTítulo';
      expect(headingNumeral(v, v.indexOf('\n\n') + 1), '32');
    });

    test('a entrada no meio de um bloco: o bloco dela', () {
      const t = 'Prefácio\nXII\nO título';
      expect(headingNumeral(t, t.indexOf('título')), 'XII');
    });

    test('sem número perto: nada', () {
      const t = 'MACHADO DE ASSIS\nDA ACADEMIA BRAZILEIRA\nB. L. GARNIER';
      expect(headingNumeral(t, t.indexOf('DA ACADEMIA')), isNull);
      expect(headingNumeral('Texto corrido sem número.', 0), isNull);
      expect(headingNumeral('', 0), isNull);
      expect(headingNumeral('abc', 99), isNull);
      expect(headingNumeral('abc', -1), isNull);
      // o bloco da entrada tem texto e não é número: o de antes não vale se também não for
      const u = 'O ano de 1914 foi longo.\nUm título\nTexto';
      expect(headingNumeral(u, u.indexOf('Um título')), isNull);
      // número longo demais não é título de capítulo
      const v = '1234 5678 9012 3456 7890 1\nTítulo';
      expect(headingNumeral(v, v.indexOf('Título')), isNull);
    });
  });
}

// G13.4 — o texto de Copiar e Compartilhar (D-39): o trecho entre aspas curvas, sem as imagens e com os espaços
// normalizados, e "— Autor, Título (pág. N)"; o trecho da busca: até 100 caracteres, cortado na palavra.
import 'package:app_leitura/features/reader/presentation/reader_actions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'citação da D-39: aspas curvas, autor, título e a página de referência',
    () {
      expect(
        quoteForSharing(
          excerpt: ' como a  vaga\nque se retira￼ ',
          author: 'Machado de Assis',
          title: 'Dom Casmurro',
          refPage: 159,
        ),
        '“como a vaga que se retira”\n— Machado de Assis, Dom Casmurro (pág. 159)',
      );
    },
  );

  test('trecho da busca: curto vai inteiro; longo é cortado no último espaço antes de 100', () {
    expect(searchPrefill('  olhos  de\nressaca '), 'olhos de ressaca');
    final longo = List.filled(30, 'abcd').join(' '); // 149 caracteres
    final r = searchPrefill(longo);
    expect(r.length, lessThanOrEqualTo(100));
    expect(
      r,
      List.filled(20, 'abcd').join(' '),
      reason: '20 palavras = 99 caracteres',
    );
    expect(
      searchPrefill('a' * 150),
      'a' * 100,
      reason: 'sem espaço, corta em 100',
    );
    expect(searchPrefill('x' * 100), 'x' * 100);
  });

  test('trecho para mostrar: sem as imagens e com um espaço só', () {
    expect(cleanExcerpt('\n a\uFFFC  b\t c '), 'a b c');
  });
}

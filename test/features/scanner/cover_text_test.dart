// G07.5 — palpite de título e autor a partir do OCR da capa (no aparelho).
import 'package:app_leitura/features/scanner/domain/cover_text.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('título = a letra maior (várias linhas na ordem de leitura); autor = a maior das outras', () {
    final g = guessFromCover(const [
      CoverLine('MACHADO DE ASSIS', 40, top: 50),
      CoverLine('MEMÓRIAS PÓSTUMAS', 90, top: 300),
      CoverLine('DE BRÁS CUBAS', 84, top: 400),
      CoverLine('Penguin Companhia', 18, top: 1500),
      CoverLine('12', 30, top: 10),
    ]);
    expect(g.title, 'Memórias Póstumas de Brás Cubas');
    expect(g.author, 'Machado de Assis');
  });

  test('texto que já tem minúsculas fica como está; capa sem texto útil = sem palpite', () {
    expect(
      guessFromCover(const [CoverLine('O Cortiço', 50)]).title,
      'O Cortiço',
    );
    expect(
      guessFromCover(const [CoverLine('7', 80), CoverLine('', 9)]).title,
      isNull,
    );
    expect(guessFromCover(const []).author, isNull);
  });

  test('legible: caixa alta vira título legível com as palavras pequenas em minúsculas', () {
    expect(legible('A HORA DA ESTRELA'), 'A Hora da Estrela');
    expect(legible('  THE  LORD OF THE RINGS '), 'The Lord of the Rings');
    expect(legible('Grande Sertão: Veredas'), 'Grande Sertão: Veredas');
  });
}

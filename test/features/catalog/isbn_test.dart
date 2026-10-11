// G07 — ISBN: a mesma regra do pipeline, do Worker e da Edge Function (Anexo 02 §7.1).
import 'package:app_leitura/features/catalog/domain/isbn.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ISBN-10 vira ISBN-13; dígito verificador conferido; hífens e espaços aceitos', () {
    expect(normalizeIsbn('85-359-0277-5'), '9788535902778');
    expect(normalizeIsbn('0-8044-2957-X'), '9780804429573');
    expect(normalizeIsbn('0 8044 2957 x'), '9780804429573');
    expect(normalizeIsbn('978-65-5532-123-4'), '9786555321234');
    expect(normalizeIsbn('979-10-90636-07-1'), '9791090636071');
    expect(normalizeIsbn('9786555321230'), isNull);
    expect(normalizeIsbn('8535902776'), isNull);
    expect(normalizeIsbn('9770000000000'), isNull);
    expect(normalizeIsbn(''), isNull);
  });

  test('ISBN-10 de volta (só 978) e a região brasileira (978-85 e 978-65)', () {
    expect(isbn10Of('9788535902778'), '8535902775');
    expect(isbn10Of('9780804429573'), '080442957X');
    expect(isbn10Of('9791090636071'), isNull);
    expect(isBrazilianIsbn('9788535902778'), isTrue);
    expect(isBrazilianIsbn('9786555321234'), isTrue);
    expect(isBrazilianIsbn('9780141439518'), isFalse);
  });

  test('código de barras: só EAN de livro; preço (EAN-5), revista (977) e produto não', () {
    expect(isbnFromBarcode('9788535902778'), '9788535902778');
    expect(isbnFromBarcode(' 8535902775 '), '9788535902778');
    expect(isbnFromBarcode('52990'), isNull);
    expect(isbnFromBarcode('9771234567003'), isNull);
    expect(isbnFromBarcode('7891000315507'), isNull);
    expect(isbnFromBarcode('https://exemplo.com/9788535902778'), isNull);
  });
}

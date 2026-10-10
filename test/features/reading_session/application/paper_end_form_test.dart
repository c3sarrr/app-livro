// T04.9 — D-260: o que a folha da sessão manda gravar a partir dos campos (página e total, só dígitos e opcionais).
import 'package:app_leitura/features/reading_session/application/paper_end_form.dart';
import 'package:flutter_test/flutter_test.dart';

PaperEndForm _ler(String page, {String total = '', int? livro}) =>
    PaperEndForm.read(page: page, total: total, bookTotal: livro);

void main() {
  group('sem página', () {
    test('nada digitado: encerra só a sessão', () {
      expect(_ler(''), const PaperEndAccepted());
      expect(_ler('   '), const PaperEndAccepted());
    });

    test(
      'o total digitado (livro sem total) vai para o livro mesmo sem página',
      () {
        expect(_ler('', total: '368'), const PaperEndAccepted(pagesTotal: 368));
      },
    );

    test('um total 0 não vale e é ignorado', () {
      expect(_ler('', total: '0'), const PaperEndAccepted());
    });

    test('com o total do livro, o campo do total é ignorado (o livro não é regravado)', () {
      expect(_ler('', total: '999', livro: 425), const PaperEndAccepted());
    });
  });

  group('com página', () {
    test('no total do livro: a página, sem regravar o total', () {
      expect(_ler('344', livro: 425), const PaperEndAccepted(page: 344));
      expect(_ler('1', livro: 425), const PaperEndAccepted(page: 1));
      expect(_ler('425', livro: 425), const PaperEndAccepted(page: 425));
    });

    test('no total digitado: a página e o total', () {
      expect(
        _ler('120', total: '368'),
        const PaperEndAccepted(page: 120, pagesTotal: 368),
      );
      expect(
        _ler('368', total: '368'),
        const PaperEndAccepted(page: 368, pagesTotal: 368),
      );
    });

    test('sem total nenhum (nem 0): "Informe o total de páginas para registrar a página."', () {
      const aviso = PaperEndRejected(
        'Informe o total de páginas para registrar a página.',
      );
      expect(_ler('12'), aviso);
      expect(_ler('12', total: '0'), aviso);
    });

    test('fora de 1…N: "A página vai de 1 a N." (com o total do livro ou o digitado)', () {
      expect(
        _ler('0', livro: 425),
        const PaperEndRejected('A página vai de 1 a 425.'),
      );
      expect(
        _ler('426', livro: 425),
        const PaperEndRejected('A página vai de 1 a 425.'),
      );
      expect(
        _ler('369', total: '368'),
        const PaperEndRejected('A página vai de 1 a 368.'),
      );
      expect(
        _ler('0', total: '368'),
        const PaperEndRejected('A página vai de 1 a 368.'),
      );
    });

    test('o total do livro manda, mesmo com outro digitado', () {
      expect(
        _ler('400', total: '300', livro: 425),
        const PaperEndAccepted(page: 400),
      );
    });
  });

  test('igualdade e toString', () {
    expect(
      const PaperEndAccepted(page: 1).hashCode,
      const PaperEndAccepted(page: 1).hashCode,
    );
    expect(
      const PaperEndAccepted(page: 1),
      isNot(const PaperEndAccepted(page: 2)),
    );
    expect(
      const PaperEndAccepted(page: 1),
      isNot(const PaperEndAccepted(page: 1, pagesTotal: 9)),
    );
    expect(const PaperEndRejected('a'), isNot(const PaperEndRejected('b')));
    expect(
      const PaperEndRejected('a').hashCode,
      const PaperEndRejected('a').hashCode,
    );
    expect('${const PaperEndAccepted(page: 3, pagesTotal: 9)}', contains('3'));
    expect('${const PaperEndRejected('x')}', contains('x'));
  });
}

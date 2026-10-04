// D-66: faixas de idade (sinal da loja ou data de nascimento) — a data nunca sai do aparelho.
import 'package:app_leitura/features/account/domain/age.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AgeBand', () {
    test('faixas do Google Play pela idade em anos completos', () {
      expect(AgeBand.forAge(0), AgeBand.under13);
      expect(AgeBand.forAge(12), AgeBand.under13);
      expect(AgeBand.forAge(13), AgeBand.from13to15);
      expect(AgeBand.forAge(15), AgeBand.from13to15);
      expect(AgeBand.forAge(16), AgeBand.from16to17);
      expect(AgeBand.forAge(17), AgeBand.from16to17);
      expect(AgeBand.forAge(18), AgeBand.adult);
      expect(AgeBand.forAge(90), AgeBand.adult);
    });

    test(
      'códigos iguais aos do servidor (private.account_age.band) e ida e volta',
      () {
        expect(AgeBand.values.map((b) => b.code), [
          'under_13',
          '13_15',
          '16_17',
          '18_plus',
        ]);
        for (final b in AgeBand.values) {
          expect(AgeBand.fromCode(b.code), b);
        }
        expect(AgeBand.fromCode(null), isNull);
        expect(AgeBand.fromCode('18+'), isNull);
        expect(AgeBand.adult.isMinor, isFalse);
        expect(
          [
            AgeBand.under13,
            AgeBand.from13to15,
            AgeBand.from16to17,
          ].every((b) => b.isMinor),
          isTrue,
        );
      },
    );

    test('intervalo da loja: limite inferior decide; teto < 13 é menor de 13; sem veredito → null', () {
      expect(AgeBand.fromRange(18, null), AgeBand.adult);
      expect(AgeBand.fromRange(16, 17), AgeBand.from16to17);
      expect(AgeBand.fromRange(13, 15), AgeBand.from13to15);
      expect(AgeBand.fromRange(0, 12), AgeBand.under13);
      expect(AgeBand.fromRange(null, null), isNull);
      expect(ageGates, [13, 16, 18]);
    });

    test('AgeCheck: permitido a partir de 13; igualdade por valor', () {
      expect(
        const AgeCheck(AgeBand.under13, AgeSource.birthdate).allowed,
        isFalse,
      );
      expect(
        const AgeCheck(AgeBand.from13to15, AgeSource.playSignal).allowed,
        isTrue,
      );
      expect(
        const AgeCheck(AgeBand.adult, AgeSource.appleSignal),
        const AgeCheck(AgeBand.adult, AgeSource.appleSignal),
      );
      expect(AgeSource.values.map((s) => s.code), [
        'play_signal',
        'apple_signal',
        'birthdate',
      ]);
    });
  });

  group('data de nascimento', () {
    test('anos completos: o aniversário conta no próprio dia', () {
      final nasc = DateTime(2010, 10, 4);
      expect(fullYears(nasc, DateTime(2023, 10, 3)), 12);
      expect(fullYears(nasc, DateTime(2023, 10, 4)), 13);
      expect(fullYears(nasc, DateTime(2023, 10, 5)), 13);
      expect(fullYears(nasc, DateTime(2024, 1, 1)), 13);
    });

    test('nascido em 29/02: completa ano em 01/03 nos anos não bissextos', () {
      final nasc = DateTime(2012, 2, 29);
      expect(fullYears(nasc, DateTime(2025, 2, 28)), 12);
      expect(fullYears(nasc, DateTime(2025, 3, 1)), 13);
      expect(fullYears(nasc, DateTime(2024, 2, 29)), 12);
    });

    test('faixa pela data; data no futuro ou com mais de 120 anos → null', () {
      final hoje = DateTime(2026, 10, 4);
      expect(bandFromBirthDate(DateTime(2014, 10, 5), hoje), AgeBand.under13);
      expect(
        bandFromBirthDate(DateTime(2013, 10, 4), hoje),
        AgeBand.from13to15,
      );
      expect(bandFromBirthDate(DateTime(2009, 1, 1), hoje), AgeBand.from16to17);
      expect(bandFromBirthDate(DateTime(2008, 10, 4), hoje), AgeBand.adult);
      expect(bandFromBirthDate(DateTime(2027, 1, 1), hoje), isNull);
      expect(bandFromBirthDate(DateTime(1900, 1, 1), hoje), isNull);
    });

    test('DD/MM/AAAA (também com - ou .); data inexistente ou formato errado → null', () {
      expect(parseBirthDate('04/10/2008'), DateTime(2008, 10, 4));
      expect(parseBirthDate(' 4-1-2008 '), DateTime(2008, 1, 4));
      expect(parseBirthDate('29.02.2012'), DateTime(2012, 2, 29));
      expect(parseBirthDate('29/02/2013'), isNull);
      expect(parseBirthDate('31/04/2010'), isNull);
      expect(parseBirthDate('2010-04-01'), isNull);
      expect(parseBirthDate('04/10/08'), isNull);
      expect(parseBirthDate(''), isNull);
    });
  });
}

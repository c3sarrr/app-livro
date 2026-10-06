// G10.4 — velocidade pessoal e tempo restante (Anexo 03 §8, D-97): média móvel exponencial (α = 0,2) dos
// caracteres por minuto das sessões de 3 min ou mais, a primeira sessão começa a média; sem sessão assim,
// 1.000 car./min; o restante arredonda a 10 min acima de 1 h e a 5 min abaixo, e aparece "≈ H h MM min".
import 'package:app_leitura/features/reader/content/ref_pages.dart';
import 'package:app_leitura/features/reader/domain/reading_speed.dart';
import 'package:flutter_test/flutter_test.dart';

SpeedSample _s(int segundos, int? paginas, [double porPagina = 1500]) =>
    (activeSeconds: segundos, pagesViewed: paginas, charsPerRefPage: porPagina);

void main() {
  test('sem sessão de 3 min: 1.000 caracteres por minuto', () {
    expect(personalSpeed(const []), defaultCharsPerMinute);
    expect(defaultCharsPerMinute, 1000);
    // curtas demais ou sem página lida não entram
    expect(personalSpeed([_s(179, 5), _s(600, 0), _s(600, null)]), 1000);
  });

  test('a 1ª sessão começa a média; as seguintes pesam 0,2', () {
    // 10 páginas de 1.500 em 10 min = 1.500/min
    expect(personalSpeed([_s(600, 10)]), 1500);
    // + 3 páginas em 5 min = 900/min → 0,2 × 900 + 0,8 × 1.500 = 1.380
    expect(personalSpeed([_s(600, 10), _s(300, 3)]), closeTo(1380, 1e-9));
    // a sessão de 3 min exatos entra; a curta no meio não muda nada
    expect(
      personalSpeed([_s(600, 10), _s(60, 9), _s(180, 2)]),
      closeTo(0.2 * 1000 + 0.8 * 1500, 1e-9),
    );
    // o tamanho da página de referência de cada livro conta
    expect(personalSpeed([_s(600, 10, 3000)]), 3000);
  });

  test(
    'caracteres por página de referência: total ÷ páginas; sem índice, 1.500',
    () {
      expect(
        charsPerRefPage(totalChars: 395352, refPagesTotal: 264),
        395352 / 264,
      );
      expect(charsPerRefPage(), refPageChars.toDouble());
      expect(charsPerRefPage(totalChars: 0, refPagesTotal: 10), 1500);
      expect(charsPerRefPage(totalChars: 9000, refPagesTotal: 0), 1500);
    },
  );

  test(
    'tempo restante: 10 em 10 min acima de 1 h, 5 em 5 abaixo, no mínimo 5',
    () {
      Duration t(double minutos) => timeLeftFor((minutos * 1000).round(), 1000);
      expect(timeLeftFor(0, 1000), Duration.zero);
      expect(timeLeftFor(-5, 1000), Duration.zero);
      expect(timeLeftFor(5000, 0), Duration.zero);
      expect(t(1), const Duration(minutes: 5));
      expect(t(7.4), const Duration(minutes: 5));
      expect(t(7.5), const Duration(minutes: 10));
      expect(t(43), const Duration(minutes: 45));
      expect(t(59.9), const Duration(minutes: 60));
      expect(t(60), const Duration(minutes: 60));
      expect(t(64), const Duration(minutes: 60));
      expect(t(125), const Duration(minutes: 130));
      expect(t(134.9), const Duration(minutes: 130));
    },
  );

  test('"≈ 2 h 10 min" no leitor; abaixo de 1 h, "≈ 45 min"', () {
    expect(readerTimeLeftLabel(const Duration(minutes: 130)), '≈ 2 h 10 min');
    expect(readerTimeLeftLabel(const Duration(minutes: 60)), '≈ 1 h 00 min');
    expect(readerTimeLeftLabel(const Duration(minutes: 125)), '≈ 2 h 05 min');
    expect(readerTimeLeftLabel(const Duration(minutes: 45)), '≈ 45 min');
  });
}

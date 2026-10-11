// G19.1 — as datas dos cartões (R5), no fuso do aparelho.
import 'package:app_leitura/features/highlights/domain/card_dates.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const sp = Duration(hours: -3);
  Duration fuso(DateTime _) => sp;
  // 20/09/2026 20:00 em São Paulo
  final agora = DateTime.utc(2026, 9, 20, 23);
  String data(DateTime em, {bool ano = false}) =>
      cardDate(em, now: agora, offsetAt: fuso, withYear: ano);

  // o dia anterior já tem a data, como o arquivo (o grifo da pág. 152, de 19/09, mostra "19 set" no dia 20)
  test('hoje no fuso; ontem já é a data', () {
    expect(data(DateTime.utc(2026, 9, 20, 22, 41)), 'hoje'); // 19:41 SP
    expect(data(DateTime.utc(2026, 9, 21, 1)), 'hoje'); // 22:00 SP do mesmo dia
    expect(data(DateTime.utc(2026, 9, 20, 2, 59)), '19 set'); // 19/09 23:59 SP
    expect(data(DateTime.utc(2026, 9, 20, 3)), 'hoje'); // 20/09 00:00 SP
    expect(data(DateTime.utc(2026, 9, 19, 2, 59)), '18 set'); // 18/09 23:59 SP
  });

  test('no mesmo ano: dia e mês abreviado; em outro ano, com o ano', () {
    expect(data(DateTime.utc(2026, 9, 2, 22, 30)), '2 set');
    expect(data(DateTime.utc(2026, 1, 15, 12)), '15 jan');
    expect(data(DateTime.utc(2025, 12, 15, 12)), '15 dez 2025');
    expect(data(DateTime.utc(2027, 3, 1, 12)), '1 mar 2027');
  });

  test('os 12 meses', () {
    expect(
      [for (var m = 1; m <= 12; m++) data(DateTime.utc(2026, m, 10, 12))],
      [
        '10 jan',
        '10 fev',
        '10 mar',
        '10 abr',
        '10 mai',
        '10 jun',
        '10 jul',
        '10 ago',
        '10 set',
        '10 out',
        '10 nov',
        '10 dez',
      ],
    );
  });

  test('com o ano sempre (exportação), sem hoje', () {
    expect(data(DateTime.utc(2026, 9, 2, 22, 30), ano: true), '2 set 2026');
    expect(data(DateTime.utc(2026, 9, 20, 22, 41), ano: true), '20 set 2026');
  });

  test('horas locais (não UTC) também', () {
    expect(data(DateTime.utc(2026, 9, 20, 22, 41).toLocal()), 'hoje');
  });
}

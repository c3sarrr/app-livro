// G15.2 (D-149) — a fonte do clube do livro (faixa do sumário, tela 27): vazia no app até a G21; o fuso do aparelho
// para as datas da folha.
import 'package:app_leitura/features/reader/application/reader_club_source.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('NoReaderClub: nenhum clube — a faixa some até a G21', () async {
    expect(await const NoReaderClub().goalFor('dona', 'livro'), isNull);
  });

  test('readerUtcOffset: somado ao instante em UTC, dá o relógio do aparelho naquele instante', () {
    for (final t in [
      DateTime.utc(2026, 9, 20, 23),
      DateTime.utc(2026, 1, 15, 2, 30),
      DateTime.utc(2026, 7, 1, 12),
    ]) {
      final relogio = t.add(readerUtcOffset(t));
      final local = t.toLocal();
      expect(
        (
          relogio.year,
          relogio.month,
          relogio.day,
          relogio.hour,
          relogio.minute,
        ),
        (local.year, local.month, local.day, local.hour, local.minute),
      );
    }
  });
}

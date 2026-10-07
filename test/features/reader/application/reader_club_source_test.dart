// G15.2 (D-149) — a fonte do clube do livro (faixa do sumário, tela 27): vazia no app até a G21; o fuso do aparelho
// para as datas da folha.
import 'package:app_leitura/features/reader/application/reader_club_source.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('NoReaderClub: nenhum clube — a faixa some até a G21', () async {
    expect(await const NoReaderClub().goalFor('dona', 'livro'), isNull);
  });

  test('readerUtcOffset: o deslocamento do fuso do aparelho no instante', () {
    final t = DateTime.utc(2026, 9, 20, 23);
    expect(readerUtcOffset(t), t.toLocal().timeZoneOffset);
  });
}

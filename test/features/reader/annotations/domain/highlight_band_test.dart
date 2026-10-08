// G17 (D-172) — as faixas do fundo por altura, em frações da letra: Baixa 50–92 %, Média 12–92 % (a prévia da 23b,
// 14–92 %), Alta 0–100 %; sem altura, a Média.
import 'package:app_leitura/features/reader/annotations/domain/annotation.dart';
import 'package:app_leitura/features/reader/annotations/domain/highlight_band.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('na página: Baixa, Média, Alta e sem altura (a Média)', () {
    expect(fillBand(FillHeight.low), (0.50, 0.92));
    expect(fillBand(FillHeight.medium), (0.12, 0.92));
    expect(fillBand(FillHeight.high), (0.0, 1.0));
    expect(fillBand(null), (0.12, 0.92));
  });

  test('na prévia da 23b: só a Média muda (14 %)', () {
    expect(previewBand(FillHeight.low), (0.50, 0.92));
    expect(previewBand(FillHeight.medium), (0.14, 0.92));
    expect(previewBand(FillHeight.high), (0.0, 1.0));
    expect(previewBand(null), (0.14, 0.92));
  });
}

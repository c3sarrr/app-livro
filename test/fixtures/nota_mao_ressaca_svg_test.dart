// R00 (D-267) — a tinta da nota à mão do mundo embutida em Dart é a linha do arquivo do handoff, caractere a caractere
// (o mundo monta no aparelho sem o repositório).
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'nota_mao_ressaca_svg.dart';
import 'tinta_do_mundo.dart' show arquivoDaNotaAMao;

void main() {
  test('svgDaNotaAMao = a linha do arquivo nota_mao_ressaca.svg (sem a quebra final)', () {
    final arquivo = File(arquivoDaNotaAMao).readAsStringSync();
    // o arquivo é uma linha só, com a quebra no fim (LF ou CRLF, conforme o checkout)
    expect(arquivo, anyOf('$svgDaNotaAMao\n', '$svgDaNotaAMao\r\n'));
    expect(svgDaNotaAMao.length, 5694);
  });
}

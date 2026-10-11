// R00 (D-267) — a tinta da nota à mão do mundo embutida em Dart é o arquivo do handoff, byte a byte (o mundo monta no
// aparelho sem o repositório).
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'nota_mao_ressaca_svg.dart';
import 'tinta_do_mundo.dart' show arquivoDaNotaAMao;

void main() {
  test('svgDaNotaAMao = o arquivo nota_mao_ressaca.svg, byte a byte', () {
    expect(svgDaNotaAMao, File(arquivoDaNotaAMao).readAsStringSync());
    expect(svgDaNotaAMao.length, 5695);
  });
}

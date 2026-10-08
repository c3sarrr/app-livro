// G17.1 — os nomes das cores: as 6 favoritas da tela 23 (rótulos do leitor de tela e o subtítulo, R8, R12) e as 4
// cores do marca-texto da tela 23b (as da barra da tela 21 — R15, R17).
import 'package:app_leitura/core/design_system/color/color_names.dart';
import 'package:app_leitura/features/reader/presentation/highlight_toolbar.dart'
    show highlightPalette;
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('as 6 favoritas da tela 23, com os rótulos do arquivo', () {
    expect(penColorName('#FF552E'), 'Coral');
    expect(penColorName('#552CB7'), 'Roxo');
    expect(penColorName('#058CD7'), 'Azul');
    expect(penColorName('#00995E'), 'Verde');
    expect(penColorName('#F2A815'), 'Dourado');
    expect(penColorName('#1A1714'), 'Tinta preta');
    expect(penColorName('#ff552e'), 'Coral');
    expect(penColorName('#12AB34'), isNull);
  });

  test('as 4 cores do marca-texto, as mesmas da barra da tela 21', () {
    expect(markerColors, [for (final c in highlightPalette) c.hex]);
    expect(markerColorName('#FED170'), 'amarelo');
    expect(markerColorName('#FFC1C6'), 'rosa');
    expect(markerColorName('#ABCF82'), 'verde');
    expect(markerColorName('#B6ACE4'), 'lavanda');
    expect(markerColorName('#fed170'), 'amarelo');
    expect(markerColorName('#FF552E'), isNull);
  });

  test('o nome em minúsculas para o leitor de tela e os subtítulos', () {
    expect(colorNameOf('#FF552E'), 'coral');
    expect(colorNameOf('#1A1714'), 'tinta preta');
    expect(colorNameOf('#FED170'), 'amarelo');
    expect(colorNameOf('#12AB34'), isNull);
  });
}

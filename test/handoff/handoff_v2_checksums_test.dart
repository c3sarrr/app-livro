import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

/// G00: o pacote `handoff_v2/` (referências do arquivo do Claude Design e SQL de referência) é somente
/// leitura. Este teste falha se qualquer arquivo listado em `handoff_v2/CHECKSUMS.txt` mudar ou sumir.
/// (A G01 escreve `referencia/layout/` e `referencia/png/`, que ficam fora da lista de propósito.)
void main() {
  test('handoff_v2/CHECKSUMS.txt confere byte a byte', () {
    final lines = File('handoff_v2/CHECKSUMS.txt')
        .readAsLinesSync()
        .where((l) => l.trim().isNotEmpty)
        .toList();
    expect(lines, isNotEmpty);
    final problems = <String>[];
    for (final line in lines) {
      final match = RegExp(r'^([0-9a-f]{64}) \*(.+)$').firstMatch(line);
      expect(match, isNotNull, reason: 'linha inválida: $line');
      final expected = match!.group(1)!;
      final path = match.group(2)!;
      final file = File(path);
      if (!file.existsSync()) {
        problems.add('ausente: $path');
        continue;
      }
      final actual = sha256.convert(file.readAsBytesSync()).toString();
      if (actual != expected) problems.add('alterado: $path');
    }
    expect(problems, isEmpty, reason: problems.join('\n'));
    expect(lines.length, 36);
  });
}

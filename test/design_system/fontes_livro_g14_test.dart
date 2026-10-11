// G14.1 (D-18) — as 4 fontes do texto do livro entram completas, do google/fonts e sem modificação (a Lora tem
// Reserved Font Name): os arquivos byte a byte, as famílias no pubspec com os estilos certos e a licença.
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// sha256 dos arquivos do google/fonts (baixados em 06/10/2026).
const Map<String, String> _hashes = {
  'Lora-Wght.ttf':
      '822a6621ccbe8d97d20ac88c1c41f5615c9c2c202eaa75f272cd452aac6475a7',
  'Lora-Italic-Wght.ttf':
      '22d8d8854b53807aa664ca34f2031a9ed57a1d0dea296b8b96cdd3aad937a2b3',
  'Figtree-Wght.ttf':
      '26ad3db9b31ff7dde67a91ff515d022d2f495cd506590699cf264f0bfe6fb714',
  'Figtree-Italic-Wght.ttf':
      '94dec1f18b9275d69e8b4a91b6514bdc18199048347e1c36e1285b11b0b87653',
  'AtkinsonHyperlegible-Regular.ttf':
      '7fb917c89019896d0b52ee84b7cbb3304c18cb90b19a62f5e32712bd23e97669',
  'AtkinsonHyperlegible-Italic.ttf':
      '021beda4d3c6edfc78872e436d74009f9a1bcb294331908fe5747c61d3dcc514',
  'AtkinsonHyperlegible-Bold.ttf':
      '5a3b0c8cc8ca545155150b4512a1fa248298df121c50d6557e651e61fbdab92f',
  'AtkinsonHyperlegible-BoldItalic.ttf':
      '7a46f1b0ef2f64b61065c1a6b5a11fcb9b019b44062d88ba121a083cc39e86bf',
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('os 8 arquivos do livro são os do google/fonts, byte a byte', () {
    for (final e in _hashes.entries) {
      final f = File('assets/fonts/livro/${e.key}');
      expect(f.existsSync(), isTrue, reason: e.key);
      expect(
        sha256.convert(f.readAsBytesSync()).toString(),
        e.value,
        reason: e.key,
      );
    }
  });

  test('pubspec: LoraBook e FigtreeBook (variáveis + itálico), AtkinsonBook (400/700 + itálicos)', () async {
    final manifest = (json.decode(
      await rootBundle.loadString('FontManifest.json'),
    ) as List).cast<Map<String, dynamic>>();
    List<(String, int?, String?)> de(String family) => [
      for (final f
          in (manifest.singleWhere((m) => m['family'] == family)['fonts']
                  as List)
              .cast<Map<String, dynamic>>())
        (
          (f['asset'] as String).split('/').last,
          f['weight'] as int?,
          f['style'] as String?,
        ),
    ];
    expect(de('LoraBook'), [
      ('Lora-Wght.ttf', null, null),
      ('Lora-Italic-Wght.ttf', null, 'italic'),
    ]);
    expect(de('FigtreeBook'), [
      ('Figtree-Wght.ttf', null, null),
      ('Figtree-Italic-Wght.ttf', null, 'italic'),
    ]);
    expect(de('AtkinsonBook'), [
      ('AtkinsonHyperlegible-Regular.ttf', 400, null),
      ('AtkinsonHyperlegible-Italic.ttf', 400, 'italic'),
      ('AtkinsonHyperlegible-Bold.ttf', 700, null),
      ('AtkinsonHyperlegible-BoldItalic.ttf', 700, 'italic'),
    ]);
  });

  test('licença: os arquivos do livro listados, a Lora sem modificação', () {
    final t = File('assets/fonts/LICENCAS_FONTES_OFL.txt').readAsStringSync();
    expect(t, contains('livro/Lora{,-Italic}-Wght.ttf'));
    expect(t, contains('livro/Figtree{,-Italic}-Wght.ttf'));
    expect(
      t,
      contains(
        'livro/AtkinsonHyperlegible-{Regular,Italic,Bold,BoldItalic}.ttf',
      ),
    );
    expect(t, contains('google/fonts'));
  });
}

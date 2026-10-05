// G09.1 — leitor de ZIP do EPUB (Anexo 03 §4): acesso aleatório pelo arquivo, só as entradas pedidas, e
// nada de arquivo malicioso derrubar o app (limites de entradas, de tamanho e de compressão; CRC conferido).
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:app_leitura/features/reader/content/content_failure.dart';
import 'package:app_leitura/features/reader/content/zip_reader.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/epub_builder.dart';

/// Posição de cada registro do diretório central (assinatura PK\x01\x02).
List<int> _centralRecords(Uint8List z) => [
  for (var i = 0; i + 4 <= z.length; i++)
    if (z[i] == 0x50 && z[i + 1] == 0x4B && z[i + 2] == 1 && z[i + 3] == 2) i,
];

/// Posição de cada cabeçalho local (PK\x03\x04).
List<int> _localRecords(Uint8List z) => [
  for (var i = 0; i + 4 <= z.length; i++)
    if (z[i] == 0x50 && z[i + 1] == 0x4B && z[i + 2] == 3 && z[i + 3] == 4) i,
];

void _u32(Uint8List z, int at, int v) =>
    ByteData.sublistView(z).setUint32(at, v, Endian.little);

void _u16(Uint8List z, int at, int v) =>
    ByteData.sublistView(z).setUint16(at, v, Endian.little);

void main() {
  late Directory dir;
  setUp(() => dir = Directory.systemTemp.createTempSync('booknest_zip_'));
  tearDown(() => dir.deleteSync(recursive: true));

  ZipReader abrir(List<int> bytes) =>
      ZipReader.open(writeTemp(dir, 'a.zip', bytes));

  test('lê entradas guardadas e comprimidas, na ordem do diretório', () {
    final texto = 'Retórica dos namorados ' * 400;
    final z = abrir(
      zipBytes([
        ('mimetype', u('application/epub+zip')),
        ('OEBPS/a.xhtml', u(texto)),
        ('OEBPS/img/capa.jpg', tinyJpeg()),
      ]),
    );
    addTearDown(z.close);
    expect(z.names, ['mimetype', 'OEBPS/a.xhtml', 'OEBPS/img/capa.jpg']);
    expect(String.fromCharCodes(z.read('mimetype')), 'application/epub+zip');
    expect(z.readText('OEBPS/a.xhtml'), texto);
    expect(z.read('OEBPS/img/capa.jpg'), tinyJpeg());
    expect(z.contains('OEBPS/a.xhtml'), isTrue);
    expect(z.contains('oebps/A.XHTML'), isFalse);
    // nome com outra caixa: achado só pela busca tolerante
    expect(z.find('oebps/A.XHTML'), 'OEBPS/a.xhtml');
    expect(() => z.read('nao/existe'), throwsA(isA<ContentDamaged>()));
  });

  group(
    'arquivo que não é ZIP ou está quebrado → danificado (nunca exceção solta)',
    () {
      test('vazio, bytes aleatórios, PDF', () {
        for (final bytes in [
          <int>[],
          List<int>.generate(5000, (i) => Random(7).nextInt(256)),
          u('%PDF-1.7\n%âãÏÓ\n1 0 obj\n'),
        ]) {
          expect(() => abrir(bytes), throwsA(isA<ContentDamaged>()));
        }
      });

      test('ZIP cortado no meio', () {
        final z = zipBytes([
          ('mimetype', u('application/epub+zip')),
          ('a.txt', u('x' * 5000)),
        ]);
        expect(
          () => abrir(z.sublist(0, z.length ~/ 2)),
          throwsA(isA<ContentDamaged>()),
        );
      });

      test('CRC errado: a entrada é recusada', () {
        final z = zipBytes(
          [('a.txt', u('conteúdo original'))],
          stored: {'a.txt'},
        );
        // o conteúdo guardado (sem compressão) é trocado por outro do mesmo tamanho
        final loc = _localRecords(z).single;
        final d = ByteData.sublistView(z);
        final at =
            loc +
            30 +
            d.getUint16(loc + 26, Endian.little) +
            d.getUint16(loc + 28, Endian.little);
        z[at] = z[at] ^ 0xFF;
        final r = abrir(z);
        addTearDown(r.close);
        expect(() => r.read('a.txt'), throwsA(isA<ContentDamaged>()));
      });

      test('cabeçalho local que não confere com o diretório', () {
        final z = zipBytes([('a.txt', u('abc'))]);
        _u32(z, _localRecords(z).single, 0x12345678);
        final r = abrir(z);
        addTearDown(r.close);
        expect(() => r.read('a.txt'), throwsA(isA<ContentDamaged>()));
      });
    },
  );

  group('limites contra arquivo malicioso', () {
    test('mais de 10.000 entradas', () {
      final z = zipBytes(
        [
          for (var i = 0; i <= ZipReader.maxEntries; i++) ('f$i', const [1]),
        ],
        stored: {for (var i = 0; i <= ZipReader.maxEntries; i++) 'f$i'},
      );
      expect(() => abrir(z), throwsA(isA<ContentDamaged>()));
    });

    test('tamanho declarado acima do teto', () {
      final z = zipBytes([('a.txt', u('abc'))]);
      // tamanho descompactado no diretório central (offset 24)
      _u32(z, _centralRecords(z).single + 24, ZipReader.maxEntryBytes + 1);
      final r = abrir(z);
      addTearDown(r.close);
      expect(() => r.read('a.txt'), throwsA(isA<ContentDamaged>()));
    });

    test('bomba: declara pouco e infla muito → para no teto pedido', () {
      final z = zipBytes([('a.txt', List<int>.filled(3 * 1024 * 1024, 0x41))]);
      final r = abrir(z);
      addTearDown(r.close);
      expect(
        () => r.read('a.txt', maxBytes: 1024 * 1024),
        throwsA(isA<ContentDamaged>()),
      );
      // o mesmo arquivo com o tamanho declarado mentindo (diz 100 bytes)
      final mentira = Uint8List.fromList(z);
      _u32(mentira, _centralRecords(mentira).single + 24, 100);
      final r2 = abrir(mentira);
      addTearDown(r2.close);
      expect(() => r2.read('a.txt'), throwsA(isA<ContentDamaged>()));
    });

    test('tamanho comprimido que não combina com o descompactado → recusado antes de ler', () {
      // guardado (sem compressão) dizendo 5.000 bytes comprimidos para 3; e o mesmo num deflate
      for (final guardado in [true, false]) {
        final z = zipBytes(
          [('a.txt', u('abc')), ('b.bin', List<int>.filled(8000, 7))],
          stored: {if (guardado) 'a.txt', 'b.bin'},
        );
        _u32(z, _centralRecords(z).first + 20, 5000);
        final r = abrir(z);
        addTearDown(r.close);
        expect(
          () => r.read('a.txt'),
          throwsA(
            isA<ContentDamaged>().having(
              (e) => e.reason,
              'motivo',
              'zip_comprimido',
            ),
          ),
          reason: guardado ? 'guardado' : 'deflate',
        );
        expect(r.read('b.bin'), hasLength(8000));
      }
    });

    test('compressão acima de 100:1 numa entrada grande', () {
      final z = zipBytes([('a.txt', List<int>.filled(8 * 1024 * 1024, 0))]);
      final r = abrir(z);
      addTearDown(r.close);
      expect(() => r.read('a.txt'), throwsA(isA<ContentDamaged>()));
    });

    test('entrada cifrada no ZIP → protegido; compressão desconhecida → não suportado', () {
      final z = zipBytes([('a.txt', u('abc'))], stored: {'a.txt'});
      _u16(z, _centralRecords(z).single + 8, 0x0001); // flag de cifra
      final r = abrir(z);
      addTearDown(r.close);
      expect(() => r.read('a.txt'), throwsA(isA<ContentProtected>()));

      final b = zipBytes([('b.txt', u('abc'))], stored: {'b.txt'});
      _u16(b, _centralRecords(b).single + 10, 12); // bzip2
      final r2 = abrir(b);
      addTearDown(r2.close);
      expect(() => r2.read('b.txt'), throwsA(isA<ContentUnsupported>()));
    });
  });
}

// G10.2 — tamanho natural das imagens do livro pelo cabeçalho (PNG, JPEG, GIF, WebP), sem decodificar; o que
// não é imagem conhecida ou está cortado → sem tamanho (a imagem não ocupa espaço na página).
import 'dart:typed_data';

import 'package:app_leitura/features/reader/content/image_size.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/image_headers.dart';

void main() {
  test('PNG, JPEG (baseline e progressivo), GIF e os três WebP', () {
    expect(imageSizeOf(pngHeader(1600, 1200)), (1600, 1200));
    expect(imageSizeOf(jpegHeader(640, 480)), (640, 480));
    expect(imageSizeOf(jpegHeader(300, 2000, sof: 0xC2)), (300, 2000));
    expect(imageSizeOf(gifHeader(100, 50)), (100, 50));
    expect(imageSizeOf(webpLossy(800, 600)), (800, 600));
    expect(imageSizeOf(webpLossless(321, 123)), (321, 123));
    expect(imageSizeOf(webpExtended(70000, 3)), (70000, 3));
  });

  test('não é imagem, cabeçalho cortado, tamanho zero → sem tamanho', () {
    expect(imageSizeOf(Uint8List(0)), isNull);
    expect(imageSizeOf(Uint8List.fromList('não é imagem'.codeUnits)), isNull);
    expect(imageSizeOf(pngHeader(10, 10).sublist(0, 20)), isNull);
    expect(imageSizeOf(pngHeader(0, 10)), isNull);
    expect(imageSizeOf(jpegHeader(40, 40).sublist(0, 24)), isNull);
    // JPEG sem SOF (só o começo do arquivo)
    expect(
      imageSizeOf(Uint8List(64)..setAll(0, const [0xFF, 0xD8, 0xFF, 0xE0])),
      isNull,
    );
    // DHT (C4) não é SOF
    expect(imageSizeOf(jpegHeader(40, 40, sof: 0xC4)), isNull);
  });
}

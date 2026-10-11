// G09.4 — PNG mínimo (RGBA 8 bits, sem filtro, zlib do `dart:io`) para a capa tirada da 1ª página do PDF
// (D-90). Dart puro: roda fora da interface e nos testes.
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart' show getCrc32;

/// PNG de uma imagem [width]×[height] em BGRA8888 (a saída do PDFium).
Uint8List encodePngFromBgra(Uint8List bgra, int width, int height) {
  if (width <= 0 || height <= 0 || bgra.length < width * height * 4) {
    throw ArgumentError(
      'imagem inválida: ${width}x$height, ${bgra.length} bytes',
    );
  }
  final stride = width * 4;
  final raw = Uint8List(height * (stride + 1));
  var o = 0;
  for (var y = 0; y < height; y++) {
    raw[o++] = 0; // sem filtro
    final row = y * stride;
    for (var x = 0; x < stride; x += 4) {
      raw[o++] = bgra[row + x + 2];
      raw[o++] = bgra[row + x + 1];
      raw[o++] = bgra[row + x];
      raw[o++] = bgra[row + x + 3];
    }
  }
  final out = BytesBuilder(copy: false)
    ..add(const [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);
  void chunk(String type, List<int> data) {
    final len = ByteData(4)..setUint32(0, data.length);
    final body = Uint8List.fromList([...type.codeUnits, ...data]);
    final crc = ByteData(4)..setUint32(0, getCrc32(body));
    out
      ..add(len.buffer.asUint8List())
      ..add(body)
      ..add(crc.buffer.asUint8List());
  }

  final ihdr = ByteData(13)
    ..setUint32(0, width)
    ..setUint32(4, height)
    ..setUint8(8, 8) // bits por canal
    ..setUint8(9, 6) // RGBA
    ..setUint8(10, 0)
    ..setUint8(11, 0)
    ..setUint8(12, 0);
  chunk('IHDR', ihdr.buffer.asUint8List());
  chunk('IDAT', ZLibEncoder(level: 6).convert(raw));
  chunk('IEND', const []);
  return out.takeBytes();
}

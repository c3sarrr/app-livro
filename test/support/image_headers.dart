// G10.2 — cabeçalhos mínimos de imagem (só o que diz o tamanho) para os testes do leitor.
import 'dart:typed_data';

Uint8List _be32(int v) => Uint8List(4)..buffer.asByteData().setUint32(0, v);

/// PNG: assinatura + IHDR com [w] × [h] (o resto do arquivo não importa para o tamanho).
Uint8List pngHeader(int w, int h) => Uint8List.fromList([
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, //
  0, 0, 0, 13, 0x49, 0x48, 0x44, 0x52,
  ..._be32(w),
  ..._be32(h),
  8, 6, 0, 0, 0, 0, 0, 0, 0,
]);

/// JPEG: SOI, um APP0 de 16 bytes e o SOF0 com [w] × [h].
Uint8List jpegHeader(int w, int h, {int sof = 0xC0}) => Uint8List.fromList([
  0xFF, 0xD8, //
  0xFF, 0xE0, 0, 16, ...List.filled(14, 0),
  0xFF, sof, 0, 17, 8, h >> 8, h & 0xFF, w >> 8, w & 0xFF, 3,
  ...List.filled(9, 0),
]);

/// GIF89a com [w] × [h].
Uint8List gifHeader(int w, int h) => Uint8List.fromList([
  0x47, 0x49, 0x46, 0x38, 0x39, 0x61, //
  w & 0xFF, w >> 8, h & 0xFF, h >> 8, 0, 0, 0,
]);

Uint8List _riff(String chunk, List<int> payload) => Uint8List.fromList([
  ...'RIFF'.codeUnits, 0, 0, 0, 0, ...'WEBP'.codeUnits, //
  ...chunk.codeUnits, payload.length, 0, 0, 0, ...payload,
]);

/// WebP com perdas (VP8): tamanho em 14 bits depois do código de início.
Uint8List webpLossy(int w, int h) => _riff('VP8 ', [
  0,
  0,
  0,
  0x9D,
  0x01,
  0x2A,
  w & 0xFF,
  (w >> 8) & 0x3F,
  h & 0xFF,
  (h >> 8) & 0x3F, //
  ...List.filled(10, 0),
]);

/// WebP sem perdas (VP8L): assinatura 0x2F e (w−1, h−1) em 14 bits cada.
Uint8List webpLossless(int w, int h) {
  final v = (w - 1) | ((h - 1) << 14);
  return _riff('VP8L', [
    0x2F,
    v & 0xFF,
    (v >> 8) & 0xFF,
    (v >> 16) & 0xFF,
    (v >> 24) & 0xFF,
    ...List.filled(10, 0),
  ]);
}

/// WebP estendido (VP8X): (w−1, h−1) em 24 bits cada.
Uint8List webpExtended(int w, int h) => _riff('VP8X', [
  0, 0, 0, 0, //
  (w - 1) & 0xFF, ((w - 1) >> 8) & 0xFF, ((w - 1) >> 16) & 0xFF,
  (h - 1) & 0xFF, ((h - 1) >> 8) & 0xFF, ((h - 1) >> 16) & 0xFF,
  ...List.filled(10, 0),
]);

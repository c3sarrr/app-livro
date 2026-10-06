// G10.2 — tamanho natural de uma imagem do livro (px) pelo cabeçalho do arquivo, sem decodificar: PNG, JPEG,
// GIF e WebP (VP8, VP8L, VP8X). Roda no isolate do conteúdo; a paginação precisa só do tamanho (D-96: a imagem
// cabe inteira na página, escalada, sem ampliar).
import 'dart:typed_data';

/// Largura × altura em px, ou `null` quando o formato não é conhecido ou o cabeçalho está quebrado.
(int, int)? imageSizeOf(Uint8List b) {
  try {
    return _png(b) ?? _gif(b) ?? _webp(b) ?? _jpeg(b);
  } on RangeError {
    return null;
  }
}

(int, int)? _valid(int w, int h) => w > 0 && h > 0 ? (w, h) : null;

(int, int)? _png(Uint8List b) {
  const sig = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];
  if (b.length < 24) return null;
  for (var i = 0; i < 8; i++) {
    if (b[i] != sig[i]) return null;
  }
  final d = ByteData.sublistView(b);
  return _valid(d.getUint32(16), d.getUint32(20));
}

(int, int)? _gif(Uint8List b) {
  if (b.length < 10 || b[0] != 0x47 || b[1] != 0x49 || b[2] != 0x46) {
    return null;
  }
  final d = ByteData.sublistView(b);
  return _valid(d.getUint16(6, Endian.little), d.getUint16(8, Endian.little));
}

(int, int)? _webp(Uint8List b) {
  if (b.length < 30 ||
      String.fromCharCodes(b, 0, 4) != 'RIFF' ||
      String.fromCharCodes(b, 8, 12) != 'WEBP') {
    return null;
  }
  final d = ByteData.sublistView(b);
  switch (String.fromCharCodes(b, 12, 16)) {
    case 'VP8 ':
      return _valid(
        d.getUint16(26, Endian.little) & 0x3FFF,
        d.getUint16(28, Endian.little) & 0x3FFF,
      );
    case 'VP8L':
      final v = d.getUint32(21, Endian.little);
      return _valid((v & 0x3FFF) + 1, ((v >> 14) & 0x3FFF) + 1);
    case 'VP8X':
      int u24(int at) => b[at] | (b[at + 1] << 8) | (b[at + 2] << 16);
      return _valid(u24(24) + 1, u24(27) + 1);
  }
  return null;
}

(int, int)? _jpeg(Uint8List b) {
  if (b.length < 4 || b[0] != 0xFF || b[1] != 0xD8) return null;
  final d = ByteData.sublistView(b);
  var i = 2;
  while (i + 9 < b.length) {
    if (b[i] != 0xFF) return null;
    final marker = b[i + 1];
    if (marker == 0xFF) {
      i++; // preenchimento
      continue;
    }
    // SOF0–SOF15, menos DHT (C4), JPG (C8) e DAC (CC)
    if (marker >= 0xC0 &&
        marker <= 0xCF &&
        marker != 0xC4 &&
        marker != 0xC8 &&
        marker != 0xCC) {
      return _valid(d.getUint16(i + 7), d.getUint16(i + 5));
    }
    if (marker == 0xD8 || (marker >= 0xD0 && marker <= 0xD7)) {
      i += 2;
      continue;
    }
    i += 2 + d.getUint16(i + 2);
  }
  return null;
}

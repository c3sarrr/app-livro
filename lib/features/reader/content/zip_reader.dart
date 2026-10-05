// G09.1 — leitor do ZIP do EPUB (Anexo 03 §4): acesso aleatório pelo arquivo (só o diretório central e as
// entradas pedidas são lidos), inflate do `dart:io` com teto, CRC conferido. Um leitor próprio em vez do
// decodificador do pacote `archive` porque aquele descompacta a entrada inteira na memória antes de qualquer
// limite (bomba de ZIP). Síncrono: roda dentro do isolate da indexação.
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:archive/archive.dart' show getCrc32;

import 'content_failure.dart';

/// Uma entrada do diretório central.
final class ZipEntry {
  const ZipEntry({
    required this.name,
    required this.flags,
    required this.method,
    required this.crc32,
    required this.compressedSize,
    required this.size,
    required this.localHeaderOffset,
  });

  final String name;
  final int flags;
  final int method;
  final int crc32;
  final int compressedSize;
  final int size;
  final int localHeaderOffset;

  bool get encrypted => flags & 0x0001 != 0;
}

final class ZipReader {
  ZipReader._(this._raf, this._length, this._entries)
    : _byLower = {
        for (final n in _entries.keys.toList().reversed) n.toLowerCase(): n,
      };

  /// Limites contra arquivo malicioso (D-93).
  static const int maxEntries = 10000;
  static const int maxEntryBytes = 64 * 1024 * 1024;
  static const int maxRatio = 100;

  /// A razão de compressão só é conferida em entradas maiores que isto (texto pequeno comprime muito).
  static const int ratioFloorBytes = 1024 * 1024;
  static const int _maxCentralDirectory = 16 * 1024 * 1024;
  static const int _chunk = 64 * 1024;

  final RandomAccessFile _raf;
  final int _length;
  final Map<String, ZipEntry> _entries;
  final Map<String, String> _byLower;

  /// Abre o ZIP em [path]. Não é ZIP / está cortado / passa dos limites → [ContentDamaged].
  static ZipReader open(String path) {
    final RandomAccessFile raf;
    try {
      raf = File(path).openSync();
    } on FileSystemException {
      throw const ContentDamaged('zip_abrir');
    }
    try {
      final length = raf.lengthSync();
      return ZipReader._(raf, length, _readDirectory(raf, length));
    } on ContentFailure {
      raf.closeSync();
      rethrow;
    } on Object {
      raf.closeSync();
      throw const ContentDamaged('zip');
    }
  }

  /// Nomes na ordem do diretório central.
  List<String> get names => _entries.keys.toList(growable: false);

  bool contains(String name) => _entries.containsKey(name);

  ZipEntry? entry(String name) => _entries[name];

  /// O nome exato, ou o primeiro com a mesma grafia sem caixa (EPUBs com `href` em outra caixa).
  String? find(String name) =>
      _entries.containsKey(name) ? name : _byLower[name.toLowerCase()];

  /// Bytes da entrada [name], até [maxBytes] (padrão: [maxEntryBytes]).
  Uint8List read(String name, {int? maxBytes}) {
    final e = _entries[name];
    if (e == null) throw const ContentDamaged('zip_entrada_ausente');
    if (e.encrypted) throw const ContentProtected('encrypted');
    if (e.method != 0 && e.method != 8) {
      throw const ContentUnsupported('zip_compressao');
    }
    final cap = math.min(maxBytes ?? maxEntryBytes, maxEntryBytes);
    if (e.size > cap) throw const ContentDamaged('zip_entrada_grande');
    if (e.size > ratioFloorBytes && e.compressedSize * maxRatio < e.size) {
      throw const ContentDamaged('zip_razao');
    }
    try {
      final head = _readAt(e.localHeaderOffset, 30);
      final h = ByteData.sublistView(head);
      if (h.getUint32(0, Endian.little) != 0x04034b50) {
        throw const ContentDamaged('zip_cabecalho_local');
      }
      final start =
          e.localHeaderOffset +
          30 +
          h.getUint16(26, Endian.little) +
          h.getUint16(28, Endian.little);
      if (start + e.compressedSize > _length) {
        throw const ContentDamaged('zip_cortado');
      }
      final raw = _readAt(start, e.compressedSize);
      final data = e.method == 0 ? raw : _inflate(raw, e.size);
      if (data.length != e.size) throw const ContentDamaged('zip_tamanho');
      if (getCrc32(data) != e.crc32) throw const ContentDamaged('zip_crc');
      return data;
    } on ContentFailure {
      rethrow;
    } on Object {
      throw const ContentDamaged('zip_entrada');
    }
  }

  /// Texto UTF-8 da entrada (bytes inválidos viram U+FFFD).
  String readText(String name, {int? maxBytes}) =>
      utf8.decode(read(name, maxBytes: maxBytes), allowMalformed: true);

  void close() => _raf.closeSync();

  Uint8List _readAt(int position, int n) => _readSync(_raf, position, n);

  static Uint8List _readSync(RandomAccessFile raf, int position, int n) {
    raf.setPositionSync(position);
    final b = raf.readSync(n);
    if (b.length != n) throw const ContentDamaged('zip_cortado');
    return b;
  }

  /// Inflate em pedaços; passa de [limit] bytes → danificado (a entrada mentiu o tamanho).
  static Uint8List _inflate(Uint8List raw, int limit) {
    final out = _CappedSink(limit);
    final inflater = ZLibDecoder(raw: true).startChunkedConversion(out);
    for (var i = 0; i < raw.length; i += _chunk) {
      inflater.add(
        Uint8List.sublistView(raw, i, math.min(raw.length, i + _chunk)),
      );
    }
    inflater.close();
    return out.bytes();
  }

  static Map<String, ZipEntry> _readDirectory(
    RandomAccessFile raf,
    int length,
  ) {
    if (length < 22) throw const ContentDamaged('zip_curto');
    final tailLen = math.min(length, 22 + 0xFFFF);
    final tail = _readSync(raf, length - tailLen, tailLen);
    final t = ByteData.sublistView(tail);
    var eocd = -1;
    for (var i = tail.length - 22; i >= 0; i--) {
      if (t.getUint32(i, Endian.little) == 0x06054b50) {
        eocd = i;
        break;
      }
    }
    if (eocd < 0) throw const ContentDamaged('zip_sem_diretorio');
    var count = t.getUint16(eocd + 10, Endian.little);
    var cdSize = t.getUint32(eocd + 12, Endian.little);
    var cdOffset = t.getUint32(eocd + 16, Endian.little);
    if (count == 0xFFFF || cdSize == 0xFFFFFFFF || cdOffset == 0xFFFFFFFF) {
      // ZIP64: localizador logo antes do fim do diretório
      final locAt = length - tailLen + eocd - 20;
      if (locAt < 0) throw const ContentDamaged('zip64');
      final loc = ByteData.sublistView(_readSync(raf, locAt, 20));
      if (loc.getUint32(0, Endian.little) != 0x07064b50) {
        throw const ContentDamaged('zip64');
      }
      final recAt = loc.getUint64(8, Endian.little);
      if (recAt < 0 || recAt + 56 > length) throw const ContentDamaged('zip64');
      final rec = ByteData.sublistView(_readSync(raf, recAt, 56));
      if (rec.getUint32(0, Endian.little) != 0x06064b50) {
        throw const ContentDamaged('zip64');
      }
      count = rec.getUint64(32, Endian.little);
      cdSize = rec.getUint64(40, Endian.little);
      cdOffset = rec.getUint64(48, Endian.little);
    }
    if (count > maxEntries) throw const ContentDamaged('zip_entradas');
    if (cdSize > _maxCentralDirectory ||
        cdOffset < 0 ||
        cdOffset + cdSize > length) {
      throw const ContentDamaged('zip_diretorio');
    }
    final cd = _readSync(raf, cdOffset, cdSize);
    final d = ByteData.sublistView(cd);
    final entries = <String, ZipEntry>{};
    var p = 0;
    var n = 0;
    while (p + 46 <= cd.length && d.getUint32(p, Endian.little) == 0x02014b50) {
      if (++n > maxEntries) throw const ContentDamaged('zip_entradas');
      final flags = d.getUint16(p + 8, Endian.little);
      final method = d.getUint16(p + 10, Endian.little);
      final crc = d.getUint32(p + 16, Endian.little);
      var compressed = d.getUint32(p + 20, Endian.little);
      var size = d.getUint32(p + 24, Endian.little);
      final nameLen = d.getUint16(p + 28, Endian.little);
      final extraLen = d.getUint16(p + 30, Endian.little);
      final commentLen = d.getUint16(p + 32, Endian.little);
      var offset = d.getUint32(p + 42, Endian.little);
      final end = p + 46 + nameLen + extraLen + commentLen;
      if (end > cd.length) throw const ContentDamaged('zip_diretorio');
      final nameBytes = Uint8List.sublistView(cd, p + 46, p + 46 + nameLen);
      if (size == 0xFFFFFFFF ||
          compressed == 0xFFFFFFFF ||
          offset == 0xFFFFFFFF) {
        // campo extra 0x0001: só os valores marcados, nesta ordem
        var x = p + 46 + nameLen;
        final xEnd = x + extraLen;
        while (x + 4 <= xEnd) {
          final id = d.getUint16(x, Endian.little);
          final len = d.getUint16(x + 2, Endian.little);
          if (id == 0x0001) {
            var q = x + 4;
            if (size == 0xFFFFFFFF && q + 8 <= x + 4 + len) {
              size = d.getUint64(q, Endian.little);
              q += 8;
            }
            if (compressed == 0xFFFFFFFF && q + 8 <= x + 4 + len) {
              compressed = d.getUint64(q, Endian.little);
              q += 8;
            }
            if (offset == 0xFFFFFFFF && q + 8 <= x + 4 + len) {
              offset = d.getUint64(q, Endian.little);
            }
          }
          x += 4 + len;
        }
      }
      if (offset < 0 || offset + 30 > length || compressed < 0 || size < 0) {
        throw const ContentDamaged('zip_diretorio');
      }
      final name = _name(nameBytes, flags);
      entries.putIfAbsent(
        name,
        () => ZipEntry(
          name: name,
          flags: flags,
          method: method,
          crc32: crc,
          compressedSize: compressed,
          size: size,
          localHeaderOffset: offset,
        ),
      );
      p = end;
    }
    if (entries.isEmpty) throw const ContentDamaged('zip_vazio');
    return entries;
  }

  static String _name(Uint8List bytes, int flags) {
    if (flags & 0x0800 != 0) return utf8.decode(bytes, allowMalformed: true);
    try {
      return utf8.decode(bytes);
    } on FormatException {
      return latin1.decode(bytes);
    }
  }
}

/// Recebe a saída do inflate e para no teto.
final class _CappedSink implements Sink<List<int>> {
  _CappedSink(this.limit);

  final int limit;
  final BytesBuilder _out = BytesBuilder(copy: false);

  @override
  void add(List<int> data) {
    if (_out.length + data.length > limit) {
      throw const ContentDamaged('zip_inflado_demais');
    }
    _out.add(data);
  }

  @override
  void close() {}

  Uint8List bytes() => _out.takeBytes();
}

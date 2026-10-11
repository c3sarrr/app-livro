// G09.4 — cópia do arquivo importado para a pasta dos livros (Anexo 03 §3): em pedaços, com o SHA-256
// calculado durante a cópia (nada inteiro na memória; cada escrita espera o disco). O tipo sai do conteúdo.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart'
    show CouldNotRollBackException, DriftWrappedException;
import 'package:drift/native.dart' show SqliteException;

final class CopiedFile {
  const CopiedFile({
    required this.file,
    required this.bytes,
    required this.sha256,
    required this.head,
  });

  final File file;
  final int bytes;

  /// SHA-256 em hexadecimal minúsculo.
  final String sha256;

  /// Primeiros bytes (até 1 KiB) para reconhecer o tipo.
  final Uint8List head;
}

/// Copia [source] para [target] com o SHA-256. Falhou no meio → apaga o parcial e relança.
Future<CopiedFile> copyWithSha256(Stream<List<int>> source, File target) async {
  final out = _DigestSink();
  final hasher = sha256.startChunkedConversion(out);
  final head = BytesBuilder(copy: true);
  var bytes = 0;
  final raf = await target.open(mode: FileMode.write);
  try {
    await for (final chunk in source) {
      hasher.add(chunk);
      if (head.length < 1024) {
        head.add(
          chunk.length <= 1024 - head.length
              ? chunk
              : chunk.sublist(0, 1024 - head.length),
        );
      }
      await raf.writeFrom(chunk);
      bytes += chunk.length;
    }
    await raf.flush();
    await raf.close();
  } on Object {
    try {
      await raf.close();
    } on Object {
      // já fechado
    }
    if (await target.exists()) {
      await target.delete();
    }
    rethrow;
  }
  hasher.close();
  return CopiedFile(
    file: target,
    bytes: bytes,
    sha256: out.value.toString(),
    head: head.toBytes(),
  );
}

final class _DigestSink implements Sink<Digest> {
  late Digest value;

  @override
  void add(Digest data) => value = data;

  @override
  void close() {}
}

enum BookFileKind { epub, pdf, unknown }

/// EPUB (ZIP — o pacote confere depois) ou PDF (`%PDF-` no primeiro 1 KiB, como os leitores aceitam).
BookFileKind sniffBookFile(Uint8List head) {
  if (head.length >= 4 &&
      head[0] == 0x50 &&
      head[1] == 0x4B &&
      head[2] == 0x03 &&
      head[3] == 0x04) {
    return BookFileKind.epub;
  }
  if (latin1.decode(head, allowInvalid: true).contains('%PDF-')) {
    return BookFileKind.pdf;
  }
  return BookFileKind.unknown;
}

/// Disco cheio: no arquivo (Android/iOS/Linux ENOSPC = 28; Windows 112 e 39) ou no banco (SQLITE_FULL = 13,
/// inclusive embrulhado pelo drift).
bool isNoSpace(Object e) => switch (e) {
  FileSystemException(:final osError) =>
    osError?.errorCode == 28 ||
        osError?.errorCode == 112 ||
        osError?.errorCode == 39,
  SqliteException(:final resultCode) => resultCode == 13,
  CouldNotRollBackException(:final cause) => isNoSpace(cause),
  DriftWrappedException(:final cause?) => isNoSpace(cause),
  _ => false,
};

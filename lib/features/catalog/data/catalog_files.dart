// Download dos arquivos do catálogo com retomada (Range + If-Range) e conferência por sha256.
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

import '../domain/catalog_failure.dart';
import 'catalog_manifest.dart';

/// Tempo máximo sem chegar nenhum byte (o arquivo tem dezenas de MB: o total não tem limite).
const Duration catalogIdleTimeout = Duration(seconds: 60);

/// sha256 de um arquivo em fluxo (fora da thread da interface).
Future<String> fileSha256(String path) => Isolate.run(() async {
  final digest = await sha256.bind(File(path).openRead()).first;
  return digest.toString();
});

/// Descomprime [gz] em [out] e devolve o sha256 do resultado (fora da thread da interface).
Future<String> gunzipWithSha256(String gz, String out) => Isolate.run(() async {
  final sink = File(out).openWrite();
  final hash = _Coletor();
  final hashing = sha256.startChunkedConversion(hash);
  try {
    await for (final chunk in File(gz).openRead().transform(gzip.decoder)) {
      hashing.add(chunk);
      sink.add(chunk);
    }
  } finally {
    // fecha mesmo com o gzip quebrado: no Windows, arquivo aberto não pode ser apagado depois
    await sink.close();
  }
  hashing.close();
  return hash.value.toString();
});

final class _Coletor implements Sink<Digest> {
  late Digest value;

  @override
  void add(Digest data) => value = data;

  @override
  void close() {}
}

/// Baixa [file] para [dir] (`<nome>.part` enquanto incompleto), retomando do ponto. Devolve o arquivo
/// completo, já conferido. O `.part.json` guarda o sha256 esperado e o ETag (If-Range).
Future<File> downloadCatalogFile({
  required http.Client client,
  required Uri base,
  required Directory dir,
  required CatalogFile file,
}) async {
  final name = file.path.split('/').last;
  final part = File('${dir.path}${Platform.pathSeparator}$name.part');
  final info = File('${part.path}.json');
  Map<String, Object?> state = {};
  if (await info.exists()) {
    try {
      state = jsonDecode(await info.readAsString()) as Map<String, Object?>;
    } on FormatException {
      state = {};
    }
  }
  if (state['sha256'] != file.sha256) {
    // outro arquivo (versão nova): recomeça
    if (await part.exists()) await part.delete();
    state = {'sha256': file.sha256};
  }
  // já baixado e conferido numa tentativa anterior (que falhou depois, ao descompactar): reaproveita
  final done = File('${dir.path}${Platform.pathSeparator}$name');
  if (await done.exists()) {
    if (await done.length() == file.bytes &&
        await fileSha256(done.path) == file.sha256) {
      return done;
    }
    await done.delete(); // de outra versão
  }
  final url = base.resolve(
    'v1/catalog/${file.path.replaceFirst('catalog/v1/', '')}',
  );
  for (var tentativa = 0; tentativa < 2; tentativa++) {
    var have = await part.exists() ? await part.length() : 0;
    if (have < file.bytes) {
      final req = http.Request('GET', url);
      final etag = state['etag'];
      if (have > 0) {
        req.headers['Range'] = 'bytes=$have-';
        if (etag is String) req.headers['If-Range'] = etag;
      }
      final http.StreamedResponse resp;
      try {
        resp = await client.send(req).timeout(const Duration(seconds: 30));
      } on TimeoutException {
        throw const CatalogOffline();
      } on SocketException {
        throw const CatalogOffline();
      } on http.ClientException {
        throw const CatalogOffline();
      }
      if (resp.statusCode == 416) {
        await resp.stream.drain<void>();
        await part.delete();
        continue;
      }
      if (resp.statusCode == 429) {
        await resp.stream.drain<void>();
        throw const CatalogQuotaExceeded();
      }
      if (resp.statusCode != 200 && resp.statusCode != 206) {
        await resp.stream.drain<void>();
        throw resp.statusCode >= 500
            ? CatalogOffline('http_${resp.statusCode}')
            : CatalogUnexpected('http_${resp.statusCode}');
      }
      final newEtag = resp.headers['etag'];
      if (newEtag != null) state['etag'] = newEtag;
      await info.writeAsString(jsonEncode(state), flush: true);
      final sink = part.openWrite(
        mode: resp.statusCode == 206 ? FileMode.append : FileMode.write,
      );
      // o erro do fluxo NÃO passa para o arquivo: o que chegou fica gravado e a próxima vez retoma
      CatalogFailure? cut;
      var pending = 0;
      try {
        await for (final chunk in resp.stream.timeout(catalogIdleTimeout)) {
          sink.add(chunk);
          pending += chunk.length;
          if (pending >= 4 << 20) {
            await sink.flush();
            pending = 0;
          }
        }
      } on TimeoutException {
        cut = const CatalogOffline('parado');
      } on SocketException {
        cut = const CatalogOffline();
      } on http.ClientException {
        cut = const CatalogOffline();
      } finally {
        await sink.close();
      }
      if (cut != null) throw cut;
      have = await part.length();
    }
    if (have == file.bytes && await fileSha256(part.path) == file.sha256) {
      await info.delete();
      return part.rename(done.path);
    }
    // tamanho ou hash diferente: descarta e tenta uma vez do zero
    await part.delete();
    state.remove('etag');
  }
  // nada de sobra na pasta do catálogo
  if (await info.exists()) {
    await info.delete();
  }
  throw const CatalogCorrupted('sha');
}

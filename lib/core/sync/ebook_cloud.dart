// E-books na nuvem (Pro, opcional — Anexo 02 §6.4, G06): o cliente nunca toca no bucket direto.
//   upload   → URL assinada da Edge Function `ebook-upload-url` (confere Pro e a cota de 2 GB) e envio
//              RETOMÁVEL (TUS em `/storage/v1/upload/resumable/sign` com o token da URL assinada —
//              provado na G06: corte no meio, retomada do ponto, mesmo sha256; token inválido ou de
//              outro caminho é recusado);
//   download → URL de 5 min da Edge Function `ebook-download-url`; o arquivo só fica se o sha256 bater.
// O caminho do arquivo na nuvem vai no livro (`storage_object_path`) e chega aos outros aparelhos pela
// sincronização; o 2º aparelho baixa sob demanda.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart'
    show FunctionException, FunctionsFetchException, SupabaseClient;

import '../data/database/app_database.dart';
import '../data/database/daos/kv_dao.dart';
import '../data/database/daos/library_daos.dart';
import '../data/database/versioning.dart';
import '../data/model/nullable.dart';

// ------------------------------------------------------------------------- falhas

@immutable
sealed class EbookCloudFailure implements Exception {
  const EbookCloudFailure(this.code);

  /// Código curto, sem conteúdo (telemetria e mensagens).
  final String code;

  @override
  String toString() => 'EbookCloudFailure($code)';
}

final class EbookProRequired extends EbookCloudFailure {
  const EbookProRequired() : super('pro_required');
}

final class EbookQuotaExceeded extends EbookCloudFailure {
  const EbookQuotaExceeded() : super('quota_exceeded');
}

final class EbookNotFound extends EbookCloudFailure {
  const EbookNotFound(super.code);
}

/// O arquivo baixado não é o do livro (sha256 diferente) — descartado.
final class EbookCorrupted extends EbookCloudFailure {
  const EbookCorrupted() : super('sha_diferente');
}

/// Sem rede ou erro passageiro: tentar de novo depois (o envio retoma de onde parou).
final class EbookTransient extends EbookCloudFailure {
  const EbookTransient(super.code);
}

/// O token da URL assinada não vale mais (venceu no meio do envio): a próxima tentativa pede outro.
final class EbookTicketExpired extends EbookTransient {
  const EbookTicketExpired() : super('token_vencido');
}

final class EbookUnexpected extends EbookCloudFailure {
  const EbookUnexpected(super.code);
}

// ------------------------------------------------------------------------- servidor

@immutable
final class UploadTicket {
  const UploadTicket({required this.path, required this.token});
  final String path;
  final String token;
}

@immutable
final class DownloadTicket {
  const DownloadTicket({required this.path, required this.url});
  final String path;
  final Uri url;
}

abstract interface class EbookCloudApi {
  Future<UploadTicket> uploadTicket({
    required String userBookId,
    required String sha256,
    required int bytes,
  });

  Future<DownloadTicket> downloadTicket(String userBookId);
}

final class SupabaseEbookCloudApi implements EbookCloudApi {
  SupabaseEbookCloudApi(this._client, {required this.projectUrl});

  final SupabaseClient _client;

  /// Endereço público do projeto (`SUPABASE_URL` do app): a função devolve a URL assinada RELATIVA.
  final Uri projectUrl;

  Future<Map<String, Object?>> _call(
    String fn,
    Map<String, Object?> body,
  ) async {
    try {
      final r = await _client.functions.invoke(fn, body: body);
      final d = r.data is String ? jsonDecode(r.data as String) : r.data;
      return (d as Map).cast<String, Object?>();
    } on FunctionsFetchException {
      throw const EbookTransient('rede');
    } on FunctionException catch (e) {
      final code = switch (e.details) {
        {'erro': final String c} => c,
        _ => 'http_${e.status}',
      };
      throw switch ((e.status, code)) {
        (_, 'pro_required') => const EbookProRequired(),
        (_, 'quota_exceeded') => const EbookQuotaExceeded(),
        (404, _) || (409, _) => EbookNotFound(code),
        (final s, _) when s >= 500 || s == 429 => EbookTransient(code),
        _ => EbookUnexpected(code),
      };
    }
  }

  @override
  Future<UploadTicket> uploadTicket({
    required String userBookId,
    required String sha256,
    required int bytes,
  }) async {
    final j = await _call('ebook-upload-url', {
      'user_book_id': userBookId,
      'sha256': sha256,
      'bytes': bytes,
    });
    return UploadTicket(
      path: j['path']! as String,
      token: j['token']! as String,
    );
  }

  @override
  Future<DownloadTicket> downloadTicket(String userBookId) async {
    final j = await _call('ebook-download-url', {'user_book_id': userBookId});
    return DownloadTicket(
      path: j['path']! as String,
      url: projectUrl.resolve(j['signed_path']! as String),
    );
  }
}

// ------------------------------------------------------------------------- envio retomável (TUS)

/// Envio retomável para o Storage com o token da URL assinada (protocolo TUS 1.0.0). Pedaços de 6 MiB
/// (exigência do Storage); um corte no meio deixa o envio onde parou — a próxima tentativa pergunta ao
/// servidor (`HEAD`) e continua dali.
final class ResumableUploader {
  ResumableUploader({
    required this.endpoint,
    required this.apiKey,
    http.Client? client,
    this.chunkSize = defaultChunk,
  }) : _http = client ?? http.Client();

  static const int defaultChunk = 6 * 1024 * 1024;

  /// `<SUPABASE_URL>/storage/v1/upload/resumable/sign`.
  final Uri endpoint;
  final String apiKey;
  final int chunkSize;
  final http.Client _http;

  Map<String, String> _headers(String token) => {
    'Tus-Resumable': '1.0.0',
    'apikey': apiKey,
    'x-signature': token,
  };

  /// Sobe [file] para [path]. [resumeFrom] = endereço de um envio começado antes ([onCreated] avisa
  /// o endereço novo, para guardar). Lança [EbookTransient] num corte (nada se perde).
  Future<void> upload({
    required File file,
    required String bucket,
    required String path,
    required String token,
    required String contentType,
    Uri? resumeFrom,
    void Function(Uri location)? onCreated,
    void Function(int sent, int total)? onProgress,
  }) async {
    final total = await file.length();
    var location = resumeFrom;
    var offset = location == null ? null : await _offsetOf(location, token);
    if (location == null || offset == null) {
      location = await _create(bucket, path, token, contentType, total);
      onCreated?.call(location);
      offset = 0;
    }
    final raf = await file.open();
    try {
      while (offset! < total) {
        final n = total - offset < chunkSize ? total - offset : chunkSize;
        await raf.setPosition(offset);
        final bytes = await raf.read(n);
        final r = await _send(
          http.Request('PATCH', location)
            ..headers.addAll({
              ..._headers(token),
              'Upload-Offset': '$offset',
              'Content-Type': 'application/offset+octet-stream',
            })
            ..bodyBytes = bytes,
        );
        if (r.statusCode != 204) throw _failure(r);
        offset = int.parse(r.headers['upload-offset'] ?? '${offset + n}');
        onProgress?.call(offset, total);
      }
    } finally {
      await raf.close();
    }
  }

  Future<int?> _offsetOf(Uri location, String token) async {
    final r = await _send(
      http.Request('HEAD', location)..headers.addAll(_headers(token)),
    );
    if (r.statusCode == 200 || r.statusCode == 204) {
      return int.tryParse(r.headers['upload-offset'] ?? '');
    }
    if (r.statusCode >= 500) throw _failure(r);
    return null; // envio expirado ou desconhecido: começa de novo
  }

  Future<Uri> _create(
    String bucket,
    String path,
    String token,
    String contentType,
    int total,
  ) async {
    String b64(String s) => base64.encode(utf8.encode(s));
    final r = await _send(
      http.Request('POST', endpoint)
        ..headers.addAll({
          ..._headers(token),
          'Upload-Length': '$total',
          'x-upsert': 'true',
          'Upload-Metadata':
              'bucketName ${b64(bucket)},objectName ${b64(path)},'
              'contentType ${b64(contentType)}',
        }),
    );
    final loc = r.headers['location'];
    if (r.statusCode != 201 || loc == null) throw _failure(r);
    return endpoint.resolve(loc);
  }

  /// Um pedido pendurado vira falha passageira (o envio retoma depois).
  static const Duration requestTimeout = Duration(seconds: 60);

  Future<http.Response> _send(http.BaseRequest req) async {
    try {
      return await http.Response.fromStream(
        await _http.send(req).timeout(requestTimeout),
      ).timeout(requestTimeout);
    } on SocketException {
      throw const EbookTransient('rede');
    } on http.ClientException {
      throw const EbookTransient('rede');
    } on TimeoutException {
      throw const EbookTransient('rede');
    }
  }

  static EbookCloudFailure _failure(http.Response r) => switch (r.statusCode) {
    401 || 403 => const EbookTicketExpired(),
    final s when s >= 500 || s == 429 => EbookTransient('tus_$s'),
    final s => EbookUnexpected('tus_$s'),
  };
}

// ------------------------------------------------------------------------- no aparelho

/// Onde guardar o arquivo baixado de um livro (a pasta dos livros é da importação — G09).
typedef BookFilePath = Future<String> Function(
  String userBookId,
  String format,
);

final class EbookCloud {
  EbookCloud({
    required this._db,
    required this._api,
    required this._uploader,
    required this._versioning,
    required this._bookFilePath,
    http.Client? download,
    DateTime Function()? now,
  }) : _http = download ?? http.Client(),
       _now = now ?? DateTime.now;

  final AppDatabase _db;
  final EbookCloudApi _api;
  final ResumableUploader _uploader;
  final LocalVersioning _versioning;
  final BookFilePath _bookFilePath;
  final http.Client _http;
  final DateTime Function() _now;

  /// O token da URL assinada vale 2 h; depois disso pede outro.
  static const Duration ticketLife = Duration(minutes: 110);

  /// Prefixo das chaves do `kv` com o envio pela metade de cada livro.
  static const String resumePrefix = 'ebook.envio.';

  static String resumeKey(String userBookId) => '$resumePrefix$userBookId';

  /// Abertura do app: um envio que estava "subindo" quando o app fechou fica como falho (tenta de novo).
  Future<void> recover() => _db.customStatement(
    "UPDATE local_files SET upload_state = 'failed' WHERE upload_state = 'uploading'",
  );

  Future<void> _state(String userBookId, String s) =>
      (_db.update(
        _db.localFiles,
      )..where((t) => t.userBookId.equals(userBookId))).write(
        LocalFilesCompanion(
          uploadState: Value(s),
          updatedAt: Value(_now().toUtc()),
        ),
      );

  /// Sobe o arquivo do livro (precisa do Pro e do livro já sincronizado). Retoma um envio cortado.
  /// No fim, o caminho na nuvem vai para o livro (`storage_object_path`) com versão nova — chega aos
  /// outros aparelhos pela sincronização.
  Future<String> upload(String userBookId) async {
    final f = await (_db.select(
      _db.localFiles,
    )..where((t) => t.userBookId.equals(userBookId))).getSingleOrNull();
    final book = await UserBooksDao(_db).byId(userBookId);
    if (f == null || book == null || book.meta.isDeleted) {
      throw const EbookNotFound('sem_arquivo_local');
    }
    final kv = KvDao(_db);
    await _state(userBookId, 'uploading');
    try {
      final saved = switch (await kv.get(resumeKey(userBookId))) {
        final String s => jsonDecode(s) as Map,
        null => null,
      };
      // o envio guardado só vale para o MESMO arquivo e com o token ainda em dia
      final fresh =
          saved != null &&
          saved['sha'] == f.sha256 &&
          saved['bytes'] == f.bytes &&
          _now().millisecondsSinceEpoch - (saved['at']! as int) <
              ticketLife.inMilliseconds;
      final ticket = fresh
          ? UploadTicket(
              path: saved['path']! as String,
              token: saved['token']! as String,
            )
          : await _api.uploadTicket(
              userBookId: userBookId,
              sha256: f.sha256,
              bytes: f.bytes,
            );
      final at = fresh ? saved['at']! as int : _now().millisecondsSinceEpoch;
      Future<void> remember(Uri? location) => kv.set(
        resumeKey(userBookId),
        jsonEncode({
          'path': ticket.path,
          'token': ticket.token,
          'at': at,
          'sha': f.sha256,
          'bytes': f.bytes,
          'location': location?.toString(),
        }),
      );
      if (!fresh) await remember(null);
      final location = saved?['location'];
      await _uploader.upload(
        file: File(f.path),
        bucket: 'ebooks',
        path: ticket.path,
        token: ticket.token,
        contentType: book.format.name == 'pdf'
            ? 'application/pdf'
            : 'application/epub+zip',
        resumeFrom: fresh && location is String ? Uri.parse(location) : null,
        onCreated: remember,
      );
      await _versioning.write('user_books', userBookId, (v) async {
        final atual = (await UserBooksDao(_db).byId(userBookId))!;
        // apagado enquanto subia: o caminho não vai para o livro (o servidor recolhe o arquivo sem
        // livro ativo — reconciliação da fila de exclusão)
        if (atual.meta.isDeleted) return;
        await UserBooksDao(_db).upsert(
          atual.copyWith(
            storageObjectPath: Nullable(ticket.path),
            meta: atual.meta.edited(
              DateTime.fromMillisecondsSinceEpoch(v.ms, isUtc: true),
              v,
            ),
          ),
        );
      });
      await _db.customStatement('DELETE FROM kv WHERE key = ?', [
        resumeKey(userBookId),
      ]);
      await _state(userBookId, 'uploaded');
      return ticket.path;
    } on EbookTicketExpired {
      await _db.customStatement('DELETE FROM kv WHERE key = ?', [
        resumeKey(userBookId),
      ]);
      await _state(userBookId, 'failed');
      rethrow;
    } on EbookCloudFailure {
      await _state(userBookId, 'failed');
      rethrow;
    }
  }

  /// Baixa o arquivo do livro que está na nuvem (2º aparelho, sob demanda). Só fica no aparelho se o
  /// sha256 for o do livro. Devolve o caminho local.
  Future<String> download(String userBookId) async {
    final book = await UserBooksDao(_db).byId(userBookId);
    final sha = book?.contentSha256;
    if (book == null || sha == null || book.storageObjectPath == null) {
      throw const EbookNotFound('sem_arquivo_na_nuvem');
    }
    final ticket = await _api.downloadTicket(userBookId);
    final destino = await _bookFilePath(userBookId, book.format.name);
    final parte = File('$destino.parte');
    final http.StreamedResponse r;
    try {
      r = await _http.send(http.Request('GET', ticket.url));
    } on SocketException {
      throw const EbookTransient('rede');
    } on http.ClientException {
      throw const EbookTransient('rede');
    }
    if (r.statusCode != 200) {
      await r.stream.drain<void>();
      throw r.statusCode >= 500
          ? EbookTransient('download_${r.statusCode}')
          : EbookUnexpected('download_${r.statusCode}');
    }
    final sink = parte.openWrite();
    final hash = _DigestSink();
    final calc = sha256.startChunkedConversion(hash);
    var bytes = 0;
    try {
      await for (final chunk in r.stream.timeout(
        ResumableUploader.requestTimeout,
      )) {
        calc.add(chunk);
        sink.add(chunk);
        bytes += chunk.length;
      }
    } on Object {
      await sink.close();
      if (await parte.exists()) await parte.delete();
      throw const EbookTransient('rede');
    }
    await sink.close();
    calc.close();
    if (hash.digest.toString() != sha) {
      await parte.delete();
      throw const EbookCorrupted();
    }
    await parte.rename(destino);
    await _db
        .into(_db.localFiles)
        .insertOnConflictUpdate(
          LocalFilesCompanion.insert(
            userBookId: userBookId,
            path: destino,
            bytes: bytes,
            sha256: sha,
            uploadState: const Value('uploaded'),
            updatedAt: _now().toUtc(),
          ),
        );
    return destino;
  }
}

/// Recebe o sha256 calculado em fluxo.
final class _DigestSink implements Sink<Digest> {
  late Digest digest;

  @override
  void add(Digest d) => digest = d;

  @override
  void close() {}
}

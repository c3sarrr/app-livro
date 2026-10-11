// Dublês do catálogo (G07): o Worker de mentira serve a fixture gerada pelo pipeline
// (`test/fixtures/catalogo`, Python) com Range, ETag e cortes de conexão.
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:app_leitura/features/catalog/data/edge_catalog_api.dart';
import 'package:app_leitura/features/catalog/data/external_isbn_api.dart';
import 'package:app_leitura/features/catalog/application/isbn_resolver.dart';
import 'package:app_leitura/features/catalog/domain/catalog_book.dart';
import 'package:app_leitura/features/catalog/domain/community.dart';
import 'package:http/http.dart' as http;

const String v1 = '2026-09-30.1';
const String v2 = '2026-10-31.1';
final Directory fixtureDir = Directory('test/fixtures/catalogo');

Uint8List fixtureBytes(String path) =>
    File('${fixtureDir.path}/$path').readAsBytesSync();

/// Descomprime o catalog.db da fixture numa pasta (para abrir direto).
Future<String> catalogDbFile(Directory dir, String version) async {
  final out = File('${dir.path}${Platform.pathSeparator}catalog_$version.db');
  await out.writeAsBytes(
    gzip.decode(fixtureBytes('catalog/v1/$version/catalog.db.gz')),
  );
  return out.path;
}

Map<String, Object?> fixtureManifest(String version) =>
    jsonDecode(utf8.decode(fixtureBytes('catalog/v1/$version/manifest.json')))
        as Map<String, Object?>;

final class FakeCatalogServer extends http.BaseClient {
  /// Versão anunciada em `/v1/catalog/manifest.json`.
  String current = v1;

  /// Troca o manifesto servido (ex.: um sha256 errado publicado por engano).
  Map<String, Object?> Function(Map<String, Object?>)? editManifest;

  /// Arquivos trocados (caminho publicado → bytes) — para corromper um delta, por exemplo.
  final Map<String, Uint8List> overrides = {};

  /// Corta a conexão depois de mandar este número de bytes (uma vez).
  int? cutAfterBytes;

  /// Próximas respostas com este status (uma por pedido).
  final List<int> statuses = [];

  final List<http.BaseRequest> requests = [];

  int get downloads => requests
      .where((r) => r.url.path.endsWith('.gz') && r.method == 'GET')
      .length;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest req) async {
    requests.add(req);
    final path = req.url.path;
    http.StreamedResponse json(int status, Object body) =>
        http.StreamedResponse(
          Stream.value(utf8.encode(jsonEncode(body))),
          status,
          request: req,
          headers: {'content-type': 'application/json'},
        );
    if (statuses.isNotEmpty) return json(statuses.removeAt(0), {'erro': 'x'});
    if (path == '/v1/catalog/manifest.json') {
      final m = fixtureManifest(current);
      return json(200, editManifest?.call(m) ?? m);
    }
    const prefix = '/v1/catalog/';
    if (!path.startsWith(prefix)) return json(404, {'erro': 'nao_encontrado'});
    final published = 'catalog/v1/${path.substring(prefix.length)}';
    final Uint8List bytes;
    try {
      bytes = overrides[published] ?? fixtureBytes(published);
    } on FileSystemException {
      return json(404, {'erro': 'nao_encontrado'});
    }
    final etag = '"${bytes.length}-${published.hashCode}"';
    var start = 0;
    var status = 200;
    final range = req.headers['Range'];
    final ifRange = req.headers['If-Range'];
    if (range != null && (ifRange == null || ifRange == etag)) {
      start = int.parse(RegExp(r'bytes=(\d+)-').firstMatch(range)![1]!);
      if (start >= bytes.length) {
        return http.StreamedResponse(const Stream.empty(), 416, request: req);
      }
      status = 206;
    }
    var body = bytes.sublist(start);
    final cut = cutAfterBytes;
    Stream<List<int>> stream = Stream.value(body);
    if (cut != null && cut < body.length) {
      cutAfterBytes = null;
      body = body.sublist(0, cut);
      final c = StreamController<List<int>>();
      c.add(body);
      unawaited(
        Future<void>.delayed(Duration.zero).then((_) async {
          c.addError(http.ClientException('conexão caiu', req.url));
          await c.close();
        }),
      );
      stream = c.stream;
    }
    return http.StreamedResponse(
      stream,
      status,
      request: req,
      headers: {'etag': etag, 'content-length': '${bytes.length - start}'},
    );
  }
}

/// Borda de mentira: livros por ISBN e falhas programadas.
final class FakeEdge implements EdgeCatalogApi {
  final Map<String, CatalogBook> books = {};
  Object? failure;
  final List<String> calls = [];

  @override
  Future<CatalogBook?> byIsbn(String isbn13) async {
    calls.add(isbn13);
    final f = failure;
    if (f != null) throw f;
    return books[isbn13];
  }
}

final class FakeCommunity implements CommunityCatalogLookup {
  final Map<String, CatalogBook> books = {};
  final Map<String, List<CommunitySuggestion>> pending = {};
  final List<String> calls = [];

  @override
  Future<CommunityLookup> lookup(String isbn13) async {
    calls.add(isbn13);
    return CommunityLookup(
      book: books[isbn13],
      pending: pending[isbn13] ?? const [],
    );
  }
}

final class FakeExternal implements ExternalIsbnApi {
  final Map<String, CatalogBook> books = {};
  Object? failure;
  final List<String> calls = [];

  @override
  Future<CatalogBook?> byIsbn(String isbn13) async {
    calls.add(isbn13);
    final f = failure;
    if (f != null) throw f;
    return books[isbn13];
  }
}

CatalogBook livroCatalogo(
  String isbn, {
  String title = 'Livro',
  String source = 'openlibrary',
}) => CatalogBook(
  isbn13: isbn,
  title: title,
  authors: const ['Autora'],
  source: source,
  license: source == 'openlibrary' ? 'OL-sem-direitos' : null,
);

// Camada da borda (Anexo 02 §7.3): o Worker do catálogo responde pelo ISBN a partir dos dumps abertos.
// O pedido leva só o ISBN (permitido também ao Grátis — §4.3.7).
import 'dart:async';
import 'dart:convert';
import 'dart:io' show IOException;

import 'package:http/http.dart' as http;

import '../domain/catalog_book.dart';
import '../domain/catalog_failure.dart';

abstract interface class EdgeCatalogApi {
  /// O livro, ou null se o catálogo aberto não tem esse ISBN.
  Future<CatalogBook?> byIsbn(String isbn13);
}

final class HttpEdgeCatalogApi implements EdgeCatalogApi {
  HttpEdgeCatalogApi(this._client, this.base);

  final http.Client _client;

  /// Endereço do Worker (`CATALOG_URL`), terminado em `/`.
  final Uri base;

  static const Duration timeout = Duration(seconds: 6);

  @override
  Future<CatalogBook?> byIsbn(String isbn13) async {
    final http.Response r;
    try {
      r = await _client.get(base.resolve('v1/isbn/$isbn13')).timeout(timeout);
    } on TimeoutException {
      throw const CatalogOffline();
    } on IOException {
      // SocketException, HandshakeException (portal de login do Wi-Fi) — achado 4 da revisão
      throw const CatalogOffline();
    } on http.ClientException {
      throw const CatalogOffline();
    }
    switch (r.statusCode) {
      case 200:
        try {
          final j =
              jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, Object?>;
          return CatalogBook.fromJson(j['livro']! as Map<String, Object?>);
        } on Object {
          // 200 que não é a resposta do Worker (portal de Wi-Fi devolvendo HTML, por exemplo)
          throw const CatalogUnexpected('resposta');
        }
      case 404:
        return null;
      case 429:
        throw const CatalogQuotaExceeded();
      case final s when s >= 500:
        throw CatalogOffline('http_$s');
      case final s:
        throw CatalogUnexpected('http_$s');
    }
  }
}

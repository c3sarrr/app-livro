// Último recurso (Anexo 02 §7.5, D-73): a Edge Function `isbn-lookup` consulta as APIs externas pela
// região do ISBN (Brasil → CBL pela BrasilAPI; resto → Open Library/Google Books pela BrasilAPI;
// Hardcover/ISBNdb quando houver chave), com cota diária por conta. O resultado fica só com a pessoa.
import 'dart:async';
import 'dart:convert';
import 'dart:io' show IOException;

import 'package:supabase_flutter/supabase_flutter.dart'
    show FunctionException, FunctionsFetchException, SupabaseClient;

import '../domain/catalog_book.dart';
import '../domain/catalog_failure.dart';

abstract interface class ExternalIsbnApi {
  Future<CatalogBook?> byIsbn(String isbn13);
}

final class SupabaseExternalIsbnApi implements ExternalIsbnApi {
  SupabaseExternalIsbnApi(this._client);

  final SupabaseClient _client;

  /// A Edge Function consulta até 4 fontes (4 s cada): passou disso, a pessoa tenta de novo.
  static const Duration timeout = Duration(seconds: 20);

  @override
  Future<CatalogBook?> byIsbn(String isbn13) async {
    if (_client.auth.currentSession == null) {
      throw const CatalogNeedsAccount();
    }
    final Object? data;
    try {
      final r = await _client.functions
          .invoke('isbn-lookup', body: {'isbn': isbn13})
          .timeout(timeout);
      data = r.data;
    } on FunctionsFetchException {
      throw const CatalogOffline();
    } on FunctionException catch (e) {
      return switch (e.status) {
        404 => null,
        429 => throw const CatalogQuotaExceeded(),
        401 => throw const CatalogNeedsAccount(),
        final s when s >= 500 => throw CatalogOffline('http_$s'),
        final s => throw CatalogUnexpected('http_$s'),
      };
    } on TimeoutException {
      throw const CatalogOffline('tempo');
    } on IOException {
      throw const CatalogOffline();
    }
    try {
      final d = data is String ? jsonDecode(data) : data;
      final j = (d! as Map).cast<String, Object?>();
      final livro = (j['livro']! as Map).cast<String, Object?>();
      return CatalogBook.fromJson({
        ...livro,
        'year': livro['year'] ?? livro['published_year'],
      });
    } on Object {
      throw const CatalogUnexpected('resposta'); // achado 4 da revisão
    }
  }
}

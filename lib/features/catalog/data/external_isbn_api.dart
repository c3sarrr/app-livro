// Último recurso (Anexo 02 §7.5, D-73): a Edge Function `isbn-lookup` consulta as APIs externas pela
// região do ISBN (Brasil → CBL pela BrasilAPI; resto → Open Library/Google Books pela BrasilAPI;
// Hardcover/ISBNdb quando houver chave), com cota diária por conta. O resultado fica só com a pessoa.
import 'dart:convert';

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

  @override
  Future<CatalogBook?> byIsbn(String isbn13) async {
    if (_client.auth.currentSession == null) {
      throw const CatalogNeedsAccount();
    }
    try {
      final r = await _client.functions.invoke(
        'isbn-lookup',
        body: {'isbn': isbn13},
      );
      final d = r.data is String ? jsonDecode(r.data as String) : r.data;
      final j = (d as Map).cast<String, Object?>();
      final livro = (j['livro']! as Map).cast<String, Object?>();
      return CatalogBook.fromJson({
        ...livro,
        'year': livro['year'] ?? livro['published_year'],
      });
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
    }
  }
}

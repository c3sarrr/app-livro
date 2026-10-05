// Camada da comunidade (Anexo 02 §7.4, D-74) pelas RPCs do Supabase. A consulta leva só o ISBN; o
// envio leva ISBN + título + autor + editora e só acontece com um toque explícito da pessoa
// (lista branca do Grátis, §4.3.7). Quem enviou nunca volta do servidor.
import 'dart:async';
import 'dart:io' show SocketException;

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart'
    show PostgrestException, SupabaseClient;

import '../application/isbn_resolver.dart' show CommunityCatalogLookup;
import '../domain/catalog_book.dart';
import '../domain/catalog_failure.dart';
import '../domain/community.dart';

abstract interface class CommunityCatalogApi implements CommunityCatalogLookup {
  /// "Adicionar este livro" (toque explícito).
  Future<CommunityContribution> submit({
    required String isbn13,
    required String title,
    required String authors,
    String? publisher,
  });

  /// "Confirmar" a sugestão de outra pessoa (toque explícito).
  Future<CommunityContribution> confirm(String submissionId);
}

final class SupabaseCommunityCatalogApi implements CommunityCatalogApi {
  SupabaseCommunityCatalogApi(this._client);

  final SupabaseClient _client;

  static const Duration timeout = Duration(seconds: 8);

  @override
  Future<CommunityLookup> lookup(String isbn13) => _guard(() async {
    final r = await _client.rpc<Object?>(
      'catalog_by_isbn',
      params: {'p_isbn13': isbn13},
    );
    final j = (r! as Map).cast<String, Object?>();
    final e = j['edition'];
    return CommunityLookup(
      book: e is Map ? CatalogBook.fromJson(e.cast<String, Object?>()) : null,
      pending: [
        for (final p in (j['pending'] as List<Object?>?) ?? const [])
          CommunitySuggestion.fromJson((p! as Map).cast<String, Object?>()),
      ],
    );
  });

  @override
  Future<CommunityContribution> submit({
    required String isbn13,
    required String title,
    required String authors,
    String? publisher,
  }) => _guard(
    () => _contribution(
      _client.rpc<Object?>(
        'catalog_submit',
        params: {
          'p_isbn13': isbn13,
          'p_title': title,
          'p_authors': authors,
          'p_publisher': publisher,
        },
      ),
    ),
  );

  @override
  Future<CommunityContribution> confirm(String submissionId) => _guard(
    () => _contribution(
      _client.rpc<Object?>(
        'catalog_confirm',
        params: {'p_submission': submissionId},
      ),
    ),
  );

  static Future<CommunityContribution> _contribution(
    Future<Object?> call,
  ) async {
    final j = ((await call)! as Map).cast<String, Object?>();
    final e = j['edition'];
    final book = e is Map
        ? CatalogBook.fromJson(e.cast<String, Object?>())
        : null;
    return switch (j['status']) {
      'pending' => ContributionPending(j['submission_id']! as String),
      'confirmed' => ContributionConfirmed(j['submission_id']! as String),
      'approved' when book != null => ContributionApproved(book),
      'exists' => ContributionAlreadyInCatalog(book),
      final s => throw CatalogUnexpected('status_$s'),
    };
  }

  Future<T> _guard<T>(Future<T> Function() run) async {
    if (_client.auth.currentSession == null) {
      throw const CatalogNeedsAccount();
    }
    try {
      return await run().timeout(timeout);
    } on PostgrestException catch (e) {
      throw switch ((e.code, e.message)) {
        (_, 'age_required') => const CatalogNeedsAge(),
        (_, 'quota_exceeded') => const CatalogQuotaExceeded(),
        ('28000', _) ||
        ('PGRST301', _) ||
        ('PGRST303', _) => const CatalogNeedsAccount(),
        (_, final m)
            when const {
              'own_submission',
              'not_found',
              'invalid_isbn',
              'invalid_fields',
            }.contains(m) =>
          CatalogUnexpected(m),
        (final c, _) => CatalogUnexpected('pg_${c ?? 'desconhecido'}'),
      };
    } on TimeoutException {
      throw const CatalogOffline();
    } on SocketException {
      throw const CatalogOffline();
    } on http.ClientException {
      throw const CatalogOffline();
    }
  }
}

// O servidor da sincronização do Pro (ADR-003): o JWT da sessão, o estado do Pro (com a hora do
// servidor, para medir o relógio do aparelho) e a RPC `sync_apply_changes`. Os erros da CHAMADA são
// classificados aqui; as recusas por linha voltam no resultado.
import 'dart:async' show TimeoutException;
import 'dart:io' show SocketException;

import 'package:flutter/foundation.dart' show immutable;
import 'package:http/http.dart' show ClientException;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Estado do Pro segundo o servidor (`public.my_entitlement()`).
@immutable
final class Entitlement {
  const Entitlement({
    required this.pro,
    required this.activeUntil,
    required this.serverTimeMs,
  });

  factory Entitlement.fromJson(Map<String, Object?> j) => Entitlement(
    pro: j['pro'] == true,
    activeUntil: switch (j['active_until']) {
      final String s => DateTime.parse(s).toUtc(),
      _ => null,
    },
    serverTimeMs: (j['server_time_ms'] as num?)?.toInt(),
  );

  final bool pro;

  /// Fim previsto do Pro (a carência da loja já está dentro).
  final DateTime? activeUntil;

  /// Hora do servidor na resposta (ms desde a época).
  final int? serverTimeMs;
}

/// Uma recusa por linha da RPC (`rejected[]`): erro permanente daquela linha.
@immutable
final class SyncRejection {
  const SyncRejection({
    required this.table,
    required this.id,
    required this.error,
    required this.code,
  });

  factory SyncRejection.fromJson(Map<String, Object?> j) => SyncRejection(
    table: j['table'] as String? ?? '',
    id: j['id'] as String? ?? '',
    error: j['error'] as String? ?? '',
    code: j['code'] as String?,
  );

  final String table;
  final String id;

  /// Mensagem do Postgres (fica só no aparelho — pode citar valores da linha).
  final String error;

  /// SQLSTATE (`22023`, `23503`, `23505`…).
  final String? code;

  /// HLC mais de 5 min à frente do relógio do servidor.
  bool get invalidHlc => error == 'invalid_hlc';
}

@immutable
final class ApplyResult {
  const ApplyResult({
    required this.applied,
    required this.skipped,
    required this.rejected,
  });

  factory ApplyResult.fromJson(Map<String, Object?> j) => ApplyResult(
    applied: (j['applied'] as num?)?.toInt() ?? 0,
    skipped: (j['skipped'] as num?)?.toInt() ?? 0,
    rejected: [
      for (final r in (j['rejected'] as List? ?? const []).cast<Map>())
        SyncRejection.fromJson(r.cast<String, Object?>()),
    ],
  );

  final int applied;
  final int skipped;
  final List<SyncRejection> rejected;
}

/// Falha da chamada inteira (nada do lote foi aplicado — tudo continua na fila).
@immutable
sealed class SyncCallFailure implements Exception {
  const SyncCallFailure(this.kind);

  /// Rótulo curto, sem conteúdo (telemetria).
  final String kind;

  @override
  String toString() => 'SyncCallFailure($kind)';
}

/// O servidor diz que a conta não é Pro (`pro_required`).
final class ProRequired extends SyncCallFailure {
  const ProRequired() : super('pro_required');
}

/// Sem sessão válida (token vencido ou revogado).
final class SyncUnauthorized extends SyncCallFailure {
  const SyncUnauthorized() : super('unauthorized');
}

/// Rede, 5xx, conflito/trava transitória: repetir com recuo.
final class SyncTransient extends SyncCallFailure {
  const SyncTransient(super.kind);
}

/// Resposta inesperada (defeito do app ou do servidor).
final class SyncUnexpected extends SyncCallFailure {
  const SyncUnexpected(super.kind);
}

/// Classifica um erro da chamada.
SyncCallFailure syncFailureOf(Object e) => switch (e) {
  final SyncCallFailure f => f,
  PostgrestException(:final message) when message == 'pro_required' =>
    const ProRequired(),
  PostgrestException(:final code) when _sessionCode(code) =>
    const SyncUnauthorized(),
  PostgrestException(:final code) when _transientCode(code) => SyncTransient(
    'pg_$code',
  ),
  PostgrestException(:final code) => SyncUnexpected('pg_${code ?? '?'}'),
  AuthRetryableFetchException() => const SyncTransient('auth_rede'),
  AuthException() => const SyncUnauthorized(),
  SocketException() ||
  TimeoutException() ||
  ClientException() => const SyncTransient('rede'),
  _ => SyncUnexpected(e.runtimeType.toString()),
};

bool _sessionCode(String? c) =>
    c == '28000' || c == 'PGRST301' || c == 'PGRST302' || c == 'PGRST303';

/// Os mesmos SQLSTATE que a RPC relança (40xxx, 53xxx, 55P03, 57xxx), conexão (08xxx) e respostas
/// HTTP sem código do Postgres (429, 5xx do gateway).
bool _transientCode(String? c) {
  if (c == null) return false;
  if (c == '55P03' || c == '429') return true;
  if (RegExp(r'^5\d\d$').hasMatch(c)) return true;
  return c.length == 5 &&
      const ['40', '53', '57', '08'].contains(c.substring(0, 2));
}

abstract interface class SyncBackend {
  /// Id da conta da sessão atual (null = sem sessão).
  String? get userId;

  /// JWT da sessão (renovado se estiver vencendo). Null = sem sessão.
  Future<({String token, DateTime? expiresAt})?> accessToken();

  Future<Entitlement> entitlement();

  /// Aplica um lote (≤ 500 operações). Lança [SyncCallFailure].
  Future<ApplyResult> applyChanges(List<Map<String, Object?>> changes);
}

/// [SyncBackend] sobre o cliente do Supabase.
final class SupabaseSyncBackend implements SyncBackend {
  SupabaseSyncBackend(this._client);

  final SupabaseClient _client;

  /// Renova o token quando faltar menos que isto.
  static const Duration refreshMargin = Duration(minutes: 1);

  @override
  String? get userId => _client.auth.currentUser?.id;

  @override
  Future<({String token, DateTime? expiresAt})?> accessToken() async {
    var s = _client.auth.currentSession;
    if (s == null) return null;
    final exp = s.expiresAt == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(s.expiresAt! * 1000, isUtc: true);
    if (exp != null && exp.difference(DateTime.now().toUtc()) < refreshMargin) {
      try {
        s = (await _client.auth.refreshSession()).session ?? s;
      } catch (e) {
        throw syncFailureOf(e);
      }
    }
    return (
      token: s.accessToken,
      expiresAt: s.expiresAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(
              s.expiresAt! * 1000,
              isUtc: true,
            ),
    );
  }

  @override
  Future<Entitlement> entitlement() async {
    try {
      final r = await _client.rpc<Object?>('my_entitlement');
      return Entitlement.fromJson((r! as Map).cast<String, Object?>());
    } catch (e) {
      throw syncFailureOf(e);
    }
  }

  @override
  Future<ApplyResult> applyChanges(List<Map<String, Object?>> changes) async {
    try {
      final r = await _client.rpc<Object?>(
        'sync_apply_changes',
        params: {'p_changes': changes},
      );
      return ApplyResult.fromJson((r! as Map).cast<String, Object?>());
    } catch (e) {
      throw syncFailureOf(e);
    }
  }
}

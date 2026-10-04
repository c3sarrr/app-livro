// Operações da conta no servidor (com o JWT de quem está logado): resumo, faixa etária, @, exportação
// e exclusão. Tudo aqui é permitido para o Grátis (§4.3.7: login/sessão e perfil) — nenhum dado pessoal
// do aparelho passa por esta classe (teste de privacidade da G05).
import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/account_failure.dart';
import '../domain/account_summary.dart';
import '../domain/age.dart';
import 'auth_gateway.dart' show accountFailureOf;

abstract interface class AccountApi {
  Future<AccountSummary> summary();
  Future<void> recordAge(AgeCheck check);

  /// Troca o @ (já normalizado por `normalizeHandle`).
  Future<void> setHandle(String handle);

  /// Tudo o que o servidor guarda sobre a conta (LGPD — Edge Function `export-data`).
  Future<Map<String, Object?>> exportServerData();

  /// Exclusão imediata (Edge Function `delete-account`: RevenueCat → Storage → Auth).
  Future<void> deleteAccount();
}

/// [AccountApi] sobre o cliente do Supabase.
final class SupabaseAccountApi implements AccountApi {
  SupabaseAccountApi(this._client);

  final SupabaseClient _client;

  String get _uid {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw const NotSignedIn();
    return id;
  }

  void _requireSignedIn() => _uid;

  /// [handle]: o pedido é a troca do @ (só aí a chave duplicada quer dizer "@ em uso").
  Future<T> _guard<T>(Future<T> Function() run, {bool handle = false}) async {
    try {
      return await run();
    } on PostgrestException catch (e) {
      throw _postgrestFailure(e, handle: handle);
    } on FunctionException catch (e) {
      throw _functionFailure(e);
    } catch (e) {
      throw accountFailureOf(e);
    }
  }

  /// Só os códigos que dizem respeito à SESSÃO viram [NotSignedIn] (o app sai da conta com ele);
  /// falta de permissão (42501) é defeito do servidor, não motivo para deslogar.
  static AccountFailure _postgrestFailure(
    PostgrestException e, {
    required bool handle,
  }) => switch ((e.code, e.message)) {
    ('23505', _) when handle => const HandleTaken(),
    ('23514', _) || (_, 'handle_reserved') when handle => const HandleInvalid(),
    (_, 'content_blocked') => const ContentBlocked(),
    (_, 'age_required') =>
      const AgeCheckRequired(), // social sem faixa registrada
    (_, 'underage') => const Underage(),
    (_, 'quota_exceeded') => const ExportLimitReached(),
    ('28000', _) || ('PGRST301', _) || ('PGRST303', _) => const NotSignedIn(),
    (final code, _) => ServerFailure('pg_${code ?? 'desconhecido'}'),
  };

  static AccountFailure _functionFailure(FunctionException e) => switch (e) {
    FunctionsFetchException() => const OfflineFailure(), // sem resposta (rede)
    FunctionException(status: 401) => const NotSignedIn(),
    FunctionException(status: 429) => const ExportLimitReached(),
    FunctionException(:final status) => ServerFailure('fn_$status'),
  };

  @override
  Future<AccountSummary> summary() => _guard(() async {
    _requireSignedIn();
    final r = await _client.rpc<Object?>('my_account');
    // sessão válida e nenhum perfil: a conta foi excluída (página web, outro aparelho)
    if (r is! Map) throw const AccountGone();
    return AccountSummary.fromJson(r.cast<String, Object?>());
  });

  @override
  Future<void> recordAge(AgeCheck check) => _guard(() async {
    if (!check.allowed) throw const Underage();
    await _client.rpc<Object?>(
      'set_my_age_band',
      params: {'p_band': check.band.code, 'p_source': check.source.code},
    );
  });

  @override
  Future<void> setHandle(String handle) => _guard(() async {
    await _client.from('profiles').update({'handle': handle}).eq('id', _uid);
  }, handle: true);

  @override
  Future<Map<String, Object?>> exportServerData() => _guard(() async {
    _requireSignedIn();
    final r = await _client.functions.invoke('export-data');
    final data = r.data;
    final json = data is String ? jsonDecode(data) : data;
    if (json is! Map) throw const ServerFailure('exportacao_vazia');
    return json.cast<String, Object?>();
  });

  @override
  Future<void> deleteAccount() => _guard(() async {
    _requireSignedIn();
    await _client.functions.invoke(
      'delete-account',
      body: const {'confirmar': true},
    );
  });
}

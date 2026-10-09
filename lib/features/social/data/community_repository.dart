// G21.3 — o que cerca a comunidade (docs/progresso/G21.md §3): denunciar (D-52; a fila vai para o painel da
// moderação, D-220), os termos (D-222) e a contagem do sininho (D-212: só o ponto; uma ida que não traz as linhas).
import 'package:supabase_flutter/supabase_flutter.dart' show SupabaseClient;

import '../domain/social_models.dart';
import 'social_call.dart';

abstract interface class ReportRepository {
  /// [details]: o que a pessoa escreveu (até 1000 caracteres; o servidor confere).
  Future<void> report(
    ReportTarget target,
    String id,
    ReportReason reason, {
    String? details,
  });
}

abstract interface class TermsRepository {
  Future<TermsStatus> mine();

  /// Aceita a [version] lida; se mudou no meio, [SocialTermsRequired] e a folha volta com a nova.
  Future<void> accept(String version);
}

abstract interface class NotificationsRepository {
  /// Quantas notificações não lidas (só o número: o ponto do sininho).
  Future<int> unreadCount();
  Future<void> markAllRead();
}

final class SupabaseReportRepository implements ReportRepository {
  SupabaseReportRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<void> report(
    ReportTarget target,
    String id,
    ReportReason reason, {
    String? details,
  }) => socialCall(
    _client,
    // sem `select`: quem denuncia não lê a tabela das denúncias
    () => _client.from('content_reports').insert({
      'reporter_id': socialUserId(_client),
      'target_type': target.code,
      'target_id': id,
      'reason': reason.code,
      'details': ?details,
    }),
  );
}

final class SupabaseTermsRepository implements TermsRepository {
  SupabaseTermsRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<TermsStatus> mine() => socialCall(_client, () async {
    final r = await _client.rpc<Object?>('my_terms');
    return TermsStatus.fromJson((r! as Map).cast<String, Object?>());
  });

  @override
  Future<void> accept(String version) => socialCall(
    _client,
    () => _client.rpc<Object?>('accept_terms', params: {'p_version': version}),
  );
}

final class SupabaseNotificationsRepository implements NotificationsRepository {
  SupabaseNotificationsRepository(this._client, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final SupabaseClient _client;
  final DateTime Function() _now;

  @override
  Future<int> unreadCount() => socialCall(
    _client,
    () => _client
        .from('notifications')
        .count()
        .eq('user_id', socialUserId(_client))
        .isFilter('read_at', null)
        .retry(enabled: false),
  );

  @override
  Future<void> markAllRead() => socialCall(
    _client,
    () => _client
        .from('notifications')
        .update({'read_at': _now().toUtc().toIso8601String()})
        .eq('user_id', socialUserId(_client))
        .isFilter('read_at', null),
  );
}

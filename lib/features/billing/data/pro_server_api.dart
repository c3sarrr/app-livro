// G22.2 — o Pro do lado do servidor (docs/progresso/G22.md §2): o "conferir agora" (D-229, Edge Function
// `revenuecat-sync`) e o `my_entitlement`. As duas pela sessão da conta e com as falhas do social (G21): sem rede,
// sem conta, tentar de novo.
import 'package:supabase_flutter/supabase_flutter.dart'
    show FunctionException, FunctionsFetchException, SupabaseClient;

import '../../social/data/social_call.dart';
import '../../social/domain/social_failure.dart';

/// O Pro que o servidor conhece.
typedef ServerPro = ({bool pro, DateTime? activeUntil});

abstract interface class ProServerApi {
  /// O "conferir agora" (D-229): o servidor busca o estado da conta no RevenueCat e aplica.
  Future<ServerPro> syncNow();

  /// `my_entitlement`: o que o servidor sabe agora.
  Future<ServerPro> current();
}

ServerPro _serverPro(Object? data) {
  if (data is! Map) throw const SocialUnexpected('resposta');
  final ate = data['active_until'];
  return (
    pro: data['pro'] == true,
    activeUntil: ate is String ? DateTime.tryParse(ate)?.toUtc() : null,
  );
}

final class SupabaseProServerApi implements ProServerApi {
  SupabaseProServerApi(this._client);
  final SupabaseClient _client;

  @override
  Future<ServerPro> syncNow() => socialCall(_client, () async {
    try {
      final r = await _client.functions.invoke('revenuecat-sync');
      return _serverPro(r.data);
    } on FunctionsFetchException {
      throw const SocialOffline();
    } on FunctionException catch (e) {
      throw switch (e.status) {
        401 => const SocialNeedsAccount(),
        // o limite do dia e o RevenueCat fora do ar: tentar de novo mais tarde (R2)
        429 || 502 => const SocialOffline(),
        final s => SocialUnexpected('fn_$s'),
      };
    }
  });

  @override
  Future<ServerPro> current() => socialCall(
    _client,
    () async => _serverPro(await _client.rpc<Object?>('my_entitlement')),
  );
}

// Conector do PowerSync (ADR-003; formato provado no spike S2): credenciais = JWT da sessão do
// Supabase, só para quem o servidor confirma como Pro; upload = lotes de até 500 `PUT` com a linha
// inteira para `public.sync_apply_changes`.
import 'dart:async';

import 'package:powersync/powersync.dart';

import 'sync_backend.dart';
import 'sync_store.dart';

/// Telemetria da sincronização — só tabela, código e tipo de falha, NUNCA conteúdo (o envio ao
/// Sentry entra com a Q8/G24).
abstract interface class SyncTelemetry {
  void rejected({required String table, required String? code});
  void callFailed(String kind);
}

final class NoSyncTelemetry implements SyncTelemetry {
  const NoSyncTelemetry();

  @override
  void rejected({required String table, required String? code}) {}

  @override
  void callFailed(String kind) {}
}

/// Recuo exponencial entre tentativas que falharam: 1 s, 2 s, 4 s… até 60 s.
Duration syncBackoff(int failures) {
  final s = failures <= 1 ? 1 : 1 << (failures - 1).clamp(0, 6);
  return Duration(seconds: s > 60 ? 60 : s);
}

/// Espera que pode ser interrompida (desconectar não fica preso no recuo).
final class Backoff {
  Completer<void>? _wake;

  Future<void> wait(Duration d) async {
    final c = _wake = Completer<void>();
    final t = Timer(d, () {
      if (!c.isCompleted) c.complete();
    });
    await c.future;
    t.cancel();
  }

  void wakeUp() {
    final c = _wake;
    if (c != null && !c.isCompleted) c.complete();
  }
}

/// Quem o conector avisa.
abstract interface class SyncConnectorListener {
  /// Resposta do estado do Pro, com os instantes (relógio do aparelho) da ida e da volta.
  void entitlementChecked(
    Entitlement e, {
    required int sentAtMs,
    required int receivedAtMs,
  });

  /// O servidor diz que a conta não é mais Pro: desligar a sincronização (sem apagar nada).
  void proLost();

  /// Um lote subiu (com ou sem recusas).
  void batchUploaded(ApplyResult result);
}

final class BookNestConnector extends PowerSyncBackendConnector {
  BookNestConnector({
    required this.endpoint,
    required this._backend,
    required this._store,
    required this._listener,
    required this._deviceNowMs,
    this._telemetry = const NoSyncTelemetry(),
    Backoff? backoff,
    this._backoffFor = syncBackoff,
  }) : backoff = backoff ?? Backoff();

  /// A RPC aceita até 500 operações por chamada.
  static const int maxBatch = 500;

  final String endpoint;
  final SyncBackend _backend;
  final SyncStore _store;
  final SyncConnectorListener _listener;
  final int Function() _deviceNowMs;
  final SyncTelemetry _telemetry;
  final Backoff backoff;
  final Duration Function(int) _backoffFor;
  int _failures = 0;

  /// Falhas seguidas da chamada (zera no primeiro lote que sobe).
  int get consecutiveFailures => _failures;

  @override
  Future<PowerSyncCredentials?> fetchCredentials() async {
    final t = await _backend.accessToken();
    if (t == null) return null;
    final sent = _deviceNowMs();
    final Entitlement e;
    try {
      e = await _backend.entitlement();
    } on SyncCallFailure catch (f) {
      _telemetry.callFailed('credenciais_${f.kind}');
      rethrow;
    }
    _listener.entitlementChecked(
      e,
      sentAtMs: sent,
      receivedAtMs: _deviceNowMs(),
    );
    if (!e.pro) {
      _listener.proLost();
      return null;
    }
    return PowerSyncCredentials(
      endpoint: endpoint,
      token: t.token,
      userId: _backend.userId,
      expiresAt: t.expiresAt,
    );
  }

  @override
  Future<void> uploadData(PowerSyncDatabase database) async {
    while (true) {
      final batch = await database.getCrudBatch(limit: maxBatch);
      if (batch == null) return;
      final changes = [for (final e in batch.crud) changeOf(e)];
      final ApplyResult r;
      try {
        r = await _backend.applyChanges(changes);
      } on ProRequired {
        _failures = 0;
        _telemetry.callFailed('pro_required');
        _listener.proLost();
        rethrow;
      } on SyncCallFailure catch (f) {
        // nada foi aplicado: tudo continua na fila; o PowerSync repete depois do recuo
        _telemetry.callFailed(f.kind);
        _failures++;
        await backoff.wait(_backoffFor(_failures));
        rethrow;
      }
      _failures = 0;
      if (r.rejected.isNotEmpty) {
        await _store.recordRejections(r.rejected, changes);
        for (final x in r.rejected) {
          _telemetry.rejected(table: x.table, code: x.code);
        }
      }
      await batch.complete();
      _listener.batchUploaded(r);
    }
  }

  /// Uma operação da fila no formato da RPC.
  static Map<String, Object?> changeOf(CrudEntry e) => {
    'op': switch (e.op) {
      UpdateType.put => 'PUT',
      UpdateType.patch => 'PATCH',
      UpdateType.delete => 'DELETE',
    },
    'table': e.table,
    'id': e.id,
    'hlc': e.opData?['version_hlc'],
    'data': e.opData,
  };
}

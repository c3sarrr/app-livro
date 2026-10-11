// Conector do PowerSync (ADR-003; formato provado no spike S2): credenciais = JWT da sessão do
// Supabase, só para quem o servidor confirma como Pro; upload = lotes de até 500 `PUT` com a linha
// inteira para `public.sync_apply_changes`.
import 'dart:async';
import 'dart:convert';

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

/// Espera que pode ser interrompida (desconectar não fica preso no recuo). Depois de [close], toda
/// espera — inclusive uma que ainda vai começar — volta na hora.
final class Backoff {
  Completer<void>? _wake;
  bool _closed = false;

  bool get closed => _closed;

  Future<void> wait(Duration d) async {
    if (_closed) return;
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

  void close() {
    _closed = true;
    wakeUp();
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
    required this.owner,
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

  /// Teto do corpo de um lote (camadas de tinta podem ter centenas de KB cada).
  static const int maxBatchBytes = 2 * 1024 * 1024;

  final String endpoint;

  /// A conta dona da fila: o lote só sobe com a sessão DELA.
  final String owner;
  final SyncBackend _backend;
  final SyncStore _store;
  final SyncConnectorListener _listener;
  final int Function() _deviceNowMs;
  final SyncTelemetry _telemetry;
  final Backoff backoff;
  final Duration Function(int) _backoffFor;
  int _failures = 0;
  int _limit = maxBatch;
  bool _stopped = false;

  /// Falhas seguidas da chamada (zera no primeiro lote que sobe).
  int get consecutiveFailures => _failures;

  /// Operações por lote agora (cai pela metade depois de 3 falhas seguidas; volta a 500 ao subir).
  int get batchLimit => _limit;

  /// Desligando: o laço de envio para no próximo lote e o recuo volta na hora.
  void stop() {
    _stopped = true;
    backoff.close();
  }

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
    while (!_stopped) {
      var batch = await database.getCrudBatch(limit: _limit);
      if (batch == null) return;
      var changes = [for (final e in batch.crud) changeOf(e)];
      final cabem = _fitting(changes);
      if (cabem < changes.length) {
        batch = (await database.getCrudBatch(limit: cabem))!;
        changes = changes.sublist(0, cabem);
      }
      if (_backend.userId != owner) {
        // a sessão já é de outra conta: nada desta fila sobe com o JWT dela
        _telemetry.callFailed('dono_trocado');
        throw const SyncUnauthorized();
      }
      final alheias = [
        for (final c in changes)
          if ((c['data'] as Map?)?['user_id'] case final String u
              when u != owner)
            SyncRejection(
              table: c['table']! as String,
              id: c['id']! as String,
              error: 'owner_mismatch',
              code: 'local',
            ),
      ];
      final envio = alheias.isEmpty
          ? changes
          : [
              for (final c in changes)
                if ((c['data'] as Map?)?['user_id'] == owner) c,
            ];
      final ApplyResult r;
      try {
        r = envio.isEmpty
            ? const ApplyResult(applied: 0, skipped: 0, rejected: [])
            : await _backend.applyChanges(envio);
      } on ProRequired {
        _failures = 0;
        _telemetry.callFailed('pro_required');
        _listener.proLost();
        rethrow;
      } on SyncCallFailure catch (f) {
        // nada foi aplicado: tudo continua na fila; o PowerSync repete depois do recuo
        _telemetry.callFailed(f.kind);
        _failures++;
        if (_failures >= 3 && _limit > 1) _limit = (_limit / 2).ceil();
        await backoff.wait(_backoffFor(_failures));
        rethrow;
      }
      _failures = 0;
      _limit = maxBatch;
      final recusas = [...r.rejected, ...alheias];
      if (recusas.isNotEmpty) {
        await _store.recordRejections(recusas, changes);
        for (final x in recusas) {
          _telemetry.rejected(table: x.table, code: x.code);
        }
      }
      await batch.complete();
      _listener.batchUploaded(r);
    }
  }

  /// Quantas operações do começo cabem em [maxBatchBytes] (pelo menos 1).
  static int _fitting(List<Map<String, Object?>> changes) {
    var total = 0;
    for (var i = 0; i < changes.length; i++) {
      total += utf8.encode(jsonEncode(changes[i])).length;
      if (total > maxBatchBytes) return i == 0 ? 1 : i;
    }
    return changes.length;
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

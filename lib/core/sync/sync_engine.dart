// Modo Pro ⇄ Grátis (Anexo 02 §3.1, ADR-002/003) e troca de dono no aparelho (D-68):
// - virar Pro → ligar a fila, reenfileirar tudo como `PUT` e subir (com progresso);
// - perder o Pro (servidor diz `pro_required`, consulta diz que não é Pro, ou chegou o fim previsto
//   sem confirmação) → desligar a fila e desconectar SEM apagar nada do aparelho;
// - voltar (antes ou depois do purge) → reenfileirar tudo e reconectar;
// - trocar de dono (sair, excluir, outra conta) → desconectar e limpar a fila ANTES de mexer nos dados.
import 'dart:async';

import 'package:flutter/foundation.dart' show immutable;
import 'package:powersync/powersync.dart';

import '../data/clock/server_clock.dart';
import 'booknest_connector.dart';
import 'sync_backend.dart';
import 'sync_store.dart';

/// O que a conta pede à sincronização (implementado por [SyncEngine]; [NoSync] sem servidor).
abstract interface class SyncPort {
  /// Sessão retomada da conta que já é a dona ativa: reconecta se o aparelho estava no Pro.
  Future<void> resume(String owner);

  /// O servidor confirmou a conta (e se ela é Pro).
  Future<void> onAccountConfirmed(String owner, {required bool pro});

  /// Antes de sair, excluir ou trocar de conta: desconecta e esvazia a fila (as linhas ficam).
  Future<void> beforeOwnerChange();

  /// Alterações ainda não enviadas à nuvem.
  Future<int> pendingUploads();
}

final class NoSync implements SyncPort {
  const NoSync();

  @override
  Future<void> resume(String owner) async {}

  @override
  Future<void> onAccountConfirmed(String owner, {required bool pro}) async {}

  @override
  Future<void> beforeOwnerChange() async {}

  @override
  Future<int> pendingUploads() async => 0;
}

/// A conexão com o serviço (o [PowerSyncDatabase] no app; um dublê nos testes).
abstract interface class SyncConnection {
  Future<void> connect(PowerSyncBackendConnector connector);

  /// Desconecta e limpa a fila e o estado da sincronização SEM apagar as tabelas próprias.
  Future<void> disconnectAndClear();

  /// Só desconecta (app fechando).
  Future<void> disconnect();

  Stream<LinkStatus> get statusStream;
}

/// O essencial do `SyncStatus` do PowerSync (o construtor dele é interno ao pacote).
@immutable
final class LinkStatus {
  const LinkStatus({
    this.connected = false,
    this.connecting = false,
    this.uploading = false,
    this.downloading = false,
    this.lastSyncedAt,
  });

  factory LinkStatus.of(SyncStatus s) => LinkStatus(
    connected: s.connected,
    connecting: s.connecting,
    uploading: s.uploading,
    downloading: s.downloading,
    lastSyncedAt: s.lastSyncedAt,
  );

  final bool connected;
  final bool connecting;
  final bool uploading;
  final bool downloading;

  /// Última sincronização completa (checkpoint aplicado).
  final DateTime? lastSyncedAt;
}

final class PowerSyncConnection implements SyncConnection {
  PowerSyncConnection(this._ps, {SyncOptions? options})
    : _options =
          options ??
          const SyncOptions(
            retryDelay: Duration(seconds: 5),
            crudThrottleTime: Duration(seconds: 1),
          );

  final PowerSyncDatabase _ps;
  final SyncOptions _options;

  @override
  Future<void> connect(PowerSyncBackendConnector connector) =>
      _ps.connect(connector: connector, options: _options);

  @override
  Future<void> disconnectAndClear() =>
      _ps.disconnectAndClear(clearLocal: false);

  @override
  Future<void> disconnect() => _ps.disconnect();

  @override
  Stream<LinkStatus> get statusStream => _ps.statusStream.map(LinkStatus.of);
}

enum SyncPhase { off, connecting, syncing, synced, offline }

/// Estado para o indicador discreto (D-21).
@immutable
final class SyncState {
  const SyncState({
    this.pro = false,
    this.phase = SyncPhase.off,
    this.pending = 0,
    this.uploadTotal,
    this.lastSyncedAt,
    this.deviceAheadMs = 0,
    this.proLost = false,
  });

  /// O aparelho está no modo Pro (fila ligada).
  final bool pro;
  final SyncPhase phase;

  /// Operações esperando para subir.
  final int pending;

  /// Ao virar Pro: quantas operações entraram de uma vez (para o progresso). Null fora disso.
  final int? uploadTotal;
  final DateTime? lastSyncedAt;

  /// Quanto o relógio do aparelho está adiantado (0 = certo ou atrasado).
  final int deviceAheadMs;

  /// O Pro acabou (o aparelho voltou ao Grátis sem apagar nada).
  final bool proLost;

  /// Progresso do envio inicial (0–1) ou null.
  double? get uploadProgress {
    final t = uploadTotal;
    if (t == null || t == 0) return null;
    return ((t - pending) / t).clamp(0, 1).toDouble();
  }

  SyncState copyWith({
    bool? pro,
    SyncPhase? phase,
    int? pending,
    int? Function()? uploadTotal,
    DateTime? lastSyncedAt,
    int? deviceAheadMs,
    bool? proLost,
  }) => SyncState(
    pro: pro ?? this.pro,
    phase: phase ?? this.phase,
    pending: pending ?? this.pending,
    uploadTotal: uploadTotal == null ? this.uploadTotal : uploadTotal(),
    lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    deviceAheadMs: deviceAheadMs ?? this.deviceAheadMs,
    proLost: proLost ?? this.proLost,
  );

  @override
  bool operator ==(Object other) =>
      other is SyncState &&
      other.pro == pro &&
      other.phase == phase &&
      other.pending == pending &&
      other.uploadTotal == uploadTotal &&
      other.lastSyncedAt == lastSyncedAt &&
      other.deviceAheadMs == deviceAheadMs &&
      other.proLost == proLost;

  @override
  int get hashCode => Object.hash(
    pro,
    phase,
    pending,
    uploadTotal,
    lastSyncedAt,
    deviceAheadMs,
    proLost,
  );

  @override
  String toString() =>
      'SyncState(pro: $pro, $phase, pending: $pending, total: $uploadTotal, '
      'ahead: $deviceAheadMs, proLost: $proLost)';
}

typedef TimerFactory = Timer Function(Duration d, void Function() f);

final class SyncEngine implements SyncPort, SyncConnectorListener {
  SyncEngine({
    required this._connection,
    required this._store,
    required this._backend,
    required this._endpoint,
    required this._clock,
    this._telemetry = const NoSyncTelemetry(),
    this._backoffFor = syncBackoff,
    this._timer = Timer.new,
  });

  final SyncConnection _connection;
  final SyncStore _store;
  final SyncBackend _backend;
  final String _endpoint;
  final ServerClock _clock;
  final SyncTelemetry _telemetry;
  final Duration Function(int) _backoffFor;
  final TimerFactory _timer;

  final _states = StreamController<SyncState>.broadcast();
  SyncState _state = const SyncState();
  Future<void> _queue = Future.value();
  String? _owner;
  BookNestConnector? _connector;
  StreamSubscription<LinkStatus>? _statusSub;
  Timer? _expiry;
  bool _disposed = false;

  SyncState get state => _state;
  Stream<SyncState> get states => _states.stream;

  /// Conexão ativa (para testes e diagnóstico).
  BookNestConnector? get connector => _connector;

  void _emit(SyncState s) {
    if (s == _state || _disposed) return;
    _state = s;
    _states.add(s);
  }

  /// Uma mudança de modo de cada vez (na ordem em que chegaram).
  Future<void> _serial(Future<void> Function() f) {
    final r = _queue.then((_) => _disposed ? null : f());
    _queue = r.then<void>((_) {}, onError: (Object _) {});
    return r;
  }

  /// Espera as mudanças em andamento (testes).
  Future<void> settled() => _queue;

  // ------------------------------------------------------------------ SyncPort

  @override
  Future<void> resume(String owner) => _serial(() async {
    _emit(_state.copyWith(deviceAheadMs: _clock.deviceAheadMs));
    if (await _store.isPro() && await _store.activeOwner() == owner) {
      await _connect(owner);
    }
  });

  @override
  Future<void> onAccountConfirmed(String owner, {required bool pro}) =>
      _serial(() async {
        final wasPro = await _store.isPro();
        if (pro) {
          if (!wasPro) {
            final n = await _store.turnPro(owner);
            _emit(
              _state.copyWith(
                pro: true,
                proLost: false,
                pending: await _store.pendingUploads(),
                uploadTotal: () => n == 0 ? null : n,
              ),
            );
          }
          if (_connector == null || _owner != owner) await _connect(owner);
        } else if (wasPro) {
          await _goFree(proLost: true);
        }
      });

  @override
  Future<void> beforeOwnerChange() =>
      _serial(() => _goFree(proLost: false, resetFlag: true));

  @override
  Future<int> pendingUploads() => _store.pendingUploads();

  // ------------------------------------------------------------------ conector

  @override
  void entitlementChecked(
    Entitlement e, {
    required int sentAtMs,
    required int receivedAtMs,
  }) {
    final server = e.serverTimeMs;
    if (server != null) {
      final off = measureClockOffset(
        sentAtMs: sentAtMs,
        receivedAtMs: receivedAtMs,
        serverTimeMs: server,
      );
      if (off != null) {
        _clock.offsetMs = off;
        unawaited(_store.saveClockOffset(off));
        _emit(_state.copyWith(deviceAheadMs: _clock.deviceAheadMs));
      }
    }
    final until = e.activeUntil;
    _expiry?.cancel();
    if (e.pro && until != null) {
      final now = server ?? _clock.nowMs();
      final falta = until.millisecondsSinceEpoch - now;
      _expiry = _timer(
        Duration(milliseconds: falta < 0 ? 0 : falta) +
            const Duration(seconds: 1),
        () => unawaited(_serial(_checkExpiry)),
      );
    }
    final owner = _owner;
    if (e.pro && owner != null && server != null) {
      unawaited(
        _serial(
          () =>
              _store.requeueClockRejections(owner: owner, serverNowMs: server),
        ),
      );
    }
  }

  @override
  void proLost() {
    // fora da chamada do conector: desconectar espera o laço da sincronização terminar
    unawaited(_serial(() => _goFree(proLost: true)));
  }

  @override
  void batchUploaded(ApplyResult result) {
    final owner = _owner;
    unawaited(
      _serial(() async {
        if (owner != null && result.rejected.any((r) => r.code == '23505')) {
          await _store.resolveUniqueConflicts(owner: owner);
        }
        await _refreshPending();
      }),
    );
  }

  // ------------------------------------------------------------------ interno

  Future<void> _connect(String owner) async {
    if (_connector != null) await _connection.disconnect();
    _owner = owner;
    _clock.offsetMs = await _store.clockOffset();
    final c = _connector = BookNestConnector(
      endpoint: _endpoint,
      backend: _backend,
      store: _store,
      listener: this,
      deviceNowMs: _clock.deviceNowMs,
      telemetry: _telemetry,
      backoffFor: _backoffFor,
    );
    await _statusSub?.cancel();
    _statusSub = _connection.statusStream.listen(_onStatus);
    _emit(
      _state.copyWith(
        pro: true,
        phase: SyncPhase.connecting,
        pending: await _store.pendingUploads(),
        deviceAheadMs: _clock.deviceAheadMs,
      ),
    );
    await _connection.connect(c);
  }

  Future<void> _goFree({required bool proLost, bool resetFlag = false}) async {
    _expiry?.cancel();
    _expiry = null;
    _connector?.backoff.wakeUp();
    await _statusSub?.cancel();
    _statusSub = null;
    await _connection.disconnectAndClear();
    await _store.setFree();
    _connector = null;
    _owner = null;
    _emit(
      SyncState(
        proLost: resetFlag ? false : (proLost || _state.proLost),
        deviceAheadMs: _clock.deviceAheadMs,
      ),
    );
  }

  /// Chegou o fim previsto do Pro: confirma com o servidor; sem resposta, vale o previsto.
  Future<void> _checkExpiry() async {
    if (_connector == null) return;
    try {
      final sent = _clock.deviceNowMs();
      final e = await _backend.entitlement();
      entitlementChecked(e, sentAtMs: sent, receivedAtMs: _clock.deviceNowMs());
      if (e.pro) return; // renovou
    } on SyncCallFailure catch (f) {
      _telemetry.callFailed('expiracao_${f.kind}');
    }
    await _goFree(proLost: true);
  }

  DateTime? _lastSynced;

  void _onStatus(LinkStatus s) {
    final phase = switch (s) {
      LinkStatus(connected: true, uploading: true) ||
      LinkStatus(connected: true, downloading: true) => SyncPhase.syncing,
      LinkStatus(connected: true) => SyncPhase.synced,
      LinkStatus(connecting: true) => SyncPhase.connecting,
      _ => SyncPhase.offline,
    };
    _emit(_state.copyWith(phase: phase, lastSyncedAt: s.lastSyncedAt));
    final synced = s.lastSyncedAt;
    final owner = _owner;
    if (synced != null && synced != _lastSynced && owner != null) {
      _lastSynced = synced;
      // chegou uma sincronização completa: junta o que o servidor recusou por já ter igual
      unawaited(
        _serial(() async {
          if (_owner != owner) return;
          await _store.resolveUniqueConflicts(owner: owner, syncedAt: synced);
          await _refreshPending();
        }),
      );
    }
  }

  Future<void> _refreshPending() async {
    if (_connector == null) return;
    final n = await _store.pendingUploads();
    _emit(_state.copyWith(pending: n, uploadTotal: n == 0 ? () => null : null));
  }

  /// App fechando: desconecta sem limpar (a fila continua para a próxima abertura).
  Future<void> dispose() async {
    _expiry?.cancel();
    _connector?.backoff.wakeUp();
    await _statusSub?.cancel();
    if (_connector != null) await _connection.disconnect();
    _disposed = true;
    await _states.close();
  }
}

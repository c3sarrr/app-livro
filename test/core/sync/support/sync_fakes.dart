// Dublês da sincronização (G06): servidor de mentira (JWT, Pro, RPC), ouvinte e telemetria que gravam.
// O banco é o de verdade (PowerSync + drift num arquivo temporário): fila, gatilhos e limpeza reais.
import 'dart:io';

import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/daos/kv_dao.dart';
import 'package:app_leitura/core/data/database/local_sql.dart';
import 'package:app_leitura/core/data/database/powersync_schema.dart';
import 'package:app_leitura/core/sync/booknest_connector.dart';
import 'package:app_leitura/core/sync/sync_backend.dart';
import 'package:drift_sqlite_async/drift_sqlite_async.dart';
import 'package:powersync/powersync.dart' hide Column;

/// Banco do aparelho de verdade num arquivo temporário.
final class DbTeste {
  DbTeste._(this.dir, this.ps, this.db);

  static var _n = 0;

  static Future<DbTeste> abrir() async {
    final dir = await Directory.systemTemp.createTemp('booknest_g06_');
    final ps = PowerSyncDatabase(
      schema: buildPowerSyncSchema(),
      path: '${dir.path}${Platform.pathSeparator}app_${_n++}.db',
    );
    await ps.initialize();
    final db = AppDatabase(SqliteAsyncDriftConnection(ps));
    await db.customSelect('SELECT 1').get();
    return DbTeste._(dir, ps, db);
  }

  final Directory dir;
  final PowerSyncDatabase ps;
  final AppDatabase db;

  Future<void> modoPro(String dono) async {
    await KvDao(db).set(syncModeKey, syncModePro);
    await KvDao(db).set(activeOwnerKey, dono);
  }

  Future<int> fila() async =>
      (await ps.get('SELECT count(*) n FROM ps_crud'))['n'] as int;

  Future<int> conta(String sql, [List<Object?> args = const []]) async =>
      (await ps.get(sql, args)).values.first as int;

  Future<void> fechar() async {
    await db.close();
    await ps.close();
    await dir.delete(recursive: true);
  }
}

/// Servidor de mentira.
final class FakeSyncBackend implements SyncBackend {
  FakeSyncBackend({this.userId = 'conta'});

  @override
  String? userId;
  String? token = 'jwt-teste';
  DateTime? expiresAt = DateTime.utc(2026, 10, 4, 13);

  Entitlement entitlementAtual = const Entitlement(
    pro: true,
    activeUntil: null,
    serverTimeMs: null,
  );

  /// Próximas consultas do Pro falham com isto (uma por vez).
  final List<SyncCallFailure> falhasDoPro = [];

  /// Próximas chamadas da RPC falham com isto (uma por vez).
  final List<SyncCallFailure> falhasDaRpc = [];

  /// Recusas por id (o resto é aplicado).
  final Map<String, (String error, String code)> recusar = {};

  final List<List<Map<String, Object?>>> lotes = [];
  int consultasDoPro = 0;

  @override
  Future<({String token, DateTime? expiresAt})?> accessToken() async {
    final t = token;
    return t == null ? null : (token: t, expiresAt: expiresAt);
  }

  @override
  Future<Entitlement> entitlement() async {
    consultasDoPro++;
    if (falhasDoPro.isNotEmpty) throw falhasDoPro.removeAt(0);
    return entitlementAtual;
  }

  @override
  Future<ApplyResult> applyChanges(List<Map<String, Object?>> changes) async {
    if (falhasDaRpc.isNotEmpty) throw falhasDaRpc.removeAt(0);
    lotes.add(changes);
    final rejected = [
      for (final c in changes)
        if (recusar[c['id']] case (final e, final code))
          SyncRejection(
            table: c['table']! as String,
            id: c['id']! as String,
            error: e,
            code: code,
          ),
    ];
    return ApplyResult(
      applied: changes.length - rejected.length,
      skipped: 0,
      rejected: rejected,
    );
  }
}

/// Ouvinte do conector que só grava.
final class OuvinteTeste implements SyncConnectorListener {
  final List<Entitlement> consultas = [];
  final List<(int, int)> instantes = [];
  int proPerdido = 0;
  final List<ApplyResult> lotes = [];

  @override
  void entitlementChecked(
    Entitlement e, {
    required int sentAtMs,
    required int receivedAtMs,
  }) {
    consultas.add(e);
    instantes.add((sentAtMs, receivedAtMs));
  }

  @override
  void proLost() => proPerdido++;

  @override
  void batchUploaded(ApplyResult result) => lotes.add(result);
}

/// Telemetria que só grava (para conferir que não vai conteúdo).
final class TelemetriaTeste implements SyncTelemetry {
  final List<String> eventos = [];

  @override
  void rejected({required String table, required String? code}) =>
      eventos.add('recusa:$table:$code');

  @override
  void callFailed(String kind) => eventos.add('falha:$kind');
}

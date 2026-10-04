// O lado do banco local da sincronização do Pro: modo (Grátis/Pro), reenfileirar, recusas da RPC,
// relógio e as linhas que o servidor recusou por já ter outra igual (únicos parciais).
import 'dart:convert';

import 'package:drift/drift.dart';

import '../data/clock/server_clock.dart';
import '../data/database/app_database.dart';
import '../data/database/daos/kv_dao.dart';
import '../data/database/local_sql.dart';
import '../data/database/versioning.dart';
import 'local_merge.dart';
import 'sync_backend.dart';

/// Apaga um arquivo do aparelho (o do livro). Arquivo que já não existe não é erro.
typedef SyncFileRemover = Future<void> Function(String path);

final class SyncStore {
  SyncStore(this._db, {SyncFileRemover? removeFile, DateTime Function()? now})
    : _kv = KvDao(_db),
      _remove = removeFile,
      _now = now ?? DateTime.now;

  final AppDatabase _db;
  final KvDao _kv;
  final SyncFileRemover? _remove;
  final DateTime Function() _now;

  /// Folga antes do limite de 5 min da RPC ao reenviar uma versão que estava no futuro.
  static const int requeueMarginMs = 30 * 1000;

  Future<bool> isPro() async => await _kv.get(syncModeKey) == syncModePro;

  Future<String?> activeOwner() => _kv.get(activeOwnerKey);

  Future<void> setFree() => _kv.set(syncModeKey, syncModeFree);

  /// Virar Pro (Anexo 02 §3.1 item 2): o modo e TODA linha do [owner] na fila, numa transação.
  /// Devolve quantas operações entraram.
  Future<int> turnPro(String owner) => _db.transaction(() async {
    await _kv.set(syncModeKey, syncModePro);
    final antes = await pendingUploads();
    for (final t in personalSyncColumns.keys) {
      await _db.customStatement(enqueueAllSql(t), [owner]);
    }
    return await pendingUploads() - antes;
  });

  /// Operações esperando para subir.
  Future<int> pendingUploads() async =>
      (await _db.customSelect('SELECT count(*) AS n FROM ps_crud').getSingle())
          .read<int>('n');

  Future<int> rejectionCount() async =>
      (await _db
              .customSelect('SELECT count(*) AS n FROM sync_rejections')
              .getSingle())
          .read<int>('n');

  /// Guarda as recusas da RPC com a operação inteira ([changes] = o lote enviado). A chave é
  /// tabela + id + versão: reenviar o mesmo lote (app fechou antes de tirar da fila) não duplica.
  Future<void> recordRejections(
    List<SyncRejection> rejected,
    List<Map<String, Object?>> changes,
  ) => _db.transaction(() async {
    final at = _now().toUtc().toIso8601String();
    for (final r in rejected) {
      final op = changes.lastWhere(
        (c) => c['table'] == r.table && c['id'] == r.id,
        orElse: () => {'table': r.table, 'id': r.id},
      );
      await _db.customStatement(
        'INSERT OR REPLACE INTO sync_rejections '
        '(id, entity, row_id, reason, code, operation, rejected_at) VALUES (?, ?, ?, ?, ?, ?, ?)',
        [
          '${r.table}:${r.id}:${op['hlc']}',
          r.table,
          r.id,
          r.error,
          r.code,
          jsonEncode(op),
          at,
        ],
      );
    }
  });

  // ---------------------------------------------------------------- relógio (ADR-003)

  Future<int> clockOffset() async =>
      int.tryParse(await _kv.get(ServerClock.offsetKey) ?? '') ?? 0;

  Future<void> saveClockOffset(int ms) =>
      _kv.set(ServerClock.offsetKey, ms.toString());

  /// Linhas recusadas por `invalid_hlc` (versão > 5 min à frente do servidor, de um período com o
  /// relógio adiantado): voltam à fila com o estado atual quando a versão delas deixar de estar no
  /// futuro para o servidor ([serverNowMs]). A versão não pode descer (o gatilho de versão recusa e o
  /// LWW perderia a edição) — então é esperar o tempo real alcançá-la. Devolve quantas voltaram.
  Future<int> requeueClockRejections({
    required String owner,
    required int serverNowMs,
  }) => _db.transaction(() async {
    final rows = await _db
        .customSelect(
          "SELECT id, entity, row_id FROM sync_rejections WHERE reason = 'invalid_hlc'",
        )
        .get();
    var n = 0;
    for (final r in rows) {
      final table = r.read<String>('entity');
      final id = r.read<String>('row_id');
      final rejection = r.read<String>('id');
      if (!personalSyncColumns.containsKey(table)) continue;
      final row = await _db
          .customSelect(
            'SELECT user_id, version_hlc FROM $table WHERE id = ?',
            variables: [Variable.withString(id)],
          )
          .getSingleOrNull();
      if (row == null) {
        await _dropRejection(rejection); // a linha já não existe no aparelho
        continue;
      }
      if (row.read<String>('user_id') != owner) continue;
      final wall = int.parse(row.read<String>('version_hlc').substring(0, 16));
      if (wall > serverNowMs + LocalVersioning.maxFutureMs - requeueMarginMs) {
        continue;
      }
      await _db.customStatement(enqueueRowSql(table), [id]);
      await _dropRejection(rejection);
      n++;
    }
    return n;
  });

  // ---------------------------------------------------------------- únicos parciais (ADR-003)

  /// Livros e rótulos recusados com 23505 (o servidor já tem outro ativo com o mesmo arquivo/cor):
  /// quando o outro chega deste aparelho pela sincronização, os dois viram um ([mergeUserBook] /
  /// [mergeHighlightLabel]); se depois de uma sincronização completa ([syncedAt]) o outro não existe
  /// mais (foi apagado na nuvem), a linha volta à fila. Em seguida, as linhas recusadas por apontar
  /// para um livro que o servidor não tinha (23503) voltam à fila. Devolve quantas linhas resolveu.
  Future<int> resolveUniqueConflicts({
    required String owner,
    DateTime? syncedAt,
  }) async {
    final files = <String>[];
    final n = await _db.transaction(() async {
      var resolved = 0;
      for (final (table, key) in const [
        ('user_books', 'content_sha256'),
        ('highlight_labels', 'color'),
      ]) {
        // recusa de uma linha que já saiu do aparelho (juntada antes e reenviada pela fila)
        await _db.customStatement(
          "DELETE FROM sync_rejections WHERE entity = '$table' AND code = '23505' "
          'AND row_id NOT IN (SELECT id FROM $table)',
        );
        final losers = await _db
            .customSelect(
              'SELECT r.id AS rid, r.rejected_at, t.id, t.$key AS k FROM sync_rejections r '
              'JOIN $table t ON t.id = r.row_id '
              "WHERE r.entity = '$table' AND r.code = '23505' AND t.user_id = ? "
              'AND t.deleted_at IS NULL AND t.$key IS NOT NULL',
              variables: [Variable.withString(owner)],
            )
            .get();
        for (final l in losers) {
          final loser = l.read<String>('id');
          final survivor = await _db
              .customSelect(
                'SELECT id FROM $table WHERE user_id = ? AND $key = ? AND deleted_at IS NULL '
                "AND id <> ? AND id NOT IN (SELECT row_id FROM sync_rejections WHERE entity = '$table' "
                "AND code = '23505') ORDER BY id LIMIT 1",
                variables: [
                  Variable.withString(owner),
                  Variable.withString(l.read<String>('k')),
                  Variable.withString(loser),
                ],
              )
              .getSingleOrNull();
          if (survivor != null) {
            final s = survivor.read<String>('id');
            if (table == 'user_books') {
              final m = await mergeUserBook(_db, loser: loser, survivor: s);
              files.addAll(m.removedFiles);
            } else {
              await mergeHighlightLabel(_db, loser: loser, survivor: s);
            }
          } else {
            final rejectedAt = DateTime.parse(l.read<String>('rejected_at'));
            if (syncedAt == null || !syncedAt.isAfter(rejectedAt)) continue;
            await _db.customStatement(enqueueRowSql(table), [loser]);
          }
          await _db.customStatement(
            'DELETE FROM sync_rejections WHERE entity = ? AND row_id = ?',
            [table, loser],
          );
          resolved++;
        }
      }
      if (resolved > 0) resolved += await _requeueForeignKeyRejections(owner);
      return resolved;
    });
    final remove = _remove;
    if (remove != null) {
      for (final f in files) {
        await remove(f);
      }
    }
    return n;
  }

  /// Linhas recusadas com 23503 (referência a um livro que o servidor não tinha) voltam à fila com o
  /// estado atual.
  Future<int> _requeueForeignKeyRejections(String owner) async {
    final rows = await _db
        .customSelect(
          "SELECT id, entity, row_id FROM sync_rejections WHERE code = '23503'",
        )
        .get();
    var n = 0;
    for (final r in rows) {
      final table = r.read<String>('entity');
      final id = r.read<String>('row_id');
      if (!personalSyncColumns.containsKey(table)) continue;
      final dono = await _db
          .customSelect(
            'SELECT user_id FROM $table WHERE id = ?',
            variables: [Variable.withString(id)],
          )
          .getSingleOrNull();
      if (dono == null) {
        await _dropRejection(r.read<String>('id'));
        continue;
      }
      if (dono.read<String>('user_id') != owner) continue;
      await _db.customStatement(enqueueRowSql(table), [id]);
      await _dropRejection(r.read<String>('id'));
      n++;
    }
    return n;
  }

  Future<void> _dropRejection(String id) =>
      _db.customStatement('DELETE FROM sync_rejections WHERE id = ?', [id]);
}

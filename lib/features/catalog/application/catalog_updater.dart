// O `catalog.db` no aparelho (Anexo 02 §7.2): baixa em segundo plano — só em Wi-Fi/cabo, enquanto o
// app está aberto —, retoma de onde parou (Range), confere o sha256, troca o arquivo de uma vez, e no
// mês seguinte aplica só o delta (conferido pelo hash do conteúdo). Consulta o manifesto no máximo
// uma vez por dia.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show immutable;
import 'package:http/http.dart' as http;

import '../../../core/data/database/daos/kv_dao.dart';
import '../data/catalog_files.dart';
import '../data/catalog_manifest.dart';
import '../data/local_catalog.dart';
import '../domain/catalog_failure.dart';

enum NetworkKind {
  /// Wi-Fi ou cabo.
  unmetered,

  /// Dados móveis (o download grande espera).
  metered,
  none,
}

typedef NetworkCheck = Future<NetworkKind> Function();

@immutable
sealed class CatalogUpdate {
  const CatalogUpdate();
}

final class CatalogUpToDate extends CatalogUpdate {
  const CatalogUpToDate(this.version);
  final String version;
}

final class CatalogInstalled extends CatalogUpdate {
  const CatalogInstalled(this.version, {this.fromDelta});
  final String version;

  /// Versão de origem quando veio por delta.
  final String? fromDelta;
}

/// Não tentou: `rede_movel`, `sem_rede` ou `verificado_hoje`.
final class CatalogUpdateSkipped extends CatalogUpdate {
  const CatalogUpdateSkipped(this.reason);
  final String reason;
}

final class CatalogUpdater {
  CatalogUpdater({
    required this._client,
    required this.base,
    required this.dir,
    required this.network,
    required this._kv,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final http.Client _client;

  /// Endereço do Worker do catálogo (terminado em `/`).
  final Uri base;

  /// Pasta do catálogo no aparelho (suporte do app — fora dos documentos e do backup).
  final Directory dir;
  final NetworkCheck network;
  final KvDao _kv;
  final DateTime Function() _now;

  static const String checkedKey = 'catalogo.verificado_em';
  static const Duration checkInterval = Duration(days: 1);

  SqliteLocalCatalog? _current;
  Future<void>? _running;

  File get _dbFile => File('${dir.path}${Platform.pathSeparator}catalog.db');

  /// O catálogo aberto (null = ainda não baixado ou ilegível).
  Future<LocalCatalog?> catalog() async {
    final c = _current;
    if (c != null) return c;
    if (!await _dbFile.exists()) return null;
    try {
      return _current = await SqliteLocalCatalog.open(_dbFile.path);
    } on CatalogCorrupted {
      await _dbFile.delete();
      return null;
    }
  }

  /// Uma atualização por vez; [force] ignora a rede móvel e o "já verificado hoje".
  Future<CatalogUpdate> update({bool force = false}) async {
    while (_running != null) {
      await _running;
    }
    final run = _update(force);
    _running = run.then((_) {}, onError: (Object _) {});
    try {
      return await run;
    } finally {
      _running = null;
    }
  }

  Future<CatalogUpdate> _update(bool force) async {
    final net = await network();
    if (net == NetworkKind.none) return const CatalogUpdateSkipped('sem_rede');
    if (!force && net == NetworkKind.metered) {
      return const CatalogUpdateSkipped('rede_movel');
    }
    final now = _now().toUtc();
    final last = DateTime.tryParse(await _kv.get(checkedKey) ?? '');
    if (!force && last != null && now.difference(last) < checkInterval) {
      return const CatalogUpdateSkipped('verificado_hoje');
    }
    await dir.create(recursive: true);
    final manifest = await _manifest();
    final local = await catalog();
    final have = await local?.version();
    if (have == manifest.version) {
      await _kv.set(checkedKey, now.toIso8601String());
      return CatalogUpToDate(manifest.version);
    }
    final delta = have == null ? null : manifest.deltas[have];
    if (delta != null && local is SqliteLocalCatalog) {
      try {
        await _applyDelta(local, delta, have!, manifest);
        await _kv.set(checkedKey, now.toIso8601String());
        return CatalogInstalled(manifest.version, fromDelta: have);
      } on CatalogCorrupted {
        // delta que não fecha com o hash: cai para o arquivo inteiro
      }
    }
    await _installFull(manifest);
    await _kv.set(checkedKey, now.toIso8601String());
    return CatalogInstalled(manifest.version);
  }

  Future<CatalogManifest> _manifest() async {
    final http.Response r;
    try {
      r = await _client
          .get(base.resolve('v1/catalog/manifest.json'))
          .timeout(const Duration(seconds: 15));
    } on Exception {
      throw const CatalogOffline();
    }
    if (r.statusCode == 429) throw const CatalogQuotaExceeded();
    if (r.statusCode >= 500) throw CatalogOffline('http_${r.statusCode}');
    if (r.statusCode != 200) throw CatalogUnexpected('http_${r.statusCode}');
    try {
      return CatalogManifest.fromJson(
        jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, Object?>,
      );
    } on Object {
      throw const CatalogCorrupted('manifesto');
    }
  }

  Future<void> _applyDelta(
    SqliteLocalCatalog local,
    CatalogFile delta,
    String from,
    CatalogManifest m,
  ) async {
    final gz = await downloadCatalogFile(
      client: _client,
      base: base,
      dir: dir,
      file: delta,
    );
    try {
      final text = utf8.decode(gzip.decode(await gz.readAsBytes()));
      await local.applyDelta(
        const LineSplitter().convert(text),
        expectedFrom: from,
        expectedTo: m.version,
        expectedContentSha256: m.contentSha256,
      );
    } on FormatException {
      throw const CatalogCorrupted('delta');
    } finally {
      if (await gz.exists()) await gz.delete();
    }
  }

  Future<void> _installFull(CatalogManifest m) async {
    final gz = await downloadCatalogFile(
      client: _client,
      base: base,
      dir: dir,
      file: m.db,
    );
    final tmp = File('${dir.path}${Platform.pathSeparator}catalog.db.novo');
    try {
      final sha = await gunzipWithSha256(gz.path, tmp.path);
      if (sha != m.dbSha256) throw const CatalogCorrupted('db_sha');
      final novo = await SqliteLocalCatalog.open(tmp.path);
      final v = await novo.version();
      await novo.close();
      if (v != m.version) throw const CatalogCorrupted('db_versao');
      await _current?.close();
      _current = null;
      if (await _dbFile.exists()) await _dbFile.delete();
      await _deleteSideFiles(_dbFile.path);
      await _deleteSideFiles(tmp.path);
      await tmp.rename(_dbFile.path);
    } on FileSystemException {
      throw const CatalogCorrupted('gzip');
    } finally {
      if (await gz.exists()) await gz.delete();
      if (await tmp.exists()) await tmp.delete();
      await _deleteSideFiles(tmp.path);
    }
  }

  /// Diário/WAL que o SQLite pode deixar ao lado de um arquivo (versões antigas, queda no meio).
  static Future<void> _deleteSideFiles(String path) async {
    for (final s in const ['-journal', '-wal', '-shm']) {
      final f = File('$path$s');
      if (await f.exists()) await f.delete();
    }
  }

  Future<void> close() async {
    await _current?.close();
    _current = null;
  }
}

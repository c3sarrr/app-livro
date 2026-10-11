// Manifesto publicado pelo pipeline (`catalog/v1/manifest.json`): a versão atual do catalog.db, o
// arquivo inteiro e os deltas a partir das versões anteriores.
import 'package:flutter/foundation.dart' show immutable;

@immutable
final class CatalogFile {
  const CatalogFile({
    required this.path,
    required this.bytes,
    required this.sha256,
  });

  factory CatalogFile.fromJson(Map<String, Object?> j) => CatalogFile(
    path: j['path']! as String,
    bytes: (j['bytes']! as num).toInt(),
    sha256: j['sha256']! as String,
  );

  /// Caminho relativo à raiz publicada (`catalog/v1/<versão>/catalog.db.gz`).
  final String path;
  final int bytes;
  final String sha256;
}

@immutable
final class CatalogManifest {
  const CatalogManifest({
    required this.version,
    required this.db,
    required this.dbSha256,
    required this.contentSha256,
    required this.records,
    required this.deltas,
  });

  factory CatalogManifest.fromJson(Map<String, Object?> j) {
    if (j['formato'] != 1) throw const FormatException('formato do manifesto');
    final db = j['db']! as Map<String, Object?>;
    return CatalogManifest(
      version: j['versao']! as String,
      db: CatalogFile.fromJson(db),
      dbSha256: db['db_sha256']! as String,
      contentSha256: db['conteudo_sha256']! as String,
      records: (db['registros']! as num).toInt(),
      deltas: {
        for (final d in (j['deltas'] as List<Object?>?) ?? const [])
          (d! as Map<String, Object?>)['de']! as String: CatalogFile.fromJson(
            d as Map<String, Object?>,
          ),
      },
    );
  }

  final String version;

  /// O `catalog.db.gz` inteiro.
  final CatalogFile db;

  /// sha256 do `catalog.db` descomprimido.
  final String dbSha256;

  /// Hash do conteúdo (o que o app confere depois de aplicar um delta).
  final String contentSha256;
  final int records;

  /// Delta por versão de origem.
  final Map<String, CatalogFile> deltas;
}

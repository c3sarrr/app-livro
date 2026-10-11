// Ligações do catálogo (Riverpod). Sem `CATALOG_URL` não há borda nem download (só o que o aparelho já
// viu); sem conta não há comunidade nem consulta externa (D-64).
import 'dart:io' show Directory, Platform;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../../core/config/server_providers.dart';
import '../../../core/data/database/daos/kv_dao.dart';
import '../../../core/data/database/local_database.dart';
import '../../home/application/home_providers.dart' show clockProvider;
import '../data/catalog_cache_dao.dart';
import '../data/community_catalog_api.dart';
import '../data/edge_catalog_api.dart';
import '../data/external_isbn_api.dart';
import '../data/network_kind.dart';
import 'catalog_updater.dart';
import 'isbn_resolver.dart';

/// Cliente HTTP do catálogo (o teste de privacidade troca por um que grava os pedidos).
final catalogHttpClientProvider = Provider<http.Client>((ref) {
  final c = http.Client();
  ref.onDispose(c.close);
  return c;
});

/// Tipo de rede atual (testes trocam).
final networkCheckProvider = Provider<NetworkCheck>(
  (ref) => currentNetworkKind,
);

/// Pasta do catálogo no aparelho (suporte do app; testes trocam).
final catalogDirProvider = FutureProvider<Directory>((ref) async {
  final base = await getApplicationSupportDirectory();
  return Directory('${base.path}${Platform.pathSeparator}catalogo');
});

final catalogUpdaterProvider = FutureProvider<CatalogUpdater?>((ref) async {
  final env = ref.watch(appEnvProvider);
  if (!env.hasCatalog) return null;
  final db = await ref.watch(localDatabaseProvider.future);
  final u = CatalogUpdater(
    client: ref.watch(catalogHttpClientProvider),
    base: env.catalogBase,
    dir: await ref.watch(catalogDirProvider.future),
    network: ref.watch(networkCheckProvider),
    kv: KvDao(db),
    now: ref.watch(clockProvider),
  );
  ref.onDispose(u.close);
  return u;
});

final edgeCatalogApiProvider = Provider<EdgeCatalogApi?>((ref) {
  final env = ref.watch(appEnvProvider);
  if (!env.hasCatalog) return null;
  return HttpEdgeCatalogApi(
    ref.watch(catalogHttpClientProvider),
    env.catalogBase,
  );
});

final externalIsbnApiProvider = Provider<ExternalIsbnApi?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client == null ? null : SupabaseExternalIsbnApi(client);
});

/// Camada da comunidade (G07.4, D-74) — só com o servidor configurado; sem sessão, a própria API
/// recusa sem ir à rede.
final communityCatalogApiProvider = Provider<CommunityCatalogApi?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client == null ? null : SupabaseCommunityCatalogApi(client);
});

final isbnResolverProvider = FutureProvider<IsbnResolver>((ref) async {
  final db = await ref.watch(localDatabaseProvider.future);
  final updater = await ref.watch(catalogUpdaterProvider.future);
  return IsbnResolver(
    cache: CatalogCacheDao(db),
    localCatalog: () async => updater?.catalog(),
    edge: ref.watch(edgeCatalogApiProvider),
    community: ref.watch(communityCatalogApiProvider),
    external: ref.watch(externalIsbnApiProvider),
    now: ref.watch(clockProvider),
  );
});

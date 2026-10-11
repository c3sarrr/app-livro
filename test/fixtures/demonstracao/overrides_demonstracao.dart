// R00 (D-267, R6) — o que o modo demonstração troca no app: o banco (`booknest_demo.db`, semeado com o mundo de
// referência na primeira abertura), as pastas dos livros, das capas e do catálogo (`*_demo`), a conta guardada no
// aparelho (a do demo), o relógio (o "agora" de referência que anda), a cor `brand` na memória e o cabeçalho da
// Início (a Marina, com 2 notificações — o mundo; sem servidor não há conta, D-64). O banco e as pastas do app normal
// (`booknest.db`, `livros/`, `capas/`, `capas_arquivo/`, `catalogo/`) nunca são abertos, e nenhum serviço é ligado
// (`recusarServicos`, `semServicos`). Sem flutter_test.
import 'dart:io';

import 'package:app_leitura/core/config/app_env.dart';
import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/local_database.dart';
import 'package:app_leitura/core/data/database/powersync_schema.dart';
import 'package:app_leitura/core/preferences/brand_preference.dart';
import 'package:app_leitura/features/account/application/account_providers.dart';
import 'package:app_leitura/features/account/data/local_library.dart';
import 'package:app_leitura/features/catalog/application/catalog_providers.dart'
    show catalogDirProvider, catalogHttpClientProvider;
import 'package:app_leitura/features/clubs/application/clubs_providers.dart'
    show socialOwnerProvider;
import 'package:app_leitura/features/home/application/cover_providers.dart';
import 'package:app_leitura/features/home/application/home_providers.dart';
import 'package:app_leitura/features/home/data/cover_store.dart';
import 'package:app_leitura/features/library/application/library_import.dart';
import 'package:drift_sqlite_async/drift_sqlite_async.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:path_provider/path_provider.dart';
import 'package:powersync/powersync.dart' show PowerSyncDatabase;

import '../mundo_2026_09_20.dart';
import '../telas/inicio01.dart';
import 'relogio_demonstracao.dart';
import 'semear_mundo.dart';

/// O arquivo do banco do demo e as pastas dele, dentro da pasta de suporte do app.
const String bancoDemonstracao = 'booknest_demo.db';
const String livrosDemonstracao = 'livros_demo';
const String capasDemonstracao = 'capas_demo';
const String capasDoArquivoDemonstracao = 'capas_arquivo_demo';
const String catalogoDemonstracao = 'catalogo_demo';

/// Os nomes que o demo cria na pasta de suporte (o banco e os arquivos que o SQLite põe ao lado dele, e as pastas).
bool ehDaDemonstracao(String nome) =>
    nome.startsWith(bancoDemonstracao) ||
    nome == livrosDemonstracao ||
    nome == capasDemonstracao ||
    nome == capasDoArquivoDemonstracao ||
    nome == catalogoDemonstracao;

/// A pasta [nome] dentro de [suporte], criada se faltar.
Future<Directory> Function() pastaDemonstracao(
  String nome, {
  Future<Directory> Function() suporte = getApplicationSupportDirectory,
}) => () async {
  final base = await suporte();
  return Directory('${base.path}${Platform.pathSeparator}$nome')
    ..createSync(recursive: true);
};

/// Apaga o banco e as pastas do demo em [suporte] (o `--dart-define=BOOKNEST_DEMO_RECOMECAR=true`); nada mais.
Future<void> apagarDemonstracao({
  Future<Directory> Function() suporte = getApplicationSupportDirectory,
}) async {
  final base = await suporte();
  if (!base.existsSync()) return;
  for (final e in base.listSync()) {
    final nome = e.uri.pathSegments.where((s) => s.isNotEmpty).last;
    if (ehDaDemonstracao(nome)) e.deleteSync(recursive: true);
  }
}

/// Os serviços que os `--dart-define` ligariam ([env]): o servidor, a sincronização, o catálogo e a loja. O demo
/// não liga nenhum (D-267): o `runBookNest` ligaria o Supabase com a sessão guardada no aparelho — a da conta de
/// verdade — antes dos overrides, e a sincronização, o catálogo e a loja falariam com a rede.
List<String> servicosNosDefines(AppEnv env) => [
  if (env.supabaseUrl.trim().isNotEmpty ||
      env.supabasePublishableKey.trim().isNotEmpty)
    'servidor (SUPABASE_URL, SUPABASE_PUBLISHABLE_KEY)',
  if (env.powersyncUrl.trim().isNotEmpty) 'sincronização (POWERSYNC_URL)',
  if (env.catalogUrl.trim().isNotEmpty) 'catálogo (CATALOG_URL)',
  if (env.revenuecatKeyAndroid.trim().isNotEmpty ||
      env.revenuecatKeyIos.trim().isNotEmpty)
    'loja (REVENUECAT_PUBLIC_KEY_*)',
];

/// Recusa abrir o demo com serviço nos `--dart-define` ([env]) — os dois `main` do demo chamam antes de subir.
void recusarServicos(AppEnv env) {
  final servicos = servicosNosDefines(env);
  if (servicos.isNotEmpty) {
    throw StateError(
      'O modo demonstração roda sem servidor (D-267); tire os --dart-define de: ${servicos.join('; ')}.',
    );
  }
}

/// Sem serviço também por dentro: nenhuma configuração de servidor, catálogo ou loja e nenhum cliente do Supabase.
final List<Override> semServicos = List.unmodifiable([
  appEnvProvider.overrideWithValue(const AppEnv()),
  supabaseClientProvider.overrideWithValue(null),
]);

/// O cabeçalho da Início do demo: o perfil do mundo ("Boa noite, Marina", 2 notificações).
final usuarioDoMundo = TelaInicio01.usuario;

Future<PowerSyncDatabase> _abrir(String caminho) async {
  final ps = PowerSyncDatabase(schema: buildPowerSyncSchema(), path: caminho);
  await ps.initialize();
  return ps;
}

/// O banco [ps] tem a marca de uma semeadura de outra versão (num banco novo nem a tabela `kv` existe ainda).
Future<bool> _semeadoPorOutraVersao(PowerSyncDatabase ps) async {
  final kv = await ps.getOptional(
    "SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = 'kv'",
  );
  if (kv == null) return false;
  final marca = await ps.getOptional('SELECT value FROM kv WHERE key = ?', [
    chaveSemeado,
  ]);
  final versao = marca?['value'] as String?;
  return versao != null && versao != versaoDaSemeadura;
}

/// O banco e as pastas do demo (os dois alvos da D-267 usam).
List<Override> bancoDaDemonstracao({
  Future<Directory> Function() suporte = getApplicationSupportDirectory,
}) {
  final livros = pastaDemonstracao(livrosDemonstracao, suporte: suporte);
  final capasDoArquivo = pastaDemonstracao(
    capasDoArquivoDemonstracao,
    suporte: suporte,
  );
  return [
    powerSyncDatabaseProvider.overrideWith((ref) async {
      final dir = await suporte();
      final caminho = '${dir.path}${Platform.pathSeparator}$bancoDemonstracao';
      var ps = await _abrir(caminho);
      // semeado por outra versão da semeadura: o demo recomeça (os ids e as versões do mundo não se regravam por cima)
      if (await _semeadoPorOutraVersao(ps)) {
        await ps.close();
        await apagarDemonstracao(suporte: suporte);
        ps = await _abrir(caminho);
      }
      ref.onDispose(ps.close);
      return ps;
    }),
    localDatabaseProvider.overrideWith((ref) async {
      final ps = await ref.watch(powerSyncDatabaseProvider.future);
      final db = AppDatabase(SqliteAsyncDriftConnection(ps));
      ref.onDispose(db.close);
      await semearSeFaltar(db, livros: await livros());
      return db;
    }),
    localLibraryProvider.overrideWith(
      (ref) async => LocalLibrary(
        await ref.watch(localDatabaseProvider.future),
        fileCovers: capasDoArquivo,
      ),
    ),
    booksDirProvider.overrideWithValue(livros),
    fileCoversDirProvider.overrideWithValue(capasDoArquivo),
    coverImagesProvider.overrideWith(
      (ref) => CoverStore(
        dir: pastaDemonstracao(capasDemonstracao, suporte: suporte),
        client: ref.watch(catalogHttpClientProvider),
        pinned: () async =>
            shelfCoverUrls(await ref.read(localDatabaseProvider.future)),
        fileCovers: capasDoArquivo,
      ),
    ),
    // sem serviço o catálogo não baixa (`catalogUpdaterProvider` é nulo); a pasta é do demo mesmo assim
    catalogDirProvider.overrideWith(
      (ref) => pastaDemonstracao(catalogoDemonstracao, suporte: suporte)(),
    ),
    brandStoreProvider.overrideWith((ref) => MemoryBrandStore()),
    // o dono do cache do social (o clube semeado: o chip da 25, o sininho, a faixa do sumário) é o convidado do mundo;
    // sem o cliente do Supabase os provedores que vão à rede são nulos — é só a leitura do cache
    socialOwnerProvider.overrideWithValue(mundoReferencia.usuarioId),
  ];
}

/// O alvo (1) da D-267: o app de verdade sobre o banco do demo, com o relógio que parte de 20/09/2026 20:00.
List<Override> overridesDemonstracao({
  Future<Directory> Function() suporte = getApplicationSupportDirectory,
  DateTime Function()? relogio,
}) => [
  ...semServicos,
  ...bancoDaDemonstracao(suporte: suporte),
  clockProvider.overrideWithValue(
    relogio ?? relogioDemonstracao(mundoReferencia.agora),
  ),
  homeAccountUserProvider.overrideWithValue(usuarioDoMundo),
];

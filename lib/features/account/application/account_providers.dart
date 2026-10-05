// Ligações da conta (Riverpod). Sem servidor configurado (AppEnv.hasServer = false) não há cliente do
// Supabase e o app é só convidado (D-64). O `main()` injeta o cliente depois do `Supabase.initialize`.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/server_providers.dart';
import '../../../core/data/database/local_database.dart';
import '../data/account_api.dart';
import '../data/auth_gateway.dart';
import '../data/export_sink.dart';
import '../data/local_library.dart';
import '../data/native_sign_in.dart';
import '../data/store_age_signals.dart';
import '../../library/data/book_dirs.dart' show fileCoversDirectory;

export '../../../core/config/server_providers.dart'
    show appEnvProvider, supabaseClientProvider;

final googleTokenSourceProvider = Provider<GoogleTokenSource>(
  (ref) => GoogleSignInTokenSource(ref.watch(appEnvProvider)),
);

final appleTokenSourceProvider = Provider<AppleTokenSource>(
  (ref) => const SignInWithAppleTokenSource(),
);

final authGatewayProvider = Provider<AuthGateway?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) return null;
  return SupabaseAuthGateway(
    client,
    google: ref.watch(googleTokenSourceProvider),
    apple: ref.watch(appleTokenSourceProvider),
    redirect: ref.watch(appEnvProvider).authRedirect,
  );
});

final accountApiProvider = Provider<AccountApi?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client == null ? null : SupabaseAccountApi(client);
});

final storeAgeSignalsProvider = Provider<StoreAgeSignals>(
  (ref) => PluginStoreAgeSignals(),
);

final exportSinkProvider = Provider<ExportSink>(
  (ref) => const ShareExportSink(),
);

final localLibraryProvider = FutureProvider<LocalLibrary>(
  (ref) async => LocalLibrary(
    await ref.watch(localDatabaseProvider.future),
    // G09 (D-90): a capa que veio no arquivo some com o livro
    fileCovers: fileCoversDirectory,
  ),
);

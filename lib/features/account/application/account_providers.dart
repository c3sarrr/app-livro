// Ligações da conta (Riverpod). Sem servidor configurado (AppEnv.hasServer = false) não há cliente do
// Supabase e o app é só convidado (D-64). O `main()` injeta o cliente depois do `Supabase.initialize`.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show SupabaseClient;

import '../../../core/config/app_env.dart';
import '../../../core/data/database/local_database.dart';
import '../data/account_api.dart';
import '../data/auth_gateway.dart';
import '../data/export_sink.dart';
import '../data/local_library.dart';
import '../data/native_sign_in.dart';
import '../data/store_age_signals.dart';

final appEnvProvider = Provider<AppEnv>((ref) => AppEnv.fromDefines());

/// Cliente do Supabase (null = sem servidor nesta versão).
final supabaseClientProvider = Provider<SupabaseClient?>((ref) => null);

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
  (ref) async => LocalLibrary(await ref.watch(localDatabaseProvider.future)),
);

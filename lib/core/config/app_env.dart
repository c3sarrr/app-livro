// Configuração PÚBLICA do app (§4.4.1): vem de `--dart-define-from-file=env/<ambiente>.json`
// (`env/*.example.json` versionados; os reais ficam fora do git). Nunca chave secreta aqui.
// Sem servidor configurado (testes, build sem env) o app roda só como convidado (D-64).
import 'package:flutter/foundation.dart' show immutable;

@immutable
final class AppEnv {
  const AppEnv({
    this.environment = 'dev',
    this.supabaseUrl = '',
    this.supabasePublishableKey = '',
    this.googleWebClientId = '',
    this.googleIosClientId = '',
    this.authRedirect = defaultAuthRedirect,
    this.powersyncUrl = '',
    this.catalogUrl = '',
  });

  /// Lê os `--dart-define`.
  factory AppEnv.fromDefines() => const AppEnv(
    environment: String.fromEnvironment(
      'BOOKNEST_AMBIENTE',
      defaultValue: 'dev',
    ),
    supabaseUrl: String.fromEnvironment('SUPABASE_URL'),
    supabasePublishableKey: String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY'),
    googleWebClientId: String.fromEnvironment('GOOGLE_WEB_CLIENT_ID'),
    googleIosClientId: String.fromEnvironment('GOOGLE_IOS_CLIENT_ID'),
    authRedirect: String.fromEnvironment(
      'AUTH_REDIRECT',
      defaultValue: defaultAuthRedirect,
    ),
    powersyncUrl: String.fromEnvironment('POWERSYNC_URL'),
    catalogUrl: String.fromEnvironment('CATALOG_URL'),
  );

  /// Deep link de retorno do login pelo navegador (Apple no Android — D-67).
  static const String defaultAuthRedirect = 'booknest://login-callback';

  final String environment;
  final String supabaseUrl;
  final String supabasePublishableKey;

  /// Cliente OAuth "Web" do Google (o Supabase confere o idToken contra ele).
  final String googleWebClientId;

  /// Cliente OAuth "iOS" do Google.
  final String googleIosClientId;
  final String authRedirect;

  /// Serviço PowerSync (sincronização do Pro — ADR-003). Local: `tools/powersync/subir_local.sh`.
  final String powersyncUrl;

  /// Worker do catálogo de livros (G07 — ISBN e o `catalog.db`). Local: `wrangler dev` em
  /// `workers/catalog` (D-75).
  final String catalogUrl;

  static bool _filled(String v) => v.isNotEmpty && !v.startsWith('<');

  /// Há servidor (Supabase) para conta, login e social.
  bool get hasServer => _filled(supabaseUrl) && _filled(supabasePublishableKey);

  /// Há credencial do Google (D-67: só quando houver projeto na nuvem).
  bool get hasGoogle => _filled(googleWebClientId);

  /// Há sincronização do Pro (precisa do login e do serviço PowerSync).
  bool get hasSync => hasServer && _filled(powersyncUrl);

  /// Há catálogo na borda (não depende de conta: o Grátis também consulta pelo ISBN — §4.3.7).
  bool get hasCatalog => _filled(catalogUrl);

  /// O endereço do catálogo sempre terminado em `/` (para `Uri.resolve`).
  Uri get catalogBase =>
      Uri.parse(catalogUrl.endsWith('/') ? catalogUrl : '$catalogUrl/');
}

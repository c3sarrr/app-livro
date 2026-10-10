import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

import 'package:supabase_flutter/supabase_flutter.dart'
    show FlutterAuthClientOptions, Supabase;

import 'app/app.dart';
import 'core/config/app_env.dart';
import 'core/design_system/tokens/app_icons.dart';
import 'core/design_system/tokens/app_icons_inicio.dart';
import 'core/design_system/tokens/app_icons_leitor.dart';
import 'core/design_system/tokens/app_illustrations_inicio.dart';
import 'core/design_system/tokens/app_illustrations_leitor.dart';
import 'core/design_system/widgets/app_svg.dart' show preloadAppIcons;
import 'features/account/application/account_providers.dart';
import 'features/account/data/secure_session_storage.dart';
import 'features/billing/presentation/billing_lifecycle.dart';
import 'features/catalog/application/catalog_auto_update.dart';
import 'features/clubs/application/social_auto_sync.dart';
import 'features/library/presentation/incoming_books.dart';
import 'features/reader/presentation/tool_shelf.dart' show ToolShelf;

/// Licença SIL OFL 1.1 das fontes do arquivo (Bricolage Grotesque, Figtree,
/// Instrument Serif), distribuída junto das fontes em `assets/fonts/`.
const kFontLicenseAsset = 'assets/fonts/LICENCAS_FONTES_OFL.txt';

/// Famílias cobertas pela licença, como aparecem na tela de licenças do sistema.
const kFontLicensePackages = <String>[
  'Bricolage Grotesque',
  'Figtree',
  'Instrument Serif',
];

Future<void> main() => runBookNest();

/// Sobe o app. [overrides]: só para testes e para o app com a fixture do mundo de referência
/// (`test/fixtures/main_mundo_referencia.dart`, D-34). Produção: a Início lê o banco do aparelho (G08, D-85).
Future<void> runBookNest({List<Override> overrides = const []}) async {
  WidgetsFlutterBinding.ensureInitialized();
  registerFontLicenses();
  await configureSystemUi();
  // F12 12.4: os 18 SVGs já estão prontos no primeiro quadro (sem "piscar" na primeira abertura); G12: e os das
  // ilhas do leitor (a 1ª vez que os controles abrem); T03: e os da Início nova e da revisão.
  await preloadAppIcons([
    ...AppIcons.all,
    ...AppIconsInicio.all,
    ...AppIllustrationsInicio.all,
    ...AppIconsLeitor.all,
    ...AppIllustrationsLeitor.plain,
  ]);
  // D-190: e o Laço do Noite (a 1ª vez que o modo anotação abre no Noite)
  await ToolShelf.preload();
  final server = await connectServer(AppEnv.fromDefines());
  runApp(
    ProviderScope(
      overrides: [...server, ...overrides],
      // G07: o catálogo do aparelho se atualiza sozinho no Wi-Fi; G21: o social (os clubes, o sininho e os números
      // do perfil) ao abrir e voltar ao app; G22: o Pro (a loja e a ativação) acompanha o app; G09: "Abrir com" e
      // índices pendentes
      child: const CatalogAutoUpdate(
        child: SocialAutoSync(
          child: BillingLifecycle(child: IncomingBooks(child: App())),
        ),
      ),
    ),
  );
}

/// G05: com servidor configurado, liga o Supabase com a sessão no armazenamento seguro (Keychain /
/// Keystore) e só aceita como retorno de login o deep link do app (D-67). Sem servidor, o app é só
/// convidado (D-64) e nada é ligado.
Future<List<Override>> connectServer(AppEnv env) async {
  if (!env.hasServer) return const [];
  final store = FlutterSecureStore();
  final supabase = await Supabase.initialize(
    url: env.supabaseUrl,
    publishableKey: env.supabasePublishableKey,
    authOptions: FlutterAuthClientOptions(
      localStorage: SecureSessionStorage(store),
      pkceAsyncStorage: SecurePkceStorage(store),
      detectSessionInUriPredicate: (uri) =>
          uri.toString().startsWith(env.authRedirect),
    ),
    debug: false,
  );
  // `appEnvProvider` já lê os mesmos `--dart-define` (AppEnv.fromDefines).
  return [supabaseClientProvider.overrideWithValue(supabase.client)];
}

/// D-13: Android edge-to-edge (o conteúdo passa sob as barras do sistema).
/// D-06: somente retrato.
Future<void> configureSystemUi() async {
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
  ]);
}

/// Registra a licença OFL no [LicenseRegistry] (lida sob demanda do asset).
void registerFontLicenses() {
  LicenseRegistry.addLicense(() async* {
    final text = await rootBundle.loadString(kFontLicenseAsset);
    yield LicenseEntryWithLineBreaks(kFontLicensePackages, text);
  });
}

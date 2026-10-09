// G22.3 — as ligações da compra (Riverpod). Sem a chave do RevenueCat no env (os testes, o Windows, o build sem env)
// o gateway é nulo e o app segue sem compra, como sem Supabase (D-64). Um build de produção com a chave da Test Store
// também fica sem compra (o SDK derrubaria o app).
import 'package:flutter/foundation.dart'
    show TargetPlatform, debugPrint, defaultTargetPlatform, kReleaseMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart' show LaunchMode, launchUrl;

import '../../../core/config/server_providers.dart';
import '../data/billing_gateway.dart';
import '../data/pro_server_api.dart';
import '../data/revenuecat_gateway.dart';

/// A chave do RevenueCat para este build, ou nenhuma.
String? billingKeyFor({
  required String android,
  required String ios,
  required TargetPlatform platform,
  required bool release,
}) {
  final key = switch (platform) {
    TargetPlatform.android => android,
    TargetPlatform.iOS => ios,
    _ => '',
  };
  if (key.isEmpty || key.startsWith('<')) return null;
  if (release && key.startsWith('test_')) return null;
  return key;
}

final billingGatewayProvider = Provider<BillingGateway?>((ref) {
  final env = ref.watch(appEnvProvider);
  final platform = defaultTargetPlatform;
  final key = billingKeyFor(
    android: env.revenuecatKeyAndroid,
    ios: env.revenuecatKeyIos,
    platform: platform,
    release: kReleaseMode,
  );
  if (key == null) {
    final teste =
        kReleaseMode &&
        (env.revenuecatKeyAndroid.startsWith('test_') ||
            env.revenuecatKeyIos.startsWith('test_'));
    if (teste) {
      debugPrint(
        'RevenueCat: chave da Test Store num build de produção; a compra fica desligada.',
      );
    }
    return null;
  }
  return RevenueCatGateway(apiKey: key, platform: platform);
});

/// O Pro do servidor ("conferir agora" e `my_entitlement`): só com o Supabase.
final proServerApiProvider = Provider<ProServerApi?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client == null ? null : SupabaseProServerApi(client);
});

/// A espera do recuo da ativação (R2); o teste troca por uma que não espera.
final billingSleepProvider = Provider<Future<void> Function(Duration)>(
  (ref) => Future<void>.delayed,
);

/// A plataforma da loja (R6: onde gerenciar); o teste escolhe.
final billingPlatformProvider = Provider<TargetPlatform>(
  (ref) => defaultTargetPlatform,
);

/// Abre a página de gestão da loja fora do app (R6). Devolve se abriu.
final billingLauncherProvider = Provider<Future<bool> Function(Uri)>(
  (ref) =>
      (uri) => launchUrl(uri, mode: LaunchMode.externalApplication),
);

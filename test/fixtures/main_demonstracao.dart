// R00 (D-267) — o modo demonstração, alvo (1): o app de verdade sobre um banco só do demo (`booknest_demo.db`), com
// o mundo de referência gravado na primeira abertura (a Início, o leitor com o EPUB, os grifos, a tinta, os
// marcadores, as metas, o cronômetro do papel e o clube no cache), sem servidor e com o relógio que parte de dom
// 20/09/2026 20:00 e anda. Fora de `lib/` (D-34) e nunca em release — o build de loja é o `lib/main.dart`. No
// celular, pelo script que confere a assinatura e guarda o app normal (o `flutter run` desinstala o app quando a
// instalação por cima falha, e os dados do app normal vão junto):
//   python3 tools/celular/demo.py               (e `--voltar` para o app normal)
//   python3 tools/celular/demo.py --recomecar   (= `--dart-define=BOOKNEST_DEMO_RECOMECAR=true`)
// (o segundo apaga o banco e as pastas do demo a cada abertura: o mundo volta ao estado de referência). Sem os
// `--dart-define` dos serviços (`recusarServicos`): com eles o app ligaria a conta guardada no aparelho.
import 'package:app_leitura/core/config/app_env.dart';
import 'package:app_leitura/main.dart' as app;
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/widgets.dart';

import 'demonstracao/overrides_demonstracao.dart';

Future<void> main() async {
  if (kReleaseMode) {
    throw StateError('O modo demonstração não roda em release (D-267).');
  }
  recusarServicos(AppEnv.fromDefines());
  WidgetsFlutterBinding.ensureInitialized();
  if (const bool.fromEnvironment('BOOKNEST_DEMO_RECOMECAR')) {
    await apagarDemonstracao();
  }
  await app.runBookNest(overrides: overridesDemonstracao());
}

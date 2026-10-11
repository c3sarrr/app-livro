// G03 — o app com os dados do arquivo (mundo de referência, D-34); desde a G08 a produção lê o banco do aparelho, e
// este alvo continua para ver as pranchas. R00 (D-267, alvo 2): a Início da prancha 01 como ela é, e o leitor e os
// grifos abrindo o Dom Casmurro do banco do modo demonstração (`demonstracao/prancha_no_aparelho.dart`). Fora de
// `lib/` e nunca em release. No celular, pelo script que confere a assinatura e guarda o app normal:
//   python3 tools/celular/demo.py --alvo 2      (e `--voltar` para o app normal)
import 'package:app_leitura/core/config/app_env.dart';
import 'package:app_leitura/main.dart' as app;
import 'package:flutter/foundation.dart' show kReleaseMode;

import 'demonstracao/overrides_demonstracao.dart' show recusarServicos;
import 'demonstracao/prancha_no_aparelho.dart';

Future<void> main() {
  if (kReleaseMode) {
    throw StateError('O mundo de referência não roda em release (D-267).');
  }
  recusarServicos(AppEnv.fromDefines());
  return app.runBookNest(overrides: overridesDaPranchaNoAparelho());
}

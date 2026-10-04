// G03 — o app com os dados do arquivo (mundo de referência, D-34), enquanto a Início não tem o
// repositório real (G08):
//   flutter run -t test/fixtures/main_mundo_referencia.dart
import 'package:app_leitura/main.dart' as app;

import 'overrides_do_mundo.dart';

Future<void> main() => app.runBookNest(overrides: overridesDoMundo);

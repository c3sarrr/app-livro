// G03 — o app com os dados do arquivo (mundo de referência, D-34); desde a G08 a produção lê o banco
// do aparelho, e este alvo continua para ver as pranchas:
//   flutter run -t test/fixtures/main_mundo_referencia.dart
import 'package:app_leitura/main.dart' as app;

import 'overrides_do_mundo.dart';

Future<void> main() => app.runBookNest(overrides: overridesDoMundoNoAparelho);

// G20 (R9) — o driver do teste de aparelho dos orçamentos: grava o que o teste mediu em
// `build/orcamentos_aparelho.json` (a tabela do relatório da G26).
import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver(
  responseDataCallback: (data) =>
      writeResponseData(data, testOutputFilename: 'orcamentos_aparelho'),
);

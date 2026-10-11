// R00.6 (R5) — o percurso das 16 telas prontas no Galaxy S22+: o mesmo de `test/app/navegacao_test.dart` (a tabela (b)
// da NAVEGACAO.md), no aparelho, sobre o banco do modo demonstração numa pasta temporária (o banco do app normal não é
// aberto — D-267). Os placeholders alcançados saem no console e no `reportData`.
//   flutter test integration_test/navegacao_test.dart -d RXCT200CA6F --no-uninstall
// (sem `--no-uninstall` o app é desinstalado no fim, e com ele os dados do app normal.)
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/fixtures/demonstracao/prancha_no_aparelho.dart';
import '../test/fixtures/paper_timer_fakes.dart' show ManualTicker;
import '../test/support/demonstracao_no_app.dart';
import '../test/support/navegacao.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('as ligações das telas prontas no aparelho', (tester) async {
    final suporte = Directory.systemTemp.createTempSync('booknest_r00_nav_');
    await montarDemonstracao(
      tester,
      overridesDaPranchaNoAparelho(
        suporte: () async => suporte,
        tique: ManualTicker(),
      ),
      tela: null,
    );

    final amarelas = await percorrer(tester, ligacoes);
    // ignore: avoid_print — a saída da R5 no console do aparelho
    print('R00NAV placeholders (${amarelas.length}):\n${amarelas.join('\n')}');
    binding.reportData = {
      'placeholders': amarelas,
      'ligacoes': ligacoes.length,
    };
    expect(
      amarelas,
      hasLength(ligacoes.where((l) => l.classe == Classe.placeholder).length),
    );

    await desmontarDemonstracao(tester);
    await tester.runAsync(() async {
      if (suporte.existsSync()) suporte.deleteSync(recursive: true);
    });
  }, timeout: const Timeout(Duration(minutes: 20)));
}

// R00.6 (R5) — o percurso das 16 telas prontas no app inteiro (o alvo (2) da D-267: a Início da prancha 01 e o leitor
// e os grifos do banco do demo, num arquivo de uma pasta temporária): as 4 abas, o botão do scanner e cada ligação da
// NAVEGACAO.md (b) — ✅ chega ao destino, ⏸ não muda nada, 🟡 alcançado e listado na saída.
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/demonstracao/prancha_no_aparelho.dart';
import '../fixtures/paper_timer_fakes.dart' show ManualTicker;
import '../support/app_normal_ao_lado.dart';
import '../support/demonstracao_no_app.dart';
import '../support/load_fonts.dart';
import '../support/navegacao.dart';

void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'as ligações das telas prontas: ✅ leva, ⏸ não faz nada, 🟡 alcançado e listado',
    (tester) async {
      final suporte = suporteComAppNormal();
      await montarDemonstracao(
        tester,
        overridesDaPranchaNoAparelho(
          suporte: () async => suporte,
          tique: ManualTicker(),
        ),
      );

      final amarelas = await percorrer(tester, ligacoes);
      // ignore: avoid_print — a saída da R5: os placeholders alcançados, um por linha
      print(
        'Placeholders alcançados (${amarelas.length}):\n${amarelas.join('\n')}',
      );
      expect(
        amarelas,
        hasLength(ligacoes.where((l) => l.classe == Classe.placeholder).length),
      );

      await desmontarDemonstracao(tester);
      await tester.runAsync(() => apagarPasta(suporte));
    },
    timeout: const Timeout(Duration(minutes: 15)),
  );
}

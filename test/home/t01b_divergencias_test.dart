// T04.5 — as divergências entre a fixture `t01b` (D-241) e a prancha 01b, uma a uma. A `t01b` é a `t01` sem a revisão
// e com a sessão do cronômetro aberta; o Para você é o da 01 (Esaú e Jacó, Memorial de Aires, Casa de Pensão). A 01b
// troca os dois últimos por Quincas Borba e O Cortiço — abaixo da dobra (y > 844), fora do PNG da prancha, e
// `referencias_inicio2_test` já separa exatamente esses 5 ids. Aqui, no app inteiro, tudo o que a 01b reaproveita da
// 01 bate (geometria e linhas), MENOS esses 5 — e cada um diverge pelo motivo escrito (título e altura do bloco).
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/home_mock_repository.dart';
import '../fixtures/paper_timer_fakes.dart';
import '../reference/inicio2/referencias_inicio2.dart';
import '../support/fase_inicio.dart';
import '../support/load_fonts.dart';

/// As seções da 01b que vêm da 01 sem mudar (a mini-barra, o cartão em sessão, o degradê e a barra são da fase L01b).
const _reaproveitadas = [
  'i01b.header',
  'i01b.headline',
  'i01b.hero',
  'i01b.today',
  'i01b.forYou',
  'i01b.club',
  'i01b.recent',
];

/// Os 5 ids que a 01b troca abaixo da dobra.
const _trocados = {
  'i01b.forYou.item2.cover.title',
  'i01b.forYou.item2.title',
  'i01b.forYou.item3.cover.textBlock',
  'i01b.forYou.item3.cover.title',
  'i01b.forYou.item3.title',
};

void main() {
  setUpAll(loadAppFonts);

  Future<void> abrir01b(WidgetTester tester) => abrirInicio01(
    tester,
    prancha: kRef01b,
    safeTop: 47,
    safeBottom: 34,
    repositorio: const HomeMockRepository01b(),
    overrides: overridesDa01b(),
  );

  testWidgets(
    'geometria e linhas: tudo o que a 01b reaproveita da 01 bate, menos os 5 do Para você',
    (tester) async {
      await abrir01b(tester);
      final falhas = [
        ...geometria01(tester, _reaproveitadas, prancha: kRef01b),
        ...texto01(tester, _reaproveitadas, prancha: kRef01b),
      ];
      for (final f in falhas) {
        debugPrint('[t01b × 01b] $f');
      }
      final ids = {
        for (final f in falhas)
          _trocados.firstWhere(
            (t) =>
                f.startsWith('$t.') ||
                f.startsWith('$t:') ||
                f.startsWith('$t['),
            orElse: () => f,
          ),
      };
      expect(ids, _trocados, reason: 'só os 5 ids da troca divergem');
    },
  );

  testWidgets(
    'os 5, um a um: o app mostra os livros da 01; a 01b, Quincas Borba e O Cortiço',
    (tester) async {
      await abrir01b(tester);
      String linhas(String id) =>
          linhas01(tester, id, '').map((l) => l.text).join(' / ');
      final esperado = {
        'i01b.forYou.item2.cover.title': (
          'Memorial / de Aires',
          'Quincas / Borba',
        ),
        'i01b.forYou.item2.title': ('Memorial de Aires', 'Quincas Borba'),
        'i01b.forYou.item3.cover.title': ('Casa de / Pensão', 'O Cortiço'),
        'i01b.forYou.item3.title': ('Casa de Pensão', 'O Cortiço'),
      };
      for (final MapEntry(key: id, value: (app, prancha)) in esperado.entries) {
        expect(linhas(id), app, reason: id);
        expect(
          kRef01b.elements[id]!.lines.map((l) => l.text).join(' / '),
          prancha,
          reason: id,
        );
      }
      // o bloco do título da capa do O Cortiço tem uma linha só: 37,21 de altura (o da Casa de Pensão, 60,61)
      final bloco = retanguloDeLayout(
        tester,
        'i01b.forYou.item3.cover.textBlock',
      );
      expect(bloco.height, closeTo(60.61, 0.5));
      expect(
        kRef01b.elements['i01b.forYou.item3.cover.textBlock']!.rect.height,
        closeTo(37.21, 1e-9),
      );
    },
  );
}

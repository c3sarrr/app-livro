// T04.11 — L01b.6: a 01b inteira no app (`kRef01b`, 390 × 844 safe 47/34, rolagem 0): os 272 ids menos os 5 do Para
// você que a `t01b` não reproduz (D-241, `t01b_divergencias_test`), todas as linhas de texto, os goldens @3x (a tela,
// os estados sem prancha e o `brand`) e o desempenho: um tique da sessão refaz só o tempo, o rótulo e a barrinha.
// O gate visual contra o PNG da prancha roda fora do teste (a captura `t04_01b` com `BOOKNEST_CAPTURAS`):
//   python3 tools/compare_images.py --flutter <captura> --ref docs/design/medicao/inicio2/png/001b_inicio_lendo_agora_390x844@3x.png
//     --scale 3 --layout docs/design/medicao/inicio2/layout/layout_001b_inicio_lendo_agora.json --out build/visual_diff/t04
import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/widgets/neo_box.dart';
import 'package:app_leitura/core/preferences/brand_preference.dart';
import 'package:app_leitura/features/home/domain/models.dart';
import 'package:app_leitura/features/home/presentation/home_screen.dart';
import 'package:app_leitura/features/home/presentation/sections/also_reading_section.dart';
import 'package:app_leitura/features/home/presentation/sections/today_section.dart';
import 'package:app_leitura/features/reading_session/data/paper_book_source.dart';
import 'package:app_leitura/features/reading_session/domain/open_paper_session.dart';
import 'package:app_leitura/features/shell/presentation/main_shell.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import '../../fixtures/home_mock_repository.dart';
import '../../fixtures/paper_timer_fakes.dart';
import '../../fixtures/telas/inicio01b.dart';
import '../../reference/inicio2/referencias_inicio2.dart';
import '../../support/canvas.dart';
import '../../support/capture.dart';
import '../../support/fase_inicio.dart';
import '../../support/load_fonts.dart';

/// Os 5 ids que a 01b troca abaixo da dobra (Quincas Borba e O Cortiço no Para você — D-241).
const _trocados = {
  'i01b.forYou.item2.cover.title',
  'i01b.forYou.item2.title',
  'i01b.forYou.item3.cover.textBlock',
  'i01b.forYou.item3.cover.title',
  'i01b.forYou.item3.title',
};

/// Um livro de papel com título longo e capa gerada (sem foto) — a mini-barra com dados reais.
const PaperBook _ateneu = PaperBook(
  book: Book(
    id: 'o-ateneu',
    title: 'O Ateneu: crônica de saudades',
    author: 'Raul Pompeia',
    cover: PhotoCover(),
  ),
);

Future<void> _abrir(
  WidgetTester tester, {
  List<Override>? cronometro,
  ManualTicker? tique,
  List<Override> overrides = const [],
}) async {
  // outra árvore antes: o mesmo ProviderScope guardaria a sessão da abertura anterior
  await tester.pumpWidget(const SizedBox.shrink());
  await abrirInicio01(
    tester,
    prancha: kRef01b,
    safeTop: 47,
    safeBottom: 34,
    repositorio: const HomeMockRepository01b(),
    cronometro: cronometro ?? overridesDa01b(ticker: tique),
    overrides: overrides,
  );
}

/// O id da falha de geometria/texto (o prefixo antes de `.x`, `:` ou `[`), trocado pelo dos 5 quando é um deles.
String _idDaFalha(String f) => _trocados.firstWhere(
  (t) => f.startsWith('$t.') || f.startsWith('$t:') || f.startsWith('$t['),
  orElse: () => f,
);

void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'página 01b: os 272 ids da prancha (menos os 5 trocados do Para você) dentro da tolerância, na composição real',
    (tester) async {
      await _abrir(tester);
      expect(kRef01b.elements, hasLength(272));
      final falhas = geometria01(
        tester,
        kRef01b.sections.keys,
        prancha: kRef01b,
      );
      debugPrint(
        '[T04 página 01b] ${falhas.length} falhas, todas dos 5 trocados',
      );
      for (final f in falhas) {
        expect(_trocados, contains(_idDaFalha(f)), reason: f);
      }
    },
  );

  testWidgets(
    'página 01b: as linhas de texto de todos os ids (os 5 trocados à parte)',
    (tester) async {
      await _abrir(tester);
      final falhas = texto01(tester, kRef01b.sections.keys, prancha: kRef01b);
      for (final f in falhas) {
        expect(_trocados, contains(_idDaFalha(f)), reason: f);
      }
    },
  );

  testWidgets(
    'golden: a 01b inteira (1170 × 2532) — a captura `t04_01b` vai para o gate visual',
    (tester) async {
      await _abrir(tester);
      final image = await capturar01(tester, 't04_01b');
      expect((image.width, image.height), (1170, 2532));
      await expectLater(
        image,
        matchesGoldenFile('../../golden/goldens/inicio_01b@3x.png'),
      );
    },
  );

  testWidgets(
    'golden: a sessão pausada (D-257) — o play tinta, "EM PAUSA · PAPEL", o ponto #B9AE9C e o play com o aro no cartão',
    (tester) async {
      await _abrir(
        tester,
        cronometro: overridesDa01b(
          store: MemoryPaperTimerStore({
            donoDaSessao: TelaInicio01b.sessao.pause(TelaInicio01b.agora),
          }),
        ),
      );
      final image = await capturar01(tester, 't04_01b_pausada');
      await expectLater(
        image,
        matchesGoldenFile('../../golden/goldens/inicio_01b_pausada@3x.png'),
      );
    },
  );

  testWidgets(
    'golden: "1:08:42" com título longo e a capa gerada (R5, R10) — o tempo cresce e o título encolhe',
    (tester) async {
      await _abrir(
        tester,
        cronometro: overridesDaSessao(
          store: MemoryPaperTimerStore({
            donoDaSessao: OpenPaperSession.start(
              id: '01925a00-0000-7000-8000-0000000001b2',
              userBookId: _ateneu.book.id,
              now: TelaInicio01b.agora.subtract(
                const Duration(hours: 1, minutes: 8, seconds: 42),
              ),
            ),
          }),
          livros: FixedPaperBookSource({
            ...estanteDePapel01().livros,
            _ateneu.book.id: _ateneu,
          }),
        ),
      );
      expect(
        tester
            .widget<AppText>(find.byKey(const ValueKey('miniBar.time')))
            .span
            .toPlainText(),
        '1:08:42',
      );
      final image = await capturar01(tester, 't04_01b_hora');
      await expectLater(
        image,
        matchesGoldenFile('../../golden/goldens/inicio_01b_hora@3x.png'),
      );
    },
  );

  testWidgets(
    'o `brand` (D-33) pinta a barrinha da mini-barra — golden com o rosa `#FFC1C6`',
    (tester) async {
      await _abrir(tester);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(MainShell)),
      );
      const rosa = Color(0xFFFFC1C6);
      expect(AppColors.brandOptions, contains(rosa));
      await container.read(brandProvider.notifier).set(rosa);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<NeoBox>(find.byKey(const ValueKey('miniBar.progress')))
            .color,
        rosa,
      );
      final image = await capturar01(tester, 't04_01b_rosa');
      await expectLater(
        image,
        matchesGoldenFile('../../golden/goldens/inicio_01b_rosa@3x.png'),
      );
    },
  );

  testWidgets('desempenho: um tique refaz só o tique da mini-barra (o tempo, o rótulo e a barrinha) — nem a Início, nem o '
      'cartão, nem a capa, os textos e o botão da mini-barra', (tester) async {
    final tique = ManualTicker();
    await _abrir(tester, tique: tique);
    expect(tique.hasListener, isTrue);
    final refeitos = <String>[];
    debugOnRebuildDirtyWidget = (e, _) =>
        refeitos.add(e.widget.runtimeType.toString());
    try {
      tique.tick();
      await tester.pump(Duration.zero);
      await tester.pump();
    } finally {
      debugOnRebuildDirtyWidget = null;
    }
    expect(refeitos, contains('SecondTicking'));
    for (final fora in [
      '$HomeScreen',
      '$AlsoReadingSection',
      '$TodaySection',
      '$MainShell',
      '_BookCard',
      '_Cover',
      '_Texts',
      'BrasCubasWingsCover',
      'CircleIconButton',
      'SessionMiniBar',
    ]) {
      expect(refeitos, isNot(contains(fora)), reason: fora);
    }
    debugPrint('[T04 tique] ${refeitos.length} widgets refeitos: $refeitos');
  });

  testWidgets(
    'a raiz do golden e a captura: a 01b no aparelho (o canvas é a tela de 390 × 844)',
    (tester) async {
      await _abrir(tester);
      expect(kRef01b.canvas, const Size(390, 844));
      expect(find.byKey(goldenRootKey), findsOneWidget);
      expect(tester.getSize(find.byKey(goldenRootKey)), const Size(390, 844));
      final image = await captureAt(tester, find.byKey(goldenRootKey));
      expect((image.width, image.height), (1170, 2532));
    },
  );
}

// T03.12 — fase L01a7 (o ingresso do clube "Leitoras de Capitu") contra a prancha 01 (`kRef01`) e as larguras
// 360/430: o mesmo desenho, medidas e pintores da v1 (F09), com o subtítulo "Dom Casmurro · até o cap. 50" (D-241: o
// número do leitor e do clube). A seção não mudou de código: só os dados. Recorte do gate visual: y 1810,52–2119,12
// (`docs/design/fases/L01a7_clube.md`).
import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/features/home/domain/models.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fixtures/mundo_2026_09_20.dart';
import '../../fixtures/telas/inicio01.dart';
import '../../reference/inicio2/referencias_inicio2.dart';
import '../../reference/inicio2_larguras/referencias_inicio2_larguras.dart';
import '../../support/app_text_finder.dart';
import '../../support/fase_inicio.dart';
import '../../support/load_fonts.dart';

const _secoes = ['i01.club'];

Future<void> _abrir(WidgetTester tester, {LeitorRefPrancha prancha = kRef01}) =>
    abrirInicio01(tester, prancha: prancha);

void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'L01a7 geometria: os ${kRef01.idsOfSection('i01.club').length} ids do ingresso',
    (tester) async {
      await _abrir(tester);
      expect(idsDasSecoes(kRef01, _secoes), isNotEmpty);
      expect(geometria01(tester, _secoes), isEmpty);
    },
  );

  testWidgets('L01a7 texto: o título, "Dom Casmurro · até o cap. 50", o progresso, o CTA e a ponta nas baselines '
      'da prancha', (tester) async {
    await _abrir(tester);
    expect(texto01(tester, _secoes), isEmpty);
  });

  for (final tela in ['01w360', '01w430']) {
    testWidgets(
      'L01a7 a ${tela.substring(3)} px: geometria e texto da prancha medida nessa largura',
      (tester) async {
        final ref = kRefInicio2Larguras[tela]!;
        await _abrir(tester, prancha: ref);
        expect(geometria01(tester, _secoes, prancha: ref), isEmpty);
        expect(texto01(tester, _secoes, prancha: ref), isEmpty);
      },
    );
  }

  testWidgets(
    'L01a7 dados: o clube até o cap. 50 — a meta do mundo de referência (D-241), não o 100 da v1',
    (tester) async {
      await _abrir(tester);
      final clube = TelaInicio01.snapshot(TelaInicio01.agora).club!;
      expect(clube.untilChapter, mundoReferencia.clube.metaCapitulo);
      expect(clube.untilChapter, 50);
      expect(findAppText('Dom Casmurro · até o cap. 50'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) => w is AppText && w.span.toPlainText().contains('cap. 100'),
        ),
        findsNothing,
      );
    },
  );

  testWidgets('L01a7 semântica: a seção, os rótulos do arquivo (participantes, progresso do grupo 54 %, "Você", '
      'mensagens novas e o encontro) e os decorativos fora', (tester) async {
    final semantics = tester.ensureSemantics();
    await _abrir(tester);
    expect(find.semantics.byLabel('Seu clube do livro'), findsAtLeast(1));
    expect(noDe(tester, 'i01.club.avatars').label, '11 participantes');
    final barra = noDe(tester, 'i01.club.progressBar').getSemanticsData();
    expect((barra.label, barra.value), ('Progresso do grupo', '54%'));
    expect(noDe(tester, 'i01.club.youMarker').label, 'Você');
    expect(noDe(tester, 'i01.club.cta.badge').label, '3 mensagens novas');
    expect(
      find.semantics.byLabel(
        'Próximo encontro: quinta, 24 de setembro, às 20h',
      ),
      findsOneWidget,
    );
    for (final id in [
      'i01.club.notchTop',
      'i01.club.notchBottom',
      'i01.club.cta.icon',
    ]) {
      expect(
        find
                .descendant(
                  of: ini(id),
                  matching: find.byType(ExcludeSemantics),
                  matchRoot: true,
                )
                .evaluate()
                .isNotEmpty ||
            find
                .ancestor(of: ini(id), matching: find.byType(ExcludeSemantics))
                .evaluate()
                .isNotEmpty,
        isTrue,
        reason: id,
      );
    }
    final cta = linksDaSecao('Seu clube do livro');
    expect(cta, hasLength(1));
    expect(
      cta.single.getSemanticsData().hasAction(SemanticsAction.tap),
      isTrue,
    );
    semantics.dispose();
  });

  testWidgets('L01a7 toque no CTA: abre a discussão do clube (como na v1)', (
    tester,
  ) async {
    await _abrir(tester);
    await tocar01(tester, 'i01.club.cta');
    expect(rotaAtual(tester), '/clube/${mundoReferencia.clube.id}/discussao');
  });

  testWidgets(
    'L01a7 o clube é o da fixture t01 (a mesma instância do instantâneo)',
    (tester) async {
      expect(TelaInicio01.snapshot(TelaInicio01.agora).club, isA<BookClub>());
    },
  );

  testWidgets(
    'L01a7 captura: a seção no canvas da prancha (gate visual fora do teste)',
    (tester) async {
      await _abrir(tester);
      final image = await capturar01(tester, 't03_L01a7');
      expect((image.width, image.height), (1170, 7950));
    },
  );
}

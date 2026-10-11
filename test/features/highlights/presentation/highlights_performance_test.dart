// G19.9 — desempenho da tela 25: com 2.000 grifos no livro, a lista abre e rola sem montar todos os cartões (a
// `SliverList` constrói sob demanda) — conta-se os cartões montados na abertura e depois de rolar até o fim.
import 'package:app_leitura/core/data/database/daos/annotation_daos.dart';
import 'package:app_leitura/core/data/model/record_meta.dart';
import 'package:app_leitura/features/highlights/presentation/highlight_card.dart';
import 'package:app_leitura/features/reader/annotations/domain/annotation.dart';
import 'package:app_leitura/features/reader/domain/locator.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fixtures/mundo_2026_09_20.dart';
import '../../../support/dados_t25.dart';
import '../../../support/fase_l25.dart';
import '../../../support/load_fonts.dart';

/// Um UUID v7 de teste com o número [n] no fim.
String _id(int n) =>
    '01a06980-2180-7fad-8c24-${n.toRadixString(16).padLeft(12, '0')}';

void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    '2.000 grifos: a lista monta só os cartões perto da tela, na abertura e no fim',
    (tester) async {
      final livro = await livroDaTela25(comAnotacoes: false);
      addTearDown(livro.close);
      final base = mundoReferencia.anotacoes.firstWhere(
        (a) => a.refPage == 3 && a.kind == AnnotationKind.highlight,
      );
      final ancora = base.anchor as EpubAnchor;
      await tester.runAsync(() async {
        final dao = AnnotationsDao(livro.db);
        await livro.db.transaction(() async {
          for (var i = 0; i < 2000; i++) {
            final id = _id(i + 1);
            await dao.upsert(
              Annotation(
                id: id,
                meta: RecordMeta(
                  userId: base.meta.userId,
                  createdAt: base.meta.createdAt.add(Duration(minutes: i)),
                  updatedAt: base.meta.createdAt.add(Duration(minutes: i)),
                  version: base.meta.version,
                ),
                userBookId: livro.userBookId,
                kind: AnnotationKind.highlight,
                groupId: id,
                source: AnnotationSource.selection,
                anchor: EpubAnchor(
                  sha: ancora.sha,
                  spine: ancora.spine,
                  start: ancora.start,
                  end: ancora.end,
                  quote: ancora.quote,
                  refPage: 3 + i ~/ 4,
                ),
                refPage: 3 + i ~/ 4,
                chapterIndex: base.chapterIndex,
                color: '#FED170',
                style: HighlightStyle.fill,
                fillHeight: FillHeight.medium,
              ),
            );
          }
        });
      });
      await abrirTela25(tester, livro, tela: const Size(390, 844));
      final abertos = find.byType(HighlightCardView).evaluate().length;
      expect(abertos, inInclusiveRange(1, 20));
      for (var i = 0; i < 40; i++) {
        await tester.fling(hl('hl.scroll'), const Offset(0, -3000), 8000);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
      }
      await tester.pumpAndSettle();
      final noMeio = find.byType(HighlightCardView).evaluate().length;
      expect(noMeio, inInclusiveRange(1, 20));
      // até o fim da lista: o último cartão e o fim montados, ainda sem os outros
      final rolagem = tester
          .state<ScrollableState>(
            find
                .descendant(
                  of: hl('hl.scroll'),
                  matching: find.byType(Scrollable),
                )
                .first,
          )
          .position;
      for (var i = 0; i < 20 && hl('hl.end').evaluate().isEmpty; i++) {
        rolagem.jumpTo(rolagem.maxScrollExtent);
        await tester.pump();
      }
      expect(hl('hl.end'), findsOneWidget);
      expect(hl('hl.list.card2000'), findsOneWidget);
      expect(
        find.byType(HighlightCardView).evaluate().length,
        inInclusiveRange(1, 20),
      );
    },
  );
}

// G13.5 — o mundo da tela 21 no banco do leitor (D-34): o Dom Casmurro do mundo na pág. 159 e as anotações do mundo
// da 21 (o grifo de seleção amarelo em "aqueles olhos de Capitu"; sem tinta), gravadas como estão no mundo (a âncora
// é de outro arquivo: o leitor acha o lugar pela citação). A seleção da prancha é feita com os gestos de verdade:
// pressão longa em "como" e a alça final arrastada até o ponto de "ressaca.".
import 'package:app_leitura/core/data/database/daos/annotation_daos.dart';
import 'package:app_leitura/core/data/database/daos/reader_daos.dart';
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:app_leitura/features/reader/layout/page_snapshot.dart';
import 'package:app_leitura/features/reader/presentation/reader_page_view.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/mundo_2026_09_20.dart';
import '../fixtures/telas/indice_t19.dart';
import '../fixtures/telas/instantaneo.dart' show mundoDaTela21;
import '../fixtures/telas/t21.dart';
import 'canvas.dart';
import 'dados_t20.dart';
import 'mundo_epub.dart';
import 'pump_reader.dart';
import 'reader_harness.dart';

/// O Dom Casmurro da tela 21 na estante da conta do mundo, no papel [papel].
Future<LivroNaEstante> livroDaTela21({
  ReaderPaper papel = ReaderPaper.creme,
}) async {
  final m = mundoDaTela21;
  final livro = await LivroNaEstante.epubDe(
    mundoEpub(Slugs.domCasmurro, completo: true),
    livro: m.domCasmurro,
    leitor: m.usuarioId,
  );
  await livro.usarIndice(indiceDaTela19(livro.index));
  await livro.guardarPosicao(itemDaPagina159, 0);
  for (final a in m.anotacoes) {
    await AnnotationsDao(livro.db).upsert(a);
  }
  await ReaderSettingsDao(livro.db).upsert(m.ajustes.copyWith(paper: papel));
  return livro;
}

/// A página do EPUB na tela.
PageSnapshot paginaNaTela(WidgetTester tester) =>
    tester.widget<ReaderPageView>(find.byType(ReaderPageView)).document.current
        as PageSnapshot;

/// Abre a tela 21: o leitor na pág. 159 e a seleção de `t21.selecao` feita com os gestos (pressão longa em "como"
/// e a alça final arrastada até o ponto final, pelo ponto da alça na linha).
Future<LeitorNaTela> abrirTela21(
  WidgetTester tester,
  LivroNaEstante livro, {
  bool golden = false,
}) async {
  setCanvasView(tester, logical: const Size(390, 844));
  final t = await abrirLeitor(
    tester,
    livro,
    golden: golden,
    deps: (t) => depsDaTela20(t, livro),
  );
  // o grifo do mundo é relido do banco
  for (var i = 0; i < 3; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 16));
  }
  final p = paginaNaTela(tester);
  final sel = t21.selecao!;
  final a = p.item.text.indexOf(sel.texto);
  final z = a + sel.texto.length;
  final como = p.boxesOf(p.spine, a, a + 4).first;
  await tester.longPressAt(como.rect.center);
  await tester.pump(const Duration(milliseconds: 50));
  // o dedo pega a bolinha, mas quem anda é o ponto da alça na linha (a borda, no meio da linha)
  final bolinha = tester.getCenter(
    find.byKey(const ValueKey('r21.page.text.handleEnd.knob')),
  );
  final alca = Offset(como.rect.right, como.rect.center.dy);
  final ponto = p.boxesOf(p.spine, z - 1, z).single.rect.center;
  final g = await tester.startGesture(bolinha);
  await g.moveTo(bolinha + (ponto - alca));
  await tester.pump();
  await g.up();
  for (var i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
  return t;
}

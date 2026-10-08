// G18 — o Espaço e a nota à mão pela tela inteira, no mundo das telas 23/24 (a pág. 159 do Dom Casmurro com os
// trechos da D-160): o Espaço fica ativo (R4); arrastar 3 linhas a partir da fresta de "Vá, de ressaca." mostra o
// abridor e o texto de baixo desce sem recuo (R3); o que passa do pé da tela fica escondido; ao soltar, a caixa da
// 24b e a Caneta (D-187); o Concluir sem escrever não grava nada (D-188).
import 'package:app_leitura/core/data/database/daos/annotation_daos.dart';
import 'package:app_leitura/features/reader/annotations/ink/ink_geometry.dart';
import 'package:app_leitura/features/reader/application/annotation_session.dart';
import 'package:app_leitura/features/reader/presentation/annotation_mode.dart';
import 'package:app_leitura/features/reader/presentation/space_opener.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/canvas.dart';
import '../../../support/dados_t20.dart' show depsDaTela20;
import '../../../support/dados_t22.dart';
import '../../../support/dados_t23.dart';
import '../../../support/load_fonts.dart';
import '../../../support/pump_reader.dart';
import '../../../support/reader_harness.dart';

Finder _key(String k) => find.byKey(ValueKey<String>(k));

Future<void> _quadros(WidgetTester tester, [int n = 30]) async {
  for (var i = 0; i < n; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

AnnotationSession _sessao(WidgetTester tester) =>
    tester.widget<AnnotationMode>(find.byType(AnnotationMode)).session;

/// O texto da linha [l] da página da sessão (os trechos da D-160 com espaço comum).
String _texto(AnnotationSession s, InkLine l) =>
    s.anchors.textOf(l.unit)!.substring(l.from, l.to).replaceAll(' ', ' ');

/// A linha da página da sessão que começa com [inicio].
InkLine _linha(AnnotationSession s, String inicio) =>
    s.geometry.lines.firstWhere((l) => _texto(s, l).startsWith(inicio));

void main() {
  setUpAll(loadAppFonts);

  late LivroNaEstante livro;
  setUp(() async => livro = await livroDaTela23());
  tearDown(() async => livro.close());

  /// O leitor na pág. 159, o modo anotação e o Espaço.
  Future<AnnotationSession> espaco(WidgetTester tester) async {
    setCanvasView(tester, logical: const Size(390, 844));
    await precacheTela23(tester);
    await abrirLeitor(tester, livro, deps: (t) => depsDaTela20(t, livro));
    await esperarBancoL22(tester);
    await entrarNoModoAnotacao(tester);
    await tester.tap(_key('ann.toolShelf.space'));
    await tester.pump();
    final s = _sessao(tester);
    expect(s.tool, AnnotationTool.space);
    expect(find.text('Chega numa próxima fase'), findsNothing);
    return s;
  }

  testWidgets(
    'arrastar 3 linhas na fresta de "Vá, de ressaca.": o abridor e o texto de baixo a 546,08 sem recuo; soltar: a '
    'caixa da 24b e a Caneta; Concluir sem escrever não grava (D-188)',
    (tester) async {
      final s = await espaco(tester);
      // a fresta: a base da linha de "Vá, de ressaca." (na tela, 30 abaixo do leitor limpo)
      final fresta = _linha(s, 'Olhos de ressaca? Vá, de ressaca.').bottom + 30;
      expect(fresta, closeTo(404.08, 0.5));
      final topo = fresta + 14;
      final l = s.geometry.lineHeight;
      final g = await tester.startGesture(Offset(221.72, fresta + 2));
      await g.moveTo(
        Offset(221.72, fresta + 20),
        timeStamp: const Duration(milliseconds: 8),
      );
      await g.moveTo(
        Offset(221.72, topo + 3 * l - 2),
        timeStamp: const Duration(milliseconds: 16),
      );
      await tester.pump();
      // o abridor da 24: a área, 3 linhas
      final abridor = tester.widget<SpaceOpener>(find.byType(SpaceOpener));
      expect(abridor.lines, 3);
      final area = tester.getRect(_key('ann.page.spaceOpener'));
      expect(area.top, closeTo(418.08, 0.5));
      expect(area.height, closeTo(104, 0.5));
      // "É o que me dá ideia…" desce, sem recuo
      final e = _linha(s, 'É o que me dá ideia');
      expect(e.top + 30, closeTo(546.08, 0.5));
      expect(e.left, closeTo(28, 0.01));
      // o que passa do pé da tela fica escondido: a página vai até a linha cortada pelo pé
      expect(s.geometry.lines.last.top + 30, lessThan(844));
      expect(
        s.geometry.lines.any(
          (x) => _texto(s, x).startsWith('arrastado, agarrei-me'),
        ),
        isTrue,
      );
      await g.up();
      await tester.pump();
      expect(find.byType(SpaceOpener), findsNothing);
      final nota = s.notes.single;
      expect((nota.lines, nota.collapsed), (3, false));
      expect(s.tool, AnnotationTool.pen);
      final caixa = s.noteBox(nota.id)!.shift(const Offset(0, 30));
      expect(caixa.top, closeTo(434.08, 0.5));
      expect(caixa.height, 150);
      // Concluir sem escrever: nada vai ao banco (D-188)
      await tester.tap(_key('ann.done'));
      await esperarBancoL22(tester);
      await _quadros(tester);
      expect(find.byType(AnnotationMode), findsNothing);
      final espacos = await tester.runAsync(
        () => InkLayersDao(livro.db).liveSpacesForBook(livro.book.id),
      );
      expect(espacos, isEmpty);
    },
  );
}

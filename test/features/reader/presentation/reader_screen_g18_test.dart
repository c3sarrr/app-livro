// G18 — o Espaço e a nota à mão pela tela inteira, no mundo das telas 23/24 (a pág. 159 do Dom Casmurro com os
// trechos da D-160): o Espaço fica ativo (R4); arrastar 3 linhas a partir da fresta de "Vá, de ressaca." mostra o
// abridor e o texto de baixo desce sem recuo (R3); o que passa do pé da tela fica escondido; ao soltar, a caixa da
// 24b e a Caneta (D-187); o Concluir sem escrever não grava nada (D-188). G18.5: com tinta, o Concluir grava e o
// leitor limpo repagina com a caixa (R11); recolhida, a faixa aparece e abre com um toque (D-184). G18.6: a alça para
// na tinta e cresce (D-186), recolher e abrir, apagar com a pílula e o Desfazer (D-185); o Voltar grava como o Concluir
// (D-42); o rascunho guardado traz a nota (D-166); a nota que não cabe vai inteira para a página seguinte (R12); Noite.
// O teto de 256 KiB avisa na pílula por 2 s (D-191). Abrir o livro com a nota no capítulo: a 1ª página já sai com a
// caixa e a tinta que chega depois não repagina; sem a nota, repagina; o modo anotação espera (revisão 7).
import 'dart:async';

import 'package:app_leitura/core/data/database/daos/annotation_daos.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/features/reader/annotations/ink/gesture_arbiter.dart';
import 'package:app_leitura/features/reader/annotations/ink/ink_changes.dart';
import 'package:app_leitura/features/reader/annotations/ink_repository.dart';
import 'package:app_leitura/features/reader/annotations/ink/ink_geometry.dart';
import 'package:app_leitura/features/reader/annotations/space/space_metrics.dart';
import 'package:app_leitura/features/reader/application/annotation_session.dart';
import 'package:app_leitura/features/reader/application/reader_document.dart';
import 'package:app_leitura/features/reader/application/reader_ink.dart'
    show InkSource;
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:app_leitura/features/reader/layout/page_snapshot.dart';
import 'package:app_leitura/features/reader/layout/paginator.dart';
import 'package:app_leitura/features/reader/presentation/annotation_mode.dart';
import 'package:app_leitura/features/reader/presentation/reader_page_view.dart';
import 'package:app_leitura/features/reader/presentation/space_opener.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fixtures/mundo_2026_09_20.dart' show mundoReferencia;
import '../../../support/app_text_finder.dart';
import '../../../support/canvas.dart';
import '../../../support/dados_t20.dart' show depsDaTela20;
import '../../../support/dados_t22.dart';
import '../../../support/dados_t23.dart';
import '../../../support/dados_t24.dart';
import '../../../support/load_fonts.dart';
import '../../../support/pump_reader.dart';
import '../../../support/reader_harness.dart';

Finder _key(String k) => find.byKey(ValueKey<String>(k));

Future<void> _quadros(WidgetTester tester, [int n = 30]) async {
  for (var i = 0; i < n; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

ReaderDocument _doc(WidgetTester tester) =>
    tester.widget<ReaderPageView>(find.byType(ReaderPageView)).document;

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

  testWidgets('Concluir com tinta grava a nota; o leitor limpo repagina com ela (R11); recolhida, a faixa "Abrir a nota à mão" '
      'abre com um toque (D-184)', (tester) async {
    final s = await espaco(tester);
    final fresta = _linha(s, 'Olhos de ressaca? Vá, de ressaca.').bottom + 30;
    final l = s.geometry.lineHeight;
    await tracarL22(tester, [
      Offset(221.72, fresta + 2),
      Offset(221.72, fresta + 20),
      Offset(221.72, fresta + 14 + 3 * l - 2),
    ]);
    final nota = s.notes.single;
    final caixa = s.noteBox(nota.id)!.shift(const Offset(0, 30));
    // escrever na caixa (a Caneta voltou — D-187)
    await tracarL22(tester, [
      Offset(80, caixa.top + 40),
      Offset(140, caixa.top + 44),
      Offset(200, caixa.top + 42),
    ]);
    expect(s.notes.single.strokes, hasLength(1));
    await tester.tap(_key('ann.page.handNote.actions.collapse'));
    await tester.pump();
    expect(s.notes.single.collapsed, isTrue);
    await tester.tap(_key('ann.done'));
    await esperarBancoL22(tester);
    await _quadros(tester);
    expect(find.byType(AnnotationMode), findsNothing);
    final gravadas = await tester.runAsync(
      () => InkLayersDao(livro.db).liveSpacesForBook(livro.book.id),
    );
    expect(gravadas!.single.collapsed, isTrue);
    // o leitor limpo: a faixa no lugar do espaço
    await esperarBancoL22(tester);
    await _quadros(tester);
    final faixa = spacesOf(_doc(tester).current)
        .singleWhere((x) => x.id == nota.id);
    expect(faixa.rect.height, closeTo(stripFlowHeight(l), 1e-3));
    final h = tester.ensureSemantics();
    expect(find.bySemanticsLabel('Abrir a nota à mão'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Nota à mão, depois de “Vá, de ressaca.”'),
      findsOneWidget,
    );
    h.dispose();
    // um toque na faixa abre e grava; o capítulo repagina com a caixa
    await tester.tapAt(faixa.rect.center);
    await esperarBancoL22(tester);
    await _quadros(tester);
    final aberta = spacesOf(_doc(tester).current)
        .singleWhere((x) => x.id == nota.id);
    expect(aberta.rect.height, closeTo(noteFlowHeight(3), 1e-3));
    final depois = await tester.runAsync(
      () => InkLayersDao(livro.db).liveSpacesForBook(livro.book.id),
    );
    expect(depois!.single.collapsed, isFalse);
    final h2 = tester.ensureSemantics();
    expect(find.bySemanticsLabel('Abrir a nota à mão'), findsNothing);
    expect(
      find.bySemanticsLabel(RegExp(r'^Nota à mão, \d+ de ')),
      findsOneWidget,
    );
    h2.dispose();
  });

  testWidgets(
    'a tela 24 pelo mundo (R15): o Espaço e o dedo parado 3 linhas abaixo da fresta',
    (tester) async {
      final (_, dedo) = await abrirTela24(tester, livro);
      final s = sessaoNaTela(tester);
      expect(s.tool, AnnotationTool.space);
      expect(s.opening.value!.lines, 3);
      expect(
        tester.getRect(_key('ann.page.spaceOpener')).top,
        closeTo(418.08, 0.5),
      );
      await dedo.up();
      await tester.pump();
      expect(s.notes.single.lines, 3);
    },
  );

  testWidgets(
    'a tela 24b pelo mundo (R15): a nota salva de 3 linhas, com a tinta do arquivo, e a Caneta',
    (tester) async {
      final mundo = await livroDaTela24b();
      addTearDown(mundo.close);
      await abrirTela24b(tester, mundo);
      final s = sessaoNaTela(tester);
      final nota = s.notes.single;
      expect((nota.lines, nota.collapsed), (3, false));
      expect(nota.strokes, isNotEmpty);
      expect(
        tester.getRect(_key('ann.page.handNote')).top,
        closeTo(434.08, 0.5),
      );
      expect(tester.getRect(_key('ann.page.handNote')).height, 150);
    },
  );

  /// Abre uma nota de 3 linhas na fresta da linha [l] (coordenadas da sessão) e escreve nela pela sessão (o caminho do
  /// dedo, sem depender do que está por cima da página na tela).
  Future<SessionNoteRef> notaComTinta(
    WidgetTester tester,
    AnnotationSession s,
    InkLine l,
  ) async {
    final fresta = l.bottom + s.textShift;
    await tracarL22(tester, [
      Offset(dedoDaTela24, fresta + 2),
      Offset(dedoDaTela24, fresta + 20),
      Offset(dedoDaTela24, fresta + 14 + 3 * s.geometry.lineHeight - 2),
    ]);
    final nota = s.notes.single;
    final caixa = s.noteBox(nota.id)!;
    InkPointer dedo(double x, double y, int t) => (
      id: 9,
      kind: InkPointerKind.touch,
      x: x,
      y: y + s.textShift,
      pressure: 1,
      tMs: t,
    );
    s
      ..pointerDown(dedo(80, caixa.top + 40, 0))
      ..pointerMove(dedo(140, caixa.top + 44, 8))
      ..pointerUp(dedo(200, caixa.top + 42, 16));
    await tester.pump();
    expect(s.notes.single.strokes, hasLength(1));
    return (id: nota.id, at: nota.at);
  }

  testWidgets(
    'a alça para na tinta e cresce (D-186); recolher e abrir; apagar com a pílula e o Desfazer (D-185)',
    (tester) async {
      final mundo = await livroDaTela24b();
      addTearDown(mundo.close);
      await abrirTela24b(tester, mundo);
      final s = sessaoNaTela(tester);
      final id = s.notes.single.id;
      // a tinta da 24b desce até a 2ª pauta: a alça não sobe de 3 linhas
      Future<void> alca(double dy) async {
        final g = await tester.startGesture(
          tester.getCenter(_key('ann.page.handNote.handle')),
        );
        await g.moveBy(Offset(0, dy.sign * 20));
        await g.moveBy(Offset(0, dy - dy.sign * 20));
        await tester.pump();
        await g.up();
        await tester.pump();
      }

      await alca(-84);
      expect(s.notes.single.lines, 3);
      await alca(84);
      expect(s.notes.single.lines, 5);
      expect(tester.getRect(_key('ann.page.handNote')).height, 42 * 5 + 24);
      // "É o que…" desceu as 2 linhas da caixa
      expect(
        _linha(s, 'É o que me dá ideia').top + 30,
        closeTo(546.08 + 64 + 84, 0.5),
      );
      // recolher e abrir
      await tester.tap(_key('ann.page.handNote.actions.collapse'));
      await tester.pump();
      expect(s.notes.single.collapsed, isTrue);
      await tester.tap(_key('ann.page.handNote.open'));
      await tester.pump();
      expect(s.notes.single.collapsed, isFalse);
      // apagar: some na hora, a pílula "Nota apagada · Desfazer"; Desfazer volta
      await tester.tap(_key('ann.page.handNote.actions.delete'));
      await tester.pump();
      expect(s.notes, isEmpty);
      expect(_key('leitor.desfazer'), findsOneWidget);
      await tester.tap(_key('leitor.desfazer.botao'));
      await tester.pump();
      expect(s.notes.single.id, id);
      expect(_key('leitor.desfazer'), findsNothing);
    },
  );

  testWidgets('o teto de 256 KiB (D-191): "A nota está cheia" e "Seleção grande demais para mover" na pílula acima da prateleira, '
      'por 2 s; o leitor de tela lê', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(accessibleNavigation: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    final mundo = await livroDaTela24b();
    addTearDown(mundo.close);
    await abrirTela24b(tester, mundo);
    final s = sessaoNaTela(tester);
    tester.takeAnnouncements();
    for (final (motivo, texto) in const [
      (InkRefusal.noteFull, 'A nota está cheia'),
      (InkRefusal.selectionTooBig, 'Seleção grande demais para mover'),
    ]) {
      s.onRefused!(motivo);
      await tester.pump();
      expect(findAppText(texto), findsOneWidget, reason: texto);
      expect(tester.takeAnnouncements().map((a) => a.message), [texto]);
      final aviso = tester.getRect(_key('leitor.aviso'));
      expect(aviso.center.dx, closeTo(195, 0.01));
      expect(
        aviso.bottom,
        closeTo(tester.getRect(_key('ann.toolShelf')).top - 12 - 12, 0.01),
      );
      await tester.pump(const Duration(milliseconds: 1900));
      expect(findAppText(texto), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 100));
      expect(findAppText(texto), findsNothing, reason: '2 s');
    }
  });

  /// O leitor no mundo da 24b (a nota à mão na pág. 159) com a tinta do leitor demorando a chegar.
  Future<_TintaDemorada> comTintaDemorada(WidgetTester tester) async {
    final mundo = await livroDaTela24b();
    addTearDown(mundo.close);
    final tinta = _TintaDemorada(
      DriftInkRepository(
        mundo.db,
        mundo.versioning,
        now: () => mundoReferencia.agora,
      ),
    );
    setCanvasView(tester, logical: const Size(390, 844));
    await precacheTela24(tester);
    await abrirLeitor(
      tester,
      mundo,
      deps: (t) => depsDaTela20(t, mundo, ink: tinta),
    );
    await esperarBancoL22(tester);
    expect(tinta.esperando, isTrue, reason: 'a tinta do leitor ainda chega');
    return tinta;
  }

  /// A página do layout (cada leitura de `current` embrulha a mesma): repaginar faz outra.
  ReaderPage folha(WidgetTester tester) =>
      (_doc(tester).current as PageSnapshot).page;

  /// O capítulo assentado (a página do cache vira a do layout completo): a mesma página por 3 voltas.
  Future<ReaderPage> assentada(WidgetTester tester) async {
    var p = folha(tester);
    var iguais = 0;
    for (var i = 0; iguais < 3 && i < 40; i++) {
      await esperarBancoL22(tester);
      final q = folha(tester);
      iguais = identical(p, q) ? iguais + 1 : 0;
      p = q;
    }
    expect(iguais, 3, reason: 'o capítulo assenta');
    return p;
  }

  InkSource tintaNaTela(WidgetTester tester) =>
      tester.widget<ReaderPageView>(find.byType(ReaderPageView)).ink!;

  testWidgets(
    'abrir o livro com a nota no capítulo (revisão 7): a 1ª página já sai com a caixa e os desenhos, mesmo com a tinta '
    'ainda chegando (e repaginar no meio não tira o espaço); quando a tinta chega com as mesmas notas, nada repagina',
    (tester) async {
      final tinta = await comTintaDemorada(tester);
      final atual = _doc(tester).current;
      expect(spacesOf(atual), hasLength(1));
      expect(tintaNaTela(tester).notesOn(atual), hasLength(1));
      expect(tintaNaTela(tester).drawingsOn(atual), isNotEmpty);
      // repaginar com a tinta ainda chegando: os espaços com que o livro abriu ficam
      await tester.runAsync(() => (_doc(tester) as SpacedDocument).respace());
      final pagina = await assentada(tester);
      expect(spacesOf(_doc(tester).current), hasLength(1));
      tinta.soltar();
      await esperarBancoL22(tester);
      expect(tinta.esperando, isFalse);
      expect(
        identical(await assentada(tester), pagina),
        isTrue,
        reason: 'as mesmas notas: o livro não repagina',
      );
      expect(spacesOf(_doc(tester).current), hasLength(1));
      expect(tintaNaTela(tester).notesOn(_doc(tester).current), hasLength(1));
    },
  );

  testWidgets(
    'a tinta do leitor chega sem a nota (o rascunho a apagou ao abrir — D-166): o livro repagina sem o espaço',
    (tester) async {
      final tinta = await comTintaDemorada(tester);
      expect(spacesOf(_doc(tester).current), hasLength(1));
      tinta
        ..vazia = true
        ..soltar();
      await assentada(tester);
      expect(spacesOf(_doc(tester).current), isEmpty);
      expect(tintaNaTela(tester).notesOn(_doc(tester).current), isEmpty);
    },
  );

  testWidgets(
    'o modo anotação pedido com a tinta ainda chegando espera por ela e pela repaginação: abre na página nova',
    (tester) async {
      final tinta = await comTintaDemorada(tester);
      await entrarNoModoAnotacao(tester);
      expect(find.byType(AnnotationMode), findsNothing, reason: 'espera');
      tinta
        ..vazia = true
        ..soltar();
      for (
        var i = 0;
        i < 40 && find.byType(AnnotationMode).evaluate().isEmpty;
        i++
      ) {
        await esperarBancoL22(tester);
      }
      await _quadros(tester);
      final s = sessaoNaTela(tester);
      expect(s.notes, isEmpty);
      expect(spacesOf(_doc(tester).current), isEmpty);
      expect(spacesOf(s.page!), isEmpty);
    },
  );

  testWidgets('a tinta que muda no banco enquanto o modo anotação abre (depois da 1ª leitura dela) só repagina o livro depois '
      'que ele sai', (tester) async {
    final mundo = await livroDaTela24b();
    addTearDown(mundo.close);
    // a próxima pergunta pela conta espera (o modo para no meio da abertura)
    Completer<void>? portao;
    setCanvasView(tester, logical: const Size(390, 844));
    await precacheTela24(tester);
    await abrirLeitor(
      tester,
      mundo,
      deps: (t) => depsDaTela20(
        t,
        mundo,
        owner: () async {
          final p = portao;
          if (p != null) {
            portao = null;
            await p.future;
          }
          return mundo.leitor;
        },
      ),
    );
    await esperarBancoL22(tester);
    final nota = spacesOf(_doc(tester).current).single;
    double altura() => spacesOf(_doc(tester).current).single.rect.height;
    await tester.tapAt(const Offset(195, 420));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    await _quadros(tester, 6);
    final segurar = portao = Completer<void>();
    await tester.tap(_key('r20.bottomIsland.tools.annotate'));
    await esperarBancoL22(tester);
    expect(find.byType(AnnotationMode), findsNothing);
    expect(portao, isNull, reason: 'o modo parou na conta');
    // outro aparelho recolhe a nota
    await tester.runAsync(
      () => DriftInkRepository(
        mundo.db,
        mundo.versioning,
        now: () => mundoReferencia.agora,
      ).setCollapsed(mundo.leitor, nota.id, true),
    );
    await esperarBancoL22(tester);
    expect(altura(), nota.rect.height, reason: 'espera o modo sair');
    segurar.complete();
    for (
      var i = 0;
      i < 40 && find.byType(AnnotationMode).evaluate().isEmpty;
      i++
    ) {
      await esperarBancoL22(tester);
    }
    await _quadros(tester);
    expect(find.byType(AnnotationMode), findsOneWidget);
    expect(altura(), nota.rect.height);
    // ao sair, repagina com a faixa
    await tester.tap(_key('ann.done'));
    for (var i = 0; i < 2; i++) {
      await esperarBancoL22(tester);
      await _quadros(tester);
    }
    expect(find.byType(AnnotationMode), findsNothing);
    expect(
      altura(),
      closeTo(
        stripFlowHeight(
          (_doc(tester).current as PageSnapshot).typography.lineHeight,
        ),
        0.01,
      ),
    );
  });

  testWidgets('o Voltar grava a nota como o Concluir (D-42)', (tester) async {
    final s = await espaco(tester);
    final nota = await notaComTinta(
      tester,
      s,
      _linha(s, 'Olhos de ressaca? Vá, de ressaca.'),
    );
    await tester.binding.handlePopRoute();
    await esperarBancoL22(tester);
    await _quadros(tester);
    expect(find.byType(AnnotationMode), findsNothing);
    final gravadas = await tester.runAsync(
      () => InkLayersDao(livro.db).liveSpacesForBook(livro.book.id),
    );
    expect(gravadas!.single.id, nota.id);
  });

  testWidgets(
    'o rascunho a cada 5 s traz a nota; "matar" o app e reabrir grava (D-166)',
    (tester) async {
      final s = await espaco(tester);
      final nota = await notaComTinta(
        tester,
        s,
        _linha(s, 'Olhos de ressaca? Vá, de ressaca.'),
      );
      final repo = DriftInkRepository(livro.db, livro.versioning);
      Future<List<InkChanges>?> rascunho() =>
          tester.runAsync(() => repo.draftsOf(livro.leitor, livro.userBookId));
      await tester.pump(inkDraftEvery);
      await esperarBancoL22(tester);
      final guardado = await rascunho();
      expect(guardado!.single.notes.single.layerId, nota.id);
      // o app morre e o livro é aberto de novo: o rascunho é gravado
      await tester.pumpWidget(const SizedBox.shrink());
      await esperarBancoL22(tester);
      await abrirLeitor(tester, livro, deps: (t) => depsDaTela20(t, livro));
      await esperarBancoL22(tester);
      await _quadros(tester);
      final gravadas = await tester.runAsync(
        () => InkLayersDao(livro.db).liveSpacesForBook(livro.book.id),
      );
      expect(gravadas!.single.id, nota.id);
      expect(await rascunho(), isEmpty);
      // e o leitor limpo abre o espaço dela
      expect(
        spacesOf(_doc(tester).current).map((x) => x.id),
        contains(nota.id),
      );
    },
  );

  testWidgets(
    'R12: a nota que não cabe no resto da página vai inteira para a seguinte; a de cima acaba na âncora',
    (tester) async {
      final s = await espaco(tester);
      final limpo = _doc(tester).current as PageSnapshot;
      final fundo = limpo.typography.topInset + limpo.typography.contentHeight;
      // a última linha com a fresta acima da prateleira (no modo, onde o dedo começa) cuja caixa (206) não cabe até o
      // pé da página limpa
      final l = s.geometry.lines.lastWhere(
        (x) =>
            x.bottom + s.textShift + 2 < 660 &&
            x.bottom + noteFlowHeight(3) > fundo,
      );
      final nota = await notaComTinta(tester, s, l);
      await tester.tap(_key('ann.done'));
      await esperarBancoL22(tester);
      await _quadros(tester);
      await esperarBancoL22(tester);
      await _quadros(tester);
      final atual = _doc(tester).current as PageSnapshot;
      expect(spacesOf(atual).map((x) => x.id), isNot(contains(nota.id)));
      expect(atual.page.end, nota.at, reason: 'a página acaba na âncora');
      await tester.tapAt(const Offset(360, 420));
      await _quadros(tester);
      final seguinte = _doc(tester).current as PageSnapshot;
      expect(seguinte.page.slices.first, isA<SpaceSlice>());
      expect(seguinte.page.start, nota.at);
      final espacos = spacesOf(seguinte);
      expect(espacos.first.id, nota.id);
      expect(
        espacos.first.rect.top,
        closeTo(seguinte.typography.topInset, 0.01),
      );
    },
  );

  testWidgets('a nota que o leitor passou para a página seguinte (R12) entra na sessão da página de cima: a caixa no pé '
      'dela (R3), e a mesma fresta não abre outra (R5)', (tester) async {
    final s = await espaco(tester);
    final limpo = _doc(tester).current as PageSnapshot;
    final fundo = limpo.typography.topInset + limpo.typography.contentHeight;
    final l = s.geometry.lines.lastWhere(
      (x) =>
          x.bottom + s.textShift + 2 < 660 &&
          x.bottom + noteFlowHeight(3) > fundo,
    );
    final nota = await notaComTinta(tester, s, l);
    await tester.tap(_key('ann.done'));
    await esperarBancoL22(tester);
    await _quadros(tester);
    await esperarBancoL22(tester);
    await _quadros(tester);
    expect(
      spacesOf(_doc(tester).current).map((x) => x.id),
      isNot(contains(nota.id)),
    );
    // de novo no modo, na mesma página
    await entrarNoModoAnotacao(tester);
    final s2 = _sessao(tester);
    expect(s2.notes.map((n) => n.id), [nota.id]);
    expect(s2.noteBox(nota.id), isNotNull);
    await tester.tap(_key('ann.toolShelf.space'));
    await tester.pump();
    final fresta = l.bottom + s2.textShift;
    await tracarL22(tester, [
      Offset(dedoDaTela24, fresta + 2),
      Offset(dedoDaTela24, fresta + 20),
      Offset(dedoDaTela24, fresta + 120),
    ]);
    expect(s2.notes, hasLength(1));
  });

  testWidgets('com o modo aberto, a tinta que muda no banco (outro aparelho) não repagina o livro: a página do modo fica viva; '
      'ao sair, repagina', (tester) async {
    final mundo = await livroDaTela24b();
    addTearDown(mundo.close);
    await abrirTela24b(tester, mundo);
    final s = sessaoNaTela(tester);
    final id = s.notes.single.id;
    final pagina = s.page!;
    await tester.runAsync(
      () => DriftInkRepository(
        mundo.db,
        mundo.versioning,
      ).setCollapsed(mundo.leitor, id, true),
    );
    await esperarBancoL22(tester);
    await _quadros(tester);
    expect(pagina.alive, isTrue, reason: 'a página do modo não morre');
    expect(
      spacesOf(_doc(tester).current).singleWhere((x) => x.id == id).rect.height,
      closeTo(noteFlowHeight(3), 1e-3),
      reason: 'o leitor limpo espera o modo sair',
    );
    // sair sem mudanças: o livro repagina com a faixa
    await tester.tap(_key('ann.done'));
    await esperarBancoL22(tester);
    await _quadros(tester);
    await esperarBancoL22(tester);
    await _quadros(tester);
    expect(find.byType(AnnotationMode), findsNothing);
    expect(
      spacesOf(_doc(tester).current).singleWhere((x) => x.id == id).rect.height,
      closeTo(stripFlowHeight(s.geometry.lineHeight), 1e-3),
    );
  });

  testWidgets('Noite (R14): a caixa e o abridor com as cores do Noite', (
    tester,
  ) async {
    final noite = await livroDaTela24b(papel: ReaderPaper.noite);
    addTearDown(noite.close);
    await abrirTela24b(tester, noite);
    final b =
        tester
                .widget<Container>(_key('ann.page.handNote.actions.delete.box'))
                .decoration!
            as BoxDecoration;
    expect(b.color, AppColors.islandNight);
    expect(b.border, Border.all(width: 1.5, color: AppColors.inkNight));
    // o Espaço no Noite
    final s = sessaoNaTela(tester);
    await tester.tap(_key('ann.toolShelf.space'));
    await tester.pump();
    final l = _linha(s, 'que eles foram e me fizeram.');
    await tracarL22(tester, [
      Offset(dedoDaTela24, l.bottom + 30 + 2),
      Offset(dedoDaTela24, l.bottom + 30 + 40),
    ], soltar: false);
    await tester.pump();
    expect(
      tester.widget<SpaceOpener>(find.byType(SpaceOpener)).colors.chip,
      AppColors.inkNight,
    );
  });
}

/// A nota criada no teste: a camada e a âncora.
typedef SessionNoteRef = ({String id, int at});

/// A tinta do leitor que demora a chegar: o rascunho (o 1º passo da leitura da tinta) espera [soltar].
final class _TintaDemorada implements InkRepository {
  _TintaDemorada(this._real);

  final InkRepository _real;
  final _portao = Completer<void>();
  var _pedido = false;

  /// O banco sem tinta nenhuma (o rascunho recuperado apagou a nota).
  var vazia = false;

  /// A tinta do leitor pediu o rascunho e espera.
  bool get esperando => _pedido && !_portao.isCompleted;

  void soltar() => _portao.complete();

  @override
  Future<bool> recoverDraft(String owner, String userBookId) async {
    _pedido = true;
    await _portao.future;
    return _real.recoverDraft(owner, userBookId);
  }

  @override
  Future<List<SavedDrawing>> drawingsOfBook(String userBookId) async =>
      vazia ? const [] : _real.drawingsOfBook(userBookId);

  @override
  Future<List<SavedNote>> notesOfBook(String userBookId) async =>
      vazia ? const [] : _real.notesOfBook(userBookId);

  @override
  Future<void> setCollapsed(String owner, String layerId, bool collapsed) =>
      _real.setCollapsed(owner, layerId, collapsed);

  @override
  Future<void> commit(String owner, String userBookId, InkChanges c) =>
      _real.commit(owner, userBookId, c);

  @override
  Future<void> saveDraft(
    String owner,
    String userBookId,
    InkChanges c, {
    required String session,
  }) => _real.saveDraft(owner, userBookId, c, session: session);

  @override
  Future<List<InkChanges>> draftsOf(String owner, String userBookId) =>
      _real.draftsOf(owner, userBookId);

  @override
  Future<void> clearDraft(
    String owner,
    String userBookId, {
    required String session,
  }) => _real.clearDraft(owner, userBookId, session: session);
}

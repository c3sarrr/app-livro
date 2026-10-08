// G16.6 — o modo anotação pela rota real, com o Dom Casmurro do Gutenberg num banco em memória: "Anotar" fecha os
// controles e abre a camada sobre a página (D-167); Concluir sem mudanças só sai; o traço do dedo grava no Concluir
// (uma camada e o desenho) e aparece no leitor limpo; o Voltar é o Concluir (D-42); Marca-texto e o poço avisam e a
// ferramenta continua (D-163); a falha ao salvar deixa o modo com a pílula e tocar de novo grava (D-21); a página de
// baixo não responde no modo; PDF avisa (D-164). G16.7 (comportamento): Espaço e o 2º toque na ativa também avisam;
// a espessura grava no `pen_presets` e vale para o traço seguinte; Desfazer e Refazer ligam e desligam; 2 dedos movem
// a página até o limite e ela volta do batente (D-165); a tinta acompanha a fonte, o tamanho e a margem (G14 — a
// moldura da D-162); o Noite (D-167 17); o leitor de tela (o anúncio ao entrar); o rascunho a cada 5 s é gravado ao
// reabrir o livro depois de "matar" o app (D-166). (Vindo da 19 sem NBSP, as quebras ficam e o texto desce 30: L22a.)
import 'dart:convert';
import 'dart:io';

import 'package:app_leitura/core/data/database/daos/annotation_daos.dart';
import 'package:app_leitura/core/data/database/daos/content_daos.dart';
import 'package:app_leitura/core/data/database/daos/library_daos.dart';
import 'package:app_leitura/core/data/database/daos/reader_daos.dart';
import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/widgets/app_svg.dart';
import 'package:app_leitura/core/design_system/widgets/neo_box.dart';
import 'package:app_leitura/features/library/domain/user_book.dart';
import 'package:app_leitura/features/reader/annotations/domain/pen_presets.dart';
import 'package:app_leitura/features/reader/annotations/ink/ink_changes.dart';
import 'package:app_leitura/features/reader/annotations/ink/ink_units.dart';
import 'package:app_leitura/features/reader/annotations/ink_repository.dart';
import 'package:app_leitura/features/reader/application/annotation_session.dart';
import 'package:app_leitura/features/reader/application/reader_document.dart';
import 'package:app_leitura/features/reader/content/book_index.dart';
import 'package:app_leitura/features/reader/content/ref_pages.dart';
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:app_leitura/features/reader/presentation/annotation_canvas.dart';
import 'package:app_leitura/features/reader/presentation/annotation_mode.dart';
import 'package:app_leitura/features/reader/presentation/reader_overlays.dart'
    show readerSoonText;
import 'package:app_leitura/features/reader/presentation/reader_page_view.dart';
import 'package:app_leitura/features/reader/presentation/reader_palette.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdfrx/pdfrx.dart' show pdfrxInitialize;

import '../../../support/canvas.dart';
import '../../../support/dados_t22.dart';
import '../../../support/epub_builder.dart' show simpleEpub;
import '../../../support/fake_ink_repository.dart';
import '../../../support/load_fonts.dart';
import '../../../support/personal_builders.dart';
import '../../../support/pump_reader.dart';
import '../../../support/reader_harness.dart';

Finder _key(String k) => find.byKey(ValueKey<String>(k));

ReaderPageView _pagina(WidgetTester tester) =>
    tester.widget<ReaderPageView>(find.byType(ReaderPageView));

ReaderDocument _doc(WidgetTester tester) => _pagina(tester).document;

Future<void> _quadros(WidgetTester tester, [int n = 30]) async {
  for (var i = 0; i < n; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

/// Espera o banco (o `pen_presets`, as gravações do Concluir, a tinta relida) e a tela.
Future<void> _banco(WidgetTester tester) async {
  for (var i = 0; i < 15; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 16));
  }
}

Future<void> _abrirControles(WidgetTester tester) async {
  await tester.tapAt(const Offset(195, 420));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 150));
  await _quadros(tester, 6);
  expect(_key('r20.topIsland'), findsOneWidget);
}

/// Controles → "Anotar" → a camada entra (220 ms).
Future<void> _anotar(WidgetTester tester) async {
  await _abrirControles(tester);
  await tester.tap(_key('r20.bottomIsland.tools.annotate'));
  await _banco(tester);
  await _quadros(tester, 20);
  expect(_key('ann.island'), findsOneWidget);
}

AnnotationSession _sessao(WidgetTester tester) =>
    tester.widget<AnnotationMode>(find.byType(AnnotationMode)).session;

/// Um traço de dedo pela página, numa linha do meio.
Future<void> _risco(WidgetTester tester) async {
  final g = await tester.startGesture(const Offset(60, 330));
  for (var i = 1; i <= 8; i++) {
    await g.moveTo(
      Offset(60 + 25.0 * i, 332 + (i.isEven ? 2 : -2)),
      timeStamp: Duration(milliseconds: 16 * i),
    );
  }
  await g.up();
  await tester.pump();
}

/// Concluir e espera a camada sair (220 ms) e o banco.
Future<void> _concluir(WidgetTester tester) async {
  await tester.tap(_key('ann.done'));
  await _banco(tester);
  await _quadros(tester, 20);
}

String? _aviso(WidgetTester tester) {
  final f = find.descendant(
    of: _key('leitor.aviso'),
    matching: find.byType(AppText),
  );
  return f.evaluate().isEmpty
      ? null
      : tester.widget<AppText>(f).span.toPlainText();
}

/// Desfazer/Refazer ligados (o ícone sem o 0,38).
(bool, bool) _botoes(WidgetTester tester) => (
  tester.widget<AppSvg>(_key('ann.island.undo.icon')).opacity == null,
  tester.widget<AppSvg>(_key('ann.island.redo.icon')).opacity == null,
);

/// O deslocamento pintado da página (o da sessão, ou a volta do batente).
double _pintado(WidgetTester tester) =>
    (tester.widget<CustomPaint>(_key('ann.canvas.page')).painter!
            as AnnotationPagePainter)
        .pan
        .value;

/// 2 dedos juntos (o 2º no mesmo instante: o traço do 1º é descartado) andando [dy] na vertical em [passos].
Future<void> _doisDedos(
  WidgetTester tester,
  double dy, {
  int passos = 10,
}) async {
  final a = await tester.startGesture(const Offset(150, 400), pointer: 71);
  final b = await tester.startGesture(const Offset(240, 420), pointer: 72);
  for (var i = 1; i <= passos; i++) {
    final t = Duration(milliseconds: 16 * i);
    await a.moveBy(Offset(0, dy / passos), timeStamp: t);
    await b.moveBy(Offset(0, dy / passos), timeStamp: t);
    await tester.pump();
  }
  await a.up();
  await b.up();
  await tester.pump();
}

/// Cada ponto do desenho na moldura do trecho dele: a fração da largura do trecho (`k` estica o x) e a altura em em
/// a partir da linha de base (D-162). O trecho fica numa linha só.
List<(double, double)> _naMoldura(DisplayPage p, PageDrawing d) {
  final caixas = p.boxesOf(d.range.unit, d.range.from, d.range.to);
  final esq = caixas.map((c) => c.rect.left).reduce((a, b) => a < b ? a : b);
  final dir = caixas.map((c) => c.rect.right).reduce((a, b) => a > b ? a : b);
  final c = caixas.first;
  expect(
    caixas.every((x) => x.baseline == c.baseline),
    isTrue,
    reason: 'o trecho numa linha',
  );
  return [
    for (final s in d.strokes)
      for (final q in s.points)
        ((q.x - esq) / (dir - esq), (q.y - c.baseline) / c.em),
  ];
}

void main() {
  setUpAll(loadAppFonts);

  late LivroNaEstante livro;
  setUp(() async {
    livro = await LivroNaEstante.domCasmurro();
    await livro.guardarPosicao(2, livro.index.spine[2].chars ~/ 2);
  });
  tearDown(() async => livro.close());

  testWidgets(
    '"Anotar" fecha os controles e abre o modo sobre a página; Concluir sem mudanças só sai',
    (tester) async {
      setCanvasView(tester, logical: const Size(390, 844));
      await abrirLeitor(tester, livro);
      final antes = _doc(tester).numbers.refPage;
      await _anotar(tester);
      expect(_key('r20.topIsland'), findsNothing);
      expect(_sessao(tester).tool, AnnotationTool.pen);
      // a página de baixo não responde: tocar à direita não vira (o toque é um ponto de tinta — e Desfazer tira)
      await tester.tapAt(const Offset(370, 420));
      await _quadros(tester, 10);
      expect(_doc(tester).numbers.refPage, antes);
      expect(_sessao(tester).visibleStrokes, hasLength(1));
      await tester.tap(_key('ann.island.undo'));
      await tester.pump();
      expect(_sessao(tester).visibleStrokes, isEmpty);
      await _concluir(tester);
      expect(_key('ann.island'), findsNothing);
      expect(_key('r20.topIsland'), findsNothing);
      expect(
        await tester.runAsync(
          () => InkLayersDao(livro.db).liveOverTextForBook(livro.userBookId),
        ),
        isEmpty,
      );
    },
  );

  testWidgets('o traço do dedo grava no Concluir e aparece no leitor limpo', (
    tester,
  ) async {
    setCanvasView(tester, logical: const Size(390, 844));
    await abrirLeitor(tester, livro);
    await _anotar(tester);
    await _risco(tester);
    expect(_sessao(tester).visibleStrokes, hasLength(1));
    expect(_sessao(tester).canUndo, isTrue);
    await _concluir(tester);
    expect(_key('ann.island'), findsNothing);
    final camadas = await tester.runAsync(
      () => InkLayersDao(livro.db).liveOverTextForBook(livro.userBookId),
    );
    expect(camadas, hasLength(1));
    final tinta = _pagina(tester).ink!;
    expect(tinta.drawingsOn(_doc(tester).current), hasLength(1));
  });

  testWidgets('o Voltar é o Concluir (D-42)', (tester) async {
    setCanvasView(tester, logical: const Size(390, 844));
    await abrirLeitor(tester, livro);
    await _anotar(tester);
    await _risco(tester);
    await tester.binding.handlePopRoute();
    await _banco(tester);
    await _quadros(tester, 20);
    expect(_key('ann.island'), findsNothing);
    expect(
      find.byType(ReaderPageView),
      findsOneWidget,
      reason: 'o livro fica aberto',
    );
    expect(
      await tester.runAsync(
        () => InkLayersDao(livro.db).liveOverTextForBook(livro.userBookId),
      ),
      hasLength(1),
    );
  });

  testWidgets(
    'Marca-texto, o poço, o Espaço e o 2º toque na ativa mostram o aviso e a ferramenta continua (D-163); a Borracha troca',
    (tester) async {
      setCanvasView(tester, logical: const Size(390, 844));
      await abrirLeitor(tester, livro);
      await _anotar(tester);
      await tester.tap(_key('ann.toolShelf.marker'));
      await tester.pump();
      expect(_aviso(tester), readerSoonText);
      expect(_sessao(tester).tool, AnnotationTool.pen);
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();
      expect(_aviso(tester), isNull);
      await tester.tap(_key('ann.island.colorWell'));
      await tester.pump();
      expect(_aviso(tester), readerSoonText);
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();
      // o Espaço (G18) e o 2º toque na ativa (o painel da caneta — G17)
      for (final k in const ['ann.toolShelf.space', 'ann.toolShelf.pen']) {
        expect(_aviso(tester), isNull);
        await tester.tap(_key(k));
        await tester.pump();
        expect(_aviso(tester), readerSoonText, reason: k);
        expect(_sessao(tester).tool, AnnotationTool.pen, reason: k);
        await tester.pump(const Duration(seconds: 2));
        await tester.pump();
      }
      await tester.tap(_key('ann.toolShelf.eraser'));
      await tester.pump();
      expect(_sessao(tester).tool, AnnotationTool.eraser);
      await tester.pump(const Duration(seconds: 2));
      await _concluir(tester);
    },
  );

  testWidgets(
    'a falha ao salvar deixa o modo com a pílula (D-21); tocar de novo grava e sai',
    (tester) async {
      setCanvasView(tester, logical: const Size(390, 844));
      final repo = FakeInkRepository()..failCommit = true;
      final t = await abrirLeitor(
        tester,
        livro,
        deps: (t) async => livro.readerDeps(
          awake: t.awake,
          onError: (e, _) => t.erros.add(e),
          ink: repo,
        ),
      );
      await _anotar(tester);
      await _risco(tester);
      await _concluir(tester);
      expect(_key('ann.island'), findsOneWidget);
      expect(_aviso(tester), annotationSaveFailed);
      expect(t.erros, isNotEmpty);
      expect(repo.drafts, hasLength(1), reason: 'o rascunho fica guardado');
      repo.failCommit = false;
      await _concluir(tester);
      expect(_key('ann.island'), findsNothing);
      expect(repo.commits, hasLength(1));
    },
  );

  testWidgets('a espessura grava no pen_presets e vale para o traço seguinte', (
    tester,
  ) async {
    setCanvasView(tester, logical: const Size(390, 844));
    await abrirLeitor(tester, livro);
    await _anotar(tester);
    expect(_sessao(tester).strokeSize, StrokeSize.medium);
    await tester.tap(_key('ann.island.width.thick'));
    await _banco(tester);
    expect(_sessao(tester).strokeSize, StrokeSize.thick);
    final gravado = await tester.runAsync(
      () => PenPresetsDao(livro.db).forUser(livro.leitor),
    );
    expect(gravado!.strokeSize, StrokeSize.thick);
    await _risco(tester);
    final traco = _sessao(tester).visibleStrokes.single;
    expect(
      traco.widthCentiMm,
      widthCentiMm(gravado.penWidthMm, StrokeSize.thick),
    );
    await _concluir(tester);
  });

  testWidgets(
    'Desfazer e Refazer ligam e desligam com o traço, e o Desfazer some com ele',
    (tester) async {
      setCanvasView(tester, logical: const Size(390, 844));
      await abrirLeitor(tester, livro);
      await _anotar(tester);
      expect(_botoes(tester), (false, false));
      await _risco(tester);
      expect(_botoes(tester), (true, false));
      await tester.tap(_key('ann.island.undo'));
      await tester.pump();
      expect(_sessao(tester).visibleStrokes, isEmpty);
      expect(_botoes(tester), (false, true));
      await tester.tap(_key('ann.island.redo'));
      await tester.pump();
      expect(_sessao(tester).visibleStrokes, hasLength(1));
      expect(_botoes(tester), (true, false));
      // um traço novo depois de desfazer apaga o Refazer
      await tester.tap(_key('ann.island.undo'));
      await tester.pump();
      await _risco(tester);
      expect(_botoes(tester), (true, false));
      await _concluir(tester);
    },
  );

  testWidgets(
    '2 dedos movem a página (sem traço) até o limite e ela volta do batente em 220 ms (D-165)',
    (tester) async {
      setCanvasView(tester, logical: const Size(390, 844));
      await abrirLeitor(tester, livro);
      await _anotar(tester);
      final s = _sessao(tester);
      final limite = s.panLimit;
      expect(
        limite,
        greaterThan(40),
        reason: 'a página cheia passa da borda de mesa',
      );
      await _doisDedos(tester, -limite / 2);
      expect(s.visibleStrokes, isEmpty, reason: '2 dedos não desenham');
      expect(s.panOffset, moreOrLessEquals(-limite / 2, epsilon: 1e-6));
      expect(_pintado(tester), moreOrLessEquals(-limite / 2, epsilon: 1e-6));
      // para baixo além do começo: volta ao 0
      await _doisDedos(tester, limite);
      expect(s.panOffset, 0);
      await tester.pump(const Duration(milliseconds: 230));
      expect(_pintado(tester), moreOrLessEquals(0, epsilon: 1e-6));
      // para cima além do limite: estica 1/3 do excesso e volta ao limite
      await _doisDedos(tester, -1.5 * limite);
      expect(s.panOffset, moreOrLessEquals(-limite, epsilon: 1e-6));
      final solto = _pintado(tester);
      expect(solto, lessThan(-limite - 1), reason: 'ainda além do batente');
      await tester.pump(const Duration(milliseconds: 110));
      expect(_pintado(tester), inExclusiveRange(solto, -limite));
      await tester.pump(const Duration(milliseconds: 120));
      expect(_pintado(tester), moreOrLessEquals(-limite, epsilon: 1e-6));
      await _concluir(tester);
    },
  );

  testWidgets(
    'a tinta aparece no leitor limpo e acompanha o tamanho, a fonte e a margem (G14 — a moldura da D-162)',
    (tester) async {
      setCanvasView(tester, logical: const Size(390, 844));
      await abrirLeitor(tester, livro);
      final antes = _doc(tester).current;
      // um traço curto sob o começo da 1ª linha da página
      final primeira = antes
          .boxesOf(antes.shown!.unit, antes.shown!.from, antes.shown!.from + 1)
          .first;
      await _anotar(tester);
      final y = primeira.baseline + annotationTextShift + 4;
      final g = await tester.startGesture(Offset(primeira.rect.left + 4, y));
      for (var i = 1; i <= 6; i++) {
        await g.moveTo(
          Offset(primeira.rect.left + 4 + 7.0 * i, y + (i.isEven ? 1 : -1)),
          timeStamp: Duration(milliseconds: 16 * i),
        );
      }
      await g.up();
      await tester.pump();
      await _concluir(tester);
      PageDrawing desenho() {
        final d = _pagina(tester).ink!.drawingsOn(_doc(tester).current);
        expect(d, hasLength(1), reason: 'o desenho na página aberta');
        return d.single;
      }

      final moldura = _naMoldura(_doc(tester).current, desenho());
      Future<void> mudar(String chave) async {
        await tester.tapAt(const Offset(195, 420));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 150));
        await _quadros(tester, 6);
        await tester.tap(_key('r20.bottomIsland.tools.font'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 150));
        await _quadros(tester, 6);
        await tester.tap(_key(chave));
        await _banco(tester);
        await _banco(tester);
        await tester.binding.handlePopRoute(); // fecha a folha
        await tester.pump(const Duration(milliseconds: 150));
        await tester.binding.handlePopRoute(); // fecha os controles
        await tester.pump(const Duration(milliseconds: 150));
        await _quadros(tester, 10);
      }

      for (final chave in const [
        'rs.sheet.size.larger',
        'rs.sheet.fonts.lora',
        'rs.sheet.margins.wide',
      ]) {
        await mudar(chave);
        final agora = _naMoldura(_doc(tester).current, desenho());
        expect(agora, hasLength(moldura.length), reason: chave);
        for (var i = 0; i < agora.length; i++) {
          expect(
            agora[i].$1,
            moreOrLessEquals(moldura[i].$1, epsilon: 1e-3),
            reason: '$chave x $i',
          );
          expect(
            agora[i].$2,
            moreOrLessEquals(moldura[i].$2, epsilon: 1e-3),
            reason: '$chave y $i',
          );
        }
      }
      final ajustes = await tester.runAsync(
        () => ReaderSettingsDao(livro.db).forUser(livro.leitor),
      );
      expect(
        (ajustes!.fontStep, ajustes.fontFamily, ajustes.margins),
        (5, ReaderFontFamily.lora, ReaderMargins.larga),
      );
    },
  );

  testWidgets(
    'Noite (D-167 17): pílula e ilha escuras, o papel do Noite na página e na borda de mesa; a tinta não muda',
    (tester) async {
      final noite = await livroDaTela22(papel: ReaderPaper.noite);
      addTearDown(noite.close);
      await abrirTela22(tester, noite);
      for (final id in const ['ann.modePill', 'ann.island']) {
        final caixa = tester.widget<NeoBox>(
          find
              .descendant(
                of: _key(id),
                matching: find.byType(NeoBox),
                matchRoot: true,
              )
              .first,
        );
        expect(
          (caixa.color, caixa.border?.color, caixa.shadowColor),
          (AppColors.islandNight, AppColors.inkNight, AppColors.shadowNight),
          reason: id,
        );
      }
      final papel = ReaderPalette.of(ReaderPaper.noite).paper;
      final borda =
          (tester.widget<DecoratedBox>(_key('ann.deskEdge')).decoration
                  as BoxDecoration)
              .gradient!
              .colors;
      expect(borda.first, papel);
      expect(
        (tester.widget<CustomPaint>(_key('ann.canvas.page')).painter!
                as AnnotationPagePainter)
            .paper,
        papel,
      );
      for (final t in _sessao(tester).visibleStrokes) {
        expect(t.argb, 0xFFFF552E, reason: 'a tinta fica coral');
      }
      expect(tester.widget<AppSvg>(_key('ann.toolShelf.pen.art')).colors, {
        AppColors.lavender: AppColors.lavender,
        AppColors.flame: AppColors.flame,
      }, reason: 'os objetos da prateleira como no Creme');
    },
  );

  testWidgets(
    'leitor de tela: entrar anuncia "Modo anotação. Caneta, coral." e a página diz que está no modo',
    (tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(accessibleNavigation: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      final h = tester.ensureSemantics();
      setCanvasView(tester, logical: const Size(390, 844));
      await abrirLeitor(tester, livro);
      final n = _doc(tester).numbers;
      await _abrirControles(tester);
      tester.takeAnnouncements();
      await tester.tap(_key('r20.bottomIsland.tools.annotate'));
      await _banco(tester);
      await _quadros(tester, 20);
      expect(tester.takeAnnouncements().map((a) => a.message), [
        'Modo anotação. Caneta, coral.',
      ]);
      expect(
        find.bySemanticsLabel(
          'Dom Casmurro, página ${n.refPage} de ${n.refTotal} — modo anotação',
        ),
        findsOneWidget,
      );
      h.dispose();
      await _concluir(tester);
    },
  );

  testWidgets(
    'o rascunho vai ao banco a cada 5 s; "matar" o app e reabrir o livro grava o desenho (D-166)',
    (tester) async {
      setCanvasView(tester, logical: const Size(390, 844));
      await abrirLeitor(tester, livro);
      await _anotar(tester);
      await _risco(tester);
      final repo = DriftInkRepository(livro.db, livro.versioning);
      Future<List<InkChanges>?> rascunho() =>
          tester.runAsync(() => repo.draftsOf(livro.leitor, livro.userBookId));
      expect(await rascunho(), isEmpty, reason: 'antes dos 5 s');
      await tester.pump(inkDraftEvery);
      await _banco(tester);
      expect(await rascunho(), hasLength(1), reason: 'o rascunho dos 5 s');
      expect(
        await tester.runAsync(
          () => InkLayersDao(livro.db).liveOverTextForBook(livro.userBookId),
        ),
        isEmpty,
        reason: 'nada gravado de verdade ainda',
      );
      // o app morre (a árvore sai sem Concluir) e o livro é aberto de novo
      await tester.pumpWidget(const SizedBox.shrink());
      await _banco(tester);
      await abrirLeitor(tester, livro);
      await _banco(tester);
      expect(
        await tester.runAsync(
          () => InkLayersDao(livro.db).liveOverTextForBook(livro.userBookId),
        ),
        hasLength(1),
      );
      expect(await rascunho(), isEmpty, reason: 'o rascunho foi usado');
      expect(
        _pagina(tester).ink!.drawingsOn(_doc(tester).current),
        hasLength(1),
      );
    },
  );

  testWidgets(
    'o app indo para o segundo plano guarda o rascunho já; sair do leitor com o modo aberto também (D-166)',
    (tester) async {
      setCanvasView(tester, logical: const Size(390, 844));
      await abrirLeitor(tester, livro);
      await _anotar(tester);
      await _risco(tester);
      final repo = DriftInkRepository(livro.db, livro.versioning);
      Future<List<InkChanges>?> rascunhos() =>
          tester.runAsync(() => repo.draftsOf(livro.leitor, livro.userBookId));
      expect(await rascunhos(), isEmpty);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await _banco(tester);
      expect(await rascunhos(), hasLength(1), reason: 'antes dos 5 s');
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      // mais um traço e o leitor sai da árvore com o modo aberto: o rascunho fica com os 2
      await _risco(tester);
      await tester.pumpWidget(const SizedBox.shrink());
      await _banco(tester);
      final guardados = await rascunhos();
      expect(guardados, hasLength(1));
      expect(guardados!.single.layers.single.strokeCount, 2);
    },
  );

  testWidgets(
    'página sem texto (só uma imagem): "Anotar" mostra o aviso e não abre o modo (D-170)',
    (tester) async {
      // um PNG de 1×1
      final png = base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8/x8AAwMCAO+ip1sAAAAASUVORK5CYII=',
      );
      final soImagem = (await tester.runAsync(
        () => LivroNaEstante.epubDe(
          simpleEpub(
            chapters: [
              (
                file: 'c1.xhtml',
                title: 'Um',
                body: '<img src="fig.png" alt=""/>',
              ),
              (
                file: 'c2.xhtml',
                title: 'Dois',
                body: '<p>Depois da figura.</p>',
              ),
            ],
            extra: {'OEBPS/fig.png': png},
          ),
        ),
      ))!;
      addTearDown(() => tester.runAsync(soImagem.close));
      setCanvasView(tester, logical: const Size(390, 844));
      await abrirLeitor(tester, soImagem);
      await _abrirControles(tester);
      await tester.tap(_key('r20.bottomIsland.tools.annotate'));
      await _banco(tester);
      expect(_aviso(tester), readerSoonText);
      expect(find.byType(AnnotationMode), findsNothing);
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(milliseconds: 200));
    },
  );

  testWidgets('PDF: "Anotar" mostra o aviso (D-164)', (tester) async {
    final tmp = Directory.systemTemp.createTempSync('booknest_g16_pdf_');
    addTearDown(
      () => tester.runAsync(() async {
        for (var i = 0; i < 20 && tmp.existsSync(); i++) {
          try {
            tmp.deleteSync(recursive: true);
          } on FileSystemException {
            await Future<void>.delayed(const Duration(milliseconds: 100));
          }
        }
      }),
    );
    await tester.runAsync(() async {
      final copia = File('test/fixtures/livros/amostra.pdf')
          .copySync('${tmp.path}${Platform.pathSeparator}amostra.pdf');
      await UserBooksDao(livro.db).upsert(
        livro.book.copyWith(format: BookFileFormat.pdf, title: 'Amostra'),
      );
      await LocalFilesDao(livro.db).upsert(
        userBookId: livro.userBookId,
        path: copia.path,
        bytes: copia.lengthSync(),
        sha256: shaTeste,
        now: t0Teste,
      );
      await BookContentIndexDao(livro.db).upsert(
        livro.userBookId,
        BookIndex(
          contentSha256: shaTeste,
          layout: 'pdf',
          spine: const [],
          toc: const [],
          refPages: RefPageMap.pdf(2),
        ),
        builtAt: t0Teste,
      );
    });
    setCanvasView(tester, logical: const Size(390, 844));
    await abrirLeitor(
      tester,
      livro,
      esperar: false,
      deps: (t) async => livro.readerDeps(
        awake: t.awake,
        pdfInitialize: () => pdfrxInitialize(tmpPath: tmp.path),
      ),
    );
    for (var i = 0; i < 200 && _key('r19.footer').evaluate().isEmpty; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 16));
    }
    await tester.pumpAndSettle();
    await _abrirControles(tester);
    await tester.tap(_key('r20.bottomIsland.tools.annotate'));
    await tester.pump();
    expect(_aviso(tester), readerSoonText);
    expect(find.byType(AnnotationMode), findsNothing);
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 200));
  });
}

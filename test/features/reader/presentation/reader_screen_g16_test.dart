// G16.6 — o modo anotação pela rota real, com o Dom Casmurro do Gutenberg num banco em memória: "Anotar" fecha os
// controles e abre a camada sobre a página (D-167); Concluir sem mudanças só sai; o traço do dedo grava no Concluir
// (uma camada e o desenho) e aparece no leitor limpo; o Voltar é o Concluir (D-42); Marca-texto e o poço avisam e a
// ferramenta continua (D-163); a falha ao salvar deixa o modo com a pílula e tocar de novo grava (D-21); a página de
// baixo não responde no modo; PDF avisa (D-164).
import 'dart:io';

import 'package:app_leitura/core/data/database/daos/annotation_daos.dart';
import 'package:app_leitura/core/data/database/daos/content_daos.dart';
import 'package:app_leitura/core/data/database/daos/library_daos.dart';
import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/features/library/domain/user_book.dart';
import 'package:app_leitura/features/reader/application/annotation_session.dart';
import 'package:app_leitura/features/reader/application/reader_document.dart';
import 'package:app_leitura/features/reader/content/book_index.dart';
import 'package:app_leitura/features/reader/content/ref_pages.dart';
import 'package:app_leitura/features/reader/presentation/annotation_mode.dart';
import 'package:app_leitura/features/reader/presentation/reader_overlays.dart'
    show readerSoonText;
import 'package:app_leitura/features/reader/presentation/reader_page_view.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdfrx/pdfrx.dart' show pdfrxInitialize;

import '../../../support/canvas.dart';
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
    'Marca-texto e o poço mostram o aviso e a ferramenta continua (D-163); a Borracha troca',
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

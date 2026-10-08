// G13 — a seleção e os grifos pela rota real, com o Dom Casmurro de verdade num banco em memória:
// - a pressão longa numa palavra seleciona (com um toque de vibração) e mostra as alças e a barra; fora das letras,
//   nada; com os controles abertos, só os fecha (D-45, D-117, D-136);
// - com a seleção: tocar dentro fica, fora fecha; o arrasto fecha e vira; o Voltar fecha só a seleção (D-136);
// - o toque num grifo abre a barra dele com a cor marcada, sem alças nem fundo (D-132, D-137); fora de grifo, os
//   terços; o grifo que passa da página fica com a barra ao virar para a parte seguinte;
// - as ações da barra, uma de cada vez; a folha da nota (D-131, D-138); o "Desfazer" até a próxima ação (D-139);
// - G17: "Outra cor" abre a folha com o seletor da tela 23 (D-178), no lugar do aviso da D-129;
// - o PDF não seleciona (D-134).
import 'dart:io';

import 'package:app_leitura/core/data/database/daos/annotation_daos.dart';
import 'package:app_leitura/core/data/database/daos/content_daos.dart';
import 'package:app_leitura/core/data/database/daos/library_daos.dart';
import 'package:app_leitura/features/library/domain/user_book.dart';
import 'package:app_leitura/features/reader/annotations/domain/annotation.dart';
import 'package:app_leitura/features/reader/application/pdf_reader_document.dart';
import 'package:app_leitura/features/reader/application/reader_document.dart';
import 'package:app_leitura/features/reader/domain/locator.dart';
import 'package:app_leitura/core/data/database/daos/kv_dao.dart';
import 'package:app_leitura/features/reader/application/reader_annotations.dart';
import 'package:app_leitura/features/reader/presentation/reader_actions.dart';
import 'package:app_leitura/features/reader/presentation/reader_overlays.dart';
import 'package:app_leitura/features/reader/presentation/reader_page_view.dart';
import 'package:app_leitura/features/reader/presentation/reader_screen.dart';
import 'package:flutter/gestures.dart' show kLongPressTimeout;
import 'package:flutter/semantics.dart' show CustomSemanticsAction;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdfrx/pdfrx.dart' show pdfrxInitialize;

import '../../../support/app_text_finder.dart';
import '../../../support/canvas.dart';
import '../../../support/load_fonts.dart';
import '../../../support/personal_builders.dart';
import '../../../support/pump_reader.dart';
import '../../../support/reader_harness.dart';

Finder _key(String k) => find.byKey(ValueKey<String>(k));

ReaderDocument _doc(WidgetTester tester) =>
    tester.widget<ReaderPageView>(find.byType(ReaderPageView)).document;

ReaderPagesPainter _pintor(WidgetTester tester) => tester
    .widgetList<CustomPaint>(
      find.descendant(
        of: find.byType(ReaderPageView),
        matching: find.byType(CustomPaint),
      ),
    )
    .map((c) => c.painter)
    .whereType<ReaderPagesPainter>()
    .single;

Future<void> _quadros(WidgetTester tester, [int n = 10]) async {
  for (var i = 0; i < n; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

/// A [n]-ésima palavra de 4 letras ou mais da página na tela e onde ela está.
({ReaderRange r, Rect rect}) _palavra(WidgetTester tester, {int n = 12}) {
  final p = _doc(tester).current;
  final s = p.shown!;
  final texto = p.textOf(s.unit, s.from, s.to);
  final m = RegExp(
    r'(?<![\p{L}-])\p{L}{4,}(?![\p{L}-])',
    unicode: true,
  ).allMatches(texto).elementAt(n);
  final r = (unit: s.unit, from: s.from + m.start, to: s.from + m.end);
  return (r: r, rect: p.boxesOf(r.unit, r.from, r.to).first.rect);
}

void main() {
  setUpAll(loadAppFonts);

  late LivroNaEstante livro;
  late List<String> vibracoes;
  String? copiado;
  late List<String> compartilhados;
  late List<Rect?> origens;
  setUp(() async {
    livro = await LivroNaEstante.domCasmurro();
    await livro.guardarPosicao(2, livro.index.spine[2].chars ~/ 2);
  });
  tearDown(() async => livro.close());

  Future<LeitorNaTela> abrir(
    WidgetTester tester, {
    bool falhaCopiar = false,
  }) async {
    vibracoes = [];
    copiado = null;
    compartilhados = [];
    origens = [];
    final mensageiro =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          ..setMockMethodCallHandler(SystemChannels.platform, (call) async {
            if (call.method == 'HapticFeedback.vibrate') {
              vibracoes.add(call.arguments as String);
            }
            if (call.method == 'Clipboard.setData') {
              if (falhaCopiar) throw PlatformException(code: 'sem teclado');
              copiado = (call.arguments as Map)['text'] as String;
            }
            return null;
          });
    addTearDown(
      () => mensageiro.setMockMethodCallHandler(SystemChannels.platform, null),
    );
    setCanvasView(tester, logical: const Size(390, 844));
    return abrirLeitor(
      tester,
      livro,
      overrides: [
        readerShareProvider.overrideWithValue((t, origem) async {
          compartilhados.add(t);
          origens.add(origem);
        }),
      ],
    );
  }

  /// Deixa o banco (em memória, com futuros de verdade) gravar e a tela reler.
  Future<void> banco(WidgetTester tester) async {
    for (var i = 0; i < 3; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await _quadros(tester, 3);
    }
  }

  Future<List<Annotation>> vivos(WidgetTester tester) async => (await tester
      .runAsync(() => AnnotationsDao(livro.db).forBook(livro.userBookId)))!;

  Future<void> tocar(WidgetTester tester, String k) async {
    await tester.tap(_key(k));
    await tester.pump();
    await banco(tester);
  }

  Future<({ReaderRange r, Rect rect})> selecionar(
    WidgetTester tester, {
    int n = 12,
  }) async {
    final w = _palavra(tester, n: n);
    await tester.longPressAt(w.rect.center);
    await _quadros(tester);
    return w;
  }

  testWidgets(
    'pressão longa numa palavra: seleciona com um toque de vibração; alças, barra e o pintor',
    (tester) async {
      final t = await abrir(tester);
      final w = await selecionar(tester);
      expect(vibracoes, ['HapticFeedbackType.selectionClick']);
      expect(_key('r21.toolbar'), findsOneWidget);
      expect(_key('r21.page.text.handleStart.knob'), findsOneWidget);
      expect(_key('r21.page.text.handleEnd.knob'), findsOneWidget);
      expect(_pintor(tester).selection!.value, w.r);
      expect(
        _pintor(tester).highlights,
        isNotNull,
        reason: 'os grifos do livro (EPUB)',
      );
      expect(
        tester.getRect(_key('r21.page.text.handleStart')).left,
        moreOrLessEquals(w.rect.left, epsilon: 1e-6),
      );
      expect(
        _key('r20.topIsland'),
        findsNothing,
        reason: 'os controles não abrem',
      );
      expect(t.erros, isEmpty);
    },
  );

  testWidgets(
    'pressão longa fora das letras: nada; com os controles abertos, só fecha os controles',
    (tester) async {
      await abrir(tester);
      await tester.longPressAt(const Offset(8, 420));
      await _quadros(tester);
      expect(_key('r21.toolbar'), findsNothing);
      expect(vibracoes, isEmpty);
      await tester.tapAt(const Offset(195, 420));
      await _quadros(tester, 12);
      expect(_key('r20.topIsland'), findsOneWidget);
      final w = _palavra(tester);
      await tester.longPressAt(w.rect.center);
      await _quadros(tester, 12);
      expect(_key('r20.topIsland'), findsNothing);
      expect(_key('r21.toolbar'), findsNothing);
      expect(vibracoes, isEmpty);
    },
  );

  testWidgets('arrastar sem soltar estende o fim por palavra (o começo fica)', (
    tester,
  ) async {
    await abrir(tester);
    final w = _palavra(tester);
    final outra = _palavra(tester, n: 14);
    final g = await tester.startGesture(w.rect.center);
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
    await g.moveTo(outra.rect.center);
    await tester.pump();
    await g.up();
    await _quadros(tester);
    expect(_pintor(tester).selection!.value, (
      unit: w.r.unit,
      from: w.r.from,
      to: outra.r.to,
    ));
  });

  testWidgets(
    'com a seleção: dentro fica; fora fecha sem abrir os controles; Voltar fecha só a seleção',
    (tester) async {
      await abrir(tester);
      final w = await selecionar(tester);
      await tester.tapAt(w.rect.center);
      await _quadros(tester);
      expect(_key('r21.toolbar'), findsOneWidget, reason: 'dentro');
      final antes = _doc(tester).mark;
      await tester.tapAt(const Offset(360, 780));
      await _quadros(tester);
      expect(_key('r21.toolbar'), findsNothing);
      expect(_pintor(tester).selection!.value, isNull);
      expect(_key('r20.topIsland'), findsNothing);
      expect(_doc(tester).mark, antes, reason: 'o toque fora não vira');
      await selecionar(tester);
      await tester.binding.handlePopRoute();
      await _quadros(tester);
      expect(_key('r21.toolbar'), findsNothing);
      expect(
        find.byType(ReaderScreen),
        findsOneWidget,
        reason: 'o livro continua',
      );
    },
  );

  testWidgets(
    'com a seleção, arrastar a página fecha e vira; a seleção não segue para a outra página',
    (tester) async {
      await abrir(tester);
      await selecionar(tester);
      final antes = _doc(tester).mark;
      await tester.dragFrom(const Offset(300, 700), const Offset(-200, 0));
      await tester.pumpAndSettle();
      expect(_key('r21.toolbar'), findsNothing);
      expect(_pintor(tester).selection!.value, isNull);
      expect(_doc(tester).mark.offset, greaterThan(antes.offset));
    },
  );

  testWidgets(
    'com a seleção, um arrasto curto que volta também fecha a seleção (D-136)',
    (tester) async {
      await abrir(tester);
      await selecionar(tester);
      final antes = _doc(tester).mark;
      await tester.timedDragFrom(
        const Offset(300, 700),
        const Offset(-40, 0),
        const Duration(milliseconds: 800),
      );
      await tester.pumpAndSettle();
      expect(_doc(tester).mark, antes, reason: 'curto e lento: volta');
      expect(_key('r21.toolbar'), findsNothing);
      expect(_pintor(tester).selection!.value, isNull);
    },
  );

  testWidgets(
    'grifo existente: tocar abre a barra com a cor marcada (D-132); fora do grifo, os terços',
    (tester) async {
      await abrir(tester);
      final w = _palavra(tester, n: 20);
      await tester.runAsync(
        () => AnnotationsDao(livro.db).upsert(
          Annotation(
            id: idTeste(60),
            meta: metaTeste(),
            userBookId: livro.userBookId,
            kind: AnnotationKind.highlight,
            groupId: idTeste(60),
            anchor: EpubAnchor(
              sha: livro.index.contentSha256,
              spine: w.r.unit,
              start: w.r.from,
              end: w.r.to,
              quote: const TextQuote(exact: 'x'),
              refPage: 1,
            ),
            refPage: 1,
            chapterIndex: 0,
            color: '#FED170',
            style: HighlightStyle.fill,
            fillHeight: FillHeight.medium,
          ),
        ),
      );
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await _quadros(tester);
      final pintados = _pintor(tester).highlights!
          .highlightsIn(_doc(tester).current.shown!);
      expect(pintados.single.range, w.r);
      await tester.tapAt(w.rect.center);
      await _quadros(tester);
      expect(_key('r21.toolbar'), findsOneWidget);
      expect(_key('r21.toolbar.colors.yellow.marked'), findsOneWidget);
      // D-137: só a barra — sem alças e sem o fundo da seleção (o grifo fica com a cor dele)
      expect(_key('r21.page.text.handleStart.knob'), findsNothing);
      expect(_key('r21.page.text.handleEnd.knob'), findsNothing);
      expect(_pintor(tester).selection!.value, isNull);
      // fecha e toca fora de grifo, no terço direito: vira
      await tester.binding.handlePopRoute();
      await _quadros(tester);
      final antes = _doc(tester).mark;
      await tester.tapAt(const Offset(370, 780));
      await tester.pumpAndSettle();
      expect(_doc(tester).mark.offset, greaterThan(antes.offset));
    },
  );

  testWidgets('PDF (D-134): sem grifos e a pressão longa não seleciona', (
    tester,
  ) async {
    final tmp = Directory.systemTemp.createTempSync('booknest_g13_pdf_');
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
    expect(_doc(tester), isA<PdfReaderDocument>());
    expect(_pintor(tester).highlights, isNull);
    await tester.longPressAt(const Offset(195, 300));
    await _quadros(tester);
    expect(_key('r21.toolbar'), findsNothing);
  });

  group('ações da barra (G13.4)', () {
    testWidgets(
      'uma cor grava o grifo de fundo, fecha a seleção, guarda a última cor e a página pinta',
      (tester) async {
        final t = await abrir(tester);
        final w = await selecionar(tester);
        await tocar(tester, 'r21.toolbar.colors.green');
        final g = (await vivos(tester)).single;
        expect(
          (g.kind, g.color, g.style, g.fillHeight),
          (
            AnnotationKind.highlight,
            '#ABCF82',
            HighlightStyle.fill,
            FillHeight.medium,
          ),
        );
        expect((g.anchor as EpubAnchor).start, w.r.from);
        expect(_key('r21.toolbar'), findsNothing);
        expect(_pintor(tester).selection!.value, isNull);
        expect(
          await tester.runAsync(
            () => KvDao(livro.db).get(lastHighlightColorKey),
          ),
          '#ABCF82',
        );
        expect(
          _pintor(tester).highlights!
              .highlightsIn(_doc(tester).current.shown!)
              .single
              .range,
          w.r,
        );
        expect(t.erros, isEmpty);
      },
    );

    testWidgets('Sublinhar usa a última cor', (tester) async {
      await tester.runAsync(
        () => KvDao(livro.db).set(lastHighlightColorKey, '#FFC1C6'),
      );
      await abrir(tester);
      await selecionar(tester);
      await tocar(tester, 'r21.toolbar.colors.underline');
      final g = (await vivos(tester)).single;
      expect(
        (g.color, g.style, g.fillHeight),
        ('#FFC1C6', HighlightStyle.underline, null),
      );
      expect(_key('r21.toolbar'), findsNothing);
    });

    testWidgets(
      'Outra cor (D-178): a folha com o seletor na última cor; Cancelar e o Voltar voltam à barra; Grifar faz o fundo Médio na cor escolhida',
      (tester) async {
        await tester.runAsync(
          () => KvDao(livro.db).set(lastHighlightColorKey, '#FFC1C6'),
        );
        await abrir(tester);
        await selecionar(tester);
        await tocar(tester, 'r21.toolbar.colors.other');
        expect(_key('leitor.outraCor'), findsOneWidget);
        expect(findAppText('#FFC1C6'), findsOneWidget);
        await tocar(tester, 'leitor.outraCor.cancelar');
        expect(_key('leitor.outraCor'), findsNothing);
        expect(_key('r21.toolbar'), findsOneWidget);
        await tocar(tester, 'r21.toolbar.colors.other');
        await tester.binding.handlePopRoute();
        await tester.pump();
        expect(_key('leitor.outraCor'), findsNothing);
        expect(_key('r21.toolbar'), findsOneWidget);
        await tocar(tester, 'r21.toolbar.colors.other');
        await tester.tap(_key('leitor.outraCor.picker.hex'));
        await tester.pump();
        await tester.enterText(find.byType(EditableText), '1a2b3c');
        await tester.pump();
        await tocar(tester, 'leitor.outraCor.grifar');
        final g = (await vivos(tester)).single;
        expect(
          (g.color, g.style, g.fillHeight),
          ('#1A2B3C', HighlightStyle.fill, FillHeight.medium),
        );
        expect(_key('leitor.outraCor'), findsNothing);
        expect(_key('r21.toolbar'), findsNothing);
        expect(
          await tester.runAsync(
            () => KvDao(livro.db).get(lastHighlightColorKey),
          ),
          '#1A2B3C',
        );
      },
    );

    testWidgets(
      'Outra cor num grifo tocado (D-132): começa na cor dele e Grifar troca a cor',
      (tester) async {
        await abrir(tester);
        final w = await selecionar(tester);
        await tocar(tester, 'r21.toolbar.colors.yellow');
        final antes = (await vivos(tester)).single;
        await tester.runAsync(
          () => KvDao(livro.db).set(lastHighlightColorKey, '#ABCF82'),
        );
        await tester.tapAt(w.rect.center);
        await _quadros(tester);
        await tocar(tester, 'r21.toolbar.colors.other');
        expect(findAppText('#FED170'), findsOneWidget);
        await tester.tap(_key('leitor.outraCor.picker.hex'));
        await tester.pump();
        await tester.enterText(find.byType(EditableText), '058cd7');
        await tester.pump();
        await tocar(tester, 'leitor.outraCor.grifar');
        final depois = (await vivos(tester)).single;
        expect(depois.id, antes.id);
        expect((depois.color, depois.style), ('#058CD7', HighlightStyle.fill));
      },
    );

    testWidgets(
      'Copiar: a citação da D-39 no teclado do sistema e "Trecho copiado" 12 acima do rodapé, por 2 s',
      (tester) async {
        await abrir(tester);
        final w = await selecionar(tester);
        final doc = _doc(tester);
        final esperado =
            '“${doc.current.textOf(w.r.unit, w.r.from, w.r.to)}”\n'
            '— ${doc.author}, ${doc.title} (pág. ${doc.anchors!.placeOf(w.r.unit, w.r.from).refPage})';
        await tocar(tester, 'r21.toolbar.actions.copy');
        expect(copiado, esperado);
        expect(esperado, startsWith('“'));
        expect(esperado, contains('— Machado de Assis, Dom Casmurro (pág. '));
        expect(_key('r21.toolbar'), findsNothing);
        expect(findAppText(readerCopiedText), findsOneWidget);
        final rodape = tester.getRect(_key('r19.footer'));
        expect(
          tester.getRect(_key('leitor.aviso')).bottom,
          moreOrLessEquals(rodape.top - 12, epsilon: 0.5),
        );
        await tester.pump(readerToastLife);
        expect(findAppText(readerCopiedText), findsNothing);
      },
    );

    testWidgets(
      'Compartilhar: a mesma citação vai para a folha do sistema, saindo do botão',
      (tester) async {
        await abrir(tester);
        final w = await selecionar(tester);
        final doc = _doc(tester);
        final botao = tester.getRect(_key('r21.toolbar.actions.share'));
        await tocar(tester, 'r21.toolbar.actions.share');
        expect(compartilhados, [
          quoteForSharing(
            excerpt: doc.anchors!.textOf(w.r.unit)!.substring(w.r.from, w.r.to),
            author: doc.author,
            title: doc.title,
            refPage: doc.anchors!.placeOf(w.r.unit, w.r.from).refPage,
          ),
        ]);
        expect(
          compartilhados.single,
          contains('— Machado de Assis, Dom Casmurro (pág. '),
        );
        expect(origens, [botao]);
        expect(_key('r21.toolbar'), findsNothing);
      },
    );

    testWidgets('Copiar que falha: relata e não diz "Trecho copiado"', (
      tester,
    ) async {
      final t = await abrir(tester, falhaCopiar: true);
      await selecionar(tester);
      await tocar(tester, 'r21.toolbar.actions.copy');
      expect(findAppText(readerCopiedText), findsNothing);
      expect(t.erros, hasLength(1));
      expect(_key('r21.toolbar'), findsNothing);
    });

    testWidgets(
      'uma ação de cada vez: dois toques rápidos em cores diferentes gravam só o primeiro',
      (tester) async {
        await abrir(tester);
        await selecionar(tester);
        await tester.tap(_key('r21.toolbar.colors.green'));
        await tester.tap(_key('r21.toolbar.colors.pink'));
        await tester.pump();
        await banco(tester);
        final g = (await vivos(tester)).single;
        expect(g.color, '#ABCF82');
        expect(_key('r21.toolbar'), findsNothing);
      },
    );

    testWidgets(
      'Buscar: o painel abre com o trecho no campo e a seleção fecha',
      (tester) async {
        await abrir(tester);
        final w = await selecionar(tester);
        final texto = _doc(tester).current.textOf(w.r.unit, w.r.from, w.r.to);
        await tocar(tester, 'r21.toolbar.actions.search');
        await tester.pump(const Duration(milliseconds: 400));
        expect(_key('leitor.busca'), findsOneWidget);
        expect(
          tester
              .widget<EditableText>(
                find.descendant(
                  of: _key('leitor.busca.campo'),
                  matching: find.byType(EditableText),
                ),
              )
              .controller
              .text,
          texto,
        );
        await tester.binding.handlePopRoute();
        await _quadros(tester);
        expect(_key('r21.toolbar'), findsNothing);
      },
    );

    testWidgets(
      'grifo existente (D-132): outra cor troca, Sublinhar troca, a marcada apaga com desfazer',
      (tester) async {
        await abrir(tester);
        final w = await selecionar(tester);
        await tocar(tester, 'r21.toolbar.colors.yellow');
        final id = (await vivos(tester)).single.id;
        Future<void> abrirGrifo() async {
          await tester.tapAt(w.rect.center);
          await _quadros(tester);
          expect(_key('r21.toolbar'), findsOneWidget);
        }

        await abrirGrifo();
        expect(_key('r21.toolbar.colors.yellow.marked'), findsOneWidget);
        await tocar(tester, 'r21.toolbar.colors.pink');
        var g = (await vivos(tester)).single;
        expect((g.id, g.color, g.style), (id, '#FFC1C6', HighlightStyle.fill));
        await abrirGrifo();
        expect(_key('r21.toolbar.colors.pink.marked'), findsOneWidget);
        await tocar(tester, 'r21.toolbar.colors.underline');
        g = (await vivos(tester)).single;
        expect(
          (g.id, g.color, g.style),
          (id, '#FFC1C6', HighlightStyle.underline),
        );
        await abrirGrifo();
        expect(_key('r21.toolbar.colors.underline.marked'), findsOneWidget);
        await tocar(tester, 'r21.toolbar.colors.underline');
        expect(await vivos(tester), isEmpty);
        expect(_key('leitor.desfazer'), findsOneWidget);
        expect(findAppText(readerRemovedText), findsOneWidget);
        await tocar(tester, 'leitor.desfazer.botao');
        expect(_key('leitor.desfazer'), findsNothing);
        g = (await vivos(tester)).single;
        expect((g.id, g.style), (id, HighlightStyle.underline));
        // apagar de novo e esperar: some em 4 s
        await abrirGrifo();
        await tocar(tester, 'r21.toolbar.colors.underline');
        expect(_key('leitor.desfazer'), findsOneWidget);
        await tester.pump(const Duration(milliseconds: 3700));
        expect(_key('leitor.desfazer'), findsOneWidget, reason: 'são 4 s');
        await tester.pump(const Duration(milliseconds: 300));
        expect(_key('leitor.desfazer'), findsNothing);
        expect(readerUndoLife, const Duration(seconds: 4));
        expect(await vivos(tester), isEmpty);
      },
    );
  });

  group('o "Desfazer" até a próxima ação (D-139)', () {
    Future<void> apagar(WidgetTester tester, Rect palavra) async {
      await tester.tapAt(palavra.center);
      await _quadros(tester);
      await tocar(tester, 'r21.toolbar.colors.yellow');
      expect(_key('leitor.desfazer'), findsOneWidget);
    }

    testWidgets('uma seleção nova tira o "Desfazer" antes dos 4 s', (
      tester,
    ) async {
      await abrir(tester);
      final w = await selecionar(tester);
      await tocar(tester, 'r21.toolbar.colors.yellow');
      await apagar(tester, w.rect);
      await selecionar(tester, n: 14);
      expect(_key('leitor.desfazer'), findsNothing);
      expect(_key('r21.toolbar'), findsOneWidget);
    });

    testWidgets(
      'com o leitor de tela fica sem prazo, até a próxima ação (virar a página)',
      (tester) async {
        tester.platformDispatcher.accessibilityFeaturesTestValue =
            const FakeAccessibilityFeatures(accessibleNavigation: true);
        addTearDown(
          tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
        );
        final semantica = tester.ensureSemantics();
        await abrir(tester);
        final w = await selecionar(tester);
        await tocar(tester, 'r21.toolbar.colors.yellow');
        await apagar(tester, w.rect);
        await tester.pump(readerUndoLife * 2);
        expect(_key('leitor.desfazer'), findsOneWidget, reason: 'sem prazo');
        tester.semantics.customAction(
          find.semantics.byLabel(RegExp(r'^Dom Casmurro, página')),
          const CustomSemanticsAction(label: 'Próxima página'),
        );
        await _quadros(tester);
        expect(_key('leitor.desfazer'), findsNothing);
        semantica.dispose();
      },
    );
  });

  testWidgets(
    'pressão longa fora das letras com uma seleção na tela: arrastar não mexe nela',
    (tester) async {
      await abrir(tester);
      final w = await selecionar(tester);
      final outra = _palavra(tester, n: 14);
      final g = await tester.startGesture(const Offset(8, 420));
      await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
      await g.moveTo(outra.rect.center);
      await tester.pump();
      await g.up();
      await _quadros(tester);
      expect(_pintor(tester).selection!.value, w.r);
    },
  );

  testWidgets(
    'grifo que passa da página: a barra fica ao virar para a parte seguinte e Copiar leva o grifo inteiro',
    (tester) async {
      final semantica = tester.ensureSemantics();
      await abrir(tester);
      final doc = _doc(tester);
      final s = doc.current.shown!;
      final texto = doc.current.textOf(s.unit, s.from, s.to);
      final m = RegExp(r'\p{L}{3,}', unicode: true).allMatches(texto).last;
      final r = (unit: s.unit, from: s.from + m.start, to: s.to + 40);
      final palavra = doc.current
          .boxesOf(s.unit, s.from + m.start, s.from + m.end)
          .first
          .rect;
      await tester.runAsync(
        () => AnnotationsDao(livro.db).upsert(
          Annotation(
            id: idTeste(61),
            meta: metaTeste(),
            userBookId: livro.userBookId,
            kind: AnnotationKind.highlight,
            groupId: idTeste(61),
            anchor: EpubAnchor(
              sha: livro.index.contentSha256,
              spine: r.unit,
              start: r.from,
              end: r.to,
              quote: const TextQuote(exact: 'x'),
              refPage: 1,
            ),
            refPage: 1,
            chapterIndex: 0,
            color: '#ABCF82',
            style: HighlightStyle.fill,
            fillHeight: FillHeight.medium,
          ),
        ),
      );
      await banco(tester);
      await tester.tapAt(palavra.center);
      await _quadros(tester);
      expect(_key('r21.toolbar'), findsOneWidget);
      tester.semantics.customAction(
        find.semantics.byLabel(RegExp(r'^Dom Casmurro, página')),
        const CustomSemanticsAction(label: 'Próxima página'),
      );
      await _quadros(tester);
      expect(_doc(tester).current.shown!.from, greaterThanOrEqualTo(s.to));
      expect(
        _key('r21.toolbar'),
        findsOneWidget,
        reason: 'o grifo continua aqui',
      );
      await tocar(tester, 'r21.toolbar.actions.copy');
      expect(
        copiado,
        quoteForSharing(
          excerpt: doc.anchors!.textOf(r.unit)!.substring(r.from, r.to),
          author: doc.author,
          title: doc.title,
          refPage: doc.anchors!.placeOf(r.unit, r.from).refPage,
        ),
      );
      semantica.dispose();
    },
  );

  group('folha da nota (D-131)', () {
    testWidgets(
      'seleção nova: Salvar grava o grifo de fundo na última cor e a nota ligada; a seleção fecha',
      (tester) async {
        await tester.runAsync(
          () => KvDao(livro.db).set(lastHighlightColorKey, '#B6ACE4'),
        );
        await abrir(tester);
        final w = await selecionar(tester);
        await tocar(tester, 'r21.toolbar.actions.note');
        expect(_key('leitor.nota'), findsOneWidget);
        expect(
          findAppText(
            '“${_doc(tester).current.textOf(w.r.unit, w.r.from, w.r.to)}”',
          ),
          findsOneWidget,
        );
        await tester.enterText(_key('leitor.nota.campo'), 'olhos de ressaca');
        await tester.pump();
        await tocar(tester, 'leitor.nota.salvar');
        expect(_key('leitor.nota'), findsNothing);
        expect(_key('r21.toolbar'), findsNothing);
        final linhas = await vivos(tester);
        final grifo = linhas.singleWhere(
          (a) => a.kind == AnnotationKind.highlight,
        );
        final nota = linhas.singleWhere((a) => a.kind == AnnotationKind.note);
        expect((grifo.color, grifo.style), ('#B6ACE4', HighlightStyle.fill));
        expect(
          (nota.parentId, nota.groupId, nota.noteText),
          (grifo.id, grifo.groupId, 'olhos de ressaca'),
        );
      },
    );

    testWidgets(
      'Cancelar ou Voltar fecham só a folha; a seleção fica e nada é gravado',
      (tester) async {
        await abrir(tester);
        await selecionar(tester);
        await tocar(tester, 'r21.toolbar.actions.note');
        await tocar(tester, 'leitor.nota.cancelar');
        expect(_key('leitor.nota'), findsNothing);
        expect(_key('r21.toolbar'), findsOneWidget);
        await tocar(tester, 'r21.toolbar.actions.note');
        await tester.binding.handlePopRoute();
        await _quadros(tester);
        expect(_key('leitor.nota'), findsNothing);
        expect(_key('r21.toolbar'), findsOneWidget);
        expect(find.byType(ReaderScreen), findsOneWidget);
        expect(await vivos(tester), isEmpty);
      },
    );

    testWidgets(
      'D-138: seleção nova sobre um grifo com nota abre com a nota que vai ficar; Salvar edita ela',
      (tester) async {
        await abrir(tester);
        await selecionar(tester);
        await tocar(tester, 'r21.toolbar.actions.note');
        await tester.enterText(_key('leitor.nota.campo'), 'primeira');
        await tester.pump();
        await tocar(tester, 'leitor.nota.salvar');
        // de novo a pressão longa na mesma palavra: uma seleção nova, que vai unir com o grifo
        await selecionar(tester);
        await tocar(tester, 'r21.toolbar.actions.note');
        expect(find.text('primeira'), findsOneWidget);
        await tester.enterText(_key('leitor.nota.campo'), 'segunda');
        await tester.pump();
        await tocar(tester, 'leitor.nota.salvar');
        final linhas = await vivos(tester);
        expect(
          linhas.where((a) => a.kind == AnnotationKind.highlight),
          hasLength(1),
        );
        expect(
          linhas.singleWhere((a) => a.kind == AnnotationKind.note).noteText,
          'segunda',
        );
      },
    );

    testWidgets(
      'grifo existente com nota: abre com o texto; Salvar vazio apaga só a nota',
      (tester) async {
        await abrir(tester);
        final w = await selecionar(tester);
        await tocar(tester, 'r21.toolbar.actions.note');
        await tester.enterText(_key('leitor.nota.campo'), 'primeira');
        await tester.pump();
        await tocar(tester, 'leitor.nota.salvar');
        await tester.tapAt(w.rect.center);
        await _quadros(tester);
        await tocar(tester, 'r21.toolbar.actions.note');
        expect(find.text('primeira'), findsOneWidget);
        await tester.enterText(_key('leitor.nota.campo'), '');
        await tester.pump();
        await tocar(tester, 'leitor.nota.salvar');
        final linhas = await vivos(tester);
        expect(linhas.single.kind, AnnotationKind.highlight);
      },
    );
  });
}

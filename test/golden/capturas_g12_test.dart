// G12.5 — capturas dos controles do leitor para conferência (mandadas na conversa), 390×844 @3x pela rota real no
// mundo de referência:
// - a tela 20 em Creme, Branco e Sépia e a 26b (Noite);
// - a barra de posição sendo arrastada (o balão em outra página);
// - o painel da busca com resultados e, depois de tocar num deles, a palavra marcada na página com a pílula;
// - um PDF com os controles (a Fonte cinza — D-122).
// Só grava com BOOKNEST_CAPTURAS=<pasta>; sem a pasta, confere que cada tela chegou ao estado pedido.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:app_leitura/core/data/database/daos/content_daos.dart';
import 'package:app_leitura/core/data/database/daos/library_daos.dart';
import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/features/library/domain/user_book.dart';
import 'package:app_leitura/features/reader/application/reader_document.dart';
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:app_leitura/features/reader/presentation/reader_page_view.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdfrx/pdfrx.dart' show pdfrxInitialize;

import '../support/app_text_finder.dart';
import '../support/canvas.dart';
import '../support/capture.dart';
import '../support/dados_t20.dart';
import '../support/fase_l20.dart' show abrirTela20;
import '../support/load_fonts.dart';
import '../support/personal_builders.dart';
import '../support/pump_reader.dart';
import '../support/reader_harness.dart';

Finder _key(String k) => find.byKey(ValueKey<String>(k));

ReaderDocument _doc(WidgetTester tester) =>
    tester.widget<ReaderPageView>(find.byType(ReaderPageView)).document;

Future<void> _gravar(WidgetTester tester, String nome) async {
  final image = await captureAt(tester, find.byKey(goldenRootKey));
  expect((image.width, image.height), (1170, 2532));
  final pasta = Platform.environment['BOOKNEST_CAPTURAS'];
  if (pasta == null) return;
  final png = await tester.runAsync(
    () => image.toByteData(format: ui.ImageByteFormat.png),
  );
  Directory(pasta).createSync(recursive: true);
  File('$pasta${Platform.pathSeparator}$nome')
      .writeAsBytesSync(png!.buffer.asUint8List());
}

Future<void> _quadros(WidgetTester tester, [int n = 30]) async {
  for (var i = 0; i < n; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

void main() {
  setUpAll(loadAppFonts);

  for (final papel in ReaderPaper.values) {
    testWidgets(
      'tela ${papel == ReaderPaper.noite ? '26b' : '20'} em ${papel.code}',
      (tester) async {
        final livro = (await tester.runAsync(
          () => livroDaTela20(papel: papel),
        ))!;
        addTearDown(() => tester.runAsync(livro.close));
        await abrirTela20(tester, livro, golden: true);
        expect(_key('r20.topIsland'), findsOneWidget);
        await _gravar(tester, 'g12_tela20_${papel.code}_390x844@3x.png');
      },
    );
  }

  testWidgets('barra de posição arrastando: o balão em outra página', (
    tester,
  ) async {
    final livro = (await tester.runAsync(livroDaTela20))!;
    addTearDown(() => tester.runAsync(livro.close));
    await abrirTela20(tester, livro, golden: true);
    final botao = tester.getCenter(_key('r20.bottomIsland.scrubber.knob'));
    final g = await tester.startGesture(botao);
    await g.moveBy(const Offset(-30, 0));
    await tester.pump();
    await g.moveBy(const Offset(-50, 0));
    await tester.pump();
    final balao = tester
        .widget<AppText>(
          find.descendant(
            of: _key('r20.bottomIsland.scrubber.bubble'),
            matching: find.byType(AppText),
          ),
        )
        .span
        .toPlainText();
    expect(balao, isNot('pág. 159'));
    await _gravar(tester, 'g12_barra_arrastando_390x844@3x.png');
    await g.up();
    await _quadros(tester);
  });

  testWidgets(
    'busca: painel com resultados; tocar marca a palavra e mostra a pílula',
    (tester) async {
      final livro = (await tester.runAsync(livroDaTela20))!;
      addTearDown(() => tester.runAsync(livro.close));
      await abrirTela20(tester, livro, golden: true);
      await tester.tap(_key('r20.topIsland.search'));
      await tester.pump();
      await tester.enterText(_key('leitor.busca.campo'), 'olhos');
      await tester.pump(const Duration(milliseconds: 250));
      await _quadros(tester, 20);
      expect(_key('leitor.busca.contagem'), findsOneWidget);
      await _gravar(tester, 'g12_busca_resultados_390x844@3x.png');
      final resultado = find.byWidgetPredicate(
        (w) =>
            w.key is ValueKey<String> &&
            (w.key! as ValueKey<String>).value.startsWith(
              'leitor.busca.resultado.',
            ),
      );
      // o último resultado na tela (em geral noutra página: a pílula de voltar aparece)
      await tester.tap(resultado.last);
      await _quadros(tester, 40);
      expect(_doc(tester).found, isNotNull);
      if (_doc(tester).numbers.refPage != 159) {
        expect(findAppText('Voltar à pág. 159'), findsOneWidget);
      }
      await _gravar(tester, 'g12_palavra_marcada_390x844@3x.png');
    },
  );

  testWidgets('PDF com os controles: Fonte cinza (D-122)', (tester) async {
    final livro = (await tester.runAsync(LivroNaEstante.domCasmurro))!;
    final tmp = Directory.systemTemp.createTempSync('booknest_g12_cap_pdf_');
    addTearDown(
      () => tester.runAsync(() async {
        await livro.close();
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
      golden: true,
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
    await tester.tapAt(const Offset(195, 420));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    await _quadros(tester, 10);
    expect(_key('r20.bottomIsland.tools.font'), findsOneWidget);
    await _gravar(tester, 'g12_pdf_controles_390x844@3x.png');
  });
}

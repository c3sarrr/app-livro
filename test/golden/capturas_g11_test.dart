// G11.5 — capturas da tela do leitor para conferência (mandadas na conversa), 390×844 @3x pela rota real:
// - os 4 papéis (D-110) na página do mundo de referência (pág. 159 de 256, 62 %);
// - o "Voltar à pág. N" depois do link "Indice" da folha de rosto do Dom Casmurro real (D-108);
// - um PDF com páginas de tamanhos diferentes (D-109), na 1ª (A4) e na 3ª (A4 deitada);
// - uma página com imagem (D-114).
// Só grava com BOOKNEST_CAPTURAS=<pasta>; sem a pasta, confere que cada tela abriu com o papel pedido.
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:app_leitura/core/data/database/daos/content_daos.dart';
import 'package:app_leitura/core/data/database/daos/library_daos.dart';
import 'package:app_leitura/core/data/database/daos/reader_daos.dart';
import 'package:app_leitura/features/library/domain/user_book.dart';
import 'package:app_leitura/features/reader/application/reader_document.dart';
import 'package:app_leitura/features/reader/content/chapter_content.dart';
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:app_leitura/features/reader/presentation/reader_page_view.dart';
import 'package:app_leitura/features/reader/presentation/reader_palette.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdfrx/pdfrx.dart' show pdfrxInitialize;

import '../support/canvas.dart';
import '../support/capture.dart';
import '../support/epub_builder.dart';
import '../support/load_fonts.dart';
import '../support/personal_builders.dart';
import '../support/pump_reader.dart';
import '../support/reader_harness.dart';

Finder _key(String k) => find.byKey(ValueKey<String>(k));

ReaderDocument _doc(WidgetTester tester) =>
    tester.widget<ReaderPageView>(find.byType(ReaderPageView)).document;

/// Grava a tela inteira @3x em BOOKNEST_CAPTURAS (se houver).
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

/// Deixa o trabalho de verdade (PDFium, decodificar imagem) andar entre os quadros.
Future<void> _esperarDeVerdade(
  WidgetTester tester,
  bool Function() pronto,
) async {
  for (var i = 0; i < 200 && !pronto(); i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 16));
  }
  expect(pronto(), isTrue);
  await tester.pumpAndSettle();
}

Future<Uint8List> _ilustracao() async {
  final rec = ui.PictureRecorder();
  final c = ui.Canvas(rec);
  final tinta = ui.Paint()..color = const ui.Color(0xFF1B1A17);
  c
    ..drawRect(const ui.Rect.fromLTWH(0, 0, 600, 360), tinta)
    ..drawRect(
      const ui.Rect.fromLTWH(12, 12, 576, 336),
      ui.Paint()..color = const ui.Color(0xFFE9C46A),
    )
    ..drawCircle(const ui.Offset(190, 180), 96, tinta)
    ..drawRect(
      const ui.Rect.fromLTWH(330, 90, 200, 180),
      ui.Paint()..color = const ui.Color(0xFFE76F51),
    );
  final img = await rec.endRecording().toImage(600, 360);
  final data = await img.toByteData(format: ui.ImageByteFormat.png);
  img.dispose();
  return data!.buffer.asUint8List();
}

void main() {
  setUpAll(loadAppFonts);

  for (final papel in ReaderPaper.values) {
    testWidgets('papel ${papel.code} (D-110)', (tester) async {
      final livro = (await tester.runAsync(livroDaTela19))!;
      addTearDown(() => tester.runAsync(livro.close));
      await tester.runAsync(
        () => ReaderSettingsDao(livro.db).upsert(
          ReaderSettings(id: usuarioTeste, meta: metaTeste(), paper: papel),
        ),
      );
      setCanvasView(tester, logical: const Size(390, 844));
      await abrirLeitor(tester, livro, golden: true);
      final fundo = tester.widget<ColoredBox>(
        find
            .ancestor(
              of: find.byType(ReaderPageView),
              matching: find.byType(ColoredBox),
            )
            .first,
      );
      expect(fundo.color, ReaderPalette.of(papel).paper);
      await _gravar(tester, 'g11_tela19_${papel.code}_390x844@3x.png');
    });
  }

  testWidgets('"Voltar à pág. N" depois do link do Indice (D-108)', (
    tester,
  ) async {
    final livro = (await tester.runAsync(LivroNaEstante.domCasmurro))!;
    addTearDown(() => tester.runAsync(livro.close));
    final rosto = livro.index.spine.indexWhere(
      (s) => s.path.endsWith('55752-h-0.htm.xhtml'),
    );
    final indice = chapterOf(livro.epub, rosto).item.text.indexOf('Indice');
    await tester.runAsync(() => livro.guardarPosicao(rosto, indice));
    setCanvasView(tester, logical: const Size(390, 844));
    await abrirLeitor(tester, livro, golden: true);
    Offset? alvo;
    for (var y = 92.0; y < 762 && alvo == null; y += 3) {
      for (var x = 28.0; x < 362 && alvo == null; x += 3) {
        if (_doc(tester).current.linkAt(Offset(x, y)) != null) {
          alvo = Offset(x + 3, y + 3);
        }
      }
    }
    await tester.tapAt(alvo!);
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(_key('leitor.voltarDoLink'), findsOneWidget);
    await _gravar(tester, 'g11_link_voltar_390x844@3x.png');
  });

  testWidgets('PDF com páginas de tamanhos diferentes (D-109)', (tester) async {
    final livro = (await tester.runAsync(LivroNaEstante.domCasmurro))!;
    final tmp = Directory.systemTemp.createTempSync('booknest_g11_cap_pdf_');
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
      final copia = File('test/fixtures/livros/tamanhos.pdf')
          .copySync('${tmp.path}${Platform.pathSeparator}tamanhos.pdf');
      await UserBooksDao(livro.db).upsert(
        livro.book.copyWith(format: BookFileFormat.pdf, title: 'Tamanhos'),
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
    await _esperarDeVerdade(
      tester,
      () => _key('r19.footer').evaluate().isNotEmpty,
    );
    expect(_doc(tester).numbers.pageLabel, 'pág. 1 de 3');
    await _gravar(tester, 'g11_pdf_a4_390x844@3x.png');
    for (var i = 0; i < 2; i++) {
      await tester.tapAt(const Offset(360, 420));
      await _esperarDeVerdade(
        tester,
        () => _doc(tester).numbers.refPage == i + 2,
      );
    }
    await _gravar(tester, 'g11_pdf_a4_deitada_390x844@3x.png');
  });

  testWidgets('página com imagem (D-114)', (tester) async {
    final png = (await tester.runAsync(_ilustracao))!;
    final livro = (await tester.runAsync(
      () async => LivroNaEstante.epubDe(
        simpleEpub(
          title: 'Ilustrado',
          chapters: [
            (
              file: 'c1.xhtml',
              title: 'Um',
              body:
                  '<p>Na manhã seguinte, o jardim amanheceu diferente: as flores tinham '
                  'mudado de lugar durante a noite.</p><img src="fig.png" alt="o jardim"/>'
                  '<p>Ninguém soube explicar como.</p>',
            ),
          ],
          extra: {'OEBPS/fig.png': png},
        ),
        title: 'Ilustrado',
      ),
    ))!;
    addTearDown(() => tester.runAsync(livro.close));
    setCanvasView(tester, logical: const Size(390, 844));
    await abrirLeitor(tester, livro, golden: true);
    // a imagem é decodificada de verdade (fora do relógio falso)
    for (var i = 0; i < 20; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 16));
    }
    await _gravar(tester, 'g11_imagem_390x844@3x.png');
  });
}

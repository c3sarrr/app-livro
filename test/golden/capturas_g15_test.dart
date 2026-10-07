// G15.5 — capturas da folha do sumário (telas 27 e 27b), para conferência (mandadas na conversa), 390×844 @3x:
// - pela rota real no mundo de referência: as duas abas em Creme e no Noite; a lista no cap. CXXXVIII (os numerais
//   largos inteiros, no espaço ao lado — D-157); a fita tirada na aba Marcadas (D-152);
// - a folha sozinha sobre o papel do leitor: um livro com partes (D-153) e um livro sem sumário (D-21).
// Só grava com BOOKNEST_CAPTURAS=<pasta>; sem a pasta, confere que cada tela chegou ao estado pedido.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:app_leitura/core/data/database/daos/reader_daos.dart';
import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_icons_leitor.dart';
import 'package:app_leitura/core/design_system/widgets/app_svg.dart';
import 'package:app_leitura/features/reader/application/toc_view.dart';
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:app_leitura/features/reader/presentation/reader_palette.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../features/reader/presentation/toc_support.dart';
import '../fixtures/mundo_2026_09_20.dart';
import '../fixtures/telas/indice_t27.dart';
import '../support/canvas.dart';
import '../support/capture.dart';
import '../support/dados_t20.dart';
import '../support/fase_l27.dart';
import '../support/load_fonts.dart';
import '../support/reader_harness.dart';

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

/// O Dom Casmurro da tela 27 com o papel da conta trocado.
Future<LivroNaEstante> _livro(ReaderPaper papel) async {
  final livro = await livroDaTela20(papel: papel);
  await livro.usarIndice(indiceDaTela27(livro.index));
  await ReaderSettingsDao(livro.db)
      .upsert(mundoReferencia.ajustes.withLook(ReaderLook(paper: papel)));
  return livro;
}

/// Espera o banco (a gravação da fita e a releitura da folha) e a tela.
Future<void> _banco(WidgetTester tester) async {
  for (var i = 0; i < 15; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 16));
  }
}

/// A folha sozinha sobre o papel do leitor, com a [view] montada à mão.
Future<void> _folha(WidgetTester tester, TocView view) async {
  setCanvasView(tester, logical: const Size(390, 844));
  await tester.pumpWidget(const SizedBox());
  await montarSumario(tester, view: view);
  final m = MesaDoSumario();
  await tester.pumpWidget(
    RepaintBoundary(
      key: goldenRootKey,
      child: ColoredBox(
        color: ReaderPalette.of(ReaderPaper.creme).paper,
        child: folhaDoSumario(m, open: true, view: view),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 160));
  await tester.pump();
}

void main() {
  setUpAll(loadAppFonts);

  for (final papel in const [ReaderPaper.creme, ReaderPaper.noite]) {
    for (final marcadas in const [false, true]) {
      final tela = marcadas ? '27b' : '27';
      testWidgets('tela $tela em ${papel.code}', (tester) async {
        final livro = (await tester.runAsync(() => _livro(papel)))!;
        addTearDown(() => tester.runAsync(livro.close));
        await abrirTela27(tester, livro, golden: true, marcadas: marcadas);
        expect(
          find.byKey(ValueKey(marcadas ? 'bm.sheet' : 'toc.sheet')),
          findsOneWidget,
        );
        await _gravar(tester, 'g15_tela${tela}_${papel.code}_390x844@3x.png');
      });
    }
  }

  testWidgets('a lista no cap. CXXXVIII: os numerais largos inteiros (D-157)', (
    tester,
  ) async {
    final livro = (await tester.runAsync(() => _livro(ReaderPaper.creme)))!;
    addTearDown(() => tester.runAsync(livro.close));
    await abrirTela27(tester, livro, golden: true);
    // o cap. CXXXVIII no meio da lista
    await Scrollable.ensureVisible(
      tester.element(find.byKey(const ValueKey('toc.sheet.chapters.ch138'))),
      alignment: 0.5,
    );
    await tester.pump();
    final numeral = find.descendant(
      of: find.byKey(const ValueKey('toc.sheet.chapters.ch138.numeral')),
      matching: find.byType(AppText),
    );
    expect(tester.widget<AppText>(numeral).span.toPlainText(), 'CXXXVIII');
    expect(tester.getSize(numeral).width, greaterThan(52));
    await _gravar(tester, 'g15_numerais_largos_390x844@3x.png');
  });

  testWidgets('Marcadas: a fita tirada fica no cartão até fechar (D-152)', (
    tester,
  ) async {
    final livro = (await tester.runAsync(() => _livro(ReaderPaper.creme)))!;
    addTearDown(() => tester.runAsync(livro.close));
    await abrirTela27(tester, livro, golden: true, marcadas: true);
    await tester.tap(
      find.byKey(const ValueKey('bm.sheet.bookmarks.item1.ribbon')),
    );
    await _banco(tester);
    expect(
      tester
          .widget<AppSvg>(
            find.byKey(const ValueKey('bm.sheet.bookmarks.item1.ribbon.icon')),
          )
          .asset,
      AppIconsLeitor.ribbonEmpty,
    );
    await _gravar(tester, 'g15_fita_tirada_390x844@3x.png');
  });

  testWidgets('um livro com partes (D-153)', (tester) async {
    TocRow parte(int entrada, String titulo) => TocRow(
      kind: TocRowKind.part,
      entry: entrada,
      title: titulo,
      target: (spine: entrada, offset: 0),
    );
    final linhas = [
      parte(0, 'Primeira parte'),
      linha(0, numeral: 'I', titulo: 'A chegada', pagina: 1, lido: true),
      linha(1, numeral: 'II', titulo: 'O porto', pagina: 9, lido: true),
      linha(
        2,
        numeral: 'III',
        titulo: 'A casa da colina',
        pagina: 17,
        atual: true,
        progresso: 0.4,
      ),
      parte(10, 'Segunda parte'),
      linha(3, numeral: 'IV', titulo: 'O inverno', pagina: 31),
      linha(4, numeral: 'V', titulo: 'Cartas', pagina: 40),
      parte(20, 'Epílogo'),
      linha(5, numeral: 'VI', titulo: 'Depois', pagina: 52),
    ];
    await _folha(
      tester,
      TocView(
        subtitle: 'A casa da colina · 6 capítulos',
        chapters: 6,
        bookmarks: 0,
        rows: linhas,
        currentRow: 3,
        refPage: 19,
        club: null,
        cards: const [],
      ),
    );
    expect(
      find.byKey(const ValueKey('toc.sheet.chapters.part10')),
      findsOneWidget,
    );
    await _gravar(tester, 'g15_partes_390x844@3x.png');
  });

  testWidgets('um livro sem sumário (D-21)', (tester) async {
    await _folha(
      tester,
      const TocView(
        subtitle: 'Cartas sem data',
        chapters: null,
        bookmarks: 0,
        rows: [],
        currentRow: null,
        refPage: 1,
        club: null,
        cards: [],
      ),
    );
    expect(find.byKey(const ValueKey('toc.sheet.empty')), findsOneWidget);
    await _gravar(tester, 'g15_sem_sumario_390x844@3x.png');
  });
}

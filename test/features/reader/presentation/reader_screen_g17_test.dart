// G17 — os painéis e o marca-texto pela rota real, com o Dom Casmurro do Gutenberg num banco em memória: o 2º toque no
// Marca-texto abre o painel da 23b com os rótulos e as contagens do banco (D-40); "Editar rótulos" abre a folha sobre
// o painel, Salvar grava e volta com o rótulo novo, Cancelar não grava e o Voltar fecha a folha primeiro (D-177, D-42
// por camadas); o marca-texto sobre o grifo amarelo da página une com ele (D-173) e o Concluir grava.
import 'package:app_leitura/core/data/database/daos/annotation_daos.dart';
import 'package:app_leitura/features/reader/annotations/domain/annotation.dart';
import 'package:app_leitura/features/reader/annotations/domain/highlight_label.dart';
import 'package:app_leitura/features/reader/application/annotation_session.dart';
import 'package:app_leitura/features/reader/application/reader_document.dart';
import 'package:app_leitura/features/reader/domain/locator.dart';
import 'package:app_leitura/features/reader/presentation/annotation_mode.dart';
import 'package:app_leitura/features/reader/presentation/reader_page_view.dart';
import 'package:flutter/material.dart' show TextField;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/app_text_finder.dart';
import '../../../support/canvas.dart';
import '../../../support/load_fonts.dart';
import '../../../support/personal_builders.dart';
import '../../../support/pump_reader.dart';
import '../../../support/reader_harness.dart';

Finder _key(String k) => find.byKey(ValueKey<String>(k));

ReaderDocument _doc(WidgetTester tester) =>
    tester.widget<ReaderPageView>(find.byType(ReaderPageView)).document;

Future<void> _quadros(WidgetTester tester, [int n = 30]) async {
  for (var i = 0; i < n; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

/// Espera o banco e a tela.
Future<void> _banco(WidgetTester tester) async {
  for (var i = 0; i < 15; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 16));
  }
}

/// Controles → "Anotar" → a camada entra.
Future<void> _anotar(WidgetTester tester) async {
  await tester.tapAt(const Offset(195, 420));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 150));
  await _quadros(tester, 6);
  await tester.tap(_key('r20.bottomIsland.tools.annotate'));
  await _banco(tester);
  await _quadros(tester, 20);
  expect(_key('ann.island'), findsOneWidget);
}

AnnotationSession _sessao(WidgetTester tester) =>
    tester.widget<AnnotationMode>(find.byType(AnnotationMode)).session;

/// O Marca-texto e o 2º toque: o painel da 23b entra (150 ms).
Future<void> _painelDoMarcaTexto(WidgetTester tester) async {
  await tester.tap(_key('ann.toolShelf.marker'));
  await tester.pump();
  await tester.tap(_key('ann.toolShelf.marker'));
  await tester.pump();
  await _quadros(tester, 12);
  expect(_key('ann.markerPanel'), findsOneWidget);
}

void main() {
  setUpAll(loadAppFonts);

  late LivroNaEstante livro;
  setUp(() async {
    livro = await LivroNaEstante.domCasmurro();
    await livro.guardarPosicao(2, livro.index.spine[2].chars ~/ 2);
  });
  tearDown(() async => livro.close());

  /// Os rótulos de [livro.leitor] e 2 grifos amarelos e 1 rosa em outros livros.
  Future<void> semear(WidgetTester tester) async {
    await tester.runAsync(() async {
      final rotulos = HighlightLabelsDao(livro.db);
      await rotulos.upsert(
        HighlightLabel(
          id: idTeste(40),
          meta: metaTeste(userId: livro.leitor),
          color: '#FED170',
          label: 'lindo',
        ),
      );
      final grifos = AnnotationsDao(livro.db);
      for (final (n, cor) in [
        (41, '#FED170'),
        (42, '#FED170'),
        (43, '#FFC1C6'),
      ]) {
        await grifos.upsert(
          grifoTeste(n, livro: idTeste(90), cor: cor, dono: livro.leitor),
        );
      }
    });
  }

  testWidgets(
    'o 2º toque no Marca-texto abre a 23b com os rótulos e as contagens do banco (D-40)',
    (tester) async {
      setCanvasView(tester, logical: const Size(390, 844));
      await semear(tester);
      await abrirLeitor(tester, livro);
      await _anotar(tester);
      await _painelDoMarcaTexto(tester);
      expect(findAppText('Fundo · amarelo “lindo” · média'), findsOneWidget);
      expect(findAppText('lindo'), findsOneWidget);
      expect(findAppText('2 grifos'), findsOneWidget);
      expect(findAppText('1 grifo'), findsOneWidget);
      expect(findAppText('0 grifos'), findsNWidgets(2));
    },
  );

  testWidgets(
    '"Editar rótulos": a folha sobre o painel; o Voltar e Cancelar fecham sem gravar; Salvar grava e volta com o rótulo novo (D-177)',
    (tester) async {
      setCanvasView(tester, logical: const Size(390, 844));
      await semear(tester);
      await abrirLeitor(tester, livro);
      await _anotar(tester);
      await _painelDoMarcaTexto(tester);
      Future<void> abrirFolha() async {
        await tester.tap(_key('ann.markerPanel.colorsHeader.editLabels'));
        await tester.pump();
        expect(_key('ann.labels'), findsOneWidget);
      }

      await abrirFolha();
      // o Voltar fecha só a folha (o painel fica)
      await tester.binding.handlePopRoute();
      await tester.pump();
      expect(_key('ann.labels'), findsNothing);
      expect(_key('ann.markerPanel'), findsOneWidget);
      await abrirFolha();
      await tester.enterText(_key('ann.labels.pink.field'), 'personagem');
      await tester.tap(_key('ann.labels.cancel'));
      await tester.pump();
      expect(_key('ann.labels'), findsNothing);
      expect(findAppText('personagem'), findsNothing);
      await abrirFolha();
      expect(
        tester
            .widget<TextField>(_key('ann.labels.yellow.field'))
            .controller!
            .text,
        'lindo',
      );
      await tester.enterText(_key('ann.labels.yellow.field'), 'lindo demais');
      await tester.enterText(_key('ann.labels.pink.field'), 'personagem');
      await tester.tap(_key('ann.labels.save'));
      await _banco(tester);
      expect(_key('ann.labels'), findsNothing);
      expect(
        findAppText('Fundo · amarelo “lindo demais” · média'),
        findsOneWidget,
      );
      expect(findAppText('personagem'), findsOneWidget);
      final gravados = await tester.runAsync(
        () => HighlightLabelsDao(livro.db).forUser(livro.leitor),
      );
      expect(
        {for (final l in gravados!) l.color: l.label},
        {'#FED170': 'lindo demais', '#FFC1C6': 'personagem'},
      );
      expect(_sessao(tester).labels['#FFC1C6'], 'personagem');
    },
  );

  testWidgets(
    'o marca-texto sobre o grifo amarelo da página une com ele (D-173) e o Concluir grava',
    (tester) async {
      setCanvasView(tester, logical: const Size(390, 844));
      await abrirLeitor(tester, livro);
      final pagina = _doc(tester).current;
      final shown = pagina.shown!;
      // a 1ª linha da página: o grifo amarelo nas primeiras palavras (de seleção, criado antes)
      final linha = pagina
          .boxesOf(shown.unit, shown.from, shown.from + 1)
          .first;
      final texto = pagina.textOf(shown.unit, shown.from, shown.to);
      final primeira = RegExp(r'\S+').firstMatch(texto)!;
      final grifo = Annotation(
        id: idTeste(50),
        meta: metaTeste(userId: livro.leitor),
        userBookId: livro.userBookId,
        kind: AnnotationKind.highlight,
        groupId: idTeste(50),
        anchor: EpubAnchor(
          sha: livro.index.contentSha256,
          spine: shown.unit,
          start: shown.from + primeira.start,
          end: shown.from + primeira.end,
          quote: TextQuote(exact: primeira.group(0)!),
          refPage: 1,
        ),
        refPage: 1,
        chapterIndex: 0,
        color: '#FED170',
        style: HighlightStyle.fill,
        fillHeight: FillHeight.medium,
      );
      await tester.runAsync(() => AnnotationsDao(livro.db).upsert(grifo));
      await _banco(tester);
      await _anotar(tester);
      expect(_sessao(tester).desk.items.map((h) => h.id), [grifo.id]);
      await tester.tap(_key('ann.toolShelf.marker'));
      await tester.pump();
      // o traço amarelo ao longo da 1ª linha inteira (30 abaixo no modo)
      final y = (linha.textTop + linha.textBottom) / 2 + annotationTextShift;
      final g = await tester.startGesture(Offset(linha.rect.left + 2, y));
      for (var i = 1; i <= 10; i++) {
        await g.moveTo(
          Offset(linha.rect.left + 2 + 25.0 * i, y),
          timeStamp: Duration(milliseconds: 16 * i),
        );
      }
      await g.up();
      await tester.pump();
      final mesa = _sessao(tester).desk.items;
      expect(mesa.map((h) => h.id), [
        grifo.id,
      ], reason: 'uniu com o mais antigo');
      expect(mesa.single.end, greaterThan((grifo.anchor as EpubAnchor).end));
      await tester.tap(_key('ann.done'));
      await _banco(tester);
      await _quadros(tester, 20);
      final linhas = await tester.runAsync(
        () => AnnotationsDao(livro.db).forBook(livro.userBookId),
      );
      final salvo = linhas!.singleWhere((a) => a.id == grifo.id);
      expect((salvo.anchor as EpubAnchor).end, mesa.single.end);
      expect(salvo.source, AnnotationSource.selection);
      expect(
        linhas.where((a) => a.kind == AnnotationKind.highlight),
        hasLength(1),
      );
    },
  );
}

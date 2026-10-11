// G17 — os painéis e o marca-texto pela rota real, com o Dom Casmurro do Gutenberg num banco em memória: o 2º toque no
// Marca-texto abre o painel da 23b com os rótulos e as contagens do banco (D-40); "Editar rótulos" abre a folha sobre
// o painel, Salvar grava e volta com o rótulo novo, Cancelar não grava e o Voltar fecha a folha primeiro (D-177, D-42
// por camadas); o marca-texto sobre o grifo amarelo da página une com ele (D-173) e o Concluir grava. G17.7
// (comportamento): os ajustes da caneta gravam o `pen_presets` e valem no traço seguinte; o marca-texto na margem
// fica como tinta translúcida e aparece no leitor limpo (R22); o rosa no meio de um amarelo de seleção o corta, o
// Desfazer e o Refazer voltam e o Concluir grava os 3; no Noite, a tinta preta sai na cor das letras (D-174).
import 'package:app_leitura/core/data/database/daos/annotation_daos.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/features/reader/annotations/domain/pen_presets.dart';
import 'package:app_leitura/features/reader/annotations/ink/bnk1_codec.dart';
import 'package:app_leitura/features/reader/annotations/ink/ink_stroke.dart';
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
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
import '../../../support/capture.dart';
import '../../../support/dados_t23.dart';
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
    'os rótulos que não abrem (o banco falhou): o modo abre com os nomes das cores e a falha vai ao relatório',
    (tester) async {
      setCanvasView(tester, logical: const Size(390, 844));
      final t = await abrirLeitor(tester, livro);
      await tester.runAsync(
        () => livro.db.customStatement('DROP TABLE highlight_labels'),
      );
      await _anotar(tester);
      expect(t.erros, isNotEmpty);
      await _painelDoMarcaTexto(tester);
      expect(findAppText('Fundo · amarelo · média'), findsOneWidget);
      expect(findAppText('0 grifos'), findsNWidgets(4));
    },
  );

  testWidgets(
    'Salvar que falha: a folha "Rótulos" fica com o que foi digitado e a falha vai ao relatório',
    (tester) async {
      setCanvasView(tester, logical: const Size(390, 844));
      await semear(tester);
      final t = await abrirLeitor(tester, livro);
      await _anotar(tester);
      await _painelDoMarcaTexto(tester);
      await tester.tap(_key('ann.markerPanel.colorsHeader.editLabels'));
      await tester.pump();
      await tester.runAsync(
        () => livro.db.customStatement('DROP TABLE highlight_labels'),
      );
      await tester.enterText(_key('ann.labels.pink.field'), 'personagem');
      await tester.tap(_key('ann.labels.save'));
      await _banco(tester);
      expect(t.erros, isNotEmpty);
      expect(_key('ann.labels'), findsOneWidget);
      expect(
        tester
            .widget<TextField>(_key('ann.labels.pink.field'))
            .controller!
            .text,
        'personagem',
      );
      expect(_sessao(tester).labels, {'#FED170': 'lindo'});
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

  testWidgets(
    'os ajustes da caneta gravam o pen_presets e valem no traço seguinte',
    (tester) async {
      setCanvasView(tester, logical: const Size(390, 844));
      await abrirLeitor(tester, livro);
      await _anotar(tester);
      await tester.tap(_key('ann.toolShelf.pen'));
      await tester.pump();
      await _quadros(tester, 12);
      expect(_key('ann.penPanel'), findsOneWidget);
      await tester.tap(_key('ann.penPanel.tips.fountain'));
      await _banco(tester);
      await tester.tap(_key('ann.penPanel.picker.hex'));
      await tester.pump();
      await tester.enterText(find.byType(EditableText), '058cd7');
      await _banco(tester);
      final gravado = await tester.runAsync(
        () => PenPresetsDao(livro.db).forUser(livro.leitor),
      );
      expect((gravado!.penTip, gravado.penColor), (PenTip.fountain, '#058CD7'));
      await tester.tap(_key('ann.penPanel.close'));
      await tester.pump();
      await _quadros(tester, 12);
      expect(_key('ann.penPanel'), findsNothing);
      final g = await tester.startGesture(const Offset(80, 330));
      for (var i = 1; i <= 6; i++) {
        await g.moveTo(
          Offset(80 + 20.0 * i, 332),
          timeStamp: Duration(milliseconds: 16 * i),
        );
      }
      await g.up();
      await tester.pump();
      final t = _sessao(tester).visibleStrokes.single;
      expect((t.tip, t.argb), (tipCode(PenTip.fountain), 0xFF058CD7));
    },
  );

  testWidgets(
    'o marca-texto na margem fica como tinta translúcida e aparece no leitor limpo (R22)',
    (tester) async {
      setCanvasView(tester, logical: const Size(390, 844));
      await abrirLeitor(tester, livro);
      final pagina = _doc(tester).current;
      final shown = pagina.shown!;
      final linha = pagina
          .boxesOf(shown.unit, shown.from, shown.from + 1)
          .first;
      await _anotar(tester);
      await tester.tap(_key('ann.toolShelf.marker'));
      await tester.pump();
      // do lado de fora das letras, na altura da 1ª linha (30 abaixo no modo)
      final y = (linha.textTop + linha.textBottom) / 2 + annotationTextShift;
      final g = await tester.startGesture(Offset(linha.rect.left - 20, y));
      await g.moveTo(
        Offset(linha.rect.left - 6, y),
        timeStamp: const Duration(milliseconds: 16),
      );
      await g.up();
      await tester.pump();
      expect(_sessao(tester).desk.items, isEmpty);
      expect(_sessao(tester).visibleStrokes.single.tool, InkTool.marker.code);
      await tester.tap(_key('ann.done'));
      await _banco(tester);
      await _quadros(tester, 20);
      final camadas = await tester.runAsync(
        () => InkLayersDao(livro.db).liveOverTextForBook(livro.userBookId),
      );
      final tracos = decodeStrokesB64(camadas!.single.strokesB64, Bnk1Unit.em);
      expect(
        (tracos.single.tool, tracos.single.argb),
        (InkTool.marker.code, 0xE6FED170),
      );
      final desenhos = tester
          .widget<ReaderPageView>(find.byType(ReaderPageView))
          .ink!
          .drawingsOn(_doc(tester).current);
      expect(desenhos.single.strokes.single.tool, InkTool.marker.code);
    },
  );

  testWidgets(
    'o rosa no meio de um amarelo de seleção o corta; Desfazer e Refazer; o Concluir grava os 3 (D-173)',
    (tester) async {
      setCanvasView(tester, logical: const Size(390, 844));
      await abrirLeitor(tester, livro);
      final pagina = _doc(tester).current;
      final shown = pagina.shown!;
      final texto = pagina.textOf(shown.unit, shown.from, shown.to);
      final palavras = RegExp(
        r'[\p{L}]{3,}',
        unicode: true,
      ).allMatches(texto).take(3).toList();
      final a = shown.from + palavras.first.start;
      final z = shown.from + palavras.last.end;
      final grifo = Annotation(
        id: idTeste(60),
        meta: metaTeste(userId: livro.leitor),
        userBookId: livro.userBookId,
        kind: AnnotationKind.highlight,
        groupId: idTeste(60),
        anchor: EpubAnchor(
          sha: livro.index.contentSha256,
          spine: shown.unit,
          start: a,
          end: z,
          quote: TextQuote(
            exact: texto.substring(a - shown.from, z - shown.from),
          ),
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
      await _painelDoMarcaTexto(tester);
      await tester.tap(_key('ann.markerPanel.colors.pink'));
      await tester.pump();
      await tester.tap(_key('ann.markerPanel.close'));
      await tester.pump();
      await _quadros(tester, 12);
      // sobre a 2ª palavra
      final meio = palavras[1];
      final caixa = pagina
          .boxesOf(shown.unit, shown.from + meio.start, shown.from + meio.end)
          .first;
      final y = (caixa.textTop + caixa.textBottom) / 2 + annotationTextShift;
      final g = await tester.startGesture(Offset(caixa.rect.left + 1, y));
      await g.moveTo(
        Offset(caixa.rect.right - 1, y),
        timeStamp: const Duration(milliseconds: 16),
      );
      await g.up();
      await tester.pump();
      final s = _sessao(tester);
      expect(s.desk.items, hasLength(3));
      await tester.tap(_key('ann.island.undo'));
      await tester.pump();
      expect(s.desk.items.map((h) => h.id), [grifo.id]);
      await tester.tap(_key('ann.island.redo'));
      await tester.pump();
      expect(s.desk.items, hasLength(3));
      await tester.tap(_key('ann.done'));
      await _banco(tester);
      await _quadros(tester, 20);
      final linhas = [
        for (final x in (await tester.runAsync(
          () => AnnotationsDao(livro.db).forBook(livro.userBookId),
        ))!)
          if (x.kind == AnnotationKind.highlight) x,
      ];
      expect(linhas, hasLength(3));
      final amarelo = linhas.singleWhere((x) => x.id == grifo.id);
      expect(
        (amarelo.anchor as EpubAnchor).end,
        lessThanOrEqualTo(shown.from + meio.start),
      );
      final rosa = linhas.singleWhere((x) => x.color == '#FFC1C6');
      expect(rosa.source, AnnotationSource.ink);
      final direita = linhas.singleWhere(
        (x) => x.id != grifo.id && x.color == '#FED170',
      );
      expect(
        (direita.source, direita.groupId, (direita.anchor as EpubAnchor).end),
        (AnnotationSource.selection, grifo.groupId, z),
      );
    },
  );

  testWidgets(
    'Noite: o painel nas cores do Noite e a tinta preta sai na cor das letras (D-174)',
    (tester) async {
      final noite = await livroDaTela23(papel: ReaderPaper.noite);
      addTearDown(noite.close);
      await abrirTela23(tester, noite, golden: true);
      expect(
        (tester.widget<Container>(_key('ann.penPanel')).decoration!
                as BoxDecoration)
            .color,
        AppColors.islandNight,
      );
      await tester.tap(_key('ann.penPanel.favorites.black'));
      await _banco(tester);
      await tester.tap(_key('ann.penPanel.close'));
      await tester.pump();
      await _quadros(tester, 12);
      final g = await tester.startGesture(const Offset(120, 420));
      for (var i = 1; i <= 6; i++) {
        await g.moveTo(
          Offset(120 + 15.0 * i, 420),
          timeStamp: Duration(milliseconds: 16 * i),
        );
      }
      await g.up();
      await tester.pump();
      await _quadros(tester, 4);
      // o traço novo (pode entrar num desenho do mundo que ele toca — D-162)
      expect(
        _sessao(tester).visibleStrokes.where((t) => t.argb == 0xFF1A1714),
        hasLength(1),
      );
      final img = await captureAt(tester, find.byKey(goldenRootKey));
      final rgba = await rgbaOf(tester, img);
      final i = ((420 * 3) * img.width + 165 * 3) * 4;
      expect((rgba[i], rgba[i + 1], rgba[i + 2]), (0xE3, 0xD9, 0xC6));
    },
  );
}

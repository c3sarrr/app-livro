// G11.3 — a tela 19 pela rota real `/leitor/:bookId`, com o Dom Casmurro de verdade num banco em memória: a
// página e o rodapé nos lugares do arquivo (e com as áreas do aparelho — D-112), virar pelo toque grava a
// posição ao sair, o Voltar do Android, a barra de status (D-105), o ciclo de vida com a tela acesa (D-111), o
// "abrindo" depois de 300 ms e os erros (D-21), o link do "Indice" com a pílula de voltar (D-108) e o leitor de
// tela (Anexo 03 §11).
// G12.3 — os controles das telas 20/26b (D-117…D-124): abrir e fechar (centro, fora das ilhas, arrasto, Voltar)
// em 150 ms, a barra de status, as ilhas com o aparelho, o Tema em 220 ms, a fita, a barra de posição com a
// pílula, os avisos das próximas fases e o PDF.
import 'dart:async';

import 'package:app_leitura/core/data/database/daos/content_daos.dart';
import 'package:app_leitura/core/data/database/daos/library_daos.dart';
import 'package:app_leitura/core/data/database/daos/reader_daos.dart';
import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/features/reader/application/reader_document.dart';
import 'package:app_leitura/features/reader/content/book_index.dart';
import 'package:app_leitura/features/reader/content/chapter_content.dart';
import 'package:app_leitura/features/reader/domain/locator.dart';
import 'package:app_leitura/features/reader/presentation/reader_page_view.dart';
import 'package:app_leitura/features/reader/presentation/reader_screen.dart';
import 'package:flutter/semantics.dart' show CustomSemanticsAction;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/app_text_finder.dart';
import '../../../support/canvas.dart';
import '../../../support/load_fonts.dart';
import '../../../support/personal_builders.dart';
import '../../../support/pump_reader.dart';
import '../../../support/reader_harness.dart';

Finder _key(String k) => find.byKey(ValueKey<String>(k));

/// O documento aberto na tela (o da página).
ReaderDocument _doc(WidgetTester tester) =>
    tester.widget<ReaderPageView>(find.byType(ReaderPageView)).document;

/// Quadros para a fila de layout e o banco andarem.
Future<void> _quadros(WidgetTester tester, [int n = 40]) async {
  for (var i = 0; i < n; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

/// A pílula "Voltar à pág. N" no vão entre "pág. X de Y" e "%" (D-108): centralizada nele, na altura da linha
/// do rodapé, sem cobrir os números (8 px de folga de cada lado).
void _pilulaNoVao(WidgetTester tester) {
  final pilula = tester.getRect(_key('leitor.voltarDoLink'));
  final pag = tester.getRect(_key('r19.footer.pageLabel'));
  final pct = tester.getRect(_key('r19.footer.percent'));
  expect(pilula.left, greaterThanOrEqualTo(pag.right + 8 - 1));
  expect(pilula.right, lessThanOrEqualTo(pct.left - 8 + 1));
  expect(pilula.center.dx, closeTo((pag.right + pct.left) / 2, 1));
  expect(pilula.center.dy, closeTo(pag.center.dy, 0.5));
}

void main() {
  setUpAll(loadAppFonts);

  late LivroNaEstante livro;
  late int meio;
  setUp(() async {
    livro = await LivroNaEstante.domCasmurro();
    meio = livro.index.spine[2].chars ~/ 2;
    await livro.guardarPosicao(2, meio);
  });
  tearDown(() async => livro.close());

  Future<EpubLocator?> posicao(WidgetTester tester) async {
    final p = await tester.runAsync(
      () => ReadingPositionsDao(livro.db).forBook(livro.userBookId),
    );
    return p?.locator as EpubLocator?;
  }

  testWidgets(
    'rota real: página e rodapé nos lugares do arquivo; barra de status escondida',
    (tester) async {
      setCanvasView(tester, logical: const Size(390, 844));
      final t = await abrirLeitor(tester, livro);
      expect(find.byType(ReaderScreen), findsOneWidget);
      expect(
        tester.getRect(_key('r19.page')),
        const Rect.fromLTWH(28, 92, 334, 670),
      );
      final footer = tester.getRect(_key('r19.footer'));
      expect((footer.left, footer.right), (28.0, 362.0));
      expect(footer.top, closeTo(790.19, 0.5));
      expect(footer.height, closeTo(13.81, 0.5));
      final label = tester.widget<AppText>(_key('r19.footer.pageLabel'));
      expect(label.span.toPlainText(), matches(RegExp(r'^pág\. \d+ de 264$')));
      expect(t.ui.log, ['imersivo']);
      expect(t.awake.log, ['on']);
      expect(t.erros, isEmpty);
    },
  );

  testWidgets(
    'áreas do aparelho (D-112): iPhone dá o arquivo; Android com área maior desce a página',
    (tester) async {
      setCanvasView(
        tester,
        logical: const Size(390, 844),
        safeTop: 47,
        safeBottom: 34,
      );
      await abrirLeitor(tester, livro);
      expect(tester.getRect(_key('r19.page')).top, 92);
      expect(tester.getRect(_key('r19.footer')).bottom, closeTo(804, 0.5));
      await tester.pumpWidget(const SizedBox());
      setCanvasView(
        tester,
        logical: const Size(390, 844),
        safeTop: 59,
        safeBottom: 48,
      );
      await abrirLeitor(tester, livro);
      final page = tester.getRect(_key('r19.page'));
      expect((page.top, page.bottom), (104.0, 844.0 - 96));
      expect(tester.getRect(_key('r19.footer')).bottom, closeTo(844 - 54, 0.5));
    },
  );

  testWidgets(
    'virar pelo toque e sair pelo Voltar do Android: a posição vai para a página nova',
    (tester) async {
      setCanvasView(tester, logical: const Size(390, 844));
      final t = await abrirLeitor(tester, livro);
      final antes = _doc(tester).mark;
      await tester.tapAt(const Offset(360, 420));
      await _quadros(
        tester,
        20,
      ); // a virada (220 ms) — a animação anda de quadro em quadro
      final depois = _doc(tester).mark;
      expect(depois.offset, greaterThan(antes.offset));
      await tester.binding.handlePopRoute();
      await tester.pump();
      // menos de 1 s depois da virada: só o fechar pode ter gravado a página nova (o guardião espera 1 s)
      final p = await posicao(tester);
      expect((p!.spine, p.offset), (depois.spine, depois.offset));
      expect(t.ui.log, [
        'imersivo',
        'padrão',
      ], reason: 'a barra volta já na saída');
      await tester.pumpAndSettle(); // a saída da rota
      expect(find.byType(ReaderScreen), findsNothing);
      expect(t.awake.log.last, 'off');
    },
  );

  testWidgets(
    'ciclo de vida: escondido solta a tela e grava; inativo não; voltar liga de novo',
    (tester) async {
      setCanvasView(tester, logical: const Size(390, 844));
      final t = await abrirLeitor(tester, livro);
      await tester.tapAt(const Offset(360, 420));
      await _quadros(tester);
      final mark = _doc(tester).mark;
      final b = tester.binding;
      b.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      expect(t.awake.log, ['on']);
      b
        ..handleAppLifecycleStateChanged(AppLifecycleState.hidden)
        ..handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await _quadros(tester, 5);
      expect(t.awake.log, ['on', 'off']);
      expect((await posicao(tester))!.offset, mark.offset);
      b
        ..handleAppLifecycleStateChanged(AppLifecycleState.hidden)
        ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
        ..handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(t.awake.log, ['on', 'off', 'on']);
    },
  );

  testWidgets('"Abrindo o livro…" só depois de 300 ms', (tester) async {
    setCanvasView(tester, logical: const Size(390, 844));
    final pronto = Completer<void>();
    await abrirLeitor(
      tester,
      livro,
      esperar: false,
      deps: (t) async {
        await pronto.future;
        return livro.readerDeps(awake: t.awake);
      },
    );
    await tester.pump(); // o quadro que monta a rota: os 300 ms contam daqui
    await tester.pump(const Duration(milliseconds: 290));
    expect(findAppText('Abrindo o livro…'), findsNothing);
    await tester.pump(const Duration(milliseconds: 20));
    expect(findAppText('Abrindo o livro…'), findsOneWidget);
    pronto.complete();
    await esperarLeitor(tester);
    expect(findAppText('Abrindo o livro…'), findsNothing);
    expect(_key('r19.footer'), findsOneWidget);
  });

  group('erros (D-21)', () {
    Future<void> erro(
      WidgetTester tester,
      String texto, {
      Future<void> Function()? preparar,
      Future<bool> Function(String id)? indexar,
    }) async {
      setCanvasView(tester, logical: const Size(390, 844));
      if (preparar != null) await tester.runAsync(preparar);
      final t = await abrirLeitor(
        tester,
        livro,
        deps: (t) async => livro.readerDeps(awake: t.awake, indexar: indexar),
      );
      expect(findAppText(texto), findsOneWidget);
      expect(findAppText('Voltar'), findsOneWidget);
      expect(t.ui.log, isEmpty, reason: 'a barra de status fica');
      await tester.tap(findAppText('Voltar'));
      await _quadros(tester, 10);
      await tester.pumpAndSettle(); // a saída da rota
      expect(find.byType(ReaderScreen), findsNothing);
    }

    testWidgets('fora da estante', (tester) async {
      await erro(
        tester,
        'Este livro não está mais na sua estante.',
        preparar: () => UserBooksDao(livro.db).upsert(
          livro.book.copyWith(
            meta: livro.book.meta.deleted(t0Teste, livro.book.meta.version),
          ),
        ),
      );
    });

    testWidgets('arquivo fora do aparelho', (tester) async {
      await erro(
        tester,
        'O arquivo deste livro não está mais no aparelho.',
        preparar: () => LocalFilesDao(livro.db).upsert(
          userBookId: livro.userBookId,
          path: '${livro.dir.path}/sumiu/outro.epub',
          bytes: 1,
          sha256: livro.index.contentSha256,
          now: t0Teste,
        ),
      );
    });

    testWidgets('danificado', (tester) async {
      await erro(
        tester,
        'Não deu para abrir este livro. O arquivo pode estar danificado.',
        preparar: () => BookContentIndexDao(livro.db).delete(livro.userBookId),
        indexar: (_) async => false,
      );
    });

    testWidgets('páginas fixas (D-92)', (tester) async {
      await erro(
        tester,
        'Este livro tem páginas fixas; a leitura dele ainda não está pronta no BookNest.',
        preparar: () => BookContentIndexDao(livro.db).upsert(
          livro.userBookId,
          BookIndex(
            contentSha256: livro.index.contentSha256,
            layout: 'fixed',
            spine: livro.index.spine,
            toc: livro.index.toc,
            refPages: livro.index.refPages,
          ),
          builtAt: t0Teste,
        ),
      );
    });

    testWidgets('inesperado: "Tentar de novo" reabre', (tester) async {
      setCanvasView(tester, logical: const Size(390, 844));
      await tester.runAsync(
        () => BookContentIndexDao(livro.db).delete(livro.userBookId),
      );
      var vez = 0;
      final t = await abrirLeitor(
        tester,
        livro,
        deps: (t) async => livro.readerDeps(
          awake: t.awake,
          onError: (e, _) => t.erros.add(e),
          indexar: (id) async {
            if (vez++ == 0) throw StateError('disco cheio');
            await BookContentIndexDao(livro.db)
                .upsert(id, livro.index, builtAt: t0Teste);
            return true;
          },
        ),
      );
      expect(findAppText('Não deu para abrir o livro agora.'), findsOneWidget);
      expect(t.erros.single, isA<StateError>());
      // passa dos 300 ms da 1ª abertura: o "abrindo" dela já teria aparecido
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(findAppText('Tentar de novo'));
      await tester.pump();
      // nem "Abrindo" nem "Preparando" (esta reabertura indexa de novo): de novo só depois de 300 ms (D-113)
      expect(find.byKey(const ValueKey('leitor.abrindo')), findsNothing);
      await esperarLeitor(tester);
      expect(_key('r19.footer'), findsOneWidget);
    });
  });

  testWidgets(
    'leitor de tela: "Dom Casmurro, página X de 264", o texto da página e Próxima/Anterior',
    (tester) async {
      final handle = tester.ensureSemantics();
      setCanvasView(tester, logical: const Size(390, 844));
      await abrirLeitor(tester, livro);
      final data = tester.getSemantics(_key('r19.page')).getSemanticsData();
      final n = _doc(tester).numbers;
      expect(data.label, 'Dom Casmurro, página ${n.refPage} de ${n.refTotal}');
      expect(data.value, _doc(tester).current.spokenText);
      expect(data.value, isNotEmpty);
      final acoes = {
        for (final id in data.customSemanticsActionIds ?? <int>[])
          CustomSemanticsAction.getAction(id)!.label,
      };
      expect(acoes, {
        'Próxima página',
        'Página anterior',
        'Mostrar os controles',
        'Fechar o livro',
      });
      // o rodapé não repete a página
      expect(find.semantics.byLabel(RegExp(r'^pág\.')), findsNothing);
      // as ações fazem o que dizem
      final pagina = find.semantics.byLabel(RegExp(r'^Dom Casmurro, página'));
      final antes = _doc(tester).mark;
      tester.semantics.customAction(
        pagina,
        const CustomSemanticsAction(label: 'Próxima página'),
      );
      await _quadros(tester);
      expect(_doc(tester).mark.offset, greaterThan(antes.offset));
      tester.semantics.customAction(
        pagina,
        const CustomSemanticsAction(label: 'Página anterior'),
      );
      await _quadros(tester);
      expect(_doc(tester).mark, antes);
      tester.semantics.customAction(
        pagina,
        const CustomSemanticsAction(label: 'Fechar o livro'),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ReaderScreen), findsNothing);
      handle.dispose();
    },
  );

  testWidgets(
    'link do "Indice" (D-108): vai ao índice, a pílula volta à página de onde saiu',
    (tester) async {
      setCanvasView(tester, logical: const Size(390, 844));
      final rosto = livro.index.spine.indexWhere(
        (s) => s.path.endsWith('55752-h-0.htm.xhtml'),
      );
      // abre na página da folha de rosto que tem o "Indice"
      final indice = chapterOf(livro.epub, rosto).item.text.indexOf('Indice');
      expect(indice, greaterThanOrEqualTo(0));
      await tester.runAsync(() => livro.guardarPosicao(rosto, indice));
      await abrirLeitor(tester, livro);
      final origem = _doc(tester).mark;
      final pag = _doc(tester).numbers.refPage;
      Offset? alvo;
      for (var y = 92.0; y < 762 && alvo == null; y += 3) {
        for (var x = 28.0; x < 362 && alvo == null; x += 3) {
          if (_doc(tester).current.linkAt(Offset(x, y)) != null) {
            alvo = Offset(x + 3, y + 3);
          }
        }
      }
      expect(alvo, isNotNull, reason: 'o "Indice" está na folha de rosto');
      await tester.tapAt(alvo!);
      await _quadros(tester);
      expect(_doc(tester).mark.spine, isNot(rosto));
      final pilula = findAppText('Voltar à pág. $pag');
      expect(pilula, findsOneWidget);
      _pilulaNoVao(tester);
      await tester.tap(pilula);
      await _quadros(tester);
      expect(_doc(tester).mark, origem);
      expect(pilula, findsNothing);
      // de novo, e espera os 6 s
      await tester.tapAt(alvo);
      await _quadros(tester);
      expect(pilula, findsOneWidget);
      await tester.pump(const Duration(seconds: 6));
      await tester.pump();
      expect(pilula, findsNothing);
    },
  );

  group('revisão da G11', () {
    /// Abre na página da folha de rosto que tem o "Indice" e toca nele: volta (mark de origem, pág. dela).
    Future<(ReaderMark, int)> seguirIndice(WidgetTester tester) async {
      final rosto = livro.index.spine.indexWhere(
        (s) => s.path.endsWith('55752-h-0.htm.xhtml'),
      );
      final indice = chapterOf(livro.epub, rosto).item.text.indexOf('Indice');
      await tester.runAsync(() => livro.guardarPosicao(rosto, indice));
      await abrirLeitor(tester, livro);
      final origem = _doc(tester).mark;
      final pag = _doc(tester).numbers.refPage;
      Offset? alvo;
      for (var y = 92.0; y < 762 && alvo == null; y += 3) {
        for (var x = 28.0; x < 362 && alvo == null; x += 3) {
          if (_doc(tester).current.linkAt(Offset(x, y)) != null) {
            alvo = Offset(x + 3, y + 3);
          }
        }
      }
      await tester.tapAt(alvo!);
      await _quadros(tester);
      expect(_doc(tester).mark.spine, isNot(rosto));
      return (origem, pag);
    }

    testWidgets('pílula no vão também numa tela de 360 px (D-108)', (
      tester,
    ) async {
      setCanvasView(tester, logical: const Size(360, 800));
      final (_, pag) = await seguirIndice(tester);
      expect(findAppText('Voltar à pág. $pag'), findsOneWidget);
      _pilulaNoVao(tester);
    });

    testWidgets(
      'fechar com a pílula valendo grava a página de onde saiu (D-115)',
      (tester) async {
        setCanvasView(tester, logical: const Size(390, 844));
        final (origem, _) = await seguirIndice(tester);
        await tester.pump(
          const Duration(seconds: 2),
        ); // mais que o 1 s do guardião, dentro dos 6 s
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        final p = (await posicao(tester))!;
        expect((p.spine, p.offset), (origem.spine, origem.offset));
      },
    );

    testWidgets('depois que a pílula some, a posição é a do destino', (
      tester,
    ) async {
      setCanvasView(tester, logical: const Size(390, 844));
      await seguirIndice(tester);
      final destino = _doc(tester).mark;
      await tester.pump(const Duration(seconds: 6));
      await tester.pump(const Duration(seconds: 2));
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      final p = (await posicao(tester))!;
      expect((p.spine, p.offset), (destino.spine, destino.offset));
    });

    testWidgets(
      'com o leitor de tela: a pílula é anunciada e fica até as 2 viradas (D-116)',
      (tester) async {
        tester.platformDispatcher.accessibilityFeaturesTestValue =
            const FakeAccessibilityFeatures(accessibleNavigation: true);
        addTearDown(
          tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
        );
        setCanvasView(tester, logical: const Size(390, 844));
        final (_, pag) = await seguirIndice(tester);
        expect(
          tester.takeAnnouncements().map((a) => a.message),
          contains('Voltar à pág. $pag, no rodapé'),
        );
        await tester.pump(const Duration(seconds: 7));
        expect(
          findAppText('Voltar à pág. $pag'),
          findsOneWidget,
          reason: 'sem os 6 s',
        );
        for (var i = 0; i < 2; i++) {
          await tester.tapAt(const Offset(360, 420));
          await _quadros(tester, 20);
        }
        expect(findAppText('Voltar à pág. $pag'), findsNothing);
      },
    );

    testWidgets(
      'capítulo que não abre no meio da leitura: aviso de arquivo danificado (D-21)',
      (tester) async {
        setCanvasView(tester, logical: const Size(390, 844));
        await tester.runAsync(() => livro.guardarPosicao(2, 0));
        await abrirLeitor(
          tester,
          livro,
          deps: (t) async => livro.readerDeps(awake: t.awake, quebrados: {1}),
        );
        await tester.tapAt(
          const Offset(40, 420),
        ); // volta para o item 1, que não abre
        await _quadros(tester);
        expect(
          findAppText(
            'Não deu para abrir este livro. O arquivo pode estar danificado.',
          ),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'dependências que não vieram: "Tentar de novo" pede de novo e abre',
      (tester) async {
        setCanvasView(tester, logical: const Size(390, 844));
        var vez = 0;
        await abrirLeitor(
          tester,
          livro,
          deps: (t) async {
            if (vez++ == 0) throw StateError('sem banco');
            return livro.readerDeps(awake: t.awake);
          },
        );
        expect(tester.takeException(), isA<StateError>(), reason: 'relatado');
        expect(
          findAppText('Não deu para abrir o livro agora.'),
          findsOneWidget,
        );
        await tester.tap(findAppText('Tentar de novo'));
        await esperarLeitor(tester);
        expect(_key('r19.footer'), findsOneWidget);
        expect(vez, 2);
      },
    );

    testWidgets(
      'em segundo plano a página que muda por dentro não religa a tela acesa',
      (tester) async {
        setCanvasView(tester, logical: const Size(390, 844));
        final t = await abrirLeitor(tester, livro);
        final b = tester.binding;
        for (final s in [
          AppLifecycleState.inactive,
          AppLifecycleState.hidden,
        ]) {
          b.handleAppLifecycleStateChanged(s);
        }
        await tester.pump();
        expect(t.awake.log.last, 'off');
        unawaited(_doc(tester).goTo((spine: 3, offset: 0)));
        await _quadros(tester);
        expect(
          t.awake.log.last,
          'off',
          reason: 'a página mudou por dentro, ninguém tocou',
        );
        for (final s in [
          AppLifecycleState.inactive,
          AppLifecycleState.resumed,
        ]) {
          b.handleAppLifecycleStateChanged(s);
        }
        await tester.pump();
        expect(t.awake.log.last, 'on');
      },
    );

    testWidgets(
      'iOS: arrastar da borda esquerda volta a página, não fecha o livro',
      (tester) async {
        setCanvasView(tester, logical: const Size(390, 844));
        await abrirLeitor(tester, livro);
        final antes = _doc(tester).mark;
        await tester.timedDragFrom(
          const Offset(4, 420),
          const Offset(200, 0),
          const Duration(milliseconds: 300),
        );
        await tester.pumpAndSettle();
        expect(find.byType(ReaderScreen), findsOneWidget);
        expect(_doc(tester).mark.offset, lessThan(antes.offset));
      },
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    );

    testWidgets('"Abrindo" e os erros são região viva para o leitor de tela', (
      tester,
    ) async {
      final h = tester.ensureSemantics();
      setCanvasView(tester, logical: const Size(390, 844));
      final pronto = Completer<void>();
      await abrirLeitor(
        tester,
        livro,
        esperar: false,
        deps: (t) async {
          await pronto.future;
          throw StateError('sem banco');
        },
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 310));
      expect(
        tester.getSemantics(find.byKey(const ValueKey('leitor.abrindo'))),
        isSemantics(isLiveRegion: true),
      );
      pronto.complete();
      await esperarLeitor(tester);
      expect(tester.takeException(), isA<StateError>());
      expect(
        tester.getSemantics(findAppText('Não deu para abrir o livro agora.')),
        isSemantics(isLiveRegion: true),
      );
      h.dispose();
    });
  });
}

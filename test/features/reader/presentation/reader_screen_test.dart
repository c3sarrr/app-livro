// G11.3 — a tela 19 pela rota real `/leitor/:bookId`, com o Dom Casmurro de verdade num banco em memória: a
// página e o rodapé nos lugares do arquivo (e com as áreas do aparelho — D-112), virar pelo toque grava a
// posição ao sair, o "Fechar o livro" provisório (D-106), o Voltar do Android, a barra de status (D-105), o
// ciclo de vida com a tela acesa (D-111), o "abrindo" depois de 300 ms e os erros (D-21), o link do "Indice"
// com a pílula de voltar (D-108) e o leitor de tela (Anexo 03 §11).
import 'dart:async';

import 'package:app_leitura/core/data/database/daos/content_daos.dart';
import 'package:app_leitura/core/data/database/daos/library_daos.dart';
import 'package:app_leitura/core/data/database/daos/reader_daos.dart';
import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/widgets/app_svg.dart';
import 'package:app_leitura/core/design_system/widgets/circle_icon_button.dart';
import 'package:app_leitura/features/reader/application/reader_document.dart';
import 'package:app_leitura/features/reader/content/chapter_content.dart';
import 'package:app_leitura/features/reader/content/book_index.dart';
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
      await _quadros(tester);
      final depois = _doc(tester).mark;
      expect(depois.offset, greaterThan(antes.offset));
      await tester.binding.handlePopRoute();
      await _quadros(tester, 10);
      await tester.pumpAndSettle(); // a saída da rota
      expect(find.byType(ReaderScreen), findsNothing);
      expect(t.ui.log, ['imersivo', 'padrão']);
      expect(t.awake.log.last, 'off');
      final p = await posicao(tester);
      expect((p!.spine, p.offset), (depois.spine, depois.offset));
    },
  );

  testWidgets(
    'centro: "Fechar o livro" no lugar da tela 20; some com outro toque ou em 4 s; fecha gravando',
    (tester) async {
      setCanvasView(tester, logical: const Size(390, 844));
      final t = await abrirLeitor(tester, livro);
      // a transparência é a cor do papel do botão (o app não usa camada de opacidade — F12 12.4)
      double opacidade() => _key('leitor.fechar').evaluate().isEmpty
          ? 0
          : tester.widget<CircleIconButton>(_key('leitor.fechar')).color!.a;
      expect(opacidade(), 0);
      // cada mudança começa a animar no quadro seguinte ao toque (ou ao fim dos 4 s)
      await tester.tapAt(const Offset(195, 420));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 75));
      expect(
        opacidade(),
        allOf(greaterThan(0.3), lessThan(0.7)),
        reason: 'na metade dos 150 ms',
      );
      await tester.pump(const Duration(milliseconds: 75));
      expect(opacidade(), 1);
      final botao = tester.widget<CircleIconButton>(_key('leitor.fechar'));
      expect(botao.border!.color, AppColors.ink);
      expect(
        (botao.icon as AppSvg).color,
        isNull,
        reason: 'inteiro: as cores do arquivo',
      );
      expect(
        tester.getRect(_key('leitor.fechar')),
        const Rect.fromLTWH(23.5, 63, 44, 44),
      );
      await tester.tapAt(const Offset(195, 420));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      expect(opacidade(), 0);
      await tester.tapAt(const Offset(195, 420));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 3900));
      expect(opacidade(), 1);
      await tester.pump(
        const Duration(milliseconds: 100),
      ); // 4 s depois do toque: começa a sumir
      await tester.pump(const Duration(milliseconds: 150));
      expect(opacidade(), 0, reason: '4 s');
      await tester.tapAt(const Offset(195, 420));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      await tester.tap(_key('leitor.fechar'));
      await _quadros(tester, 20);
      await tester.pumpAndSettle(); // a saída da rota
      expect(find.byType(ReaderScreen), findsNothing);
      expect(t.ui.log, ['imersivo', 'padrão']);
      expect((await posicao(tester))!.spine, 2);
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
      await tester.tap(findAppText('Tentar de novo'));
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
      expect(acoes, {'Próxima página', 'Página anterior'});
      // o rodapé não repete a página
      expect(find.semantics.byLabel(RegExp(r'^pág\.')), findsNothing);
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
      final r = tester.getRect(_key('leitor.voltarDoLink'));
      expect(r.center.dx, closeTo(195, 0.5));
      expect(r.center.dy, closeTo(797.1, 3));
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
}

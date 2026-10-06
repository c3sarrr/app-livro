// G12.4 — a busca no livro (D-120):
// - a sessão da busca com um documento de mentira: 250 ms depois de parar de digitar, menos de 2 caracteres
//   limpa, uma busca nova cancela a anterior, "Buscando…" só depois de 300 ms, singular/plural, "Nada
//   encontrado", e acima de 500 para e avisa;
// - o painel pela rota real com o Dom Casmurro: a lupa abre com o campo focado; os resultados com "pág. N" e o
//   trecho com a palavra marcada na cor `brand`; tocar leva à página, marca a palavra até virar e mostra a pílula;
//   reabrir mostra a última busca; × limpa; ← e Voltar fecham o painel (os controles continuam); Noite.
import 'dart:async';

import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/widgets/neo_box.dart';
import 'package:app_leitura/features/reader/application/reader_document.dart';
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:app_leitura/features/reader/presentation/book_search_panel.dart';
import 'package:app_leitura/features/reader/presentation/reader_chrome_palette.dart';
import 'package:app_leitura/features/reader/presentation/reader_page_view.dart';
import 'package:app_leitura/features/reader/presentation/reader_palette.dart';
import 'package:app_leitura/features/reader/presentation/reader_screen.dart';
import 'package:flutter/material.dart' show MaterialApp;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/app_text_finder.dart';
import '../../../support/canvas.dart';
import '../../../support/load_fonts.dart';
import '../../../support/pump_reader.dart';
import '../../../support/reader_harness.dart';

Finder _key(String k) => find.byKey(ValueKey<String>(k));

/// Documento de mentira: cada busca devolve um controlador que o teste alimenta.
final class _Doc implements ReaderDocument {
  final buscas = <(String, StreamController<SearchGroup>)>[];

  @override
  Stream<SearchGroup> search(String query) {
    final c = StreamController<SearchGroup>();
    buscas.add((query, c));
    return c.stream;
  }

  @override
  Object? noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

SearchGroup _grupo(
  String titulo,
  int n, {
  int desde = 0,
  bool porPagina = false,
}) => (
  title: titulo,
  byPage: porPagina,
  hits: [
    for (var i = 0; i < n; i++)
      (
        at: (spine: 1, offset: desde + i),
        found: (unit: 1, from: desde + i, to: desde + i + 3),
        refPage: 1,
        excerpt: 'abc',
        matchStart: 0,
        matchEnd: 3,
      ),
  ],
);

ReaderDocument _doc(WidgetTester tester) =>
    tester.widget<ReaderPageView>(find.byType(ReaderPageView)).document;

Future<void> _quadros(WidgetTester tester, [int n = 30]) async {
  for (var i = 0; i < n; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

void main() {
  setUpAll(loadAppFonts);

  group('sessão da busca', () {
    testWidgets(
      '250 ms parado; menos de 2 caracteres limpa; nova busca cancela a anterior',
      (tester) async {
        final d = _Doc();
        final s = BookSearchSession(d);
        addTearDown(s.dispose);
        s.type('r');
        await tester.pump(const Duration(seconds: 1));
        expect(d.buscas, isEmpty);
        s.type('re');
        await tester.pump(const Duration(milliseconds: 200));
        s.type('res');
        await tester.pump(const Duration(milliseconds: 249));
        expect(d.buscas, isEmpty);
        await tester.pump(const Duration(milliseconds: 1));
        expect(d.buscas.map((b) => b.$1), ['res']);
        final primeira = d.buscas.single.$2;
        s.type('ress');
        await tester.pump(const Duration(milliseconds: 250));
        expect(d.buscas.map((b) => b.$1), ['res', 'ress']);
        expect(primeira.hasListener, isFalse, reason: 'cancelada');
        d.buscas.last.$2.add(_grupo('I', 2));
        await tester.pump();
        expect(s.total, 2);
        s.type('x');
        await tester.pump();
        expect(s.total, 0);
        expect(s.groups, isEmpty);
        expect(searchCountText(s), isNull);
        expect(d.buscas.last.$2.hasListener, isFalse);
      },
    );

    testWidgets(
      '"Buscando…" só depois de 300 ms; plural, singular e "Nada encontrado"',
      (tester) async {
        final d = _Doc();
        final s = BookSearchSession(d);
        addTearDown(s.dispose);
        s.type('olhos');
        await tester.pump(const Duration(milliseconds: 250));
        expect(s.running, isTrue);
        await tester.pump(const Duration(milliseconds: 299));
        expect(searchCountText(s), isNull);
        await tester.pump(const Duration(milliseconds: 1));
        expect(searchCountText(s), 'Buscando…');
        d.buscas.last.$2.add(_grupo('I', 6));
        await tester.pump();
        expect(searchCountText(s), '6 resultados');
        d.buscas.last.$2.add(_grupo('II', 1, desde: 10));
        await d.buscas.last.$2.close();
        await tester.pump();
        expect(
          (s.done, s.running, searchCountText(s)),
          (true, false, '7 resultados'),
        );
        expect(s.groups.map((g) => g.title), ['I', 'II']);
        s.type('olho');
        await tester.pump(const Duration(milliseconds: 250));
        d.buscas.last.$2.add(_grupo('I', 1));
        await d.buscas.last.$2.close();
        await tester.pump();
        expect(searchCountText(s), '1 resultado');
        s.type('xyz');
        await tester.pump(const Duration(milliseconds: 250));
        await d.buscas.last.$2.close();
        await tester.pump();
        expect(searchCountText(s), 'Nada encontrado para “xyz”.');
      },
    );

    testWidgets('acima de 500: para a busca, mostra 500 e o aviso de refinar', (
      tester,
    ) async {
      final d = _Doc();
      final s = BookSearchSession(d);
      addTearDown(s.dispose);
      s.type('de');
      await tester.pump(const Duration(milliseconds: 250));
      final c = d.buscas.single.$2;
      c.add(_grupo('I', 300));
      await tester.pump();
      expect(searchCountText(s), '300 resultados');
      c.add(_grupo('II', 201, desde: 1000));
      await tester.pump();
      expect((s.overflow, s.total), (true, 500));
      expect(searchCountText(s), 'Mais de 500 resultados. Refine a busca.');
      expect(c.hasListener, isFalse);
      expect(s.done, isTrue);
    });
  });

  group('sessão da busca (revisão)', () {
    testWidgets('espaços nas pontas e maiúsculas não refazem a busca', (
      tester,
    ) async {
      final d = _Doc();
      final s = BookSearchSession(d);
      addTearDown(s.dispose);
      s.type('olhos');
      await tester.pump(const Duration(milliseconds: 250));
      s.type('olhos ');
      s.type('OLHOS ');
      await tester.pump(const Duration(milliseconds: 500));
      expect(d.buscas, hasLength(1));
    });

    testWidgets(
      'a lista anterior fica até chegar o 1º grupo da busca nova (não pisca)',
      (tester) async {
        final d = _Doc();
        final s = BookSearchSession(d);
        addTearDown(s.dispose);
        s.type('olhos');
        await tester.pump(const Duration(milliseconds: 250));
        d.buscas.last.$2.add(_grupo('I', 3));
        await d.buscas.last.$2.close();
        await tester.pump();
        s.type('olho');
        await tester.pump(const Duration(milliseconds: 250));
        expect(s.total, 3, reason: 'ainda os de antes');
        expect(s.running, isTrue);
        d.buscas.last.$2.add(_grupo('II', 1, desde: 50));
        await tester.pump();
        expect(s.total, 1);
        expect(s.groups.map((g) => g.title), ['II']);
        await d.buscas.last.$2.close();
        await tester.pump();
        expect(s.running, isFalse);
      },
    );

    testWidgets(
      'busca que falha: relata e diz que não deu (não "Nada encontrado")',
      (tester) async {
        final d = _Doc();
        final erros = <Object>[];
        final s = BookSearchSession(d, onError: (e, _) => erros.add(e));
        addTearDown(s.dispose);
        s.type('olhos');
        await tester.pump(const Duration(milliseconds: 250));
        d.buscas.last.$2.addError(StateError('arquivo ilegível'));
        await tester.pump();
        expect((s.failed, s.done, s.running), (true, true, false));
        expect(erros, [isA<StateError>()]);
        expect(searchCountText(s), searchFailedText);
        expect(searchFailedText, 'Não deu para buscar no livro agora.');
        // a próxima busca começa limpa
        s.type('olho');
        await tester.pump(const Duration(milliseconds: 250));
        expect(s.failed, isFalse);
        await d.buscas.last.$2.close();
        await tester.pump();
      },
    );

    testWidgets(
      'PDF: o grupo já é a página — o resultado não repete o "pág. N"',
      (tester) async {
        tester.view
          ..devicePixelRatio = 1
          ..physicalSize = const Size(390, 844);
        addTearDown(tester.view.reset);
        final d = _Doc();
        final s = BookSearchSession(d);
        addTearDown(s.dispose);
        await tester.pumpWidget(
          MaterialApp(
            home: BookSearchPanel(
              session: s,
              paper: ReaderPalette.of(ReaderPaper.creme),
              palette: ReaderChromePalette.of(ReaderPaper.creme),
              brand: AppColors.lavender,
              onClose: () {},
              onPick: (_) {},
            ),
          ),
        );
        s.type('conto');
        await tester.pump(const Duration(milliseconds: 250));
        d.buscas.last.$2.add(_grupo('Pág. 1', 1, porPagina: true));
        await d.buscas.last.$2.close();
        await tester.pump();
        expect(findAppText('PÁG. 1'), findsOneWidget);
        expect(findAppText('pág. 1'), findsNothing);
      },
    );

    testWidgets(
      'palavra achada no trecho: escura na marca em todo papel (no Noite, a cor do papel — D-127)',
      (tester) async {
        tester.view
          ..devicePixelRatio = 1
          ..physicalSize = const Size(390, 844);
        addTearDown(tester.view.reset);
        Future<TextSpan> achada(ReaderPaper papel) async {
          final d = _Doc();
          final s = BookSearchSession(d);
          addTearDown(s.dispose);
          await tester.pumpWidget(
            MaterialApp(
              key: ValueKey(papel),
              home: BookSearchPanel(
                session: s,
                paper: ReaderPalette.of(papel),
                palette: ReaderChromePalette.of(papel),
                brand: AppColors.lavender,
                onClose: () {},
                onPick: (_) {},
              ),
            ),
          );
          s.type('abc');
          await tester.pump(const Duration(milliseconds: 250));
          d.buscas.last.$2.add(_grupo('Um', 1));
          await d.buscas.last.$2.close();
          await tester.pump();
          final trecho = tester
              .widgetList<AppText>(
                find.descendant(
                  of: _key('leitor.busca.resultado.1.0'),
                  matching: find.byType(AppText),
                ),
              )
              .last;
          return (trecho.span as TextSpan).children!.cast<TextSpan>()[1];
        }

        for (final papel in ReaderPaper.values) {
          final p = ReaderPalette.of(papel);
          final palavra = await achada(papel);
          expect(
            palavra.style!.background!.color.toARGB32(),
            AppColors.lavender.toARGB32(),
            reason: papel.name,
          );
          expect(
            palavra.style!.color,
            papel == ReaderPaper.noite ? p.paper : p.text,
            reason: papel.name,
          );
        }
      },
    );
  });

  group('painel', () {
    late LivroNaEstante livro;
    setUp(() async {
      livro = await LivroNaEstante.domCasmurro();
      await livro.guardarPosicao(2, livro.index.spine[2].chars ~/ 2);
    });
    tearDown(() async => livro.close());

    Future<void> abrirBusca(WidgetTester tester) async {
      await tester.tapAt(const Offset(195, 420));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      await tester.tap(_key('r20.topIsland.search'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
    }

    Future<void> buscar(WidgetTester tester, String q) async {
      await tester.enterText(_key('leitor.busca.campo'), q);
      await tester.pump(const Duration(milliseconds: 250));
      await _quadros(tester, 10);
    }

    testWidgets(
      'a lupa abre o painel com o campo focado; resultados com pág. e a palavra marcada',
      (tester) async {
        setCanvasView(tester, logical: const Size(390, 844));
        final t = await abrirLeitor(tester, livro);
        await abrirBusca(tester);
        expect(_key('leitor.busca'), findsOneWidget);
        expect(
          find.byWidgetPredicate(
            (w) => w is EditableText && w.focusNode.hasFocus,
          ),
          findsOneWidget,
        );
        expect(t.ui.log.last, 'padrão');
        final esperado = [
          for (final g
              in await tester.runAsync(
                    () => _doc(tester).search('ressaca').toList(),
                  ) ??
                  <SearchGroup>[])
            ...g.hits,
        ];
        expect(esperado, isNotEmpty);
        await buscar(tester, 'ressaca');
        final contagem = tester.widget<AppText>(_key('leitor.busca.contagem'));
        expect(
          contagem.span.toPlainText(),
          esperado.length == 1
              ? '1 resultado'
              : '${esperado.length} resultados',
        );
        final h = esperado.first;
        final item = _key(
          'leitor.busca.resultado.${h.found.unit}.${h.found.from}',
        );
        expect(item, findsOneWidget);
        expect(
          find.descendant(of: item, matching: findAppText('pág. ${h.refPage}')),
          findsOneWidget,
        );
        final trecho = tester
            .widgetList<AppText>(
              find.descendant(of: item, matching: find.byType(AppText)),
            )
            .last;
        final partes = (trecho.span as TextSpan).children!.cast<TextSpan>();
        expect(partes[1].text, h.excerpt.substring(h.matchStart, h.matchEnd));
        expect(
          partes[1].style!.background!.color.toARGB32(),
          AppColors.lavender.toARGB32(),
        );
        expect(trecho.span.toPlainText(), h.excerpt);
      },
    );

    testWidgets(
      'tocar num resultado: página dele, palavra marcada até virar, pílula e controles fechados',
      (tester) async {
        setCanvasView(tester, logical: const Size(390, 844));
        final t = await abrirLeitor(tester, livro);
        final pag = _doc(tester).numbers.refPage;
        await abrirBusca(tester);
        await buscar(tester, 'ressaca');
        final primeiro = find.byWidgetPredicate(
          (w) =>
              w.key is ValueKey<String> &&
              (w.key! as ValueKey<String>).value.startsWith(
                'leitor.busca.resultado.',
              ),
        );
        final chave =
            (tester.widget(primeiro.first).key! as ValueKey<String>).value;
        final partes = chave.split('.');
        final unit = int.parse(partes[3]);
        final from = int.parse(partes[4]);
        await tester.tap(primeiro.first);
        await _quadros(tester, 30);
        expect(_key('leitor.busca'), findsNothing);
        expect(_key('r20.topIsland'), findsNothing);
        expect(t.ui.log.last, 'imersivo');
        final doc = _doc(tester);
        expect(doc.found?.unit, unit);
        expect(doc.found?.from, from);
        expect(doc.mark.spine, unit);
        expect(findAppText('Voltar à pág. $pag'), findsOneWidget);
        await tester.tapAt(const Offset(360, 420));
        await _quadros(tester, 20);
        expect(_doc(tester).found, isNull, reason: 'virar apaga a marca');
      },
    );

    testWidgets(
      'reabrir mostra a última busca; × limpa; ← e Voltar fecham o painel',
      (tester) async {
        setCanvasView(tester, logical: const Size(390, 844));
        await abrirLeitor(tester, livro);
        await abrirBusca(tester);
        await buscar(tester, 'capitu');
        expect(_key('leitor.busca.contagem'), findsOneWidget);
        await tester.tap(_key('leitor.busca.fechar'));
        await tester.pump();
        expect(_key('leitor.busca'), findsNothing);
        expect(
          _key('r20.topIsland'),
          findsOneWidget,
          reason: 'os controles ficam',
        );
        await tester.tap(_key('r20.topIsland.search'));
        await tester.pump();
        expect(
          tester
              .widget<EditableText>(find.byType(EditableText))
              .controller
              .text,
          'capitu',
        );
        expect(_key('leitor.busca.contagem'), findsOneWidget);
        await tester.tap(_key('leitor.busca.limpar'));
        await tester.pump();
        expect(
          tester
              .widget<EditableText>(find.byType(EditableText))
              .controller
              .text,
          '',
        );
        expect(_key('leitor.busca.contagem'), findsNothing);
        expect(_key('leitor.busca.limpar'), findsNothing);
        await tester.binding.handlePopRoute();
        await tester.pump();
        expect(_key('leitor.busca'), findsNothing);
        expect(_key('r20.topIsland'), findsOneWidget);
        await tester.binding.handlePopRoute();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 150));
        expect(_key('r20.topIsland'), findsNothing);
        expect(find.byType(ReaderScreen), findsOneWidget);
      },
    );

    testWidgets(
      'Noite: o painel na cor do papel do Noite e a ilha do campo da 26b',
      (tester) async {
        setCanvasView(tester, logical: const Size(390, 844));
        await abrirLeitor(tester, livro);
        await tester.tapAt(const Offset(195, 420));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 150));
        await tester.tap(_key('r20.bottomIsland.tools.theme'));
        await _quadros(tester, 40);
        await tester.tap(_key('r20.topIsland.search'));
        await tester.pump();
        expect(
          tester.widget<ColoredBox>(_key('leitor.busca')).color,
          const Color(0xFF1F1B17),
        );
        final ilha = tester.widget<NeoBox>(_key('leitor.busca.ilha'));
        expect(
          (ilha.color, ilha.border!.color),
          (AppColors.islandNight, AppColors.inkNight),
        );
      },
    );
  });
}

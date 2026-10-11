// T04.9 — a folha da sessão (D-256, D-260, D-262): aberta por cima das abas, o tempo que anda, pausar/retomar, a
// página (só dígitos) e o total (pedido só sem o do livro, já com as páginas do catálogo), os avisos que impedem o
// encerramento, encerrar (o writer grava e a folha fecha), descartar (com confirmação), fechar, o play de outro livro
// (encerrar ou descartar começa o dele; fechar, nada), a semântica e o teclado.
import 'dart:async';

import 'package:app_leitura/features/home/application/home_providers.dart';
import 'package:app_leitura/features/home/domain/models.dart';
import 'package:app_leitura/features/reading_session/application/paper_timer_controller.dart';
import 'package:app_leitura/features/reading_session/data/paper_book_source.dart';
import 'package:app_leitura/features/reading_session/domain/open_paper_session.dart';
import 'package:app_leitura/features/reading_session/presentation/session_sheet.dart';
import 'package:app_leitura/features/shell/presentation/main_shell.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fixtures/home_mock_repository.dart';
import '../../../fixtures/paper_timer_fakes.dart';
import '../../../fixtures/telas/inicio01.dart';
import '../../../fixtures/telas/inicio01b.dart';
import '../../../reference/inicio2/referencias_inicio2.dart';
import '../../../support/app_text_finder.dart';
import '../../../support/fase_inicio.dart';
import '../../../support/load_fonts.dart';

/// Um livro de papel sem total, com ISBN (o catálogo do aparelho sabe 368 páginas).
const PaperBook _semTotal = PaperBook(
  book: Book(
    id: 'o-alienista',
    title: 'O Alienista',
    author: 'Machado de Assis',
    cover: PhotoCover(),
  ),
  isbn13: '9788594318602',
);

Finder _k(String key) => find.byKey(ValueKey(key));

/// A estante com o catálogo do aparelho ilegível (o `catalog.db` trocando de versão).
final class _CatalogoQuebrado implements PaperBookSource {
  _CatalogoQuebrado(this.estante);

  final PaperBookSource estante;

  @override
  Future<PaperBook?> book(String owner, String userBookId) =>
      estante.book(owner, userBookId);

  @override
  Future<int?> catalogPages(String isbn13) async =>
      throw StateError('catalog.db ilegível');
}

void main() {
  setUpAll(loadAppFonts);

  late DateTime agora;
  late ManualTicker tique;
  late MemoryPaperTimerStore loja;
  late LojaQueFalha banco;
  late RecordingPaperSessionWriter writer;
  late FixedPaperBookSource estante;

  Future<void> abrir(
    WidgetTester tester, {
    OpenPaperSession? sessao,
    Book? pendente,
    bool catalogoQuebrado = false,
  }) async {
    agora = TelaInicio01b.agora;
    tique = ManualTicker();
    loja = MemoryPaperTimerStore({
      donoDaSessao: sessao ?? TelaInicio01b.sessao,
    });
    banco = LojaQueFalha(loja);
    writer = RecordingPaperSessionWriter();
    estante = FixedPaperBookSource(
      {...estanteDePapel01().livros, _semTotal.book.id: _semTotal},
      paginasDoCatalogo: {_semTotal.isbn13!: 368},
    );
    await abrirInicio01(
      tester,
      prancha: kRef01b,
      safeTop: 47,
      safeBottom: 34,
      repositorio: const HomeMockRepository01b(),
      relogio: clockProvider.overrideWithValue(() => agora),
      cronometro: overridesDaSessao(
        store: banco,
        writer: writer,
        livros: catalogoQuebrado ? _CatalogoQuebrado(estante) : estante,
        ticker: tique,
      ),
    );
    final ctx = tester.element(find.byType(MainShell));
    showSessionSheet(ctx, pending: pendente).ignore();
    await tester.pumpAndSettle();
  }

  Future<void> tocar(WidgetTester tester, String key) async {
    await tester.ensureVisible(_k(key));
    await tester.tap(_k(key));
    await tester.pumpAndSettle();
  }

  OpenPaperSession? aberta() => loja.sessoes[donoDaSessao];

  testWidgets('D-256 abre por cima das abas (navigator raiz) com o título e "Sessão em andamento · 08:42", que anda com o '
      'tique; a mini-barra fica sob o véu', (tester) async {
    await abrir(tester);
    expect(_k('session.sheet'), findsOneWidget);
    expect(_k('session.sheet.veil'), findsOneWidget);
    expect(findAppText('Brás Cubas'), findsAtLeast(1));
    expect(findAppText('Sessão em andamento · 08:42'), findsOneWidget);
    agora = agora.add(const Duration(seconds: 1));
    tique.tick();
    await tester.pump(Duration.zero);
    expect(findAppText('Sessão em andamento · 08:43'), findsOneWidget);
    expect(rotaAtual(tester), '/inicio');
    // a folha está acima da mini-barra (o véu cobre a tela inteira)
    expect(
      tester.getRect(_k('session.sheet.veil')),
      const Rect.fromLTWH(0, 0, 390, 844),
    );
  });

  testWidgets(
    'Pausar/Retomar alterna, e a linha vira "Sessão em pausa · …" (parada)',
    (tester) async {
      await abrir(tester);
      await tocar(tester, 'session.sheet.toggle');
      expect(aberta()!.isRunning, isFalse);
      expect(findAppText('Sessão em pausa · 08:42'), findsOneWidget);
      expect(findAppText('Retomar'), findsAtLeast(1));
      agora = agora.add(const Duration(minutes: 2));
      tique.tick();
      await tester.pump(Duration.zero);
      expect(findAppText('Sessão em pausa · 08:42'), findsOneWidget);
      await tocar(tester, 'session.sheet.toggle');
      expect(aberta()!.isRunning, isTrue);
      expect(findAppText('Sessão em andamento · 08:42'), findsOneWidget);
    },
  );

  testWidgets(
    'D-260 sem total no livro: "De quantas páginas é o livro?" já com as 368 do catálogo; a página só aceita dígitos',
    (tester) async {
      await abrir(
        tester,
        sessao: OpenPaperSession.start(
          id: '01925a00-0000-7000-8000-0000000000c1',
          userBookId: _semTotal.book.id,
          now: TelaInicio01b.agora.subtract(const Duration(minutes: 20)),
        ),
      );
      expect(estante.consultasDoCatalogo, [_semTotal.isbn13]);
      expect(_k('session.sheet.total'), findsOneWidget);
      expect(find.text('368'), findsOneWidget);
      await tester.enterText(
        find.descendant(
          of: _k('session.sheet.page'),
          matching: find.byType(EditableText),
        ),
        '1a2-0',
      );
      await tester.pump();
      expect(find.text('120'), findsOneWidget);
      await tocar(tester, 'session.sheet.end');
      expect(writer.fins.single.page, 120);
      expect(writer.fins.single.pagesTotal, 368);
      expect(_k('session.sheet'), findsNothing);
      expect(aberta(), isNull);
    },
  );

  testWidgets('com o total no livro (Orgulho, 425): só a página, "Última registrada: pág. 344"; fora de 1…425 → "A página vai '
      'de 1 a 425." e nada encerra', (tester) async {
    await abrir(
      tester,
      sessao: OpenPaperSession.start(
        id: '01925a00-0000-7000-8000-0000000000c2',
        userBookId: TelaInicio01.orgulho.id,
        now: TelaInicio01b.agora.subtract(const Duration(minutes: 20)),
      ),
    );
    expect(_k('session.sheet.total'), findsNothing);
    expect(findAppText('Última registrada: pág. 344'), findsOneWidget);
    final pagina = find.descendant(
      of: _k('session.sheet.page'),
      matching: find.byType(EditableText),
    );
    for (final fora in ['0', '426']) {
      await tester.enterText(pagina, fora);
      await tocar(tester, 'session.sheet.end');
      expect(findAppText('A página vai de 1 a 425.'), findsOneWidget);
      expect(writer.fins, isEmpty);
      expect(_k('session.sheet'), findsOneWidget);
    }
    await tester.enterText(pagina, '360');
    await tocar(tester, 'session.sheet.end');
    expect(writer.fins.single.page, 360);
    expect(writer.fins.single.pagesTotal, isNull);
  });

  testWidgets('D-260 página sem total (nem do livro, nem digitado) → "Informe o total de páginas para registrar a página." e '
      'nada encerra; sem página, encerra só a sessão', (tester) async {
    await abrir(tester); // o Brás Cubas da fixture: sem total, sem ISBN
    expect(
      find.descendant(
        of: _k('session.sheet.total'),
        matching: find.byType(EditableText),
      ),
      findsOneWidget,
    );
    await tester.enterText(
      find.descendant(
        of: _k('session.sheet.page'),
        matching: find.byType(EditableText),
      ),
      '12',
    );
    await tocar(tester, 'session.sheet.end');
    expect(
      findAppText('Informe o total de páginas para registrar a página.'),
      findsOneWidget,
    );
    expect(writer.fins, isEmpty);
    await tester.enterText(
      find.descendant(
        of: _k('session.sheet.page'),
        matching: find.byType(EditableText),
      ),
      '',
    );
    await tocar(tester, 'session.sheet.end');
    final fim = writer.fins.single;
    expect((fim.page, fim.pagesTotal), (null, null));
    expect(fim.record!.activeSeconds, TelaInicio01b.tempoDaSessao.inSeconds);
    expect(aberta(), isNull);
  });

  testWidgets('D-256 descartar pede confirmação ("Descartar esta sessão? Os 08:42 não serão gravados."): Voltar volta; '
      'Descartar limpa sem gravar e fecha', (tester) async {
    await abrir(tester);
    await tocar(tester, 'session.sheet.discard');
    expect(
      findAppText('Descartar esta sessão? Os 08:42 não serão gravados.'),
      findsOneWidget,
    );
    await tocar(tester, 'session.sheet.back');
    expect(_k('session.sheet.end'), findsOneWidget);
    expect(aberta(), isNotNull);
    await tocar(tester, 'session.sheet.discard');
    await tocar(tester, 'session.sheet.confirmDiscard');
    expect(writer.fins, isEmpty);
    expect(aberta(), isNull);
    expect(_k('session.sheet'), findsNothing);
    expect(find.byKey(const ValueKey('miniBar')), findsNothing);
  });

  testWidgets('"Fechar" e o toque no véu fecham sem mudar nada', (
    tester,
  ) async {
    await abrir(tester);
    final antes = aberta();
    await tocar(tester, 'session.sheet.close');
    expect(_k('session.sheet'), findsNothing);
    expect(aberta(), antes);
    showSessionSheet(tester.element(find.byType(MainShell))).ignore();
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(195, 60));
    await tester.pumpAndSettle();
    expect(_k('session.sheet'), findsNothing);
    expect(aberta(), antes);
    expect(writer.fins, isEmpty);
  });

  for (final (acao, chaves) in [
    ('encerrar', ['session.sheet.end']),
    ('descartar', ['session.sheet.discard', 'session.sheet.confirmDiscard']),
  ]) {
    testWidgets('D-262 aberta pelo play do Orgulho: "Para começar Orgulho e Preconceito, encerre ou descarte esta sessão." — '
        '$acao começa a sessão dele', (tester) async {
      await abrir(tester, pendente: TelaInicio01.orgulho);
      expect(
        findAppText(
          'Para começar Orgulho e Preconceito, encerre ou descarte esta sessão.',
        ),
        findsOneWidget,
      );
      for (final k in chaves) {
        await tocar(tester, k);
      }
      expect(_k('session.sheet'), findsNothing);
      final nova = aberta()!;
      expect(nova.userBookId, TelaInicio01.orgulho.id);
      expect(nova.isRunning, isTrue);
      expect(nova.id, isNot(TelaInicio01b.sessao.id));
      expect(writer.fins, hasLength(acao == 'encerrar' ? 1 : 0));
    });
  }

  testWidgets('D-262 "Fechar" não começa nada', (tester) async {
    await abrir(tester, pendente: TelaInicio01.orgulho);
    await tocar(tester, 'session.sheet.close');
    expect(aberta(), TelaInicio01b.sessao);
  });

  testWidgets(
    'semântica: o diálogo "Cronômetro" (escopo da rota), o título como cabeçalho, os botões e os campos com rótulo',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await abrir(tester);
      final dialogo = find.semantics.byLabel('Cronômetro');
      expect(dialogo, findsOneWidget);
      final d = dialogo.evaluate().single.getSemanticsData();
      expect(d.flagsCollection.scopesRoute, isTrue);
      expect(d.flagsCollection.namesRoute, isTrue);
      final titulo = tester.getSemantics(_k('session.sheet.title'));
      expect(titulo.getSemanticsData().flagsCollection.isHeader, isTrue);
      for (final rotulo in [
        'Pausar',
        'Encerrar sessão',
        'Descartar sessão',
        'Fechar',
      ]) {
        final b = find.semantics.byLabel(rotulo);
        expect(b, findsOneWidget, reason: rotulo);
        final bd = b.evaluate().single.getSemanticsData();
        expect(bd.flagsCollection.isButton, isTrue, reason: rotulo);
        expect(bd.hasAction(SemanticsAction.tap), isTrue, reason: rotulo);
      }
      for (final campo in [
        'Em que página você parou?',
        'De quantas páginas é o livro?',
      ]) {
        final c = find.semantics.byLabel(campo);
        expect(c, findsAtLeast(1), reason: campo);
        expect(
          c.evaluate().first.getSemanticsData().flagsCollection.isTextField,
          isTrue,
          reason: campo,
        );
      }
      semantics.dispose();
    },
  );

  testWidgets(
    'o teclado sobe a folha: o cartão acaba 14 acima dele e a página fica à vista (a folha rola se não couber)',
    (tester) async {
      await abrir(tester);
      tester.view.viewInsets = const FakeViewPadding(bottom: 320 * 3);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      final cartao = tester.getRect(_k('session.sheet'));
      expect(cartao.bottom, closeTo(844 - 320 - 14, 1e-3));
      expect(cartao.top, greaterThanOrEqualTo(47 + 14 - 1e-3));
      await tester.ensureVisible(_k('session.sheet.page'));
      await tester.pumpAndSettle();
      final campo = tester.getRect(_k('session.sheet.page'));
      expect(campo.top, greaterThanOrEqualTo(cartao.top));
      expect(campo.bottom, lessThanOrEqualTo(cartao.bottom));
    },
  );

  testWidgets('a sessão que acaba por outro caminho fecha a folha junto', (
    tester,
  ) async {
    await abrir(tester);
    final c = ProviderScope.containerOf(tester.element(find.byType(MainShell)));
    await c.read(paperTimerProvider.notifier).discard();
    await tester.pumpAndSettle();
    expect(_k('session.sheet'), findsNothing);
  });

  testWidgets('a sessão que acaba enquanto outra rota cobre a folha: a folha (pausada, coberta) sai quando a de cima '
      'sai — a de cima não é tirada', (tester) async {
    await abrir(tester);
    final nav = Navigator.of(
      tester.element(_k('session.sheet')),
      rootNavigator: true,
    );
    unawaited(
      nav.push<void>(
        PageRouteBuilder<void>(
          pageBuilder: (_, _, _) => const SizedBox(key: ValueKey('por.cima')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final c = ProviderScope.containerOf(
      tester.element(find.byType(MainShell, skipOffstage: false)),
    );
    await c.read(paperTimerProvider.notifier).discard();
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('por.cima')), findsOneWidget);
    nav.pop();
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('por.cima')), findsNothing);
    expect(_k('session.sheet'), findsNothing);
    expect(find.byType(MainShell), findsOneWidget);
  });

  testWidgets('o encerramento que termina com outra rota por cima (um link aberto durante a gravação): a folha tira só '
      'ela, sem fechar a de cima', (tester) async {
    await abrir(tester);
    final nav = Navigator.of(
      tester.element(_k('session.sheet')),
      rootNavigator: true,
    );
    final portao = Completer<void>();
    writer.portao = portao;
    await tester.tap(_k('session.sheet.end'));
    await tester.pump();
    unawaited(
      nav.push<void>(
        PageRouteBuilder<void>(
          pageBuilder: (_, _, _) => const SizedBox(key: ValueKey('por.cima')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    portao.complete();
    await tester.pumpAndSettle();
    expect(writer.fins, hasLength(1));
    expect(find.byKey(const ValueKey('por.cima')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('session.sheet'), skipOffstage: false),
      findsNothing,
      reason: 'a folha saiu da pilha por baixo da rota de cima',
    );
    nav.pop();
    await tester.pumpAndSettle();
    expect(find.byType(MainShell), findsOneWidget);
    expect(_k('session.sheet'), findsNothing);
  });

  group('D-266 as falhas na folha', () {
    testWidgets(
      'encerrar falha (o banco fora do ar): "Não deu para encerrar a sessão. Tente de novo.", a folha continua '
      'com os botões e a sessão aberta; tentar de novo encerra',
      (tester) async {
        await abrir(tester);
        writer.falha = StateError('banco fora do ar');
        await tocar(tester, 'session.sheet.end');
        expect(tester.takeException(), isA<StateError>());
        expect(_k('session.sheet'), findsOneWidget);
        expect(
          findAppText('Não deu para encerrar a sessão. Tente de novo.'),
          findsOneWidget,
        );
        expect(aberta(), TelaInicio01b.sessao);
        expect(writer.fins, isEmpty);
        await tocar(tester, 'session.sheet.end');
        expect(writer.fins, hasLength(1));
        expect(_k('session.sheet'), findsNothing);
        expect(aberta(), isNull);
      },
    );

    testWidgets(
      'encerrar com o livro fora da estante: a sessão sai com ele e a folha fecha, sem aviso nem relato',
      (tester) async {
        await abrir(tester);
        writer.falha = livroSumiu;
        await tocar(tester, 'session.sheet.end');
        expect(_k('session.sheet'), findsNothing);
        expect(aberta(), isNull);
      },
    );

    testWidgets('descartar falha: volta da confirmação para a folha com "Não deu para descartar a sessão. Tente de '
        'novo." e a sessão aberta', (tester) async {
      await abrir(tester);
      await tocar(tester, 'session.sheet.discard');
      banco.falharAoLimpar = true;
      await tocar(tester, 'session.sheet.confirmDiscard');
      expect(tester.takeException(), isA<StateError>());
      expect(_k('session.sheet.confirm'), findsNothing);
      expect(
        findAppText('Não deu para descartar a sessão. Tente de novo.'),
        findsOneWidget,
      );
      expect(aberta(), TelaInicio01b.sessao);
    });

    testWidgets('pausar e retomar falham: "Não deu para pausar a sessão. Tente de novo." / "… retomar …"; o aviso sai '
        'quando dá certo', (tester) async {
      await abrir(tester);
      banco.falharAoGravar = true;
      await tocar(tester, 'session.sheet.toggle');
      expect(tester.takeException(), isA<StateError>());
      expect(
        findAppText('Não deu para pausar a sessão. Tente de novo.'),
        findsOneWidget,
      );
      expect(aberta()!.isRunning, isTrue);
      banco.falharAoGravar = false;
      await tocar(tester, 'session.sheet.toggle');
      expect(_k('session.sheet.notice'), findsNothing);
      expect(aberta()!.isRunning, isFalse);
      banco.falharAoGravar = true;
      await tocar(tester, 'session.sheet.toggle');
      expect(tester.takeException(), isA<StateError>());
      expect(
        findAppText('Não deu para retomar a sessão. Tente de novo.'),
        findsOneWidget,
      );
      expect(aberta()!.isRunning, isFalse);
    });

    testWidgets(
      'D-262 o livro à espera que saiu da estante: encerrar fecha a folha e nada começa (sem relato)',
      (tester) async {
        await abrir(
          tester,
          pendente: const Book(
            id: 'saiu-da-estante',
            title: 'O Cortiço',
            author: 'Aluísio Azevedo',
            cover: PhotoCover(),
          ),
        );
        await tocar(tester, 'session.sheet.end');
        expect(writer.fins, hasLength(1));
        expect(_k('session.sheet'), findsNothing);
        expect(aberta(), isNull);
      },
    );

    testWidgets('D-262 o livro à espera não começa por outra falha: vai ao relatório e a folha fecha (a sessão já foi '
        'encerrada)', (tester) async {
      await abrir(tester, pendente: TelaInicio01.orgulho);
      banco.falharAoGravar = true;
      await tocar(tester, 'session.sheet.end');
      expect(tester.takeException(), isA<StateError>());
      expect(writer.fins, hasLength(1));
      expect(_k('session.sheet'), findsNothing);
      expect(aberta(), isNull);
    });

    testWidgets(
      'o catálogo do aparelho ilegível: vai ao relatório e o total fica vazio para digitar',
      (tester) async {
        await abrir(
          tester,
          catalogoQuebrado: true,
          sessao: OpenPaperSession.start(
            id: '01925a00-0000-7000-8000-0000000000c1',
            userBookId: _semTotal.book.id,
            now: TelaInicio01b.agora.subtract(const Duration(minutes: 20)),
          ),
        );
        expect(tester.takeException(), isA<StateError>());
        expect(_k('session.sheet.total'), findsOneWidget);
        expect(
          tester
              .widget<EditableText>(
                find.descendant(
                  of: _k('session.sheet.total'),
                  matching: find.byType(EditableText),
                ),
              )
              .controller
              .text,
          isEmpty,
        );
      },
    );
  });
}

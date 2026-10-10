// T04.4 — D-263: o leitor entrando na pilha pausa a sessão do papel que roda; outras rotas não; sem cronômetro criado,
// o observador não o cria.
import 'package:app_leitura/features/home/application/home_providers.dart'
    show clockProvider;
import 'package:app_leitura/features/home/domain/models.dart';
import 'package:app_leitura/features/reading_session/application/paper_timer_controller.dart';
import 'package:app_leitura/features/reading_session/application/reader_pause_observer.dart';
import 'package:app_leitura/features/reading_session/data/paper_book_source.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fixtures/paper_timer_fakes.dart';

const _bras = '01925a00-0000-7000-8000-0000000000b1';

final _t0 = DateTime.utc(2026, 9, 20, 22, 51, 18);

void main() {
  late DateTime agora;
  late GlobalKey<NavigatorState> nav;

  Future<ProviderContainer> abrir(
    WidgetTester tester, {
    bool assistir = true,
  }) async {
    agora = _t0;
    nav = GlobalKey<NavigatorState>();
    final container = ProviderContainer.test(
      overrides: [
        clockProvider.overrideWithValue(() => agora),
        ...overridesDaSessao(
          livros: FixedPaperBookSource({
            _bras: const PaperBook(
              book: Book(
                id: _bras,
                title: 'Brás Cubas',
                author: 'Machado de Assis',
                cover: PhotoCover(),
              ),
            ),
          }),
        ),
      ],
    );
    if (assistir) {
      final sub = container.listen(paperTimerProvider, (_, _) {});
      addTearDown(sub.close);
    }
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: WidgetsApp(
          navigatorKey: nav,
          navigatorObservers: [ReaderPausesPaperTimer()],
          color: const Color(0xFFF7F0E3),
          onGenerateRoute: (s) => PageRouteBuilder<void>(
            settings: s,
            pageBuilder: (_, _, _) => const SizedBox(),
          ),
        ),
      ),
    );
    return container;
  }

  Future<void> empilhar(WidgetTester tester, String nome) async {
    nav.currentState!.pushNamed(nome);
    await tester.pumpAndSettle();
  }

  /// O controlador roda na zona do teste: as tarefas dele andam com o `pump` (o `runAsync` travaria).
  Future<void> fazer(WidgetTester tester, Future<Object?> f) async {
    await tester.pumpAndSettle();
    await f;
  }

  bool rodando(ProviderContainer c) =>
      c.read(paperTimerProvider).value!.session!.isRunning;

  testWidgets('/leitor/:bookId pausa a sessão que roda (D-263)', (
    tester,
  ) async {
    final c = await abrir(tester);
    await fazer(tester, c.read(paperTimerProvider.notifier).start(_bras));
    expect(rodando(c), isTrue);
    agora = _t0.add(const Duration(minutes: 2));
    await empilhar(tester, readerRouteName);
    await fazer(tester, c.read(paperTimerProvider.future));
    expect(rodando(c), isFalse);
    expect(c.read(paperTimerProvider).value!.session!.activeSeconds, 120);
  });

  testWidgets('a página do livro, o scanner e as abas não pausam', (
    tester,
  ) async {
    final c = await abrir(tester);
    await fazer(tester, c.read(paperTimerProvider.notifier).start(_bras));
    for (final r in [
      '/livro/:bookId',
      '/scanner',
      '/inicio',
      '/livro/:bookId/destaques',
    ]) {
      await empilhar(tester, r);
      expect(rodando(c), isTrue, reason: r);
    }
  });

  testWidgets('trocar a rota pelo leitor (replace) também pausa', (
    tester,
  ) async {
    final c = await abrir(tester);
    await fazer(tester, c.read(paperTimerProvider.notifier).start(_bras));
    await empilhar(tester, '/livro/:bookId');
    nav.currentState!.pushReplacementNamed(readerRouteName);
    await tester.pumpAndSettle();
    await fazer(tester, c.read(paperTimerProvider.future));
    expect(rodando(c), isFalse);
  });

  testWidgets('sem cronômetro criado, o leitor não o cria', (tester) async {
    final c = await abrir(tester, assistir: false);
    await empilhar(tester, readerRouteName);
    expect(c.exists(paperTimerProvider), isFalse);
  });

  testWidgets('sem sessão, ou pausada: nada muda', (tester) async {
    final c = await abrir(tester);
    await fazer(tester, c.read(paperTimerProvider.future));
    await empilhar(tester, readerRouteName);
    expect(c.read(paperTimerProvider).value!.session, isNull);
  });
}

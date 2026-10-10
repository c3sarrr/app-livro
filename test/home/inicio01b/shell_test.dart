// T04.8 — L01b.4 / D-259: o shell com a sessão do cronômetro aberta. A ordem de pintura do original (conteúdo →
// degradê → mini-barra → barra → FAB), o degradê de 240 / 48 % (150 / 55 % sem sessão), a mini-barra 30 acima da barra
// (acompanha a D-02), a mesma nas 4 abas e ausente nas telas empilhadas, e a folga do fim das abas (+96: a Início
// 140 → 236, os blocos mínimos 116 → 212). Os 17 ids da barra e o degradê contra a prancha 01b.
import 'package:app_leitura/features/reading_session/application/paper_timer_controller.dart';
import 'package:app_leitura/features/reading_session/presentation/session_mini_bar.dart';
import 'package:app_leitura/features/shell/presentation/bottom_fade.dart';
import 'package:app_leitura/features/shell/presentation/floating_nav_bar.dart';
import 'package:app_leitura/features/shell/presentation/main_shell.dart';
import 'package:app_leitura/features/shell/presentation/scanner_fab.dart';
import 'package:app_leitura/features/shell/presentation/shell_insets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import '../../fixtures/home_mock_repository.dart';
import '../../fixtures/overrides_do_mundo.dart' show cronometroDoMundo;
import '../../fixtures/paper_timer_fakes.dart';
import '../../fixtures/telas/inicio01b.dart';
import '../../reference/inicio2/referencias_inicio2.dart';
import '../../support/fase_inicio.dart';
import '../../support/load_fonts.dart';
import '../../support/pump_app.dart';

Future<void> _abrir(
  WidgetTester tester, {
  List<Override>? cronometro,
  double safeBottom = 34,
}) => abrirInicio01(
  tester,
  prancha: kRef01b,
  safeTop: 47,
  safeBottom: safeBottom,
  repositorio: const HomeMockRepository01b(),
  cronometro: cronometro ?? overridesDa01b(),
);

Stack _camadas(WidgetTester tester) => tester.widget<Stack>(
  find
      .descendant(of: find.byType(MainShell), matching: find.byType(Stack))
      .first,
);

/// O degradê: a altura da camada e o ponto em que fica opaco.
(double, double) _degrade(WidgetTester tester) {
  final camada = _camadas(tester).children[1] as Positioned;
  final fade = tester.widget<BottomFade>(find.byType(BottomFade));
  return (camada.height!, fade.opaqueAt);
}

ProviderContainer _container(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(MainShell)));

Finder get _miniBarra => find.byKey(const ValueKey('miniBar'));

/// A folga do fim do bloco mínimo da aba (o `Positioned` em volta da rolagem do `PlaceholderScreen`).
double _folgaDoBloco(WidgetTester tester) => tester
    .widget<Positioned>(
      find
          .ancestor(
            of: find.byType(SingleChildScrollView),
            matching: find.byType(Positioned),
          )
          .first,
    )
    .bottom!;

void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'L01b.4 ordem com sessão: conteúdo → degradê → mini-barra → barra → FAB; o degradê de 240 opaco a 48 %',
    (tester) async {
      await _abrir(tester);
      final [conteudo, fade, mini, barra, fab] = _camadas(tester).children
          .cast<Positioned>();
      expect(conteudo.child, isA<ShellInsets>());
      expect((conteudo.child as ShellInsets).extraBottom, 96);
      expect((fade.child as IgnorePointer).child, isA<BottomFade>());
      expect(_degrade(tester), (240.0, 0.48));
      expect(mini.child, isA<SessionMiniBar>());
      expect(barra.child, isA<FloatingNavBar>());
      expect(fab.child, isA<ScannerFab>());
      expect(_miniBarra, findsOneWidget);
    },
  );

  testWidgets(
    'L01b.4 geometria: o degradê (390 × 240 em 604) e os 17 ids da barra contra a prancha 01b',
    (tester) async {
      await _abrir(tester);
      expect(
        idsDasSecoes(kRef01b, ['i01b.bottomFade', 'i01b.nav']),
        hasLength(18),
      );
      expect(
        geometria01(tester, ['i01b.bottomFade', 'i01b.nav'], prancha: kRef01b),
        isEmpty,
      );
      expect(texto01(tester, ['i01b.nav'], prancha: kRef01b), isEmpty);
    },
  );

  testWidgets(
    'D-259 sem sessão: o degradê da 01 (150 / 55 %), nada da mini-barra e nenhuma folga a mais',
    (tester) async {
      await _abrir(tester, cronometro: cronometroDoMundo());
      expect(_degrade(tester), (150.0, 0.55));
      expect(_miniBarra, findsNothing);
      expect(
        (_camadas(tester).children.first as Positioned).child,
        isA<ShellInsets>().having((s) => s.extraBottom, 'extraBottom', 0),
      );
    },
  );

  testWidgets(
    'D-02 com a área segura de 50: a barra sobe a 46 e a mini-barra junto (146 da base)',
    (tester) async {
      await _abrir(tester, safeBottom: 50);
      expect(tester.getRect(_miniBarra).bottom, closeTo(844 - 146, 1e-3));
      expect(
        tester.getRect(find.byKey(const ValueKey('nav'))).bottom,
        closeTo(844 - 46, 1e-3),
      );
    },
  );

  testWidgets('D-259 a folga: começar e encerrar a sessão soma e tira 96 do fim da Início (a padding 140 → 236), sem mexer '
      'na rolagem', (tester) async {
    await _abrir(tester, cronometro: cronometroDoMundo());
    double padding() =>
        (tester.widget<SingleChildScrollView>(homeScrollView()).padding!
                as EdgeInsets)
            .bottom;
    final pos = homeScrollPosition(tester);
    pos.jumpTo(300);
    await tester.pump();
    final antes = pos.maxScrollExtent;
    expect(padding(), 140);
    final c = _container(tester);
    await c
        .read(paperTimerProvider.notifier)
        .start(TelaInicio01b.livroDaSessao.book.id);
    await tester.pumpAndSettle();
    expect(_miniBarra, findsOneWidget);
    expect(padding(), 236);
    expect(pos.maxScrollExtent, closeTo(antes + 96, 1e-6));
    expect(pos.pixels, 300);
    await c.read(paperTimerProvider.notifier).discard();
    await tester.pumpAndSettle();
    expect(_miniBarra, findsNothing);
    expect(padding(), 140);
    expect(pos.maxScrollExtent, closeTo(antes, 1e-6));
  });

  testWidgets('D-259 a mesma mini-barra nas 4 abas (os blocos mínimos ganham 96: 116 → 212); some sob o livro, o leitor e o '
      'scanner e volta com eles fechados', (tester) async {
    await _abrir(tester);
    for (final (aba, rota) in [
      ('i01b.nav.library', '/biblioteca'),
      ('i01b.nav.clubs', '/clubes'),
      ('i01b.nav.profile', '/perfil'),
      ('i01b.nav.home', '/inicio'),
    ]) {
      await tocar01(tester, aba);
      expect(rotaAtual(tester), rota);
      expect(_miniBarra, findsOneWidget, reason: rota);
      if (rota == '/biblioteca' || rota == '/perfil') {
        expect(_folgaDoBloco(tester), 212, reason: rota);
      }
    }
    for (final (id, rota) in [
      ('i01b.alsoReading.card2', '/livro/'),
      ('i01b.hero.cta', '/leitor/'),
      ('i01b.nav.scanner.fab', '/scanner'),
    ]) {
      // a 200: o cartão do Orgulho e o herói ficam acima da mini-barra e do degradê
      homeScrollPosition(tester).jumpTo(id == 'i01b.hero.cta' ? 0 : 200);
      await tester.pumpAndSettle();
      await tocar01(tester, id);
      expect(rotaAtual(tester), startsWith(rota));
      expect(_miniBarra, findsNothing, reason: rota);
      await tester.binding.handlePopRoute(); // o Voltar do sistema
      await tester.pumpAndSettle();
      expect(_miniBarra, findsOneWidget, reason: '$rota fechado');
    }
  });

  testWidgets('D-259 sem sessão, os blocos mínimos voltam a 116', (
    tester,
  ) async {
    await _abrir(tester, cronometro: cronometroDoMundo());
    await tocar01(tester, 'i01b.nav.profile');
    expect(_folgaDoBloco(tester), 116);
  });

  test('a folga a mais é a mini-barra + os 30 até a barra', () {
    expect(ShellInsets.miniBar, SessionMiniBar.height + 30);
  });
}

// T04.10 — L01b.5: os toques do cronômetro no app inteiro (o canvas da 01, onde a mini-barra fica no fim e não cobre
// os cartões): o play começa a sessão (a mini-barra aparece, o cartão vira "pausar", a rota não muda); o pausar do
// cartão e o da mini-barra pausam e retomam; o toque na mini-barra abre a folha; o play de outro livro com a sessão
// aberta abre a folha com o aviso (D-262); o "Ler agora" segue a D-258 (e o R11); abrir o leitor pausa a sessão (D-263).
import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_icons_inicio.dart';
import 'package:app_leitura/core/design_system/widgets/app_svg.dart';
import 'package:app_leitura/features/home/data/home_repository.dart';
import 'package:app_leitura/features/home/domain/models.dart';
import 'package:app_leitura/features/reading_session/domain/open_paper_session.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fixtures/home_mock_repository.dart';
import '../../fixtures/paper_timer_fakes.dart';
import '../../fixtures/telas/inicio01.dart';
import '../../fixtures/telas/inicio01b.dart';
import '../../support/app_text_finder.dart';
import '../../support/fase_inicio.dart';
import '../../support/load_fonts.dart';

/// A `t01` com outro herói e outro "Também lendo".
final class _Inicio implements SyncHomeRepository {
  const _Inicio({required this.heroi, required this.lendo});

  final ContinueReading? heroi;
  final List<AlsoReadingItem> lendo;

  @override
  HomeSnapshot snapshot(DateTime now) {
    final s = TelaInicio01.snapshot(now);
    return HomeSnapshot(
      now: s.now,
      user: s.user,
      continueReading: heroi,
      alsoReading: lendo,
      readingDay: s.readingDay,
      dailyReview: s.dailyReview,
      forYou: s.forYou,
      club: s.club,
      recent: s.recent,
    );
  }

  @override
  Stream<HomeSnapshot> watch(DateTime Function() clock) => const Stream.empty();
}

AlsoReadingItem _papelSemPagina(int i) {
  final b = TelaInicio01.tambemLendo[i];
  return AlsoReadingItem(
    book: b.book,
    progress: b.progress,
    format: BookFormat.physical,
  );
}

AlsoReadingItem _ebook(int i) {
  final b = TelaInicio01.tambemLendo[i];
  return AlsoReadingItem(
    book: b.book,
    progress: b.progress,
    format: BookFormat.epub,
  );
}

Finder _k(String key) => find.byKey(ValueKey(key));

void main() {
  setUpAll(loadAppFonts);

  late MemoryPaperTimerStore loja;

  Future<void> abrir(
    WidgetTester tester, {
    OpenPaperSession? sessao,
    SyncHomeRepository repositorio = const HomeMockRepository(),
  }) async {
    loja = MemoryPaperTimerStore({donoDaSessao: ?sessao});
    await abrirInicio01(
      tester,
      repositorio: repositorio,
      cronometro: overridesDaSessao(store: loja, livros: estanteDePapel01()),
    );
  }

  OpenPaperSession? aberta() => loja.sessoes[donoDaSessao];

  String icone(WidgetTester tester, String key) =>
      tester.widget<AppSvg>(_k(key)).asset;

  testWidgets(
    'o play do Brás Cubas começa a sessão: a mini-barra aparece, o cartão vira "pausar" e a rota não muda',
    (tester) async {
      await abrir(tester);
      expect(_k('miniBar'), findsNothing);
      await tocar01(tester, 'i01.alsoReading.card1.play');
      expect(rotaAtual(tester), '/inicio');
      expect(aberta()!.userBookId, TelaInicio01.brasCubas.id);
      expect(aberta()!.isRunning, isTrue);
      expect(_k('miniBar'), findsOneWidget);
      expect(
        tester.widget<AppText>(_k('miniBar.title')).span.toPlainText(),
        'Brás Cubas',
      );
      expect(
        icone(tester, 'alsoReading.card1.play.icon'),
        AppIconsInicio.pause,
      );
    },
  );

  testWidgets(
    'D-257 o pausar do cartão e o da mini-barra pausam e retomam, e os dois acompanham',
    (tester) async {
      await abrir(tester, sessao: TelaInicio01b.sessao);
      await tocar01(tester, 'i01.alsoReading.card1.play');
      expect(aberta()!.isRunning, isFalse);
      expect(icone(tester, 'miniBar.pause.icon'), AppIconsInicio.playInk);
      expect(icone(tester, 'alsoReading.card1.play.icon'), AppIconsInicio.play);
      await tester.tap(_k('miniBar.pause'));
      await tester.pumpAndSettle();
      expect(aberta()!.isRunning, isTrue);
      expect(icone(tester, 'miniBar.pause.icon'), AppIconsInicio.pauseInk);
      expect(
        icone(tester, 'alsoReading.card1.play.icon'),
        AppIconsInicio.pause,
      );
    },
  );

  testWidgets('D-256 o toque na mini-barra abre a folha da sessão', (
    tester,
  ) async {
    await abrir(tester, sessao: TelaInicio01b.sessao);
    await tester.tap(_k('miniBar.title'));
    await tester.pumpAndSettle();
    expect(_k('session.sheet'), findsOneWidget);
    expect(_k('session.sheet.pending'), findsNothing);
    expect(rotaAtual(tester), '/inicio');
  });

  testWidgets('D-262 o play de outro livro com a sessão aberta abre a folha dela com "Para começar Orgulho e Preconceito, '
      'encerre ou descarte esta sessão." (nada começa sozinho)', (tester) async {
    await abrir(
      tester,
      sessao: TelaInicio01b.sessao,
      repositorio: _Inicio(
        heroi: TelaInicio01.snapshot(TelaInicio01.agora).continueReading,
        lendo: [_papelSemPagina(0), _papelSemPagina(1)],
      ),
    );
    await tocar01(tester, 'i01.alsoReading.card2.play');
    expect(
      findAppText(
        'Para começar Orgulho e Preconceito, encerre ou descarte esta sessão.',
      ),
      findsOneWidget,
    );
    expect(aberta(), TelaInicio01b.sessao);
  });

  group('D-258 "Ler agora"', () {
    testWidgets('pausada → retoma', (tester) async {
      await abrir(
        tester,
        sessao: TelaInicio01b.sessao.pause(TelaInicio01b.agora),
      );
      await tocar01(tester, 'i01.today.readNow');
      expect(aberta()!.isRunning, isTrue);
      expect(aberta()!.id, TelaInicio01b.sessao.id);
    });

    testWidgets('rodando → nada (nem folha)', (tester) async {
      await abrir(tester, sessao: TelaInicio01b.sessao);
      await tocar01(tester, 'i01.today.readNow');
      expect(aberta(), TelaInicio01b.sessao);
      expect(_k('session.sheet'), findsNothing);
      expect(rotaAtual(tester), '/inicio');
    });

    testWidgets('sem sessão e sem livro de papel: o herói (e-book) no leitor', (
      tester,
    ) async {
      final heroi = TelaInicio01.snapshot(TelaInicio01.agora).continueReading!;
      await abrir(
        tester,
        repositorio: _Inicio(heroi: heroi, lendo: [_ebook(0), _ebook(1)]),
      );
      await tocar01(tester, 'i01.today.readNow');
      expect(rotaAtual(tester), '/leitor/${heroi.book.id}');
      expect(aberta(), isNull);
    });

    testWidgets('R11 sem nada em leitura: nada', (tester) async {
      await abrir(tester, repositorio: const _Inicio(heroi: null, lendo: []));
      await tocar01(tester, 'i01.today.readNow');
      expect(rotaAtual(tester), '/inicio');
      expect(aberta(), isNull);
      expect(_k('session.sheet'), findsNothing);
    });
  });

  testWidgets(
    'D-263 com a sessão rodando, o "Continuar" do herói (e-book) abre o leitor e pausa a sessão do papel',
    (tester) async {
      await abrir(tester, sessao: TelaInicio01b.sessao);
      await tocar01(tester, 'i01.hero.cta');
      expect(rotaAtual(tester), startsWith('/leitor/'));
      expect(aberta()!.isRunning, isFalse);
      expect(_k('miniBar'), findsNothing); // a tela empilhada cobre o shell
    },
  );
}

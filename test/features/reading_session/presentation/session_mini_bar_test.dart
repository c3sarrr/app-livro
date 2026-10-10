// T04.7 — a mini-barra fora da prancha: pausada (D-257), o tique (só o tempo, o rótulo e a barrinha mudam; sem tique
// pausada ou em segundo plano, e a volta refaz pela parede), "1:08:42" e títulos longos (R5), as capas reais (R10), a
// barrinha (R1: vazia sem o instantâneo da Início, cheia com a meta batida, sem a sessão de ontem) e o botão.
import 'dart:async';

import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/tokens/app_icons_inicio.dart';
import 'package:app_leitura/core/design_system/widgets/app_svg.dart';
import 'package:app_leitura/core/design_system/widgets/neo_box.dart';
import 'package:app_leitura/features/home/application/home_providers.dart';
import 'package:app_leitura/features/home/data/home_repository.dart';
import 'package:app_leitura/features/home/domain/models.dart';
import 'package:app_leitura/features/home/presentation/covers/book_cover.dart';
import 'package:app_leitura/features/home/presentation/covers/bras_cubas_wings_cover.dart';
import 'package:app_leitura/features/reading_session/data/paper_book_source.dart';
import 'package:app_leitura/features/reading_session/domain/open_paper_session.dart';
import 'package:app_leitura/features/reading_session/presentation/session_mini_bar.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fixtures/home_mock_repository.dart';
import '../../../fixtures/overrides_do_mundo.dart' show brandDoMundo;
import '../../../fixtures/paper_timer_fakes.dart';
import '../../../fixtures/telas/inicio01.dart';
import '../../../fixtures/telas/inicio01b.dart';
import '../../../support/load_fonts.dart';
import '../../../support/precache_svgs.dart';

/// 20/09/2026 23:00 UTC = 20:00 em São Paulo (o fuso dos falsos: −3 h).
final _t0 = DateTime.utc(2026, 9, 20, 23);

/// A Início que nunca chega (o instantâneo carregando).
final class _Carregando implements HomeRepository {
  @override
  Stream<HomeSnapshot> watch(DateTime Function() clock) =>
      StreamController<HomeSnapshot>().stream;
}

/// A Início da 01b com outro "Seu dia".
final class _ComDia implements SyncHomeRepository {
  const _ComDia({required this.lidos, required this.meta});

  final int lidos;
  final int meta;

  @override
  HomeSnapshot snapshot(DateTime now) {
    final s = TelaInicio01b.snapshot(now);
    final d = s.readingDay;
    return HomeSnapshot(
      now: s.now,
      user: s.user,
      continueReading: s.continueReading,
      alsoReading: s.alsoReading,
      readingDay: ReadingDay(
        goalMinutes: meta,
        readMinutes: lidos,
        streakDays: d.streakDays,
        highlightsToday: d.highlightsToday,
        sessionsToday: d.sessionsToday,
        week: d.week,
        badgeTargetDays: d.badgeTargetDays,
      ),
      dailyReview: s.dailyReview,
      forYou: s.forYou,
      club: s.club,
      recent: s.recent,
    );
  }

  @override
  Stream<HomeSnapshot> watch(DateTime Function() clock) => const Stream.empty();
}

const _bras = TelaInicio01b.livroDaSessao;

PaperBook _livro(
  String id,
  String titulo, {
  BookCover cover = const PhotoCover(),
}) => PaperBook(
  book: Book(id: id, title: titulo, author: 'Autor', cover: cover),
);

OpenPaperSession _rodando(String livro, Duration ha) => OpenPaperSession.start(
  id: '01925a00-0000-7000-8000-0000000000aa',
  userBookId: livro,
  now: _t0.subtract(ha),
);

void main() {
  setUpAll(loadAppFonts);

  late DateTime agora;
  late ManualTicker tique;
  late MemoryPaperTimerStore loja;

  Future<void> abrir(
    WidgetTester tester, {
    required OpenPaperSession? sessao,
    List<PaperBook> livros = const [_bras],
    HomeRepository? inicio,
    DateTime? relogio,
  }) async {
    // outra árvore antes: o mesmo ProviderScope guardaria a sessão da abertura anterior
    await tester.pumpWidget(const SizedBox.shrink());
    agora = relogio ?? _t0;
    tique = ManualTicker();
    loja = MemoryPaperTimerStore({donoDaSessao: ?sessao});
    tester.view.physicalSize = const Size(390 * 3, 200 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await precacheAppIcons(tester);
    await precacheSvgs(tester, const [
      'assets/illustrations/inicio2/il_capa_bras_cubas_asas.svg',
    ]);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          clockProvider.overrideWithValue(() => agora),
          homeRepositoryProvider.overrideWithValue(
            inicio ?? const HomeMockRepository01b(),
          ),
          brandDoMundo,
          ...overridesDaSessao(
            store: loja,
            livros: FixedPaperBookSource({
              for (final l in livros) l.book.id: l,
            }),
            ticker: tique,
          ),
        ],
        child: const Directionality(
          textDirection: TextDirection.ltr,
          child: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: SizedBox(
                width: 358,
                height: SessionMiniBar.height,
                child: SessionMiniBar(),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  String texto(WidgetTester tester, String key) =>
      tester.widget<AppText>(find.byKey(ValueKey(key))).span.toPlainText();

  double barrinha(WidgetTester tester) =>
      tester.getSize(find.byKey(const ValueKey('miniBar.progress'))).width;

  String rotulo(WidgetTester tester) => tester
      .getSemantics(find.byKey(const ValueKey('miniBar')))
      .getSemanticsData()
      .label;

  Future<void> segundos(WidgetTester tester, int n) async {
    agora = agora.add(Duration(seconds: n));
    tique.tick();
    // o tique chega por microtarefa: o `pump(Duration.zero)` a entrega antes de ver se há quadro
    await tester.pump(Duration.zero);
  }

  testWidgets('sem sessão: nada (nem um pixel que pegue toque)', (
    tester,
  ) async {
    await abrir(tester, sessao: null);
    expect(find.byKey(const ValueKey('miniBar')), findsNothing);
    expect(tique.hasListener, isFalse);
  });

  testWidgets('D-257 pausada: o play tinta, "EM PAUSA · PAPEL" com o ponto #B9AE9C, "Sessão em pausa: …", "Retomar" e o '
      'tempo parado (sem tique)', (tester) async {
    final semantics = tester.ensureSemantics();
    await abrir(
      tester,
      sessao: _rodando(_bras.book.id, TelaInicio01b.tempoDaSessao).pause(_t0),
    );
    final icone = tester.widget<AppSvg>(
      find.byKey(const ValueKey('miniBar.pause.icon')),
    );
    expect((icone.asset, icone.size), (AppIconsInicio.playInk, 18.0));
    expect(
      tester
          .widget<AppText>(
            find.descendant(
              of: find.byKey(const ValueKey('miniBar.kicker')),
              matching: find.byType(AppText),
            ),
          )
          .span
          .toPlainText(),
      'EM PAUSA · PAPEL',
    );
    expect(
      tester
          .widget<NeoBox>(find.byKey(const ValueKey('miniBar.kicker.dot')))
          .color,
      AppColors.kickerOnInk,
    );
    expect(
      rotulo(tester),
      'Sessão em pausa: Brás Cubas, 8 minutos e 42 segundos. Abrir cronômetro',
    );
    expect(
      tester
          .getSemantics(find.byKey(const ValueKey('miniBar.pause')))
          .getSemanticsData()
          .label,
      'Retomar',
    );
    expect(texto(tester, 'miniBar.time'), '08:42');
    expect(tique.hasListener, isFalse);
    agora = agora.add(const Duration(minutes: 3));
    await tester.pump();
    expect(texto(tester, 'miniBar.time'), '08:42');
    semantics.dispose();
  });

  testWidgets('R5 o tique: a cada segundo o tempo, o rótulo e a barrinha mudam — a capa, os textos e o botão são as mesmas '
      'instâncias (não se refazem)', (tester) async {
    final semantics = tester.ensureSemantics();
    await abrir(
      tester,
      sessao: _rodando(_bras.book.id, TelaInicio01b.tempoDaSessao),
    );
    expect(tique.hasListener, isTrue);
    expect(texto(tester, 'miniBar.time'), '08:42');
    expect(barrinha(tester), closeTo(355 * 0.89, 1e-6));
    Widget w(String k) => tester.widget(find.byKey(ValueKey(k)));
    final antes = [w('miniBar.cover'), w('miniBar.texts'), w('miniBar.pause')];
    await segundos(tester, 1);
    expect(texto(tester, 'miniBar.time'), '08:43');
    expect(
      rotulo(tester),
      'Sessão em andamento: Brás Cubas, 8 minutos e 43 segundos. Abrir cronômetro',
    );
    expect(barrinha(tester), closeTo(355 * (18 * 60 + 523) / 1800, 1e-6));
    final depois = [w('miniBar.cover'), w('miniBar.texts'), w('miniBar.pause')];
    for (final (i, a) in antes.indexed) {
      expect(identical(a, depois[i]), isTrue, reason: '$a');
    }
    // o tempo sai da parede, não da contagem de tiques: 2 tiques com 5 s passados = 5 s
    agora = agora.add(const Duration(seconds: 5));
    tique
      ..tick()
      ..tick();
    await tester.pump(Duration.zero);
    expect(texto(tester, 'miniBar.time'), '08:48');
    semantics.dispose();
  });

  testWidgets(
    'em segundo plano o tique para; ao voltar, o tempo é refeito pela parede (o que passou conta)',
    (tester) async {
      await abrir(
        tester,
        sessao: _rodando(_bras.book.id, TelaInicio01b.tempoDaSessao),
      );
      expect(tique.hasListener, isTrue);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      expect(tique.hasListener, isTrue, reason: 'inativo ainda está à vista');
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      expect(tique.hasListener, isFalse);
      agora = agora.add(const Duration(minutes: 10));
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(tique.hasListener, isTrue);
      expect(texto(tester, 'miniBar.time'), '18:42');
    },
  );

  testWidgets(
    'R5 com 1 h 08 min 42 s: "1:08:42" inteiro (a largura cresce) e o título encolhe com reticências',
    (tester) async {
      final longo = _livro(
        'o-ateneu',
        'O Ateneu: crônica de saudades de um internato',
      );
      await abrir(
        tester,
        sessao: _rodando(
          longo.book.id,
          const Duration(hours: 1, minutes: 8, seconds: 42),
        ),
        livros: [longo],
      );
      expect(tester.takeException(), isNull);
      expect(texto(tester, 'miniBar.time'), '1:08:42');
      final tempo = tester.renderObject<RenderAppText>(
        find.byKey(const ValueKey('miniBar.time')),
      );
      expect(tempo.debugDidExceedMaxLines, isFalse);
      expect(tempo.size.width, greaterThan(63.05));
      final titulo = tester.renderObject<RenderAppText>(
        find.byKey(const ValueKey('miniBar.title')),
      );
      expect(titulo.debugDidExceedMaxLines, isTrue);
      expect(titulo.size.width, lessThan(157.95));
      // o botão continua inteiro, na borda direita (padding 10)
      expect(
        tester.getRect(find.byKey(const ValueKey('miniBar.pause'))).right,
        closeTo(16 + 358 - 1.5 - 10, 1e-3),
      );
    },
  );

  testWidgets('R10 capas: o Brás Cubas da fixture com asas; a foto (ou a gerada) na moldura 32 × 48 de borda #F7F0E3; outra '
      'arte desenhada sem versão de mini-barra → a gerada', (tester) async {
    await abrir(
      tester,
      sessao: _rodando(_bras.book.id, TelaInicio01b.tempoDaSessao),
    );
    expect(find.byType(BrasCubasWingsCover), findsOneWidget);
    for (final livro in [
      _livro('senhora', 'Senhora'),
      _livro(
        TelaInicio01.orgulho.id,
        'Orgulho e Preconceito',
        cover: TelaInicio01.orgulho.cover,
      ),
    ]) {
      await abrir(
        tester,
        sessao: _rodando(livro.book.id, const Duration(minutes: 1)),
        livros: [livro],
      );
      final capa = tester.widget<PhotoBookCover>(find.byType(PhotoBookCover));
      expect(capa.slot, CoverSlot.miniBar);
      expect(capa.book, livro.book);
      expect(find.byKey(const ValueKey('cover.generated')), findsOneWidget);
      final moldura = tester.widget<NeoBox>(
        find
            .descendant(
              of: find.byType(PhotoBookCover),
              matching: find.byType(NeoBox),
            )
            .first,
      );
      expect((moldura.width, moldura.height), (32.0, 48.0));
      expect(
        moldura.border,
        const BorderSide(width: 1.2, color: AppColors.paper),
      );
      expect((moldura.shadow, moldura.clip), (null, true));
      expect(
        tester.getSize(find.byKey(const ValueKey('miniBar.cover'))),
        const Size(32, 48),
      );
    }
  });

  testWidgets('R1 a barrinha: vazia sem o instantâneo da Início; cheia (355) com a meta batida; sem os segundos de uma sessão '
      'que começou ontem', (tester) async {
    await abrir(
      tester,
      sessao: _rodando(_bras.book.id, TelaInicio01b.tempoDaSessao),
      inicio: _Carregando(),
    );
    expect(barrinha(tester), 0);
    await abrir(
      tester,
      sessao: _rodando(_bras.book.id, TelaInicio01b.tempoDaSessao),
      inicio: const _ComDia(lidos: 25, meta: 30),
    );
    expect(barrinha(tester), 355);
    // 00:05 em São Paulo, a sessão começou 23:50 de ontem: só os 18 min do dia contam
    await abrir(
      tester,
      sessao: OpenPaperSession.start(
        id: '01925a00-0000-7000-8000-0000000000ab',
        userBookId: _bras.book.id,
        now: DateTime.utc(2026, 9, 21, 2, 50),
      ),
      relogio: DateTime.utc(2026, 9, 21, 3, 5),
    );
    expect(texto(tester, 'miniBar.time'), '15:00');
    expect(barrinha(tester), closeTo(355 * 18 / 30, 1e-6));
  });

  testWidgets('D-257 o botão pausa e retoma (o ícone e o tique acompanham)', (
    tester,
  ) async {
    await abrir(
      tester,
      sessao: _rodando(_bras.book.id, TelaInicio01b.tempoDaSessao),
    );
    await tester.tap(find.byKey(const ValueKey('miniBar.pause')));
    await tester.pumpAndSettle();
    expect(loja.sessoes[donoDaSessao]!.isRunning, isFalse);
    expect(tique.hasListener, isFalse);
    expect(
      tester
          .widget<AppSvg>(find.byKey(const ValueKey('miniBar.pause.icon')))
          .asset,
      AppIconsInicio.playInk,
    );
    await tester.tap(find.byKey(const ValueKey('miniBar.pause')));
    await tester.pumpAndSettle();
    expect(loja.sessoes[donoDaSessao]!.isRunning, isTrue);
    expect(tique.hasListener, isTrue);
  });
}

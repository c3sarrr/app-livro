import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart' show AppRoutes;
import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/tokens/app_icons.dart';
import '../../account/application/account_controller.dart';
import '../application/home_providers.dart';
import '../domain/models.dart';
import 'home_states.dart';
import 'sections/also_reading_section.dart';
import 'sections/book_club_ticket.dart';
import 'sections/for_you_section.dart';
import 'sections/header_section.dart';
import 'sections/headline_section.dart';
import 'sections/hero_section.dart';
import 'sections/recently_added_section.dart';
import 'sections/review_section.dart';
import 'sections/today_section.dart';

/// Tela Início da prancha 01 (T03, D-240): ritmo vertical exato da prancha — inset superior, as 9 seções, os 8 gaps
/// entre elas e o padding inferior (o conteúdo termina em 2612,12 no canvas de 390 × 2650).
///
/// F12 12.1: é aqui que os toques das seções viram navegação (mapa de toques da fase). As seções só expõem
/// callbacks; os destinos são as rotas-placeholder da F02 e os ids vêm do snapshot lido no momento do toque
/// (`ref.read`). G08: a tela assiste só o tipo do estado (carregando/dados/erro — D-85) e quais seções têm
/// dados (D-78); os dados de cada seção não a reconstroem.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  /// D-02: inset superior do conteúdo = max(62, viewPadding.top + 15).
  static double topInset(BuildContext context) => math.max(
    AppSpacing.topInsetMin,
    MediaQuery.viewPaddingOf(context).top + 15,
  );

  /// Lupa do cabeçalho (`header.search`, prancha 01): a busca não tem prancha (C14) — D-243 b: o elemento fica
  /// idêntico à prancha e o toque não faz nada (`docs/design/estados_sem_design.md`).
  static void onSearch() {}

  /// "Play" do livro de papel sem página (`alsoReading.cardN.play`, prancha 01): o cronômetro é da T04 — D-243 b: o
  /// elemento fica idêntico à prancha e o toque não faz nada (`docs/design/estados_sem_design.md`).
  static void onStartReading(Book book) {}

  /// "Ler agora" (`today.readNow`, prancha 01): o cronômetro é da T04 — D-243 b: o elemento fica idêntico à prancha e
  /// o toque não faz nada (`docs/design/estados_sem_design.md`).
  static void onReadNow() {}

  /// "Revisar" do cartão "Seus grifos de hoje" (`review.cta`, prancha 01): a revisão é da T05 — D-243 b: o elemento
  /// fica idêntico à prancha e o toque não faz nada (`docs/design/estados_sem_design.md`).
  static void onReview() {}

  /// "Mais opções para …" (`recent.rowN.more`): o arquivo não define o menu, então o toque não abre nada.
  /// TODO(produto): definir o menu do livro (compartilhar, remover da lista…) antes de implementar.
  static void onMoreOptions(Book book) {}

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // D-85: carregando → dados → erro. Só o tipo do estado e quais seções existem fazem a tela reconstruir;
    // os dados de cada seção são assistidos por ela mesma.
    final status = ref.watch(
      homeStateProvider.select(
        (s) => switch (s) {
          AsyncData() => _Status.data,
          AsyncError() => _Status.error,
          _ => _Status.loading,
        },
      ),
    );
    return Scaffold(
      backgroundColor: AppColors.paper,
      // Scaffold sem appBar/drawer/FAB: só pinta o fundo e, no iOS, trata o toque na status bar
      // (anima o PrimaryScrollController para o topo — `primary: true` sozinho não faz isso).
      body: SingleChildScrollView(
        primary: true,
        // D-207: a rolagem volta depois que o sistema fecha o app
        restorationId: 'inicio.rolagem',
        padding: EdgeInsets.only(
          top: topInset(context),
          bottom: AppSpacing.bottomPadding,
        ),
        child: switch (status) {
          _Status.data => const _HomeSections(),
          _Status.loading => const _NoData(child: HomeLoadingView()),
          _Status.error => _NoData(
            child: HomeErrorView(
              icon: AppIcons.bookOpen,
              onRetry: () => ref.read(homeStateProvider.notifier).retry(),
            ),
          ),
        },
      ),
    );
  }
}

enum _Status { loading, data, error }

/// Carregando ou erro (D-85): o cabeçalho (conta + relógio) e o aviso, com o ritmo do arquivo (gap 24).
class _NoData extends ConsumerWidget {
  const _NoData({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = homeUserOf(ref.watch(accountControllerProvider));
    final now = ref.watch(clockProvider)();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _gutter(
          HeaderSection(
            user: user,
            now: now,
            onNotificationsTap: () =>
                unawaited(context.push<void>(AppRoutes.notificacoes)),
            onSearchTap: HomeScreen.onSearch,
          ),
        ),
        SizedBox(height: AppSpacing.sectionGaps[0]),
        _gutter(child),
      ],
    );
  }
}

/// As 9 seções da prancha 01, na ordem e com os gaps da prancha; a que não tem dados some junto com o gap de antes
/// dela (a seguinte fica com o próprio gap).
class _HomeSections extends ConsumerWidget {
  const _HomeSections();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const gaps = AppSpacing.sectionGaps; // 24, 24, 32, 36, 40, 40, 40, 40
    // Quais seções têm dados (D-78/D-80/D-81, D-247): só isto muda a estrutura da tela.
    final layout = ref.watch(
      homeSnapshotProvider.select(
        (s) => (
          also: s.alsoReading.isNotEmpty,
          review: s.dailyReview != null,
          forYou: s.forYou != null,
          club: s.club != null,
          recent: s.recent.isNotEmpty,
        ),
      ),
    );
    // Rota por empilhamento: o botão voltar devolve a Início exatamente como estava (mesma rolagem).
    void push(String location) => unawaited(context.push<void>(location));
    HomeSnapshot snapshot() => ref.read(homeSnapshotProvider);
    void openBook(Book book) => push(AppRoutes.livro(book.id));
    // Os toques só existem quando a seção aparece (com dados); a leitura no toque é o instantâneo atual.
    void withReading(void Function(ContinueReading r) f) {
      final r = snapshot().continueReading;
      if (r != null) f(r);
    }

    // (índice da seção no arquivo, widget) — o gap antes da seção i é gaps[i − 1].
    final sections = <(int, Widget)>[
      (
        0,
        _gutter(
          HeaderSection(
            onNotificationsTap: () => push(AppRoutes.notificacoes),
            onSearchTap: HomeScreen.onSearch,
          ),
        ),
      ),
      (1, _gutter(const HeadlineSection())),
      (
        2,
        _gutter(
          HeroSection(
            // o exemplar físico não tem arquivo: vai à página do livro, não ao leitor (D-123)
            onContinueTap: () => withReading(
              (r) => push(
                r.format == BookFormat.physical
                    ? AppRoutes.livro(r.book.id)
                    : AppRoutes.leitor(r.book.id),
              ),
            ),
            onHighlightsTap: () =>
                withReading((r) => push(AppRoutes.destaques(r.book.id))),
            onScanTap: () => push(AppRoutes.scanner),
            // Troca de aba (não empilha): a Biblioteca é um ramo do shell.
            onLibraryTap: () => context.go(AppRoutes.biblioteca),
          ),
        ),
      ),
      if (layout.also)
        (
          3,
          _gutter(
            AlsoReadingSection(
              onBookTap: openBook,
              onStartReadingTap: HomeScreen.onStartReading,
            ),
          ),
        ),
      (4, _gutter(const TodaySection(onReadNowTap: HomeScreen.onReadNow))),
      // Só com a fixture até a T05 (D-247): com dados reais a revisão some com o gap.
      if (layout.review)
        (5, _gutter(const ReviewSection(onReviewTap: HomeScreen.onReview))),
      // O carrossel vai até as bordas (F08).
      if (layout.forYou)
        (
          6,
          _fullBleed(
            'forYou',
            ForYouSection(
              onBookTap: openBook,
              onSeeAllTap: () => push(AppRoutes.paraVoce),
            ),
          ),
        ),
      if (layout.club)
        (
          7,
          _gutter(
            BookClubTicket(
              onDiscussionTap: () {
                final club = snapshot().club;
                if (club != null) push(AppRoutes.discussao(club.id));
              },
            ),
          ),
        ),
      if (layout.recent)
        (
          8,
          _gutter(
            RecentlyAddedSection(
              onBookTap: openBook,
              onMoreTap: HomeScreen.onMoreOptions,
              // Troca de aba (não empilha): a Biblioteca é um ramo do shell.
              onLibraryTap: () => context.go(AppRoutes.biblioteca),
            ),
          ),
        ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (k, (i, w)) in sections.indexed) ...[
          if (k > 0) SizedBox(height: gaps[i - 1]),
          w,
        ],
      ],
    );
  }
}

/// Padding lateral do `main` (20).
Widget _gutter(Widget child) => Padding(
  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
  child: child,
);

/// O retângulo da seção "Para você" é 20→370, mas o carrossel ocupa 0→390 (`margin: 4px -20px 0`
/// no CSS). A Key marca o retângulo do CSS sem restringir o carrossel.
Widget _fullBleed(String id, Widget child) => Stack(
  children: [
    Positioned(
      left: AppSpacing.gutter,
      right: AppSpacing.gutter,
      top: 0,
      bottom: 0,
      child: IgnorePointer(child: SizedBox.expand(key: ValueKey(id))),
    ),
    child,
  ],
);

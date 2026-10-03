import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart' show AppRoutes;
import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../application/home_providers.dart';
import '../domain/models.dart';
import 'sections/also_reading_section.dart';
import 'sections/book_club_ticket.dart';
import 'sections/continue_reading_hero.dart';
import 'sections/for_you_section.dart';
import 'sections/header_section.dart';
import 'sections/headline_section.dart';
import 'sections/reading_day_card.dart';
import 'sections/recently_added_section.dart';

/// Tela Início: ritmo vertical exato do arquivo — inset superior, as 8 seções, gaps entre seções e padding
/// inferior (total 2355,16 no canvas). Desde a F10 todas as seções estão construídas; o teste de geometria do
/// bloco (F02) continua valendo.
///
/// F12 12.1: é aqui que os toques das seções viram navegação (mapa de toques da fase). As seções só expõem
/// callbacks; os destinos são as rotas-placeholder da F02 e os ids vêm do snapshot lido no momento do toque
/// (`ref.read`): a tela não assiste nada, então não reconstrói quando os dados mudam.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  /// D-02: inset superior do conteúdo = max(62, viewPadding.top + 15).
  static double topInset(BuildContext context) => math.max(
    AppSpacing.topInsetMin,
    MediaQuery.viewPaddingOf(context).top + 15,
  );

  /// "Mais opções para …" (`recent.rowN.more`): o arquivo não define o menu, então o toque não abre nada.
  /// TODO(produto): definir o menu do livro (compartilhar, remover da lista…) antes de implementar.
  static void onMoreOptions(Book book) {}

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const gaps = AppSpacing.sectionGaps; // 24, 24, 32, 36, 40, 40, 40
    // Rota por empilhamento: o botão voltar devolve a Início exatamente como estava (mesma rolagem).
    void push(String location) => unawaited(context.push<void>(location));
    HomeSnapshot snapshot() => ref.read(homeSnapshotProvider);
    void openBook(Book book) => push(AppRoutes.livro(book.id));
    // Scaffold sem appBar/drawer/FAB: só pinta o fundo e, no iOS, trata o toque na status bar
    // (anima o PrimaryScrollController para o topo — `primary: true` sozinho não faz isso).
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SingleChildScrollView(
        primary: true,
        padding: EdgeInsets.only(
          top: topInset(context),
          bottom: AppSpacing.bottomPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _gutter(
              HeaderSection(
                onNotificationsTap: () => push(AppRoutes.notificacoes),
              ),
            ),
            SizedBox(height: gaps[0]),
            _gutter(const HeadlineSection()),
            SizedBox(height: gaps[1]),
            _gutter(
              ContinueReadingHero(
                onContinueTap: () =>
                    push(AppRoutes.leitor(snapshot().continueReading.book.id)),
                onHighlightsTap: () => push(
                  AppRoutes.destaques(snapshot().continueReading.book.id),
                ),
              ),
            ),
            SizedBox(height: gaps[2]),
            _gutter(AlsoReadingSection(onBookTap: openBook)),
            SizedBox(height: gaps[3]),
            _gutter(const ReadingDayCard()),
            SizedBox(height: gaps[4]),
            // O carrossel vai até as bordas (F08).
            _fullBleed(
              'forYou',
              ForYouSection(
                onBookTap: openBook,
                onSeeAllTap: () => push(AppRoutes.paraVoce),
              ),
            ),
            SizedBox(height: gaps[5]),
            _gutter(
              BookClubTicket(
                onDiscussionTap: () =>
                    push(AppRoutes.discussao(snapshot().club.id)),
              ),
            ),
            SizedBox(height: gaps[6]),
            _gutter(
              RecentlyAddedSection(
                onBookTap: openBook,
                onMoreTap: onMoreOptions,
                // Troca de aba (não empilha): a Biblioteca é um ramo do shell.
                onLibraryTap: () => context.go(AppRoutes.biblioteca),
              ),
            ),
          ],
        ),
      ),
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

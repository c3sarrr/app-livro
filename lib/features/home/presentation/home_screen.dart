import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import 'sections/also_reading_section.dart';
import 'sections/book_club_ticket.dart';
import 'sections/continue_reading_hero.dart';
import 'sections/for_you_section.dart';
import 'sections/header_section.dart';
import 'sections/headline_section.dart';
import 'sections/reading_day_card.dart';

/// Tela Início (esqueleto da F02): ritmo vertical exato do arquivo — inset superior, as 8 seções como
/// blocos vazios na altura de referência, gaps entre seções e padding inferior (total 2355,16 no canvas).
/// Cada fase de seção substitui o seu placeholder; o teste de geometria do bloco continua valendo.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  /// D-02: inset superior do conteúdo = max(62, viewPadding.top + 15).
  static double topInset(BuildContext context) => math.max(
    AppSpacing.topInsetMin,
    MediaQuery.viewPaddingOf(context).top + 15,
  );

  @override
  Widget build(BuildContext context) {
    const gaps = AppSpacing.sectionGaps; // 24, 24, 32, 36, 40, 40, 40
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
            _gutter(const HeaderSection()),
            SizedBox(height: gaps[0]),
            _gutter(const HeadlineSection()),
            SizedBox(height: gaps[1]),
            _gutter(const ContinueReadingHero()),
            SizedBox(height: gaps[2]),
            _gutter(const AlsoReadingSection()),
            SizedBox(height: gaps[3]),
            _gutter(const ReadingDayCard()),
            SizedBox(height: gaps[4]),
            // O carrossel vai até as bordas (F08).
            _fullBleed('forYou', const ForYouSection()),
            SizedBox(height: gaps[5]),
            _gutter(const BookClubTicket()),
            SizedBox(height: gaps[6]),
            _gutter(const _Placeholder('recent', 334)),
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

/// Bloco vazio na altura de referência da seção.
class _Placeholder extends StatelessWidget {
  const _Placeholder(this.id, this.height);

  final String id;
  final double height;

  @override
  Widget build(BuildContext context) =>
      SizedBox(key: ValueKey<String>(id), height: height);
}

import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/text/app_text.dart';
import '../../../../core/design_system/tokens/app_colors.dart';
import '../../../../core/design_system/tokens/app_icons.dart';
import '../../../../core/design_system/tokens/app_radii.dart';
import '../../../../core/design_system/tokens/app_shadows.dart';
import '../../../../core/design_system/tokens/app_typography.dart';
import '../../../../core/design_system/widgets/app_svg.dart';
import '../../../../core/design_system/widgets/circle_icon_button.dart';
import '../../../../core/design_system/widgets/count_badge.dart';
import '../../../../core/design_system/widgets/neo_box.dart';
import '../../../../core/design_system/widgets/pill.dart';
import '../../../../core/design_system/widgets/pressable.dart';
import '../../../../core/design_system/widgets/stadium_progress_bar.dart';
import '../../application/formatters.dart';
import '../../application/home_providers.dart';
import '../../domain/models.dart';
import '../covers/book_cover.dart';
import '../covers/dom_casmurro_cover.dart';
import '../home_states.dart';

/// Seção 3 — Cartão "Continuar lendo" (F05): fundo `brand`, borda 1,5, raio 28, sombra dura 4/4 e
/// `overflow: hidden`; padding 20 e coluna com gap 20 (linha da capa + metadados, 158; ações, 54) → 275.
/// Os dois brilhos são `position: absolute` a partir da padding box e pintam por cima do conteúdo.
class ContinueReadingHero extends ConsumerWidget {
  const ContinueReadingHero({
    super.key,
    this.onContinueTap,
    this.onHighlightsTap,
    this.onScanTap,
    this.onLibraryTap,
  });

  /// "Continuar lendo" (ligado a `/leitor/:bookId` na F12).
  final VoidCallback? onContinueTap;

  /// Destaques e notas do livro (ligado na F12).
  final VoidCallback? onHighlightsTap;

  /// Convite com a estante vazia: "Escanear livro" (D-78).
  final VoidCallback? onScanTap;

  /// Convite com livros e nenhum em leitura: "Ver biblioteca" (D-85).
  final VoidCallback? onLibraryTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reading = ref.watch(
      homeSnapshotProvider.select((s) => s.continueReading),
    );
    final brand = ref.watch(homeThemeProvider.select((t) => t.brand));
    if (reading == null) {
      final empty = ref.watch(
        homeSnapshotProvider.select((s) => s.shelfIsEmpty),
      );
      return _Invitation(
        brand: brand,
        shelfIsEmpty: empty,
        onTap: empty ? onScanTap : onLibraryTap,
      );
    }
    assert(switch (reading.book.cover) {
      DesignedCover(:final art) => art == CoverArt.domCasmurro,
      PhotoCover() => true,
    }, 'A única arte de capa do hero no arquivo é a de Dom Casmurro.');
    // <section aria-label="Continuar lendo"> (convenção §5.1 do prompt mestre).
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: 'Continuar lendo',
      child: NeoBox(
        key: const ValueKey('hero'),
        color: brand,
        border: const BorderSide(width: 1.5, color: AppColors.ink),
        radius: BorderRadius.circular(AppRadii.card),
        shadow: AppShadows.hard4,
        clip: true,
        // Stack = padding box (dentro da borda): referência dos brilhos absolutos.
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min, // altura auto do CSS
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 20,
                children: [
                  IntrinsicHeight(
                    child: Row(
                      key: const ValueKey('hero.topRow'),
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 20,
                      children: [
                        _CoverSlot(book: reading.book),
                        Expanded(child: _Meta(reading: reading)),
                      ],
                    ),
                  ),
                  _Actions(
                    reading: reading,
                    onContinueTap: onContinueTap,
                    onHighlightsTap: onHighlightsTap,
                  ),
                ],
              ),
            ),
            // Depois do conteúdo na Stack → pintados por cima (o pequeno encosta no "rr" do título).
            const Positioned(
              top: 18,
              right: 18,
              child: AppSvg(
                AppIcons.sparkleOutline,
                size: 30,
                key: ValueKey('hero.sparkleLarge'),
              ),
            ),
            const Positioned(
              top: 54,
              right: 50,
              child: AppSvg(
                AppIcons.sparkleSolid,
                size: 14,
                key: ValueKey('hero.sparkleSmall'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Capa 104×156 com `margin: 2px 0 0 2px` (ocupa 106×158) e `transform: rotate(-3deg)` em torno do
/// centro. O `Align(topLeft)` impede que o stretch da linha estique a capa (altura definida no CSS):
/// em 360 o título quebra, a linha mede 158,8 e a capa continua com 156.
class _CoverSlot extends StatelessWidget {
  const _CoverSlot({required this.book});

  final Book book;

  static const double _angle = -3 * math.pi / 180;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 2, top: 2),
        child: SizedBox(
          key: const ValueKey('hero.cover'), // slot de layout, sem rotação
          width: 104,
          height: 156,
          child: Transform.rotate(
            angle: _angle,
            child: KeyedSubtree(
              key: const ValueKey('hero.cover#rot'),
              child: switch (book.cover) {
                DesignedCover() => const DomCasmurroCover(),
                final PhotoCover c => PhotoBookCover(
                  book: book,
                  cover: c,
                  slot: CoverSlot.hero,
                ),
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Metadados (181 de largura, esticados a 158): `padding-top: 2` e `space-between` entre o topo
/// (pílula, título, autor) e a base (percentual × tempo restante e barra).
class _Meta extends StatelessWidget {
  const _Meta({required this.reading});

  final ContinueReading reading;

  @override
  Widget build(BuildContext context) {
    final percent = HomeFormatters.percent(reading.progress);
    final (chapter, totalChapters) = (reading.chapter, reading.totalChapters);
    final timeLeft = reading.timeLeft;
    // Livro real (D-79): título e autor de qualquer tamanho — limitados às linhas que cabem no cartão.
    final real = reading.book.cover is PhotoCover;
    return Padding(
      key: const ValueKey('hero.meta'),
      padding: const EdgeInsets.only(top: 2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            key: const ValueKey('hero.meta.top'),
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 10,
            children: [
              // align-self: flex-start → a pílula abraça o texto. Sem capítulos (PDF), sem pílula.
              if (chapter != null && totalChapters != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Pill(
                    key: const ValueKey('hero.chapterPill'),
                    padding: const EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 10,
                    ),
                    color: AppColors.surface,
                    border: const BorderSide(width: 1.5, color: AppColors.ink),
                    child: AppText(
                      HomeFormatters.chapterLabel(chapter, totalChapters),
                      style: AppTextStyles.label12Bold,
                    ),
                  ),
                ),
              Column(
                key: const ValueKey('hero.titleBlock'),
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 3,
                children: [
                  Semantics(
                    container: true,
                    header: true,
                    headingLevel: 2, // <h2>
                    child: AppText(
                      reading.book.title,
                      key: const ValueKey('hero.title'),
                      style: AppTextStyles.heroTitle,
                      maxLines: real ? 3 : null,
                      ellipsis: real,
                    ),
                  ),
                  AppText(
                    reading.book.author,
                    key: const ValueKey('hero.author'),
                    style: AppTextStyles.body14Plum,
                    maxLines: real ? 1 : null,
                    ellipsis: real,
                  ),
                ],
              ),
            ],
          ),
          Column(
            key: const ValueKey('hero.meta.bottom'),
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: [
              Row(
                key: const ValueKey('hero.progressRow'),
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  AppText(
                    percent,
                    key: const ValueKey('hero.percent'),
                    style: AppTextStyles.heroPercent,
                  ),
                  // Sem sessões para estimar, sem rótulo (D-85).
                  if (timeLeft != null)
                    AppText(
                      HomeFormatters.durationLabel(timeLeft, approx: true),
                      key: const ValueKey('hero.timeLeft'),
                      style: AppTextStyles.caption12Plum,
                    ),
                ],
              ),
              // role="progressbar" aria-label="Progresso do livro" aria-valuenow="62".
              Semantics(
                container: true,
                label: 'Progresso do livro',
                value: percent,
                excludeSemantics: true,
                child: StadiumProgressBar(
                  key: const ValueKey('hero.progressBar'),
                  fillKey: const ValueKey('hero.progressFill'),
                  progress: reading.progress,
                  height: 10,
                  background: AppColors.surface,
                  fillColor: AppColors.ink,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Ações (altura 54, gap 10): CTA `flex-grow` (243) com ícone + rótulo centralizados e o botão de
/// destaques 54 com o badge sobreposto (top −4 / right −4 a partir da borda interna, sem recorte).
class _Actions extends StatelessWidget {
  const _Actions({
    required this.reading,
    required this.onContinueTap,
    required this.onHighlightsTap,
  });

  final ContinueReading reading;
  final VoidCallback? onContinueTap;
  final VoidCallback? onHighlightsTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const ValueKey('hero.actions'),
      height: 54,
      child: Row(
        spacing: 10,
        children: [
          Expanded(
            child: Pressable(
              isLink: true, // <a href>
              semanticsLabel: 'Continuar lendo',
              onTap: onContinueTap,
              child: NeoBox(
                key: const ValueKey('hero.cta'),
                height: 54,
                color: AppColors.ink,
                radius: BorderRadius.circular(AppRadii.pill),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 10,
                  children: [
                    const AppSvg(
                      AppIcons.bookOpen,
                      size: 20,
                      key: ValueKey('hero.cta.icon'),
                    ),
                    AppText(
                      'Continuar lendo',
                      key: const ValueKey('hero.cta.label'),
                      style: AppTextStyles.cta16OnInk,
                    ),
                  ],
                ),
              ),
            ),
          ),
          CircleIconButton(
            key: const ValueKey('hero.notesButton'),
            size: 54,
            color: AppColors.surface,
            border: const BorderSide(width: 1.5, color: AppColors.ink),
            icon: const AppSvg(
              AppIcons.highlighter,
              size: 22,
              key: ValueKey('hero.notesButton.icon'),
            ),
            // Não-const: AppTextStyles.* são `static final`.
            overlays: [
              Positioned(
                top: -4,
                right: -4,
                child: CountBadge(
                  key: const ValueKey('hero.notesButton.badge'),
                  label: '${reading.highlightsCount}',
                  style: AppTextStyles.micro11Bold,
                  minWidth: 22,
                  height: 22,
                  horizontalPadding: 5,
                  background: AppColors.sun,
                  border: const BorderSide(width: 1.5, color: AppColors.ink),
                ),
              ),
            ],
            onTap: onHighlightsTap,
            semanticsLabel: HomeFormatters.highlightsAria(
              reading.highlightsCount,
            ),
          ),
        ],
      ),
    );
  }
}

/// Convite no lugar do cartão (D-78/D-85 — estado sem desenho no arquivo, só primitivos): mesma caixa do herói
/// (`brand`, borda 1,5, raio 28, sombra 4/4, brilhos), título, uma linha e a pílula tinta.
class _Invitation extends StatelessWidget {
  const _Invitation({
    required this.brand,
    required this.shelfIsEmpty,
    required this.onTap,
  });

  final Color brand;
  final bool shelfIsEmpty;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (title, body, label, icon) = shelfIsEmpty
        ? (
            'Sua estante está vazia',
            'Escaneie o código de barras de um livro para começar.',
            'Escanear livro',
            AppIcons.navScanner,
          )
        : (
            'Nada em leitura agora',
            'Escolha um livro da sua estante para começar.',
            'Ver biblioteca',
            AppIcons.navLibrary,
          );
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: 'Continuar lendo',
      child: NeoBox(
        key: const ValueKey('hero'),
        color: brand,
        border: const BorderSide(width: 1.5, color: AppColors.ink),
        radius: BorderRadius.circular(AppRadii.card),
        shadow: AppShadows.hard4,
        clip: true,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 20,
                children: [
                  // A margem direita deixa os brilhos livres.
                  Padding(
                    padding: const EdgeInsets.only(right: 44),
                    child: Column(
                      key: const ValueKey('hero.invite'),
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 8,
                      children: [
                        Semantics(
                          container: true,
                          header: true,
                          headingLevel: 2, // <h2>
                          child: AppText(
                            title,
                            key: const ValueKey('hero.invite.title'),
                            style: AppTextStyles.heroTitle,
                          ),
                        ),
                        AppText(
                          body,
                          key: const ValueKey('hero.invite.body'),
                          style: AppTextStyles.body14Plum,
                        ),
                      ],
                    ),
                  ),
                  InkPillButton(
                    key: const ValueKey('hero.invite.cta'),
                    icon: icon,
                    label: label,
                    onTap: onTap,
                  ),
                ],
              ),
            ),
            const Positioned(
              top: 18,
              right: 18,
              child: AppSvg(
                AppIcons.sparkleOutline,
                size: 30,
                key: ValueKey('hero.sparkleLarge'),
              ),
            ),
            const Positioned(
              top: 54,
              right: 50,
              child: AppSvg(
                AppIcons.sparkleSolid,
                size: 14,
                key: ValueKey('hero.sparkleSmall'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// T04 — a mini-barra do cronômetro do livro de papel (prancha 01b, L01b.2–3; D-256, D-257, R1, R5, R9, R10, R12): o
// `<a>` 358 × 66 tinta acima da barra, com a barrinha da meta do dia, a capa girada, "LENDO · PAPEL", o título, o tempo
// e o botão de pausar. Só existe com uma sessão aberta (o shell a põe entre o degradê e a barra — D-259). O tempo sai
// do relógio de parede a cada tique de 1 s; o tique só corre com a sessão rodando e o app à vista, e cada tique refaz
// só o tempo, o rótulo e a barrinha (o resto são as mesmas instâncias de widget).
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design_system/text/app_text.dart';
import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_icons_inicio.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/app_svg.dart';
import '../../../core/design_system/widgets/circle_icon_button.dart';
import '../../../core/design_system/widgets/neo_box.dart';
import '../../../core/design_system/widgets/pressable.dart';
import '../../../core/preferences/brand_preference.dart';
import '../../home/application/formatters.dart';
import '../../home/application/home_providers.dart';
import '../../home/domain/models.dart';
import '../../home/presentation/covers/book_cover.dart';
import '../../home/presentation/covers/bras_cubas_wings_cover.dart';
import '../application/paper_timer_controller.dart';
import '../application/paper_timer_format.dart';
import '../application/second_ticker.dart';
import 'second_ticking.dart';
import 'session_sheet.dart';

/// A mini-barra com a sessão aberta (nada sem ela). Fundo e borda tinta 1,5, raio 22, sombra 0/4
/// `rgba(26,23,20,.35)` sem desfoque e recorte; padding 0/10/0/12 e gap 12 entre a capa, os textos (que crescem), o
/// tempo e o botão, centrados na altura.
class SessionMiniBar extends ConsumerWidget {
  const SessionMiniBar({super.key});

  /// Altura (o shell a põe 30 acima da barra — D-259).
  static const double height = 66;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timer = ref.watch(paperTimerProvider.select((t) => t.value));
    final session = timer?.session;
    final book = timer?.book?.book;
    if (session == null || book == null) return const SizedBox.shrink();
    final running = session.isRunning;
    final title = HomeFormatters.bookTitleShort(book);
    // R1: sem o instantâneo da Início (carregando ou erro), a barrinha fica vazia
    final day = ref.watch(
      homeStateProvider.select(
        (s) => switch (s.value?.readingDay) {
          final d? => (read: d.readMinutes, goal: d.goalMinutes),
          null => null,
        },
      ),
    );
    final brand = ref.watch(brandProvider);
    final clock = ref.watch(clockProvider);
    final offsetAt = ref.watch(paperTimerUtcOffsetProvider);
    // as partes que o tique não muda: as mesmas instâncias a cada tique (o Flutter não as refaz)
    final cover = _Cover(book: book);
    final texts = _Texts(running: running, title: title);
    final button = CircleIconButton(
      key: const ValueKey('miniBar.pause'),
      size: 44,
      color: AppColors.paper,
      icon: AppSvg(
        running ? AppIconsInicio.pauseInk : AppIconsInicio.playInk,
        size: 18,
        key: const ValueKey('miniBar.pause.icon'),
      ),
      onTap: ref.read(paperTimerProvider.notifier).toggleFromTap,
      semanticsLabel: running
          ? PaperTimerFormat.pauseButton
          : PaperTimerFormat.resumeButton,
    );
    return SecondTicking(
      running: running,
      ticker: ref.watch(secondTickerProvider),
      builder: (context) {
        final now = clock().toUtc();
        final seconds = session.elapsedAt(now);
        final progress = day == null
            ? 0.0
            : PaperTimerFormat.dailyProgress(
                readMinutes: day.read,
                goalMinutes: day.goal,
                openSeconds: session.isOnLocalDay(now, offsetAt) ? seconds : 0,
              );
        // <a aria-label="Sessão em andamento: …"> com o <button> dentro: o rótulo não é região ao vivo (muda a cada
        // segundo sem se anunciar — R12); o resto fica fora da árvore
        return Pressable(
          isLink: true,
          semanticsLabel: PaperTimerFormat.miniBarLabel(
            running: running,
            title: title,
            seconds: seconds,
          ),
          excludeSemantics: false,
          // o toque na barra: a folha da sessão (D-256)
          onTap: () => unawaited(showSessionSheet(context)),
          child: NeoBox(
            key: const ValueKey('miniBar'),
            height: height,
            color: AppColors.ink,
            border: const BorderSide(width: 1.5, color: AppColors.ink),
            radius: BorderRadius.circular(22),
            shadow: const Offset(0, 4),
            shadowColor: AppColors.miniBarShadow,
            clip: true,
            child: Stack(
              children: [
                // a barrinha da meta (`position: absolute` no canto da padding box): largura = o progresso (R1),
                // raio 0/4/4/0, recortada pelo canto de 20,5 da borda
                Positioned(
                  left: 0,
                  top: 0,
                  right: 0,
                  height: 4,
                  child: ExcludeSemantics(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: progress,
                        child: NeoBox(
                          key: const ValueKey('miniBar.progress'),
                          color: brand,
                          radius: const BorderRadius.horizontal(
                            right: Radius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 10, 0),
                    child: Row(
                      spacing: 12,
                      children: [
                        cover,
                        Expanded(child: texts),
                        ExcludeSemantics(
                          child: AppText(
                            PaperTimerFormat.clock(seconds),
                            key: const ValueKey('miniBar.time'),
                            style: AppTextStyles.miniBarTime,
                          ),
                        ),
                        button,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// A capa 32 × 48 girada −5° (R10): a desenhada com asas no Brás Cubas da fixture; com dados reais, a foto (ou a
/// gerada) na moldura da mini-barra. A Key do id fica no slot sem giro; o filho do giro leva `miniBar.cover#rot`.
class _Cover extends StatelessWidget {
  const _Cover({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    final art = switch (book.cover) {
      DesignedCover(art: CoverArt.brasCubas) => const BrasCubasWingsCover(),
      final PhotoCover c => PhotoBookCover(
        book: book,
        cover: c,
        slot: CoverSlot.miniBar,
      ),
      // as outras artes desenhadas não têm versão de mini-barra: a capa gerada do livro (D-79)
      _ => PhotoBookCover(
        book: book,
        cover: const PhotoCover(),
        slot: CoverSlot.miniBar,
      ),
    };
    return SizedBox(
      key: const ValueKey('miniBar.cover'),
      width: 32,
      height: 48,
      child: ExcludeSemantics(
        child: Transform.rotate(
          angle: -5 * math.pi / 180,
          child: KeyedSubtree(
            key: const ValueKey('miniBar.cover#rot'),
            child: art,
          ),
        ),
      ),
    );
  }
}

/// "LENDO · PAPEL" (o ponto 7 coral; pausada, "EM PAUSA · PAPEL" e o ponto `#B9AE9C` — D-257) e, 2 abaixo, o título
/// 15 numa linha com reticências.
class _Texts extends StatelessWidget {
  const _Texts({required this.running, required this.title});

  final bool running;
  final String title;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Column(
        key: const ValueKey('miniBar.texts'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            key: const ValueKey('miniBar.kicker'),
            spacing: 6,
            children: [
              NeoBox(
                key: const ValueKey('miniBar.kicker.dot'),
                width: 7,
                height: 7,
                color: running ? AppColors.flame : AppColors.kickerOnInk,
                radius: BorderRadius.circular(3.5),
              ),
              Flexible(
                child: AppText(
                  PaperTimerFormat.kicker(running: running),
                  style: AppTextStyles.miniBarKicker,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2), // margin-top: 2
          AppText(
            title,
            key: const ValueKey('miniBar.title'),
            style: AppTextStyles.miniBarTitle,
            maxLines: 1,
            ellipsis: true,
          ),
        ],
      ),
    );
  }
}

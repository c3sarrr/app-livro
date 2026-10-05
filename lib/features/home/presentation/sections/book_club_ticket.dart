import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/painters/chromium_dash.dart';
import '../../../../core/design_system/painters/hatch_painter.dart';
import '../../../../core/design_system/text/app_text.dart';
import '../../../../core/design_system/tokens/app_colors.dart';
import '../../../../core/design_system/tokens/app_icons.dart';
import '../../../../core/design_system/tokens/app_radii.dart';
import '../../../../core/design_system/tokens/app_typography.dart';
import '../../../../core/design_system/widgets/app_svg.dart';
import '../../../../core/design_system/widgets/count_badge.dart';
import '../../../../core/design_system/widgets/neo_box.dart';
import '../../../../core/design_system/widgets/pill.dart';
import '../../../../core/design_system/widgets/pressable.dart';
import '../../application/formatters.dart';
import '../../application/home_providers.dart';
import '../../domain/models.dart';

/// Seção 7 — Ticket do clube do livro (F09). A `<section>` só recorta (raio 28, sem borda nem fundo); dentro
/// dela, o ticket (fundo `#FFFAF1`, borda 1,5, raio 28, recorte) é uma linha: corpo flexível (255) + canhoto
/// (92) esticado à altura do corpo (1,5 + 18 + 27,4 + 14 + 77,8 + 14 + 34,4 + 14 + 46 + 18 + 1,5 = 266,6).
/// Os dois entalhes são filhos da seção, pintados por cima do ticket, com o centro sobre a perfuração e sobre
/// as bordas de cima e de baixo; o recorte da seção deixa só meio círculo de cada um.
class BookClubTicket extends ConsumerWidget {
  const BookClubTicket({super.key, this.onDiscussionTap});

  /// "Abrir discussão" (ligado a `/clube/:clubId/discussao` na F12).
  final VoidCallback? onDiscussionTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final club = ref.watch(homeSnapshotProvider.select((s) => s.club));
    // Sem clube, sem ticket (D-80).
    if (club == null) return const SizedBox.shrink();
    // <section aria-label="Seu clube do livro"> (convenção §5.1 do prompt mestre).
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: 'Seu clube do livro',
      child: ClipRRect(
        key: const ValueKey('club'),
        borderRadius: BorderRadius.circular(AppRadii.card),
        // `Clip.none`: os entalhes saem 13 px acima e abaixo da Stack; com o `Clip.hardEdge` padrão ela
        // empilharia um recorte retangular SEM suavização sobre o do `ClipRRect` (o único do CSS).
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            NeoBox(
              key: const ValueKey('club.ticket'),
              color: AppColors.surface,
              border: const BorderSide(width: 1.5, color: AppColors.ink),
              radius: BorderRadius.circular(AppRadii.card),
              clip: true,
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Padding(
                        key: const ValueKey('club.body'),
                        padding: const EdgeInsets.fromLTRB(18, 18, 16, 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          spacing: 14,
                          children: [
                            _TopRow(club: club),
                            _TitleBlock(club: club),
                            _ProgressBlock(club: club),
                            _Cta(club: club, onTap: onDiscussionTap),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      key: const ValueKey('club.stub'),
                      width: 92,
                      child: _Stub(meeting: club.nextMeeting),
                    ),
                  ],
                ),
              ),
            ),
            // right 79,75 → centro em x = 350 − 92,75 (sobre a perfuração); top/bottom −13 → centro na borda.
            const Positioned(
              top: -13,
              right: 79.75,
              child: _Notch(key: ValueKey('club.notchTop')),
            ),
            const Positioned(
              bottom: -13,
              right: 79.75,
              child: _Notch(key: ValueKey('club.notchBottom')),
            ),
          ],
        ),
      ),
    );
  }
}

/// Linha superior (`space-between`, centralizada, gap 8): pílula "Clube do livro" (padding 5 10, borda 1,5,
/// 12/700, `nowrap`) → 99,38 × 27,4 e os avatares (grupo 80 × 26, centrado → y + 0,7).
class _TopRow extends StatelessWidget {
  const _TopRow({required this.club});

  final BookClub club;

  @override
  Widget build(BuildContext context) {
    return Row(
      key: const ValueKey('club.topRow'),
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      spacing: 8,
      children: [
        // `white-space: nowrap`: um filho não flexível da Row é diagramado sem limite de largura, então o texto
        // nunca quebra.
        Pill(
          key: const ValueKey('club.pill'),
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          color: AppColors.blush,
          border: const BorderSide(width: 1.5, color: AppColors.ink),
          child: AppText('Clube do livro', style: AppTextStyles.label12Bold),
        ),
        _Avatars(club: club),
      ],
    );
  }
}

/// Avatares 26×26 (border-box, borda 1,5, raio 50 %) sobrepostos com `margin-left: −8` (passo 18): os de
/// depois pintam por cima. Os exibidos vêm dos dados; o último é o "+N" (`#FFFAF1`, Figtree 10). O grupo é
/// um único nó "11 participantes" (`aria-label` do arquivo).
class _Avatars extends StatelessWidget {
  const _Avatars({required this.club});

  final BookClub club;

  static const double _size = 26, _step = 26 - 8;

  @override
  Widget build(BuildContext context) {
    final extra = club.participantsCount - club.shownParticipants.length;
    final avatars = [
      for (final p in club.shownParticipants)
        (p.initial, p.color, AppTextStyles.micro11Bold),
      if (extra > 0)
        (
          HomeFormatters.participantsExtra(
            club.participantsCount,
            club.shownParticipants.length,
          ),
          AppColors.surface,
          AppTextStyles.avatarCount,
        ),
    ];
    return Semantics(
      container: true,
      label: HomeFormatters.participantsAria(club.participantsCount),
      excludeSemantics: true,
      child: SizedBox(
        key: const ValueKey('club.avatars'),
        // 26 + 3 × 18 = 80 × 26 (sem avatares, o flex vazio do CSS mede 0 × 0).
        width: avatars.isEmpty ? 0 : _size + (avatars.length - 1) * _step,
        height: avatars.isEmpty ? 0 : _size,
        child: Stack(
          children: [
            for (final (i, (label, color, style)) in avatars.indexed)
              Positioned(
                left: i * _step,
                child: NeoBox(
                  key: ValueKey('club.avatar$i'),
                  width: _size,
                  height: _size,
                  color: color,
                  border: const BorderSide(width: 1.5, color: AppColors.ink),
                  radius: BorderRadius.circular(_size / 2),
                  child: Center(child: AppText(label, style: style)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Título + subtítulo (gap 6). No arquivo o título é UM `<h3>` com `<br>`: "Leitoras de" (Bricolage 22,
/// line-height 1, ls −0,5) e "Capitu" (Instrument Serif itálico 36, line-height 0,95, ls −0,4). A 2ª linha mede
/// a caixa do itálico (34,2), que cobre o strut da Bricolage; como cada linha tem outro letter-spacing, são
/// dois `AppText` numa coluna (22 + 34,2 = 56,2), sob um único nó de cabeçalho "Leitoras de Capitu".
class _TitleBlock extends StatelessWidget {
  const _TitleBlock({required this.club});

  final BookClub club;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('club.titleBlock'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 6,
      children: [
        Semantics(
          container: true,
          header: true,
          headingLevel: 3, // <h3>
          label: HomeFormatters.clubName(club),
          excludeSemantics: true,
          child: Column(
            key: const ValueKey('club.title'),
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppText(club.namePrefix, style: AppTextStyles.clubTitle),
              AppText(club.nameHighlight, style: AppTextStyles.clubSerif),
            ],
          ),
        ),
        AppText(
          HomeFormatters.clubSubtitle(club.book, club.untilChapter),
          key: const ValueKey('club.subtitle'),
          style: AppTextStyles.body13Muted,
        ),
      ],
    );
  }
}

/// Progresso (gap 8): trilho 12 (raio 999, borda 1,5, hachura, recorte) com o preenchimento do grupo (54 % da
/// largura interna 218 → 117,72, `#FFC1C6`, borda direita 1,5, sem raio: a curva do trilho o recorta) e o
/// marcador "Você" 24×24 centrado em 62 % da largura TOTAL do trilho (221 → 137,02) e na metade da altura —
/// transborda 6 px acima e abaixo. Embaixo, as legendas (`space-between`).
class _ProgressBlock extends StatelessWidget {
  const _ProgressBlock({required this.club});

  final BookClub club;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('club.progressBlock'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        // O ticket está sob `IntrinsicHeight`: o `SizedBox` de altura fixa responde à consulta intrínseca sem
        // descer até o `LayoutBuilder` (que não calcula dimensões intrínsecas).
        SizedBox(
          key: const ValueKey('club.progressTrack'),
          height: 12,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth; // 221
              // `width: 54%` com `box-sizing: border-box`: a caixa nunca fica mais estreita que a própria borda
              // direita (1,5), então abaixo de 1,5 / 218 (0,69 %) o CSS ainda mostra o fio da borda no começo do
              // trilho. Com os dados do arquivo (0,54) não muda nada.
              final fillFactor = math.max(club.groupProgress, 1.5 / (w - 3));
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // role="progressbar" aria-label="Progresso do grupo" aria-valuenow="54".
                  Positioned.fill(
                    child: Semantics(
                      container: true,
                      label: 'Progresso do grupo',
                      value: HomeFormatters.percent(club.groupProgress),
                      excludeSemantics: true,
                      child: NeoBox(
                        key: const ValueKey('club.progressBar'),
                        border: const BorderSide(
                          width: 1.5,
                          color: AppColors.ink,
                        ),
                        radius: BorderRadius.circular(AppRadii.pill),
                        clip: true,
                        child: Stack(
                          children: [
                            const Positioned.fill(
                              child: CustomPaint(
                                painter: HatchPainter(stripe: AppColors.hatch),
                              ),
                            ),
                            // O `Align` deixa explícito o alinhamento à esquerda (a Stack já afrouxa as
                            // restrições); a Key está no `DecoratedBox`, que mede 117,72 × 9.
                            Align(
                              alignment: Alignment.centerLeft,
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: fillFactor,
                                heightFactor: 1,
                                child: const DecoratedBox(
                                  key: ValueKey('club.progressFill'),
                                  decoration: BoxDecoration(
                                    color: AppColors.blush,
                                    border: Border(
                                      right: BorderSide(
                                        width: 1.5,
                                        color: AppColors.ink,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // position: absolute; left: 62%; top: 50%; margin: −12px 0 0 −12px → pinta por cima do trilho.
                  Positioned(
                    left: w * club.userProgress - 12,
                    top: -6,
                    child: Semantics(
                      container: true,
                      label: 'Você',
                      excludeSemantics: true,
                      child: NeoBox(
                        key: const ValueKey('club.youMarker'),
                        width: 24,
                        height: 24,
                        color: AppColors.sun,
                        border: const BorderSide(
                          width: 1.5,
                          color: AppColors.ink,
                        ),
                        radius: BorderRadius.circular(12),
                        child: Center(
                          child: AppText(
                            club.userInitial,
                            style: AppTextStyles.markerInitial,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        Row(
          key: const ValueKey('club.progressLabels'),
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppText(
              HomeFormatters.groupProgressLabel(club.groupProgress),
              key: const ValueKey('club.groupLabel'),
              style: AppTextStyles.caption12Muted,
            ),
            AppText(
              HomeFormatters.userProgressLabel(club.userProgress),
              key: const ValueKey('club.youLabel'),
              style: AppTextStyles.label12Bold,
            ),
          ],
        ),
      ],
    );
  }
}

/// CTA 221 × 46 (raio 999, tinta), conteúdo centralizado com gap 8: balão 18 (traço `#F7F0E3`) + "Abrir
/// discussão" 14/700 `#F7F0E3` + badge (mín. 20 × 20, padding 0 6, `#FF552E`, texto tinta 11/700). O `<a>`
/// não tem `aria-label`: o nome do link é o texto; o badge é um nó próprio ("3 mensagens novas") dentro dele.
class _Cta extends StatelessWidget {
  const _Cta({required this.club, required this.onTap});

  final BookClub club;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      isLink: true, // <a href>
      onTap: onTap,
      child: NeoBox(
        key: const ValueKey('club.cta'),
        height: 46,
        color: AppColors.ink,
        radius: BorderRadius.circular(AppRadii.pill),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 8,
          children: [
            const AppSvg(
              AppIcons.messageCircle,
              size: 18,
              key: ValueKey('club.cta.icon'),
            ),
            AppText(
              'Abrir discussão',
              key: const ValueKey('club.cta.label'),
              style: AppTextStyles.cta14OnInk,
            ),
            Semantics(
              container: true,
              label: HomeFormatters.messagesAria(club.unreadMessages),
              excludeSemantics: true,
              child: CountBadge(
                key: const ValueKey('club.cta.badge'),
                label: '${club.unreadMessages}',
                style: AppTextStyles.micro11Bold,
                minWidth: 20,
                height: 20,
                horizontalPadding: 6,
                background: AppColors.flame,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Canhoto 92 × 263,6: fundo `#FFC1C6`, borda esquerda 1,5 TRACEJADA (a perfuração: 59 traços de 3 em 263,6,
/// vão 1,4931, algoritmo do Chromium), padding 18 8 e coluna centralizada com gap 12 — "ENCONTRO" / data
/// (QUI · 24 · SET) / pílula "20h": bloco de 131,3 centrado na vertical. Um único nó com o `aria-label` do
/// arquivo ("Próximo encontro: quinta, 24 de setembro, às 20h").
class _Stub extends StatelessWidget {
  const _Stub({required this.meeting});

  final DateTime meeting;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: HomeFormatters.meetingAria(meeting),
      excludeSemantics: true,
      child: ColoredBox(
        color: AppColors.blush,
        child: Stack(
          children: [
            // A borda tracejada sobre o fundo (os vãos mostram o blush, como no CSS).
            const Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 1.5,
              child: ExcludeSemantics(
                child: CustomPaint(
                  key: ValueKey('club.stub.perforation'),
                  painter: ChromiumDashPainter(axis: Axis.vertical),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(1.5 + 8, 18, 8, 18),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 12,
                  children: [
                    AppText(
                      'ENCONTRO',
                      key: const ValueKey('club.stub.label'),
                      style: AppTextStyles.stubLabel,
                    ),
                    Column(
                      key: const ValueKey('club.stub.date'),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppText(
                          HomeFormatters.weekdayShort(meeting),
                          key: const ValueKey('club.stub.weekday'),
                          style: AppTextStyles.stubMeta,
                        ),
                        AppText(
                          HomeFormatters.day(meeting),
                          key: const ValueKey('club.stub.day'),
                          style: AppTextStyles.stubDay,
                        ),
                        AppText(
                          HomeFormatters.monthShort(meeting),
                          key: const ValueKey('club.stub.month'),
                          style: AppTextStyles.stubMeta,
                        ),
                      ],
                    ),
                    Pill(
                      key: const ValueKey('club.stub.time'),
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 10,
                      ),
                      color: AppColors.surface,
                      border: const BorderSide(
                        width: 1.5,
                        color: AppColors.ink,
                      ),
                      child: AppText(
                        HomeFormatters.hourLabel(meeting),
                        style: AppTextStyles.body13Bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Entalhe 26×26 (border-box): círculo `#F7F0E3` (o fundo da tela) com borda 1,5 tinta. `aria-hidden`.
class _Notch extends StatelessWidget {
  const _Notch({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExcludeSemantics(
      child: NeoBox(
        width: 26,
        height: 26,
        color: AppColors.paper,
        border: BorderSide(width: 1.5, color: AppColors.ink),
        radius: BorderRadius.all(Radius.circular(13)),
      ),
    );
  }
}

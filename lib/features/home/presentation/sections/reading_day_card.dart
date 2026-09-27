import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/painters/chromium_dash.dart';
import '../../../../core/design_system/painters/goal_dial_painter.dart';
import '../../../../core/design_system/painters/hatch_painter.dart';
import '../../../../core/design_system/painters/top_border_crescent_painter.dart';
import '../../../../core/design_system/text/app_text.dart';
import '../../../../core/design_system/tokens/app_colors.dart';
import '../../../../core/design_system/tokens/app_icons.dart';
import '../../../../core/design_system/tokens/app_radii.dart';
import '../../../../core/design_system/tokens/app_shadows.dart';
import '../../../../core/design_system/tokens/app_strokes.dart';
import '../../../../core/design_system/tokens/app_typography.dart';
import '../../../../core/design_system/widgets/app_svg.dart';
import '../../../../core/design_system/widgets/neo_box.dart';
import '../../../../core/design_system/widgets/pill.dart';
import '../../application/formatters.dart';
import '../../application/home_providers.dart';
import '../../domain/models.dart';

/// Seção 5 — "Seu dia de leitura" (F07): cartão `#FED170`, borda 1,5, raio 28, sombra dura 4/4, padding 18 e
/// `overflow: hidden`; coluna com gap 16 — cabeçalho (32), linha da meta (112), cartão da semana (153,8) e
/// rodapé (16) → 400,8. Os dois círculos decorativos são `position: absolute` e vêm antes no DOM: pintam
/// ATRÁS do conteúdo (os demais filhos são `position: relative`) e o canto arredondado os recorta.
class ReadingDayCard extends ConsumerWidget {
  const ReadingDayCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final day = ref.watch(homeSnapshotProvider.select((s) => s.readingDay));
    final weekColor = ref.watch(homeThemeProvider.select((t) => t.weekColor));
    // <section aria-label="Seu dia de leitura"> (convenção §5.1 do prompt mestre).
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: 'Seu dia de leitura',
      child: NeoBox(
        key: const ValueKey('today'),
        color: AppColors.sun,
        border: const BorderSide(width: 1.5, color: AppColors.ink),
        radius: BorderRadius.circular(AppRadii.card),
        shadow: AppShadows.hard4,
        clip: true,
        // Stack = padding box (dentro da borda): referência dos círculos absolutos. Sem recorte próprio —
        // o único recorte é o do cartão (padding box com raio interno 26,5).
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Primeiros na Stack → pintados atrás do conteúdo.
            const Positioned(
              right: -46,
              top: -46,
              child: _DecoCircle(id: 'today.decoCircleLarge', size: 153),
            ),
            const Positioned(
              right: -20,
              top: -20,
              child: _DecoCircle(id: 'today.decoCircleSmall', size: 101),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min, // altura auto do CSS
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 16,
                children: [
                  _Header(streakDays: day.streakDays),
                  _GoalRow(day: day),
                  _WeekCard(day: day, weekColor: weekColor),
                  _Footer(day: day),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Círculo decorativo `aria-hidden` em content-box: 150 + 2 × 1,5 = 153 e 98 + 3 = 101. Só a borda
/// `rgba(26,23,20,.14)`, sem preenchimento; raio 50 %.
class _DecoCircle extends StatelessWidget {
  const _DecoCircle({required this.id, required this.size});

  /// `today.decoCircleLarge` / `today.decoCircleSmall`.
  final String id;

  /// Tamanho externo (conteúdo + bordas).
  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: NeoBox(
        key: ValueKey(id),
        width: size,
        height: size,
        border: const BorderSide(width: 1.5, color: AppColors.decoRing),
        radius: BorderRadius.circular(size / 2),
      ),
    );
  }
}

/// Cabeçalho (32, `space-between`, centralizado): o `<h3>` misto numa linha de 29,9 (a serifada define
/// ascendente e descendente) → y + 1,05; pílula de sequência 84,23 × 32.
class _Header extends StatelessWidget {
  const _Header({required this.streakDays});

  final int streakDays;

  @override
  Widget build(BuildContext context) {
    return Row(
      key: const ValueKey('today.header'),
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // "Seu dia de " + <span>leitura</span>: um parágrafo, duas fontes, a mesma baseline. O AppText não é
        // fronteira semântica: o texto vira o rótulo deste nó de cabeçalho.
        Semantics(
          container: true,
          header: true,
          headingLevel: 3, // <h3>
          child: AppText.rich(
            TextSpan(
              text: 'Seu dia de ',
              style: AppTextStyles.cardTitleM,
              children: [
                TextSpan(text: 'leitura', style: AppTextStyles.cardSerifM),
              ],
            ),
            key: const ValueKey('today.title'),
          ),
        ),
        // height 32, padding 0 11 0 8, gap 5: chama 17 + "12 dias" → 1,5 + 8 + 17 + 5 + 40,23 + 11 + 1,5.
        NeoBox(
          key: const ValueKey('today.streakPill'),
          height: 32,
          color: AppColors.surface,
          border: const BorderSide(width: 1.5, color: AppColors.ink),
          radius: BorderRadius.circular(AppRadii.pill),
          padding: const EdgeInsets.fromLTRB(8, 0, 11, 0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 5,
            children: [
              const AppSvg(
                AppIcons.flame,
                size: 17,
                key: ValueKey('today.streakPill.icon'),
              ),
              AppText(
                HomeFormatters.countLabel(streakDays, 'dia', 'dias'),
                style: AppTextStyles.body13Bold,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Linha da meta (gap 18, centralizada): o dial 112 (`flex-shrink: 0`) e a coluna de texto, que encolhe até
/// os 181 restantes (`min-width: 0`) e fica centrada na altura do dial (75,8 → y + 18,1).
class _GoalRow extends StatelessWidget {
  const _GoalRow({required this.day});

  final ReadingDay day;

  @override
  Widget build(BuildContext context) {
    final remaining = HomeFormatters.remainingGoal(
      day.goalMinutes,
      day.readMinutes,
    );
    return Row(
      key: const ValueKey('today.goalRow'),
      spacing: 18,
      children: [
        _GoalDial(readMinutes: day.readMinutes, goalMinutes: day.goalMinutes),
        Expanded(
          child: Column(
            key: const ValueKey('today.goalText'),
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 10,
            children: [
              // line-height 1,3; quebra em "Faltam 12 min para fechar" / "a meta de hoje." (o "a" estouraria
              // os 181 por 5,55 — o `text-wrap: pretty` do arquivo dá o mesmo resultado do quebrador guloso).
              AppText.rich(
                TextSpan(
                  text: remaining.before,
                  style: AppTextStyles.goalSentence,
                  children: [
                    TextSpan(
                      text: remaining.strong,
                      style: AppTextStyles.goalSentenceStrong,
                    ),
                    TextSpan(text: remaining.after),
                  ],
                ),
                key: const ValueKey('today.goalText.sentence'),
              ),
              // flex-wrap: wrap com gap 6 nos dois sentidos (em 360 o segundo chip desce).
              Wrap(
                key: const ValueKey('today.chips'),
                spacing: 6,
                runSpacing: 6,
                children: [
                  _Chip(
                    id: 'today.chip.pages',
                    label: HomeFormatters.countLabel(
                      day.pagesToday,
                      'página',
                      'páginas',
                    ),
                  ),
                  _Chip(
                    id: 'today.chip.highlights',
                    label: HomeFormatters.countLabel(
                      day.highlightsToday,
                      'destaque',
                      'destaques',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Dial 112×112: o `<svg>` `aria-hidden` (face, 31 marcações, arco de 60 %, pino) e, por cima, a coluna
/// centralizada "18" (34, line-height 1) + "de 30 min" (bloco de 47,2 → y + 32,4), que continua legível.
class _GoalDial extends StatelessWidget {
  const _GoalDial({required this.readMinutes, required this.goalMinutes});

  final int readMinutes;
  final int goalMinutes;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const ValueKey('today.dial'),
      width: 112,
      height: 112,
      child: Stack(
        children: [
          // Positioned.fill: sem filho e com restrição frouxa, o CustomPaint mediria 0×0.
          Positioned.fill(
            child: ExcludeSemantics(
              child: CustomPaint(
                key: const ValueKey('today.dial.svg'),
                painter: GoalDialPainter(progress: readMinutes / goalMinutes),
              ),
            ),
          ),
          Positioned.fill(
            child: Column(
              key: const ValueKey('today.dial.center'),
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppText(
                  '$readMinutes',
                  key: const ValueKey('today.dial.value'),
                  style: AppTextStyles.dialValue,
                ),
                AppText(
                  'de $goalMinutes min',
                  key: const ValueKey('today.dial.caption'),
                  style: AppTextStyles.dialCaption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Chip: `padding: 5px 9px`, borda 1,2, fundo `rgba(255,250,241,.7)`, 12/700 → 26,8 de altura.
class _Chip extends StatelessWidget {
  const _Chip({required this.id, required this.label});

  /// `today.chip.pages` / `today.chip.highlights`.
  final String id;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Pill(
      key: ValueKey(id),
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 9),
      color: AppColors.chipGlass,
      border: const BorderSide(width: AppStrokes.thin, color: AppColors.ink),
      child: AppText(label, style: AppTextStyles.label12Bold),
    );
  }
}

/// Cartão da semana 311 × 153,8: `#FFFAF1`, borda 1,5, raio 22, padding 14/14/12, coluna gap 8 — cabeçalho
/// por baseline (15,6), gráfico (80) e rótulos (13,2). Sem sombra e sem recorte.
class _WeekCard extends StatelessWidget {
  const _WeekCard({required this.day, required this.weekColor});

  final ReadingDay day;

  /// `{{weekColor}}` do arquivo: só os preenchimentos dos dias anteriores (o de hoje é `#FF552E`).
  final Color weekColor;

  @override
  Widget build(BuildContext context) {
    final week = day.week;
    final labels = HomeFormatters.weekInitials(week);
    return NeoBox(
      key: const ValueKey('today.week'),
      color: AppColors.surface,
      border: const BorderSide(width: 1.5, color: AppColors.ink),
      radius: BorderRadius.circular(AppRadii.cardM),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          // align-items: baseline — o total (ascendente menor) começa 0,95 mais abaixo.
          Row(
            key: const ValueKey('today.week.header'),
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              AppText(
                'Esta semana',
                key: const ValueKey('today.week.title'),
                style: AppTextStyles.body13Bold,
              ),
              AppText(
                HomeFormatters.weekTotalLabel(week),
                key: const ValueKey('today.week.total'),
                style: AppTextStyles.caption12Muted,
              ),
            ],
          ),
          // <div aria-label="Minutos lidos por dia: …">: o rótulo do arquivo e o desenho fora da árvore.
          Semantics(
            container: true,
            label: HomeFormatters.weekAria(week, day.goalMinutes),
            excludeSemantics: true,
            child: SizedBox(
              key: const ValueKey('today.week.chart'),
              height: 80,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // grid de 7 × minmax(0, 1fr) com gap 8 → colunas de 33,143, alinhadas embaixo.
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    spacing: 8,
                    children: [
                      for (final (i, stat) in week.indexed)
                        Expanded(
                          child: _Bar(
                            id: 'today.week.bar$i',
                            stat: stat,
                            color: stat.isToday ? AppColors.flame : weekColor,
                          ),
                        ),
                    ],
                  ),
                  // Linha da meta: position: absolute → pinta POR CIMA das barras (left/right −4, bottom 38;
                  // 64 traços em 288, opacidade .45 na cor).
                  const Positioned(
                    left: -4,
                    right: -4,
                    bottom: 38,
                    height: 1.5,
                    child: CustomPaint(
                      key: ValueKey('today.week.goalLine'),
                      painter: ChromiumDashPainter(
                        axis: Axis.horizontal,
                        thickness: 1.5,
                        color: AppColors.goalLine,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Mesma grade do gráfico, texto centralizado; "Hoje" em tinta (800 → 700).
          Row(
            key: const ValueKey('today.week.labels'),
            spacing: 8,
            children: [
              for (final (i, stat) in week.indexed)
                Expanded(
                  child: AppText(
                    labels[i],
                    key: ValueKey('today.week.label$i'),
                    style: stat.isToday
                        ? AppTextStyles.micro11Bold
                        : AppTextStyles.weekDay,
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Trilho 80 (raio 999 → 16,571) com borda 1,2 (1,5 no de hoje), hachura 135° na padding box e o
/// preenchimento alinhado embaixo, com a borda superior em meia-lua. O recorte do trilho (raio interno
/// 15,371 / 15,071) arredonda também a base do preenchimento.
class _Bar extends StatelessWidget {
  const _Bar({required this.id, required this.stat, required this.color});

  /// `today.week.bar0` … `today.week.bar6`.
  final String id;
  final WeekDayStat stat;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final today = stat.isToday;
    return NeoBox(
      key: ValueKey(id),
      height: 80,
      border: BorderSide(
        width: today ? AppStrokes.regular : AppStrokes.thin,
        color: AppColors.ink,
      ),
      radius: BorderRadius.circular(AppRadii.pill),
      clip: true,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: HatchPainter(
                stripe: today ? AppColors.hatchToday : AppColors.hatch,
              ),
            ),
          ),
          // width: 100%; display: flex + align-items: flex-end → encostado embaixo.
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              key: ValueKey('$id.fill'),
              height: stat.barHeightPx,
              width: double.infinity,
              child: CustomPaint(
                painter: TopBorderCrescentPainter(fill: color),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Rodapé (16, gap 8, centralizado): brilho sólido 16 + a frase 13/600 com "2 dias" 800 → 700 (a linha de
/// 15,6 fica centrada → y + 0,2).
class _Footer extends StatelessWidget {
  const _Footer({required this.day});

  final ReadingDay day;

  @override
  Widget build(BuildContext context) {
    final hint = HomeFormatters.badgeHint(day.streakDays, day.badgeTargetDays);
    return Row(
      key: const ValueKey('today.footer'),
      spacing: 8,
      children: [
        const AppSvg(
          AppIcons.sparkleSolid,
          size: 16,
          key: ValueKey('today.footer.icon'),
        ),
        AppText.rich(
          TextSpan(
            text: hint.before,
            style: AppTextStyles.body13Semi,
            children: [
              TextSpan(text: hint.strong, style: AppTextStyles.body13Bold),
              TextSpan(text: hint.after),
            ],
          ),
          key: const ValueKey('today.footer.text'),
        ),
      ],
    );
  }
}

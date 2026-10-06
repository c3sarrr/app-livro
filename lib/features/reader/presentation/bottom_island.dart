// G12.3 — ilha de baixo dos controles (`r20.bottomIsland`, L20b, "Controles de leitura"): a barra de posição, a
// linha de progresso ("62% do livro · 256 pág." e "≈ 2 h 10 min") e as 5 ferramentas sob um tracejado. Tema
// alterna o papel (D-121); Fonte, Grifos, Anotar e Sumário chegam em fases próximas (D-118) — a tela decide o que
// cada uma faz. No PDF a Fonte fica cinza e desabilitada (D-122). O contador de Grifos some com 0 e mostra "99+"
// acima de 99 (D-124); o leitor de tela ouve o número junto do rótulo.
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../../core/design_system/text/app_text.dart';
import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_icons_leitor.dart';
import '../../../core/design_system/tokens/app_shadows.dart';
import '../../../core/design_system/tokens/app_strokes.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/app_svg.dart';
import '../../../core/design_system/widgets/count_badge.dart';
import '../../../core/design_system/widgets/neo_box.dart';
import '../../../core/design_system/widgets/pressable.dart';
import '../application/reader_chrome.dart' show readerNotesBadge;
import '../application/reader_document.dart';
import 'reader_chrome_scope.dart';
import 'scrubber.dart';

/// As ferramentas da ilha de baixo, na ordem do arquivo.
enum ReaderTool { font, theme, notes, annotate, toc }

/// Borda de cima tracejada como o `border-top: dashed` do Chromium: traço = 2 × espessura, vão ≈ espessura,
/// ajustado para começar e terminar com traço (1,5 px → 3/1,5 numa largura de 327 — medido na prancha @3x).
class DashedTopBorderPainter extends CustomPainter {
  const DashedTopBorderPainter({required this.color, this.width = 1.5});

  final Color color;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    final dash = 2 * width;
    final length = size.width;
    if (length <= 0) return;
    final n = math.max(1, ((length + width) / (dash + width)).round());
    final gap = n == 1 ? 0.0 : (length - n * dash) / (n - 1);
    final paint = Paint()..color = color;
    for (var i = 0; i < n; i++) {
      final x = i * (dash + gap);
      canvas.drawRect(
        Rect.fromLTWH(x, 0, math.min(dash, length - x), width),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(DashedTopBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.width != width;
}

class BottomIsland extends StatelessWidget {
  const BottomIsland({
    super.key,
    required this.numbers,
    required this.timeLeftLabel,
    required this.notes,
    required this.isPdf,
    required this.onJump,
    required this.onTool,
  });

  final ReaderNumbersView numbers;

  /// "≈ 2 h 10 min"; `null` = não mostra (fim do livro).
  final String? timeLeftLabel;

  /// Grifos + notas + à mão + desenhos do livro (o contador).
  final int notes;

  /// PDF: Fonte desabilitada (D-122).
  final bool isPdf;
  final ValueChanged<int> onJump;
  final ValueChanged<ReaderTool> onTool;

  @override
  Widget build(BuildContext context) {
    final s = ReaderChromeScope.of(context);
    final p = s.palette;
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: 'Controles de leitura',
      child: NeoBox(
        key: const ValueKey('r20.bottomIsland'),
        color: p.island,
        border: BorderSide(width: AppStrokes.regular, color: p.border),
        radius: BorderRadius.circular(28),
        shadow: AppShadows.hard3,
        shadowColor: p.shadow,
        padding: const EdgeInsets.fromLTRB(16, 30, 16, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Scrubber(
              page: numbers.refPage,
              total: numbers.refTotal,
              progression: numbers.progression,
              onJump: onJump,
            ),
            const SizedBox(height: 8),
            _ProgressRow(numbers: numbers, timeLeftLabel: timeLeftLabel),
            const SizedBox(height: 14),
            _ToolsRow(notes: notes, isPdf: isPdf, onTool: onTool),
          ],
        ),
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({required this.numbers, required this.timeLeftLabel});

  final ReaderNumbersView numbers;
  final String? timeLeftLabel;

  @override
  Widget build(BuildContext context) {
    final p = ReaderChromeScope.of(context).palette;
    final muted = AppTextStyles.readerProgress.copyWith(color: p.muted);
    final left = timeLeftLabel;
    return Row(
      key: const ValueKey('r20.bottomIsland.progressRow'),
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.rich(
          TextSpan(
            children: [
              TextSpan(
                text: numbers.percentLabel,
                style: AppTextStyles.readerProgressStrong.copyWith(
                  color: p.title,
                ),
              ),
              TextSpan(
                text: ' do livro · ${numbers.refTotal} pág.',
                style: muted,
              ),
            ],
          ),
          key: const ValueKey('r20.bottomIsland.progressRow.position'),
          maxLines: 1,
        ),
        if (left != null)
          AppText(
            left,
            key: const ValueKey('r20.bottomIsland.progressRow.timeLeft'),
            style: muted,
            maxLines: 1,
          ),
      ],
    );
  }
}

class _ToolsRow extends StatelessWidget {
  const _ToolsRow({
    required this.notes,
    required this.isPdf,
    required this.onTool,
  });

  final int notes;
  final bool isPdf;
  final ValueChanged<ReaderTool> onTool;

  @override
  Widget build(BuildContext context) {
    final p = ReaderChromeScope.of(context).palette;
    return CustomPaint(
      key: const ValueKey('r20.bottomIsland.tools'),
      painter: DashedTopBorderPainter(color: p.dash),
      child: Padding(
        padding: const EdgeInsets.only(top: AppStrokes.regular + 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final t in ReaderTool.values)
              Expanded(
                child: _Tool(
                  tool: t,
                  notes: notes,
                  enabled: !(isPdf && t == ReaderTool.font),
                  onTap: () => onTool(t),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Tool extends StatelessWidget {
  const _Tool({
    required this.tool,
    required this.notes,
    required this.enabled,
    required this.onTap,
  });

  final ReaderTool tool;
  final int notes;
  final bool enabled;
  final VoidCallback onTap;

  static const _id = {
    ReaderTool.font: 'font',
    ReaderTool.theme: 'theme',
    ReaderTool.notes: 'notes',
    ReaderTool.annotate: 'annotate',
    ReaderTool.toc: 'toc',
  };

  static const _label = {
    ReaderTool.font: 'Fonte',
    ReaderTool.theme: 'Tema',
    ReaderTool.notes: 'Grifos',
    ReaderTool.annotate: 'Anotar',
    ReaderTool.toc: 'Sumário',
  };

  /// O nome lido pelo leitor de tela (o do arquivo; Grifos com o número de marcas).
  String get _spoken => switch (tool) {
    ReaderTool.annotate => 'Anotar à mão',
    ReaderTool.notes when notes == 1 => 'Grifos, 1 marca',
    ReaderTool.notes when notes > 1 => 'Grifos, $notes marcas',
    _ => _label[tool]!,
  };

  @override
  Widget build(BuildContext context) {
    final s = ReaderChromeScope.of(context);
    final p = s.palette;
    final night = p.night;
    final id = 'r20.bottomIsland.tools.${_id[tool]}';
    final ink = enabled ? p.title : p.disabled;
    final String? icon = switch (tool) {
      ReaderTool.font => null,
      ReaderTool.theme => night ? AppIconsLeitor.moon : AppIconsLeitor.sun,
      ReaderTool.notes =>
        night ? AppIconsLeitor.highlighterNight : AppIconsLeitor.highlighter,
      ReaderTool.annotate =>
        night ? AppIconsLeitor.annotateNight : AppIconsLeitor.annotate,
      ReaderTool.toc => night ? AppIconsLeitor.tocNight : AppIconsLeitor.toc,
    };
    final badge = tool == ReaderTool.notes ? readerNotesBadge(notes) : null;
    return Pressable(
      key: ValueKey(id),
      semanticsLabel: _spoken,
      enabled: enabled,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 5,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              NeoBox(
                key: ValueKey('$id.circle'),
                width: 52,
                height: 44,
                color: p.well,
                border: BorderSide(width: AppStrokes.regular, color: ink),
                radius: BorderRadius.circular(16),
                child: Center(
                  child: icon == null
                      ? AppText(
                          'Aa',
                          style: AppTextStyles.readerToolAa.copyWith(
                            color: ink,
                          ),
                        )
                      : AppSvg(
                          icon,
                          key: ValueKey('$id.icon'),
                          size: 21,
                          opacity: s.a,
                        ),
                ),
              ),
              if (badge != null)
                Positioned(
                  // medido da borda de dentro da caixa (−8 do lado de fora da borda de 1,5)
                  top: AppStrokes.regular - 8,
                  right: AppStrokes.regular - 8,
                  child: CountBadge(
                    key: ValueKey('$id.badge'),
                    label: badge,
                    style: AppTextStyles.readerBadge.copyWith(
                      color: s.tint(AppColors.ink),
                    ),
                    minWidth: 22,
                    height: 22,
                    horizontalPadding: 5,
                    background: s.tint(AppColors.sun),
                    border: BorderSide(
                      width: AppStrokes.regular,
                      color: s.tint(AppColors.ink),
                    ),
                  ),
                ),
            ],
          ),
          AppText(
            _label[tool]!,
            style: AppTextStyles.readerToolLabel.copyWith(color: ink),
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}

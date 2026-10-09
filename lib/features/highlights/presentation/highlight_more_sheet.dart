// G19.7 — as folhas da tela 25 (D-192; D-23: não desenhadas, no padrão da folha da nota — D-131): o véu e o cartão a
// 14 das bordas, raio 28, borda 1,5 e sombra dura, com as cores das ilhas do Creme. "Mais opções" de um cartão
// (R11): no alto "pág. N · ‹rótulo da R4›" e o começo do trecho; Editar/Escrever nota e Trocar cor (só em cartão com
// grifo), Compartilhar no clube, Apagar e Fechar. A nota abre a `NoteSheet` do leitor.
import 'dart:math' as math;

import 'package:flutter/rendering.dart' show SemanticsRole;
import 'package:flutter/widgets.dart';

import '../../../core/design_system/text/app_text.dart';
import '../../../core/design_system/tokens/app_shadows.dart';
import '../../../core/design_system/tokens/app_strokes.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/neo_box.dart';
import '../../../core/design_system/widgets/pressable.dart';
import '../../reader/annotations/domain/annotation.dart';
import '../../reader/domain/locator.dart';
import '../../reader/domain/reader_settings.dart';
import '../../reader/presentation/color_picker.dart' show colorLabel;
import '../../reader/presentation/highlight_toolbar.dart'
    show highlightPalette, toolbarMarkGap, toolbarSwatch;
import '../../reader/presentation/note_sheet.dart';
import '../../reader/presentation/reader_actions.dart' show cleanExcerpt;
import '../../reader/presentation/reader_chrome_palette.dart';
import '../../reader/presentation/reader_palette.dart';
import '../domain/highlight_card.dart';
import 'highlight_card.dart' show hexColor;

/// A folha fica a 14 das bordas (a da nota — D-131).
const double hlSheetMargin = 14;

/// O rótulo do cartão na folha: "GRIFO + NOTA", "DESENHO + À MÃO".
String cardKindText(HighlightCard c) => [
  c.label,
  if (c.hasNotePill) 'NOTA',
  if (c.hasHandPill) 'À MÃO',
].join(' + ');

/// O trecho do grifo da nota do cartão (o `exact` da âncora); sem grifo, [fallback].
String cardExcerpt(HighlightCard c, String fallback) =>
    switch (c.noteParent?.anchor) {
      EpubAnchor(:final quote) => quote.exact,
      _ => fallback,
    };

/// O véu e o cartão da folha (o véu fecha).
class HighlightsSheetFrame extends StatelessWidget {
  const HighlightsSheetFrame({
    super.key,
    required this.id,
    required this.label,
    required this.palette,
    required this.onDismiss,
    required this.child,
  });

  /// `hl.more`, `hl.export`.
  final String id;
  final String label;
  final ReaderChromePalette palette;
  final VoidCallback onDismiss;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            excludeFromSemantics: true,
            onTap: onDismiss,
            child: ColoredBox(key: ValueKey('$id.veil'), color: p.veil),
          ),
        ),
        Positioned(
          left: hlSheetMargin,
          right: hlSheetMargin,
          // acima da área segura e do teclado
          bottom:
              math.max(
                MediaQuery.viewPaddingOf(context).bottom,
                MediaQuery.viewInsetsOf(context).bottom,
              ) +
              hlSheetMargin,
          child: Semantics(
            container: true,
            role: SemanticsRole.dialog,
            scopesRoute: true,
            namesRoute: true,
            explicitChildNodes: true,
            label: label,
            child: NeoBox(
              key: ValueKey(id),
              color: p.island,
              border: BorderSide(width: AppStrokes.regular, color: p.border),
              radius: BorderRadius.circular(28),
              shadow: AppShadows.hard3,
              shadowColor: p.shadow,
              padding: const EdgeInsets.all(16),
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}

/// Um botão da folha: pílula de 48 com a borda 1,5.
Widget sheetButton(
  ReaderChromePalette p,
  String key,
  String label, {
  required VoidCallback? onTap,
  Color? fill,
  Offset? shadow,
}) => Pressable(
  semanticsLabel: label,
  enabled: onTap != null,
  onTap: onTap,
  child: NeoBox(
    key: ValueKey(key),
    height: 48,
    color: fill ?? p.island,
    border: BorderSide(width: AppStrokes.regular, color: p.border),
    radius: BorderRadius.circular(999),
    shadow: shadow,
    shadowColor: p.shadow,
    child: Center(
      child: AppText(
        label,
        style: AppTextStyles.readerNoteButton.copyWith(
          color: onTap == null ? p.disabled : p.title,
        ),
        maxLines: 1,
      ),
    ),
  ),
);

class HighlightMoreSheet extends StatelessWidget {
  const HighlightMoreSheet({
    super.key,
    required this.card,
    required this.excerpt,
    required this.palette,
    required this.onNote,
    required this.onColor,
    required this.onShare,
    required this.onDelete,
    required this.onClose,
  });

  final HighlightCard card;

  /// O texto do cartão (o começo vai numa linha, com "…").
  final String excerpt;
  final ReaderChromePalette palette;
  final VoidCallback onNote;
  final ValueChanged<String> onColor;
  final VoidCallback onShare;
  final VoidCallback onDelete;
  final VoidCallback onClose;

  Widget _colors(ReaderChromePalette p, String current) {
    final line = BorderSide(width: AppStrokes.regular, color: p.border);
    final known = highlightPalette.any((c) => c.hex == current);
    final swatches = [
      for (final c in highlightPalette)
        (key: c.key, hex: c.hex, label: c.label),
      if (!known)
        (
          key: 'current',
          hex: current,
          label: 'Cor atual: ${colorLabel(current)}',
        ),
    ];
    const out = toolbarMarkGap + AppStrokes.regular;
    return Row(
      key: const ValueKey('hl.more.colors'),
      spacing: 10,
      children: [
        Expanded(
          child: AppText(
            'Trocar cor',
            style: AppTextStyles.readerNoteButton.copyWith(color: p.title),
            maxLines: 1,
          ),
        ),
        for (final s in swatches)
          Pressable(
            semanticsLabel: s.label,
            selected: s.hex == current,
            // a marcada não faz nada (para apagar há o Apagar)
            onTap: s.hex == current ? () {} : () => onColor(s.hex),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                NeoBox(
                  key: ValueKey('hl.more.colors.${s.key}'),
                  width: toolbarSwatch,
                  height: toolbarSwatch,
                  color: hexColor(s.hex),
                  border: line,
                  radius: BorderRadius.circular(toolbarSwatch / 2),
                ),
                if (s.hex == current)
                  Positioned(
                    key: ValueKey('hl.more.colors.${s.key}.marked'),
                    left: -out,
                    top: -out,
                    width: toolbarSwatch + 2 * out,
                    height: toolbarSwatch + 2 * out,
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.fromBorderSide(line),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final h = card.highlight;
    final current = h?.color;
    return HighlightsSheetFrame(
      id: 'hl.more',
      label: 'Mais opções',
      palette: p,
      onDismiss: onClose,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          AppText(
            'pág. ${card.page} · ${cardKindText(card)}',
            key: const ValueKey('hl.more.title'),
            style: AppTextStyles.readerToolbarLabel.copyWith(color: p.label),
            maxLines: 1,
          ),
          AppText(
            cleanExcerpt(excerpt),
            key: const ValueKey('hl.more.excerpt'),
            style: AppTextStyles.readerSearchExcerpt.copyWith(
              color: ReaderPalette.of(ReaderPaper.creme).text,
            ),
            maxLines: 1,
            ellipsis: true,
          ),
          const SizedBox(height: 2),
          if (h != null) ...[
            sheetButton(
              p,
              'hl.more.note',
              card.notes.isEmpty ? 'Escrever nota' : 'Editar nota',
              onTap: onNote,
            ),
            if (current != null && h.kind == AnnotationKind.highlight)
              _colors(p, current),
          ],
          sheetButton(
            p,
            'hl.more.share',
            'Compartilhar no clube',
            onTap: onShare,
          ),
          sheetButton(p, 'hl.more.delete', 'Apagar', onTap: onDelete),
          sheetButton(p, 'hl.more.close', 'Fechar', onTap: onClose),
        ],
      ),
    );
  }
}

/// A nota do grifo do cartão: a `NoteSheet` do leitor (D-131) com o trecho e o texto que já existe.
class HighlightNoteSheet extends StatelessWidget {
  const HighlightNoteSheet({
    super.key,
    required this.card,
    required this.palette,
    required this.brand,
    required this.onCancel,
    required this.onSave,
  });

  final HighlightCard card;
  final ReaderChromePalette palette;
  final Color brand;
  final VoidCallback onCancel;
  final ValueChanged<String> onSave;

  @override
  Widget build(BuildContext context) => NoteSheet(
    excerpt: cleanExcerpt(cardExcerpt(card, '')),
    initial: card.notes.firstOrNull?.noteText ?? '',
    palette: palette,
    paper: ReaderPalette.of(ReaderPaper.creme),
    brand: brand,
    onCancel: onCancel,
    onSave: onSave,
  );
}

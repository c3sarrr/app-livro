// G19.4 — os filtros da tela 25 (L25b):
// - tipo (`radiogroup` "Tipo"): os chips de 40 na faixa que rola na horizontal, com a máscara do arquivo (preto até
//   85 % → transparente); o ativo com a `brand` e a sombra 2/2; o número em 700 (`#1A1714` no ativo, `#8A8073` nos
//   outros) — as contagens são as do livro (R1); a máscara é o papel em degradê por cima (sem `ShaderMask` — 12.4);
// - cor (`group` "Filtrar por cor"): "COR" + as caixas redondas de 28 (D-196), a marcada com o anel da tela 21
//   (D-201); com mais cores do que cabem, a fileira rola na horizontal junto com o "COR";
// - "Só do clube" (`switch`): o círculo rosa com `ic_people` 15; ligado, a pílula rosa com a sombra 2/2 (D-202).
import 'package:flutter/rendering.dart' show SemanticsRole;
import 'package:flutter/widgets.dart';

import '../../../core/design_system/text/app_text.dart';
import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_icons_leitor.dart';
import '../../../core/design_system/tokens/app_strokes.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/app_svg.dart';
import '../../../core/design_system/widgets/neo_box.dart';
import '../../../core/design_system/widgets/pressable.dart';
import '../../../core/design_system/widgets/tap_target.dart';
import '../../reader/annotations/domain/annotation_stats.dart';
import '../domain/card_filters.dart';
import 'highlight_card.dart' show hexColor;

const BorderSide _line = BorderSide(
  width: AppStrokes.regular,
  color: AppColors.ink,
);

/// A faixa dos tipos: os chips de 40 + o padding de baixo 4 (a sombra do ativo cabe).
const double typesHeight = 44;

/// O esmaecido da direita da faixa: o papel de 0 % (até 85 % da largura) a 100 % (na borda).
const LinearGradient typesFade = LinearGradient(
  colors: [
    AppColors.paperTransparent,
    AppColors.paperTransparent,
    AppColors.paper,
  ],
  stops: [0, 0.85, 1],
);

/// As caixas de cor: 28, a 5 uma da outra; o anel da marcada a 1,5 (D-201).
const double colorSwatch = 28;
const double colorGap = 5;
const double colorRingGap = 1.5;

/// O id de cada tipo no arquivo (`hl.types.<id>`).
const Map<TypeFilter, String> typeIds = {
  TypeFilter.all: 'all',
  TypeFilter.highlights: 'highlights',
  TypeFilter.notes: 'notes',
  TypeFilter.handwriting: 'handwritten',
  TypeFilter.drawings: 'drawings',
};

const Map<TypeFilter, String> typeNames = {
  TypeFilter.all: 'Tudo',
  TypeFilter.highlights: 'Grifos',
  TypeFilter.notes: 'Notas',
  TypeFilter.handwriting: 'À mão',
  TypeFilter.drawings: 'Desenhos',
};

int typeCount(TypeFilter t, AnnotationKindCounts c) => switch (t) {
  TypeFilter.all => c.highlights + c.notes + c.handwriting + c.drawings,
  TypeFilter.highlights => c.highlights,
  TypeFilter.notes => c.notes,
  TypeFilter.handwriting => c.handwriting,
  TypeFilter.drawings => c.drawings,
};

class HighlightTypes extends StatelessWidget {
  const HighlightTypes({
    super.key,
    required this.counts,
    required this.active,
    required this.brand,
    required this.onType,
  });

  final AnnotationKindCounts counts;
  final TypeFilter active;
  final Color brand;
  final ValueChanged<TypeFilter> onType;

  Widget _chip(TypeFilter t) {
    final on = t == active;
    final id = 'hl.types.${typeIds[t]}';
    final n = typeCount(t, counts);
    return Pressable(
      checked: on,
      semanticsLabel: '${typeNames[t]}, $n',
      onTap: () => onType(t),
      child: NeoBox(
        key: ValueKey(id),
        height: 40,
        color: on ? brand : AppColors.surface,
        border: _line,
        radius: BorderRadius.circular(999),
        shadow: on ? const Offset(2, 2) : null,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: [
            AppText(typeNames[t]!, style: AppTextStyles.hlChip, maxLines: 1),
            AppText(
              '$n',
              key: ValueKey('$id.count'),
              style: on
                  ? AppTextStyles.hlChipCount.copyWith(color: AppColors.ink)
                  : AppTextStyles.hlChipCount,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    role: SemanticsRole.radioGroup,
    label: 'Tipo',
    explicitChildNodes: true,
    child: SizedBox(
      key: const ValueKey('hl.types'),
      height: typesHeight,
      // a máscara do arquivo (preto até 85 % → transparente), sem camada intermediária (D-124, F12 12.4): o fundo
      // é o papel liso, então o papel em degradê por cima dá o mesmo
      child: Stack(
        children: [
          ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            children: [
              for (final (i, t) in TypeFilter.values.indexed) ...[
                if (i > 0) const SizedBox(width: 8),
                Align(alignment: Alignment.topCenter, child: _chip(t)),
              ],
            ],
          ),
          const Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                key: ValueKey('hl.types.fade'),
                decoration: BoxDecoration(gradient: typesFade),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class HighlightColorFilters extends StatelessWidget {
  const HighlightColorFilters({
    super.key,
    required this.colors,
    required this.marked,
    required this.clubOnly,
    required this.onColor,
    required this.onClubOnly,
  });

  final List<ColorChoice> colors;
  final Set<String> marked;
  final bool clubOnly;
  final ValueChanged<String> onColor;
  final ValueChanged<bool> onClubOnly;

  Widget _swatch(ColorChoice c) {
    final on = marked.contains(c.hex);
    final id = 'hl.filters.colors.${c.key}';
    const out = colorRingGap + AppStrokes.regular;
    return TapTarget(
      child: Pressable(
        checked: on,
        exclusive: false,
        semanticsLabel: c.label,
        onTap: () => onColor(c.hex),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            NeoBox(
              key: ValueKey(id),
              width: colorSwatch,
              height: colorSwatch,
              color: hexColor(c.hex),
              border: _line,
              radius: BorderRadius.circular(colorSwatch / 2),
            ),
            if (on)
              Positioned(
                key: ValueKey('$id.marked'),
                left: -out,
                top: -out,
                width: colorSwatch + 2 * out,
                height: colorSwatch + 2 * out,
                child: const IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.fromBorderSide(_line),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _clubOnly() => TapTarget(
    child: Pressable(
      toggled: clubOnly,
      semanticsLabel: 'Só do clube',
      onTap: () => onClubOnly(!clubOnly),
      child: NeoBox(
        key: const ValueKey('hl.filters.clubOnly'),
        height: 44,
        color: clubOnly ? AppColors.blush : AppColors.surface,
        border: _line,
        radius: BorderRadius.circular(999),
        shadow: clubOnly ? const Offset(2, 2) : null,
        padding: const EdgeInsets.fromLTRB(9, 0, 12, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 6,
          children: [
            NeoBox(
              key: const ValueKey('hl.filters.clubOnly.circle'),
              width: 26,
              height: 26,
              color: AppColors.blush,
              border: _line,
              radius: BorderRadius.circular(13),
              child: const Center(
                child: AppSvg(
                  AppIconsLeitor.people,
                  key: ValueKey('hl.filters.clubOnly.icon'),
                  size: 15,
                ),
              ),
            ),
            Flexible(
              child: AppText(
                'Só do clube',
                style: AppTextStyles.hlClubOnly,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  /// A largura natural da pílula das cores: borda + 12, "COR" + 2, cada caixa com o vão de 5, 7 + borda.
  static double naturalColorsWidth(int n) {
    final p = TextPainter(
      text: TextSpan(text: 'COR', style: AppTextStyles.hlColorLabel),
      textDirection: TextDirection.ltr,
    )..layout();
    final label = p.width;
    p.dispose();
    return AppStrokes.regular +
        12 +
        label +
        2 +
        n * (colorGap + colorSwatch) +
        7 +
        AppStrokes.regular;
  }

  /// A largura natural de "Só do clube" (o mínimo dela quando as cores rolam).
  static double naturalClubWidth() {
    final p = TextPainter(
      text: TextSpan(text: 'Só do clube', style: AppTextStyles.hlClubOnly),
      textDirection: TextDirection.ltr,
    )..layout();
    final label = p.width;
    p.dispose();
    return AppStrokes.regular + 9 + 26 + 6 + label + 12 + AppStrokes.regular;
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final natural = naturalColorsWidth(colors.length);
      final room = box.maxWidth - 8 - naturalClubWidth();
      final scrolls = natural > room;
      final row = Row(
        mainAxisSize: MainAxisSize.min,
        spacing: colorGap,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 2),
            child: AppText(
              'COR',
              key: const ValueKey('hl.filters.colors.label'),
              style: AppTextStyles.hlColorLabel,
              maxLines: 1,
            ),
          ),
          for (final c in colors) _swatch(c),
        ],
      );
      return SizedBox(
        key: const ValueKey('hl.filters'),
        height: 44,
        child: Row(
          spacing: 8,
          children: [
            Semantics(
              container: true,
              label: 'Filtrar por cor',
              explicitChildNodes: true,
              child: NeoBox(
                key: const ValueKey('hl.filters.colors'),
                width: scrolls ? room : null,
                height: 44,
                color: AppColors.surface,
                border: _line,
                radius: BorderRadius.circular(999),
                clip: scrolls,
                padding: scrolls
                    ? EdgeInsets.zero
                    : const EdgeInsets.fromLTRB(12, 0, 7, 0),
                child: scrolls
                    ? SingleChildScrollView(
                        key: const ValueKey('hl.filters.colors.scroll'),
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.fromLTRB(12, 0, 7, 0),
                        child: Center(child: row),
                      )
                    : row,
              ),
            ),
            Expanded(child: _clubOnly()),
          ],
        ),
      );
    },
  );
}

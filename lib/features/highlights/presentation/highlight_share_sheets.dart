// G21.5 — as duas folhas do "Compartilhar no clube" (docs/progresso/G21.md §5). Sem prancha (D-23, como as outras
// folhas da 25): no padrão da folha da nota — o véu, o cartão a 14 das bordas, raio 28, borda 1,5 e sombra dura; o
// título em caixa alta. Ficam em docs/design/estados_sem_design.md para o design.
// - "Antes de publicar" (D-222): as regras provisórias da comunidade (até a G25), "Aceitar e continuar" e "Agora não".
// - "Compartilhar em…": um botão por clube que lê o livro (a bolinha da cor e o nome) e Fechar.
import 'package:flutter/widgets.dart';

import '../../../core/design_system/text/app_text.dart';
import '../../../core/design_system/tokens/app_shadows.dart';
import '../../../core/design_system/tokens/app_strokes.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/neo_box.dart';
import '../../../core/design_system/widgets/pressable.dart';
import '../../reader/presentation/reader_chrome_palette.dart';
import '../application/highlights_share.dart';
import 'highlight_card.dart' show hexColor;
import 'highlight_more_sheet.dart';

/// As regras provisórias da comunidade (até os termos definitivos da G25).
const List<String> communityRulesDraft = [
  'Respeito: nada de ataque, ódio ou assédio.',
  'Spoiler com cuidado: o app esconde o que está à frente de quem lê.',
  'Nada de conteúdo sexual, spam ou propaganda.',
  'Denúncias são vistas em até 24 horas; o que quebra as regras sai do ar.',
];

class HighlightTermsSheet extends StatelessWidget {
  const HighlightTermsSheet({
    super.key,
    required this.palette,
    required this.brand,
    required this.onAccept,
    required this.onLater,
  });

  final ReaderChromePalette palette;
  final Color brand;
  final VoidCallback onAccept;
  final VoidCallback onLater;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    return HighlightsSheetFrame(
      id: 'hl.terms',
      label: 'Antes de publicar',
      palette: p,
      onDismiss: onLater,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText(
            'ANTES DE PUBLICAR',
            key: const ValueKey('hl.terms.title'),
            style: AppTextStyles.readerToolbarLabel.copyWith(color: p.label),
            maxLines: 1,
          ),
          const SizedBox(height: 10),
          AppText(
            'As regras da comunidade, por enquanto:',
            key: const ValueKey('hl.terms.lead'),
            style: AppTextStyles.hlSubtitleStrong.copyWith(color: p.title),
          ),
          const SizedBox(height: 6),
          for (final (i, r) in communityRulesDraft.indexed)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: AppText(
                '· $r',
                key: ValueKey('hl.terms.rule$i'),
                style: AppTextStyles.hlSubtitle.copyWith(color: p.muted),
              ),
            ),
          const SizedBox(height: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 10,
            children: [
              sheetButton(
                p,
                'hl.terms.accept',
                'Aceitar e continuar',
                onTap: onAccept,
                fill: brand,
                shadow: AppShadows.hard2,
              ),
              sheetButton(p, 'hl.terms.later', 'Agora não', onTap: onLater),
            ],
          ),
        ],
      ),
    );
  }
}

class HighlightShareToSheet extends StatelessWidget {
  const HighlightShareToSheet({
    super.key,
    required this.clubs,
    required this.palette,
    required this.onPick,
    required this.onClose,
  });

  final List<ShareClub> clubs;
  final ReaderChromePalette palette;
  final ValueChanged<ShareClub> onPick;
  final VoidCallback onClose;

  Widget _club(int i, ShareClub c) {
    final p = palette;
    return Pressable(
      semanticsLabel: c.name,
      onTap: () => onPick(c),
      child: NeoBox(
        key: ValueKey('hl.shareTo.club$i'),
        height: 48,
        color: p.island,
        border: BorderSide(width: AppStrokes.regular, color: p.border),
        radius: BorderRadius.circular(999),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          spacing: 10,
          children: [
            NeoBox(
              key: ValueKey('hl.shareTo.club$i.dot'),
              width: 14,
              height: 14,
              color: hexColor(c.color),
              border: BorderSide(width: AppStrokes.regular, color: p.border),
              radius: BorderRadius.circular(7),
            ),
            Expanded(
              child: AppText(
                c.name,
                style: AppTextStyles.readerNoteButton.copyWith(color: p.title),
                maxLines: 1,
                ellipsis: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = palette;
    return HighlightsSheetFrame(
      id: 'hl.shareTo',
      label: 'Compartilhar em…',
      palette: p,
      onDismiss: onClose,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          AppText(
            'COMPARTILHAR EM…',
            key: const ValueKey('hl.shareTo.title'),
            style: AppTextStyles.readerToolbarLabel.copyWith(color: p.label),
            maxLines: 1,
          ),
          const SizedBox(height: 2),
          for (final (i, c) in clubs.indexed) _club(i, c),
          sheetButton(p, 'hl.shareTo.close', 'Fechar', onTap: onClose),
        ],
      ),
    );
  }
}

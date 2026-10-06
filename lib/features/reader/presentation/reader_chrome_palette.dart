// G12.1 — cores das ilhas do leitor (telas 20 e 26b): medidas no arquivo (L20a/L20b/L26b), nada calculado por
// inversão. Nos papéis claros (Creme, Branco, Sépia) as ilhas são as da tela 20 e o véu é o próprio papel a 62 %;
// no Noite, as da 26b. `lerp` faz a troca do Tema em 220 ms (D-121) e `faded` o abrir/fechar em 150 ms sem
// `Opacity` (D-124).
import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/painting.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../domain/reader_settings.dart';
import 'reader_palette.dart';

@immutable
final class ReaderChromePalette {
  const ReaderChromePalette({
    required this.night,
    required this.veil,
    required this.island,
    required this.border,
    required this.shadow,
    required this.well,
    required this.title,
    required this.muted,
    required this.label,
    required this.hatch,
    required this.hatchBase,
    required this.bubble,
    required this.bubbleText,
    required this.dash,
    required this.disabled,
  });

  factory ReaderChromePalette.of(ReaderPaper p) {
    if (p == ReaderPaper.noite) {
      return ReaderChromePalette(
        night: true,
        veil: AppColors.veilNight.withValues(alpha: 0.55),
        island: AppColors.islandNight,
        border: AppColors.inkNight,
        shadow: AppColors.shadowNight,
        well: AppColors.paperNight,
        title: AppColors.inkNight,
        muted: AppColors.mutedNight,
        label: AppColors.mutedNight,
        hatch: AppColors.hatchNight,
        hatchBase: AppColors.islandNight,
        bubble: AppColors.inkNight,
        bubbleText: AppColors.paperNight,
        dash: AppColors.dashNight,
        disabled: AppColors.readerFooterNight,
      );
    }
    final paper = ReaderPalette.of(p);
    return ReaderChromePalette(
      night: false,
      veil: paper.paper.withValues(alpha: 0.62),
      island: AppColors.surface,
      border: AppColors.ink,
      shadow: AppColors.ink,
      well: AppColors.paper,
      title: AppColors.ink,
      muted: AppColors.inkMuted,
      label: AppColors.labelReader,
      hatch: AppColors.hatchReader,
      hatchBase: AppColors.surface,
      bubble: AppColors.ink,
      bubbleText: AppColors.paper,
      dash: AppColors.dashReader,
      disabled: paper.footer,
    );
  }

  /// Ícones do Noite (variantes `_noite`) e a lua no Tema.
  final bool night;

  /// Véu da página (`r20.fade`).
  final Color veil;

  /// Fundo, borda e sombra dura das ilhas (e do botão da barra de posição).
  final Color island, border, shadow;

  /// Fundo do círculo do fechar e das caixas das ferramentas.
  final Color well;

  /// Título, rótulos das ferramentas e o "62%"; [muted] = autor e linha de progresso.
  final Color title, muted;

  /// Rótulos pequenos da barra de ações e da folha da nota ("GRIFAR", "NOTA" — G13).
  final Color label;

  /// Hachura do trilho (listra e base), balão (fundo e texto) e o tracejado acima das ferramentas.
  final Color hatch, hatchBase, bubble, bubbleText, dash;

  /// Ferramenta desabilitada (Fonte no PDF — D-122): a cor do rodapé do papel (D-110).
  final Color disabled;

  /// Todas as cores com o alfa multiplicado por [a] (abrir/fechar sem `Opacity`).
  ReaderChromePalette faded(double a) {
    if (a >= 1) return this;
    Color f(Color c) => c.withValues(alpha: c.a * a);
    return ReaderChromePalette(
      night: night,
      veil: f(veil),
      island: f(island),
      border: f(border),
      shadow: f(shadow),
      well: f(well),
      title: f(title),
      muted: f(muted),
      label: f(label),
      hatch: f(hatch),
      hatchBase: f(hatchBase),
      bubble: f(bubble),
      bubbleText: f(bubbleText),
      dash: f(dash),
      disabled: f(disabled),
    );
  }

  static ReaderChromePalette lerp(
    ReaderChromePalette a,
    ReaderChromePalette b,
    double t,
  ) {
    if (t <= 0) return a;
    if (t >= 1) return b;
    Color l(Color x, Color y) => Color.lerp(x, y, t)!;
    return ReaderChromePalette(
      night: t < 0.5 ? a.night : b.night,
      veil: l(a.veil, b.veil),
      island: l(a.island, b.island),
      border: l(a.border, b.border),
      shadow: l(a.shadow, b.shadow),
      well: l(a.well, b.well),
      title: l(a.title, b.title),
      muted: l(a.muted, b.muted),
      label: l(a.label, b.label),
      hatch: l(a.hatch, b.hatch),
      hatchBase: l(a.hatchBase, b.hatchBase),
      bubble: l(a.bubble, b.bubble),
      bubbleText: l(a.bubbleText, b.bubbleText),
      dash: l(a.dash, b.dash),
      disabled: l(a.disabled, b.disabled),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ReaderChromePalette &&
      other.night == night &&
      other.veil == veil &&
      other.island == island &&
      other.border == border &&
      other.shadow == shadow &&
      other.well == well &&
      other.title == title &&
      other.muted == muted &&
      other.label == label &&
      other.hatch == hatch &&
      other.hatchBase == hatchBase &&
      other.bubble == bubble &&
      other.bubbleText == bubbleText &&
      other.dash == dash &&
      other.disabled == disabled;

  @override
  int get hashCode => Object.hash(
    night,
    veil,
    island,
    border,
    shadow,
    well,
    title,
    muted,
    label,
    hatch,
    hatchBase,
    bubble,
    bubbleText,
    dash,
    disabled,
  );
}

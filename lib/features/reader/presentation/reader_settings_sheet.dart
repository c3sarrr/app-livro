// G14.3 — tela 26, a folha de ajustes de leitura (L26): a página do leitor fica viva em cima (a "prévia" é ela,
// não um `Text` à parte) e a folha embaixo. Ela tem tamanho (7 passos), fonte, papel, entrelinha e margens; cada
// toque pede a mudança à sessão, que grava e repagina (D-144). Abre e fecha em 150 ms subindo e descendo. Fecha pelo
// ×, tocando na página de cima ou puxando pela alça (D-141). No Noite, as cores das ilhas (D-143). Abaixo de 15,2
// do topo da folha, o papel cobre a página (L26: a prévia tem 210 e a folha começa em 286,8). Numa tela baixa, a folha
// para logo abaixo da pílula e o que vem depois do título rola por dentro (D-145).
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../../core/design_system/painters/dashed_stadium_painter.dart';
import '../../../core/design_system/text/app_text.dart';
import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_icons_leitor.dart';
import '../../../core/design_system/tokens/app_shadows.dart';
import '../../../core/design_system/tokens/app_strokes.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/app_svg.dart';
import '../../../core/design_system/widgets/circle_icon_button.dart';
import '../../../core/design_system/widgets/neo_box.dart';
import '../../../core/design_system/widgets/pressable.dart';
import '../../../core/design_system/widgets/tap_target.dart';
import '../domain/reader_settings.dart';
import 'reader_chrome_palette.dart';
import 'reader_controls.dart' show readerControlsLayout;
import 'reader_overlays.dart' show readerFade;

/// A folha fica a 10 das bordas.
const double readerSheetSide = 10;

/// A página aparece até 15,2 abaixo do topo da folha (L26).
const double readerSheetPagePeek = 15.2;

/// A pílula "prévia ao vivo" tem 26 de altura; numa tela baixa, a folha para 8 abaixo dela (D-145).
const double readerLivePillHeight = 26;
const double readerSheetPillGap = 8;

/// Puxar pela alça fecha a partir de 64 para baixo, ou com o dedo a 700/s; empurrar de volta para cima a 700/s
/// devolve a folha ao lugar, mesmo depois dos 64.
const double readerSheetDismissDrag = 64;
const double readerSheetDismissVelocity = 700;

/// A base da folha: 10 no canvas e num iPhone 390×844 (área de baixo 34).
double readerSheetBottom(EdgeInsets viewPadding) =>
    math.max(10.0, viewPadding.bottom - 24);

/// Onde fica a caixa do texto da página (o nó "Prévia da página" do leitor de tela).
typedef ReaderSheetPage = ({double left, double top, double width});

/// O passo do ponto mais perto de [dx] no trilho de largura [width]: pontos de 7 e o ativo de 14, distribuídos como
/// o `space-evenly` do arquivo dentro da borda de 1,5.
int readerStepAt(double dx, double width, int active) {
  const n = 7;
  final inner = width - 2 * AppStrokes.regular;
  final gap = (inner - (n - 1) * 7 - 14) / (n + 1);
  var x = AppStrokes.regular + gap;
  var best = 1;
  var bestD = double.infinity;
  for (var i = 1; i <= n; i++) {
    final w = i == active ? 14.0 : 7.0;
    final d = (dx - (x + w / 2)).abs();
    if (d < bestD) {
      bestD = d;
      best = i;
    }
    x += w + gap;
  }
  return best;
}

/// Um passo a mais e um a menos no tamanho, sobre os ajustes da sessão (toques seguidos somam).
ReaderLook _larger(ReaderLook l) =>
    l.copyWith(fontStep: math.min(7, l.fontStep + 1));
ReaderLook _smaller(ReaderLook l) =>
    l.copyWith(fontStep: math.max(1, l.fontStep - 1));

/// As cores do cartão de cada papel (L26, PAPEL): fundo, "Aa" e as duas linhas — as mesmas em todo tema (D-143).
({Color card, Color ink, Color line}) readerPaperCard(ReaderPaper p) =>
    switch (p) {
      ReaderPaper.creme => (
        card: AppColors.paperCream,
        ink: AppColors.bookText,
        line: AppColors.paperLineCream,
      ),
      ReaderPaper.branco => (
        card: AppColors.paperWhite,
        ink: AppColors.ink,
        line: AppColors.paperLineWhite,
      ),
      ReaderPaper.sepia => (
        card: AppColors.paperSepia,
        ink: AppColors.bookTextSepia,
        line: AppColors.paperLineSepia,
      ),
      ReaderPaper.noite => (
        card: AppColors.paperNight,
        ink: AppColors.inkNight,
        line: AppColors.dashNight,
      ),
    };

/// As fontes da folha: (fonte, id da prancha, nome, legenda, estilo do "Aa").
final List<(ReaderFontFamily, String, String, String, TextStyle)> _fonts = [
  (
    ReaderFontFamily.literata,
    'literata',
    'Literata',
    'tela',
    AppTextStyles.readerSheetSampleLiterata,
  ),
  (
    ReaderFontFamily.lora,
    'lora',
    'Lora',
    'clássica',
    AppTextStyles.readerSheetSampleLora,
  ),
  (
    ReaderFontFamily.figtree,
    'figtree',
    'Figtree',
    'sem serifa',
    AppTextStyles.readerSheetSampleFigtree,
  ),
  (
    ReaderFontFamily.atkinson,
    'atkinson',
    'Atkinson',
    'baixa visão', // D-147 (a prancha diz "dislexia"; a fonte é do Braille Institute, para baixa visão)
    AppTextStyles.readerSheetSampleAtkinson,
  ),
];

const List<(ReaderPaper, String, String)> _papers = [
  (ReaderPaper.creme, 'cream', 'Creme'),
  (ReaderPaper.branco, 'white', 'Branco'),
  (ReaderPaper.sepia, 'sepia', 'Sépia'),
  (ReaderPaper.noite, 'night', 'Noite'),
];

const List<(ReaderLineSpacing, String, String, String)> _spacings = [
  (ReaderLineSpacing.justo, 'tight', 'Justo', AppIconsLeitor.spacingTight),
  (ReaderLineSpacing.medio, 'medium', 'Médio', AppIconsLeitor.spacingMedium),
  (ReaderLineSpacing.solto, 'loose', 'Solto', AppIconsLeitor.spacingLoose),
];

const List<(ReaderMargins, String, String, String)> _margins = [
  (ReaderMargins.estreita, 'narrow', 'Estreita', AppIconsLeitor.marginsNarrow),
  (ReaderMargins.media, 'medium', 'Média', AppIconsLeitor.marginsMedium),
  (ReaderMargins.larga, 'wide', 'Larga', AppIconsLeitor.marginsWide),
];

class ReaderSettingsSheet extends StatefulWidget {
  const ReaderSettingsSheet({
    super.key,
    required this.open,
    required this.look,
    required this.palette,
    required this.paper,
    required this.brand,
    required this.page,
    required this.pageText,
    required this.onChange,
    required this.onClose,
  });

  final bool open;

  /// Os ajustes mostrados (os da sessão).
  final ReaderLook look;

  /// As cores das ilhas (inteiras; a pílula esmaece sozinha).
  final ReaderChromePalette palette;

  /// O papel da página: cobre a página abaixo do corte.
  final Color paper;
  final Color brand;
  final ReaderSheetPage page;

  /// O texto da página (o valor da "Prévia da página").
  final String pageText;

  /// Uma mudança pedida (aplicada pela sessão sobre os ajustes dela — toques rápidos somam).
  final ValueChanged<ReaderLookChange> onChange;
  final VoidCallback onClose;

  @override
  State<ReaderSettingsSheet> createState() => _ReaderSettingsSheetState();
}

class _ReaderSettingsSheetState extends State<ReaderSettingsSheet> {
  /// Quanto o dedo puxou a folha para baixo pela alça.
  double _drag = 0;

  @override
  void didUpdateWidget(ReaderSettingsSheet old) {
    super.didUpdateWidget(old);
    if (widget.open && !old.open) _drag = 0;
  }

  void _dragged(DragUpdateDetails d) =>
      setState(() => _drag = math.max(0, _drag + d.delta.dy));

  void _released(DragEndDetails d) {
    final v = d.velocity.pixelsPerSecond.dy;
    if (v >= readerSheetDismissVelocity ||
        (_drag >= readerSheetDismissDrag && v > -readerSheetDismissVelocity)) {
      widget.onClose();
    } else {
      setState(() => _drag = 0);
    }
  }

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween<double>(end: widget.open ? 1 : 0),
    duration: readerFade,
    builder: (context, a, _) {
      if (a == 0) return const SizedBox.shrink();
      final pad = MediaQuery.viewPaddingOf(context);
      return IgnorePointer(
        // fechando: os toques já vão para os controles que voltam
        ignoring: !widget.open,
        child: ExcludeSemantics(
          excluding: !widget.open,
          child: BlockSemantics(
            blocking: widget.open,
            child: Stack(
              children: [
                // a página de cima: o toque fecha (D-141); a página não vira nem seleciona por baixo
                Positioned.fill(
                  child: GestureDetector(
                    key: const ValueKey('rs.backdrop'),
                    behavior: HitTestBehavior.opaque,
                    excludeFromSemantics: true,
                    onTap: widget.onClose,
                  ),
                ),
                Positioned.fill(
                  child: CustomMultiChildLayout(
                    delegate: _SheetLayout(
                      shown: a,
                      drag: _drag,
                      bottom: readerSheetBottom(pad),
                      pillTop: readerControlsLayout(pad).top,
                      page: widget.page,
                    ),
                    children: [
                      LayoutId(
                        id: _Part.paper,
                        child: IgnorePointer(
                          child: ColoredBox(
                            key: const ValueKey('rs.paper'),
                            color: widget.paper,
                          ),
                        ),
                      ),
                      LayoutId(
                        id: _Part.preview,
                        child: Semantics(
                          key: const ValueKey('rs.page'),
                          container: true,
                          label: 'Prévia da página',
                          value: widget.pageText,
                          child: const SizedBox.expand(),
                        ),
                      ),
                      LayoutId(
                        id: _Part.pill,
                        // só aviso: o toque nela é da página de cima (fecha)
                        child: IgnorePointer(
                          child: ExcludeSemantics(
                            child: _LivePill(
                              palette: widget.palette.faded(a),
                              a: a,
                            ),
                          ),
                        ),
                      ),
                      LayoutId(
                        id: _Part.sheet,
                        child: Semantics(
                          container: true,
                          scopesRoute: true,
                          namesRoute: true,
                          explicitChildNodes: true,
                          label: 'Ajustes de leitura',
                          child: _Sheet(
                            look: widget.look,
                            palette: widget.palette,
                            brand: widget.brand,
                            onChange: widget.onChange,
                            onClose: widget.onClose,
                            onDrag: _dragged,
                            onRelease: _released,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

enum _Part { paper, preview, pill, sheet }

/// A folha embaixo (subindo com [shown] e descendo com o [drag]); o papel do corte para baixo; a prévia da caixa do
/// texto até o corte; a pílula centralizada no lugar da ilha de cima (D-124).
final class _SheetLayout extends MultiChildLayoutDelegate {
  _SheetLayout({
    required this.shown,
    required this.drag,
    required this.bottom,
    required this.pillTop,
    required this.page,
  });

  final double shown, drag, bottom, pillTop;
  final ReaderSheetPage page;

  @override
  void performLayout(Size size) {
    // a folha cabe entre a base e logo abaixo da pílula (D-145): numa tela baixa, ela rola por dentro
    final room =
        size.height -
        bottom -
        (pillTop + readerLivePillHeight + readerSheetPillGap);
    final s = layoutChild(
      _Part.sheet,
      BoxConstraints(
        minWidth: size.width - 2 * readerSheetSide,
        maxWidth: size.width - 2 * readerSheetSide,
        maxHeight: math.max(0, room),
      ),
    );
    final rest = size.height - bottom - s.height;
    // fechada: toda abaixo da tela, com a sombra
    final away = size.height + AppShadows.drop4.dy;
    final top = rest + (away - rest) * (1 - shown) + drag;
    positionChild(_Part.sheet, Offset(readerSheetSide, top));
    final cut = top + readerSheetPagePeek;
    layoutChild(
      _Part.paper,
      BoxConstraints.tightFor(
        width: size.width,
        height: math.max(0, size.height - cut),
      ),
    );
    positionChild(_Part.paper, Offset(0, cut));
    layoutChild(
      _Part.preview,
      BoxConstraints.tightFor(
        width: page.width,
        height: math.max(0, cut - page.top),
      ),
    );
    positionChild(_Part.preview, Offset(page.left, page.top));
    final pill = layoutChild(_Part.pill, BoxConstraints.loose(size));
    positionChild(_Part.pill, Offset((size.width - pill.width) / 2, pillTop));
  }

  @override
  bool shouldRelayout(_SheetLayout old) =>
      old.shown != shown ||
      old.drag != drag ||
      old.bottom != bottom ||
      old.pillTop != pillTop ||
      old.page != page;
}

/// "● prévia ao vivo" (`rs.livePill`): fora do leitor de tela.
class _LivePill extends StatelessWidget {
  const _LivePill({required this.palette, required this.a});

  /// Já esmaecida.
  final ReaderChromePalette palette;
  final double a;

  @override
  Widget build(BuildContext context) => NeoBox(
    key: const ValueKey('rs.livePill'),
    height: readerLivePillHeight,
    color: palette.island,
    border: BorderSide(width: AppStrokes.regular, color: palette.border),
    radius: BorderRadius.circular(13),
    padding: const EdgeInsets.symmetric(horizontal: 11),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        SizedBox(
          key: const ValueKey('rs.livePill.dot'),
          width: 7,
          height: 7,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.flame.withValues(alpha: a),
              shape: BoxShape.circle,
            ),
          ),
        ),
        AppText(
          'prévia ao vivo',
          style: AppTextStyles.readerSheetPill.copyWith(color: palette.title),
          maxLines: 1,
        ),
      ],
    ),
  );
}

/// A folha (`rs.sheet`): alça e título (por onde se puxa para fechar), tamanho, fonte, papel, entrelinha e margens.
class _Sheet extends StatelessWidget {
  const _Sheet({
    required this.look,
    required this.palette,
    required this.brand,
    required this.onChange,
    required this.onClose,
    required this.onDrag,
    required this.onRelease,
  });

  final ReaderLook look;
  final ReaderChromePalette palette;
  final Color brand;
  final ValueChanged<ReaderLookChange> onChange;
  final VoidCallback onClose;
  final GestureDragUpdateCallback onDrag;
  final GestureDragEndCallback onRelease;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final line = BorderSide(width: AppStrokes.regular, color: p.border);
    return NeoBox(
      key: const ValueKey('rs.sheet'),
      color: p.island,
      border: line,
      radius: const BorderRadius.only(
        topLeft: Radius.circular(32),
        topRight: Radius.circular(32),
        bottomLeft: Radius.circular(44),
        bottomRight: Radius.circular(44),
      ),
      shadow: AppShadows.drop4,
      shadowColor: p.shadow,
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // a alça e o título: puxar para baixo fecha (D-141); ficam parados quando o resto rola (D-145)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              excludeFromSemantics: true,
              onVerticalDragUpdate: onDrag,
              onVerticalDragEnd: onRelease,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: SizedBox(
                      key: const ValueKey('rs.sheet.grabber'),
                      width: 40,
                      height: 5,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: p.dash,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    key: const ValueKey('rs.sheet.header'),
                    height: 44,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Semantics(
                          container: true,
                          header: true,
                          child: AppText.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Ajustes ',
                                  style: AppTextStyles.readerSheetTitle
                                      .copyWith(color: p.title),
                                ),
                                TextSpan(
                                  text: 'de leitura',
                                  style: AppTextStyles.readerSheetTitleSerif
                                      .copyWith(color: p.title),
                                ),
                              ],
                            ),
                            key: const ValueKey('rs.sheet.title'),
                            maxLines: 1,
                          ),
                        ),
                        TapTarget(
                          child: CircleIconButton(
                            key: const ValueKey('rs.sheet.close'),
                            size: 44,
                            color: p.well,
                            border: line,
                            icon: AppSvg(
                              AppIconsLeitor.closeRound,
                              key: const ValueKey('rs.sheet.close.icon'),
                              size: 18,
                              color: p.night ? p.title : null,
                            ),
                            semanticsLabel: 'Fechar',
                            onTap: onClose,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // o resto rola quando a tela é baixa (D-145); as margens de 18 e 20 ficam dentro, com as sombras dos cartões
          Flexible(
            child: SingleChildScrollView(
              key: const ValueKey('rs.sheet.scroll'),
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SizeRow(
                    step: look.fontStep,
                    palette: p,
                    brand: brand,
                    onChange: onChange,
                  ),
                  const SizedBox(height: 16),
                  _Label('FONTE', id: 'rs.sheet.fontLabel', palette: p),
                  const SizedBox(height: 7),
                  _Fonts(
                    look: look,
                    palette: p,
                    brand: brand,
                    onChange: onChange,
                  ),
                  const SizedBox(height: 16),
                  _Label('PAPEL', id: 'rs.sheet.paperLabel', palette: p),
                  const SizedBox(height: 9),
                  _Papers(
                    look: look,
                    palette: p,
                    brand: brand,
                    onChange: onChange,
                  ),
                  const SizedBox(height: 14),
                  _Label('ENTRELINHA', id: 'rs.sheet.spacingLabel', palette: p),
                  const SizedBox(height: 7),
                  _Segmented<ReaderLineSpacing>(
                    id: 'rs.sheet.spacing',
                    label: 'Entrelinha',
                    value: look.lineSpacing,
                    options: _spacings,
                    palette: p,
                    brand: brand,
                    onPick: (v) => onChange((l) => l.copyWith(lineSpacing: v)),
                  ),
                  const SizedBox(height: 12),
                  _Label('MARGENS', id: 'rs.sheet.marginsLabel', palette: p),
                  const SizedBox(height: 7),
                  _Segmented<ReaderMargins>(
                    id: 'rs.sheet.margins',
                    label: 'Margens',
                    value: look.margins,
                    options: _margins,
                    palette: p,
                    brand: brand,
                    onPick: (v) => onChange((l) => l.copyWith(margins: v)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "A" pequeno, os 7 pontos e "A" grande (`rs.sheet.size`).
class _SizeRow extends StatelessWidget {
  const _SizeRow({
    required this.step,
    required this.palette,
    required this.brand,
    required this.onChange,
  });

  final int step;
  final ReaderChromePalette palette;
  final Color brand;
  final ValueChanged<ReaderLookChange> onChange;

  @override
  Widget build(BuildContext context) => SizedBox(
    key: const ValueKey('rs.sheet.size'),
    height: 48,
    child: Row(
      spacing: 10,
      children: [
        _StepButton(
          id: 'rs.sheet.size.smaller',
          label: 'Diminuir a letra',
          style: AppTextStyles.readerSheetSmallA,
          palette: palette,
          enabled: step > 1,
          onTap: () => onChange(_smaller),
        ),
        Expanded(
          child: _Steps(
            step: step,
            palette: palette,
            brand: brand,
            onChange: onChange,
          ),
        ),
        _StepButton(
          id: 'rs.sheet.size.larger',
          label: 'Aumentar a letra',
          style: AppTextStyles.readerSheetLargeA,
          palette: palette,
          enabled: step < 7,
          onTap: () => onChange(_larger),
        ),
      ],
    ),
  );
}

/// Um "A" de 48: nas pontas fica indisponível (cinza e "indisponível" ao leitor de tela, como a Fonte no PDF).
class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.id,
    required this.label,
    required this.style,
    required this.palette,
    required this.enabled,
    required this.onTap,
  });

  final String id, label;
  final TextStyle style;
  final ReaderChromePalette palette;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ink = enabled ? palette.title : palette.disabled;
    return Pressable(
      key: ValueKey(id),
      semanticsLabel: label,
      enabled: enabled,
      onTap: onTap,
      child: NeoBox(
        width: 48,
        height: 48,
        color: palette.well,
        border: BorderSide(width: AppStrokes.regular, color: ink),
        radius: BorderRadius.circular(24),
        child: Center(
          child: AppText('A', style: style.copyWith(color: ink), maxLines: 1),
        ),
      ),
    );
  }
}

/// O trilho tracejado com os 7 pontos (`rs.sheet.size.steps`): tocar num ponto ou arrastar escolhe o passo mais
/// perto; para o leitor de tela é um controle deslizante (D-144). Os toques seguem o dedo mesmo antes de a sessão
/// avisar o passo novo (vale o último); aumentar e diminuir andam um passo sobre os ajustes da sessão.
class _Steps extends StatefulWidget {
  const _Steps({
    required this.step,
    required this.palette,
    required this.brand,
    required this.onChange,
  });

  /// O passo mostrado (o da sessão quando ela avisou).
  final int step;
  final ReaderChromePalette palette;
  final Color brand;
  final ValueChanged<ReaderLookChange> onChange;

  @override
  State<_Steps> createState() => _StepsState();
}

class _StepsState extends State<_Steps> {
  /// O último passo pedido por este toque ou arrasto (o arrasto não pede o mesmo de novo a cada movimento).
  int? _picked;

  void _pick(double dx, double width) {
    final n = readerStepAt(dx, width, widget.step);
    if (n == _picked) return;
    _picked = n;
    widget.onChange((l) => l.copyWith(fontStep: n));
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.step;
    final p = widget.palette;
    return Semantics(
      container: true,
      slider: true,
      label: 'Tamanho da letra',
      value: '$step de 7',
      increasedValue: step < 7 ? '${step + 1} de 7' : null,
      decreasedValue: step > 1 ? '${step - 1} de 7' : null,
      onIncrease: step < 7 ? () => widget.onChange(_larger) : null,
      onDecrease: step > 1 ? () => widget.onChange(_smaller) : null,
      child: LayoutBuilder(
        builder: (context, c) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          excludeFromSemantics: true,
          onTapUp: (d) {
            _picked = null;
            _pick(d.localPosition.dx, c.maxWidth);
          },
          onHorizontalDragStart: (d) {
            _picked = null;
            _pick(d.localPosition.dx, c.maxWidth);
          },
          onHorizontalDragUpdate: (d) => _pick(d.localPosition.dx, c.maxWidth),
          child: CustomPaint(
            key: const ValueKey('rs.sheet.size.steps'),
            painter: DashedStadiumPainter(color: p.dash),
            child: SizedBox(
              height: 48,
              child: Padding(
                padding: const EdgeInsets.all(AppStrokes.regular),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (var i = 1; i <= 7; i++)
                      if (i == step)
                        NeoBox(
                          key: ValueKey('rs.sheet.size.step$i'),
                          width: 14,
                          height: 14,
                          color: widget.brand,
                          border: BorderSide(
                            width: AppStrokes.regular,
                            color: p.border,
                          ),
                          radius: BorderRadius.circular(7),
                        )
                      else
                        SizedBox(
                          key: ValueKey('rs.sheet.size.step$i'),
                          width: 7,
                          height: 7,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: i < step ? p.title : p.dash,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// "FONTE", "PAPEL", "ENTRELINHA", "MARGENS": fora do leitor de tela (o grupo logo abaixo já tem o nome).
class _Label extends StatelessWidget {
  const _Label(this.text, {required this.id, required this.palette});

  final String text, id;
  final ReaderChromePalette palette;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: AppText(
      text,
      key: ValueKey(id),
      style: AppTextStyles.readerSheetLabel.copyWith(color: palette.label),
      maxLines: 1,
    ),
  );
}

/// FONTE (`rs.sheet.fonts`): 4 cartões de 82, o "Aa" na própria fonte; o escolhido na `brand` com sombra 2/2.
class _Fonts extends StatelessWidget {
  const _Fonts({
    required this.look,
    required this.palette,
    required this.brand,
    required this.onChange,
  });

  final ReaderLook look;
  final ReaderChromePalette palette;
  final Color brand;
  final ValueChanged<ReaderLookChange> onChange;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final line = BorderSide(width: AppStrokes.regular, color: p.border);
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: 'Fonte',
      child: Row(
        key: const ValueKey('rs.sheet.fonts'),
        spacing: 8,
        children: [
          for (final (f, id, name, caption, sample) in _fonts)
            Expanded(
              child: Builder(
                builder: (context) {
                  final on = look.fontFamily == f;
                  final ink = on ? AppColors.ink : p.title;
                  final k = 'rs.sheet.fonts.$id';
                  return Pressable(
                    key: ValueKey(k),
                    semanticsLabel: '$name, $caption',
                    checked: on,
                    onTap: () => onChange((l) => l.copyWith(fontFamily: f)),
                    child: NeoBox(
                      height: 82,
                      color: on ? brand : p.well,
                      border: line,
                      radius: BorderRadius.circular(16),
                      shadow: on ? AppShadows.hard2 : null,
                      shadowColor: p.shadow,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AppText(
                            'Aa',
                            key: ValueKey('$k.sample'),
                            style: sample.copyWith(color: ink),
                            maxLines: 1,
                          ),
                          const SizedBox(height: 2),
                          AppText(
                            name,
                            key: ValueKey('$k.name'),
                            style: AppTextStyles.readerSheetFontName.copyWith(
                              color: ink,
                            ),
                            maxLines: 1,
                          ),
                          // gap 2 com `margin-top: -1`
                          const SizedBox(height: 1),
                          AppText(
                            caption,
                            key: ValueKey('$k.caption'),
                            style: AppTextStyles.readerSheetCaption.copyWith(
                              color: on ? AppColors.captionOnBrand : p.caption,
                            ),
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

/// PAPEL (`rs.sheet.papers`): o cartão de 62 nas cores do papel, com "Aa" e 2 linhas; o escolhido com sombra 2/2 e
/// o ✓ de 22 na `brand`; o nome embaixo (o escolhido em 800).
class _Papers extends StatelessWidget {
  const _Papers({
    required this.look,
    required this.palette,
    required this.brand,
    required this.onChange,
  });

  final ReaderLook look;
  final ReaderChromePalette palette;
  final Color brand;
  final ValueChanged<ReaderLookChange> onChange;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final line = BorderSide(width: AppStrokes.regular, color: p.border);
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: 'Tema do papel',
      child: Row(
        key: const ValueKey('rs.sheet.papers'),
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (paper, id, name) in _papers)
            Expanded(
              child: Builder(
                builder: (context) {
                  final on = look.paper == paper;
                  final c = readerPaperCard(paper);
                  final k = 'rs.sheet.papers.$id';
                  Widget bar(String key, {double width = 1}) =>
                      FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: width,
                        child: SizedBox(
                          key: ValueKey(key),
                          height: 3,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: c.line,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      );
                  return Pressable(
                    key: ValueKey(k),
                    semanticsLabel: 'Tema $name',
                    checked: on,
                    onTap: () => onChange((l) => l.copyWith(paper: paper)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: NeoBox(
                            key: ValueKey('$k.card'),
                            height: 62,
                            color: c.card,
                            border: line,
                            radius: BorderRadius.circular(14),
                            shadow: on ? AppShadows.hard2 : null,
                            shadowColor: p.shadow,
                            child: Stack(
                              fit: StackFit.expand,
                              clipBehavior: Clip.none,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      AppText(
                                        'Aa',
                                        key: ValueKey('$k.sample'),
                                        style: AppTextStyles
                                            .readerSheetPaperSample
                                            .copyWith(color: c.ink),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                      ),
                                      const SizedBox(height: 7),
                                      bar('$k.line1'),
                                      const SizedBox(height: 4),
                                      bar('$k.line2', width: 0.7),
                                    ],
                                  ),
                                ),
                                if (on)
                                  Positioned(
                                    right: -7,
                                    top: -7,
                                    child: NeoBox(
                                      key: ValueKey('$k.check'),
                                      width: 22,
                                      height: 22,
                                      color: brand,
                                      border: line,
                                      radius: BorderRadius.circular(11),
                                      child: Center(
                                        child: AppSvg(
                                          AppIconsLeitor.checkSmall,
                                          key: ValueKey('$k.check.icon'),
                                          size: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        AppText(
                          name,
                          key: ValueKey('$k.name'),
                          style:
                              (on
                                      ? AppTextStyles.readerSheetPaperNameOn
                                      : AppTextStyles.readerSheetPaperName)
                                  .copyWith(color: p.title),
                          maxLines: 1,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

/// ENTRELINHA e MARGENS: um segmentado de 46 com 3 opções; a escolhida na `brand`, com borda e texto em 800.
class _Segmented<T> extends StatelessWidget {
  const _Segmented({
    required this.id,
    required this.label,
    required this.value,
    required this.options,
    required this.palette,
    required this.brand,
    required this.onPick,
  });

  final String id, label;
  final T value;
  final List<(T, String, String, String)> options;
  final ReaderChromePalette palette;
  final Color brand;
  final ValueChanged<T> onPick;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: label,
      child: NeoBox(
        key: ValueKey(id),
        height: 46,
        color: p.well,
        border: BorderSide(width: AppStrokes.regular, color: p.border),
        radius: BorderRadius.circular(23),
        padding: const EdgeInsets.all(3),
        child: Row(
          spacing: 3,
          children: [
            for (final (v, sid, text, icon) in options)
              Expanded(
                child: Builder(
                  builder: (context) {
                    final on = v == value;
                    return TapTarget(
                      child: Pressable(
                        key: ValueKey('$id.$sid'),
                        checked: on,
                        onTap: () => onPick(v),
                        child: NeoBox(
                          height: 37,
                          color: on ? brand : null,
                          border: BorderSide(
                            width: AppStrokes.regular,
                            color: on ? p.border : const Color(0x00000000),
                          ),
                          radius: BorderRadius.circular(999),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 7,
                            children: [
                              AppSvg(
                                icon,
                                key: ValueKey('$id.$sid.icon'),
                                size: 18,
                                // no Noite, tingido com o título; sobre a brand fica a tinta do arquivo
                                color: !on && p.night ? p.title : null,
                              ),
                              AppText(
                                text,
                                style:
                                    (on
                                            ? AppTextStyles.readerSheetOptionOn
                                            : AppTextStyles.readerSheetOption)
                                        .copyWith(
                                          color: on ? AppColors.ink : p.title,
                                        ),
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// G15.3 — a aba Capítulos da folha do sumário (tela 27, L27): a faixa do clube (D-149: só com clube), a lista
// "Capítulos" que some nos 22 de cima e nos 40 de baixo (a máscara da prancha, pintada com a cor da folha — sem camada),
// as linhas (numeral do livro — D-150 —, título, marcas — Anexo 02 §4.2 —, página e "lido"), o capítulo atual num
// cartão com o anel e "você está na pág. N", as partes como título pequeno (D-153) e a lista sem sumário (D-21). A lista
// abre com o cartão atual a 378,4 do topo dela (L27: sete linhas acima); numa lista baixa, o cartão fica inteiro acima
// do esmaecido de baixo (D-154); uma vez por abertura: trocar de aba e voltar deixa a lista onde estava. Sem numeral
// em nenhuma linha, a coluna do numeral some. Numeral ou página mais largos que a coluna transbordam no espaço ao lado,
// inteiros, como no HTML da prancha (D-157). O índice que não se leu deixa só a moldura. A lista monta sob demanda
// (G20, R12): só as linhas à vista e as vizinhas; a abertura vai à altura estimada e, com o cartão montado, ao lugar
// exato.
import 'dart:math' as math;

import 'package:flutter/rendering.dart'
    show OverflowBoxFit, RenderAbstractViewport, ScrollCacheExtent;
import 'package:flutter/widgets.dart';

import '../../../core/design_system/painters/chromium_dash.dart';
import '../../../core/design_system/text/app_text.dart';
import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_icons_leitor.dart';
import '../../../core/design_system/tokens/app_shadows.dart';
import '../../../core/design_system/tokens/app_strokes.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/app_svg.dart';
import '../../../core/design_system/widgets/neo_box.dart';
import '../../../core/design_system/widgets/pressable.dart';
import '../annotations/domain/annotation.dart' show AnnotationKind;
import '../annotations/domain/annotation_stats.dart';
import '../application/reader_annotations.dart' show hexColor;
import '../application/toc_view.dart';
import 'reader_chrome_palette.dart';

/// O cartão do capítulo atual abre a 378,4 do topo da lista (L27: sete linhas acima dele).
const double tocCurrentTop = 378.4;

/// A lista some nos 22 de cima e nos 40 de baixo (`mask-image` da prancha).
const double tocFadeTop = 22;
const double tocFadeBottom = 40;

/// A lista começa 6 acima da caixa dela (`margin-top: -6px`), recortada.
const double tocListLift = 6;

/// Quanto da lista fica montado além do que se vê, em cima e embaixo (R12, G20).
const double tocListCache = 600;

/// A borda fina dos símbolos, da pílula e do "lido" (1,3).
const double _thin = 1.3;

class TocChapters extends StatefulWidget {
  const TocChapters({
    super.key,
    required this.view,
    required this.palette,
    required this.onChapter,
    this.onClub,
    this.offset,
    this.onOffset,
  });

  final TocView view;
  final ReaderChromePalette palette;
  final ValueChanged<TocRow> onChapter;
  final VoidCallback? onClub;

  /// Onde a lista estava nesta abertura (voltando da aba Marcadas); `null` = abre no capítulo atual.
  final double? offset;

  /// A lista rolou: a folha guarda onde, para a volta da outra aba.
  final ValueChanged<double>? onOffset;

  @override
  State<TocChapters> createState() => _TocChaptersState();
}

class _TocChaptersState extends State<TocChapters> {
  late final ScrollController _scroll = ScrollController(
    initialScrollOffset: widget.offset ?? 0,
  );
  final GlobalKey _current = GlobalKey();
  late bool _placed = widget.offset != null;

  /// Passos da altura inicial: com a lista sob demanda (R12, G20) o cartão atual pode não estar montado — a rolagem
  /// vai à altura estimada (a média das linhas montadas) e, com o cartão montado, ao lugar exato.
  int _steps = 0;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_scrolled);
    if (!_placed) _later();
  }

  void _scrolled() => widget.onOffset?.call(_scroll.offset);

  @override
  void didUpdateWidget(TocChapters old) {
    super.didUpdateWidget(old);
    if (!_placed) _later();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _later() =>
      WidgetsBinding.instance.addPostFrameCallback((_) => _place());

  /// A altura inicial (uma vez por abertura): o cartão atual a 378,4 do topo da lista, ou mais acima até ele ficar
  /// inteiro acima do esmaecido de baixo; dentro dos limites da rolagem.
  void _place() {
    if (!mounted || _placed || !_scroll.hasClients) return;
    final pos = _scroll.position;
    final rows = widget.view.rows;
    final at = rows.indexWhere((r) => r.current);
    final card = _current.currentContext?.findRenderObject();
    if (at < 0 || _steps >= 4) {
      _placed = true;
      return;
    }
    _steps++;
    if (card is! RenderBox || !card.attached) {
      // longe do que está montado: a altura estimada pela média das linhas, e o lugar exato no quadro seguinte
      final mean = (pos.maxScrollExtent + pos.viewportDimension) / rows.length;
      final to = (mean * at - tocCurrentTop).clamp(
        pos.minScrollExtent,
        pos.maxScrollExtent,
      );
      _scroll.jumpTo(to);
      _later();
      return;
    }
    final top = RenderAbstractViewport.of(card)
        .getOffsetToReveal(card, 0)
        .offset;
    final want = math.max(
      top - tocCurrentTop,
      top + card.size.height + tocFadeBottom - pos.viewportDimension,
    );
    final to = want.clamp(pos.minScrollExtent, pos.maxScrollExtent);
    if ((to - pos.pixels).abs() < 0.01) {
      _placed = true;
      return;
    }
    // a lista sob demanda pode corrigir as linhas de cima ao rolar: confere de novo no quadro seguinte
    _scroll.jumpTo(to);
    _later();
  }

  Widget _row(TocView v, bool numerals, int i) {
    final r = v.rows[i];
    final p = widget.palette;
    if (r.kind == TocRowKind.part) {
      return _PartRow(row: r, palette: p, onTap: widget.onChapter);
    }
    if (r.current) {
      return _CurrentCard(
        anchor: _current,
        row: r,
        refPage: v.refPage,
        numerals: numerals,
        palette: p,
        onTap: widget.onChapter,
      );
    }
    return _ChapterRow(
      row: r,
      numerals: numerals,
      palette: p,
      onTap: widget.onChapter,
    );
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.view;
    final p = widget.palette;
    final numerals = v.rows.any((r) => r.numeral != null);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (v.club case final club?)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: _ClubStrip(club: club, palette: p, onTap: widget.onClub),
          ),
        const SizedBox(height: 8),
        Expanded(
          child: Semantics(
            container: true,
            explicitChildNodes: true,
            label: 'Capítulos',
            child: SizedBox(
              key: const ValueKey('toc.sheet.chapters'),
              child: v.rows.isEmpty
                  ? (v.tocFailed ? null : _Empty(palette: p))
                  : Stack(
                      clipBehavior: Clip.hardEdge,
                      children: [
                        Positioned(
                          top: -tocListLift,
                          left: 0,
                          right: 0,
                          bottom: 0,
                          // R12 (G20): a lista monta sob demanda — com 5.000 capítulos, só as linhas à vista
                          child: KeyedSubtree(
                            key: const ValueKey('toc.sheet.chapters.list'),
                            child: CustomScrollView(
                              controller: _scroll,
                              // as linhas vizinhas montadas: a rolagem sem espera e as linhas logo abaixo da dobra (a
                              // prancha tem as do XXXIII ao XXXVII sob o esmaecido)
                              scrollCacheExtent: const ScrollCacheExtent.pixels(
                                tocListCache,
                              ),
                              slivers: [
                                SliverPadding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                  ),
                                  sliver: SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (context, i) => _row(v, numerals, i),
                                      childCount: v.rows.length,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // a máscara da prancha: a cor da folha por cima das bordas da lista (sem camada)
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          height: tocFadeTop,
                          child: _Fade(color: p.island, down: true),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          height: tocFadeBottom,
                          child: _Fade(color: p.island, down: false),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Uma faixa da cor da folha que esmaece a lista: opaca na borda, transparente para dentro.
class _Fade extends StatelessWidget {
  const _Fade({required this.color, required this.down});

  final Color color;

  /// Opaca em cima (a borda de cima) ou embaixo.
  final bool down;

  @override
  Widget build(BuildContext context) {
    final clear = color.withValues(alpha: 0);
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: down ? [color, clear] : [clear, color],
          ),
        ),
      ),
    );
  }
}

/// O rótulo do capítulo para o leitor de tela: "XXV, No Passeio Público, página 121, 1 marca, lido".
String _spoken(TocRow r, {int? refPage}) => [
  ?r.numeral,
  r.title,
  if (r.page != null) 'página ${r.page}',
  if (r.marks.count > 0) r.marksLabel,
  if (r.read) 'lido',
  if (r.current) ...['lendo', 'você está na pág. $refPage'],
].join(', ');

TextStyle _numeralStyle(ReaderChromePalette p, {bool current = false}) =>
    AppTextStyles.readerTocNumeral.copyWith(
      color: current ? p.title : (p.night ? p.caption : AppColors.inkSoft),
    );

/// Uma linha (`toc.sheet.chapters.chN`): numeral 52 · título Literata 16 · marcas · página 30 · "lido" 18, com o
/// tracejado de 1,2 embaixo.
class _ChapterRow extends StatelessWidget {
  const _ChapterRow({
    required this.row,
    required this.numerals,
    required this.palette,
    required this.onTap,
  });

  final TocRow row;
  final bool numerals;
  final ReaderChromePalette palette;
  final ValueChanged<TocRow> onTap;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final id = 'toc.sheet.chapters.ch${row.chapter! + 1}';
    final body = SizedBox(
      key: ValueKey('$id.link'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 50),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 12, 0),
              child: Row(
                children: [
                  if (numerals) ...[
                    _Column(
                      key: row.numeral == null ? null : ValueKey('$id.numeral'),
                      width: 52,
                      text: row.numeral,
                      style: _numeralStyle(p),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Padding(
                      key: ValueKey('$id.title'),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: AppText(
                        row.title,
                        style: AppTextStyles.readerTocChapter.copyWith(
                          color: p.night
                              ? p.title
                              : (row.read ? AppColors.bookText : AppColors.ink),
                        ),
                      ),
                    ),
                  ),
                  if (row.marks.count > 0) ...[
                    const SizedBox(width: 10),
                    _Marks(id: '$id.marks', marks: row.marks, palette: p),
                  ],
                  const SizedBox(width: 10),
                  _Column(
                    key: row.page == null ? null : ValueKey('$id.page'),
                    width: 30,
                    text: row.page?.toString(),
                    style: AppTextStyles.readerTocPage.copyWith(
                      color: p.night ? p.label : AppColors.labelReader,
                    ),
                    end: true,
                  ),
                  const SizedBox(width: 10),
                  if (row.read)
                    _ReadCheck(id: '$id.read', palette: p)
                  else
                    SizedBox(
                      key: ValueKey('$id.status'),
                      width: 18,
                      height: 18,
                    ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: AppStrokes.thin,
            child: CustomPaint(
              painter: ChromiumDashPainter(
                axis: Axis.horizontal,
                thickness: AppStrokes.thin,
                color: p.night ? p.dash : AppColors.tocRule,
              ),
            ),
          ),
        ],
      ),
    );
    return KeyedSubtree(
      key: ValueKey(id),
      child: row.target == null
          ? body
          : Pressable(
              onTap: () => onTap(row),
              semanticsLabel: _spoken(row),
              child: body,
            ),
    );
  }
}

/// O capítulo atual (`aria-current=location`): cartão com o numeral na tinta, o título em 17/500, a página em 800, o
/// anel e, embaixo, a pílula "você está na pág. N" e as marcas.
class _CurrentCard extends StatelessWidget {
  const _CurrentCard({
    required this.anchor,
    required this.row,
    required this.refPage,
    required this.numerals,
    required this.palette,
    required this.onTap,
  });

  final GlobalKey anchor;
  final TocRow row;
  final int refPage;
  final bool numerals;
  final ReaderChromePalette palette;
  final ValueChanged<TocRow> onTap;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final id = 'toc.sheet.chapters.ch${row.chapter! + 1}';
    final line = BorderSide(width: _thin, color: p.border);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: KeyedSubtree(
        key: anchor,
        child: KeyedSubtree(
          key: ValueKey(id),
          child: Pressable(
            onTap: () => onTap(row),
            semanticsLabel: _spoken(row, refPage: refPage),
            child: NeoBox(
              key: ValueKey('$id.link'),
              color: p.island,
              border: BorderSide(width: AppStrokes.regular, color: p.border),
              radius: BorderRadius.circular(16),
              shadow: AppShadows.hard2,
              shadowColor: p.shadow,
              padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    key: ValueKey('$id.row'),
                    children: [
                      if (numerals) ...[
                        _Column(
                          key: row.numeral == null
                              ? null
                              : ValueKey('$id.numeral'),
                          width: 52,
                          text: row.numeral,
                          style: _numeralStyle(p, current: true),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Expanded(
                        child: AppText(
                          row.title,
                          key: ValueKey('$id.title'),
                          style: AppTextStyles.readerTocChapterCurrent.copyWith(
                            color: p.title,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _Column(
                        key: row.page == null ? null : ValueKey('$id.page'),
                        width: 30,
                        text: row.page?.toString(),
                        style: AppTextStyles.readerTocPageCurrent.copyWith(
                          color: p.title,
                        ),
                        end: true,
                      ),
                      const SizedBox(width: 10),
                      CustomPaint(
                        key: ValueKey('$id.progressRing'),
                        size: const Size(18, 18),
                        painter: TocProgressRingPainter(progress: row.progress),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 7, left: numerals ? 62 : 0),
                    child: Row(
                      key: ValueKey('$id.meta'),
                      children: [
                        NeoBox(
                          key: ValueKey('$id.youAreHere'),
                          height: 24,
                          color: AppColors.flame,
                          border: line,
                          radius: BorderRadius.circular(999),
                          padding: const EdgeInsets.fromLTRB(7, 0, 9, 0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AppSvg(
                                AppIconsLeitor.ribbonTiny,
                                key: ValueKey('$id.youAreHere.icon'),
                                size: 9,
                                height: 11,
                              ),
                              const SizedBox(width: 5),
                              AppText(
                                'você está na pág. $refPage',
                                key: ValueKey('$id.youAreHere.text'),
                                style: AppTextStyles.readerTocHere,
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                        if (row.marks.count > 0) ...[
                          const SizedBox(width: 10),
                          _Marks(id: '$id.marks', marks: row.marks, palette: p),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// O anel do capítulo atual (`toc.sheet.chapters.chN.progressRing`): trilho `#E9DFCC` e o arco coral de 2,6 a partir do
/// alto, no sentido horário, com ponta redonda (o SVG da prancha: raio 7, `stroke-dasharray` 44).
class TocProgressRingPainter extends CustomPainter {
  const TocProgressRingPainter({required this.progress});

  /// 0…1.
  final double progress;
  static const double radius = 7, stroke = 2.6;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    canvas.drawCircle(
      c,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = AppColors.hatchReader,
    );
    if (progress <= 0) return;
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress.clamp(0.0, 1.0),
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = AppColors.flame,
    );
  }

  @override
  bool shouldRepaint(TocProgressRingPainter old) => old.progress != progress;
}

/// As marcas do capítulo (Anexo 02 §4.2): até 3 símbolos de 16 sobrepostos −4 e o número.
class _Marks extends StatelessWidget {
  const _Marks({required this.id, required this.marks, required this.palette});

  final String id;
  final ChapterMarks marks;
  final ReaderChromePalette palette;

  static String _name(AnnotationKind k) => switch (k) {
    AnnotationKind.highlight => 'highlight',
    AnnotationKind.note => 'note',
    AnnotationKind.drawing => 'ink',
    AnnotationKind.handwriting => 'handwritten',
  };

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final line = BorderSide(width: _thin, color: p.border);
    final seen = <AnnotationKind, int>{};
    final placed = <Widget>[];
    var x = 0.0;
    for (final s in marks.symbols) {
      final n = seen[s.kind] = (seen[s.kind] ?? 0) + 1;
      final key = '$id.${_name(s.kind)}${n == 1 ? '' : '$n'}';
      final w = s.kind == AnnotationKind.note ? 14.0 : 16.0;
      final Widget symbol = switch (s.kind) {
        AnnotationKind.note => SizedBox(
          key: ValueKey(key),
          width: 14,
          height: 14,
          child: Transform.rotate(
            angle: -6 * math.pi / 180,
            child: NeoBox(
              color: AppColors.sun,
              border: line,
              radius: BorderRadius.circular(3),
            ),
          ),
        ),
        AnnotationKind.handwriting => NeoBox(
          key: ValueKey(key),
          width: 16,
          height: 16,
          color: AppColors.surface,
          border: line,
          radius: BorderRadius.circular(8),
          child: Center(
            child: AppSvg(
              AppIconsLeitor.pencilCoral,
              key: ValueKey('$key.icon'),
              size: 9,
            ),
          ),
        ),
        _ => NeoBox(
          key: ValueKey(key),
          width: 16,
          height: 16,
          color: s.color == null ? AppColors.sun : hexColor(s.color!),
          border: line,
          radius: BorderRadius.circular(8),
        ),
      };
      placed.add(
        Positioned(
          left: x,
          top: s.kind == AnnotationKind.note ? 1 : 0,
          child: symbol,
        ),
      );
      x += w - 4;
    }
    final width = marks.symbols.isEmpty ? 0.0 : x + 4;
    return ExcludeSemantics(
      child: Row(
        key: ValueKey(id),
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            key: ValueKey('$id.symbols'),
            width: width,
            height: 16,
            child: Stack(clipBehavior: Clip.none, children: placed),
          ),
          const SizedBox(width: 5),
          AppText(
            '${marks.count}',
            key: ValueKey('$id.count'),
            style: AppTextStyles.readerTocMarks.copyWith(
              color: p.night ? p.label : AppColors.labelReader,
            ),
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}

/// "lido": círculo verde de 18 com o ✓ de 11.
class _ReadCheck extends StatelessWidget {
  const _ReadCheck({required this.id, required this.palette});

  final String id;
  final ReaderChromePalette palette;

  @override
  Widget build(BuildContext context) => NeoBox(
    key: ValueKey(id),
    width: 18,
    height: 18,
    color: AppColors.leaf,
    border: BorderSide(width: _thin, color: palette.border),
    radius: BorderRadius.circular(9),
    child: Center(
      child: AppSvg(
        AppIconsLeitor.checkRead,
        key: ValueKey('$id.icon'),
        size: 11,
      ),
    ),
  );
}

/// Uma coluna de largura fixa (o numeral, 52; a página, 30) cujo texto mais largo transborda no espaço ao lado,
/// inteiro e numa linha, como no HTML da prancha (D-157): o numeral para a direita, a página (alinhada à direita) para
/// a esquerda.
class _Column extends StatelessWidget {
  const _Column({
    super.key,
    required this.width,
    required this.text,
    required this.style,
    this.end = false,
  });

  final double width;
  final String? text;
  final TextStyle style;

  /// Alinhada à direita (a página).
  final bool end;

  @override
  Widget build(BuildContext context) {
    final t = text;
    return SizedBox(
      width: width,
      child: t == null
          ? null
          : OverflowBox(
              alignment: end ? Alignment.centerRight : Alignment.centerLeft,
              minWidth: 0,
              maxWidth: double.infinity,
              fit: OverflowBoxFit.deferToChild,
              child: AppText(
                t,
                style: style,
                textAlign: end ? TextAlign.right : TextAlign.left,
                maxLines: 1,
              ),
            ),
    );
  }
}

/// A parte (D-153, versão mínima — D-21): um título pequeno em maiúsculas acima dos capítulos dela.
class _PartRow extends StatelessWidget {
  const _PartRow({
    required this.row,
    required this.palette,
    required this.onTap,
  });

  final TocRow row;
  final ReaderChromePalette palette;
  final ValueChanged<TocRow> onTap;

  @override
  Widget build(BuildContext context) {
    final id = 'toc.sheet.chapters.part${row.entry}';
    final body = Semantics(
      header: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 14, 10, 6),
        child: AppText(
          row.title.toUpperCase(),
          key: ValueKey('$id.title'),
          // o leitor de tela lê como no livro, não letra por letra
          semanticsLabel: row.title,
          style: AppTextStyles.readerTocPart.copyWith(
            color: palette.night ? palette.caption : AppColors.inkSoft,
          ),
        ),
      ),
    );
    return KeyedSubtree(
      key: ValueKey(id),
      child: row.target == null
          ? body
          : Pressable(onTap: () => onTap(row), child: body),
    );
  }
}

/// Sem sumário (D-21).
class _Empty extends StatelessWidget {
  const _Empty({required this.palette});

  final ReaderChromePalette palette;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(14, 24, 14, 0),
    child: Align(
      alignment: Alignment.topCenter,
      child: AppText(
        'Este livro não tem sumário.',
        key: const ValueKey('toc.sheet.empty'),
        style: AppTextStyles.readerTocEmpty.copyWith(
          color: palette.night ? palette.label : AppColors.labelReader,
        ),
        textAlign: TextAlign.center,
      ),
    ),
  );
}

/// A faixa do clube (D-149): bandeira, "NOME · QUI 24/9", "Até o cap. L · faltam 18" e a seta.
class _ClubStrip extends StatelessWidget {
  const _ClubStrip({required this.club, required this.palette, this.onTap});

  final TocClubStrip club;
  final ReaderChromePalette palette;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const ink = BorderSide(width: AppStrokes.regular, color: AppColors.ink);
    return Pressable(
      onTap: onTap,
      isLink: true,
      semanticsLabel: club.spoken,
      child: NeoBox(
        key: const ValueKey('toc.sheet.club'),
        color: AppColors.blush,
        border: BorderSide(width: AppStrokes.regular, color: palette.border),
        radius: BorderRadius.circular(18),
        shadow: AppShadows.hard2,
        shadowColor: palette.shadow,
        padding: const EdgeInsets.fromLTRB(10, 10, 8, 10),
        child: Row(
          children: [
            const NeoBox(
              key: ValueKey('toc.sheet.club.flag'),
              width: 38,
              height: 38,
              color: AppColors.surface,
              border: ink,
              radius: BorderRadius.all(Radius.circular(19)),
              child: Center(
                child: AppSvg(
                  AppIconsLeitor.flag,
                  key: ValueKey('toc.sheet.club.flag.icon'),
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                key: const ValueKey('toc.sheet.club.texts'),
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppText(
                    club.kicker,
                    key: const ValueKey('toc.sheet.club.kicker'),
                    style: AppTextStyles.readerTocClubKicker,
                    maxLines: 1,
                    ellipsis: true,
                  ),
                  const SizedBox(height: 2),
                  AppText(
                    club.goal,
                    key: const ValueKey('toc.sheet.club.goal'),
                    style: AppTextStyles.readerTocClubGoal,
                    maxLines: 1,
                    ellipsis: true,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const NeoBox(
              key: ValueKey('toc.sheet.club.arrow'),
              width: 34,
              height: 34,
              color: AppColors.surface,
              border: ink,
              radius: BorderRadius.all(Radius.circular(17)),
              child: Center(
                child: AppSvg(
                  AppIconsLeitor.chevronRight,
                  key: ValueKey('toc.sheet.club.arrow.icon'),
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

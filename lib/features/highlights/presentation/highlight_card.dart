// G19.5 — um cartão da tela 25 (L25c.2–L25c.5): o cabeçalho com as pílulas (R4), a data (R5) e "Mais opções"; a
// citação (R3) com o fundo dos grifos, a mancha do grifo à mão e a tinta dos desenhos (R10); a nota em post-it; o chip
// do clube (R8); a miniatura da nota à mão. As medidas são as da L25c (cartão 358, padding 12/8/16/16, raio 20,
// sombra 3/3). Para o leitor de tela, um nó com o rótulo da R4 e o texto, que abre o livro; "Mais opções", o chip e
// a miniatura são nós à parte.
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../../../core/design_system/painters/dashed_stadium_painter.dart';
import '../../../core/design_system/text/app_text.dart';
import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_icons_leitor.dart';
import '../../../core/design_system/tokens/app_strokes.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/app_svg.dart';
import '../../../core/design_system/widgets/neo_box.dart';
import '../../../core/design_system/widgets/pressable.dart';
import '../../reader/annotations/domain/annotation.dart';
import '../../reader/annotations/domain/ink_layer.dart';
import '../../reader/presentation/ink_painter.dart'
    show handHighlightAlpha, handHighlightPath;
import '../../reader/presentation/page_marks.dart'
    show underlineOffset, underlineThickness;
import '../../reader/presentation/wavy_underline.dart';
import '../application/highlights_club_source.dart';
import '../domain/card_text.dart';
import '../domain/highlight_card.dart';
import 'ink_thumbnail.dart';
import 'marked_quote.dart';

const BorderSide _line = BorderSide(
  width: AppStrokes.regular,
  color: AppColors.ink,
);

/// O tamanho da letra da citação (Literata 16,5).
const double quoteEm = 16.5;

/// A caixa da letra da Literata 16,5 (ascent + descent da fonte, sem a entrelinha — o `content area` do CSS: 24,5
/// nos inline da L25c), como a `readerTextArea` do leitor.
double quoteContentHeight() {
  final q = AppTextStyles.hlQuote;
  final b =
      ui.ParagraphBuilder(ui.ParagraphStyle(textDirection: TextDirection.ltr))
        ..pushStyle(
          ui.TextStyle(
            fontFamily: q.fontFamily,
            fontFamilyFallback: q.fontFamilyFallback,
            fontSize: q.fontSize,
            fontWeight: q.fontWeight,
            fontVariations: q.fontVariations,
          ),
        )
        ..addText('x');
  final p = b.build()..layout(const ui.ParagraphConstraints(width: 1e6));
  final m = p.computeLineMetrics().first;
  p.dispose();
  return m.ascent + m.descent;
}

/// O alpha do fundo do grifo a cada cor do arquivo (`mark` a .9/.95/.85/.75); outra cor, .9.
double markAlpha(String hex) => switch (hex) {
  '#FFC1C6' => 0.95,
  '#ABCF82' => 0.85,
  '#B6ACE4' => 0.75,
  _ => 0.9,
};

Color hexColor(String hex) =>
    Color(0xFF000000 | int.parse(hex.substring(1), radix: 16));

/// A caixa da letra de uma linha do trecho, no meio da linha.
Rect contentRect(QuoteBox b, double content) {
  final mid = (b.top + b.bottom) / 2;
  return Rect.fromLTRB(b.left, mid - content / 2, b.right, mid + content / 2);
}

/// O fundo do grifo (o `mark`): de 14 % a 92 % da caixa da letra, recortado no raio 3, uma caixa por linha.
QuotePainter markBand(String hex) => (canvas, origin, boxes, content) {
  final paint = Paint()
    ..color = hexColor(hex).withValues(alpha: markAlpha(hex));
  for (final b in boxes) {
    final r = contentRect(b, content).shift(origin);
    canvas
      ..save()
      ..clipRRect(RRect.fromRectAndRadius(r, const Radius.circular(3)))
      ..drawRect(
        Rect.fromLTRB(
          r.left,
          r.top + r.height * 0.14,
          r.right,
          r.top + r.height * 0.92,
        ),
        paint,
      )
      ..restore();
  }
};

/// O grifo sublinhado (R25 do leitor): a faixa abaixo da base, na cor viva.
QuotePainter underlineBand(String hex) => (canvas, origin, boxes, content) {
  final paint = Paint()..color = hexColor(hex);
  for (final b in boxes) {
    canvas.drawRect(
      Rect.fromLTRB(
        b.left,
        b.baseline + underlineOffset,
        b.right,
        b.baseline + underlineOffset + underlineThickness,
      ).shift(origin),
      paint,
    );
  }
};

/// O grifo ondulado (R25 do leitor), como no leitor.
QuotePainter wavyBand(String hex) => (canvas, origin, boxes, content) {
  for (final b in boxes) {
    paintWavyUnderline(
      canvas,
      origin.dx + b.left,
      origin.dx + b.right,
      origin.dy + b.baseline,
      hexColor(hex),
    );
  }
};

/// A caixa da mancha do grifo à mão no cartão (o `svg` do arquivo: 4 para os lados, de 3 abaixo do topo da letra até
/// 1 acima do pé).
Rect freehandRect(QuoteBox b, double content) {
  final r = contentRect(b, content);
  return Rect.fromLTRB(r.left - 4, r.top + 3, r.right + 4, r.bottom - 1);
}

/// A mancha do grifo feito à mão (D-161), multiplicada a 90 %.
QuotePainter freehandBlob(String hex) => (canvas, origin, boxes, content) {
  final paint = Paint()
    ..isAntiAlias = true
    ..color = hexColor(hex).withValues(alpha: handHighlightAlpha)
    ..blendMode = BlendMode.multiply;
  for (final b in boxes) {
    canvas.drawPath(
      handHighlightPath(freehandRect(b, content).shift(origin)),
      paint,
    );
  }
};

/// A tinta do desenho [layer] sobre o trecho (R10), pela imagem guardada em [cache].
QuotePainter drawingInk(InkLayer layer, InkThumbnailCache cache, double dpr) =>
    (canvas, origin, boxes, content) =>
        cache.paintDrawing(canvas, origin, layer, [
          for (final b in boxes)
            (left: b.left, right: b.right, baseline: b.baseline, em: quoteEm),
        ], dpr: dpr);

/// As marcas da citação: o trecho de cada grifo e de cada desenho no texto dos [spans].
List<QuoteMark> quoteMarks(
  List<CardSpan> spans,
  HighlightCard card,
  Map<String, InkLayer> layers,
  InkThumbnailCache cache,
  double dpr,
) {
  final byId = {for (final a in card.items) a.id: a};
  final marks = <QuoteMark>[];
  var offset = 0;
  for (final s in spans) {
    final a = s.annotationId == null ? null : byId[s.annotationId];
    final start = offset;
    offset += s.text.length;
    if (a == null) continue;
    final color = a.color;
    switch (a.kind) {
      case AnnotationKind.highlight when color == null:
        break;
      case AnnotationKind.highlight when a.source == AnnotationSource.ink:
        marks.add(
          QuoteMark(start: start, end: offset, front: freehandBlob(color!)),
        );
      case AnnotationKind.highlight:
        marks.add(switch (a.style) {
          HighlightStyle.underline => QuoteMark(
            start: start,
            end: offset,
            front: underlineBand(color!),
          ),
          HighlightStyle.wavy => QuoteMark(
            start: start,
            end: offset,
            front: wavyBand(color!),
          ),
          _ => QuoteMark(start: start, end: offset, behind: markBand(color!)),
        });
      case AnnotationKind.drawing:
        final layer = layers[a.inkLayerId];
        if (layer != null) {
          marks.add(
            QuoteMark(
              start: start,
              end: offset,
              front: drawingInk(layer, cache, dpr),
            ),
          );
        }
      case AnnotationKind.note || AnnotationKind.handwriting:
        break;
    }
  }
  return marks;
}

/// "Leitoras de Capitu · 3 respostas" ("1 resposta" no singular).
String repliesText(int n) => n == 1 ? '· 1 resposta' : '· $n respostas';

class HighlightCardView extends StatelessWidget {
  const HighlightCardView({
    super.key,
    required this.id,
    required this.card,
    required this.spans,
    required this.date,
    required this.semanticsLabel,
    required this.handLabel,
    required this.layers,
    required this.cache,
    required this.content,
    this.club,
    required this.onOpen,
    required this.onMore,
    this.onClub,
  });

  /// `hl.list.card<n>`.
  final String id;
  final HighlightCard card;
  final List<CardSpan> spans;

  /// A data da linha do cabeçalho ("2 set", "hoje" — ou "pág. 121 · 15 set" no sem lugar).
  final String date;

  /// O rótulo do cartão para o leitor de tela (R4 + o texto).
  final String semanticsLabel;

  /// O rótulo da miniatura da nota à mão ("Nota à mão, hoje" — D-31).
  final String handLabel;
  final Map<String, InkLayer> layers;
  final InkThumbnailCache cache;
  final double content;
  final ClubChip? club;
  final VoidCallback onOpen;
  final VoidCallback onMore;
  final VoidCallback? onClub;

  ValueKey<String> _k(String s) => ValueKey('$id.$s');

  Widget _pill(String key, String label, {String? dot, bool extra = false}) =>
      NeoBox(
        key: _k('head.$key'),
        height: 24,
        color: extra ? AppColors.sun : AppColors.paper,
        border: _line,
        radius: BorderRadius.circular(999),
        padding: const EdgeInsets.symmetric(horizontal: 9),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: [
            if (dot != null)
              NeoBox(
                key: _k('head.$key.dot'),
                width: 10,
                height: 10,
                color: hexColor(dot),
                border: const BorderSide(
                  width: AppStrokes.thin,
                  color: AppColors.ink,
                ),
                radius: BorderRadius.circular(5),
              ),
            AppText(label, style: AppTextStyles.hlPill, maxLines: 1),
          ],
        ),
      );

  Widget _head() {
    final main = switch (card.kind) {
      CardKind.highlight => 'highlight',
      CardKind.drawing when card.drawings.length > 1 => 'drawings',
      CardKind.drawing => 'drawing',
      CardKind.handwriting => 'handwritten',
    };
    return ExcludeSemantics(
      child: SizedBox(
        key: _k('head'),
        height: 24,
        child: Row(
          spacing: 6,
          children: [
            _pill(main, card.label, dot: card.dot),
            if (card.hasNotePill) _pill('note', 'NOTA', extra: true),
            if (card.hasHandPill) _pill('handwritten', 'À MÃO', extra: true),
            Expanded(
              child: Center(
                child: SizedBox(
                  key: _k('head.sep'),
                  width: double.infinity,
                  height: 0,
                ),
              ),
            ),
            AppText(
              date,
              key: _k('head.date'),
              style: AppTextStyles.hlDate,
              maxLines: 1,
            ),
            // o lugar de "Mais opções" (o botão vai por cima, com o alvo de 48 — `_more`)
            const SizedBox(width: 36, height: 24),
          ],
        ),
      ),
    );
  }

  /// "Mais opções": a caixa de 36 do arquivo (margem −6 em cima e embaixo), com o alvo de toque de 48.
  Widget _more() => Positioned(
    top: AppStrokes.regular + 12 - 6 - 6,
    right: AppStrokes.regular + 8 - 6,
    child: Pressable(
      semanticsLabel: 'Mais opções',
      onTap: onMore,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: SizedBox.square(
          key: _k('head.more'),
          dimension: 36,
          child: Center(
            child: AppSvg(
              AppIconsLeitor.moreDots,
              key: _k('head.more.icon'),
              size: 20,
            ),
          ),
        ),
      ),
    ),
  );

  Widget _quote(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return MarkedQuote(
      marks: quoteMarks(spans, card, layers, cache, dpr),
      // as marcas são refeitas a cada build: repinta só quando o que elas pintam muda
      signature: (
        card,
        [for (final s in spans) '${s.annotationId}\u0000${s.text}']
            .join('\u0001'),
        [
          for (final d in card.drawings)
            layers[d.inkLayerId]?.meta.version.toString(),
        ].join(','),
        dpr,
      ),
      content: content,
      child: AppText.rich(
        key: _k('body.quote'),
        TextSpan(
          style: AppTextStyles.hlQuote,
          children: [
            for (final s in spans)
              TextSpan(
                text: s.text,
                style: s.annotationId == null
                    ? AppTextStyles.hlQuoteMuted
                    : null,
              ),
          ],
        ),
      ),
    );
  }

  /// O post-it da nota: margem 14, padding 12/12/11, raio 12, girado −0,6°; a fita girada −3° no meio do topo.
  Widget _note(String text) => Padding(
    padding: const EdgeInsets.only(top: 14),
    child: Transform.rotate(
      key: _k('body.note'),
      angle: -0.6 * math.pi / 180,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          NeoBox(
            key: _k('body.note.box'),
            color: AppColors.sun,
            border: _line,
            radius: BorderRadius.circular(12),
            shadow: const Offset(2, 2),
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 11),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppText(
                    'NOTA',
                    key: _k('body.note.label'),
                    style: AppTextStyles.hlNoteLabel,
                  ),
                  const SizedBox(height: 3),
                  AppText(
                    text,
                    key: _k('body.note.text'),
                    style: AppTextStyles.hlNoteText,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: AppStrokes.regular - 9,
            left: 0,
            right: 0,
            child: Center(
              child: Transform.rotate(
                key: _k('body.note.tape'),
                angle: -3 * math.pi / 180,
                child: NeoBox(
                  key: _k('body.note.tape.box'),
                  width: 46,
                  height: 16,
                  color: AppColors.surface.withValues(alpha: 0.85),
                  border: const BorderSide(
                    width: AppStrokes.thin,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  /// O chip do clube: pílula rosa de 32, padding 0/12/0/8, o ícone 17 e os dois textos a 6 (o `gap` do arquivo).
  Widget _club(ClubChip c) => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: Row(
      key: _k('body.club'),
      children: [
        Pressable(
          isLink: true,
          semanticsLabel: '${c.name} ${repliesText(c.replies)}',
          onTap: onClub,
          child: NeoBox(
            key: _k('body.club.chip'),
            height: 32,
            color: AppColors.blush,
            border: _line,
            radius: BorderRadius.circular(999),
            padding: const EdgeInsets.fromLTRB(8, 0, 12, 0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 6,
              children: [
                AppSvg(
                  AppIconsLeitor.peopleChip,
                  key: _k('body.club.chip.icon'),
                  size: 17,
                ),
                AppText(c.name, style: AppTextStyles.hlClub, maxLines: 1),
                AppText(
                  repliesText(c.replies),
                  key: _k('body.club.chip.replies'),
                  style: AppTextStyles.hlClubReplies,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  /// A miniatura da nota à mão: a caixa tracejada de 96 (+ bordas), a etiqueta, as pautas e a tinta.
  Widget _handNote(BuildContext context, InkLayer? layer) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Semantics(
        container: true,
        image: true,
        label: handLabel,
        child: ExcludeSemantics(
          child: SizedBox(
            key: _k('body.handNote'),
            height: thumbNoteInkHeight + 2 * AppStrokes.regular,
            child: CustomPaint(
              painter: HandNotePainter(layer, cache, dpr),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  for (final (i, top) in [(1, 46.0), (2, 80.0)])
                    Positioned(
                      left: AppStrokes.regular + 10,
                      right: AppStrokes.regular + 10,
                      top: AppStrokes.regular + top,
                      child: SizedBox(
                        key: _k('body.handNote.rule$i'),
                        height: 1.2,
                        child: const ColoredBox(color: AppColors.noteRule),
                      ),
                    ),
                  Positioned(
                    left: AppStrokes.regular,
                    right: AppStrokes.regular,
                    top: AppStrokes.regular,
                    height: thumbNoteInkHeight,
                    child: SizedBox(key: _k('body.handNote.ink')),
                  ),
                  Positioned(
                    left: AppStrokes.regular + 10,
                    top: AppStrokes.regular - 11,
                    child: NeoBox(
                      key: _k('body.handNote.tag'),
                      height: 21,
                      color: AppColors.sun,
                      border: _line,
                      radius: BorderRadius.circular(999),
                      padding: const EdgeInsets.fromLTRB(6, 0, 8, 0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 4,
                        children: [
                          AppSvg(
                            AppIconsLeitor.pencilHeavy,
                            key: _k('body.handNote.tag.icon'),
                            size: 11,
                          ),
                          AppText(
                            'Nota à mão',
                            style: AppTextStyles.hlHandTag,
                            maxLines: 1,
                          ),
                        ],
                      ),
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

  @override
  Widget build(BuildContext context) {
    final note = card.notes.firstOrNull?.noteText;
    final hand = card.handwriting.firstOrNull;
    final c = club;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        label: semanticsLabel,
        onTapHint: 'Abrir no livro',
        onTap: onOpen,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          excludeFromSemantics: true,
          onTap: onOpen,
          child: Stack(
            children: [
              NeoBox(
                key: ValueKey(id),
                color: AppColors.surface,
                border: _line,
                radius: BorderRadius.circular(20),
                shadow: const Offset(3, 3),
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _head(),
                    const SizedBox(height: 10),
                    Padding(
                      key: _k('body'),
                      padding: const EdgeInsets.only(right: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ExcludeSemantics(child: _quote(context)),
                          if (note != null)
                            ExcludeSemantics(child: _note(note)),
                          if (c != null) _club(c),
                          if (hand != null)
                            _handNote(context, layers[hand.inkLayerId]),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _more(),
            ],
          ),
        ),
      ),
    );
  }
}

/// A caixa tracejada da miniatura da nota à mão (`#FFFDF8`, raio 14, tracejado 1,5 de tinta) e a tinta dela, pela
/// imagem do cache.
class HandNotePainter extends CustomPainter {
  HandNotePainter(this.layer, this.cache, this.dpr);

  final InkLayer? layer;
  final InkThumbnailCache cache;
  final double dpr;

  @override
  void paint(Canvas canvas, Size size) {
    final box = Offset.zero & size;
    canvas.drawRRect(
      RRect.fromRectAndRadius(box, const Radius.circular(14)),
      Paint()..color = AppColors.paperWhite,
    );
    drawDashedRRect(canvas, box, radius: 14, color: AppColors.ink);
    final l = layer;
    if (l == null) return;
    cache.paintHandNote(
      canvas,
      const Offset(AppStrokes.regular, AppStrokes.regular),
      l,
      dpr: dpr,
    );
  }

  @override
  bool shouldRepaint(HandNotePainter old) =>
      old.layer?.id != layer?.id ||
      old.layer?.meta.version != layer?.meta.version ||
      old.dpr != dpr ||
      old.cache != cache;
}

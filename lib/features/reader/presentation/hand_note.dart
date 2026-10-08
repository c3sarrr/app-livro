// G18.4 — a caixa da nota à mão (tela 24b, L24b.1, L24b.3) e a faixa recolhida (D-184), pintadas no canvas (no
// modo, por baixo da página; no leitor limpo, no lugar do espaço — D-183):
// - a caixa: fundo `#FFFDF8`, tracejado 1,5 de tinta com raio 18, as pautas `#EFE5D3` a 12 dos lados e a tinta da
//   nota (na unidade dela, medida por dentro da borda) recortada por dentro da borda;
// - a faixa: o mesmo fundo e tracejado na altura de uma linha do texto, sem pautas nem tinta;
// - a etiqueta "✎ Nota à mão" (no leitor limpo; o modo põe a dele, um widget): a pílula `#FED170` com a borda 1,5 de
//   tinta, o lápis (`ic_pencil_bold`, 13) e as letras Figtree 11,5/800.
// Noite (R14): fundo `#2A2520`, tracejado `#EDE3D1`, pautas `#4A433A`; a etiqueta continua amarela; a tinta pela
// D-174 (e o Marca-texto pela D-133). Sem camada (regra 12.4).
// G18.4 (L24b.2, L24b.4, R7–R9) — no modo, os controles por cima da página (irmãos do canvas: o toque neles não vira
// tinta), nos lugares da prancha relativos à caixa: a etiqueta, os botões Recolher e Apagar (40, redondos), a dica,
// a alça (52×22, sombra 2/2) que muda as linhas, e na faixa o "Abrir a nota"; o leitor de tela ouve o grupo "Nota à
// mão, depois de “…”" (R13), a tinta "Nota à mão, ‹dia› de ‹mês›" (D-31), os botões e a alça (com aumentar e
// diminuir de uma linha).
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../../core/design_system/painters/dashed_stadium_painter.dart';
import '../../../core/design_system/text/app_text.dart';
import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_icons_leitor.dart';
import '../../../core/design_system/tokens/app_shadows.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/app_svg.dart';
import '../../../core/design_system/widgets/pressable.dart';
import '../annotations/ink/ink_commands.dart' show SessionNote;
import '../annotations/ink/ink_stroke.dart';
import '../annotations/space/hand_note_layout.dart';
import '../annotations/space/note_ink.dart';
import '../annotations/space/space_metrics.dart';
import '../annotations/space/space_seam.dart';
import '../application/annotation_session.dart';
import '../application/reader_ink.dart' show ReaderNote;
import '../layout/display_page.dart';
import 'ink_painter.dart';

/// As cores da caixa, da faixa e dos controles no papel (Creme, Branco, Sépia) e no Noite (R14).
@immutable
final class HandNoteColors {
  const HandNoteColors({
    required this.paper,
    required this.line,
    required this.rule,
    required this.button,
    required this.hint,
  });

  /// O fundo da caixa e da faixa.
  final Color paper;

  /// O tracejado e a borda dos botões e da alça.
  final Color line;
  final Color rule;

  /// O fundo dos botões e da alça.
  final Color button;
  final Color hint;

  /// A prancha 24b (Creme, Branco e Sépia).
  static const HandNoteColors onPaper = HandNoteColors(
    paper: AppColors.paperWhite,
    line: AppColors.ink,
    rule: AppColors.noteRule,
    button: AppColors.surface,
    hint: AppColors.readerFooter,
  );

  /// R14: o fundo da ilha do Noite, o tracejado e as bordas claros, as pautas escuras.
  static const HandNoteColors night = HandNoteColors(
    paper: AppColors.islandNight,
    line: AppColors.inkNight,
    rule: AppColors.dashNight,
    button: AppColors.islandNight,
    hint: AppColors.mutedNight,
  );
}

/// O raio da caixa e o da faixa (no máximo a metade da altura dela).
const double handNoteRadius = 18;

/// A caixa da nota de [lines] linhas em [box] (a caixa com a borda) e a tinta [strokes] dela (unidade da nota); com
/// [tag], a etiqueta por cima. [lightText] = as letras do Noite (a tinta pela D-174).
void paintHandNote(
  Canvas canvas,
  Rect box, {
  required int lines,
  required List<InkStroke> strokes,
  required HandNoteColors colors,
  Color? lightText,
  bool tag = false,
}) {
  final parts = handNoteLayout(box, lines);
  final rr = RRect.fromRectAndRadius(
    box,
    const Radius.circular(handNoteRadius),
  );
  canvas.drawRRect(rr, Paint()..color = colors.paper);
  final rule = Paint()..color = colors.rule;
  for (final r in parts.rules) {
    canvas.drawRect(r, rule);
  }
  if (strokes.isNotEmpty) {
    final frame = inkFrame(box);
    final onPage = [for (final s in strokes) fromNote(s, frame)];
    // o `overflow: hidden` da caixa: a tinta fica por dentro da borda
    canvas
      ..save()
      ..clipRRect(rr.deflate(noteBorder));
    if (lightText != null) {
      paintInkBehind(canvas, onPage, lightText: lightText);
    }
    paintInk(canvas, onPage, lightText: lightText);
    if (lightText != null) {
      paintInkFill(canvas, onPage, lightText: lightText);
    }
    canvas.restore();
  }
  drawDashedRRect(
    canvas,
    box,
    radius: handNoteRadius,
    thickness: noteBorder,
    color: colors.line,
  );
  if (tag) paintNoteTag(canvas, parts.tag);
}

/// A faixa recolhida em [strip] (a altura de uma linha do texto — D-184); com [tag], a etiqueta no meio dela.
void paintNoteStrip(
  Canvas canvas,
  Rect strip, {
  required HandNoteColors colors,
  bool tag = false,
}) {
  final radius = math.min(handNoteRadius, strip.height / 2);
  canvas.drawRRect(
    RRect.fromRectAndRadius(strip, Radius.circular(radius)),
    Paint()..color = colors.paper,
  );
  drawDashedRRect(
    canvas,
    strip,
    radius: radius,
    thickness: noteBorder,
    color: colors.line,
  );
  if (tag) paintNoteTag(canvas, stripLayout(strip).tag);
}

// ---- o leitor limpo (R11, D-183, D-184) ------------------------------------------------------------------------

/// A caixa da nota no bloco [block] do espaço (com as margens): a da 24b, 30 abaixo do topo e 42·n + 24 de altura
/// (D-182); recolhida, a faixa, 10 para dentro em cima e embaixo (D-184).
Rect noteBoxIn(Rect block, {required int lines, required bool collapsed}) =>
    collapsed
    ? Rect.fromLTRB(
        block.left,
        block.top + stripMargin,
        block.right,
        block.bottom - stripMargin,
      )
    : Rect.fromLTWH(
        block.left,
        block.top + noteMarginTop,
        block.width,
        noteBoxHeight(lines),
      );

/// As notas [notes] que têm espaço na página [page], com a caixa (ou a faixa) delas, de cima para baixo.
List<(ReaderNote, Rect)> placedNotes(DisplayPage page, List<ReaderNote> notes) {
  if (notes.isEmpty) return const [];
  final byId = {for (final n in notes) n.id: n};
  return [
    for (final s in spacesOf(page))
      if (byId[s.id] case final n?)
        (n, noteBoxIn(s.rect, lines: n.lines, collapsed: n.collapsed)),
  ];
}

/// R11: as notas [notes] da página [page] do leitor limpo — a caixa com a etiqueta, as pautas e a tinta, ou a faixa
/// com a etiqueta; sem botões, alça nem dica (D-183). [lightText] = as letras do Noite (R14).
void paintPageNotes(
  Canvas canvas,
  DisplayPage page,
  List<ReaderNote> notes, {
  Color? lightText,
}) {
  final colors = lightText == null
      ? HandNoteColors.onPaper
      : HandNoteColors.night;
  for (final (n, box) in placedNotes(page, notes)) {
    if (n.collapsed) {
      paintNoteStrip(canvas, box, colors: colors, tag: true);
    } else {
      paintHandNote(
        canvas,
        box,
        lines: n.lines,
        strokes: n.strokes,
        colors: colors,
        lightText: lightText,
        tag: true,
      );
    }
  }
}

// ---- a etiqueta ------------------------------------------------------------------------------------------------

/// Por dentro da borda da etiqueta: 7 até o lápis, 5 até o texto, 10 depois dele (a prancha: 8,5 / 5 / 11,5 com a
/// borda); a base das letras 16,03 abaixo do topo.
const double noteTagPadLeft = 7;
const double noteTagGap = 5;
const double noteTagPadRight = 10;
const double noteTagIcon = 13;
const double noteTagBaseline = 16.03;

/// "Nota à mão".
const String noteTagText = 'Nota à mão';

final TextPainter _tagText = TextPainter(
  text: TextSpan(text: noteTagText, style: AppTextStyles.annNoteTag),
  textDirection: TextDirection.ltr,
  maxLines: 1,
)..layout();

/// O lápis do arquivo (`ic_pencil_bold`: `M4 20h4L19 9a2.8 2.8 0 0 0-4-4L4 16z`, traço 2,4 na caixa de 24).
final Path _pencil = Path()
  ..moveTo(4, 20)
  ..lineTo(8, 20)
  ..lineTo(19, 9)
  ..arcToPoint(
    const Offset(15, 5),
    radius: const Radius.circular(2.8),
    clockwise: false,
  )
  ..lineTo(4, 16)
  ..close();

/// O tamanho da etiqueta (a largura vem do texto).
Size noteTagSize() => Size(
  noteBorder +
      noteTagPadLeft +
      noteTagIcon +
      noteTagGap +
      _tagText.width +
      noteTagPadRight +
      noteBorder,
  noteTagHeight,
);

/// A etiqueta "✎ Nota à mão" com o canto de cima à esquerda em [at].
void paintNoteTag(Canvas canvas, Offset at) {
  final size = noteTagSize();
  final rr = RRect.fromRectAndRadius(
    at & size,
    Radius.circular(size.height / 2),
  );
  canvas
    ..drawRRect(rr, Paint()..color = AppColors.sun)
    ..drawRRect(
      rr.deflate(noteBorder / 2),
      Paint()
        ..color = AppColors.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = noteBorder,
    );
  final iconLeft = at.dx + noteBorder + noteTagPadLeft;
  canvas
    ..save()
    ..translate(iconLeft, at.dy + (size.height - noteTagIcon) / 2)
    ..scale(noteTagIcon / 24)
    ..drawPath(
      _pencil,
      Paint()
        ..color = AppColors.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    )
    ..restore();
  final baseline = _tagText.computeDistanceToActualBaseline(
    TextBaseline.alphabetic,
  );
  _tagText.paint(
    canvas,
    Offset(
      iconLeft + noteTagIcon + noteTagGap,
      at.dy + noteTagBaseline - baseline,
    ),
  );
}

// ---- os controles no modo (L24b.2, L24b.4) ---------------------------------------------------------------------

/// A dica "puxe a alça para aumentar" e a altura da linha dela (Figtree 11 × 1,2).
const String noteHintText = 'puxe a alça para aumentar';
const double noteHintHeight = 13.2;

/// Os rótulos do leitor de tela (R13).
const String noteCollapseLabel = 'Recolher a nota';
const String noteDeleteLabel = 'Apagar a nota';
const String noteOpenLabel = 'Abrir a nota';

/// O botão da faixa no leitor limpo (R13).
const String noteOpenInReaderLabel = 'Abrir a nota à mão';
const String noteHandleLabel = 'Arrastar para mudar a altura do espaço';

/// A pílula do apagar (D-185).
const String noteDeletedText = 'Nota apagada';

const List<String> _months = [
  'janeiro',
  'fevereiro',
  'março',
  'abril',
  'maio',
  'junho',
  'julho',
  'agosto',
  'setembro',
  'outubro',
  'novembro',
  'dezembro',
];

/// D-31: a tinta da nota para o leitor de tela, "Nota à mão, 20 de setembro" (a data local de [createdAt]).
String noteInkLabel(DateTime createdAt) {
  final d = createdAt.toLocal();
  return 'Nota à mão, ${d.day} de ${_months[d.month - 1]}';
}

/// R13: o grupo da nota, "Nota à mão, depois de “‹a frase da âncora›”" (sem o texto do item, só "Nota à mão").
String noteGroupLabel(String? text, int at) => text == null
    ? 'Nota à mão'
    : 'Nota à mão, depois de “${sentenceBefore(text, at)}”';

/// As notas da sessão no modo: os controles de cada caixa e de cada faixa, [dy] abaixo do lugar delas na página (os
/// 30 px do modo e o deslocamento dos 2 dedos), recortados na caixa da página [pageBox].
class HandNoteLayer extends StatelessWidget {
  const HandNoteLayer({
    super.key,
    required this.session,
    required this.dy,
    required this.pageBox,
    required this.colors,
  });

  final AnnotationSession session;
  final double dy;
  final Rect pageBox;
  final HandNoteColors colors;

  @override
  Widget build(BuildContext context) {
    final s = session;
    final notes = <Widget>[];
    for (final n in s.notes) {
      final box = s.noteBox(n.id)?.shift(Offset(0, dy));
      if (box == null) continue;
      final label = noteGroupLabel(s.anchors.textOf(n.unit), n.at);
      notes.add(
        n.collapsed
            ? _strip(n, box, label)
            : _box(n, box, label, s.noteStrokes(n.id).isNotEmpty),
      );
    }
    return ClipRect(
      clipper: _PageClip(pageBox),
      child: Stack(clipBehavior: Clip.none, children: notes),
    );
  }

  /// A caixa aberta: a área vai dos botões (acima) até a sombra da alça (abaixo), e as peças se posicionam nela.
  Widget _box(SessionNote n, Rect box, String label, bool inked) {
    final p = handNoteLayout(box, n.lines);
    final area = Rect.fromLTRB(
      box.left,
      math.min(p.delete.top, p.tag.dy),
      box.right,
      p.handle.bottom + AppShadows.hard2.dy,
    );
    Rect at(Rect r) => r.shift(-area.topLeft);
    final ink = inkFrame(box);
    return Positioned.fromRect(
      key: ValueKey('ann.page.handNote@${n.id}'),
      rect: area,
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        label: label,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            _mark('ann.page.handNote', at(box)),
            Positioned.fromRect(
              rect: at(Rect.fromLTWH(ink.left, ink.top, ink.width, box.height)),
              child: IgnorePointer(
                child: inked
                    ? Semantics(
                        key: const ValueKey('ann.page.handNote.ink'),
                        image: true,
                        label: noteInkLabel(n.createdAt),
                        child: const SizedBox.expand(),
                      )
                    : const SizedBox.expand(
                        key: ValueKey('ann.page.handNote.ink'),
                      ),
              ),
            ),
            Positioned(
              left: p.tag.dx - area.left,
              top: p.tag.dy - area.top,
              child: const IgnorePointer(child: NoteTag()),
            ),
            Positioned(
              left: p.hintBottomLeft.dx - area.left,
              top: p.hintBottomLeft.dy - noteHintHeight - area.top,
              child: IgnorePointer(
                child: AppText(
                  noteHintText,
                  key: const ValueKey('ann.page.handNote.hint'),
                  style: AppTextStyles.annNoteHint.copyWith(color: colors.hint),
                  maxLines: 1,
                ),
              ),
            ),
            Positioned(
              left: p.collapse.left - area.left,
              top: p.collapse.top - area.top,
              child: SizedBox(
                key: const ValueKey('ann.page.handNote.actions'),
                width: p.delete.right - p.collapse.left,
                height: p.collapse.height,
                child: Row(
                  children: [
                    _RoundButton(
                      id: 'ann.page.handNote.actions.collapse',
                      label: noteCollapseLabel,
                      icon: AppIconsLeitor.chevronUp,
                      size: p.collapse.width,
                      iconSize: 18,
                      colors: colors,
                      onTap: () => session.toggleNote(n.id),
                    ),
                    const Spacer(),
                    _RoundButton(
                      id: 'ann.page.handNote.actions.delete',
                      label: noteDeleteLabel,
                      icon: AppIconsLeitor.trash,
                      size: p.delete.width,
                      iconSize: 18,
                      colors: colors,
                      onTap: () => session.deleteNote(n.id),
                    ),
                  ],
                ),
              ),
            ),
            Positioned.fromRect(
              key: const ValueKey('handle'),
              rect: at(p.handle),
              child: _Handle(session: session, id: n.id, colors: colors),
            ),
            // as pautas mudam de número com a alça: por último, para não trocar o lugar das outras peças (a alça
            // arrastando continua a mesma)
            for (final (i, r) in p.rules.indexed)
              _mark('ann.page.handNote.rule${i + 1}', at(r)),
          ],
        ),
      ),
    );
  }

  /// A faixa recolhida (D-184): a etiqueta e o "Abrir a nota".
  Widget _strip(SessionNote n, Rect strip, String label) {
    final p = stripLayout(strip);
    return Positioned.fromRect(
      key: ValueKey('ann.page.handNote@${n.id}'),
      rect: strip,
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        label: label,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            _mark('ann.page.handNote', Offset.zero & strip.size),
            Positioned(
              left: p.tag.dx - strip.left,
              top: p.tag.dy - strip.top,
              child: const IgnorePointer(child: NoteTag()),
            ),
            Positioned.fromRect(
              rect: p.open.shift(-strip.topLeft),
              child: _RoundButton(
                id: 'ann.page.handNote.open',
                label: noteOpenLabel,
                icon: AppIconsLeitor.chevronUp,
                size: p.open.width,
                iconSize: 16,
                flip: true,
                colors: colors,
                onTap: () => session.toggleNote(n.id),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Uma peça que só marca o lugar (a pintura é do canvas).
  static Widget _mark(String id, Rect r) => Positioned.fromRect(
    rect: r,
    child: IgnorePointer(child: SizedBox(key: ValueKey(id))),
  );
}

final class _PageClip extends CustomClipper<Rect> {
  const _PageClip(this.rect);

  final Rect rect;

  @override
  Rect getClip(Size size) => rect;

  @override
  bool shouldReclip(_PageClip old) => old.rect != rect;
}

/// A etiqueta "✎ Nota à mão" (o widget do modo; no leitor limpo, [paintNoteTag]): 24 de altura, pílula `#FED170` com
/// a borda 1,5 de tinta, 7 até o lápis de 13, 5 até o texto e 10 depois dele. Fica fora da árvore semântica (o grupo
/// já diz "Nota à mão").
class NoteTag extends StatelessWidget {
  const NoteTag({super.key});

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      key: const ValueKey('ann.page.handNote.tag'),
      height: noteTagHeight,
      padding: const EdgeInsets.fromLTRB(noteTagPadLeft, 0, noteTagPadRight, 0),
      decoration: BoxDecoration(
        color: AppColors.sun,
        border: Border.all(width: noteBorder, color: AppColors.ink),
        borderRadius: BorderRadius.circular(noteTagHeight / 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppSvg(
            AppIconsLeitor.pencilBold,
            key: ValueKey('ann.page.handNote.tag.icon'),
            size: noteTagIcon,
          ),
          const SizedBox(width: noteTagGap),
          AppText(noteTagText, style: AppTextStyles.annNoteTag, maxLines: 1),
        ],
      ),
    ),
  );
}

/// Um botão redondo da nota: [size] com a borda 1,5, o ícone [icon] de [iconSize] no meio ([flip] = de ponta-cabeça).
class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.id,
    required this.label,
    required this.icon,
    required this.size,
    required this.iconSize,
    required this.colors,
    required this.onTap,
    this.flip = false,
  });

  final String id;
  final String label;
  final String icon;
  final double size;
  final double iconSize;
  final HandNoteColors colors;
  final VoidCallback onTap;
  final bool flip;

  @override
  Widget build(BuildContext context) {
    Widget svg = AppSvg(
      icon,
      key: ValueKey('$id.icon'),
      size: iconSize,
      colors: colors.line == AppColors.ink
          ? null
          : {AppColors.ink: colors.line},
    );
    if (flip) svg = RotatedBox(quarterTurns: 2, child: svg);
    return Pressable(
      key: ValueKey(id),
      semanticsLabel: label,
      onTap: onTap,
      child: Container(
        key: ValueKey('$id.box'),
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.button,
          shape: BoxShape.circle,
          border: Border.all(width: noteBorder, color: colors.line),
        ),
        child: svg,
      ),
    );
  }
}

/// A alça (R7, D-186): arrastar muda as linhas de 42 em 42; soltar é um passo. O leitor de tela aumenta e diminui
/// de uma linha.
class _Handle extends StatefulWidget {
  const _Handle({
    required this.session,
    required this.id,
    required this.colors,
  });

  final AnnotationSession session;
  final String id;
  final HandNoteColors colors;

  @override
  State<_Handle> createState() => _HandleState();
}

class _HandleState extends State<_Handle> {
  double? _from;

  void _step(double dy) {
    widget.session
      ..dragNoteHandle(widget.id, dy)
      ..endNoteHandle(widget.id);
  }

  void _end() {
    if (_from == null) return;
    _from = null;
    widget.session.endNoteHandle(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.colors;
    Widget bar(String id) => Container(
      key: ValueKey('ann.page.handNote.handle.$id'),
      width: 20,
      height: 1.6,
      decoration: BoxDecoration(
        color: c.line,
        borderRadius: BorderRadius.circular(2),
      ),
    );
    return Semantics(
      key: const ValueKey('ann.page.handNote.handle'),
      container: true,
      button: true,
      label: noteHandleLabel,
      onIncrease: () => _step(noteLinePx),
      onDecrease: () => _step(-noteLinePx),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        onVerticalDragDown: (d) => _from = d.globalPosition.dy,
        onVerticalDragUpdate: (d) {
          final from = _from;
          if (from == null) return;
          widget.session.dragNoteHandle(widget.id, d.globalPosition.dy - from);
        },
        onVerticalDragEnd: (_) => _end(),
        onVerticalDragCancel: _end,
        child: Container(
          key: const ValueKey('ann.page.handNote.handle.box'),
          decoration: BoxDecoration(
            color: c.button,
            border: Border.all(width: noteBorder, color: c.line),
            borderRadius: BorderRadius.circular(11),
            boxShadow: [BoxShadow(color: c.line, offset: AppShadows.hard2)],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [bar('bar1'), const SizedBox(height: 3), bar('bar2')],
          ),
        ),
      ),
    );
  }
}

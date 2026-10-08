// G18.4 — a caixa da nota à mão (tela 24b, L24b.1, L24b.3) e a faixa recolhida (D-184), pintadas no canvas (no
// modo, por baixo da página; no leitor limpo, no lugar do espaço — D-183):
// - a caixa: fundo `#FFFDF8`, tracejado 1,5 de tinta com raio 18, as pautas `#EFE5D3` a 12 dos lados e a tinta da
//   nota (na unidade dela, medida por dentro da borda) recortada por dentro da borda;
// - a faixa: o mesmo fundo e tracejado na altura de uma linha do texto, sem pautas nem tinta;
// - a etiqueta "✎ Nota à mão" (no leitor limpo; o modo põe a dele, um widget): a pílula `#FED170` com a borda 1,5 de
//   tinta, o lápis (`ic_pencil_bold`, 13) e as letras Figtree 11,5/800.
// Noite (R14): fundo `#2A2520`, tracejado `#EDE3D1`, pautas `#4A433A`; a etiqueta continua amarela; a tinta pela
// D-174 (e o Marca-texto pela D-133). Sem camada (regra 12.4).
import 'dart:math' as math;

import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/painting.dart';

import '../../../core/design_system/painters/dashed_stadium_painter.dart';
import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../annotations/ink/ink_stroke.dart';
import '../annotations/space/hand_note_layout.dart';
import '../annotations/space/note_ink.dart';
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

// G19.1 — a exportação da tela 25 (D-194, R9): os grifos e as notas de texto do livro todo, em Markdown (um título
// por livro, um bloco por página, a citação em ">" e a nota logo abaixo) e em CSV (UTF-8 com BOM, ";", CRLF — abre
// direto no Excel brasileiro). Desenhos e notas à mão ficam de fora (o PDF com eles é do Pro — D-65). Dart puro.
import '../../../core/design_system/color/color_names.dart';
import '../../reader/annotations/domain/annotation.dart';
import '../../reader/domain/locator.dart';
import 'card_dates.dart';

/// O livro no cabeçalho do Markdown.
typedef ExportBook = ({String title, String? author});

const String _from = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
const String _to = 'aaaaaeeeeiiiiooooouuuucn';

/// `dom-casmurro-grifos-e-notas.md`.
String exportFileName(String title, String ext) {
  final b = StringBuffer();
  for (final ch in title.toLowerCase().split('')) {
    final i = _from.indexOf(ch);
    b.write(i >= 0 ? _to[i] : ch);
  }
  final slug = b
      .toString()
      .replaceAll(RegExp('[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
  return '${slug.isEmpty ? 'livro' : slug}-grifos-e-notas.$ext';
}

bool _exportable(Annotation a) =>
    a.kind == AnnotationKind.highlight || a.kind == AnnotationKind.note;

/// Quantos itens a exportação leva (grifos e notas de texto — R12).
int exportableCount(Iterable<Annotation> items) =>
    items.where(_exportable).length;

String _exact(Annotation a) => switch (a.anchor) {
  EpubAnchor(:final quote) => quote.exact,
  _ => '',
};

String _kindWord(Annotation h) => h.source == AnnotationSource.ink
    ? 'Grifo à mão livre'
    : 'Grifo ${markerColorName(h.color ?? '') ?? 'de outra cor'}';

String _colorWord(Annotation h) =>
    markerColorName(h.color ?? '') ?? (h.color ?? '');

Map<String, List<Annotation>> _notesByParent(Iterable<Annotation> items) {
  final m = <String, List<Annotation>>{};
  for (final a in items) {
    final p = a.parentId;
    if (a.kind == AnnotationKind.note && p != null) (m[p] ??= []).add(a);
  }
  return m;
}

String _two(int x) => x.toString().padLeft(2, '0');

String markdownOf(
  ExportBook book,
  List<Annotation> inBookOrder, {
  required DateTime now,
  required Duration Function(DateTime utc) offsetAt,
}) {
  final u = now.toUtc();
  final d = u.add(offsetAt(u));
  final author = book.author;
  final b = StringBuffer()
    ..writeln('# ${book.title} — grifos e notas')
    ..writeln(
      [
        if (author != null && author.isNotEmpty) author,
        'exportado em ${_two(d.day)}/${_two(d.month)}/${d.year}',
      ].join(' · '),
    );
  final notes = _notesByParent(inBookOrder);
  int? page;
  for (final h in inBookOrder) {
    if (h.kind != AnnotationKind.highlight) continue;
    if (h.refPage != page) {
      b
        ..writeln()
        ..writeln('## pág. ${h.refPage}');
      page = h.refPage;
    } else {
      b.writeln();
    }
    final when = cardDate(
      h.meta.createdAt,
      now: now,
      offsetAt: offsetAt,
      withYear: true,
    );
    b
      ..writeln('> ${_exact(h)}')
      ..writeln()
      ..writeln('${_kindWord(h)} · $when');
    for (final n in notes[h.id] ?? const <Annotation>[]) {
      b.writeln('**Nota:** ${n.noteText}');
    }
  }
  b.writeln();
  return b.toString();
}

String _csvField(String s) =>
    s.contains(RegExp('[;"\r\n]')) ? '"${s.replaceAll('"', '""')}"' : s;

String csvOf(
  List<Annotation> inBookOrder, {
  required List<String?> chapterLabels,
  required Duration Function(DateTime utc) offsetAt,
}) {
  final notes = _notesByParent(inBookOrder);
  final rows = <List<String>>[
    ['pagina', 'capitulo', 'tipo', 'cor', 'trecho', 'nota', 'criado_em'],
  ];
  for (final h in inBookOrder) {
    if (h.kind != AnnotationKind.highlight) continue;
    final u = h.meta.createdAt.toUtc();
    final t = u.add(offsetAt(u));
    final c = h.chapterIndex;
    rows.add([
      '${h.refPage}',
      c < chapterLabels.length ? chapterLabels[c] ?? '' : '',
      h.source == AnnotationSource.ink ? 'grifo à mão livre' : 'grifo',
      _colorWord(h),
      _exact(h),
      [for (final n in notes[h.id] ?? const <Annotation>[]) n.noteText!]
          .join(' | '),
      '${t.year}-${_two(t.month)}-${_two(t.day)} ${_two(t.hour)}:${_two(t.minute)}',
    ]);
  }
  final body = rows.map((r) => r.map(_csvField).join(';')).join('\r\n');
  return '﻿$body\r\n';
}

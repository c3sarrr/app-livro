// G16.4 — o que o Concluir grava (§4) e o rascunho em JSON no `kv`, na chave `ink_draft:<dono>:<user_book_id>`.
// As linhas já vão com a âncora, a página, o capítulo e o grupo calculados: gravar o rascunho não precisa da página
// aberta (D-166). Versão desconhecida ou JSON quebrado viram `null`: o rascunho nunca derruba a abertura do livro.
// G17 (R24): o formato 2 leva os grifos do marca-texto — os novos, os movidos pela D-32 e os tirados com o destino
// das notas — e ainda lê o formato 1 da G16 (sem grifos). G18 (R10): o formato 3 leva as notas à mão (a camada
// `space` e a anotação `handwriting` de cada uma) e as apagadas; lê os formatos 1 e 2 (sem notas).
import 'dart:convert';

import 'package:flutter/foundation.dart'
    show immutable, listEquals, mapEquals, setEquals;

import '../../domain/locator.dart';
import '../domain/annotation.dart'
    show AnnotationSource, FillHeight, HighlightStyle;

/// A versão do formato do rascunho.
const int inkDraftVersion = 3;

/// A chave do rascunho no `kv` (só do aparelho, nunca sincroniza): uma por sessão do modo anotação ([session]), para
/// que uma sessão nunca apague nem sobrescreva o rascunho de outra (o de uma sessão que morreu e que não gravou ao
/// abrir o livro). Sem [session], o começo comum das chaves do livro (`<começo>:<sessão>`).
String draftKey(String owner, String userBookId, [String? session]) =>
    session == null
    ? 'ink_draft:$owner:$userBookId'
    : 'ink_draft:$owner:$userBookId:$session';

/// Um desenho pronto a gravar: a camada `over_text` ([layerId], âncora de 8 chaves, os traços em BNK1) e a anotação
/// `drawing` dela ([annotationId], âncora de intervalo de 7 chaves, página, capítulo, grupo e a cor do 1º traço).
@immutable
final class DrawingRow {
  DrawingRow({
    required this.layerId,
    required this.annotationId,
    required DateTime createdAt,
    required this.anchor,
    required this.range,
    required this.refPage,
    required this.chapterIndex,
    required this.groupId,
    required this.color,
    required this.strokesB64,
    required this.strokeCount,
  }) : createdAt = createdAt.toUtc();

  final String layerId;
  final String annotationId;
  final DateTime createdAt;

  /// A âncora da camada (com `"ink": {"w"}`).
  final TextAnchor anchor;

  /// A âncora da anotação (7 chaves).
  final EpubAnchor range;
  final int refPage;
  final int chapterIndex;
  final String groupId;

  /// `#RRGGBB` do 1º traço.
  final String color;
  final String strokesB64;
  final int strokeCount;

  Map<String, Object?> toJson() => {
    'layerId': layerId,
    'annotationId': annotationId,
    'createdAt': createdAt.toIso8601String(),
    'anchor': anchor.toJson(),
    'range': range.toJson(),
    'refPage': refPage,
    'chapterIndex': chapterIndex,
    'groupId': groupId,
    'color': color,
    'strokesB64': strokesB64,
    'strokeCount': strokeCount,
  };

  /// A linha do JSON [j]; `null` se faltar ou sobrar algo do tipo errado.
  static DrawingRow? tryFromJson(Object? j) {
    if (j is! Map<String, dynamic>) return null;
    final anchor = j['anchor'];
    final range = j['range'];
    final createdAt = j['createdAt'];
    if (j['layerId'] is! String ||
        j['annotationId'] is! String ||
        createdAt is! String ||
        anchor is! Map<String, dynamic> ||
        range is! Map<String, dynamic> ||
        j['refPage'] is! int ||
        j['chapterIndex'] is! int ||
        j['groupId'] is! String ||
        j['color'] is! String ||
        j['strokesB64'] is! String ||
        j['strokeCount'] is! int) {
      return null;
    }
    final epub = TextAnchor.fromJson(range);
    final at = DateTime.tryParse(createdAt);
    if (epub is! EpubAnchor || at == null) return null;
    return DrawingRow(
      layerId: j['layerId'] as String,
      annotationId: j['annotationId'] as String,
      createdAt: at,
      anchor: TextAnchor.fromJson(anchor),
      range: epub,
      refPage: j['refPage'] as int,
      chapterIndex: j['chapterIndex'] as int,
      groupId: j['groupId'] as String,
      color: j['color'] as String,
      strokesB64: j['strokesB64'] as String,
      strokeCount: j['strokeCount'] as int,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is DrawingRow &&
      other.layerId == layerId &&
      other.annotationId == annotationId &&
      other.createdAt == createdAt &&
      other.anchor == anchor &&
      other.range == range &&
      other.refPage == refPage &&
      other.chapterIndex == chapterIndex &&
      other.groupId == groupId &&
      other.color == color &&
      other.strokesB64 == strokesB64 &&
      other.strokeCount == strokeCount;

  @override
  int get hashCode => Object.hash(
    layerId,
    annotationId,
    createdAt,
    anchor,
    range,
    refPage,
    chapterIndex,
    groupId,
    color,
    strokesB64,
    strokeCount,
  );
}

/// G18 (R10) — uma nota à mão pronta a gravar: a camada `space` ([layerId]: as linhas, recolhida, os traços em BNK1
/// na unidade da caixa) e a anotação `handwriting` ([annotationId]); as duas com a âncora vazia na costura (7 chaves),
/// a página, o capítulo e o grupo.
@immutable
final class NoteRow {
  NoteRow({
    required this.layerId,
    required this.annotationId,
    required DateTime createdAt,
    required this.anchor,
    required this.refPage,
    required this.chapterIndex,
    required this.groupId,
    required this.lines,
    required this.collapsed,
    required this.strokesB64,
    required this.strokeCount,
  }) : createdAt = createdAt.toUtc();

  final String layerId;
  final String annotationId;
  final DateTime createdAt;
  final EpubAnchor anchor;
  final int refPage;
  final int chapterIndex;
  final String groupId;
  final int lines;
  final bool collapsed;
  final String strokesB64;
  final int strokeCount;

  Map<String, Object?> toJson() => {
    'layerId': layerId,
    'annotationId': annotationId,
    'createdAt': createdAt.toIso8601String(),
    'anchor': anchor.toJson(),
    'refPage': refPage,
    'chapterIndex': chapterIndex,
    'groupId': groupId,
    'lines': lines,
    'collapsed': collapsed,
    'strokesB64': strokesB64,
    'strokeCount': strokeCount,
  };

  /// A linha do JSON [j]; `null` se faltar ou sobrar algo do tipo errado (ou as linhas fora de 1–12 — D-41).
  static NoteRow? tryFromJson(Object? j) {
    if (j is! Map<String, dynamic>) return null;
    final anchor = j['anchor'];
    final createdAt = j['createdAt'];
    final lines = j['lines'];
    if (j['layerId'] is! String ||
        j['annotationId'] is! String ||
        createdAt is! String ||
        anchor is! Map<String, dynamic> ||
        j['refPage'] is! int ||
        j['chapterIndex'] is! int ||
        j['groupId'] is! String ||
        lines is! int ||
        lines < 1 ||
        lines > 12 ||
        j['collapsed'] is! bool ||
        j['strokesB64'] is! String ||
        j['strokeCount'] is! int) {
      return null;
    }
    final epub = TextAnchor.fromJson(anchor);
    final at = DateTime.tryParse(createdAt);
    if (epub is! EpubAnchor || at == null) return null;
    return NoteRow(
      layerId: j['layerId'] as String,
      annotationId: j['annotationId'] as String,
      createdAt: at,
      anchor: epub,
      refPage: j['refPage'] as int,
      chapterIndex: j['chapterIndex'] as int,
      groupId: j['groupId'] as String,
      lines: lines,
      collapsed: j['collapsed'] as bool,
      strokesB64: j['strokesB64'] as String,
      strokeCount: j['strokeCount'] as int,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is NoteRow &&
      other.layerId == layerId &&
      other.annotationId == annotationId &&
      other.createdAt == createdAt &&
      other.anchor == anchor &&
      other.refPage == refPage &&
      other.chapterIndex == chapterIndex &&
      other.groupId == groupId &&
      other.lines == lines &&
      other.collapsed == collapsed &&
      other.strokesB64 == strokesB64 &&
      other.strokeCount == strokeCount;

  @override
  int get hashCode => Object.hash(
    layerId,
    annotationId,
    createdAt,
    anchor,
    refPage,
    chapterIndex,
    groupId,
    lines,
    collapsed,
    strokesB64,
    strokeCount,
  );
}

/// O enum de código [code] em [values]; `null` se não for um deles.
T? _byCode<T extends Enum>(
  List<T> values,
  Object? code,
  String Function(T) of,
) {
  for (final v in values) {
    if (of(v) == code) return v;
  }
  return null;
}

/// Um grifo novo do marca-texto (G17, R24): o traço que virou grifo, ou o pedaço da direita de um cortado pela D-32
/// (com a cor, o estilo, a altura, o grupo e a origem do cortado). A âncora de 7 chaves, a página e o capítulo do
/// começo, já calculados.
@immutable
final class HighlightRow {
  HighlightRow({
    required this.id,
    required DateTime createdAt,
    required this.range,
    required this.refPage,
    required this.chapterIndex,
    required this.groupId,
    required this.color,
    required this.style,
    required this.fillHeight,
    required this.source,
  }) : createdAt = createdAt.toUtc();

  final String id;
  final DateTime createdAt;
  final EpubAnchor range;
  final int refPage;
  final int chapterIndex;
  final String groupId;

  /// `#RRGGBB`.
  final String color;
  final HighlightStyle style;

  /// Só no fundo.
  final FillHeight? fillHeight;
  final AnnotationSource source;

  Map<String, Object?> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'range': range.toJson(),
    'refPage': refPage,
    'chapterIndex': chapterIndex,
    'groupId': groupId,
    'color': color,
    'style': style.code,
    'fillHeight': fillHeight?.code,
    'source': source.code,
  };

  /// A linha do JSON [j]; `null` se faltar ou sobrar algo do tipo errado.
  static HighlightRow? tryFromJson(Object? j) {
    if (j is! Map<String, dynamic>) return null;
    final range = j['range'];
    final createdAt = j['createdAt'];
    if (j['id'] is! String ||
        createdAt is! String ||
        range is! Map<String, dynamic> ||
        j['refPage'] is! int ||
        j['chapterIndex'] is! int ||
        j['groupId'] is! String ||
        j['color'] is! String) {
      return null;
    }
    final style = _byCode(HighlightStyle.values, j['style'], (v) => v.code);
    final height = _byCode(FillHeight.values, j['fillHeight'], (v) => v.code);
    final source = _byCode(AnnotationSource.values, j['source'], (v) => v.code);
    final epub = TextAnchor.fromJson(range);
    final at = DateTime.tryParse(createdAt);
    if (style == null ||
        (height == null && j['fillHeight'] != null) ||
        source == null ||
        epub is! EpubAnchor ||
        at == null) {
      return null;
    }
    return HighlightRow(
      id: j['id'] as String,
      createdAt: at,
      range: epub,
      refPage: j['refPage'] as int,
      chapterIndex: j['chapterIndex'] as int,
      groupId: j['groupId'] as String,
      color: j['color'] as String,
      style: style,
      fillHeight: height,
      source: source,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is HighlightRow &&
      other.id == id &&
      other.createdAt == createdAt &&
      other.range == range &&
      other.refPage == refPage &&
      other.chapterIndex == chapterIndex &&
      other.groupId == groupId &&
      other.color == color &&
      other.style == style &&
      other.fillHeight == fillHeight &&
      other.source == source;

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    range,
    refPage,
    chapterIndex,
    groupId,
    color,
    style,
    fillHeight,
    source,
  );
}

/// Um grifo salvo que a D-32 encolheu ou estendeu (G17): o lugar novo, a página e o capítulo do começo.
@immutable
final class MovedHighlight {
  const MovedHighlight({
    required this.id,
    required this.range,
    required this.refPage,
    required this.chapterIndex,
  });

  final String id;
  final EpubAnchor range;
  final int refPage;
  final int chapterIndex;

  Map<String, Object?> toJson() => {
    'id': id,
    'range': range.toJson(),
    'refPage': refPage,
    'chapterIndex': chapterIndex,
  };

  static MovedHighlight? tryFromJson(Object? j) {
    if (j is! Map<String, dynamic>) return null;
    final range = j['range'];
    if (j['id'] is! String ||
        range is! Map<String, dynamic> ||
        j['refPage'] is! int ||
        j['chapterIndex'] is! int) {
      return null;
    }
    final epub = TextAnchor.fromJson(range);
    if (epub is! EpubAnchor) return null;
    return MovedHighlight(
      id: j['id'] as String,
      range: epub,
      refPage: j['refPage'] as int,
      chapterIndex: j['chapterIndex'] as int,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is MovedHighlight &&
      other.id == id &&
      other.range == range &&
      other.refPage == refPage &&
      other.chapterIndex == chapterIndex;

  @override
  int get hashCode => Object.hash(id, range, refPage, chapterIndex);
}

/// O que o Concluir grava: os desenhos novos e mudados, as camadas apagadas (a anotação vai junto) e os grifos
/// apagados pela Borracha (as notas filhas vão junto). G17: os grifos novos do marca-texto, os salvos que a D-32
/// moveu e os que ela tirou, com o grifo para onde vão as notas de cada um (`null` = o destino foi apagado pela
/// Borracha: as notas vão junto — D-168).
@immutable
final class InkChanges {
  const InkChanges({
    this.layers = const [],
    this.deletedLayers = const {},
    this.erasedHighlights = const {},
    this.highlights = const [],
    this.moved = const [],
    this.removed = const {},
    this.notes = const [],
    this.deletedNotes = const {},
  });

  final List<DrawingRow> layers;

  /// G18: as notas à mão novas e mudadas, e as camadas `space` apagadas (as que ficaram sem traço também — D-188).
  final List<NoteRow> notes;
  final Set<String> deletedNotes;
  final Set<String> deletedLayers;
  final Set<String> erasedHighlights;
  final List<HighlightRow> highlights;
  final List<MovedHighlight> moved;
  final Map<String, String?> removed;

  bool get isEmpty =>
      layers.isEmpty &&
      deletedLayers.isEmpty &&
      erasedHighlights.isEmpty &&
      highlights.isEmpty &&
      moved.isEmpty &&
      removed.isEmpty &&
      notes.isEmpty &&
      deletedNotes.isEmpty;

  @override
  bool operator ==(Object other) =>
      other is InkChanges &&
      listEquals(other.layers, layers) &&
      setEquals(other.deletedLayers, deletedLayers) &&
      setEquals(other.erasedHighlights, erasedHighlights) &&
      listEquals(other.highlights, highlights) &&
      listEquals(other.moved, moved) &&
      mapEquals(other.removed, removed) &&
      listEquals(other.notes, notes) &&
      setEquals(other.deletedNotes, deletedNotes);

  @override
  int get hashCode => Object.hash(
    Object.hashAll(layers),
    Object.hashAllUnordered(deletedLayers),
    Object.hashAllUnordered(erasedHighlights),
    Object.hashAll(highlights),
    Object.hashAll(moved),
    Object.hashAllUnordered(
      removed.entries.map((e) => Object.hash(e.key, e.value)),
    ),
    Object.hashAll(notes),
    Object.hashAllUnordered(deletedNotes),
  );
}

/// O rascunho: as mudanças e a hora em que foi guardado.
typedef InkDraft = ({InkChanges changes, DateTime at});

/// O JSON do rascunho das mudanças [c], guardado em [at] (formato 3).
String encodeDraft(InkChanges c, {required DateTime at}) => jsonEncode({
  'v': inkDraftVersion,
  'at': at.toUtc().toIso8601String(),
  'layers': [for (final l in c.layers) l.toJson()],
  'deletedLayers': c.deletedLayers.toList(),
  'erasedHighlights': c.erasedHighlights.toList(),
  'highlights': [for (final h in c.highlights) h.toJson()],
  'moved': [for (final m in c.moved) m.toJson()],
  'removed': c.removed,
  'notes': [for (final n in c.notes) n.toJson()],
  'deletedNotes': c.deletedNotes.toList(),
});

/// O rascunho do JSON [json] (formato 1 da G16, 2 da G17 ou 3); `null` com versão desconhecida, JSON quebrado ou
/// campos errados.
InkDraft? decodeDraft(String json) {
  final Object? j;
  try {
    j = jsonDecode(json);
  } on FormatException {
    return null;
  }
  if (j is! Map<String, dynamic>) return null;
  final v = j['v'];
  if (v != 1 && v != 2 && v != inkDraftVersion) return null;
  final at = j['at'] is String ? DateTime.tryParse(j['at'] as String) : null;
  final layers = j['layers'];
  final deleted = j['deletedLayers'];
  final erased = j['erasedHighlights'];
  // o formato 1 não tem os grifos do marca-texto
  final highlights = v == 1 ? const <Object?>[] : j['highlights'];
  final moved = v == 1 ? const <Object?>[] : j['moved'];
  final removed = v == 1 ? const <String, dynamic>{} : j['removed'];
  // os formatos 1 e 2 não têm as notas à mão
  final notes = v != inkDraftVersion ? const <Object?>[] : j['notes'];
  final deletedNotes = v != inkDraftVersion
      ? const <Object?>[]
      : j['deletedNotes'];
  if (at == null ||
      layers is! List ||
      deleted is! List ||
      erased is! List ||
      highlights is! List ||
      moved is! List ||
      removed is! Map<String, dynamic> ||
      notes is! List ||
      deletedNotes is! List ||
      deletedNotes.any((e) => e is! String) ||
      deleted.any((e) => e is! String) ||
      erased.any((e) => e is! String) ||
      removed.values.any((e) => e != null && e is! String)) {
    return null;
  }
  final rows = <DrawingRow>[];
  for (final l in layers) {
    final row = DrawingRow.tryFromJson(l);
    if (row == null) return null;
    rows.add(row);
  }
  final marks = <HighlightRow>[];
  for (final h in highlights) {
    final row = HighlightRow.tryFromJson(h);
    if (row == null) return null;
    marks.add(row);
  }
  final moves = <MovedHighlight>[];
  for (final m in moved) {
    final row = MovedHighlight.tryFromJson(m);
    if (row == null) return null;
    moves.add(row);
  }
  final noteRows = <NoteRow>[];
  for (final n in notes) {
    final row = NoteRow.tryFromJson(n);
    if (row == null) return null;
    noteRows.add(row);
  }
  return (
    changes: InkChanges(
      layers: List.unmodifiable(rows),
      deletedLayers: Set.unmodifiable(deleted.cast<String>()),
      erasedHighlights: Set.unmodifiable(erased.cast<String>()),
      highlights: List.unmodifiable(marks),
      moved: List.unmodifiable(moves),
      removed: Map.unmodifiable(removed.cast<String, String?>()),
      notes: List.unmodifiable(noteRows),
      deletedNotes: Set.unmodifiable(deletedNotes.cast<String>()),
    ),
    at: at.toUtc(),
  );
}

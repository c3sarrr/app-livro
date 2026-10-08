// G16.4 — o que o Concluir grava (§4) e o rascunho em JSON no `kv`, na chave `ink_draft:<dono>:<user_book_id>`.
// As linhas já vão com a âncora, a página, o capítulo e o grupo calculados: gravar o rascunho não precisa da página
// aberta (D-166). Versão desconhecida ou JSON quebrado viram `null`: o rascunho nunca derruba a abertura do livro.
import 'dart:convert';

import 'package:flutter/foundation.dart' show immutable, listEquals, setEquals;

import '../../domain/locator.dart';

/// A versão do formato do rascunho.
const int inkDraftVersion = 1;

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

/// O que o Concluir grava: os desenhos novos e mudados, as camadas apagadas (a anotação vai junto) e os grifos
/// apagados pela Borracha (as notas filhas vão junto).
@immutable
final class InkChanges {
  const InkChanges({
    this.layers = const [],
    this.deletedLayers = const {},
    this.erasedHighlights = const {},
  });

  final List<DrawingRow> layers;
  final Set<String> deletedLayers;
  final Set<String> erasedHighlights;

  bool get isEmpty =>
      layers.isEmpty && deletedLayers.isEmpty && erasedHighlights.isEmpty;

  @override
  bool operator ==(Object other) =>
      other is InkChanges &&
      listEquals(other.layers, layers) &&
      setEquals(other.deletedLayers, deletedLayers) &&
      setEquals(other.erasedHighlights, erasedHighlights);

  @override
  int get hashCode => Object.hash(
    Object.hashAll(layers),
    Object.hashAllUnordered(deletedLayers),
    Object.hashAllUnordered(erasedHighlights),
  );
}

/// O rascunho: as mudanças e a hora em que foi guardado.
typedef InkDraft = ({InkChanges changes, DateTime at});

/// O JSON do rascunho das mudanças [c], guardado em [at].
String encodeDraft(InkChanges c, {required DateTime at}) => jsonEncode({
  'v': inkDraftVersion,
  'at': at.toUtc().toIso8601String(),
  'layers': [for (final l in c.layers) l.toJson()],
  'deletedLayers': c.deletedLayers.toList(),
  'erasedHighlights': c.erasedHighlights.toList(),
});

/// O rascunho do JSON [json]; `null` com versão desconhecida, JSON quebrado ou campos errados.
InkDraft? decodeDraft(String json) {
  final Object? j;
  try {
    j = jsonDecode(json);
  } on FormatException {
    return null;
  }
  if (j is! Map<String, dynamic> || j['v'] != inkDraftVersion) return null;
  final at = j['at'] is String ? DateTime.tryParse(j['at'] as String) : null;
  final layers = j['layers'];
  final deleted = j['deletedLayers'];
  final erased = j['erasedHighlights'];
  if (at == null ||
      layers is! List ||
      deleted is! List ||
      erased is! List ||
      deleted.any((e) => e is! String) ||
      erased.any((e) => e is! String)) {
    return null;
  }
  final rows = <DrawingRow>[];
  for (final l in layers) {
    final row = DrawingRow.tryFromJson(l);
    if (row == null) return null;
    rows.add(row);
  }
  return (
    changes: InkChanges(
      layers: List.unmodifiable(rows),
      deletedLayers: Set.unmodifiable(deleted.cast<String>()),
      erasedHighlights: Set.unmodifiable(erased.cast<String>()),
    ),
    at: at.toUtc(),
  );
}

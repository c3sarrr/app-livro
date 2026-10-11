import 'package:flutter/foundation.dart' show immutable;

import '../../../../core/data/model/checks.dart';
import '../../../../core/data/model/nullable.dart';
import '../../../../core/data/model/record_meta.dart';
import '../../domain/locator.dart';

/// Tipo do item da tela 25 (cada um conta 1 no "Tudo 12").
enum AnnotationKind implements DbCode {
  highlight('highlight'),
  note('note'),
  handwriting('handwriting'),
  drawing('drawing');

  const AnnotationKind(this.code);

  @override
  final String code;

  static AnnotationKind fromCode(String code) => Check.byCode(values, code);
}

/// Como o grifo nasceu: seleção de texto (tela 21) ou traço de tinta convertido (23b).
enum AnnotationSource implements DbCode {
  selection('selection'),
  ink('ink');

  const AnnotationSource(this.code);

  @override
  final String code;

  static AnnotationSource fromCode(String code) => Check.byCode(values, code);
}

/// Estilo do grifo (tela 23b: Fundo · Sublinhado · Ondulado).
enum HighlightStyle implements DbCode {
  fill('fill'),
  underline('underline'),
  wavy('wavy');

  const HighlightStyle(this.code);

  @override
  final String code;

  static HighlightStyle fromCode(String code) => Check.byCode(values, code);
}

/// Altura do fundo do grifo (tela 23b: Baixa · Média · Alta).
enum FillHeight implements DbCode {
  low('low'),
  medium('medium'),
  high('high');

  const FillHeight(this.code);

  @override
  final String code;

  static FillHeight fromCode(String code) => Check.byCode(values, code);
}

/// Grifo, nota, nota à mão ou desenho (`personal.annotations`, Anexo 02 §4.1).
/// Um cartão da tela 25 = um `groupId` (regra de agrupamento: Anexo 02 §4.3).
@immutable
final class Annotation {
  Annotation({
    required String id,
    required this.meta,
    required String userBookId,
    required this.kind,
    String? parentId,
    required String groupId,
    this.source = AnnotationSource.selection,
    required this.anchor,
    required int refPage,
    required int chapterIndex,
    String? color,
    this.style,
    this.fillHeight,
    String? noteText,
    String? inkLayerId,
    String? sharedClubPostId,
  }) : id = Check.uuid(id, 'id'),
       userBookId = Check.uuid(userBookId, 'userBookId'),
       parentId = Check.uuidOrNull(parentId, 'parentId'),
       groupId = Check.uuid(groupId, 'groupId'),
       refPage = Check.range(refPage, 1, 2147483647, 'refPage'),
       chapterIndex = Check.range(chapterIndex, 0, 2147483647, 'chapterIndex'),
       color = Check.hexColorOrNull(color, 'color'),
       noteText = Check.textOrNull(noteText, max: 10000, name: 'noteText'),
       inkLayerId = Check.uuidOrNull(inkLayerId, 'inkLayerId'),
       sharedClubPostId = Check.uuidOrNull(
         sharedClubPostId,
         'sharedClubPostId',
       ) {
    // Os três CHECKs de linha do SQL.
    if ((kind == AnnotationKind.note) != (noteText != null)) {
      throw ArgumentError.value(
        noteText,
        'noteText',
        'só (e toda) nota tem texto',
      );
    }
    if ((kind == AnnotationKind.handwriting ||
            kind == AnnotationKind.drawing) &&
        inkLayerId == null) {
      throw ArgumentError.value(
        inkLayerId,
        'inkLayerId',
        'tinta exige a camada',
      );
    }
    if (kind == AnnotationKind.highlight && (color == null || style == null)) {
      throw ArgumentError.value(kind, 'kind', 'grifo exige cor e estilo');
    }
  }

  final String id;
  final RecordMeta meta;
  final String userBookId;
  final AnnotationKind kind;

  /// Nota de texto → o grifo a que ela pertence.
  final String? parentId;
  final String groupId;
  final AnnotationSource source;
  final TextAnchor anchor;
  final int refPage;
  final int chapterIndex;

  /// Cor do grifo ou da tinta (#RRGGBB).
  final String? color;
  final HighlightStyle? style;
  final FillHeight? fillHeight;
  final String? noteText;
  final String? inkLayerId;

  /// Compartilhado no clube (chip "Leitoras de Capitu · 3 respostas").
  final String? sharedClubPostId;

  Annotation copyWith({
    RecordMeta? meta,
    AnnotationKind? kind,
    Nullable<String>? parentId,
    String? groupId,
    AnnotationSource? source,
    TextAnchor? anchor,
    int? refPage,
    int? chapterIndex,
    Nullable<String>? color,
    Nullable<HighlightStyle>? style,
    Nullable<FillHeight>? fillHeight,
    Nullable<String>? noteText,
    Nullable<String>? inkLayerId,
    Nullable<String>? sharedClubPostId,
  }) => Annotation(
    id: id,
    meta: meta ?? this.meta,
    userBookId: userBookId,
    kind: kind ?? this.kind,
    parentId: parentId == null ? this.parentId : parentId.value,
    groupId: groupId ?? this.groupId,
    source: source ?? this.source,
    anchor: anchor ?? this.anchor,
    refPage: refPage ?? this.refPage,
    chapterIndex: chapterIndex ?? this.chapterIndex,
    color: color == null ? this.color : color.value,
    style: style == null ? this.style : style.value,
    fillHeight: fillHeight == null ? this.fillHeight : fillHeight.value,
    noteText: noteText == null ? this.noteText : noteText.value,
    inkLayerId: inkLayerId == null ? this.inkLayerId : inkLayerId.value,
    sharedClubPostId: sharedClubPostId == null
        ? this.sharedClubPostId
        : sharedClubPostId.value,
  );

  @override
  bool operator ==(Object other) =>
      other is Annotation &&
      other.id == id &&
      other.meta == meta &&
      other.userBookId == userBookId &&
      other.kind == kind &&
      other.parentId == parentId &&
      other.groupId == groupId &&
      other.source == source &&
      other.anchor == anchor &&
      other.refPage == refPage &&
      other.chapterIndex == chapterIndex &&
      other.color == color &&
      other.style == style &&
      other.fillHeight == fillHeight &&
      other.noteText == noteText &&
      other.inkLayerId == inkLayerId &&
      other.sharedClubPostId == sharedClubPostId;

  @override
  int get hashCode => Object.hash(
    id,
    meta,
    userBookId,
    kind,
    parentId,
    groupId,
    source,
    anchor,
    refPage,
    chapterIndex,
    color,
    style,
    fillHeight,
    noteText,
    inkLayerId,
    sharedClubPostId,
  );
}

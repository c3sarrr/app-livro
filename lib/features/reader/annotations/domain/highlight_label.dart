import 'package:flutter/foundation.dart' show immutable;

import '../../../../core/data/model/checks.dart';
import '../../../../core/data/model/record_meta.dart';

/// Rótulo de uma cor do marca-texto ("lindo", "personagem", "ideia", "pro clube") — global do
/// usuário (`personal.highlight_labels`, D-40).
@immutable
final class HighlightLabel {
  HighlightLabel({
    required String id,
    required this.meta,
    required String color,
    required String label,
    int sort = 0,
  }) : id = Check.uuid(id, 'id'),
       color = Check.hexColor(color, 'color'),
       label = Check.text(label, min: 1, max: 24, name: 'label'),
       sort = Check.range(sort, -32768, 32767, 'sort');

  final String id;
  final RecordMeta meta;
  final String color;
  final String label;
  final int sort;

  HighlightLabel copyWith({
    RecordMeta? meta,
    String? color,
    String? label,
    int? sort,
  }) => HighlightLabel(
    id: id,
    meta: meta ?? this.meta,
    color: color ?? this.color,
    label: label ?? this.label,
    sort: sort ?? this.sort,
  );

  @override
  bool operator ==(Object other) =>
      other is HighlightLabel &&
      other.id == id &&
      other.meta == meta &&
      other.color == color &&
      other.label == label &&
      other.sort == sort;

  @override
  int get hashCode => Object.hash(id, meta, color, label, sort);
}

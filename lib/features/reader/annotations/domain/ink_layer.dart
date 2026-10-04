import 'package:flutter/foundation.dart' show immutable;

import '../../../../core/data/model/checks.dart';
import '../../../../core/data/model/record_meta.dart';
import '../../domain/locator.dart';

/// Traços sobre o texto (ancorados em palavras) ou dentro de um espaço aberto entre linhas.
enum InkLayerKind implements DbCode {
  overText('over_text'),
  space('space');

  const InkLayerKind(this.code);

  @override
  final String code;

  static InkLayerKind fromCode(String code) => Check.byCode(values, code);
}

/// Camada de tinta (`personal.ink_layers`); traços no codec BNK1 em base64 (Anexo 03 §9.6).
@immutable
final class InkLayer {
  InkLayer({
    required String id,
    required this.meta,
    required String userBookId,
    required this.kind,
    required this.anchor,
    int? spaceLines,
    this.collapsed = false,
    required String strokesB64,
    required int strokeCount,
    int codecVersion = 1,
  }) : id = Check.uuid(id, 'id'),
       userBookId = Check.uuid(userBookId, 'userBookId'),
       spaceLines = Check.rangeOrNull(spaceLines, 1, 12, 'spaceLines'),
       strokesB64 = _strokes(strokesB64),
       strokeCount = Check.range(strokeCount, 0, 2147483647, 'strokeCount'),
       codecVersion = Check.range(codecVersion, -32768, 32767, 'codecVersion') {
    if ((kind == InkLayerKind.space) != (spaceLines != null)) {
      throw ArgumentError.value(
        spaceLines,
        'spaceLines',
        'só (e todo) espaço tem linhas',
      );
    }
  }

  /// ≈ 256 KiB binários (CHECK `octet_length(strokes_b64) <= 349528`; base64 é ASCII).
  static const int maxStrokesB64 = 349528;

  static String _strokes(String b64) {
    if (b64.length > maxStrokesB64) {
      throw ArgumentError.value(
        b64.length,
        'strokesB64',
        'acima de $maxStrokesB64 bytes',
      );
    }
    return b64;
  }

  final String id;
  final RecordMeta meta;
  final String userBookId;
  final InkLayerKind kind;
  final TextAnchor anchor;

  /// Altura do espaço aberto em linhas inteiras (D-41: 1–12).
  final int? spaceLines;

  /// Nota à mão recolhida (botão ˄ da tela 24b).
  final bool collapsed;
  final String strokesB64;
  final int strokeCount;
  final int codecVersion;

  InkLayer copyWith({
    RecordMeta? meta,
    TextAnchor? anchor,
    int? spaceLines,
    bool? collapsed,
    String? strokesB64,
    int? strokeCount,
    int? codecVersion,
  }) => InkLayer(
    id: id,
    meta: meta ?? this.meta,
    userBookId: userBookId,
    kind: kind,
    anchor: anchor ?? this.anchor,
    spaceLines: spaceLines ?? this.spaceLines,
    collapsed: collapsed ?? this.collapsed,
    strokesB64: strokesB64 ?? this.strokesB64,
    strokeCount: strokeCount ?? this.strokeCount,
    codecVersion: codecVersion ?? this.codecVersion,
  );

  @override
  bool operator ==(Object other) =>
      other is InkLayer &&
      other.id == id &&
      other.meta == meta &&
      other.userBookId == userBookId &&
      other.kind == kind &&
      other.anchor == anchor &&
      other.spaceLines == spaceLines &&
      other.collapsed == collapsed &&
      other.strokesB64 == strokesB64 &&
      other.strokeCount == strokeCount &&
      other.codecVersion == codecVersion;

  @override
  int get hashCode => Object.hash(
    id,
    meta,
    userBookId,
    kind,
    anchor,
    spaceLines,
    collapsed,
    strokesB64,
    strokeCount,
    codecVersion,
  );
}

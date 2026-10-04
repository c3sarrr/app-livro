import 'package:flutter/foundation.dart' show immutable;

import '../../../core/data/model/checks.dart';
import '../../../core/data/model/record_meta.dart';

/// Fonte do corpo do livro (tela 26).
enum ReaderFontFamily implements DbCode {
  literata('literata'),
  lora('lora'),
  figtree('figtree'),
  atkinson('atkinson');

  const ReaderFontFamily(this.code);

  @override
  final String code;

  static ReaderFontFamily fromCode(String code) => Check.byCode(values, code);
}

/// Papel (tema) do leitor — Sépia = #EEDDBF (D-51 b).
enum ReaderPaper implements DbCode {
  creme('creme'),
  branco('branco'),
  sepia('sepia'),
  noite('noite');

  const ReaderPaper(this.code);

  @override
  final String code;

  static ReaderPaper fromCode(String code) => Check.byCode(values, code);
}

enum ReaderLineSpacing implements DbCode {
  justo('justo'),
  medio('medio'),
  solto('solto');

  const ReaderLineSpacing(this.code);

  @override
  final String code;

  static ReaderLineSpacing fromCode(String code) => Check.byCode(values, code);
}

enum ReaderMargins implements DbCode {
  estreita('estreita'),
  media('media'),
  larga('larga');

  const ReaderMargins(this.code);

  @override
  final String code;

  static ReaderMargins fromCode(String code) => Check.byCode(values, code);
}

/// Ajustes de leitura — 1 linha por usuário (`personal.reader_settings`, id = user_id).
/// Padrões = estado da tela 26 (e do SQL). Valores numéricos dos passos: D-20.
@immutable
final class ReaderSettings {
  ReaderSettings({
    required String id,
    required this.meta,
    int fontStep = 4,
    this.fontFamily = ReaderFontFamily.literata,
    this.paper = ReaderPaper.creme,
    this.lineSpacing = ReaderLineSpacing.medio,
    this.margins = ReaderMargins.media,
  }) : id = _sameAsOwner(id, meta),
       fontStep = Check.range(fontStep, 1, 7, 'fontStep');

  static String _sameAsOwner(String id, RecordMeta meta) {
    if (id != meta.userId) throw ArgumentError.value(id, 'id', 'id = user_id');
    return id;
  }

  final String id;
  final RecordMeta meta;

  /// Ponto ativo dos 7 do controle de tamanho.
  final int fontStep;
  final ReaderFontFamily fontFamily;
  final ReaderPaper paper;
  final ReaderLineSpacing lineSpacing;
  final ReaderMargins margins;

  ReaderSettings copyWith({
    RecordMeta? meta,
    int? fontStep,
    ReaderFontFamily? fontFamily,
    ReaderPaper? paper,
    ReaderLineSpacing? lineSpacing,
    ReaderMargins? margins,
  }) => ReaderSettings(
    id: id,
    meta: meta ?? this.meta,
    fontStep: fontStep ?? this.fontStep,
    fontFamily: fontFamily ?? this.fontFamily,
    paper: paper ?? this.paper,
    lineSpacing: lineSpacing ?? this.lineSpacing,
    margins: margins ?? this.margins,
  );

  @override
  bool operator ==(Object other) =>
      other is ReaderSettings &&
      other.id == id &&
      other.meta == meta &&
      other.fontStep == fontStep &&
      other.fontFamily == fontFamily &&
      other.paper == paper &&
      other.lineSpacing == lineSpacing &&
      other.margins == margins;

  @override
  int get hashCode =>
      Object.hash(id, meta, fontStep, fontFamily, paper, lineSpacing, margins);
}

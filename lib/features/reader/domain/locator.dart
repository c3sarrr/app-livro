// Localizador (posição) e âncora (intervalo) do Anexo 03 §5 — guardados como jsonb/TEXT.
// Inspirados nos seletores do W3C Web Annotation (`TextPositionSelector` + `TextQuoteSelector`).
// Formato que este app não conhece (PDF, versão futura vinda de outro aparelho) vira `Raw*` e é
// preservado sem perda — ler do banco nunca lança exceção nem descarta campos.
import 'package:flutter/foundation.dart' show immutable;

import '../../../core/data/model/checks.dart';
import '../../../core/data/model/json_value.dart';

/// Trecho citado em volta da posição (para reancorar em outra edição — Anexo 03 §5.3).
@immutable
final class TextQuote {
  const TextQuote({this.prefix = '', required this.exact, this.suffix = ''});

  final String prefix;
  final String exact;
  final String suffix;

  Map<String, Object?> toJson() => {
    'prefix': prefix,
    'exact': exact,
    'suffix': suffix,
  };

  static TextQuote? _tryFromJson(Object? json) {
    if (json is! Map ||
        json.length != 3 ||
        json['prefix'] is! String ||
        json['exact'] is! String ||
        json['suffix'] is! String) {
      return null;
    }
    return TextQuote(
      prefix: json['prefix'] as String,
      exact: json['exact'] as String,
      suffix: json['suffix'] as String,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is TextQuote &&
      other.prefix == prefix &&
      other.exact == exact &&
      other.suffix == suffix;

  @override
  int get hashCode => Object.hash(prefix, exact, suffix);
}

/// Posição de leitura (`reading_positions.locator`, `bookmarks.locator`).
@immutable
sealed class Locator {
  const Locator();

  factory Locator.fromJson(Map<String, Object?> json) =>
      EpubLocator._tryFromJson(json) ?? RawLocator(json);

  Map<String, Object?> toJson();
}

/// Posição num EPUB: item do *spine* + deslocamento em caracteres do conteúdo canônico.
final class EpubLocator extends Locator {
  EpubLocator({
    required String sha,
    required int spine,
    required int offset,
    this.quote,
    required int refPage,
    required double progression,
  }) : sha = _sha(sha),
       spine = Check.range(spine, 0, _maxInt, 'spine'),
       offset = Check.range(offset, 0, _maxInt, 'offset'),
       refPage = Check.range(refPage, 1, _maxInt, 'refPage'),
       progression = _progression(progression);

  static const _keys = {
    'v',
    'sha',
    'spine',
    'offset',
    'quote',
    'refPage',
    'progression',
  };

  static EpubLocator? _tryFromJson(Map<String, Object?> j) {
    if (j['v'] != 1 ||
        !_keys.containsAll(j.keys) ||
        j['sha'] is! String ||
        j['spine'] is! int ||
        j['offset'] is! int ||
        j['refPage'] is! int ||
        j['progression'] is! num) {
      return null;
    }
    final quote = TextQuote._tryFromJson(j['quote']);
    if (j.containsKey('quote') && quote == null) return null;
    try {
      return EpubLocator(
        sha: j['sha'] as String,
        spine: j['spine'] as int,
        offset: j['offset'] as int,
        quote: quote,
        refPage: j['refPage'] as int,
        progression: (j['progression'] as num).toDouble(),
      );
    } on ArgumentError {
      return null;
    }
  }

  final String sha;
  final int spine;
  final int offset;
  final TextQuote? quote;
  final int refPage;
  final double progression;

  @override
  Map<String, Object?> toJson() => {
    'v': 1,
    'sha': sha,
    'spine': spine,
    'offset': offset,
    if (quote != null) 'quote': quote!.toJson(),
    'refPage': refPage,
    'progression': progression,
  };

  @override
  bool operator ==(Object other) =>
      other is EpubLocator &&
      other.sha == sha &&
      other.spine == spine &&
      other.offset == offset &&
      other.quote == quote &&
      other.refPage == refPage &&
      other.progression == progression;

  @override
  int get hashCode =>
      Object.hash(sha, spine, offset, quote, refPage, progression);
}

/// Localizador em formato não reconhecido — guardado como veio.
final class RawLocator extends Locator {
  RawLocator(Map<String, Object?> json) : json = Map.unmodifiable(json);

  final Map<String, Object?> json;

  @override
  Map<String, Object?> toJson() => json;

  @override
  bool operator ==(Object other) =>
      other is RawLocator && jsonEquals(other.json, json);

  @override
  int get hashCode => jsonHash(json);
}

/// Intervalo de texto de uma anotação ou camada de tinta (`annotations.anchor`, `ink_layers.anchor`).
@immutable
sealed class TextAnchor {
  const TextAnchor();

  factory TextAnchor.fromJson(Map<String, Object?> json) =>
      EpubAnchor._tryFromJson(json) ?? RawAnchor(json);

  Map<String, Object?> toJson();
}

final class EpubAnchor extends TextAnchor {
  EpubAnchor({
    required String sha,
    required int spine,
    required int start,
    required int end,
    required this.quote,
    required int refPage,
  }) : sha = _sha(sha),
       spine = Check.range(spine, 0, _maxInt, 'spine'),
       start = Check.range(start, 0, _maxInt, 'start'),
       end = Check.range(end, start, _maxInt, 'end'),
       refPage = Check.range(refPage, 1, _maxInt, 'refPage');

  static const _keys = {
    'v',
    'sha',
    'spine',
    'start',
    'end',
    'quote',
    'refPage',
  };

  static EpubAnchor? _tryFromJson(Map<String, Object?> j) {
    final quote = TextQuote._tryFromJson(j['quote']);
    if (j['v'] != 1 ||
        j.length != _keys.length ||
        !_keys.containsAll(j.keys) ||
        j['sha'] is! String ||
        j['spine'] is! int ||
        j['start'] is! int ||
        j['end'] is! int ||
        j['refPage'] is! int ||
        quote == null) {
      return null;
    }
    try {
      return EpubAnchor(
        sha: j['sha'] as String,
        spine: j['spine'] as int,
        start: j['start'] as int,
        end: j['end'] as int,
        quote: quote,
        refPage: j['refPage'] as int,
      );
    } on ArgumentError {
      return null;
    }
  }

  final String sha;
  final int spine;
  final int start;
  final int end;
  final TextQuote quote;
  final int refPage;

  @override
  Map<String, Object?> toJson() => {
    'v': 1,
    'sha': sha,
    'spine': spine,
    'start': start,
    'end': end,
    'quote': quote.toJson(),
    'refPage': refPage,
  };

  @override
  bool operator ==(Object other) =>
      other is EpubAnchor &&
      other.sha == sha &&
      other.spine == spine &&
      other.start == start &&
      other.end == end &&
      other.quote == quote &&
      other.refPage == refPage;

  @override
  int get hashCode => Object.hash(sha, spine, start, end, quote, refPage);
}

/// Âncora em formato não reconhecido (ex.: PDF `{"page", "quads"}`) — guardada como veio.
final class RawAnchor extends TextAnchor {
  RawAnchor(Map<String, Object?> json) : json = Map.unmodifiable(json);

  final Map<String, Object?> json;

  @override
  Map<String, Object?> toJson() => json;

  @override
  bool operator ==(Object other) =>
      other is RawAnchor && jsonEquals(other.json, json);

  @override
  int get hashCode => jsonHash(json);
}

const int _maxInt = 2147483647;

String _sha(String sha) => Check.sha256OrNull(sha, 'sha')!;

double _progression(double p) {
  if (p.isNaN || p < 0 || p > 1) {
    throw ArgumentError.value(p, 'progression', 'fora de 0…1');
  }
  return p;
}

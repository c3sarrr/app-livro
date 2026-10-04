import 'package:flutter/foundation.dart' show immutable, listEquals;

import '../../../../core/data/model/checks.dart';
import '../../../../core/data/model/record_meta.dart';
import 'annotation.dart';

/// Tipo de ponta da caneta (tela 23: Esferográfica · Tinteiro · Pincel).
enum PenTip implements DbCode {
  ballpoint('ballpoint'),
  fountain('fountain'),
  brush('brush');

  const PenTip(this.code);

  @override
  final String code;

  static PenTip fromCode(String code) => Check.byCode(values, code);
}

/// Espessura da ilha de anotação (tela 22: Fina · Média · Grossa).
enum StrokeSize implements DbCode {
  thin('thin'),
  medium('medium'),
  thick('thick');

  const StrokeSize(this.code);

  @override
  final String code;

  static StrokeSize fromCode(String code) => Check.byCode(values, code);
}

/// Predefinições da caneta e do marca-texto — 1 linha por usuário (`personal.pen_presets`).
/// Padrões = estado das telas 22/23/23b (e do SQL).
@immutable
final class PenPresets {
  PenPresets({
    required String id,
    required this.meta,
    this.penTip = PenTip.ballpoint,
    double penWidthMm = 1.2,
    String penColor = '#FF552E',
    List<String> favoriteColors = defaultFavoriteColors,
    this.strokeSize = StrokeSize.medium,
    this.highlighterStyle = HighlightStyle.fill,
    this.highlighterHeight = FillHeight.medium,
    String highlighterColor = '#FED170',
  }) : id = _sameAsOwner(id, meta),
       penWidthMm = _width(penWidthMm),
       penColor = Check.hexColor(penColor, 'penColor'),
       favoriteColors = _favorites(favoriteColors),
       highlighterColor = Check.hexColor(highlighterColor, 'highlighterColor');

  /// Coral · Roxo · Azul · Verde · Dourado · Tinta preta (tela 23).
  static const List<String> defaultFavoriteColors = [
    '#FF552E',
    '#552CB7',
    '#058CD7',
    '#00995E',
    '#F2A815',
    '#1A1714',
  ];

  static String _sameAsOwner(String id, RecordMeta meta) {
    if (id != meta.userId) throw ArgumentError.value(id, 'id', 'id = user_id');
    return id;
  }

  /// `numeric(3,1)` entre 0,3 e 4,0 (slider do arquivo).
  static double _width(double mm) {
    final tenths = mm * 10;
    if (mm < 0.3 ||
        mm > 4.0 ||
        (tenths - tenths.roundToDouble()).abs() > 1e-9) {
      throw ArgumentError.value(mm, 'penWidthMm', '0,3…4,0 com 1 casa');
    }
    return mm;
  }

  /// O SQL só limita o tamanho (`jsonb` array com até 12 itens): o formato de cada cor é regra da
  /// interface (tela 23), não do dado — senão uma linha válida no servidor quebraria a leitura aqui.
  static List<String> _favorites(List<String> colors) {
    if (colors.length > 12) {
      throw ArgumentError.value(
        colors.length,
        'favoriteColors',
        'no máximo 12',
      );
    }
    return List.unmodifiable(colors);
  }

  final String id;
  final RecordMeta meta;
  final PenTip penTip;
  final double penWidthMm;
  final String penColor;
  final List<String> favoriteColors;
  final StrokeSize strokeSize;
  final HighlightStyle highlighterStyle;
  final FillHeight highlighterHeight;
  final String highlighterColor;

  PenPresets copyWith({
    RecordMeta? meta,
    PenTip? penTip,
    double? penWidthMm,
    String? penColor,
    List<String>? favoriteColors,
    StrokeSize? strokeSize,
    HighlightStyle? highlighterStyle,
    FillHeight? highlighterHeight,
    String? highlighterColor,
  }) => PenPresets(
    id: id,
    meta: meta ?? this.meta,
    penTip: penTip ?? this.penTip,
    penWidthMm: penWidthMm ?? this.penWidthMm,
    penColor: penColor ?? this.penColor,
    favoriteColors: favoriteColors ?? this.favoriteColors,
    strokeSize: strokeSize ?? this.strokeSize,
    highlighterStyle: highlighterStyle ?? this.highlighterStyle,
    highlighterHeight: highlighterHeight ?? this.highlighterHeight,
    highlighterColor: highlighterColor ?? this.highlighterColor,
  );

  @override
  bool operator ==(Object other) =>
      other is PenPresets &&
      other.id == id &&
      other.meta == meta &&
      other.penTip == penTip &&
      other.penWidthMm == penWidthMm &&
      other.penColor == penColor &&
      listEquals(other.favoriteColors, favoriteColors) &&
      other.strokeSize == strokeSize &&
      other.highlighterStyle == highlighterStyle &&
      other.highlighterHeight == highlighterHeight &&
      other.highlighterColor == highlighterColor;

  @override
  int get hashCode => Object.hash(
    id,
    meta,
    penTip,
    penWidthMm,
    penColor,
    Object.hashAll(favoriteColors),
    strokeSize,
    highlighterStyle,
    highlighterHeight,
    highlighterColor,
  );
}

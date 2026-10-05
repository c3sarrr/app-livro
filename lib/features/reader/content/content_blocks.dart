// G09.1 — blocos do conteúdo de um item do spine (Anexo 03 §4). O texto de cada bloco, em NFC, é o pedaço
// dele no texto canônico (D-93); imagem e quebra de cena ocupam 1 caractere (U+FFFC).

/// Caractere de objeto (imagem, quebra de cena) no texto canônico.
const String objectChar = '\uFFFC';

/// Quebra de linha dentro do bloco (`<br>`).
const String lineBreakChar = '\u2028';

/// Estilo de um trecho de texto.
final class RunStyle {
  const RunStyle({
    this.italic = false,
    this.bold = false,
    this.smallCaps = false,
    this.superscript = false,
    this.subscript = false,
  });

  static const RunStyle plain = RunStyle();

  final bool italic;
  final bool bold;
  final bool smallCaps;
  final bool superscript;
  final bool subscript;

  RunStyle copyWith({
    bool? italic,
    bool? bold,
    bool? smallCaps,
    bool? superscript,
    bool? subscript,
  }) => RunStyle(
    italic: italic ?? this.italic,
    bold: bold ?? this.bold,
    smallCaps: smallCaps ?? this.smallCaps,
    superscript: superscript ?? this.superscript,
    subscript: subscript ?? this.subscript,
  );

  @override
  bool operator ==(Object other) =>
      other is RunStyle &&
      other.italic == italic &&
      other.bold == bold &&
      other.smallCaps == smallCaps &&
      other.superscript == superscript &&
      other.subscript == subscript;

  @override
  int get hashCode =>
      Object.hash(italic, bold, smallCaps, superscript, subscript);
}

/// Um trecho com o mesmo estilo (e o mesmo link interno, quando há).
final class TextRun {
  const TextRun(this.text, {this.style = RunStyle.plain, this.link});

  final String text;
  final RunStyle style;

  /// Link interno resolvido (`caminho/no/zip#fragmento`); links externos não são guardados.
  final String? link;

  @override
  bool operator ==(Object other) =>
      other is TextRun &&
      other.text == text &&
      other.style == style &&
      other.link == link;

  @override
  int get hashCode => Object.hash(text, style, link);

  @override
  String toString() => 'TextRun($text)';
}

enum BlockAlign { start, end, left, right, center, justify }

/// Estilo de bloco (subconjunto do CSS do livro; medidas em em).
final class BlockStyle {
  const BlockStyle({
    this.align,
    this.indentEm,
    this.marginTopEm,
    this.marginBottomEm,
    this.pageBreakBefore = false,
    this.quoteDepth = 0,
    this.listDepth = 0,
  });

  static const BlockStyle none = BlockStyle();

  final BlockAlign? align;
  final double? indentEm;
  final double? marginTopEm;
  final double? marginBottomEm;
  final bool pageBreakBefore;

  /// Níveis de `blockquote` em volta.
  final int quoteDepth;

  /// Níveis de lista em volta (item de lista).
  final int listDepth;

  @override
  bool operator ==(Object other) =>
      other is BlockStyle &&
      other.align == align &&
      other.indentEm == indentEm &&
      other.marginTopEm == marginTopEm &&
      other.marginBottomEm == marginBottomEm &&
      other.pageBreakBefore == pageBreakBefore &&
      other.quoteDepth == quoteDepth &&
      other.listDepth == listDepth;

  @override
  int get hashCode => Object.hash(
    align,
    indentEm,
    marginTopEm,
    marginBottomEm,
    pageBreakBefore,
    quoteDepth,
    listDepth,
  );
}

sealed class ContentBlock {
  const ContentBlock(this.style);

  final BlockStyle style;

  /// O pedaço deste bloco no texto canônico.
  String get text;
}

/// Bloco com texto (parágrafo, título, item de lista, linha pré-formatada).
sealed class TextBlock extends ContentBlock {
  const TextBlock(this.runs, super.style);

  final List<TextRun> runs;

  @override
  String get text => runs.map((r) => r.text).join();
}

final class ParagraphBlock extends TextBlock {
  const ParagraphBlock(super.runs, super.style);
}

final class HeadingBlock extends TextBlock {
  const HeadingBlock(this.level, List<TextRun> runs, BlockStyle style)
    : super(runs, style);

  /// 1–6 (`h1`…`h6`).
  final int level;
}

final class ListItemBlock extends TextBlock {
  const ListItemBlock(super.runs, super.style);
}

/// Uma linha de `pre` (espaços preservados).
final class PreformattedBlock extends TextBlock {
  const PreformattedBlock(super.runs, super.style);
}

final class ImageBlock extends ContentBlock {
  const ImageBlock({
    required this.path,
    this.alt,
    this.width,
    this.height,
    BlockStyle style = BlockStyle.none,
  }) : super(style);

  /// Caminho da imagem no ZIP.
  final String path;
  final String? alt;
  final int? width;
  final int? height;

  @override
  String get text => objectChar;
}

/// `<hr>`: quebra de cena.
final class SceneBreakBlock extends ContentBlock {
  const SceneBreakBlock([super.style = BlockStyle.none]);

  @override
  String get text => objectChar;
}

/// Um item do spine aberto: blocos, texto canônico, início de cada bloco e posição de cada `id`.
final class ParsedItem {
  const ParsedItem({
    required this.blocks,
    required this.text,
    required this.blockStarts,
    required this.idOffsets,
  });

  static const ParsedItem empty = ParsedItem(
    blocks: [],
    text: '',
    blockStarts: [],
    idOffsets: {},
  );

  final List<ContentBlock> blocks;

  /// Texto canônico do item (NFC, `\n` entre blocos, unidades UTF-16).
  final String text;
  final List<int> blockStarts;
  final Map<String, int> idOffsets;
}

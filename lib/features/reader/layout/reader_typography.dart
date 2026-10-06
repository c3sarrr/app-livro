// G10.1 — tipografia do leitor (Anexo 03 §7.1, ADR-004, D-20, D-94): um só lugar monta o estilo do texto do
// livro. Literata variável com `opsz` = tamanho e `wght` sempre explícitos (sem o `opsz` a linha sai até 2 px
// mais larga); altura de linha EXATA (`tamanho × entrelinha`, D-94); `fontWeight` fica 400 para o Skia não
// fazer negrito sintético por cima do eixo `wght`.
import 'dart:ui' as ui;

import '../content/content_blocks.dart';
import '../domain/reader_settings.dart';

/// Família do texto do livro (G10 registra a Literata; Lora, Figtree e Atkinson entram na G14).
const String readerFontFamily = 'LiterataVF';

/// Subconjuntos da Literata, na ordem do `unicode-range` do arquivo de design.
const List<String> readerFontFallback = [
  'LiterataVFExt',
  'LiterataVFVi',
  'LiterataVFCyr',
  'LiterataVFCyrExt',
  'LiterataVFGr',
  'LiterataVFGrExt',
];

/// Versão das fontes do leitor (entra na chave do cache de páginas): mudou arquivo de fonte → sobe.
const int readerFontsVersion = 1;

/// Versão das regras de layout (D-94, D-96, D-98…D-100): mudou regra → sobe (o cache antigo é ignorado).
const int readerLayoutVersion = 1;

/// Tamanhos dos 7 passos (D-20); o padrão é o 4º (20,5).
const List<double> readerFontSizes = [16, 17.5, 19, 20.5, 22, 24, 26];

/// Cor do texto no papel Creme (Anexo 03 §7.1).
const ui.Color readerInkCreme = ui.Color(0xFF2A2520);

double lineSpacingOf(ReaderLineSpacing s) => switch (s) {
  ReaderLineSpacing.justo => 1.5,
  ReaderLineSpacing.medio => 1.72,
  ReaderLineSpacing.solto => 1.95,
};

double sideMarginOf(ReaderMargins m) => switch (m) {
  ReaderMargins.estreita => 20,
  ReaderMargins.media => 28,
  ReaderMargins.larga => 40,
};

/// Peso do texto corrido, do negrito e dos títulos (eixo `wght`).
const double readerTextWeight = 400;
const double readerBoldWeight = 700;
const double readerHeadingWeight = 600;

/// Fator de tamanho dos títulos (D-98): h1 1,3×, h2 1,15×, os outros 1×.
double headingScale(int level) => switch (level) {
  1 => 1.3,
  2 => 1.15,
  _ => 1.0,
};

/// Medidas da página e estilo do texto para um viewport. Padrão = tela 19 (390×844, 20,5, Médio, Média).
final class ReaderTypography {
  const ReaderTypography({
    this.fontSize = 20.5,
    this.lineSpacing = 1.72,
    this.sideMargin = 28,
    this.viewportWidth = 390,
    this.viewportHeight = 844,
    this.topInset = 92,
    this.bottomInset = 82,
    this.ink = readerInkCreme,
  });

  /// Os ajustes da pessoa (D-20) num viewport. As áreas seguras do aparelho entram em [topInset] e
  /// [bottomInset] (quem monta a tela decide — G11).
  factory ReaderTypography.fromSettings(
    ReaderSettings s, {
    required double viewportWidth,
    required double viewportHeight,
    double topInset = 92,
    double bottomInset = 82,
    ui.Color ink = readerInkCreme,
  }) => ReaderTypography(
    fontSize: readerFontSizes[s.fontStep - 1],
    lineSpacing: lineSpacingOf(s.lineSpacing),
    sideMargin: sideMarginOf(s.margins),
    viewportWidth: viewportWidth,
    viewportHeight: viewportHeight,
    topInset: topInset,
    bottomInset: bottomInset,
    ink: ink,
  );

  final double fontSize;
  final double lineSpacing;
  final double sideMargin;
  final double viewportWidth;
  final double viewportHeight;
  final double topInset;
  final double bottomInset;

  /// Cor do texto (não muda o layout; fica fora de [layoutKey]).
  final ui.Color ink;

  /// Os mesmos ajustes com outra cor de texto (Tema — D-121): a [layoutKey] não muda, então as quebras
  /// guardadas no cache continuam valendo.
  ReaderTypography withInk(ui.Color ink) => ReaderTypography(
    fontSize: fontSize,
    lineSpacing: lineSpacing,
    sideMargin: sideMargin,
    viewportWidth: viewportWidth,
    viewportHeight: viewportHeight,
    topInset: topInset,
    bottomInset: bottomInset,
    ink: ink,
  );

  /// Altura de linha exata do texto corrido (D-94): 20,5 × 1,72 = 35,26.
  double get lineHeight => fontSize * lineSpacing;

  double get contentWidth => viewportWidth - 2 * sideMargin;
  double get contentHeight => viewportHeight - topInset - bottomInset;

  /// Recuo de parágrafo e de cada nível de citação/lista: 1,3 em.
  double get indent => 1.3 * fontSize;

  /// Tolerância de encaixe vertical (Anexo 03 §7.1).
  static const double fitTolerance = 0.02;

  /// Tudo o que muda onde as linhas quebram e onde as páginas viram (chave do cache de páginas).
  String get layoutKey =>
      'v$readerLayoutVersion|$readerFontFamily|$fontSize|$lineSpacing|$sideMargin|'
      '$topInset|$bottomInset';

  /// Estilo de um trecho, em dados (o teste confere `opsz` = tamanho, `wght` explícito e peso 400 no Skia).
  /// [size] = tamanho do bloco (títulos são maiores); [weight] = peso do bloco.
  ReaderTextSpec spec(
    RunStyle s, {
    double? size,
    double weight = readerTextWeight,
    bool link = false,
  }) {
    final w = s.bold && weight < readerBoldWeight ? readerBoldWeight : weight;
    return ReaderTextSpec(
      size: size ?? fontSize,
      lineSpacing: lineSpacing,
      wght: w,
      italic: s.italic,
      features: [
        if (s.smallCaps) 'smcp',
        if (s.superscript) 'sups',
        if (s.subscript) 'subs',
      ],
      link: link,
      ink: ink,
    );
  }

  /// O `TextStyle` do `dart:ui` de um trecho (veja [spec]).
  ui.TextStyle runStyle(
    RunStyle s, {
    double? size,
    double weight = readerTextWeight,
    bool link = false,
  }) => spec(s, size: size, weight: weight, link: link).toUi();
}

/// Estilo de um trecho do livro em dados: Literata variável com `opsz` = [size] e `wght` = [wght] sempre
/// explícitos; o peso do Skia fica 400 (o negrito vem só do eixo).
final class ReaderTextSpec {
  const ReaderTextSpec({
    required this.size,
    required this.lineSpacing,
    required this.wght,
    required this.italic,
    required this.features,
    required this.link,
    required this.ink,
  });

  final double size;
  final double lineSpacing;
  final double wght;
  final bool italic;
  final List<String> features;
  final bool link;
  final ui.Color ink;

  String get family => readerFontFamily;
  List<String> get fallback => readerFontFallback;
  ui.FontWeight get skiaWeight => ui.FontWeight.w400;

  /// Eixos da fonte variável: `opsz` igual ao tamanho (ADR-004) e `wght`.
  List<ui.FontVariation> get variations => [
    ui.FontVariation('opsz', size),
    ui.FontVariation('wght', wght),
  ];

  ui.TextStyle toUi() => ui.TextStyle(
    color: ink,
    decoration: link ? ui.TextDecoration.underline : null,
    decorationColor: link ? ink : null,
    decorationThickness: link ? 0.5 : null,
    fontFamily: family,
    fontFamilyFallback: fallback,
    fontSize: size,
    fontWeight: skiaWeight,
    fontStyle: italic ? ui.FontStyle.italic : ui.FontStyle.normal,
    height: lineSpacing,
    leadingDistribution: ui.TextLeadingDistribution.even,
    fontFeatures: [for (final f in features) ui.FontFeature.enable(f)],
    fontVariations: variations,
  );
}

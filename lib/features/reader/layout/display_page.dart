// G11.2 — uma página pronta para a tela, do EPUB ou do PDF: a tela só pinta, lê o texto para o leitor de tela
// e pergunta se há um link sob o dedo (desenho G11 §2).
import 'dart:ui' as ui;

/// Para onde virar.
enum PageDirection { forward, backward }

/// Toque num link interno: [target] = `caminho#fragmento` resolvido na leitura do XHTML (G09); [spine] e
/// [offset] = onde estava o toque (o caractere do link no texto canônico do item).
typedef LinkHit = ({String target, int spine, int offset});

/// Um trecho do texto: [unit] = item do spine (EPUB) ou página (PDF); [from]…[to) no texto dele.
typedef ReaderRange = ({int unit, int from, int to});

/// Um ponto do texto, entre dois caracteres.
typedef ReaderSpot = ({int unit, int offset});

/// A parte de um trecho numa linha da página: [rect] = as letras na altura da linha inteira; [baseline]; a área
/// do texto do CSS ([textTop]…[textBottom]: ascent + descent da fonte, centrada na linha — onde o fundo de um
/// `span` é pintado); [em] = o tamanho da letra da linha.
typedef TextLineBox = ({
  ui.Rect rect,
  double baseline,
  double textTop,
  double textBottom,
  double em,
});

abstract interface class DisplayPage {
  /// Pinta o conteúdo da página, sem o papel e o rodapé, nas coordenadas da tela.
  void paint(ui.Canvas canvas);

  /// O texto da página para o leitor de tela (Anexo 03 §11).
  String get spokenText;

  /// O link interno sob [p] (coordenadas da tela), conferido no retângulo das letras do link.
  LinkHit? linkAt(ui.Offset p);

  /// `false` quando o que a página usa já foi descartado (outros ajustes, capítulo que saiu): não pintar.
  bool get alive;

  /// Os retângulos (coordenadas da tela) das letras do trecho [from]…[to] do texto de [unit] — o item do spine
  /// (EPUB) ou a página (PDF) —, só a parte que está nesta página. A marca da busca (D-120).
  List<ui.Rect> rectsOf(int unit, int from, int to);

  /// A página cobre o que fica embaixo dela (a imagem do PDF, com fundo branco): a marca da busca vai por cima,
  /// multiplicada; no texto do EPUB ela vai por trás das letras.
  bool get opaque;

  /// O trecho de texto que a página mostra (o limite da seleção — D-47); `null` = sem texto selecionável (o PDF —
  /// D-134).
  ReaderRange? get shown;

  /// O ponto do texto mais perto de [p], sempre dentro de [shown]; `null` sem texto.
  ReaderSpot? spotAt(ui.Offset p);

  /// A palavra em volta de [s] (`getWordBoundary`: a pontuação é uma "palavra"); espaço = `null`.
  ReaderRange? wordAround(ReaderSpot s);

  /// A palavra para a pressão longa e o toque: só com o dedo sobre as letras dela e com letra ou número.
  ReaderRange? wordAt(ui.Offset p);

  /// As caixas por linha de [from]…[to) do texto de [unit] nesta página (sem o espaço do fim de linha).
  List<TextLineBox> boxesOf(int unit, int from, int to);

  /// O texto canônico de [from]…[to) de [unit], só a parte desta página.
  String textOf(int unit, int from, int to);
}

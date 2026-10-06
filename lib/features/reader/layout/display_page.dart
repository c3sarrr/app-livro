// G11.2 — uma página pronta para a tela, do EPUB ou do PDF: a tela só pinta, lê o texto para o leitor de tela
// e pergunta se há um link sob o dedo (desenho G11 §2).
import 'dart:ui' as ui;

/// Para onde virar.
enum PageDirection { forward, backward }

/// Toque num link interno: [target] = `caminho#fragmento` resolvido na leitura do XHTML (G09); [spine] e
/// [offset] = onde estava o toque (o caractere do link no texto canônico do item).
typedef LinkHit = ({String target, int spine, int offset});

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
}

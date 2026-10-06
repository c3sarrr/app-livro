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
}

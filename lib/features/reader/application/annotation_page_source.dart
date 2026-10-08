// G18 — a página do modo anotação com os espaços abertos (R3): o mesmo começo da página congelada, refeita com as
// notas e o abridor, até o pé da tela (o que passa fica escondido até o Concluir); e as áreas dos grifos nela, para
// a Borracha. A tela (o documento do EPUB) dá a página; a sessão pede de novo a cada mudança de espaço.
import '../layout/display_page.dart';
import '../layout/space_cut.dart';
import 'annotation_session.dart' show PageHighlight;

abstract interface class AnnotationPageSource {
  /// A página com os espaços [cuts] (os da sessão e os do capítulo que ela não mexe).
  DisplayPage pageWith(List<SpaceCut> cuts);

  /// As áreas dos grifos da página [page] (as caixas das letras; a mancha nos à mão de fundo).
  List<PageHighlight> highlightsOn(DisplayPage page);

  /// Descarta as páginas montadas.
  void dispose();
}

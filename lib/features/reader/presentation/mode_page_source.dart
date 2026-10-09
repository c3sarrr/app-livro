// G18 — a página do modo anotação com os espaços (R3): a do documento (o EPUB), refeita a partir do mesmo começo
// da página congelada até o pé da tela (o que passa fica escondido até o Concluir), e as áreas dos grifos nela (a
// Borracha). Guarda só as duas últimas páginas montadas (a de agora e a de antes, que a tela ainda pode estar
// pintando); as outras são descartadas na hora, e o resto quando o modo acaba. A página alta (a mesma, com as linhas
// que passaram do pé) é de quem pede: só para achar as palavras dos desenhos escondidos.
import '../annotations/domain/annotation.dart' show HighlightStyle;
import '../annotations/ink/ink_geometry.dart' show InkRect;
import '../application/annotation_page_source.dart';
import '../application/annotation_session.dart'
    show PageHighlight, annotationTextShift;
import '../application/reader_document.dart' show SpacedDocument;
import '../layout/display_page.dart';
import '../layout/space_cut.dart';
import 'ink_painter.dart' show handHighlightBoxes;
import 'page_marks.dart' show PaintedHighlight;

/// A altura do texto no modo: do topo do texto do leitor limpo ([textTop]) até o pé da tela, menos os 30 px que o
/// texto desceu, mais a linha que o pé corta.
double modeContentHeight({
  required double screenHeight,
  required double textTop,
  required double lineHeight,
}) => screenHeight - textTop - annotationTextShift + lineHeight;

/// As áreas dos grifos de seleção [highlights] e dos feitos à mão [inkHighlights] na página [page]: as caixas das
/// letras; a mancha (D-161) nos à mão de fundo; o sublinhado e o ondulado à mão, pelas letras (R23).
List<PageHighlight> highlightAreasOn(
  DisplayPage page,
  List<PaintedHighlight> highlights,
  List<PaintedHighlight> inkHighlights,
) {
  List<InkRect> letters(PaintedHighlight h) => [
    for (final b in page.boxesOf(h.range.unit, h.range.from, h.range.to))
      InkRect(b.rect.left, b.textTop, b.rect.right, b.textBottom),
  ];
  return [
    for (final h in highlights) (id: h.id, ink: false, areas: letters(h)),
    for (final h in inkHighlights)
      (
        id: h.id,
        ink: true,
        areas: h.style == HighlightStyle.fill
            ? [
                for (final (:box, color: _) in handHighlightBoxes(page, [h]))
                  InkRect(box.left, box.top, box.right, box.bottom),
              ]
            : letters(h),
      ),
  ];
}

final class ModePageSource implements AnnotationPageSource {
  ModePageSource({
    required this.document,
    required this.base,
    required this.contentHeight,
    this.highlights = const [],
    this.inkHighlights = const [],
  });

  final SpacedDocument document;

  /// A página congelada do leitor limpo (o começo das páginas montadas; sem a do documento, ela mesma).
  final DisplayPage base;

  /// A altura do texto no modo ([modeContentHeight]).
  final double contentHeight;
  final List<PaintedHighlight> highlights, inkHighlights;

  final List<void Function()> _alive = [];

  @override
  DisplayPage pageWith(List<SpaceCut> cuts) {
    final made = document.pageWithSpaces(
      base,
      cuts,
      contentHeight: contentHeight,
    );
    if (made == null) return base;
    _alive.add(made.dispose);
    while (_alive.length > 2) {
      _alive.removeAt(0)();
    }
    return made.page;
  }

  @override
  ({DisplayPage page, void Function() dispose})? tallPageWith(
    List<SpaceCut> cuts,
    double extra,
  ) =>
      document.pageWithSpaces(base, cuts, contentHeight: contentHeight + extra);

  @override
  List<PageHighlight> highlightsOn(DisplayPage page) =>
      highlightAreasOn(page, highlights, inkHighlights);

  @override
  void dispose() {
    for (final d in _alive) {
      d();
    }
    _alive.clear();
  }
}

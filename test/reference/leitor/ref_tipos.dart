// dart format off
// GERADO AUTOMATICAMENTE por tools/medicao/gen_reference_dart.py — NÃO EDITE À MÃO.
// Tipos das referências medidas das telas do leitor (19–27b). Fonte: handoff_v2/referencia/layout/*.json.
// ignore_for_file: lines_longer_than_80_chars
import 'dart:ui';

/// box = caixa sem texto próprio · boxText = caixa com fundo/borda e texto · text = texto · icon = `<svg>`
/// inline = trecho dentro do texto do pai (sem widget próprio: conferido pelas linhas do pai).
enum LeitorRefKind { box, boxText, text, icon, inline }

/// Uma linha de texto medida: left/right dos glifos e baseline absoluta.
/// hidden = linha recortada por overflow (existe no layout, mas não aparece na prancha).
class LeitorRefLine {
  const LeitorRefLine(this.text, this.left, this.right, this.baseline, {this.hidden = false});
  final String text;
  final double left;
  final double right;
  final double baseline;
  final bool hidden;
}

class LeitorRefElement {
  const LeitorRefElement(this.section, this.rect, this.kind, {this.visual, this.lines = const <LeitorRefLine>[], this.linesAll = const <LeitorRefLine>[]});
  final String section;

  /// Retângulo de LAYOUT (transforms neutralizados), coordenadas absolutas do canvas.
  final Rect rect;

  /// Caixa visual com transform (rotate/translate) — só quando difere de [rect].
  final Rect? visual;
  final LeitorRefKind kind;

  /// Linhas do texto PRÓPRIO do elemento (nós de texto diretos).
  final List<LeitorRefLine> lines;

  /// Linhas do texto COMPOSTO (texto próprio + filhos inline), quando há filhos inline com texto.
  final List<LeitorRefLine> linesAll;
}

/// Uma linha frágil: [slack] = sobra até a borda; [joinOverflow] = quanto faltaria para a próxima palavra caber.
class LeitorKnifeEdge {
  const LeitorKnifeEdge(this.id, this.line, this.text, this.slack, this.joinOverflow);
  final String id;
  final int line;
  final String text;
  final double slack;
  final double? joinOverflow;
}

class LeitorRefPrancha {
  const LeitorRefPrancha({
    required this.tela,
    required this.slug,
    required this.prefix,
    required this.canvas,
    required this.sections,
    required this.elements,
    required this.textDependentX,
    required this.textDependentY,
    required this.ellipsized,
    required this.knifeEdges,
  });
  final String tela;
  final String slug;
  final String prefix;
  final Size canvas;
  final Map<String, Rect> sections;
  final Map<String, LeitorRefElement> elements;

  /// x/w dependem da largura medida do texto → tolerância horizontal ±1,0 (demais ±0,5).
  final Set<String> textDependentX;

  /// y/h mudam quando o texto alarga (quebras de linha a montante).
  final Set<String> textDependentY;

  /// `text-overflow: ellipsis` efetivo (o texto não cabe e vira "…").
  final Set<String> ellipsized;

  /// Quebras "fio de navalha" (sobra ou estouro < 1,5 px).
  final List<LeitorKnifeEdge> knifeEdges;

  /// Ids com widget próprio de uma seção (sem os inline), na ordem do arquivo.
  Iterable<String> idsOfSection(String section, {bool includeInline = false}) => elements.entries
      .where((e) => e.value.section == section && (includeInline || e.value.kind != LeitorRefKind.inline))
      .map((e) => e.key);
}

// G03 — instantâneo de uma prancha do Leitor (D-34): o mundo (base ou variante) + o estado da tela.
// Os valores que a prancha mostra são DERIVADOS do mundo (getters abaixo), nunca escritos à mão —
// é isso que os testes de fidelidade das fases L (G11+) vão consumir.
import 'package:app_leitura/features/library/domain/user_book.dart';
import 'package:app_leitura/features/reader/annotations/domain/annotation.dart';
import 'package:app_leitura/features/reader/annotations/domain/annotation_stats.dart';
import 'package:app_leitura/features/reader/annotations/domain/ink_layer.dart';
import 'package:app_leitura/features/reader/annotations/ink/drawing_anchor.dart';
import 'package:app_leitura/features/reader/domain/bookmark.dart';
import 'package:app_leitura/features/reader/domain/locator.dart';
import 'package:app_leitura/features/reader/domain/reading_position.dart';
import 'package:app_leitura/features/reader/domain/reading_session.dart';

import '../mundo_2026_09_20.dart';
import '../sumario_dom_casmurro.dart';

enum ModoDoLeitor {
  limpo,
  controles,
  selecao,
  anotacao,
  ajustesDeLeitura,
  sumario,
  grifosENotas,
}

enum FerramentaDeAnotacao { caneta, marcaTexto, borracha, laco, reta, espaco }

enum PainelDaFerramenta { caneta, marcaTexto }

enum AbaDoSumario { capitulos, marcadas }

/// Trecho selecionado (tela 21): deslocamentos no texto do capítulo atual.
typedef Selecao = ({int inicio, int fim, String texto});

final class InstantaneoDoLeitor {
  const InstantaneoDoLeitor({
    required this.prancha,
    required this.mundo,
    required this.modo,
    this.anotacoesNaPagina = const [],
    this.tintaNaPagina = const [],
    this.selecao,
    this.ferramenta,
    this.painel,
    this.abrindoEspacoLinhas,
    this.abaDoSumario,
    this.brand = '#B6ACE4',
  });

  /// Nome da prancha medida (`handoff_v2/referencia/layout/layout_<prancha>.json`).
  final String prancha;
  final Mundo mundo;
  final ModoDoLeitor modo;

  /// O que a página desenha (as pranchas 19/20/26/26b/27 mostram a pág. 159 sem anotações).
  final List<Annotation> anotacoesNaPagina;
  final List<InkLayer> tintaNaPagina;
  final Selecao? selecao;
  final FerramentaDeAnotacao? ferramenta;
  final PainelDaFerramenta? painel;

  /// Tela 24: altura (em linhas) do espaço que está sendo aberto ("↕ 3 linhas").
  final int? abrindoEspacoLinhas;
  final AbaDoSumario? abaDoSumario;

  /// Prop `brand` do arquivo (padrão #B6ACE4 — D-33).
  final String brand;

  // ---- derivados (o que a prancha mostra) ---------------------------------------------------

  UserBook get livro => mundo.domCasmurro;

  ReadingPosition get posicao => mundo.posicao(Slugs.domCasmurro);

  /// "pág. 159 de 256".
  int get pagina => posicao.refPage;
  int get totalDePaginas => livro.refPagesTotal!;

  /// "62%".
  int get porcentagem => (posicao.progression * 100).round();

  /// Capítulo atual, 1-based (XXXII = 32).
  int get capituloAtual => posicao.chapterIndex + 1;
  CapituloDoSumario get capitulo => sumarioDomCasmurro[posicao.chapterIndex];

  /// Contador "Grifos 12" (tela 20) e filtros da tela 25.
  AnnotationKindCounts get contagens =>
      AnnotationStats.countByKind(mundo.anotacoes, userBookId: livro.id);

  /// "18 min hoje · contando sozinho" (tela 20).
  int get minutosHoje => ReadingTime.minutesOn(
    mundo.sessoes,
    localDay: mundo.agoraLocal,
    utcOffset: mundo.fuso,
  );

  /// "≈ 2 h 10 min".
  Duration get tempoRestante => mundo.tempoRestante[Slugs.domCasmurro]!;

  /// Fita "Página marcada" pressionada (tela 20).
  bool get paginaMarcada =>
      mundo.marcadoresDo(Slugs.domCasmurro).any((b) => b.refPage == pagina);

  /// Aba Marcadas (27b), na ordem do livro.
  List<Bookmark> get marcadas => mundo.marcadoresDo(Slugs.domCasmurro);

  /// "Até o cap. L · faltam 18" (tela 27).
  int get faltamParaOClube => mundo.clube.metaCapitulo - capituloAtual;

  /// Contagem por rótulo do marca-texto (23b — todos os livros, D-40).
  Map<String, int> get grifosPorCor =>
      AnnotationStats.highlightsByColor(mundo.anotacoes);

  /// Marcas de um capítulo do sumário (tela 27), pelo índice (0 = I).
  ChapterMarks marcasDoCapitulo(int indice) => AnnotationStats.chapterMarks(
    mundo.anotacoesDo(Slugs.domCasmurro),
    chapterIndex: indice,
  );

  /// Texto canônico de fixture do capítulo atual.
  String get textoDoCapitulo =>
      mundo.textosDosCapitulos[Slugs.domCasmurro]![posicao.chapterIndex]!;
}

// ---- variantes do mundo base ---------------------------------------------------------------

/// Antes da nota à mão (telas 22, 23, 23b e 24): sem o espaço aberto nem a anotação dele.
final Mundo mundoSemNotaAMao = () {
  final espaco = mundoReferencia.camadas.singleWhere(
    (c) => c.kind == InkLayerKind.space,
  );
  return mundoReferencia.copyWith(
    camadas: [
      for (final c in mundoReferencia.camadas)
        if (c.id != espaco.id) c,
    ],
    anotacoes: [
      for (final a in mundoReferencia.anotacoes)
        if (a.inkLayerId != espaco.id) a,
    ],
  );
}();

/// Tela 22: o que estava gravado quando a sessão da prancha começou — o grifo à mão e a elipse com o risco. O
/// sublinhado duplo (Reta) e a onda (ainda sendo desenhada) são da sessão: o fluxo da tela os desenha (G16).
final Mundo mundoDaTela22 = semOsDesenhosDaSessao(mundoSemNotaAMao);

/// [base] sem o sublinhado duplo e a onda da página 159: os desenhos da sessão de anotação das pranchas 22–24b. T01: as
/// 23–24b vêm depois da 22, na mesma sessão (o Desfazer aceso nas pranchas) — as provas de fidelidade gravam o mundo
/// sem eles e o fluxo os desenha.
Mundo semOsDesenhosDaSessao(Mundo base) {
  final daSessao = {
    for (final a in base.anotacoes)
      if (a.kind == AnnotationKind.drawing &&
          a.refPage == 159 &&
          const {
            'fluido misterioso',
            'a vaga que se retira',
          }.contains((a.anchor as EpubAnchor).quote.exact))
        a.id,
  };
  final camadas = {
    for (final a in base.anotacoes)
      if (daSessao.contains(a.id)) a.inkLayerId,
  };
  return base.copyWith(
    camadas: [
      for (final c in base.camadas)
        if (!camadas.contains(c.id)) c,
    ],
    anotacoes: [
      for (final a in base.anotacoes)
        if (!daSessao.contains(a.id)) a,
    ],
  );
}

/// Tela 21: antes da sessão de anotação de hoje — nenhuma tinta; um grifo de seleção (fundo amarelo)
/// em "aqueles olhos de Capitu".
final Mundo mundoDaTela21 = () {
  final dc = mundoReferencia.domCasmurro.id;
  final daPagina159DeHoje = {
    for (final a in mundoReferencia.anotacoes)
      if (a.userBookId == dc && a.refPage == 159) a.id,
  };
  final base = mundoReferencia.anotacao(
    mundoReferencia.anotacoes
        .firstWhere(
          (a) =>
              a.userBookId == dc &&
              a.refPage == 159 &&
              a.kind == AnnotationKind.highlight,
        )
        .id,
  );
  final texto = mundoReferencia.textosDosCapitulos[Slugs.domCasmurro]![31]!;
  const exato = 'aqueles olhos de Capitu';
  final inicio = texto.indexOf(exato);
  final ancora = base.anchor as EpubAnchor;
  final grifoDeSelecao = base.copyWith(
    source: AnnotationSource.selection,
    anchor: EpubAnchor(
      sha: ancora.sha,
      spine: ancora.spine,
      start: inicio,
      end: inicio + exato.length,
      quote: TextQuote(
        prefix: texto.substring(inicio - 32, inicio),
        exact: exato,
        suffix: texto.substring(
          inicio + exato.length,
          inicio + exato.length + 32,
        ),
      ),
      refPage: 159,
    ),
  );
  return mundoReferencia.copyWith(
    camadas: const [],
    anotacoes: [
      for (final a in mundoReferencia.anotacoes)
        if (!daPagina159DeHoje.contains(a.id)) a,
      grifoDeSelecao,
    ],
  );
}();

/// D-169 — as pranchas de antes da sessão de hoje (19, 20, 26, 26b, 27 e 27b): a tinta de hoje (os 3 desenhos, o
/// grifo à mão e — G18 — a nota à mão da pág. 159) fica no banco com a âncora sem lugar — outro arquivo e uma citação
/// que não existe no capítulo —, então conta (o contador 12, as marcas do sumário) e não pinta (D-44) nem abre espaço
/// na página.
final Mundo mundoSemTintaDeHoje = () {
  final dc = mundoReferencia.domCasmurro.id;
  EpubAnchor semLugar(EpubAnchor a) => EpubAnchor(
    sha: shaDeAntesDeHoje,
    spine: a.spine,
    start: a.start,
    end: a.end,
    quote: const TextQuote(exact: citacaoDeAntesDeHoje),
    refPage: a.refPage,
  );
  TextAnchor camadaSemLugar(TextAnchor a) {
    final ink = inkAnchorOf(a);
    if (ink == null) return a;
    final w = ink.w;
    return w == null
        ? semLugar(ink.range)
        : inkLayerAnchor(semLugar(ink.range), w);
  }

  final deHoje = {
    for (final a in mundoReferencia.anotacoes)
      if (a.userBookId == dc &&
          a.refPage == 159 &&
          a.source == AnnotationSource.ink &&
          (a.kind == AnnotationKind.highlight ||
              a.kind == AnnotationKind.drawing ||
              a.kind == AnnotationKind.handwriting))
        a.id,
  };
  final camadasDeHoje = {
    for (final a in mundoReferencia.anotacoes)
      if (deHoje.contains(a.id) && a.inkLayerId != null) a.inkLayerId!,
  };
  return mundoReferencia.copyWith(
    anotacoes: [
      for (final a in mundoReferencia.anotacoes)
        deHoje.contains(a.id)
            ? a.copyWith(anchor: semLugar(a.anchor as EpubAnchor))
            : a,
    ],
    camadas: [
      for (final c in mundoReferencia.camadas)
        camadasDeHoje.contains(c.id)
            ? c.copyWith(anchor: camadaSemLugar(c.anchor))
            : c,
    ],
  );
}();

/// D-169: o arquivo e a citação de "antes da sessão de hoje" (nenhum livro do mundo tem os dois).
const String shaDeAntesDeHoje =
    '0000000000000000000000000000000000000000000000000000000000000169';
const String citacaoDeAntesDeHoje = '‹antes da sessão de hoje›';

/// Itens que a página 159 mostra no modo anotação (telas 22–24b).
List<Annotation> anotacoesDaPagina159(Mundo mundo) => [
  for (final a in mundo.anotacoesDo(Slugs.domCasmurro))
    if (a.refPage == 159) a,
];

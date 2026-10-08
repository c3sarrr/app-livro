// G03 — "mundo de referência" (D-34): todos os dados que a Início e o Leitor (telas 19–27b) mostram,
// como entidades de domínio, no estado BASE de domingo 20/09/2026 20:00 em São Paulo (D-09).
//
// As pranchas são fotos independentes e nem todas saem do mesmo estado (Anexo 01 §14): cada uma tem
// o seu instantâneo em `telas/` (derivado daqui). O estado base é o das telas 24b/25 (com a nota à mão).
// A Início e o Leitor divergem em 4 números (Q25) — o instantâneo da Início (`telas/inicio.dart`)
// mantém os dela e o teste da fixture lista as diferenças.
//
// Regras desta fixture:
// * nada aqui vai para `lib/` (PROMPT MESTRE §4.3.1) — produção só usa dados reais;
// * textos do arquivo são LITERAIS; o que o arquivo não mostra e o banco exige (ids, horários exatos,
//   totais de páginas de outros livros…) é preenchimento coerente, marcado como tal;
// * âncoras: deslocamentos sobre o "texto canônico de fixture" de cada capítulo (`textosDosCapitulos`),
//   formado só por trechos literais do arquivo; o EPUB de fixture da G09 é montado com esses mesmos
//   textos (spine = índice do capítulo + 1) e o mapa de páginas é injetado (Anexo 03 §6);
// * a tinta ainda não tem traços (`strokes_b64` vazio): os traços do arquivo (referencia/svg_tinta)
//   entram com o codec BNK1 no app (G16/G17).
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' show Color;

import 'package:app_leitura/core/data/clock/hlc.dart';
import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/daos/annotation_daos.dart';
import 'package:app_leitura/core/data/database/daos/library_daos.dart';
import 'package:app_leitura/core/data/database/daos/reader_daos.dart';
import 'package:app_leitura/core/data/model/record_meta.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/features/library/domain/reading_goals.dart';
import 'package:app_leitura/features/library/domain/user_book.dart';
import 'package:app_leitura/features/reader/annotations/domain/annotation.dart';
import 'package:app_leitura/features/reader/annotations/domain/highlight_label.dart';
import 'package:app_leitura/features/reader/annotations/domain/ink_layer.dart';
import 'package:app_leitura/features/reader/annotations/domain/pen_presets.dart';
import 'package:app_leitura/features/reader/annotations/ink/drawing_anchor.dart';
import 'package:app_leitura/features/reader/domain/bookmark.dart';
import 'package:app_leitura/features/reader/domain/locator.dart';
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:app_leitura/features/reader/domain/reading_position.dart';
import 'package:app_leitura/features/reader/domain/reading_session.dart';
import 'package:crypto/crypto.dart';

import 'sumario_dom_casmurro.dart';
import 'tinta_do_mundo.dart';

/// Cores do arquivo usadas nos dados (grifos, rótulos e tinta).
abstract final class CoresDoMundo {
  static const String amarelo = '#FED170';
  static const String rosa = '#FFC1C6';
  static const String verde = '#ABCF82';
  static const String lavanda = '#B6ACE4';
  static const String coral = '#FF552E';
}

/// Livros com slug estável (o `id` da Início e a chave dos textos de fixture).
abstract final class Slugs {
  static const String domCasmurro = 'dom-casmurro';
  static const String mrsDalloway = 'mrs-dalloway';
  static const String orgulho = 'orgulho-e-preconceito';
  static const String frankenstein = 'frankenstein';
  static const String alienista = 'o-alienista';
  static const String senhora = 'senhora';
}

/// Livro que aparece sem estar na estante ("Para você" da Início — catálogo).
typedef LivroDeCatalogo = ({
  String slug,
  String titulo,
  String? tituloCurto,
  String autor,
});

/// Trecho do texto de um cartão da tela 25: cinza (contexto) ou de uma anotação.
typedef TrechoDoCartao = ({String texto, String? anotacaoId});

/// Perfil (social — `public.profiles`/cache), como a Início mostra.
typedef PerfilDoMundo = ({
  String nome,
  String inicial,
  int notificacoesNaoLidas,
});

/// Clube "Leitoras de Capitu" (social — Supabase + cache).
typedef ClubeDoMundo = ({
  String id,
  String nomePrefixo,
  String nomeDestaque,
  String livroSlug,
  int metaCapitulo,
  DateTime proximoEncontro,
  int participantes,
  List<({String inicial, Color cor})> exibidos,
  double progressoDoGrupo,
  String inicialDaUsuaria,
  int mensagensNaoLidas,
  String postCompartilhadoId,
  int respostasDoPost,
});

final class Mundo {
  Mundo({
    required this.agora,
    required this.fuso,
    required this.usuarioId,
    required this.aparelhoId,
    required this.perfil,
    required List<UserBook> livros,
    required this.slugs,
    required List<ReadingPosition> posicoes,
    required List<ReadingSession> sessoes,
    required List<Bookmark> marcadores,
    required List<Annotation> anotacoes,
    required List<InkLayer> camadas,
    required List<HighlightLabel> rotulos,
    required this.ajustes,
    required this.caneta,
    required this.metas,
    required this.clube,
    required this.paraVoceAutor,
    required List<LivroDeCatalogo> paraVoce,
    required this.tempoRestante,
    required this.textosDosCapitulos,
    required this.cartoesDaTela25,
  }) : livros = List.unmodifiable(livros),
       posicoes = List.unmodifiable(posicoes),
       sessoes = List.unmodifiable(sessoes),
       marcadores = List.unmodifiable(marcadores),
       anotacoes = List.unmodifiable(anotacoes),
       camadas = List.unmodifiable(camadas),
       rotulos = List.unmodifiable(rotulos),
       paraVoce = List.unmodifiable(paraVoce);

  /// "Agora" em UTC (= 20/09/2026 20:00 em São Paulo).
  final DateTime agora;

  /// Fuso do usuário (São Paulo, sem horário de verão).
  final Duration fuso;
  final String usuarioId;
  final String aparelhoId;
  final PerfilDoMundo perfil;
  final List<UserBook> livros;

  /// slug → id do livro na estante.
  final Map<String, String> slugs;
  final List<ReadingPosition> posicoes;
  final List<ReadingSession> sessoes;
  final List<Bookmark> marcadores;
  final List<Annotation> anotacoes;
  final List<InkLayer> camadas;
  final List<HighlightLabel> rotulos;
  final ReaderSettings ajustes;
  final PenPresets caneta;
  final ReadingGoals metas;
  final ClubeDoMundo clube;
  final String paraVoceAutor;
  final List<LivroDeCatalogo> paraVoce;

  /// Tempo para terminar, por slug ("≈ 2 h 10 min" — a regra do Anexo 03 §8 entra na G12).
  final Map<String, Duration> tempoRestante;

  /// slug → (índice do capítulo → texto canônico de fixture).
  final Map<String, Map<int, String>> textosDosCapitulos;

  /// Cartões da tela 25 na ordem do arquivo: group_id → trechos literais do cartão.
  final List<({String grupoId, List<TrechoDoCartao> trechos})> cartoesDaTela25;

  DateTime get agoraLocal => agora.add(fuso);

  UserBook livro(String slug) => livros.firstWhere((b) => b.id == slugs[slug]);

  UserBook get domCasmurro => livro(Slugs.domCasmurro);

  ReadingPosition posicao(String slug) =>
      posicoes.firstWhere((p) => p.id == slugs[slug]);

  List<Annotation> anotacoesDo(String slug) => [
    for (final a in anotacoes)
      if (a.userBookId == slugs[slug] && !a.meta.isDeleted) a,
  ];

  List<Bookmark> marcadoresDo(String slug) => [
    for (final b in marcadores)
      if (b.userBookId == slugs[slug] && !b.meta.isDeleted) b,
  ]..sort((a, b) => a.refPage.compareTo(b.refPage));

  Annotation anotacao(String id) => anotacoes.firstWhere((a) => a.id == id);

  /// Capítulo (índice) que contém a página de referência, pelo sumário.
  static int capituloDaPagina(int pagina) {
    var c = 0;
    for (var i = 0; i < sumarioDomCasmurro.length; i++) {
      if (sumarioDomCasmurro[i].pagina <= pagina) c = i;
    }
    return c;
  }

  Mundo copyWith({
    List<Annotation>? anotacoes,
    List<InkLayer>? camadas,
    List<Bookmark>? marcadores,
    ReaderSettings? ajustes,
  }) => Mundo(
    agora: agora,
    fuso: fuso,
    usuarioId: usuarioId,
    aparelhoId: aparelhoId,
    perfil: perfil,
    livros: livros,
    slugs: slugs,
    posicoes: posicoes,
    sessoes: sessoes,
    marcadores: marcadores ?? this.marcadores,
    anotacoes: anotacoes ?? this.anotacoes,
    camadas: camadas ?? this.camadas,
    rotulos: rotulos,
    ajustes: ajustes ?? this.ajustes,
    caneta: caneta,
    metas: metas,
    clube: clube,
    paraVoceAutor: paraVoceAutor,
    paraVoce: paraVoce,
    tempoRestante: tempoRestante,
    textosDosCapitulos: textosDosCapitulos,
    cartoesDaTela25: cartoesDaTela25,
  );

  /// Grava os dados pessoais num banco local (testes de DAO/repositório com dados do arquivo).
  Future<void> gravarEm(AppDatabase db) => db.transaction(() async {
    for (final b in livros) {
      await UserBooksDao(db).upsert(b);
    }
    for (final p in posicoes) {
      await ReadingPositionsDao(db).upsert(p);
    }
    for (final s in sessoes) {
      await ReadingSessionsDao(db).upsert(s);
    }
    for (final b in marcadores) {
      await BookmarksDao(db).upsert(b);
    }
    for (final l in camadas) {
      await InkLayersDao(db).upsert(l);
    }
    for (final a in anotacoes) {
      await AnnotationsDao(db).upsert(a);
    }
    for (final r in rotulos) {
      await HighlightLabelsDao(db).upsert(r);
    }
    await ReaderSettingsDao(db).upsert(ajustes);
    await PenPresetsDao(db).upsert(caneta);
    await ReadingGoalsDao(db).upsert(metas);
  });
}

/// O mundo base (construído uma vez).
final Mundo mundoReferencia = _construir();

// ---------------------------------------------------------------------------------------------

const String _usuario = 'b0a7e5c2-6f1d-4c3a-9e8b-2d4f6a8c0e12';
const String _aparelho = 'aparelho-marina-1';
const Duration _fuso = Duration(hours: -3);

/// Horário de São Paulo → UTC.
DateTime _sp(int mes, int dia, [int hora = 0, int minuto = 0]) =>
    DateTime.utc(2026, mes, dia, hora + 3, minuto);

/// UUIDv7 determinístico: instante real + bits do sha256 do nome (válido em `UuidV7.isValid`).
String _id(String nome, DateTime em) {
  final ms = em.millisecondsSinceEpoch.toRadixString(16).padLeft(12, '0');
  final h = sha256.convert(utf8.encode('mundo_2026_09_20/$nome')).toString();
  final variante = (8 + int.parse(h[3], radix: 16) % 4).toRadixString(16);
  return '${ms.substring(0, 8)}-${ms.substring(8)}-7${h.substring(0, 3)}-'
      '$variante${h.substring(4, 7)}-${h.substring(7, 19)}';
}

String _sha(String nome) =>
    sha256.convert(utf8.encode('mundo_2026_09_20/$nome.epub')).toString();

RecordMeta _meta(DateTime em, {int contador = 0}) => RecordMeta(
  userId: _usuario,
  createdAt: em,
  updatedAt: em,
  version: Hlc(em.millisecondsSinceEpoch, contador, _aparelho),
);

/// Texto da pág. 159 (cap. XXXII) — tela 19, literal.
const String paragrafoDaPagina159 =
    'Retórica dos namorados, dá-me uma comparação exata e poética para dizer o que foram '
    'aqueles olhos de Capitu. Não me acode imagem capaz de dizer, sem quebra da dignidade do '
    'estilo, o que eles foram e me fizeram. Olhos de ressaca? Vá, de ressaca. É o que me dá ideia '
    'daquela feição nova. Traziam não sei que fluido misterioso e enérgico, uma força que '
    'arrastava para dentro, como a vaga que se retira da praia, nos dias de ressaca. Para não ser '
    'arrastado, agarrei-me às outras partes vizinhas, às orelhas, aos braços, aos cabelos '
    'espalhados pelos ombros; mas tão depressa buscava as pupilas, a onda que saía delas vinha '
    'crescendo, cava e escura, ameaçando envolver-me, puxar-me e tragar-me.';

const Map<String, Map<int, String>> _textos = {
  Slugs.domCasmurro: {
    // I — tela 25 (pág. 3) e excerto do marcador da 27b
    0:
        'Uma noite destas, vindo da cidade para o Engenho Novo, encontrei no trem da Central um '
        'rapaz aqui do bairro, que eu conheço de vista e de chapéu.',
    // II — excerto do marcador (27b) e grifo da pág. 6 (25)
    1:
        'Agora que expliquei o título, passo a escrever o livro.\n'
        'O meu fim evidente era atar as duas pontas da vida, e restaurar na velhice a adolescência.',
    8: '— A vida é uma ópera e uma grande ópera.', // IX (pág. 41)
    24: 'olhos de cigana oblíqua e dissimulada.', // XXV (pág. 121)
    30: 'Capitu era Capitu, isto é, uma criatura mui particular, mais mulher do que eu era homem.',
    31: paragrafoDaPagina159, // XXXII (pág. 159)
  },
  // Grifos em outros livros (só contam para os rótulos — D-40): textos originais, domínio público.
  Slugs.mrsDalloway: {
    0:
        'Mrs. Dalloway said she would buy the flowers herself. What a lark! What a plunge! '
        'She had the oddest sense of being herself invisible; unseen; unknown;',
  },
  Slugs.orgulho: {
    0:
        'It is a truth universally acknowledged, that a single man in possession of a good '
        'fortune, must be in want of a wife. I could easily forgive his pride, if he had not '
        'mortified mine. There is a stubbornness about me that never can bear to be frightened '
        'at the will of others.',
  },
};

EpubAnchor _ancora(
  String slug,
  int capitulo,
  String exato, {
  required int pagina,
  bool depois = false,
}) {
  final texto = _textos[slug]![capitulo]!;
  final achado = texto.indexOf(exato);
  if (achado < 0) throw StateError('"$exato" não está no capítulo $capitulo');
  // `depois`: costura logo após o trecho (espaço aberto entre linhas — âncora vazia)
  final inicio = depois ? achado + exato.length : achado;
  final fim = depois ? inicio : achado + exato.length;
  return EpubAnchor(
    sha: _sha(slug),
    spine: capitulo + 1,
    start: inicio,
    end: fim,
    quote: TextQuote(
      prefix: texto.substring(math.max(0, inicio - 32), inicio),
      exact: texto.substring(inicio, fim),
      suffix: texto.substring(fim, math.min(texto.length, fim + 32)),
    ),
    refPage: pagina,
  );
}

Mundo _construir() {
  final agora = _sp(9, 20, 20);
  final ids = {
    Slugs.domCasmurro: _id('livro/dom-casmurro', _sp(8, 30, 21)),
    Slugs.mrsDalloway: _id('livro/mrs-dalloway', _sp(8, 20, 19)),
    Slugs.orgulho: _id('livro/orgulho', _sp(7, 10, 18)),
    Slugs.frankenstein: _id('livro/frankenstein', _sp(9, 19, 21)),
    Slugs.alienista: _id('livro/alienista', _sp(9, 18, 21)),
    Slugs.senhora: _id('livro/senhora', _sp(9, 17, 21)),
  };
  final dc = ids[Slugs.domCasmurro]!;

  UserBook livro(
    String slug,
    String titulo,
    String autor,
    BookFileFormat formato,
    ShelfStatus status,
    DateTime adicionado, {
    int? paginas,
    int? capitulos,
    DateTime? comecou,
    DateTime? abriu,
  }) => UserBook(
    id: ids[slug]!,
    meta: _meta(adicionado),
    title: titulo,
    authorDisplay: autor,
    format: formato,
    status: status,
    contentSha256: _sha(slug),
    refPagesTotal: paginas,
    refPageVersion: paginas == null ? null : 1,
    chaptersTotal: capitulos,
    addedAt: adicionado,
    startedAt: comecou,
    lastOpenedAt: abriu,
  );

  final livros = [
    livro(
      Slugs.domCasmurro,
      'Dom Casmurro',
      'Machado de Assis',
      BookFileFormat.epub,
      ShelfStatus.reading,
      _sp(8, 30, 21),
      paginas: 256,
      capitulos: 148,
      comecou: _sp(9, 1, 20),
      abriu: _sp(9, 20, 19, 20),
    ),
    // totais de páginas dos outros livros: preenchimento (não aparecem no arquivo)
    livro(
      Slugs.mrsDalloway,
      'Mrs. Dalloway',
      'Virginia Woolf',
      BookFileFormat.epub,
      ShelfStatus.reading,
      _sp(8, 20, 19),
      paginas: 200,
      comecou: _sp(8, 21, 20),
      abriu: _sp(9, 18, 21),
    ),
    livro(
      Slugs.orgulho,
      'Orgulho e Preconceito',
      'Jane Austen',
      BookFileFormat.epub,
      ShelfStatus.reading,
      _sp(7, 10, 18),
      paginas: 400,
      comecou: _sp(7, 11, 20),
      abriu: _sp(9, 16, 21),
    ),
    livro(
      Slugs.frankenstein,
      'Frankenstein',
      'Mary Shelley',
      BookFileFormat.epub,
      ShelfStatus.wantToRead,
      _sp(9, 19, 21),
    ),
    livro(
      Slugs.alienista,
      'O Alienista',
      'Machado de Assis',
      BookFileFormat.pdf,
      ShelfStatus.wantToRead,
      _sp(9, 18, 21),
    ),
    livro(
      Slugs.senhora,
      'Senhora',
      'José de Alencar',
      BookFileFormat.epub,
      ShelfStatus.wantToRead,
      _sp(9, 17, 21),
    ),
  ];

  ReadingPosition posicao(
    String slug,
    int pagina,
    double progressao, {
    int capitulo = 0,
    int deslocamento = 0,
    TextQuote? trecho,
    required DateTime em,
  }) => ReadingPosition(
    id: ids[slug]!,
    meta: _meta(em),
    locator: EpubLocator(
      sha: _sha(slug),
      spine: capitulo + 1,
      offset: deslocamento,
      quote: trecho,
      refPage: pagina,
      progression: progressao,
    ),
    refPage: pagina,
    chapterIndex: capitulo,
    progression: progressao,
    deviceId: _aparelho,
  );

  final posicoes = [
    // pág. 159 de 256 = 62 %; o primeiro caractere visível é o começo do parágrafo da tela 19
    posicao(
      Slugs.domCasmurro,
      159,
      0.62113,
      capitulo: 31,
      trecho: const TextQuote(
        exact: 'Retórica dos namorados',
        suffix: ', dá-me uma comparação exata e ',
      ),
      em: _sp(9, 20, 19, 40),
    ),
    // Só o progresso (34 % / 81 %) aparece no arquivo (Início). Página, capítulo e localizador destes
    // dois são preenchimento e NÃO servem para derivar nada (os textos de fixture deles só têm os
    // grifos); a posição é gravada quando o livro foi aberto pela última vez.
    posicao(Slugs.mrsDalloway, 68, 0.34, em: _sp(9, 18, 21)),
    posicao(Slugs.orgulho, 324, 0.81, em: _sp(9, 16, 21)),
  ];

  // Minutos por dia (Início, semana S T Q Q S S + Hoje) e a sequência de 12 dias (9 a 20/09).
  const minutosPorDia = {
    9: 28,
    10: 35,
    11: 31,
    12: 26,
    13: 40, // antes da semana do gráfico: preenchimento
    14: 32, 15: 45, 16: 30, 17: 22, 18: 38, 19: 55, 20: 18,
  };
  final sessoes = <ReadingSession>[];
  for (final MapEntry(key: dia, value: minutos) in minutosPorDia.entries) {
    final ehHoje = dia == 20;
    final inicio = ehHoje ? _sp(9, 20, 19, 20) : _sp(9, dia, 21);
    sessoes.add(
      ReadingSession(
        id: _id('sessao/$dia', inicio),
        meta: _meta(inicio.add(Duration(minutes: minutos))),
        userBookId: dc,
        startedAt: inicio,
        endedAt: inicio.add(Duration(minutes: minutos)),
        activeSeconds: minutos * 60,
        // hoje: 24 páginas (135 → 159) — "páginas hoje" da Início
        refPageFrom: ehHoje ? 135 : null,
        refPageTo: ehHoje ? 159 : null,
        pagesViewed: ehHoje ? 24 : null,
        source: SessionSource.auto,
        deviceId: _aparelho,
      ),
    );
  }

  Bookmark marcador(
    int pagina,
    int capitulo,
    String excerto,
    DateTime em, {
    double? progressao,
  }) => Bookmark(
    id: _id('marcador/$pagina', em),
    meta: _meta(em),
    userBookId: dc,
    locator: EpubLocator(
      sha: _sha(Slugs.domCasmurro),
      spine: capitulo + 1,
      offset: 0,
      refPage: pagina,
      progression:
          progressao ?? double.parse((pagina / 256).toStringAsFixed(5)),
    ),
    refPage: pagina,
    chapterIndex: capitulo,
    excerpt: excerto,
  );

  // Tela 27b, literal (excerto, página, capítulo, "marcada em …").
  final marcadores = [
    marcador(
      3,
      0,
      'Uma noite destas, vindo da cidade para o Engenho Novo, encontrei no trem da Central…',
      _sp(9, 2, 20, 10),
    ),
    marcador(
      6,
      1,
      'Agora que expliquei o título, passo a escrever o livro…',
      _sp(9, 3, 20, 15),
    ),
    marcador(
      159,
      31,
      'Retórica dos namorados, dá-me uma comparação exata e poética…',
      _sp(9, 20, 19, 25),
      progressao: 0.62113, // mesmo ponto da posição atual (começo da pág. 159)
    ),
  ];

  // --- tinta (camadas) e anotações da tela 25 ------------------------------------------------
  // G16: os desenhos têm os traços do arquivo (`tinta_do_mundo.dart`) e a âncora de 8 chaves (a largura do trecho
  // em em); a anotação `drawing` fica com a de 7.
  InkLayer camada(
    String nome,
    InkLayerKind tipo,
    EpubAnchor ancora,
    DateTime em, {
    int? linhas,
    DesenhoDoMundo? desenho,
    ({String strokesB64, int strokeCount})? nota,
  }) => InkLayer(
    id: _id('tinta/$nome', em),
    meta: _meta(em),
    userBookId: dc,
    kind: tipo,
    anchor: desenho == null ? ancora : inkLayerAnchor(ancora, desenho.w),
    spaceLines: linhas,
    strokesB64: desenho?.strokesB64 ?? nota?.strokesB64 ?? '',
    strokeCount: desenho?.emEm.length ?? nota?.strokeCount ?? 0,
  );

  final hoje = _sp(9, 20, 19, 41);
  final elipse = camada(
    'elipse-olhos-de-ressaca',
    InkLayerKind.overText,
    _ancora(Slugs.domCasmurro, 31, 'Olhos de ressaca?', pagina: 159),
    hoje.add(const Duration(minutes: 2)),
    desenho: desenhoDaElipse,
  );
  final espaco = camada(
    'espaco-nota-a-mao',
    InkLayerKind.space,
    _ancora(
      Slugs.domCasmurro,
      31,
      'Vá, de ressaca.',
      pagina: 159,
      depois: true,
    ),
    hoje.add(const Duration(minutes: 4)),
    linhas: 3, // "↕ 3 linhas" (tela 24)
    // G18 (R15): a tinta da 24b, na unidade da caixa
    nota: notaAMaoDoMundo,
  );
  final ondulado = camada(
    'ondulado-fluido-misterioso',
    InkLayerKind.overText,
    _ancora(Slugs.domCasmurro, 31, 'fluido misterioso', pagina: 159),
    hoje.add(const Duration(minutes: 6)),
    desenho: desenhoDoOndulado,
  );
  final duplo = camada(
    'duplo-a-vaga',
    InkLayerKind.overText,
    _ancora(Slugs.domCasmurro, 31, 'a vaga que se retira', pagina: 159),
    hoje.add(const Duration(minutes: 7)),
    desenho: desenhoDoDuplo,
  );

  Annotation anotacao(
    String nome,
    AnnotationKind tipo,
    EpubAnchor ancora,
    DateTime em, {
    String? grupo,
    String? cor,
    AnnotationSource fonte = AnnotationSource.selection,
    String? pai,
    String? nota,
    String? camada,
    String? clube,
    String slug = Slugs.domCasmurro,
  }) {
    final id = _id('anotacao/$nome', em);
    return Annotation(
      id: id,
      meta: _meta(em),
      userBookId: ids[slug]!,
      kind: tipo,
      parentId: pai,
      groupId: grupo ?? id,
      source: fonte,
      anchor: ancora,
      refPage: ancora.refPage,
      chapterIndex: slug == Slugs.domCasmurro
          ? Mundo.capituloDaPagina(ancora.refPage)
          : 0,
      color: cor,
      style: tipo == AnnotationKind.highlight ? HighlightStyle.fill : null,
      fillHeight: tipo == AnnotationKind.highlight ? FillHeight.medium : null,
      noteText: nota,
      inkLayerId: camada,
      sharedClubPostId: clube,
    );
  }

  final clubeId = _id('clube/leitoras-de-capitu', _sp(8, 1, 12));
  final postDoClube = _id('clube/post-pag-152', _sp(9, 19, 21, 5));

  final p3 = anotacao(
    'p3',
    AnnotationKind.highlight,
    _ancora(
      Slugs.domCasmurro,
      0,
      'que eu conheço de vista e de chapéu.',
      pagina: 3,
    ),
    _sp(9, 2, 19, 30),
    cor: CoresDoMundo.amarelo,
  );
  final p6 = anotacao(
    'p6',
    AnnotationKind.highlight,
    _ancora(
      Slugs.domCasmurro,
      1,
      'O meu fim evidente era atar as duas pontas da vida, e restaurar na velhice a adolescência.',
      pagina: 6,
    ),
    _sp(9, 3, 20),
    cor: CoresDoMundo.rosa,
  );
  final p6nota = anotacao(
    'p6-nota',
    AnnotationKind.note,
    p6.anchor as EpubAnchor,
    _sp(9, 3, 20, 2),
    grupo: p6.groupId,
    pai: p6.id,
    nota: 'É o livro todo nessa frase.',
  );
  final p41 = anotacao(
    'p41',
    AnnotationKind.highlight,
    _ancora(
      Slugs.domCasmurro,
      8,
      'A vida é uma ópera e uma grande ópera.',
      pagina: 41,
    ),
    _sp(9, 8, 21),
    cor: CoresDoMundo.verde,
  );
  final p121 = anotacao(
    'p121',
    AnnotationKind.highlight,
    _ancora(
      Slugs.domCasmurro,
      24,
      'olhos de cigana oblíqua e dissimulada.',
      pagina: 121,
    ),
    _sp(9, 15, 21),
    cor: CoresDoMundo.amarelo,
  );
  final p152 = anotacao(
    'p152',
    AnnotationKind.highlight,
    _ancora(
      Slugs.domCasmurro,
      30,
      'Capitu era Capitu, isto é, uma criatura mui particular, mais mulher do que eu era homem.',
      pagina: 152,
    ),
    _sp(9, 19, 21),
    cor: CoresDoMundo.lavanda,
    clube: postDoClube,
  );
  final p152nota = anotacao(
    'p152-nota',
    AnnotationKind.note,
    p152.anchor as EpubAnchor,
    _sp(9, 19, 21, 3),
    grupo: p152.groupId,
    pai: p152.id,
    nota: 'Levar para o encontro de quinta.',
  );
  // pág. 159, hoje — o grifo à mão livre vira grifo ancorado ("gruda nas palavras", 23b)
  final p159grifo = anotacao(
    'p159-grifo-a-mao-livre',
    AnnotationKind.highlight,
    _ancora(Slugs.domCasmurro, 31, 'olhos de Capitu', pagina: 159),
    hoje,
    cor: CoresDoMundo.amarelo,
    fonte: AnnotationSource.ink,
  );
  final p159elipse = anotacao(
    'p159-elipse',
    AnnotationKind.drawing,
    inkAnchorOf(elipse.anchor)!.range,
    elipse.meta.createdAt,
    cor: CoresDoMundo.coral,
    fonte: AnnotationSource.ink,
    camada: elipse.id,
  );
  final p159notaAMao = anotacao(
    'p159-nota-a-mao',
    AnnotationKind.handwriting,
    espaco.anchor as EpubAnchor,
    espaco.meta.createdAt,
    grupo: p159elipse
        .groupId, // Anexo 02 §4.3: entra no grupo do desenho da linha de cima
    fonte: AnnotationSource.ink,
    camada: espaco.id,
  );
  final p159ondulado = anotacao(
    'p159-ondulado',
    AnnotationKind.drawing,
    inkAnchorOf(ondulado.anchor)!.range,
    ondulado.meta.createdAt,
    cor: CoresDoMundo.coral,
    fonte: AnnotationSource.ink,
    camada: ondulado.id,
  );
  final p159duplo = anotacao(
    'p159-duplo',
    AnnotationKind.drawing,
    inkAnchorOf(duplo.anchor)!.range,
    duplo.meta.createdAt,
    grupo: p159ondulado.groupId, // mesma página, ≤ 2 linhas de distância (§4.3)
    cor: CoresDoMundo.coral,
    fonte: AnnotationSource.ink,
    camada: duplo.id,
  );

  // Grifos em outros livros: completam as contagens por rótulo da 23b (5 + 3 + 2 + 2).
  Annotation outro(
    String slug,
    String nome,
    String exato,
    String cor,
    DateTime em,
    int pagina,
  ) => anotacao(
    nome,
    AnnotationKind.highlight,
    _ancora(slug, 0, exato, pagina: pagina),
    em,
    cor: cor,
    slug: slug,
  );

  final outros = [
    outro(
      Slugs.mrsDalloway,
      'md-1',
      'Mrs. Dalloway said she would buy the flowers herself.',
      CoresDoMundo.amarelo,
      _sp(8, 21, 20, 10),
      1,
    ),
    outro(
      Slugs.mrsDalloway,
      'md-2',
      'What a lark! What a plunge!',
      CoresDoMundo.rosa,
      _sp(8, 21, 20, 12),
      1,
    ),
    outro(
      Slugs.mrsDalloway,
      'md-3',
      'She had the oddest sense of being herself invisible; unseen; unknown;',
      CoresDoMundo.lavanda,
      _sp(9, 18, 21, 30),
      9,
    ),
    outro(
      Slugs.orgulho,
      'pp-1',
      'It is a truth universally acknowledged, that a single man in possession of a good fortune, must be in want of a wife.',
      CoresDoMundo.amarelo,
      _sp(7, 11, 20, 5),
      1,
    ),
    outro(
      Slugs.orgulho,
      'pp-2',
      'I could easily forgive his pride, if he had not mortified mine.',
      CoresDoMundo.rosa,
      _sp(8, 2, 21),
      22,
    ),
    outro(
      Slugs.orgulho,
      'pp-3',
      'There is a stubbornness about me that never can bear to be frightened at the will of others.',
      CoresDoMundo.verde,
      _sp(9, 16, 21, 20),
      178,
    ),
  ];

  HighlightLabel rotulo(String cor, String nome, int ordem) => HighlightLabel(
    id: _id('rotulo/$nome', _sp(7, 10, 18, ordem)),
    meta: _meta(_sp(7, 10, 18, ordem)),
    color: cor,
    label: nome,
    sort: ordem,
  );

  final inicioDaConta = _sp(7, 10, 18);

  return Mundo(
    agora: agora,
    fuso: _fuso,
    usuarioId: _usuario,
    aparelhoId: _aparelho,
    perfil: (nome: 'Marina', inicial: 'M', notificacoesNaoLidas: 2),
    livros: livros,
    slugs: ids,
    posicoes: posicoes,
    sessoes: sessoes,
    marcadores: marcadores,
    anotacoes: [
      p3, p6, p6nota, p41, p121, p152, p152nota, //
      p159grifo, p159elipse, p159notaAMao, p159ondulado, p159duplo,
      ...outros,
    ],
    camadas: [elipse, espaco, ondulado, duplo],
    rotulos: [
      rotulo(CoresDoMundo.amarelo, 'lindo', 0),
      rotulo(CoresDoMundo.rosa, 'personagem', 1),
      rotulo(CoresDoMundo.verde, 'ideia', 2),
      rotulo(CoresDoMundo.lavanda, 'pro clube', 3),
    ],
    // telas 23/26: os padrões do SQL são o estado das pranchas
    ajustes: ReaderSettings(id: _usuario, meta: _meta(inicioDaConta)),
    caneta: PenPresets(id: _usuario, meta: _meta(inicioDaConta)),
    metas: ReadingGoals(
      id: _usuario,
      meta: _meta(inicioDaConta),
      dailyMinutes: 30, // "18 de 30" (Início)
      badgeTargetDays: 14, // selo com 14 dias (Início)
    ),
    clube: (
      id: clubeId,
      nomePrefixo: 'Leitoras de',
      nomeDestaque: 'Capitu',
      livroSlug: Slugs.domCasmurro,
      metaCapitulo:
          50, // "Até o cap. L · faltam 18" (tela 27) — a Início diz 100 (Q25)
      proximoEncontro: _sp(9, 24, 20), // quinta 24/09 20:00 ("QUI 24/9")
      participantes: 11,
      exibidos: const [
        (inicial: 'A', cor: AppColors.lavender),
        (inicial: 'J', cor: AppColors.leaf),
        (inicial: 'L', cor: AppColors.blush),
      ],
      progressoDoGrupo: 0.54,
      inicialDaUsuaria: 'M',
      mensagensNaoLidas: 3,
      postCompartilhadoId: postDoClube,
      respostasDoPost: 3, // "· 3 respostas" (tela 25)
    ),
    paraVoceAutor: 'Machado de Assis',
    paraVoce: const [
      (
        slug: 'memorias-postumas-de-bras-cubas',
        titulo: 'Memórias Póstumas de Brás Cubas',
        tituloCurto: 'Memórias Póstumas',
        autor: 'Machado de Assis',
      ),
      (
        slug: 'quincas-borba',
        titulo: 'Quincas Borba',
        tituloCurto: null,
        autor: 'Machado de Assis',
      ),
      (
        slug: 'o-cortico',
        titulo: 'O Cortiço',
        tituloCurto: null,
        autor: 'Aluísio Azevedo',
      ),
    ],
    tempoRestante: const {Slugs.domCasmurro: Duration(hours: 2, minutes: 10)},
    textosDosCapitulos: _textos,
    // Tela 25: os trechos de cada cartão como o arquivo escreve (contexto cinza literal — D-49).
    cartoesDaTela25: [
      (
        grupoId: p3.groupId,
        trechos: [
          (
            texto: '…encontrei no trem da Central um rapaz aqui do bairro, ',
            anotacaoId: null,
          ),
          (texto: 'que eu conheço de vista e de chapéu.', anotacaoId: p3.id),
        ],
      ),
      (
        grupoId: p6.groupId,
        trechos: [
          (
            texto: 'O meu fim evidente era atar as duas pontas da vida, e restaurar na velhice a adolescência.',
            anotacaoId: p6.id,
          ),
        ],
      ),
      (
        grupoId: p41.groupId,
        trechos: [
          (texto: '— ', anotacaoId: null),
          (texto: 'A vida é uma ópera e uma grande ópera.', anotacaoId: p41.id),
        ],
      ),
      (
        grupoId: p121.groupId,
        trechos: [
          (texto: '…', anotacaoId: null),
          (
            texto: 'olhos de cigana oblíqua e dissimulada.',
            anotacaoId: p121.id,
          ),
        ],
      ),
      (
        grupoId: p152.groupId,
        trechos: [
          (
            texto: 'Capitu era Capitu, isto é, uma criatura mui particular, mais mulher do que eu era homem.',
            anotacaoId: p152.id,
          ),
        ],
      ),
      (
        grupoId: p159grifo.groupId,
        trechos: [
          (texto: '…o que foram aqueles ', anotacaoId: null),
          (texto: 'olhos de Capitu', anotacaoId: p159grifo.id),
          (texto: '.', anotacaoId: null),
        ],
      ),
      (
        grupoId: p159elipse.groupId,
        trechos: [
          (texto: 'Olhos de ressaca?', anotacaoId: p159elipse.id),
          (texto: ' ', anotacaoId: null),
          (texto: 'Vá, de ressaca.', anotacaoId: null),
        ],
      ),
      (
        grupoId: p159ondulado.groupId,
        trechos: [
          (texto: 'Traziam não sei que ', anotacaoId: null),
          (texto: 'fluido misterioso', anotacaoId: p159ondulado.id),
          (
            texto: ' e enérgico, uma força que arrastava para dentro, como ',
            anotacaoId: null,
          ),
          (texto: 'a vaga que se retira', anotacaoId: p159duplo.id),
          (texto: ' da praia…', anotacaoId: null),
        ],
      ),
    ],
  );
}

// G19 — o mundo da tela 25 no banco (D-34): o Dom Casmurro do mundo (a linha do livro, o EPUB do mundo com o índice
// da tela 19 e a posição na pág. 159) com as 12 anotações e as 4 camadas de tinta (a de hoje também: a tela 25 mostra
// os itens de hoje), e as dependências da tela com as fontes da fixture: os trechos literais de cada cartão
// (`cartoesDaTela25` — D-49), o clube do mundo (no app, nenhum até a G21 — R8), o relógio e o fuso do mundo.
import 'dart:async';

import 'package:app_leitura/core/data/database/daos/annotation_daos.dart';
import 'package:app_leitura/core/data/database/daos/reader_daos.dart';
import 'package:app_leitura/features/highlights/application/card_text_source.dart';
import 'package:app_leitura/features/highlights/application/highlights_club_source.dart';
import 'package:app_leitura/features/highlights/application/highlights_controller.dart';
import 'package:app_leitura/features/highlights/application/highlights_file_sink.dart';
import 'package:app_leitura/features/highlights/application/highlights_repository.dart';
import 'package:app_leitura/features/highlights/application/highlights_share.dart';
import 'package:app_leitura/features/highlights/domain/highlight_card.dart';

import '../fixtures/mundo_2026_09_20.dart';
import '../fixtures/telas/indice_t19.dart';
import 'mundo_epub.dart';
import 'reader_harness.dart';

/// O Dom Casmurro da tela 25 na estante da conta do mundo.
Future<LivroNaEstante> livroDaTela25({bool comAnotacoes = true}) async {
  final m = mundoReferencia;
  final livro = await LivroNaEstante.epubDe(
    mundoEpub(Slugs.domCasmurro, completo: true),
    livro: m.domCasmurro,
    leitor: m.usuarioId,
  );
  await livro.usarIndice(indiceDaTela19(livro.index));
  await livro.guardarPosicao(itemDaPagina159, 0);
  final db = livro.db;
  for (final s in m.sessoes) {
    await ReadingSessionsDao(db).upsert(s);
  }
  for (final b in m.marcadores) {
    await BookmarksDao(db).upsert(b);
  }
  await ReaderSettingsDao(db).upsert(m.ajustes);
  if (comAnotacoes) {
    for (final l in m.camadas) {
      await InkLayersDao(db).upsert(l);
    }
    for (final a in m.anotacoes) {
      await AnnotationsDao(db).upsert(a);
    }
  }
  return livro;
}

/// Os trechos literais de cada cartão da tela 25 (o contexto cinza que o arquivo escreveu à mão — D-49).
final class TrechosDaTela25 implements CardTextSource {
  const TrechosDaTela25({this.semLugar = const {}});

  /// Os grupos que a fonte diz sem lugar (D-199).
  final Set<String> semLugar;

  @override
  Future<CardTexts> textsFor(List<HighlightCard> cards) async {
    final literais = {
      for (final c in mundoReferencia.cartoesDaTela25)
        c.grupoId: [
          for (final t in c.trechos)
            (text: t.texto, annotationId: t.anotacaoId),
        ],
    };
    final recuo = await const AnchorOnlyCardTextSource().textsFor(cards);
    return CardTexts({
      for (final c in cards)
        c.groupId: literais[c.groupId] ?? recuo.byGroup[c.groupId]!,
    }, semLugar);
  }
}

/// O clube do mundo: "Leitoras de Capitu · 3 respostas" no post da pág. 152.
final class ClubeDaTela25 implements HighlightsClubSource {
  const ClubeDaTela25();

  @override
  Future<ClubChip?> clubOf(String sharedClubPostId) async {
    final c = mundoReferencia.clube;
    return sharedClubPostId == c.postCompartilhadoId
        ? (
            clubId: c.id,
            name: '${c.nomePrefixo} ${c.nomeDestaque}',
            replies: c.respostasDoPost,
          )
        : null;
  }
}

/// Guarda o que a tela mandou compartilhar (nome, conteúdo, tipo); [falhar] simula o disco cheio.
final class ArquivosDeTeste implements HighlightsFileSink {
  final List<({String fileName, String content, String mimeType})> feitos = [];
  bool falhar = false;

  /// Segura a entrega até completar (como a folha de compartilhar do sistema, que fica aberta).
  Completer<void>? segurar;

  @override
  Future<void> share({
    required String fileName,
    required String content,
    required String mimeType,
  }) async {
    if (segurar case final s?) await s.future;
    if (falhar) throw StateError('disco cheio');
    feitos.add((fileName: fileName, content: content, mimeType: mimeType));
  }
}

/// As dependências da tela 25 no relógio e no fuso do mundo, com as fontes da fixture.
HighlightsDeps depsDaTela25(
  LivroNaEstante livro, {
  ArquivosDeTeste? arquivos,
  CardTextSource texto = const TrechosDaTela25(),
  HighlightsClubSource clube = const ClubeDaTela25(),
  List<Object>? erros,
  Duration espera = const Duration(milliseconds: 200),
  HighlightsShare? compartilhar,
}) => HighlightsDeps(
  db: livro.db,
  repository: HighlightsRepository(
    db: livro.db,
    versioning: livro.versioning,
    owner: () async => livro.leitor,
  ),
  textSourceFor: (_) async => texto,
  club: clube,
  now: () => mundoReferencia.agora,
  utcOffsetAt: (_) => mundoReferencia.fuso,
  files: arquivos ?? ArquivosDeTeste(),
  // sem a lista [erros], um erro derruba o teste (nada é engolido)
  onError: (e, st) =>
      erros == null ? Error.throwWithStackTrace(e, st) : erros.add(e),
  searchDelay: espera,
  share: compartilhar,
);

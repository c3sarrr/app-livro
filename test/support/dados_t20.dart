// G12.5 — o mundo da tela 20 no banco do leitor (D-34): o Dom Casmurro do mundo (a linha do livro, o EPUB do mundo
// com o índice da tela 19 e a posição na pág. 159) e as linhas da conta do mundo — as sessões (os "18 min hoje"),
// os marcadores (a pág. 159 marcada), as camadas de tinta e as anotações (o contador 12 = 6 + 2 + 1 + 3) e o
// ajuste de leitura com o papel pedido. Nada é escrito à mão: a tela calcula tudo dessas linhas.
import 'package:app_leitura/core/data/database/daos/annotation_daos.dart';
import 'package:app_leitura/core/data/database/daos/reader_daos.dart';
import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/features/reader/annotations/ink_repository.dart';
import 'package:app_leitura/features/reader/application/reader_session_controller.dart';
import 'package:app_leitura/features/reader/domain/reader_settings.dart';

import '../fixtures/mundo_2026_09_20.dart';
import '../fixtures/telas/indice_t19.dart';
import '../fixtures/telas/instantaneo.dart' show mundoSemTintaDeHoje;
import 'mundo_epub.dart';
import 'pump_reader.dart' show LeitorNaTela;
import 'reader_harness.dart';

/// O Dom Casmurro da tela 20 (e da 26b, com [papel] Noite) na estante da conta do mundo.
Future<LivroNaEstante> livroDaTela20({
  ReaderPaper papel = ReaderPaper.creme,
}) async {
  // D-169: a tinta de hoje fica no banco sem lugar (conta e não pinta)
  final m = mundoSemTintaDeHoje;
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
  for (final l in m.camadas) {
    await InkLayersDao(db).upsert(l);
  }
  for (final a in m.anotacoes) {
    await AnnotationsDao(db).upsert(a);
  }
  await ReaderSettingsDao(db).upsert(m.ajustes.copyWith(paper: papel));
  return livro;
}

/// A velocidade que faz o tempo restante da pág. 159 dar os 130 min ("≈ 2 h 10 min") que a prancha escreve à
/// mão. Pela velocidade das sessões do mundo dá ~1 h 10 min (G10); o desvio fica registrado na G12.
double velocidadeDaPrancha(LivroNaEstante livro) {
  final total = livro.index.totalChars;
  final antes = livro.index.globalOffset(itemDaPagina159, 0)!;
  final progresso = double.parse((antes / total).toStringAsFixed(5));
  final restantes = ((1 - progresso) * total).round();
  return restantes / 130;
}

/// As dependências do leitor no relógio do mundo (20/09/2026 20:00 em São Paulo), sem o tempo andar, e com a
/// velocidade da prancha.
Future<ReaderDeps> depsDaTela20(
  LeitorNaTela t,
  LivroNaEstante livro, {
  InkRepository? ink,
  Future<String> Function()? owner,
}) async => livro.readerDeps(
  awake: t.awake,
  onError: (e, _) => t.erros.add(e),
  now: () => mundoReferencia.agora,
  elapsed: () => Duration.zero,
  speedOf: (AppDatabase _, String _) async => velocidadeDaPrancha(livro),
  ink: ink,
  owner: owner,
);

// R00 (D-267, R6) — o mundo de referência gravado num banco do aparelho, para o modo demonstração: os dados pessoais
// do mundo (`Mundo.gravarEm` — o Dom Casmurro na pág. 159 de 256, as 12 anotações, a tinta, os marcadores, as metas e
// as sessões), o EPUB do Dom Casmurro com o índice injetado das telas do leitor, a camada da prancha 01
// (`camada_inicio01.dart`) e o clube no cache do social (`clube_demonstracao.dart`). O dono do mundo (a Marina) é o
// convidado e o dono ativo: sem servidor o app é só convidado (D-64), e é ele que a Início mostra. Uma vez por banco
// (a marca `demonstracao.semeado` no `kv`). Sem flutter_test: entra no app (`main_demonstracao.dart`).
import 'dart:io';

import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/daos/content_daos.dart';
import 'package:app_leitura/core/data/database/daos/kv_dao.dart';
import 'package:app_leitura/features/account/data/local_library.dart';
import 'package:app_leitura/features/reader/content/book_index.dart';

import '../../support/mundo_epub.dart';
import '../mundo_2026_09_20.dart';
import '../telas/indice_t19.dart';
import 'camada_inicio01.dart';
import 'clube_demonstracao.dart';

/// A marca do banco já semeado, com a versão da semeadura (um banco com a marca de outra versão recomeça do zero —
/// `bancoDaDemonstracao`).
const String chaveSemeado = 'demonstracao.semeado';
const String versaoDaSemeadura = 'r00-v1';

/// O banco [db] já tem o mundo desta versão.
Future<bool> semeado(AppDatabase db) async =>
    await KvDao(db).get(chaveSemeado) == versaoDaSemeadura;

/// O arquivo do Dom Casmurro na pasta [livros] (o nome que a importação usa: `<id do livro>.epub`).
File arquivoDoDomCasmurro(Directory livros) => File(
  '${livros.path}${Platform.pathSeparator}${mundoReferencia.domCasmurro.id}.epub',
);

/// Grava o mundo, o EPUB e o índice, a camada da 01, o clube e o dono em [db]; [livros] = a pasta dos arquivos.
Future<void> semearMundo(AppDatabase db, {required Directory livros}) async {
  final m = mundoReferencia;
  await m.gravarEm(db);

  final dc = m.domCasmurro;
  final sha = dc.contentSha256!;
  final bytes = mundoEpub(Slugs.domCasmurro, completo: true);
  livros.createSync(recursive: true);
  final arquivo = arquivoDoDomCasmurro(livros)..writeAsBytesSync(bytes);
  await LocalFilesDao(db).upsert(
    userBookId: dc.id,
    path: arquivo.path,
    bytes: bytes.length,
    sha256: sha,
    now: m.agora,
  );
  // as contagens de um livro inteiro (pág. 159 de 256, 62 %) sobre o EPUB curto do mundo — o índice das telas
  // 19–27b (G11.5, D-34); os números continuam calculados pelo leitor
  await BookContentIndexDao(db).upsert(
    dc.id,
    indiceDaTela19(indexEpubFile(arquivo.path, sha)),
    builtAt: m.agora,
  );

  await gravarCamadaDaPrancha01(db);
  await gravarClubeDemonstracao(db, m.usuarioId);

  final kv = KvDao(db);
  await kv.set(OwnerKeys.guest, m.usuarioId);
  await LocalLibrary(db).setActiveOwner(m.usuarioId);
  await kv.set(chaveSemeado, versaoDaSemeadura);
}

/// Semeia [db] se ele ainda não tem o mundo desta versão (R6).
Future<void> semearSeFaltar(AppDatabase db, {required Directory livros}) async {
  if (await semeado(db)) return;
  await semearMundo(db, livros: livros);
}

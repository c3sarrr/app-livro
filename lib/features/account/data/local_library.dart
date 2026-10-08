// Biblioteca do aparelho por dono (D-68): cada conta — e o convidado — tem as suas linhas nas 10
// tabelas pessoais (coluna `user_id`). O app mostra só as do dono ATIVO. Entrar numa conta traz para
// ela o que foi feito como convidado; sair esconde (ou apaga, se a pessoa pedir). Nada daqui vai para
// a rede (o upload do Pro é outra porta — `lib/core/sync`, G06).
import 'dart:io' show Directory, File, FileSystemException, Platform;

import 'package:drift/drift.dart';

import '../../../core/data/database/app_database.dart';
import '../../../core/data/database/daos/kv_dao.dart';
import '../../../core/data/database/local_sql.dart';
import '../../../core/data/ids/uuid_v7.dart';
import '../../../core/sync/ebook_cloud.dart' show EbookCloud;
import '../../../core/sync/local_merge.dart';
import '../../reader/annotations/ink/ink_changes.dart' show draftKey;

/// Chaves no `kv` (só local).
abstract final class OwnerKeys {
  /// Dono das linhas feitas sem conta (gerado na 1ª vez).
  static const String guest = 'conta.convidado';

  /// Dono cujas linhas o app mostra agora (conta logada ou o convidado).
  static const String active = activeOwnerKey;

  /// "Menor de 13" já informado neste aparelho (D-66): outra data digitada não destrava o login.
  static const String underageBlocked = 'conta.menor_de_13';
}

/// Tabelas em que `id = user_id` (uma linha por dono).
const Set<String> singletonTables = {
  'reader_settings',
  'pen_presets',
  'reading_goals',
};

/// O resultado de juntar o convidado a uma conta (para o relatório/diagnóstico — sem conteúdo).
final class AdoptReport {
  const AdoptReport({
    required this.moved,
    required this.discarded,
    this.mergedBooks = 0,
  });

  /// Linhas que passaram para a conta.
  final int moved;

  /// Linhas do convidado descartadas por conflito (preferência única ou rótulo da mesma cor que a
  /// conta já tinha neste aparelho).
  final int discarded;

  /// Livros do convidado com o mesmo arquivo de um livro da conta: juntados ao da conta (o servidor
  /// não aceita dois livros ativos com o mesmo arquivo — G06).
  final int mergedBooks;
}

/// Apaga um arquivo do aparelho (o do livro). Arquivo que já não existe não é erro.
typedef FileRemover = Future<void> Function(String path);

Future<void> _removeFile(String path) async {
  try {
    await File(path).delete();
  } on FileSystemException {
    // já não existia (ou o sistema o removeu): nada a fazer
  }
}

final class LocalLibrary {
  LocalLibrary(
    this._db, {
    UuidV7Generator? ids,
    FileRemover? removeFile,
    this._fileCovers,
  }) : _kv = KvDao(_db),
       _ids = ids ?? UuidV7Generator(),
       _remove = removeFile ?? _removeFile;

  final AppDatabase _db;
  final KvDao _kv;
  final UuidV7Generator _ids;
  final FileRemover _remove;

  /// Pasta das capas que vieram nos arquivos (G09, D-90): somem com o último livro que usa o arquivo.
  final Future<Directory> Function()? _fileCovers;

  Iterable<String> get _tables => personalSyncColumns.keys;

  Future<String> guestOwnerId() async {
    final g = await _kv.get(OwnerKeys.guest);
    if (g != null) return g;
    final novo = _ids.next();
    await _kv.set(OwnerKeys.guest, novo);
    return novo;
  }

  Future<String> activeOwnerId() async =>
      await _kv.get(OwnerKeys.active) ?? await guestOwnerId();

  Stream<String?> watchActiveOwnerId() => _kv.watch(OwnerKeys.active);

  Future<void> setActiveOwner(String owner) => _kv.set(OwnerKeys.active, owner);

  Future<bool> isUnderageBlocked() async =>
      await _kv.get(OwnerKeys.underageBlocked) == '1';

  Future<void> setUnderageBlocked(bool blocked) =>
      _kv.set(OwnerKeys.underageBlocked, blocked ? '1' : '0');

  /// Donos com linhas neste aparelho, fora os de [except] (ex.: contas que saíram — D-68).
  Future<Set<String>> ownersExcept(Set<String> except) async {
    final owners = <String>{};
    for (final t in _tables) {
      final rows = await _db
          .customSelect('SELECT DISTINCT user_id FROM $t')
          .get();
      owners.addAll(rows.map((r) => r.read<String>('user_id')));
    }
    return owners.difference(except);
  }

  /// Linhas guardadas de todos os donos fora os de [except].
  Future<int> countRowsExcept(Set<String> except) async {
    var n = 0;
    for (final o in await ownersExcept(except)) {
      n += await countRows(o);
    }
    return n;
  }

  /// Quantas linhas pessoais (inclusive as apagadas logicamente) o dono tem neste aparelho.
  Future<int> countRows(String owner) async {
    var n = 0;
    for (final t in _tables) {
      final r = await _db
          .customSelect(
            'SELECT count(*) AS n FROM $t WHERE user_id = ?',
            variables: [Variable.withString(owner)],
          )
          .getSingle();
      n += r.read<int>('n');
    }
    return n;
  }

  /// Passa as linhas de [from] para [to]. Conflitos: nas tabelas de linha única vence a versão mais
  /// nova (LWW pelo `version_hlc`, o mesmo critério do servidor; o id passa a ser o da conta); num
  /// rótulo da mesma cor vence o que a conta já tinha (ele pode já estar no servidor); um livro com o
  /// mesmo arquivo de um livro da conta é juntado a ele (anotações, marcadores, sessões e posição
  /// passam para o da conta; do livro vale o estado mais novo).
  Future<AdoptReport> adopt({required String from, required String to}) async {
    if (from == to) return const AdoptReport(moved: 0, discarded: 0);
    final (report, files) = await _adopt(from, to);
    for (final f in files) {
      await _remove(f);
    }
    return report;
  }

  Future<(AdoptReport, List<String>)> _adopt(
    String from,
    String to,
  ) => _db.transaction(() async {
    var moved = 0, discarded = 0, merged = 0;
    final files = <String>[];
    final dups = await _db
        .customSelect(
          'SELECT g.id AS loser, a.id AS survivor FROM user_books g JOIN user_books a '
          'ON a.content_sha256 = g.content_sha256 AND a.user_id = ? AND a.deleted_at IS NULL '
          'WHERE g.user_id = ? AND g.deleted_at IS NULL AND g.content_sha256 IS NOT NULL',
          variables: [Variable.withString(to), Variable.withString(from)],
        )
        .get();
    for (final d in dups) {
      final m = await mergeUserBook(
        _db,
        loser: d.read<String>('loser'),
        survivor: d.read<String>('survivor'),
      );
      files.addAll(m.removedFiles);
      merged++;
    }
    for (final t in singletonTables) {
      final rows = await _db
          .customSelect(
            'SELECT id, version_hlc FROM $t WHERE id IN (?, ?)',
            variables: [Variable.withString(from), Variable.withString(to)],
          )
          .get();
      String? hlcOf(String id) => rows
          .where((r) => r.read<String>('id') == id)
          .map((r) => r.read<String>('version_hlc'))
          .firstOrNull;
      final mine = hlcOf(from);
      if (mine == null) continue;
      final theirs = hlcOf(to);
      if (theirs != null && mine.compareTo(theirs) <= 0) {
        await _db.customStatement('DELETE FROM $t WHERE id = ?', [from]);
        discarded++;
        continue;
      }
      if (theirs != null) {
        await _db.customStatement('DELETE FROM $t WHERE id = ?', [to]);
      }
      await _db.customStatement(
        'UPDATE $t SET id = ?, user_id = ? WHERE id = ?',
        [to, to, from],
      );
      moved++;
    }
    discarded += await _db.customUpdate(
      'DELETE FROM highlight_labels WHERE user_id = ? AND deleted_at IS NULL '
      'AND color IN (SELECT color FROM highlight_labels '
      'WHERE user_id = ? AND deleted_at IS NULL)',
      variables: [Variable.withString(from), Variable.withString(to)],
      updates: {_db.highlightLabels},
      updateKind: UpdateKind.delete,
    );
    for (final t in _tables.where((t) => !singletonTables.contains(t))) {
      moved += await _db.customUpdate(
        'UPDATE $t SET user_id = ? WHERE user_id = ?',
        variables: [Variable.withString(to), Variable.withString(from)],
        updates: {_tableInfo(t)},
      );
    }
    return (
      AdoptReport(moved: moved, discarded: discarded, mergedBooks: merged),
      files,
    );
  });

  /// Apaga DESTE APARELHO tudo o que é do [owner]: dados pessoais, índices/caches locais dos livros e
  /// os arquivos dos livros. Exclusão física — não é a exclusão lógica que sincroniza. Devolve quantas
  /// linhas saíram.
  Future<int> erase(String owner) async {
    final files = await _db
        .customSelect(
          'SELECT path FROM local_files WHERE user_book_id IN '
          '(SELECT id FROM user_books WHERE user_id = ?)',
          variables: [Variable.withString(owner)],
        )
        .get();
    final shas = await _db
        .customSelect(
          'SELECT DISTINCT content_sha256 AS sha FROM user_books '
          'WHERE user_id = ? AND content_sha256 IS NOT NULL',
          variables: [Variable.withString(owner)],
        )
        .get();
    final n = await _eraseRows(owner);
    // depois do banco: se o app fechar no meio, sobra no máximo um arquivo órfão, nunca uma linha
    // apontando para um arquivo apagado
    for (final f in files) {
      await _remove(f.read<String>('path'));
    }
    final covers = _fileCovers;
    if (covers != null) {
      final dir = await covers();
      for (final r in shas) {
        final sha = r.read<String>('sha');
        // outra conta deste aparelho com o mesmo arquivo: a capa fica
        final still = await _db
            .customSelect(
              'SELECT 1 FROM user_books WHERE content_sha256 = ? LIMIT 1',
              variables: [Variable.withString(sha)],
            )
            .getSingleOrNull();
        if (still == null) {
          await _remove('${dir.path}${Platform.pathSeparator}$sha.img');
        }
      }
    }
    return n;
  }

  Future<int> _eraseRows(String owner) => _db.transaction(() async {
    var n = 0;
    final books = Variable.withString(owner);
    for (final t in const [
      'local_files',
      'book_content_index',
      'page_layout_cache',
    ]) {
      n += await _db.customUpdate(
        'DELETE FROM $t WHERE user_book_id IN '
        '(SELECT id FROM user_books WHERE user_id = ?)',
        variables: [books],
        updates: {_tableInfo(t)},
        updateKind: UpdateKind.delete,
      );
    }
    // índice de busca (FTS5) dos grifos: tabela virtual sem gatilho de DELETE físico
    await _db.customStatement(
      'DELETE FROM annotations_fts WHERE annotation_id IN '
      '(SELECT id FROM annotations WHERE user_id = ?)',
      [owner],
    );
    // o que a sincronização guardou dessas linhas: recusas (com a operação inteira — título, nota,
    // traços), remoções ignoradas e envios de e-book pela metade (com o token) — revisão da G06
    for (final t in _tables) {
      for (final log in const ['sync_rejections', 'sync_ignored_deletes']) {
        await _db.customStatement(
          'DELETE FROM $log WHERE entity = ? AND row_id IN '
          '(SELECT id FROM $t WHERE user_id = ?)',
          [t, owner],
        );
      }
    }
    await _db.customStatement(
      "DELETE FROM sync_rejections WHERE json_extract(operation, '\$.data.user_id') = ?",
      [owner],
    );
    await _db.customStatement(
      "DELETE FROM kv WHERE key IN (SELECT '${EbookCloud.resumePrefix}' || id "
      'FROM user_books WHERE user_id = ?)',
      [owner],
    );
    // o rascunho da tinta (G16, com os traços): `ink_draft:<dono>:<livro>`
    final drafts = draftKey(owner, '');
    await _db.customStatement('DELETE FROM kv WHERE substr(key, 1, ?) = ?', [
      drafts.length,
      drafts,
    ]);
    for (final t in _tables) {
      n += await _db.customUpdate(
        'DELETE FROM $t WHERE user_id = ?',
        variables: [Variable.withString(owner)],
        updates: {_tableInfo(t)},
        updateKind: UpdateKind.delete,
      );
    }
    return n;
  });

  /// Cache social da conta anterior (perfil, clubes e posts para abrir offline) sai ao trocar de dono.
  Future<void> clearSocialCache() => _db.delete(_db.socialCache).go();

  /// Todas as linhas pessoais do [owner], por tabela, como o banco guarda (exportação — D-65).
  Future<Map<String, List<Map<String, Object?>>>> export(String owner) async {
    final out = <String, List<Map<String, Object?>>>{};
    for (final t in _tables) {
      final rows = await _db
          .customSelect(
            'SELECT * FROM $t WHERE user_id = ? ORDER BY id',
            variables: [Variable.withString(owner)],
          )
          .get();
      out[t] = [for (final r in rows) Map<String, Object?>.of(r.data)];
    }
    return out;
  }

  TableInfo<Table, Object?> _tableInfo(String name) =>
      _db.allTables.firstWhere((t) => t.actualTableName == name);
}

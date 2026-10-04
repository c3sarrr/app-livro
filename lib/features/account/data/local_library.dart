// Biblioteca do aparelho por dono (D-68): cada conta Ã¢â‚¬â€ e o convidado Ã¢â‚¬â€ tem as suas linhas nas 10
// tabelas pessoais (coluna `user_id`). O app mostra sÃƒÂ³ as do dono ATIVO. Entrar numa conta traz para
// ela o que foi feito como convidado; sair esconde (ou apaga, se a pessoa pedir). Nada daqui vai para
// a rede (o upload do Pro ÃƒÂ© outra porta Ã¢â‚¬â€ G06).
import 'dart:io' show File, FileSystemException;

import 'package:drift/drift.dart';

import '../../../core/data/database/app_database.dart';
import '../../../core/data/database/daos/kv_dao.dart';
import '../../../core/data/database/local_sql.dart';
import '../../../core/data/ids/uuid_v7.dart';

/// Chaves no `kv` (sÃƒÂ³ local).
abstract final class OwnerKeys {
  /// Dono das linhas feitas sem conta (gerado na 1Ã‚Âª vez).
  static const String guest = 'conta.convidado';

  /// Dono cujas linhas o app mostra agora (conta logada ou o convidado).
  static const String active = 'conta.dono_ativo';

  /// "Menor de 13" jÃƒÂ¡ informado neste aparelho (D-66): outra data digitada nÃƒÂ£o destrava o login.
  static const String underageBlocked = 'conta.menor_de_13';
}

/// Tabelas em que `id = user_id` (uma linha por dono).
const Set<String> singletonTables = {
  'reader_settings',
  'pen_presets',
  'reading_goals',
};

/// O resultado de juntar o convidado a uma conta (para o relatÃƒÂ³rio/diagnÃƒÂ³stico Ã¢â‚¬â€ sem conteÃƒÂºdo).
final class AdoptReport {
  const AdoptReport({required this.moved, required this.discarded});

  /// Linhas que passaram para a conta.
  final int moved;

  /// Linhas do convidado descartadas por conflito (preferÃƒÂªncia ÃƒÂºnica ou rÃƒÂ³tulo da mesma cor que a
  /// conta jÃƒÂ¡ tinha neste aparelho).
  final int discarded;
}

/// Apaga um arquivo do aparelho (o do livro). Arquivo que jÃƒÂ¡ nÃƒÂ£o existe nÃƒÂ£o ÃƒÂ© erro.
typedef FileRemover = Future<void> Function(String path);

Future<void> _removeFile(String path) async {
  try {
    await File(path).delete();
  } on FileSystemException {
    // jÃƒÂ¡ nÃƒÂ£o existia (ou o sistema o removeu): nada a fazer
  }
}

final class LocalLibrary {
  LocalLibrary(this._db, {UuidV7Generator? ids, FileRemover? removeFile})
    : _kv = KvDao(_db),
      _ids = ids ?? UuidV7Generator(),
      _remove = removeFile ?? _removeFile;

  final AppDatabase _db;
  final KvDao _kv;
  final UuidV7Generator _ids;
  final FileRemover _remove;

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

  /// Donos com linhas neste aparelho, fora os de [except] (ex.: contas que saÃƒÂ­ram Ã¢â‚¬â€ D-68).
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

  /// Passa as linhas de [from] para [to]. Conflitos: nas tabelas de linha ÃƒÂºnica vence a versÃƒÂ£o mais
  /// nova (LWW pelo `version_hlc`, o mesmo critÃƒÂ©rio do servidor; o id passa a ser o da conta); num
  /// rÃƒÂ³tulo da mesma cor vence o que a conta jÃƒÂ¡ tinha (ele pode jÃƒÂ¡ estar no servidor).
  Future<AdoptReport> adopt({required String from, required String to}) {
    if (from == to) {
      return Future.value(const AdoptReport(moved: 0, discarded: 0));
    }
    return _db.transaction(() async {
      var moved = 0, discarded = 0;
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
      return AdoptReport(moved: moved, discarded: discarded);
    });
  }

  /// Apaga DESTE APARELHO tudo o que ÃƒÂ© do [owner]: dados pessoais, ÃƒÂ­ndices/caches locais dos livros e
  /// os arquivos dos livros. ExclusÃƒÂ£o fÃƒÂ­sica Ã¢â‚¬â€ nÃƒÂ£o ÃƒÂ© a exclusÃƒÂ£o lÃƒÂ³gica que sincroniza. Devolve quantas
  /// linhas saÃƒÂ­ram.
  Future<int> erase(String owner) async {
    final files = await _db
        .customSelect(
          'SELECT path FROM local_files WHERE user_book_id IN '
          '(SELECT id FROM user_books WHERE user_id = ?)',
          variables: [Variable.withString(owner)],
        )
        .get();
    final n = await _eraseRows(owner);
    // depois do banco: se o app fechar no meio, sobra no mÃƒÂ¡ximo um arquivo ÃƒÂ³rfÃƒÂ£o, nunca uma linha
    // apontando para um arquivo apagado
    for (final f in files) {
      await _remove(f.read<String>('path'));
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
    // ÃƒÂ­ndice de busca (FTS5) dos grifos: tabela virtual sem gatilho de DELETE fÃƒÂ­sico
    await _db.customStatement(
      'DELETE FROM annotations_fts WHERE annotation_id IN '
      '(SELECT id FROM annotations WHERE user_id = ?)',
      [owner],
    );
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

  /// Todas as linhas pessoais do [owner], por tabela, como o banco guarda (exportaÃƒÂ§ÃƒÂ£o Ã¢â‚¬â€ D-65).
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

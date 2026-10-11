// Livro escaneado → estante (D-77): exemplar físico com o ISBN-13, "quero ler", do dono ativo (a conta
// ou o convidado — D-68). Um ISBN que já está numa linha ativa não vira outra (o scanner avisa).
// A versão vem de `LocalVersioning.write` (mesma transação da gravação — ADR-003); no Pro a linha entra
// na fila de sincronização pelos gatilhos, como qualquer escrita local.
import '../../../core/data/database/app_database.dart';
import '../../../core/data/database/daos/library_daos.dart';
import '../../../core/data/database/versioning.dart';
import '../../../core/data/ids/uuid_v7.dart';
import '../../../core/data/model/record_meta.dart';
import '../../library/domain/user_book.dart';

/// Resultado de pôr na estante.
sealed class ShelfAdd {
  const ShelfAdd(this.book);
  final UserBook book;
}

final class ShelfAdded extends ShelfAdd {
  const ShelfAdded(super.book);
}

/// Já estava (outro toque, outra aba) — nada foi criado.
final class ShelfAlreadyThere extends ShelfAdd {
  const ShelfAlreadyThere(super.book);
}

/// Texto que vai para a estante: espaços colapsados e no máximo [max] caracteres (CHECK do SQL).
String shelfText(String s, int max) {
  final t = s.trim().replaceAll(RegExp(r'\s+'), ' ');
  final r = t.runes;
  return r.length <= max ? t : String.fromCharCodes(r.take(max)).trimRight();
}

/// O `author_display` não pode ser vazio (CHECK 1…500).
const String unknownAuthor = 'Autoria desconhecida';

final class ScannedShelf {
  ScannedShelf({
    required this._db,
    required this._versioning,
    required this._owner,
    UuidV7Generator? ids,
  }) : _ids = ids ?? UuidV7Generator();

  final AppDatabase _db;
  final LocalVersioning _versioning;
  final Future<String> Function() _owner;
  final UuidV7Generator _ids;

  /// O livro ativo da estante com este ISBN (null = ainda não está).
  Future<UserBook?> onShelf(String isbn13) async =>
      UserBooksDao(_db).activeByIsbn(await _owner(), isbn13);

  Future<ShelfAdd> add({
    required String isbn13,
    required String title,
    required String authorDisplay,
    String? coverRef,
  }) async {
    final owner = await _owner();
    final id = _ids.next();
    return _versioning.write('user_books', id, (v) async {
      final dao = UserBooksDao(_db);
      // conferido DENTRO da transação: dois toques seguidos não criam dois livros
      final existing = await dao.activeByIsbn(owner, isbn13);
      if (existing != null) return ShelfAlreadyThere(existing);
      final at = DateTime.fromMillisecondsSinceEpoch(v.ms, isUtc: true);
      final autor = shelfText(authorDisplay, 500);
      final book = UserBook(
        id: id,
        meta: RecordMeta(
          userId: owner,
          createdAt: at,
          updatedAt: at,
          version: v,
        ),
        title: shelfText(title, 500),
        authorDisplay: autor.isEmpty ? unknownAuthor : autor,
        format: BookFileFormat.physical,
        status: ShelfStatus.wantToRead,
        coverRef: coverRef,
        addedAt: at,
        isbn13: isbn13,
      );
      await dao.upsert(book);
      return ShelfAdded(book);
    });
  }
}

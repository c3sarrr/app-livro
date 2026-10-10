// T04.3 — o livro da sessão do cronômetro (o que a mini-barra e a folha mostram) e as páginas do catálogo DO APARELHO
// para o "De quantas páginas é o livro?" (D-260): o cache do scanner e o catalog.db, nunca a rede.
import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/daos/library_daos.dart';
import 'package:app_leitura/core/data/database/daos/reader_daos.dart';
import 'package:app_leitura/features/catalog/data/catalog_cache_dao.dart';
import 'package:app_leitura/features/catalog/data/local_catalog.dart';
import 'package:app_leitura/features/catalog/domain/catalog_book.dart';
import 'package:app_leitura/features/home/domain/models.dart';
import 'package:app_leitura/features/library/domain/user_book.dart';
import 'package:app_leitura/features/reader/domain/locator.dart';
import 'package:app_leitura/features/reader/domain/reading_position.dart';
import 'package:app_leitura/features/reading_session/data/paper_book_source.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/personal_builders.dart';

const _isbn = '9788535910667';

UserBook _papel({
  String dono = usuarioTeste,
  bool apagado = false,
  int? total,
}) => UserBook(
  id: idTeste(1),
  meta: metaTeste(userId: dono, apagado: apagado),
  title: 'Memórias Póstumas de Brás Cubas',
  authorDisplay: 'Machado de Assis',
  format: BookFileFormat.physical,
  status: ShelfStatus.reading,
  refPagesTotal: total,
  coverRef: 'ol:123',
  addedAt: DateTime.utc(2026, 9, 1, 12),
  isbn13: _isbn,
);

CatalogBook _catalogo(int? paginas) => CatalogBook(
  isbn13: _isbn,
  title: 'Memórias Póstumas de Brás Cubas',
  pages: paginas,
  source: 'openlibrary',
);

final class _Catalogo implements LocalCatalog {
  _Catalogo(this.livro, {this.falha = false});
  final CatalogBook? livro;
  final bool falha;
  int consultas = 0;

  @override
  Future<CatalogBook?> byIsbn(String isbn13) async {
    consultas++;
    if (falha) throw StateError('catálogo trocando de versão');
    return isbn13 == livro?.isbn13 ? livro : null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false));
  tearDown(() => db.close());

  LocalPaperBookSource fonte([LocalCatalog? catalogo]) =>
      LocalPaperBookSource(db, catalog: () async => catalogo);

  test('o livro do dono: título, autor e capa como a Início monta; o total e a última página', () async {
    await UserBooksDao(db).upsert(_papel(total: 368));
    await ReadingPositionsDao(db).upsert(
      ReadingPosition(
        id: idTeste(1),
        meta: metaTeste(),
        locator: PaperLocator(96),
        refPage: 96,
        chapterIndex: 0,
        progression: 0.26087,
      ),
    );
    final l = (await fonte().book(usuarioTeste, idTeste(1)))!;
    expect(
      l.book,
      Book(
        id: idTeste(1),
        title: 'Memórias Póstumas de Brás Cubas',
        author: 'Machado de Assis',
        cover: const PhotoCover(ref: 'ol:123', isbn13: _isbn),
      ),
    );
    expect(l.pagesTotal, 368);
    expect(l.lastPage, 96);
    expect(l.isbn13, _isbn);
  });

  test(
    'sem posição: sem última página; posição apagada também não conta',
    () async {
      await UserBooksDao(db).upsert(_papel());
      expect((await fonte().book(usuarioTeste, idTeste(1)))!.lastPage, isNull);
      await ReadingPositionsDao(db).upsert(
        ReadingPosition(
          id: idTeste(1),
          meta: metaTeste(apagado: true),
          locator: PaperLocator(10),
          refPage: 10,
          chapterIndex: 0,
          progression: 0.1,
        ),
      );
      expect((await fonte().book(usuarioTeste, idTeste(1)))!.lastPage, isNull);
      expect(
        (await fonte().book(usuarioTeste, idTeste(1)))!.pagesTotal,
        isNull,
      );
    },
  );

  test('apagado, de outro dono ou inexistente: null', () async {
    expect(await fonte().book(usuarioTeste, idTeste(1)), isNull);
    await UserBooksDao(db).upsert(_papel(apagado: true));
    expect(await fonte().book(usuarioTeste, idTeste(1)), isNull);
    await UserBooksDao(db).upsert(_papel(dono: idTeste(99)));
    expect(await fonte().book(usuarioTeste, idTeste(1)), isNull);
  });

  test(
    'as páginas do catálogo: o cache do scanner primeiro, depois o catalog.db',
    () async {
      final catalogo = _Catalogo(_catalogo(400));
      await CatalogCacheDao(db)
          .putBook(_catalogo(368), DateTime.utc(2026, 9, 1));
      expect(await fonte(catalogo).catalogPages(_isbn), 368);
      expect(catalogo.consultas, 0, reason: 'o cache respondeu');

      await db.delete(db.catalogCache).go();
      expect(await fonte(catalogo).catalogPages(_isbn), 400);
      expect(catalogo.consultas, 1);
    },
  );

  test(
    'sem páginas, zero, catálogo ausente ou falhando: null (sem rede)',
    () async {
      await CatalogCacheDao(db)
          .putBook(_catalogo(null), DateTime.utc(2026, 9, 1));
      expect(await fonte(_Catalogo(_catalogo(0))).catalogPages(_isbn), isNull);
      expect(await fonte().catalogPages(_isbn), isNull);
      expect(
        await fonte(_Catalogo(null, falha: true)).catalogPages(_isbn),
        isNull,
      );
      expect(
        await fonte(_Catalogo(null)).catalogPages('9780000000002'),
        isNull,
      );
    },
  );
}

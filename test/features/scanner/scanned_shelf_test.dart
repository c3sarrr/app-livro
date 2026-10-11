// G07.5 / D-77 — livro escaneado vai para a estante como exemplar físico com o ISBN-13; o mesmo ISBN
// numa linha ativa não vira outra.
import 'package:app_leitura/core/data/clock/hlc.dart';
import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/daos/library_daos.dart';
import 'package:app_leitura/core/data/database/versioning.dart';
import 'package:app_leitura/core/data/ids/uuid_v7.dart';
import 'package:app_leitura/features/library/domain/user_book.dart';
import 'package:app_leitura/features/scanner/application/scanned_shelf.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/personal_builders.dart';

void main() {
  late AppDatabase db;
  late ScannedShelf shelf;
  var agora = DateTime.utc(2026, 10, 5, 12).millisecondsSinceEpoch;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false);
    agora = DateTime.utc(2026, 10, 5, 12).millisecondsSinceEpoch;
    shelf = ScannedShelf(
      db: db,
      versioning: LocalVersioning(
        db,
        HlcClock(deviceId: 'aparelhoA', nowMs: () => agora),
      ),
      owner: () async => usuarioTeste,
      ids: UuidV7Generator(clockMs: () => agora),
    );
  });
  tearDown(() => db.close());

  test('adiciona exemplar físico, "quero ler", com o ISBN, do dono ativo e com versão nova', () async {
    final r = await shelf.add(
      isbn13: '9788535902778',
      title: '  Dom   Casmurro ',
      authorDisplay: 'Machado de Assis',
      coverRef: 'ol:8231432',
    );
    expect(r, isA<ShelfAdded>());
    final b = (await UserBooksDao(db).byId(r.book.id))!;
    expect(
      [b.title, b.authorDisplay, b.format, b.status, b.isbn13, b.coverRef],
      [
        'Dom Casmurro',
        'Machado de Assis',
        BookFileFormat.physical,
        ShelfStatus.wantToRead,
        '9788535902778',
        'ol:8231432',
      ],
    );
    expect(b.meta.userId, usuarioTeste);
    expect(b.meta.version.ms, agora);
    expect(b.addedAt, DateTime.fromMillisecondsSinceEpoch(agora, isUtc: true));
    expect(await shelf.onShelf('9788535902778'), b);
  });

  test('o mesmo ISBN de novo: já está (nada criado); apagado da estante: pode entrar de novo', () async {
    final a = await shelf.add(
      isbn13: '9788535902778',
      title: 'Dom Casmurro',
      authorDisplay: 'Machado',
    );
    agora += 1000;
    final b = await shelf.add(
      isbn13: '9788535902778',
      title: 'Outro',
      authorDisplay: 'X',
    );
    expect(
      b,
      isA<ShelfAlreadyThere>().having((x) => x.book.id, 'id', a.book.id),
    );
    expect(await UserBooksDao(db).shelf(usuarioTeste), hasLength(1));

    final apagado = a.book.copyWith(
      meta: a.book.meta.deleted(
        DateTime.fromMillisecondsSinceEpoch(agora, isUtc: true),
        Hlc(agora, 1, 'aparelhoA'),
      ),
    );
    await UserBooksDao(db).upsert(apagado);
    expect(await shelf.onShelf('9788535902778'), isNull);
    agora += 1000;
    expect(
      await shelf.add(
        isbn13: '9788535902778',
        title: 'Dom Casmurro',
        authorDisplay: 'M',
      ),
      isA<ShelfAdded>(),
    );
  });

  test('sem autor: "Autoria desconhecida"; texto longo é cortado no limite do servidor (500)', () async {
    final r = await shelf.add(
      isbn13: '9786586490008',
      title: 'Livro ${'x' * 600}',
      authorDisplay: '   ',
    );
    expect(r.book.authorDisplay, unknownAuthor);
    expect(r.book.title.runes.length, 500);
  });

  test(
    'livro de outra conta guardada no aparelho não conta como "já está" (D-68)',
    () async {
      await UserBooksDao(db)
          .upsert(livroTeste(7, dono: idTeste(99)).copyWith());
      final outro = ScannedShelf(
        db: db,
        versioning: LocalVersioning(db, HlcClock(deviceId: 'aparelhoA')),
        owner: () async => idTeste(99),
      );
      await outro.add(
        isbn13: '9788535902778',
        title: 'Dom',
        authorDisplay: 'M',
      );
      expect(await shelf.onShelf('9788535902778'), isNull);
    },
  );
}

// T04.3 — o que o fim da sessão do cronômetro grava (R7, R3, R4, D-260, D-261): a sessão (`timer`), a posição do papel
// (`PaperLocator`), o `last_opened_at` e o total de páginas — numa transação, cada linha com versão nova (HLC).
import 'package:app_leitura/core/data/clock/hlc.dart';
import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/daos/library_daos.dart';
import 'package:app_leitura/core/data/database/daos/reader_daos.dart';
import 'package:app_leitura/core/data/database/versioning.dart';
import 'package:app_leitura/core/data/model/record_meta.dart';
import 'package:app_leitura/features/library/domain/user_book.dart';
import 'package:app_leitura/features/reader/domain/locator.dart';
import 'package:app_leitura/features/reader/domain/reading_position.dart';
import 'package:app_leitura/features/reader/domain/reading_session.dart';
import 'package:app_leitura/features/reading_session/data/paper_session_writer.dart';
import 'package:app_leitura/features/reading_session/domain/open_paper_session.dart';
import 'package:app_leitura/features/reading_session/domain/paper_timer_failure.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/personal_builders.dart';

/// 20/09/2026 19:51:18 em São Paulo.
final _inicio = DateTime.utc(2026, 9, 20, 22, 51, 18);
final _fim = _inicio.add(const Duration(minutes: 8, seconds: 42));

/// O Brás Cubas de papel do teste (sem arquivo).
UserBook _papel({
  int? total,
  String dono = usuarioTeste,
  bool apagado = false,
}) => UserBook(
  id: idTeste(1),
  meta: metaTeste(userId: dono, apagado: apagado),
  title: 'Memórias Póstumas de Brás Cubas',
  authorDisplay: 'Machado de Assis',
  format: BookFileFormat.physical,
  status: ShelfStatus.reading,
  refPagesTotal: total,
  addedAt: DateTime.utc(2026, 9, 1, 12),
  isbn13: '9788535910667',
);

PaperSessionRecord _registro({int segundos = 522}) => PaperSessionRecord(
  id: idTeste(50),
  userBookId: idTeste(1),
  startedAt: _inicio,
  endedAt: _inicio.add(Duration(seconds: segundos)),
  activeSeconds: segundos,
);

void main() {
  late AppDatabase db;
  late LocalPaperSessionWriter writer;
  var agoraMs = DateTime.utc(2026, 9, 20, 23).millisecondsSinceEpoch;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false);
    agoraMs = DateTime.utc(2026, 9, 20, 23).millisecondsSinceEpoch;
    writer = LocalPaperSessionWriter(
      db: db,
      versioning: LocalVersioning(
        db,
        HlcClock(deviceId: 'aparelhoA', nowMs: () => agoraMs),
      ),
      owner: () async => usuarioTeste,
      deviceId: 'aparelhoA',
    );
  });
  tearDown(() => db.close());

  Future<void> posicaoAntes(int pagina) => ReadingPositionsDao(db).upsert(
    ReadingPosition(
      id: idTeste(1),
      meta: metaTeste(),
      locator: PaperLocator(pagina),
      refPage: pagina,
      chapterIndex: 0,
      progression: 0.1,
    ),
  );

  Future<List<ReadingSession>> sessoes() =>
      ReadingSessionsDao(db).forBook(idTeste(1));

  test('encerrar com página e total: as 3 tabelas, com versão nova (R7, D-260, D-261)', () async {
    await UserBooksDao(db).upsert(_papel());
    await posicaoAntes(96);
    await writer.end(
      PaperSessionEnd(
        userBookId: idTeste(1),
        record: _registro(),
        at: _fim,
        page: 120,
        pagesTotal: 368,
      ),
    );

    final s = (await sessoes()).single;
    expect(s.id, idTeste(50));
    expect(s.startedAt, _inicio);
    expect(s.endedAt, _fim);
    expect(s.activeSeconds, 522);
    expect(s.source, SessionSource.timer);
    expect(s.refPageFrom, 96);
    expect(s.refPageTo, 120);
    expect(s.pagesViewed, 24);
    expect(s.deviceId, 'aparelhoA');
    expect(s.meta.userId, usuarioTeste);
    expect(s.meta.createdAt, _inicio);

    final p = (await ReadingPositionsDao(db).forBook(idTeste(1)))!;
    expect(p.locator, PaperLocator(120));
    expect(p.refPage, 120);
    expect(p.chapterIndex, 0);
    expect(p.progression, 0.32609); // 120 ÷ 368 em 5 casas
    expect(p.deviceId, 'aparelhoA');
    expect(p.meta.version.ms, agoraMs);

    final b = (await UserBooksDao(db).byId(idTeste(1)))!;
    expect(b.lastOpenedAt, _fim);
    expect(b.refPagesTotal, 368);
    expect(b.meta.version.ms, agoraMs);
    expect(b.meta.updatedAt.millisecondsSinceEpoch, agoraMs);
    expect(b.meta.version.compareTo(metaTeste().version), greaterThan(0));
  });

  test('o total que o livro já tem vale; a página fica dentro dele', () async {
    await UserBooksDao(db).upsert(_papel(total: 368));
    await writer.end(
      PaperSessionEnd(
        userBookId: idTeste(1),
        record: _registro(),
        at: _fim,
        page: 368,
      ),
    );
    final p = (await ReadingPositionsDao(db).forBook(idTeste(1)))!;
    expect(p.progression, 1);
    expect((await UserBooksDao(db).byId(idTeste(1)))!.refPagesTotal, 368);
  });

  test('sem posição antes: de nulo, sem páginas vistas; voltando páginas: sem páginas vistas', () async {
    await UserBooksDao(db).upsert(_papel(total: 368));
    await writer.end(
      PaperSessionEnd(
        userBookId: idTeste(1),
        record: _registro(),
        at: _fim,
        page: 120,
      ),
    );
    var s = (await sessoes()).single;
    expect(s.refPageFrom, isNull);
    expect(s.refPageTo, 120);
    expect(s.pagesViewed, isNull);

    agoraMs += 60000;
    await writer.end(
      PaperSessionEnd(
        userBookId: idTeste(1),
        record: PaperSessionRecord(
          id: idTeste(51),
          userBookId: idTeste(1),
          startedAt: _fim,
          endedAt: _fim.add(const Duration(minutes: 5)),
          activeSeconds: 300,
        ),
        at: _fim.add(const Duration(minutes: 5)),
        page: 90,
      ),
    );
    s = (await sessoes()).firstWhere((x) => x.id == idTeste(51));
    expect(s.refPageFrom, 120);
    expect(s.refPageTo, 90);
    expect(s.pagesViewed, isNull, reason: 'negativo não é página vista');
  });

  test('sem página: a sessão e o last_opened_at, nenhuma posição', () async {
    await UserBooksDao(db).upsert(_papel());
    await writer.end(
      PaperSessionEnd(userBookId: idTeste(1), record: _registro(), at: _fim),
    );
    final s = (await sessoes()).single;
    expect(s.refPageTo, isNull);
    expect(await ReadingPositionsDao(db).forBook(idTeste(1)), isNull);
    expect((await UserBooksDao(db).byId(idTeste(1)))!.lastOpenedAt, _fim);
    expect((await UserBooksDao(db).byId(idTeste(1)))!.refPagesTotal, isNull);
  });

  test('menos de 10 s com página: a posição, o total e o last_opened_at; a sessão não (R3)', () async {
    await UserBooksDao(db).upsert(_papel());
    await writer.end(
      PaperSessionEnd(
        userBookId: idTeste(1),
        record: null,
        at: _fim,
        page: 10,
        pagesTotal: 200,
      ),
    );
    expect(await sessoes(), isEmpty);
    expect((await ReadingPositionsDao(db).forBook(idTeste(1)))!.refPage, 10);
    final b = (await UserBooksDao(db).byId(idTeste(1)))!;
    expect(b.lastOpenedAt, _fim);
    expect(b.refPagesTotal, 200);
  });

  test('menos de 10 s sem página: nada é gravado (é descartar)', () async {
    await UserBooksDao(db).upsert(_papel());
    final antes = (await UserBooksDao(db).byId(idTeste(1)))!;
    await writer.end(
      PaperSessionEnd(userBookId: idTeste(1), record: null, at: _fim),
    );
    expect(await sessoes(), isEmpty);
    expect(await ReadingPositionsDao(db).forBook(idTeste(1)), isNull);
    expect(await UserBooksDao(db).byId(idTeste(1)), antes);
  });

  test('a guarda: página sem total, fora de 1…total, total menor que 1 → ArgumentError e nada gravado', () async {
    await UserBooksDao(db).upsert(_papel());
    final antes = (await UserBooksDao(db).byId(idTeste(1)))!;
    for (final (pagina, total) in [(10, null), (0, 200), (201, 200), (5, 0)]) {
      await expectLater(
        writer.end(
          PaperSessionEnd(
            userBookId: idTeste(1),
            record: _registro(),
            at: _fim,
            page: pagina,
            pagesTotal: total,
          ),
        ),
        throwsArgumentError,
        reason: 'pág. $pagina de $total',
      );
    }
    expect(await sessoes(), isEmpty);
    expect(await UserBooksDao(db).byId(idTeste(1)), antes);
  });

  test(
    'livro apagado ou de outro dono: PaperBookGone e nada gravado',
    () async {
      await UserBooksDao(db).upsert(_papel(apagado: true));
      await expectLater(
        writer.end(
          PaperSessionEnd(
            userBookId: idTeste(1),
            record: _registro(),
            at: _fim,
          ),
        ),
        throwsA(isA<PaperBookGone>()),
      );
      await UserBooksDao(db).upsert(_papel(dono: idTeste(99)));
      await expectLater(
        writer.end(
          PaperSessionEnd(
            userBookId: idTeste(1),
            record: _registro(),
            at: _fim,
          ),
        ),
        throwsA(isA<PaperBookGone>()),
      );
      await expectLater(
        writer.recordOnly(_registro()),
        throwsA(isA<PaperBookGone>()),
      );
      expect(await sessoes(), isEmpty);
    },
  );

  test('uma transação: a falha no meio não deixa a sessão gravada', () async {
    await UserBooksDao(db).upsert(_papel());
    // a última das 3 gravações (o livro) falha: a sessão e a posição, já feitas, não podem ficar
    await db.customStatement(
      "CREATE TRIGGER falha_livro BEFORE UPDATE ON user_books BEGIN SELECT RAISE(ABORT, 'falha'); END",
    );
    await expectLater(
      writer.end(
        PaperSessionEnd(
          userBookId: idTeste(1),
          record: _registro(),
          at: _fim,
          page: 120,
          pagesTotal: 368,
        ),
      ),
      throwsA(anything),
    );
    expect(await sessoes(), isEmpty);
    expect(await ReadingPositionsDao(db).forBook(idTeste(1)), isNull);
  });

  test('recordOnly (a divisão do dia, R4): só a sessão — sem posição nem last_opened_at', () async {
    await UserBooksDao(db).upsert(_papel());
    await posicaoAntes(96);
    final antes = (await UserBooksDao(db).byId(idTeste(1)))!;
    await writer.recordOnly(_registro());
    final s = (await sessoes()).single;
    expect(s.source, SessionSource.timer);
    expect(s.refPageFrom, 96);
    expect(s.refPageTo, isNull);
    expect(s.pagesViewed, isNull);
    expect(await UserBooksDao(db).byId(idTeste(1)), antes);
    expect((await ReadingPositionsDao(db).forBook(idTeste(1)))!.refPage, 96);
  });

  test('o meta da sessão é o do dono, nascido no início', () async {
    await UserBooksDao(db).upsert(_papel());
    await writer.recordOnly(_registro());
    final m = (await sessoes()).single.meta;
    expect(m, isA<RecordMeta>());
    expect(m.createdAt, _inicio);
    expect(m.isDeleted, isFalse);
    final n = await db
        .customSelect('SELECT count(*) AS n FROM reading_sessions')
        .getSingle();
    expect(n.read<int>('n'), 1);
  });
}

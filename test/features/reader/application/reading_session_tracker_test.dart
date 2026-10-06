// G10.4 — tempo que "conta sozinho" (Anexo 03 §8, D-27/D-95), com relógio de mentira: conta com o leitor
// visível, o app em primeiro plano e uma página na tela; parado 120 s, pausa (o tempo conta até os 120 s);
// segundo plano pausa e grava; voltar retoma a mesma sessão; < 10 s não grava; página lida = ≥ 3 s ativa;
// a linha é regravada a cada 60 s ativos; "N min hoje" soma as de hoje e a aberta.
import 'package:app_leitura/core/data/clock/hlc.dart';
import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/daos/reader_daos.dart';
import 'package:app_leitura/core/data/database/versioning.dart';
import 'package:app_leitura/core/data/model/record_meta.dart';
import 'package:app_leitura/features/reader/application/reader_errors.dart';
import 'package:app_leitura/features/reader/application/reading_session_tracker.dart';
import 'package:app_leitura/features/reader/domain/reading_session.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/personal_builders.dart';

void main() {
  late AppDatabase db;
  late DateTime agora;
  setUp(() {
    db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false);
    agora = DateTime(2026, 10, 5, 15); // hora local do aparelho
  });
  tearDown(() => db.close());

  final livro = idTeste(3);

  ReadingSessionTracker contador({
    Future<String> Function()? dono,
    ReaderErrorReporter? erro,
  }) {
    final t = ReadingSessionTracker(
      db: db,
      versioning: LocalVersioning(db, HlcClock(deviceId: 'aparelhoA')),
      owner: dono ?? () async => usuarioTeste,
      onError: erro ?? (e, st) => fail('erro inesperado: $e'),
      userBookId: livro,
      deviceId: 'aparelhoA',
      now: () => agora,
      autoTick: false,
    );
    addTearDown(t.dispose);
    return t;
  }

  void passa(int segundos) => agora = agora.add(Duration(seconds: segundos));

  Future<List<ReadingSession>> gravadas() =>
      ReadingSessionsDao(db).forBook(livro);

  test(
    'só conta com o leitor visível, em primeiro plano e com página na tela',
    () async {
      final t = contador();
      await t.setVisible(true);
      passa(30);
      expect(t.counting, isFalse, reason: 'sem página na tela');
      await t.pageShown(10, 10);
      expect(t.counting, isTrue);
      passa(30);
      expect(t.activeSeconds, 30);
      await t.setVisible(false); // outra tela por cima
      passa(100);
      expect((t.counting, t.activeSeconds), (false, 30));
    },
  );

  test(
    'parado 120 s: pausa contando até os 120 s; mexer retoma a mesma sessão',
    () async {
      final t = contador();
      await t.setVisible(true);
      await t.pageShown(10, 10);
      passa(119);
      await t.tick();
      expect(t.counting, isTrue);
      passa(81); // 200 s sem tocar
      await t.tick();
      expect((t.counting, t.activeSeconds), (false, 120));
      final pausada = (await gravadas()).single;
      expect(pausada.activeSeconds, 120);
      expect(
        pausada.endedAt,
        agora.subtract(const Duration(seconds: 80)).toUtc(),
      );

      passa(100);
      expect(t.activeSeconds, 120, reason: 'parado não conta');
      await t.interaction();
      expect(t.counting, isTrue);
      passa(20);
      await t.close();
      final s = (await gravadas()).single;
      expect(s.id, pausada.id);
      expect(s.activeSeconds, 140);
      expect(s.startedAt, DateTime(2026, 10, 5, 15).toUtc());
      expect(s.endedAt, agora.toUtc());
      expect(
        (s.source, s.deviceId, s.userBookId),
        (SessionSource.auto, 'aparelhoA', livro),
      );
      expect(s.meta.userId, usuarioTeste);
      expect(s.pagesViewed, 1);
    },
  );

  test('segundo plano pausa e grava; voltar (mesmo depois de 120 s) retoma a mesma sessão', () async {
    final t = contador();
    await t.setVisible(true);
    await t.pageShown(4, 4);
    passa(20);
    await t.setForeground(false);
    expect((await gravadas()).single.activeSeconds, 20);
    passa(600);
    await t.setForeground(true);
    expect(t.counting, isTrue, reason: 'voltar ao app é interação');
    passa(15);
    await t.close();
    final s = (await gravadas()).single;
    expect(s.activeSeconds, 35);
    expect(s.endedAt.difference(s.startedAt), const Duration(seconds: 635));
  });

  test('sessão com menos de 10 s não é gravada', () async {
    final t = contador();
    await t.setVisible(true);
    await t.pageShown(1, 1);
    passa(9);
    await t.close();
    expect(await gravadas(), isEmpty);
    // fechar de novo não faz nada
    await t.close();
    await t.interaction();
    expect(t.counting, isFalse);
  });

  test('página lida = página de referência ≥ 3 s ativa na tela (somando as voltas)', () async {
    final t = contador();
    await t.setVisible(true);
    await t.pageShown(1, 1); // 2 s
    passa(2);
    await t.pageShown(2, 3); // uma tela com as págs. 2 e 3: 5 s
    passa(5);
    await t.pageShown(1, 1); // volta à 1: +2 s = 4 s
    passa(2);
    await t.pageShown(4, 4); // 2 s
    passa(2);
    await t.pageShown(5, 5); // 2,9 s
    passa(2);
    agora = agora.add(const Duration(milliseconds: 900));
    await t.close();
    final s = (await gravadas()).single;
    expect(s.pagesViewed, 3); // 1, 2 e 3
    expect((s.refPageFrom, s.refPageTo), (1, 5));
    expect(s.activeSeconds, 13);
  });

  test(
    'a sessão aberta é regravada a cada 60 s ativos, sempre a mesma linha',
    () async {
      final t = contador();
      await t.setVisible(true);
      await t.pageShown(7, 7);
      passa(30);
      await t.tick();
      expect(await gravadas(), isEmpty);
      passa(29);
      await t.interaction();
      passa(2);
      await t.tick(); // 61 s
      final primeira = (await gravadas()).single;
      expect(primeira.activeSeconds, 61);
      passa(39);
      await t.interaction();
      await t.tick(); // 100 s: só 39 desde a última
      expect((await gravadas()).single.activeSeconds, 61);
      passa(25);
      await t.tick(); // 125 s
      final segunda = (await gravadas()).single;
      expect(segunda.id, primeira.id);
      expect(segunda.activeSeconds, 125);
      expect(segunda.meta.createdAt, primeira.meta.createdAt);
      expect(
        segunda.meta.version.compareTo(primeira.meta.version),
        greaterThan(0),
      );
    },
  );

  test('falha ao gravar não para a contagem: vai para o relatório e a próxima gravação tenta de novo', () async {
    var falhas = 1;
    final erros = <Object>[];
    final t = contador(
      dono: () async {
        if (falhas-- > 0) throw StateError('disco cheio');
        return usuarioTeste;
      },
      erro: (e, _) => erros.add(e),
    );
    await t.setVisible(true);
    await t.pageShown(1, 1);
    passa(61);
    await t.tick();
    expect(erros, [isA<StateError>()]);
    expect(await gravadas(), isEmpty);
    expect(t.counting, isTrue);
    passa(1);
    await t.tick(); // tenta de novo no segundo seguinte
    expect((await gravadas()).single.activeSeconds, 62);
    expect(erros, hasLength(1));
  });

  test('"N min hoje": sessões que começaram hoje + a aberta, sem contar a aberta duas vezes', () async {
    final dao = ReadingSessionsDao(db);
    Future<void> sessao(int n, DateTime inicio, int segundos) => dao.upsert(
      ReadingSession(
        id: idTeste(n),
        meta: RecordMeta(
          userId: usuarioTeste,
          createdAt: inicio.toUtc(),
          updatedAt: inicio.toUtc(),
          version: Hlc(inicio.millisecondsSinceEpoch, 0, 'aparelhoA'),
        ),
        userBookId: idTeste(20 + n),
        startedAt: inicio.toUtc(),
        endedAt: inicio.add(Duration(seconds: segundos)).toUtc(),
        activeSeconds: segundos,
        source: SessionSource.auto,
      ),
    );
    await sessao(40, DateTime(2026, 10, 5, 0, 0), 300); // hoje, à meia-noite
    await sessao(41, DateTime(2026, 10, 4, 23, 50), 900); // ontem
    await sessao(42, DateTime(2026, 10, 5, 9), 59); // hoje

    expect(
      await minutesToday(db, userId: usuarioTeste, now: agora),
      5,
    ); // 359 s
    final t = contador();
    await t.setVisible(true);
    await t.pageShown(1, 1);
    passa(62);
    await t.interaction();
    passa(60);
    await t.tick(); // grava a aberta com 122 s
    passa(5);
    expect(t.activeSeconds, 127);
    expect(
      await minutesToday(db, userId: usuarioTeste, now: agora, open: t),
      (359 + 127) ~/ 60,
    );
    expect(await minutesToday(db, userId: 'outra', now: agora), 0);
  });
}

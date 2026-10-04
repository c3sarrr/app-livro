// G03.3 — o mesmo banco sobre a conexão do SDK do PowerSync (como no app): gatilhos da fila só no
// Pro, PUT com a linha inteira, `put` do servidor com LWW e `_extras`, `delete` que não apaga.
// (Arquivo temporário: o PowerSync abre várias conexões e não usa banco em memória.)
import 'dart:convert';
import 'dart:io';

import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/daos/annotation_daos.dart';
import 'package:app_leitura/core/data/database/daos/kv_dao.dart';
import 'package:app_leitura/core/data/database/daos/library_daos.dart';
import 'package:app_leitura/core/data/database/local_sql.dart';
import 'package:app_leitura/core/data/database/powersync_schema.dart';
import 'package:drift_sqlite_async/drift_sqlite_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powersync/powersync.dart' hide Column;

import '../../../support/personal_builders.dart';

void main() {
  late Directory dir;
  late PowerSyncDatabase ps;
  late AppDatabase db;
  late String caminho;
  var n = 0;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('booknest_g03_');
    caminho = '${dir.path}${Platform.pathSeparator}app_${n++}.db';
    ps = PowerSyncDatabase(schema: buildPowerSyncSchema(), path: caminho);
    await ps.initialize();
    db = AppDatabase(SqliteAsyncDriftConnection(ps));
    await db
        .customSelect('SELECT 1')
        .get(); // cria o esquema (migração do drift)
  });

  tearDown(() async {
    await db.close();
    await ps.close();
    await dir.delete(recursive: true);
  });

  Future<int> fila() async =>
      (await ps.get('SELECT count(*) n FROM ps_crud'))['n'] as int;

  test('esquema do PowerSync: só as 10 tabelas próprias', () {
    final s = buildPowerSyncSchema();
    expect(s.tables, isEmpty);
    expect(s.rawTables.map((t) => t.name), personalSyncColumns.keys);
  });

  test('Grátis: escrever não enche a fila', () async {
    expect(await KvDao(db).get(syncModeKey), syncModeFree);
    await UserBooksDao(db).upsert(livroTeste(1));
    await AnnotationsDao(db).upsert(grifoTeste(2, livro: idTeste(1)));
    expect(await fila(), 0);
    final r = await ps.get('SELECT powersync_in_sync_operation() s');
    expect(r['s'], 0);
  });

  test(
    'Pro: cada escrita vira um PUT com a linha inteira (formato da RPC)',
    () async {
      await KvDao(db).set(syncModeKey, syncModePro);
      await KvDao(db).set(activeOwnerKey, usuarioTeste);
      final livro = livroTeste(1);
      final grifo = grifoTeste(2, livro: livro.id);
      await UserBooksDao(db).upsert(livro);
      await AnnotationsDao(db).upsert(grifo);
      await AnnotationsDao(db).upsert(
        grifo.copyWith(meta: metaTeste(contador: 1)),
      ); // edição também é PUT (nunca PATCH)
      final lote = (await ps.getCrudBatch(limit: 500))!;
      expect(lote.crud.map((e) => (e.op, e.table, e.id)), [
        (UpdateType.put, 'user_books', livro.id),
        (UpdateType.put, 'annotations', grifo.id),
        (UpdateType.put, 'annotations', grifo.id),
      ]);
      final dados = lote.crud[1].opData!;
      expect(dados.keys.toSet(), personalSyncColumns['annotations']!.toSet());
      expect(dados['created_at'], '2026-09-20T23:00:00.000000Z');
      expect(dados['version_hlc'], '0001789945200000-0000-aparelhoA');
      expect(dados['kind'], 'highlight');
      expect(jsonDecode(dados['anchor'] as String), grifo.anchor.toJson());
      expect(
        lote.crud[2].opData!['version_hlc'],
        '0001789945200000-0001-aparelhoA',
      );
    },
  );

  group('G06 — fila por dono', () {
    const outraConta = '0199a7c4-2f00-7a10-8b20-0000000000ff';

    test('Pro: só as linhas do dono ativo entram na fila (outra conta guardada não sobe)', () async {
      await KvDao(db).set(syncModeKey, syncModePro);
      await KvDao(db).set(activeOwnerKey, usuarioTeste);
      await UserBooksDao(db).upsert(livroTeste(1));
      await UserBooksDao(db).upsert(livroTeste(2, dono: outraConta));
      await AnnotationsDao(db)
          .upsert(grifoTeste(3, livro: idTeste(2), dono: outraConta));
      final lote = (await ps.getCrudBatch(limit: 500))!;
      expect(lote.crud.map((e) => e.id), [idTeste(1)]);
    });

    test('Pro sem dono ativo registrado: nada entra na fila', () async {
      await KvDao(db).set(syncModeKey, syncModePro);
      await UserBooksDao(db).upsert(livroTeste(1));
      expect(await fila(), 0);
    });

    test('virar Pro: enqueueAllSql põe toda linha do dono (inclusive apagada) como PUT; de outro dono, não', () async {
      await UserBooksDao(db).upsert(livroTeste(1));
      await UserBooksDao(db).upsert(livroTeste(2, apagado: true));
      await UserBooksDao(db).upsert(livroTeste(3, dono: outraConta));
      await AnnotationsDao(db).upsert(grifoTeste(4, livro: idTeste(1)));
      expect(await fila(), 0);
      await ps.writeTransaction((tx) async {
        for (final t in personalSyncColumns.keys) {
          await tx.execute(enqueueAllSql(t), [usuarioTeste]);
        }
      });
      final lote = (await ps.getCrudBatch(limit: 500))!;
      expect(lote.crud.map((e) => (e.op, e.table, e.id)), [
        (UpdateType.put, 'user_books', idTeste(1)),
        (UpdateType.put, 'user_books', idTeste(2)),
        (UpdateType.put, 'annotations', idTeste(4)),
      ]);
      final apagado = lote.crud[1].opData!;
      expect(apagado.keys.toSet(), personalSyncColumns['user_books']!.toSet());
      expect(apagado['deleted_at'], isNotNull);
      expect(apagado['version_hlc'], '0001789945200000-0000-aparelhoA');
    });

    test(
      'disconnectAndClear(clearLocal: false): a fila esvazia e as linhas ficam',
      () async {
        await KvDao(db).set(syncModeKey, syncModePro);
        await KvDao(db).set(activeOwnerKey, usuarioTeste);
        await UserBooksDao(db).upsert(livroTeste(1));
        expect(await fila(), 1);
        await ps.disconnectAndClear(clearLocal: false);
        expect(await fila(), 0);
        expect(await UserBooksDao(db).byId(idTeste(1)), isNotNull);
        expect(await KvDao(db).get(syncModeKey), syncModePro);
      },
    );

    test('os gatilhos da fila são recriados ao abrir o banco (regra antiga é trocada)', () async {
      // regra antiga (G03): sem o filtro do dono
      await ps.execute('DROP TRIGGER user_books_queue_insert');
      await ps.execute(
        'CREATE TRIGGER user_books_queue_insert AFTER INSERT ON user_books '
        "FOR EACH ROW BEGIN INSERT INTO powersync_crud (op, id, type, data) VALUES ('PUT', NEW.id, "
        "'user_books', json_object('user_id', NEW.user_id)); END",
      );
      await db.close();
      await ps.close();
      ps = PowerSyncDatabase(schema: buildPowerSyncSchema(), path: caminho);
      await ps.initialize();
      db = AppDatabase(SqliteAsyncDriftConnection(ps));
      await db.customSelect('SELECT 1').get();
      await KvDao(db).set(syncModeKey, syncModePro);
      await KvDao(db).set(activeOwnerKey, usuarioTeste);
      await UserBooksDao(db).upsert(livroTeste(1, dono: outraConta));
      expect(await fila(), 0);
      await UserBooksDao(db).upsert(livroTeste(2));
      expect(await fila(), 1);
    });
  });

  group('instruções do servidor (aplicadas pelo PowerSync)', () {
    List<Object?> valores(Map<String, Object?> linha) => [
      linha['id'],
      for (final c in personalSyncColumns['user_books']!) linha[c],
    ];

    Future<Map<String, Object?>> lerLivro() async => Map.of(
      await ps.get("SELECT * FROM user_books WHERE id = '${idTeste(1)}'"),
    );

    test(
      'put: last-writer-wins pelo version_hlc; colunas novas vão para _extras',
      () async {
        await UserBooksDao(db).upsert(livroTeste(1));
        final atual = await lerLivro();

        // versão mais antiga do servidor: não sobrescreve
        final antiga = {
          ...atual,
          'title': 'Velho',
          'version_hlc': '0001789945100000-0000-aparelhoB',
        };
        await ps.execute(rawTablePutSql('user_books'), [
          ...valores(antiga),
          null,
        ]);
        expect((await lerLivro())['title'], 'Dom Casmurro');

        // versão mais nova: aplica, e guarda o que o app não conhece
        final nova = {
          ...atual,
          'title': 'Novo',
          'version_hlc': '0001789945300000-0000-aparelhoB',
        };
        await ps.execute(rawTablePutSql('user_books'), [
          ...valores(nova),
          jsonEncode({'lang': 'pt-BR'}),
        ]);
        final depois = await lerLivro();
        expect(depois['title'], 'Novo');
        expect(jsonDecode(depois['_extras'] as String), {'lang': 'pt-BR'});
        expect(await UserBooksDao(db).byId(idTeste(1)), isNotNull);
        expect(await fila(), 0);
      },
    );

    test('delete: NÃO apaga a linha do aparelho — só registra', () async {
      await UserBooksDao(db).upsert(livroTeste(1));
      await ps.execute(rawTableDeleteSql('user_books'), [idTeste(1)]);
      expect(await UserBooksDao(db).byId(idTeste(1)), isNotNull);
      final log = await ps.getAll('SELECT * FROM sync_ignored_deletes');
      expect(log, hasLength(1));
      expect(log.single['entity'], 'user_books');
      expect(log.single['row_id'], idTeste(1));
      expect(log.single['received_at'] as String, endsWith('Z'));
    });
  });
}

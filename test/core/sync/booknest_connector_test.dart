// G06.1 — conector do PowerSync: credenciais só para quem o servidor confirma como Pro; upload em
// lotes de até 500 PUT com a linha inteira; recusas por linha guardadas com a operação inteira e
// telemetria sem conteúdo; `pro_required` desliga; falha da chamada repete com recuo e nada sai da fila.
import 'dart:convert';

import 'package:app_leitura/core/data/database/daos/annotation_daos.dart';
import 'package:app_leitura/core/data/database/daos/library_daos.dart';
import 'package:app_leitura/core/data/database/local_sql.dart';
import 'package:app_leitura/core/sync/booknest_connector.dart';
import 'package:app_leitura/core/sync/sync_backend.dart';
import 'package:app_leitura/core/sync/sync_store.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/personal_builders.dart';
import 'support/sync_fakes.dart';

void main() {
  late DbTeste t;
  late FakeSyncBackend servidor;
  late OuvinteTeste ouvinte;
  late TelemetriaTeste telemetria;
  late List<int> recuos;
  late BookNestConnector c;
  var relogio = 1000;

  setUp(() async {
    t = await DbTeste.abrir();
    servidor = FakeSyncBackend(userId: usuarioTeste);
    ouvinte = OuvinteTeste();
    telemetria = TelemetriaTeste();
    recuos = [];
    c = BookNestConnector(
      endpoint: 'http://powersync.teste',
      backend: servidor,
      store: SyncStore(t.db),
      listener: ouvinte,
      deviceNowMs: () => relogio += 100,
      telemetry: telemetria,
      backoffFor: (n) {
        recuos.add(n);
        return Duration.zero;
      },
    );
  });
  tearDown(() => t.fechar());

  group('fetchCredentials', () {
    test(
      'Pro: endpoint, JWT da sessão e o usuário; mede a hora (ida e volta)',
      () async {
        final cred = (await c.fetchCredentials())!;
        expect(cred.endpoint, 'http://powersync.teste');
        expect(cred.token, 'jwt-teste');
        expect(cred.userId, usuarioTeste);
        expect(cred.expiresAt, DateTime.utc(2026, 10, 4, 13));
        expect(ouvinte.consultas, hasLength(1));
        final (ida, volta) = ouvinte.instantes.single;
        expect(volta > ida, isTrue);
        expect(ouvinte.proPerdido, 0);
      },
    );

    test('sem sessão: nada (nem consulta o Pro)', () async {
      servidor.token = null;
      expect(await c.fetchCredentials(), isNull);
      expect(servidor.consultasDoPro, 0);
    });

    test('o servidor diz que não é Pro: sem credencial e avisa (desligar sem apagar)', () async {
      servidor.entitlementAtual = const Entitlement(
        pro: false,
        activeUntil: null,
        serverTimeMs: null,
      );
      expect(await c.fetchCredentials(), isNull);
      expect(ouvinte.proPerdido, 1);
    });

    test('consulta do Pro sem rede: lança (o PowerSync tenta de novo) e registra só o tipo', () async {
      servidor.falhasDoPro.add(const SyncTransient('rede'));
      await expectLater(c.fetchCredentials(), throwsA(isA<SyncTransient>()));
      expect(ouvinte.proPerdido, 0);
      expect(telemetria.eventos, ['falha:credenciais_rede']);
    });
  });

  group('uploadData', () {
    Future<void> semear(int livros) async {
      await t.modoPro(usuarioTeste);
      for (var i = 1; i <= livros; i++) {
        await UserBooksDao(t.db).upsert(livroTeste(i));
      }
    }

    test('1.203 operações → lotes de 500, 500 e 203, no formato da RPC; a fila esvazia', () async {
      await semear(1203);
      expect(await t.fila(), 1203);
      await c.uploadData(t.ps);
      expect(servidor.lotes.map((l) => l.length), [500, 500, 203]);
      final op = servidor.lotes.first.first;
      expect(op['op'], 'PUT');
      expect(op['table'], 'user_books');
      expect(op['id'], idTeste(1));
      final dados = op['data']! as Map;
      expect(dados.keys.toSet(), personalSyncColumns['user_books']!.toSet());
      expect(op['hlc'], dados['version_hlc']);
      expect(await t.fila(), 0);
      expect(ouvinte.lotes, hasLength(3));
    });

    test('recusa por linha: sai da fila, fica no aparelho com a operação inteira; telemetria sem conteúdo', () async {
      await semear(1);
      await AnnotationsDao(t.db).upsert(grifoTeste(2, livro: idTeste(1)));
      servidor.recusar[idTeste(2)] = (
        'insert or update violates foreign key',
        '23503',
      );
      await c.uploadData(t.ps);
      expect(await t.fila(), 0);
      final r = await t.ps.getAll('SELECT * FROM sync_rejections');
      expect(r, hasLength(1));
      expect(r.single['entity'], 'annotations');
      expect(r.single['row_id'], idTeste(2));
      expect(r.single['code'], '23503');
      final op = jsonDecode(r.single['operation'] as String) as Map;
      expect(op['op'], 'PUT');
      expect((op['data'] as Map)['note_text'], isNull);
      expect((op['data'] as Map).keys, contains('anchor'));
      expect(telemetria.eventos, ['recusa:annotations:23503']);
      expect(
        telemetria.eventos.join(),
        isNot(contains('Capitu')),
        reason: 'nada do conteúdo na telemetria',
      );
      expect(await AnnotationsDao(t.db).forBook(idTeste(1)), hasLength(1));
    });

    test('o mesmo lote reenviado (app fechou antes de tirar da fila) não duplica a recusa', () async {
      await semear(1);
      servidor.recusar[idTeste(1)] = ('invalid_hlc', '22023');
      final lote = (await t.ps.getCrudBatch(limit: 500))!;
      final ops = [for (final e in lote.crud) BookNestConnector.changeOf(e)];
      final store = SyncStore(t.db);
      final r = (await servidor.applyChanges(ops)).rejected;
      await store.recordRejections(r, ops);
      await store.recordRejections(r, ops);
      expect(await store.rejectionCount(), 1);
    });

    test(
      'pro_required: avisa, lança e a fila fica (ela é limpa ao desligar)',
      () async {
        await semear(3);
        servidor.falhasDaRpc.add(const ProRequired());
        await expectLater(c.uploadData(t.ps), throwsA(isA<ProRequired>()));
        expect(ouvinte.proPerdido, 1);
        expect(await t.fila(), 3);
        expect(recuos, isEmpty);
      },
    );

    test('falha da chamada (rede, 5xx, trava): nada sai da fila; recuo 1, 2, 3… e zera ao subir', () async {
      await semear(2);
      servidor.falhasDaRpc.addAll(const [
        SyncTransient('rede'),
        SyncTransient('pg_40001'),
        SyncTransient('pg_503'),
      ]);
      for (var i = 0; i < 3; i++) {
        await expectLater(c.uploadData(t.ps), throwsA(isA<SyncTransient>()));
        expect(await t.fila(), 2);
      }
      expect(recuos, [1, 2, 3]);
      expect(c.consecutiveFailures, 3);
      await c.uploadData(t.ps);
      expect(await t.fila(), 0);
      expect(c.consecutiveFailures, 0);
      expect(telemetria.eventos, [
        'falha:rede',
        'falha:pg_40001',
        'falha:pg_503',
      ]);
    });
  });

  test('recuo exponencial: 1 s, 2 s, 4 s … até 60 s', () {
    expect(
      [for (var n = 1; n <= 8; n++) syncBackoff(n).inSeconds],
      [1, 2, 4, 8, 16, 32, 60, 60],
    );
  });

  test('Backoff: desconectar interrompe a espera', () async {
    final b = Backoff();
    final espera = b.wait(const Duration(hours: 1));
    b.wakeUp();
    await espera.timeout(const Duration(seconds: 1));
  });
}
